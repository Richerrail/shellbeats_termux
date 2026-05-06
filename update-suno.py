import json, os, shutil

music_dir = os.path.expanduser("~/storage/music")
dest_dir = os.path.expanduser("~/Music/shellbeats/suno")
os.makedirs(dest_dir, exist_ok=True)

songs = []
for i, f in enumerate(sorted(os.listdir(music_dir))):
    if not f.lower().endswith(".mp3"):
        continue
    title = f[:-4]
    fake_id = f"suno{i:07d}"
    new_name = f"{title}_[{fake_id}].mp3"
    src = os.path.join(music_dir, f)
    dst = os.path.join(dest_dir, new_name)
    for old in os.listdir(dest_dir):
        if old.startswith(f"{title}_[suno"):
            os.remove(os.path.join(dest_dir, old))
    shutil.copy2(src, dst)
    songs.append({
        "title": title,
        "video_id": fake_id,
        "duration": None,
        "downloaded": True
    })

playlist = {"name": "Suno", "type": "local", "songs": songs}
out = os.path.expanduser("~/.shellbeats/playlists/suno.json")
with open(out, "w", encoding="utf-8") as f:
    json.dump(playlist, f, ensure_ascii=False, indent=2)

print(f"{len(songs)} chansons mises à jour")