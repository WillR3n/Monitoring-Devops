#!/bin/bash

# ============================================================
# traitement.sh — Script CGI
# Reçoit les données du formulaire HTML, lance la collecte
# automatique et sauvegarde tout dans data_bulletin.txt
# BICEC — Bulletin Qualité TFJO
# ============================================================

# En-tête CGI obligatoire
echo "Content-type: text/html; charset=utf-8"
echo ""

# ============================================================
# ÉTAPE 1 — Lire les données envoyées par le formulaire
# ============================================================

read POST_DATA

# Fonction de décodage URL (%20 → espace, + → espace, etc.)
url_decode() {
    echo "$1" | sed 's/+/ /g' | python3 -c "import sys, urllib.parse; print(urllib.parse.unquote(sys.stdin.read().strip()))"
}

# Extraction de chaque champ du formulaire
AMPLITUDE=$(url_decode "$(echo "$POST_DATA" | grep -o 'AMPLITUDE=[^&]*' | cut -d= -f2)")
PCA=$(url_decode "$(echo "$POST_DATA" | grep -o 'PCA=[^&]*' | cut -d= -f2)")
STREAMSERVE=$(url_decode "$(echo "$POST_DATA" | grep -o 'STREAMSERVE=[^&]*' | cut -d= -f2)")
SWIFT=$(url_decode "$(echo "$POST_DATA" | grep -o 'SWIFT=[^&]*' | cut -d= -f2)")
TAUX_JOUR=$(url_decode "$(echo "$POST_DATA" | grep -o 'TAUX_JOUR=[^&]*' | cut -d= -f2)")
TAUX_MOIS=$(url_decode "$(echo "$POST_DATA" | grep -o 'TAUX_MOIS=[^&]*' | cut -d= -f2)")
HAS_INCIDENT=$(url_decode "$(echo "$POST_DATA" | grep -o 'HAS_INCIDENT=[^&]*' | cut -d= -f2)")
INCIDENT=$(url_decode "$(echo "$POST_DATA" | grep -o 'INCIDENT=[^&]*' | cut -d= -f2)")
ACTION=$(url_decode "$(echo "$POST_DATA" | grep -o 'ACTION=[^&]*' | cut -d= -f2)")
DUREE_INCIDENT=$(url_decode "$(echo "$POST_DATA" | grep -o 'DUREE_INCIDENT=[^&]*' | cut -d= -f2)")

# Récupération des autres traitements (dynamiques)
AUTRES_TRAITEMENTS=""
i=0
while true; do
    VAL=$(url_decode "$(echo "$POST_DATA" | grep -o "AUTRE_${i}=[^&]*" | cut -d= -f2)")
    if [ -z "$VAL" ]; then
        break
    fi
    AUTRES_TRAITEMENTS="$AUTRES_TRAITEMENTS\nAUTRE_$i=$VAL"
    i=$((i + 1))
done
NB_AUTRES=$i

# ============================================================
# ÉTAPE 2 — Collecte automatique (données simulées)
# À remplacer par : source /projet/scripts/script_bd.sh
#                   source /projet/scripts/script_logs.sh
# quand les vrais scripts seront disponibles
# ============================================================

# --- Données BD (simulées) ---
DEBUT_SAUVE_AVANT="19H40"
DEBUT_TFJ="19H42"
FIN_TFJ="00H11"
DUREE_TFJ="04H18"
FIN_SAUVE_APRES="00H27"
NB_EVENEMENTS="83788"
NB_MOUVEMENTS="109870"

# --- Données Logs (simulées) ---
OUVERTURE_SITE="00H20"
AUTORISATION="07H25"
DCO="05/02/2026"
TRANSFERT_SMS="03H33"

# ============================================================
# ÉTAPE 3 — Sauvegarder tout dans data_bulletin.txt
# ============================================================

DATA_FILE="/projet/data/data_bulletin.txt"

# Créer le dossier si inexistant
mkdir -p /projet/data

cat > "$DATA_FILE" << EOF
# ============================================================
# data_bulletin.txt
# Généré automatiquement le $(date '+%d/%m/%Y à %H:%M:%S')
# ============================================================

# === DONNÉES MANUELLES (saisies par le moniteur) ===
AMPLITUDE=$AMPLITUDE
PCA=$PCA
STREAMSERVE=$STREAMSERVE
SWIFT=$SWIFT
TAUX_JOUR=$TAUX_JOUR
TAUX_MOIS=$TAUX_MOIS
HAS_INCIDENT=$HAS_INCIDENT
INCIDENT=$INCIDENT
ACTION=$ACTION
DUREE_INCIDENT=$DUREE_INCIDENT
NB_AUTRES=$NB_AUTRES
EOF

# Ajouter les autres traitements
i=0
while true; do
    VAL=$(url_decode "$(echo "$POST_DATA" | grep -o "AUTRE_${i}=[^&]*" | cut -d= -f2)")
    if [ -z "$VAL" ]; then
        break
    fi
    echo "AUTRE_$i=$VAL" >> "$DATA_FILE"
    i=$((i + 1))
done

cat >> "$DATA_FILE" << EOF

# === DONNÉES AUTOMATIQUES — BASE DE DONNÉES ===
DEBUT_SAUVE_AVANT=$DEBUT_SAUVE_AVANT
DEBUT_TFJ=$DEBUT_TFJ
FIN_TFJ=$FIN_TFJ
DUREE_TFJ=$DUREE_TFJ
FIN_SAUVE_APRES=$FIN_SAUVE_APRES
NB_EVENEMENTS=$NB_EVENEMENTS
NB_MOUVEMENTS=$NB_MOUVEMENTS

# === DONNÉES AUTOMATIQUES — LOGS ===
OUVERTURE_SITE=$OUVERTURE_SITE
AUTORISATION=$AUTORISATION
DCO=$DCO
TRANSFERT_SMS=$TRANSFERT_SMS

# === DATE DE GÉNÉRATION ===
DATE_BULLETIN=$(date '+%d/%m/%Y')
HEURE_BULLETIN=$(date '+%H:%M:%S')
EOF

# ============================================================
# ÉTAPE 4 — Lancer la génération du bulletin HTML
# ============================================================

# À activer quand generate_bulletin.sh sera prêt :
# bash /projet/generate_bulletin.sh

# ============================================================
# ÉTAPE 5 — Réponse au navigateur
# ============================================================

cat << HTML
<!DOCTYPE html>
<html lang="fr">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>Traitement — BICEC</title>
  <style>
    body { font-family: sans-serif; background: #FAF7F4; display: flex; align-items: center; justify-content: center; min-height: 100vh; margin: 0; }
    .box { background: white; border-radius: 14px; padding: 40px 48px; box-shadow: 0 2px 20px rgba(64,18,2,0.08); text-align: center; max-width: 480px; border-top: 4px solid #D96704; }
    h2 { color: #401202; font-size: 20px; margin-bottom: 10px; }
    p { color: #6B6B6B; font-size: 14px; line-height: 1.6; margin-bottom: 20px; }
    a { display: inline-block; padding: 11px 28px; background: #D96704; color: white; border-radius: 8px; text-decoration: none; font-size: 14px; font-weight: 600; }
    a:hover { background: #bf5a03; }
    .check { font-size: 42px; margin-bottom: 16px; }
  </style>
</head>
<body>
  <div class="box">
    <div class="check">✅</div>
    <h2>Données sauvegardées !</h2>
    <p>Les données manuelles et automatiques ont été collectées et sauvegardées dans <strong>data_bulletin.txt</strong>.</p>
    <a href="/formulaire.html">Retour au formulaire</a>
  </div>
</body>
</html>
HTML
