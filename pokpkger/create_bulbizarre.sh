#!/usr/bin/env bash
set -ex # stop on error 

# https://www.angelfire.com/mn/Maija/pokemon/
# Arborescence de bulbizarre.tar.gz :
# bulbizarre/
# ├── bulbizarre.art
# ├── bulbizarre.json
# └── spells/
#     ├── charge.sh
#     └── poison.sh

TMP_DIR="/tmp"

POKEMON_NAME="Bulbizarre"
DESCRIPTION="Un Pokémon de type plante et poison."
# SPELLS=("charge" "poison")

TAR_NAME="$POKEMON_NAME.tar.gz"

mkdir -p "$TMP_DIR/$POKEMON_NAME/spells"

# Fichier : bulbizarre/bulbizarre.art
cat <<'EOF' > "$TMP_DIR/$POKEMON_NAME/${POKEMON_NAME}.art"
       _.--""`-..
     ,'          `.
   ,'          __  `.
  /|          " __   \
 , |           / |.   .
 |,'          !_.'|   |
,'             '   |   |
/              |\`--'|   |
|                \`---'   |
 .   ,                   |                       ,".
  ._     '           _'  |                    , ' \\ `.
EOF

# Fichier : bulbizarre/bulbizarre.json
cat <<EOF > "$TMP_DIR/$POKEMON_NAME/${POKEMON_NAME}.json"
{
  "name": "$POKEMON_NAME",
  "version": "1.0",
  "description": "$DESCRIPTION",
  "spells": ["charge", "poison"]
}
EOF

# Fichier : bulbizarre/spells/charge.sh
cat <<EOF > $TMP_DIR/$POKEMON_NAME/spells/charge.sh
#!/bin/bash
echo "Bulbizarre fonce sur l'adversaire avec CHARGE !"
EOF
chmod +x $TMP_DIR/$POKEMON_NAME/spells/charge.sh

# Fichier : bulbizarre/spells/poison.sh
cat <<EOF > $TMP_DIR/$POKEMON_NAME/spells/poison.sh
#!/bin/bash
echo "Bulbizarre utilise POISON sur son adversaire !"
EOF
chmod +x $TMP_DIR/$POKEMON_NAME/spells/poison.sh

# Compression du paquet
tar -czf "$TAR_NAME" -C "$TMP_DIR/$POKEMON_NAME/" .
echo "Paquet $TAR_NAME créé."
echo "Voulez-vous effacer les fichiers temporaires ?"