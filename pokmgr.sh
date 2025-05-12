#!/bin/bash

# répertoire local 
POKEMON_DIR="$HOME/.pokemons"
# fichier local des pokemons installés
export POKEDEX_FILE="$POKEMON_DIR/pokedex.json"
# serveur web
SERVER_URL="http://localhost:8000/repo"  

mkdir -p "$POKEMON_DIR"

update_user_pokedex() 
{ # mise à jour du pokedex local
    # fichier de description du pokémon à ajouter
    pokemon_name=$1
    pokemon_json="$POKEMON_DIR/$pokemon_name/$pokemon_name.json"

    echo $pokemon_json $pokemon_name $POKEDEX_FILE
    # on vérifie que le pokemon n'existe pas déjà dans le pokedex
    local entry=$(jq -c --arg name $pokemon_name '.[] | select(.name|test($name; "i"))' $POKEDEX_FILE)
    echo ":$entry:"

    if [ -n "$entry" ]; then
        # check version
        echo "found entry: $entry"
        
    else 
        # add entry if it does not exist
        echo "Mise à jour du pokedex utilisateur avec: $entry"

         # Lire le JSON complet de pikachu.json dans une variable
        NEW_ENTRY=$(<"$POKEMON_FILE")

        # Injecter dans le tableau
        # jq --argjson new "$NEW_ENTRY" '. += [$new]' "$POKEDEX_FILE" > tmp.json && mv tmp.json "$POKEDEX_FILE"
    
        jq --slurpfile newPokemon "$pokemon_json" '. + $newPokemon' "$POKEDEX_FILE" > tmp.json && mv tmp.json "$POKEDEX_FILE"
    fi
}

fetch_data_to_file() 
{ # fetch data from url and store it to given location
    data_url=$1
    file_to=$2
    
    # -s : silent
    # -o : output
    curl -s -o $file_to $data_url

    if [ $? -ne 0 ]; then echo "Erreur de téléchargement de $data_url"; exit 1; fi
}

install_pokemon() 
{ # installation du pokémon dans le répertoire local
    name="$1"

    if [ -d "$POKEMON_DIR/$name" ]; then
        echo "$name est déjà installé."
        return
    fi
    echo "Installation de $name..."
    
    # curl -s -o "/tmp/$name.tar.gz" "$SERVER_URL/$name.tar.gz"
    fetch_data_to_file "$SERVER_URL/$name.tar.gz" "/tmp/$name.tar.gz"
    
    # création du répertoire pour stocker le pokémon
    mkdir -p "$POKEMON_DIR/$name"
    # on décompresse l'archive dans un sous-répertoire du nom du pokémon
    tar -xzf "/tmp/$name.tar.gz" -C "$POKEMON_DIR/$name"

    echo "$name installé avec succès."
}

uninstall_pokemon() {
    name="$1"

    if [ -d "$POKEMON_DIR/$name" ]; then
        read -p "Êtes-vous sûr de vouloir désinstaller '$POKEMON_NAME' ? [y/N] " confirm
    else 
        echo "$name n'est pas installé"
        return 1
    fi

    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        echo "$name est en cours de désinstallation"
        rm -rf $POKEMON_DIR/$name
        # update json file...
        jq "map(select(.name != \"$name\"))" "$POKEDEX_FILE" > "$POKEDEX_FILE.tmp" && mv "$POKEDEX_FILE.tmp" "$POKEDEX_FILE"
    fi
}

list_local() {
    echo "Pokémons installés :"
    for dir in "$POKEMON_DIR"/*; do
        [ -d "$dir" ] || continue
        # list of json
        json_file="$dir/*.json"
        echo "found json: " $json_file
        if [ -f $json_file ]; then
            # lecture du nom (-r = raw)
            name=$(jq -r .name $json_file)
            # lecture de la description 
            desc=$(jq -r .description $json_file)
            echo "- $name: $desc"
        fi
    done
}

list_remote() {
    [ -f "$POKEDEX_FILE" ] || update_pokedex
    echo "Pokémons disponibles :"
    jq -c '.[]' "$POKEDEX_FILE" | while read -r pokemon; do
        name=$(echo "$pokemon" | jq -r .name)
        echo "- $name"
    done
}

perform_action() 
{ # pokemon action

    local name=$1

    # affiche un prompt à l'utilisateur
    prompt_user $name
    local action=$?
}

prompt_user() {
    local name="$1"
    local action

    echo "Vous avez invoqué $name"

    echo "Que voulez-vous faire ?
    1) Lancer un sort
    2) Fuir
    3) Attaquer"

    while true; do
        read -p "Entrez le numéro de votre choix [1-3] : " action
        if [[ "$action" =~ ^[1-3]$ ]]; then
            break
        else
            echo "Choix invalide. Veuillez entrer 1, 2 ou 3."
        fi
    done

        
    case "$action" in
    1)      
        cast_spell $name
    ;;
    2)    
        flee $name
    ;;
    3)    
        attack $name
    ;;
    *)  echo "Error: invalid action $action" 
    ;;
    esac

    return "$action"
}




update_pokedex() {
    echo "Mise à jour du pokédex..."

    # curl -s -o "$POKEDEX_FILE" "$SERVER_URL/pokedex.json"
    # on écrase le fichier s'il existe
    fetch_data_to_file "$SERVER_URL/pokedex.json" "$POKEDEX_FILE"

    echo "Pokedex mis à jour."
}


upgrade_pokemons() {
    # on fait un update avant
    [ -f "$POKEDEX_FILE" ] || update_pokedex

    for dir in "$POKEMON_DIR"/*/; do
        [ -d "$dir" ] || continue
        # extraction du nom du pokémon depuis celui du répertoire
        name=$(basename "$dir")
        # version locale
        local_ver=$(jq -r .version "$dir"/*.json)
        # version du serveur
        remote_ver=$(jq -r --arg name "$name" 'map(select(.name==$name)) | .[0].version' "$POKEDEX_FILE")
        
        if [ "$local_ver" != "$remote_ver" ]; then
            echo "Mise à jour de $name ($local_ver -> $remote_ver)..."
            rm -rf "$dir"
            install_pokemon "$name"
        fi
    done
}

search_pokemons() 
{ # cherche les pokémons par nom ou par type
    local type="$1"

    [ -f "$POKEDEX_FILE" ] || update_pokedex

    echo "Trouvés :"
    jq -c '.[]' "$POKEDEX_FILE" | while read -r pokemon; do
        pokname=$(echo "$pokemon" | jq -r .name)
        poktype=$(echo "$pokemon" | jq -r .type)
       # echo "$pokname"
       # echo "$poktype"
  
        if [[ "$poktype" == "$type" ]]; then 
            echo "- $pokname ($poktype)"
        fi
    done
}

whipta() {
    #!/bin/bash

    CHOICE=$(whiptail --title "Pokémon: Attrapez les tous !" --menu "Que voulez-vous faire ?" 15 60 4 \
    "1" "Lancer un sort" \
    "2" "Fuir" \
    "3" "Attaquer" \
    "4" "Quitter" 3>&1 1>&2 2>&3)

    exitstatus=$?

    if [ $exitstatus -eq 0 ]; then
        case $CHOICE in
            1)
                echo "Vous lancez un sort !"
                whiptail --title "Example Title" --infobox "This is an example info box." 8 70
                ;;
            2)
                echo "Vous tentez de fuir..."
                ;;
            3)
                echo "Vous attaquez !"
                ;;
            4)
                echo "À bientôt !"
                ;;
        esac
    else
        echo "Annulé par l'utilisateur."
    fi
}

whiptail --title "Example Title" --msgbox "This is an example message box. Press OK to continue." 8 70

# whipta

# load common.sh
if [ -e "./common.sh" ]; then
    echo "Loading common.sh"
    . ./common.sh
fi

case "$1" in
    install)     install_pokemon "$2" ;;
    remove)      uninstall_pokemon "$2" ;;
    list)        list_local  ;;
    list-remote) list_remote ;;
    update)      update_pokedex ;;
    upgrade)     upgrade_pokemons ;;
    run)         shift 1; prompt_user "$@" ;;
    search)      search_pokemons "$2" ;;
    *)           echo "Usage: pokmgr {install|remove|list|list-remote|update|upgrade|run <pokemon>}" ;;
esac
