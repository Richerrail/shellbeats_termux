# ShellBeats — Port Termux (Android)

Ce fork adapte ShellBeats pour fonctionner sur **Termux** (Android).

## Différences avec l'original

| Problème | Original | Ce fork |
|----------|----------|---------|
| Socket IPC mpv | `/tmp/shellbeats_mpv.sock` | `$TMPDIR/shellbeats_mpv.sock` |
| Temp deno/zip | `/tmp/shellbeats_deno_*.zip` | `$TMPDIR/shellbeats_deno_*.zip` |
| Fallback HOME absent | `/tmp` | `$TMPDIR` |
| Musique par défaut | `~/Music/shellbeats` | `$EXTERNAL_STORAGE/Music/shellbeats` si disponible |
| Makefile | Linux/macOS seulement | Détecte Termux via `uname -o` |

## Installation rapide

```bash
# Cloner ce repo
git clone https://github.com/richerrail/shellbeats_termux
cd shellbeats

# Tout installer en une commande
bash install-termux.sh
```

## Installation manuelle

```bash
# 1. Dépendances
pkg update && pkg install git clang make libcurl libcjson ncurses mpv yt-dlp

# 2. (Optionnel mais recommandé) Runtime JS pour yt-dlp
pkg install nodejs

# 3. Compiler
make && make install
```

## Accès au stockage

Pour sauvegarder la musique sur la carte SD/stockage interne :

```bash
termux-setup-storage
```

Les téléchargements seront alors dans `/sdcard/Music/shellbeats/`.

## Notes Termux

- **`/tmp` n'existe pas** sur Android. Ce fork utilise `$TMPDIR` (généralement `/data/data/com.termux/files/usr/tmp`).
- **`deno`** n'est pas dans les paquets Termux. Installe `nodejs` à la place — yt-dlp l'utilisera automatiquement.
- **mpv** est disponible via `pkg install mpv` et supporte l'IPC Unix socket.
- Le **socket Unix** a une limite de longueur de chemin (108 chars sur Linux). Si ton `$TMPDIR` est très long, mpv peut refuser de démarrer. Dans ce cas, définis `TMPDIR=/tmp` avant de lancer shellbeats.

## Utilisation

```bash
shellbeats
```

Toutes les commandes sont identiques à l'original — voir le [README principal](README.md).

## Dépannage

**mpv ne démarre pas / pas de son**
```bash
# Tester mpv manuellement
mpv --no-video https://www.youtube.com/watch?v=dQw4w9WgXcQ
```

**yt-dlp échoue**
```bash
yt-dlp --update
# ou
pip install -U yt-dlp
```

**Erreur "socket path too long"**
```bash
export TMPDIR=/data/local/tmp
shellbeats
```
