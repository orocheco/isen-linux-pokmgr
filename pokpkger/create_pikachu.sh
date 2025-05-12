#!/usr/bin/env bash
set -ex # stop on error 

# https://www.angelfire.com/mn/Maija/pokemon/
# Arborescence de bulbizarre.tar.gz :
# Pikachu/
# ├── Pikachu.art
# ├── Pikachu.json
# └── spells/
#     ├── strike.sh
#     └── thunder.sh

TMP_DIR="/tmp"

POKEMON_NAME="Pikachu"
DESCRIPTION="Un Pokémon de type foudre."
# SPELLS=("charge" "poison")

TAR_NAME="$POKEMON_NAME.tar.gz"

mkdir -p "$TMP_DIR/$POKEMON_NAME/spells"

# Fichier : bulbizarre/bulbizarre.art
cat <<'EOF' > "$TMP_DIR/$POKEMON_NAME/${POKEMON_NAME}.art"
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢠⣶⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢰⠛⢿⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡏⠀⢸⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣰⠃⠀⠼⣄⡀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⡴⠋⠳⣄⠀⠀⢀⢎⣔⠀⠀⠀⠀⠉⠳⣄⠀⠀⠀⠀⠀
⠀⢠⠞⠁⠀⠀⠀⠹⣶⢛⠘⡋⠀⢠⣎⣦⠀⠀⠈⠙⠲⢤⡀⠀
⣰⠏⠀⠀⠀⠀⠀⠀⢰⠀⠰⡤⡀⠀⢛⣋⠀⠀⠰⣄⣀⣠⣿⣆
⠛⠒⠶⠶⢶⡶⠄⢀⣨⢦⡀⠢⠃⠀⠸⣿⠇⠀⢰⠃⠉⠉⠉⠉
⠀⠀⠀⠰⠿⣤⣀⠛⢧⣌⡇⠀⠀⠀⠀⠀⠰⠉⠙⢳⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⣼⣣⣞⣽⣇⠀⠈⠑⢄⠀⠐⢄⣀⣸⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠈⠛⣿⣿⠁⠉⠠⡀⠀⠀⡆⠀⠀⠀⢹⡀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠹⡿⠇⠀⠀⢈⠁⠊⠀⠀⠀⠀⠈⣇⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⣧⠀⠀⠀⢸⠀⠀⠀⠀⠀⠀⠀⢸⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⣸⠗⠀⣀⣦⣀⣤⣤⠴⠾⣄⡀⠺⡄⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠈⠉⠉⠁⠀⠀⠀⠀⠀⠀⠀⠉⠉⠁⠀⠀
EOF

# Fichier : bulbizarre/bulbizarre.json
cat <<EOF > "$TMP_DIR/$POKEMON_NAME/${POKEMON_NAME}.json"
{
  "name": "$POKEMON_NAME",
  "version": "1.0",
  "description": "$DESCRIPTION",
  "spells": ["fonce", "foudre"]
}
EOF

# Fichier : bulbizarre/spells/strike.sh
cat <<EOF > $TMP_DIR/$POKEMON_NAME/spells/fonce.sh
#!/bin/bash
echo "$POKEMON_NAME fonce sur l'adversaire en ignorant les obstacles !"
EOF
chmod +x $TMP_DIR/$POKEMON_NAME/spells/fonce.sh

# Fichier : bulbizarre/spells/foudre.sh
cat <<EOF > $TMP_DIR/$POKEMON_NAME/spells/foudre.sh
#!/bin/bash
echo "$POKEMON_NAME utilise FOUDRE sur son adversaire !"
EOF
chmod +x $TMP_DIR/$POKEMON_NAME/spells/foudre.sh

# Compression du paquet
tar -czf "$TAR_NAME" -C "$TMP_DIR/$POKEMON_NAME/" .
echo "Paquet $TAR_NAME créé."
echo "Voulez-vous effacer les fichiers temporaires ?"