#!/usr/bin/env python3
"""
Review and annotate non-standard miniature structures in the army bag.

Run from the repo root:
  python scripts/review-structures.py              # print report
  python scripts/review-structures.py --manifest   # write manifest.json
  python scripts/review-structures.py --manifest --include-standard  # include all

The manifest (scripts/structures-manifest.json) has one entry per problematic object.
Edit the "action" field for each entry before running the apply step (not yet implemented).

Action values:
  ""            unreviewed
  "no_base"     intentionally has no separate base (e.g. Goblin Scribe, Smaug)
  "group"       multi-figure group object with no single base
  "needs_base"  broken — infantry/hero that needs a standard base added
  "inverted"    model is parent, base is child — already in desired structure
  "standard"    base is parent, model is child — needs flipping (handled in bulk later)
"""

import json
import sys
from pathlib import Path
from collections import defaultdict

BAG_GUID = "24f6d0"
SAVE_PATH = Path("../save.json")
MANIFEST_PATH = Path("./structures-manifest.json")

# Known base mesh URL hashes and their descriptions
BASE_MESH_HASHES = {
    "A6C540D6826E3F0C6A04C3BAEACD00219918F0A4": "infantry 25mm",
    "9B34DA65B0FBA7F8A39BE6BE535778600C33B45C": "cavalry",
    "EEC9D575DE9F7A10224BC73915C7FCEF4175103B": "large/monster",
    "C146077CAA8352AC16FD54942898CD6C4AC9EB19": "cavalry variant A",
    "E769B6A6D7CDF0726DA6E97581218D526F1A414D": "cavalry variant B",
    "B73070B8D079F5B712DD208B7352A7460C2D44C8": "ogre",
    "9D8E5879A1035AD770246E3032CEBBD6E58A8FB2": "huge creature",
    "D97D9E9A1828BA493D7DBF3E7DAC25B360805A76": "fell beast",
    "985F2678F03BFBCB5865A3C1A70533017C80D67A": "wraith foot",
    "5E94ACFC1A15725947F51A80F2409F8232350A57": "mumak",
    "13078A2023096261FDF67D8C0DC1C748A974D11D": "iron hills cavalry",
}


STRIP_FIELDS = {
    "Transform", "AltLookAngle", "ColorDiffuse",
    "LayoutGroupSortIndex", "Value", "Locked", "Grid", "Snap",
    "IgnoreFoW", "MeasureMovement", "DragSelectable", "Autoraise",
    "Sticky", "Tooltip", "GridProjection",
}


def strip_obj(obj: dict) -> dict:
    out = {k: v for k, v in obj.items() if k not in STRIP_FIELDS}
    if "ChildObjects" in out:
        out["ChildObjects"] = [strip_obj(c) for c in out["ChildObjects"]]
    return out


def mesh_hash(url: str) -> str:
    return url.rstrip("/").split("/")[-1] if url else ""


def is_base_mesh(url: str) -> bool:
    return mesh_hash(url) in BASE_MESH_HASHES


def base_type(url: str) -> str:
    return BASE_MESH_HASHES.get(mesh_hash(url), "")


def classify(obj: dict) -> str:
    """Return one of: standard, inverted, no_mesh, no_child, other."""
    mesh_url = obj.get("CustomMesh", {}).get("MeshURL", "")
    children = obj.get("ChildObjects", [])

    if not mesh_url:
        return "no_mesh"

    parent_is_base = is_base_mesh(mesh_url)
    base_children = [c for c in children if is_base_mesh(c.get("CustomMesh", {}).get("MeshURL", ""))]

    if parent_is_base:
        return "standard"
    elif base_children:
        return "inverted"
    elif not children:
        return "no_child"
    else:
        return "other"


def child_summary(children: list) -> list[str]:
    parts = []
    for c in children:
        cm = c.get("CustomMesh", {})
        url = cm.get("MeshURL", "")
        h = mesh_hash(url)
        bt = base_type(url)
        nick = c.get("Nickname") or ""
        if bt:
            parts.append(f"[BASE:{bt}]")
        elif nick:
            parts.append(f"[model:{nick[:30]}]")
        else:
            parts.append(f"[model:...{h[:12]}]")
    return parts


def main():
    write_manifest = "--manifest" in sys.argv
    include_standard = "--include-standard" in sys.argv

    if not SAVE_PATH.exists():
        print(f"Error: {SAVE_PATH} not found. Run from repo root.")
        sys.exit(1)

    with open(SAVE_PATH, encoding="utf-8") as f:
        save = json.load(f)

    bag = next((o for o in save["ObjectStates"] if o.get("GUID") == BAG_GUID), None)
    if not bag:
        print(f"Error: bag {BAG_GUID} not found")
        sys.exit(1)

    objects = bag.get("ContainedObjects", [])
    by_class = defaultdict(list)
    for obj in objects:
        by_class[classify(obj)].append(obj)

    # ── Report ──────────────────────────────────────────────────────────────

    counts = {k: len(v) for k, v in by_class.items()}
    print(f"Total objects: {len(objects)}")
    for k, n in sorted(counts.items()):
        print(f"  {k:12s}: {n}")
    print()

    for cls in ("no_mesh", "no_child", "inverted", "other"):
        objs = by_class.get(cls, [])
        if not objs:
            continue
        print(f"=== {cls.upper()} ({len(objs)}) ===")
        for obj in objs:
            nick = obj.get("Nickname") or "(unnamed)"
            guid = obj["GUID"]
            children = obj.get("ChildObjects", [])
            mesh_url = obj.get("CustomMesh", {}).get("MeshURL", "")
            h = mesh_hash(mesh_url)
            child_str = "  children: " + str(child_summary(children)) if children else ""
            print(f"  {guid}  {nick[:55]:55s}  ...{h[:16]}{child_str}")
        print()

    if include_standard:
        objs = by_class.get("standard", [])
        print(f"=== STANDARD ({len(objs)}) ===")
        for obj in objs:
            nick = obj.get("Nickname") or "(unnamed)"
            guid = obj["GUID"]
            children = obj.get("ChildObjects", [])
            mesh_url = obj.get("CustomMesh", {}).get("MeshURL", "")
            h = mesh_hash(mesh_url)
            bt = base_type(mesh_url)
            child_str = "  children: " + str(child_summary(children)) if children else ""
            print(f"  {guid}  {nick[:50]:50s}  [{bt}]{child_str}")
        print()

    # ── Manifest ─────────────────────────────────────────────────────────────

    if not write_manifest:
        return

    # Load existing manifest to preserve any annotations already made
    existing = {}
    if MANIFEST_PATH.exists():
        with open(MANIFEST_PATH, encoding="utf-8") as f:
            for entry in json.load(f):
                existing[entry["guid"]] = entry.get("action", "")

    entries = []
    skip_classes = {"standard"} if not include_standard else set()

    for cls in ("no_mesh", "no_child", "inverted", "other", "standard"):
        if cls in skip_classes:
            continue
        for obj in by_class.get(cls, []):
            guid = obj["GUID"]
            mesh_url = obj.get("CustomMesh", {}).get("MeshURL", "")
            children = obj.get("ChildObjects", [])
            entries.append({
                "guid": guid,
                "nickname": obj.get("Nickname") or "",
                "class": cls,
                "action": existing.get(guid, ""),
                "object": strip_obj(obj),
            })

    with open(MANIFEST_PATH, "w", encoding="utf-8") as f:
        json.dump(entries, f, indent=2)
    print(f"Wrote {MANIFEST_PATH}  ({len(entries)} entries)")
    print("Edit the 'action' field for each entry, then run the apply step.")


if __name__ == "__main__":
    main()
