# todo: prevent from being executed

if [ -z $POKEMON_DIR ]; then
    echo "POKEMON_DIR is not defined, did you export it?"
    exit 2
fi

get_spells_as_array() 
{
    local name="$1"
    local pokemon_json="$2"
    
    #set -x
    # on convertir un tableau json en équivalent bash
    local spells_array=($(jq -r '.spells[]' "$pokemon_json"))
    echo ${spells_array[@]}
}

display_spells () {
    local name="$1"
    local pokemon_json="$2"

    local spells_array=($(get_spells_as_array $name $pokemon_json))

    for spell in "${spells_array[@]}"; do
        echo " - $spell"
    done
}

cast_spell() 
{ # 
    local name="$1"
    local pokemon_json="$POKEMON_DIR/$name/$name.json"    
    # demande à l'utilisateur quel sort il veut lancer


    
    local spells_array=($(get_spells_as_array $name $pokemon_json))

    local ok=false

    while true; do

        echo "Sorts disponibles :"
        display_spells $name $pokemon_json
        
        read -p "> " selected_spell
        for spell in ${spells_array[@]}; do 
            echo "testing $spell"
            [[ "$selected_spell" == "$spell" ]] && ok=true && break
        done
        if ! $ok; then echo "Veuillez entrer un sort valide!"; else break; fi
    done

    local spell_script="$POKEMON_DIR/$name/spells/$spell.sh"

    echo $spell_script
    
    if [ -f "$spell_script" ]; then
        echo "[$name utilise $spell !]"
        bash "$spell_script"
    else
        echo "Sort $spell non trouvé pour $name."
    fi
}

attack() 
{ # todo perform an attack based on the pokemon strength
    local name="$1"
    echo "$name attaque son adversaire et lui inflige $(($RANDOM%25)) dégâts !"
}

show() 
{ # display ascii art
    local name="$1"
    local art="$POKEMON_DIR/$name/$name.art"

    if [ -f $art ]; then
        cat $art
    fi
}

flee() 
{
    local name="$1"
    show $name
    echo "$name amorçe une manoeuvre d'extraction et fuit lâchement le combat !"
}

help() 
{
    local name="$1"
    local pokemon_json="$POKEMON_DIR/$name/$name.json"
    echo $pokemon_json

    local spells=()
    #set -x
    spells=$(jq -r -c '.spells|@sh' $pokemon_json)

    echo "spells: ${spells[*]}"

    echo "Usage: $name cast ${spells/ /|}"

}