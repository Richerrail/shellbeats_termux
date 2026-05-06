# ShellBeats pour Android (Termux)

Fork de [lalo-space/shellbeats](https://github.com/lalo-space/shellbeats) adapté pour fonctionner sur **Termux** (Android).

ShellBeats est un lecteur de musique en ligne de commande qui joue de la musique YouTube directement dans ton terminal, sans interface graphique. Ce fork ajoute le support Android via Termux, les fichiers MP3 locaux, et le contrôle Bluetooth.

---

## Modifications apportées

| Problème original | Solution apportée |
|---|---|
| Socket IPC mpv dans `/tmp` | Utilise `$TMPDIR` (requis sur Android) |
| Fichiers temporaires dans `/tmp` | Utilise `$TMPDIR` |
| Fallback HOME absent → `/tmp` | Utilise `$TMPDIR` |
| Musique sauvegardée dans `~/Music` | Utilise `$EXTERNAL_STORAGE/Music` si disponible |
| Makefile Linux/macOS seulement | Détecte Termux automatiquement via `uname -o` |
| Pas de support fichiers locaux | Script `update-suno.py` pour playlists MP3 locales |
| Pas de contrôle Bluetooth | Script `shellbeats-bt.sh` via notification média Android |

---

## Installation

### 1. Prérequis

Installe les dépendances dans Termux :

```bash
pkg update
pkg install git clang make libcurl cjson ncurses mpv yt-dlp nodejs socat termux-api
```

> **Note :** `nodejs` est utilisé par yt-dlp comme runtime JavaScript. `socat` est nécessaire pour le contrôle Bluetooth.

### 2. Accès au stockage (recommandé)

Pour que ShellBeats puisse sauvegarder la musique sur ton stockage interne :

```bash
termux-setup-storage
```

Cela crée un lien `~/storage/music` vers ton dossier Music Android.

### 3. Cloner et compiler

```bash
git clone https://github.com/richerrail/shellbeats_termux
cd shellbeats_termux
make && make install
```

### 4. Lancer ShellBeats

```bash
shellbeats
```

---

## Contrôles de base

| Touche | Action |
|---|---|
| `Entrée` | Jouer la chanson sélectionnée |
| `Espace` | Pause / Reprendre |
| `n` | Chanson suivante |
| `p` | Chanson précédente |
| `R` | Mode aléatoire |
| `f` | Ouvrir les playlists |
| `d` | Télécharger la chanson |
| `D` | Télécharger toute la playlist |
| `q` | Quitter |

---

## Playlists MP3 locales (Suno, etc.)

Si tu as des fichiers MP3 sur ton téléphone (par exemple créés avec [Suno](https://suno.com)), tu peux les importer dans ShellBeats.

### Première fois

Mets tes MP3 dans ton dossier Music Android (`/sdcard/Music/`), puis lance :

```bash
python3 update-suno.py
```

Cela va :
1. Scanner tous les MP3 dans `~/storage/music/`
2. Les copier dans `~/Music/shellbeats/suno/` au bon format
3. Créer/mettre à jour la playlist `Suno` dans ShellBeats

### Mettre à jour la playlist

Quand tu ajoutes de nouveaux MP3, relance simplement :

```bash
python3 update-suno.py
```

### Ajouter dans le widget Termux

```bash
echo '#!/data/data/com.termux/files/usr/bin/bash
python3 ~/shellbeats_termux/update-suno.py' > ~/.shortcuts/UpdateSuno
chmod +x ~/.shortcuts/UpdateSuno
```

---

## Contrôle Bluetooth

Le script `shellbeats-bt.sh` crée une **notification média Android** qui permet de contrôler ShellBeats avec les boutons de tes écouteurs ou manette Bluetooth (⏮ ⏯ ⏭).

### Prérequis

- App **Termux:API** installée (F-Droid ou Play Store)
- `socat` installé : `pkg install socat`

### Utilisation

1. Lance ShellBeats normalement dans un terminal
2. Ouvre un **deuxième terminal** Termux (glisse depuis la gauche)
3. Lance le contrôleur Bluetooth :

```bash
bash ~/shellbeats_termux/shellbeats-bt.sh
```

Une notification apparaît dans ta barre Android avec les boutons ⏮ ⏯ ⏭. Tes écouteurs Bluetooth contrôlent ces boutons automatiquement.

### Ajouter dans le widget Termux

Pour lancer le contrôleur Bluetooth d'un seul tap depuis ton écran d'accueil :

```bash
cp ~/shellbeats_termux/shellbeats-bt.sh ~/.shortcuts/ShellBeats-BT
chmod +x ~/.shortcuts/ShellBeats-BT
```

Puis rafraîchis le widget Termux sur ton écran d'accueil.

---

## Importer une playlist YouTube Music

Si tu as exporté ta playlist depuis YouTube Music en `.csv`, tu peux la convertir pour ShellBeats avec ce script Python :

```python
import csv, json, os

csv_path = "ma_playlist.csv"  # ton fichier CSV
songs = []

with open(csv_path, encoding="utf-8-sig") as f:
    reader = csv.DictReader(f)
    for row in reader:
        video_id = row.get("MediaId", "").strip()
        title    = row.get("Title", "").strip()
        artist   = row.get("Artists", "").strip()
        if not video_id or not title:
            continue
        display = f"{artist} - {title}" if artist else title
        songs.append({
            "title": display,
            "video_id": video_id,
            "duration": None,
            "downloaded": False
        })

out = {"name": "Ma Playlist", "type": "local", "songs": songs}
with open(os.path.expanduser("~/.shellbeats/playlists/ma_playlist.json"), "w") as f:
    json.dump(out, f, ensure_ascii=False, indent=2)

print(f"{len(songs)} chansons converties")
```

Ajoute ensuite la playlist à l'index dans `~/.shellbeats/playlists.json` :

```json
{"name": "Ma Playlist", "filename": "ma_playlist.json"}
```

---

## Dépannage

**ShellBeats dit "mpv not found" mais mpv est installé**

```bash
which mpv  # doit retourner un chemin
# Si ok, lance avec le flag -log :
shellbeats -log
# Le -log ralentit légèrement le démarrage ce qui laisse
# le temps à mpv de s'initialiser correctement
```

**yt-dlp ne fonctionne pas**

```bash
yt-dlp --update
# ou
pip install -U yt-dlp --break-system-packages
```

**Erreur "socket path too long"**

```bash
export TMPDIR=/data/local/tmp
shellbeats
```

**Le script Bluetooth ne trouve pas ShellBeats**

Le socket IPC n'existe que quand ShellBeats est en cours d'exécution. Lance d'abord ShellBeats, puis le script Bluetooth.

**La playlist locale affiche 0 chanson**

Vérifie que le nom du dossier dans `~/Music/shellbeats/` est bien en minuscules. ShellBeats convertit les noms de playlists en minuscules automatiquement.

---

## Structure des fichiers

```
~/
├── shellbeats_termux/       # Ce repo
│   ├── shellbeats           # Binaire compilé
│   ├── update-suno.py       # Script playlists MP3 locales
│   └── shellbeats-bt.sh     # Contrôle Bluetooth
├── Music/shellbeats/
│   └── suno/                # MP3 locaux au format ShellBeats
└── .shellbeats/
    ├── config.json           # Configuration
    └── playlists/            # Playlists JSON
        ├── suno.json
        └── ma_playlist.json
```

---

## Crédits

- [lalo-space/shellbeats](https://github.com/lalo-space/shellbeats) — projet original
- Fork Android/Termux par [richerrail](https://github.com/richerrail)
