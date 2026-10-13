#!/usr/bin/env python3
"""Index the bundled files that the desktop engine opens through sys.io.File."""
import hashlib
import json
from pathlib import Path


def prepare(root: Path) -> dict:
    entries = []
    for folder, prefix in (("example_mods", "mods"), ("assets/preload", "assets")):
        for path in sorted((root / folder).rglob("*")):
            if not path.is_file() or path.suffix.lower() == ".mp3":
                continue
            if folder == "assets/preload" and path.suffix.lower() not in {
                ".lua", ".json", ".txt", ".xml", ".frag", ".vert"
            }:
                continue
            if path.name == "android-files.json":
                continue
            destination = prefix + "/" + path.relative_to(root / folder).as_posix()
            entries.append({"path": destination, "sha256": hashlib.sha256(path.read_bytes()).hexdigest()})
    digest = hashlib.sha256(json.dumps(entries, sort_keys=True).encode()).hexdigest()
    return {"version": digest, "files": entries}


if __name__ == "__main__":
    root = Path(__file__).resolve().parents[1]
    manifest = prepare(root)
    (root / "assets/preload/android-files.json").write_text(json.dumps(manifest), encoding="utf-8")
    print(f"Indexed {len(manifest['files'])} Android files.")
