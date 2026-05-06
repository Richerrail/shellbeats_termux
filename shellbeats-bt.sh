#!/data/data/com.termux/files/usr/bin/bash
# ============================================================
# ShellBeats — Contrôle Bluetooth via notification média
# Les boutons de ta manette/écouteurs Bluetooth contrôlent mpv
# Usage: bash shellbeats-bt.sh
# ============================================================

SOCKET="${TMPDIR}/shellbeats_mpv.sock"

send_mpv() {
    echo "$1" | socat - UNIX-CONNECT:"$SOCKET" 2>/dev/null
}

do_play_pause() {
    send_mpv '{"command":["cycle","pause"]}'
    update_notification
}

do_next() {
    send_mpv '{"command":["playlist-next","force"]}'
    sleep 0.5
    update_notification
}

do_prev() {
    send_mpv '{"command":["playlist-prev","force"]}'
    sleep 0.5
    update_notification
}

do_stop() {
    send_mpv '{"command":["stop"]}'
    termux-notification-remove shellbeats-media
    exit 0
}

get_current_title() {
    local result
    result=$(echo '{"command":["get_property","media-title"]}' \
        | socat - UNIX-CONNECT:"$SOCKET" 2>/dev/null)
    echo "$result" | python3 -c "
import sys,json
try:
    d=json.load(sys.stdin)
    print(d.get('data','ShellBeats'))
except:
    print('ShellBeats')
" 2>/dev/null || echo "ShellBeats"
}

update_notification() {
    local title
    title=$(get_current_title)
    termux-notification \
        --id shellbeats-media \
        --title "ShellBeats" \
        --content "$title" \
        --type media \
        --media-previous  "bash $(realpath $0) prev" \
        --media-play      "bash $(realpath $0) play_pause" \
        --media-pause     "bash $(realpath $0) play_pause" \
        --media-next      "bash $(realpath $0) next" \
        --ongoing \
        --alert-once \
        2>/dev/null
}

# Vérifier socat
if ! command -v socat >/dev/null 2>&1; then
    echo "Installation de socat..."
    pkg install socat -y
fi

# Vérifier termux-api
if ! command -v termux-notification >/dev/null 2>&1; then
    echo "Installe Termux:API : pkg install termux-api"
    exit 1
fi

# Vérifier que ShellBeats tourne
if [ ! -S "$SOCKET" ]; then
    echo "ShellBeats n'est pas en cours d'execution."
    echo "Lance d'abord: ~/shellbeats/shellbeats"
    exit 1
fi

# Gérer les appels depuis les boutons de la notification
case "$1" in
    play_pause) do_play_pause; exit 0 ;;
    next)       do_next;       exit 0 ;;
    prev)       do_prev;       exit 0 ;;
    stop)       do_stop;       exit 0 ;;
esac

# Premier lancement
echo "=== ShellBeats Bluetooth Controller ==="
echo "Notification media creee — utilise les boutons de tes ecouteurs !"
echo "(Ctrl+C pour quitter)"

update_notification

# Mise à jour du titre toutes les 5 secondes
while true; do
    sleep 5
    if [ -S "$SOCKET" ]; then
        update_notification
    else
        echo "ShellBeats s'est arrete."
        termux-notification-remove shellbeats-media
        break
    fi
done
