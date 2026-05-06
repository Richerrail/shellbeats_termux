#!/data/data/com.termux/files/usr/bin/bash
# ============================================================
# ShellBeats — installateur Termux (Android)
# Usage: bash install-termux.sh
# ============================================================
set -e

echo "=== ShellBeats — Installation Termux ==="
echo ""

# 1. Dépendances
echo "[1/4] Installation des dépendances..."
pkg update -y
pkg install -y git clang make libcurl libcjson ncurses mpv yt-dlp

# Note: deno n'est PAS disponible dans pkg, mais yt-dlp sur Termux
# fonctionne sans lui grâce au fallback web_safari / iOS client.
# Si tu veux deno pour de meilleures performances:
#   pkg install nodejs   # node fonctionne comme runtime JS pour yt-dlp

echo ""
echo "[2/4] Compilation..."
make clean
make

echo ""
echo "[3/4] Installation du binaire..."
make install

echo ""
echo "[4/4] Vérification..."
if command -v shellbeats >/dev/null 2>&1; then
    echo "✓ shellbeats installé avec succès !"
    echo ""
    echo "Lance-le avec: shellbeats"
    echo ""
    echo "Conseil: Accorde l'accès au stockage pour sauvegarder"
    echo "la musique dans /sdcard/Music:"
    echo "  termux-setup-storage"
else
    echo "✗ Erreur: shellbeats introuvable dans le PATH"
    echo "  Essaie: $PREFIX/bin/shellbeats"
fi
