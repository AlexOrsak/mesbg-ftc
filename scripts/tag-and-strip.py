#!/usr/bin/env python3
"""
Tag objects in Bag.24f6d0 based on their current embedded scripts,
then strip all LuaScript content from contained objects.

Tagging rules (applied from current script content):
  - Old firing arc scripts (>3000 chars) → Tags: ["firingArc"]
  - Any other non-empty script          → Tags: ["calcBounding"]
  - Empty script                        → Tags unchanged (needs manual review)

Run from the scripts/ directory:
  python tag-and-strip.py [--dry-run]
"""

import json
import sys
import shutil
from pathlib import Path

BAG_GUID = "24f6d0"
SAVE_PATH = Path("../save.json")
DATA_PATH = Path("../.tts/objects") / f"Bag.{BAG_GUID}.data.json"

DRY_RUN = "--dry-run" in sys.argv


def tag_for_script(lua_script: str) -> list[str] | None:
    if not lua_script:
        return None  # no existing script — needs manual review
    if len(lua_script) > 3000:
        return ["firingArc"]
    return ["calcBounding"]


def process_objects(objects: list[dict]) -> dict:
    counts = {"firingArc": 0, "calcBounding": 0, "untagged": 0, "already_tagged": 0}
    for obj in objects:
        existing_tags = obj.get("Tags") or []
        has_model_tag = any(t in ("calcBounding", "firingArc") for t in existing_tags)

        if not has_model_tag:
            new_tags = tag_for_script(obj.get("LuaScript", ""))
            if new_tags:
                obj["Tags"] = existing_tags + new_tags
                counts[new_tags[0]] += 1
            else:
                if obj["Nickname"]:
                    obj["Tags"] = existing_tags + ["calcBounding"]
                    counts["calcBounding"] += 1
                else:
                    print(obj["GUID"])
                    counts["untagged"] += 1
        else:
            counts["already_tagged"] += 1

        obj["LuaScript"] = ""
        obj["LuaScriptState"] = ""

    return counts


def main():
    if not SAVE_PATH.exists():
        print(f"Error: {SAVE_PATH} not found. Run from repo root.")
        sys.exit(1)

    with open(SAVE_PATH, encoding='utf-8') as f:
        save = json.load(f)

    bag = next(
        (o for o in save["ObjectStates"] if o.get("GUID") == BAG_GUID), None
    )
    if not bag:
        print(f"Error: bag {BAG_GUID} not found in ObjectStates")
        sys.exit(1)

    objects = bag.get("ContainedObjects", [])
    print(f"Processing {len(objects)} contained objects...")
    counts = process_objects(objects)

    print(f"  Tagged calcBounding: {counts['calcBounding']}")
    print(f"  Tagged firingArc:    {counts['firingArc']}")
    print(f"  Left untagged:       {counts['untagged']}  ← needs manual review")
    print(f"  Already tagged:      {counts['already_tagged']}")

    if DRY_RUN:
        print("\nDry run — no files written.")
        return

    shutil.copy(SAVE_PATH, SAVE_PATH.with_suffix(".json.bak"))
    with open(SAVE_PATH, "w") as f:
        json.dump(save, f, separators=(",", ":"))
    print(f"\nWrote {SAVE_PATH}  (backup: {SAVE_PATH.with_suffix('.json.bak')})")

    if DATA_PATH.exists():
        with open(DATA_PATH) as f:
            data = json.load(f)
        data_objects = data.get("ContainedObjects", [])
        # Sync tags and strip from data.json using GUID as key
        save_by_guid = {o["GUID"]: o for o in objects}
        for obj in data_objects:
            if obj["GUID"] in save_by_guid:
                src = save_by_guid[obj["GUID"]]
                obj["Tags"] = src.get("Tags")
                obj["LuaScript"] = ""
                obj["LuaScriptState"] = ""
        with open(DATA_PATH, "w") as f:
            json.dump(data, f, separators=(",", ":"))
        print(f"Wrote {DATA_PATH}")


if __name__ == "__main__":
    main()
