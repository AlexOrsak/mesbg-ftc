#!/usr/bin/env python3
"""
Swap CustomMesh between inverted parent (model) and child (base).

Only fixes objects with exactly one child and that child is a base mesh.
Objects with extra non-base children (e.g. Khazad Guard variants) are skipped.
"""

import json
import sys
from pathlib import Path

BAG_GUID = "24f6d0"
SAVE_PATH = Path("../save.json")

BASE_MESH_HASHES = {
    "A6C540D6826E3F0C6A04C3BAEACD00219918F0A4",
    "9B34DA65B0FBA7F8A39BE6BE535778600C33B45C",
    "EEC9D575DE9F7A10224BC73915C7FCEF4175103B",
    "C146077CAA8352AC16FD54942898CD6C4AC9EB19",
    "E769B6A6D7CDF0726DA6E97581218D526F1A414D",
    "B73070B8D079F5B712DD208B7352A7460C2D44C8",
    "9D8E5879A1035AD770246E3032CEBBD6E58A8FB2",
    "D97D9E9A1828BA493D7DBF3E7DAC25B360805A76",
    "985F2678F03BFBCB5865A3C1A70533017C80D67A",
    "5E94ACFC1A15725947F51A80F2409F8232350A57",
    "13078A2023096261FDF67D8C0DC1C748A974D11D",
}


def mesh_hash(url):
    return url.rstrip("/").split("/")[-1] if url else ""


def is_base_mesh(url):
    return mesh_hash(url) in BASE_MESH_HASHES


def main():
    if not SAVE_PATH.exists():
        print(f"Error: {SAVE_PATH} not found. Run from scripts/")
        sys.exit(1)

    with open(SAVE_PATH, encoding="utf-8") as f:
        save = json.load(f)

    bag = next((o for o in save["ObjectStates"] if o.get("GUID") == BAG_GUID), None)
    if not bag:
        print(f"Error: bag {BAG_GUID} not found")
        sys.exit(1)

    fixed = 0
    skipped = 0

    for obj in bag.get("ContainedObjects", []):
        mesh_url = obj.get("CustomMesh", {}).get("MeshURL", "")
        if is_base_mesh(mesh_url):
            continue  # already standard

        children = obj.get("ChildObjects", [])
        base_children = [c for c in children if is_base_mesh(c.get("CustomMesh", {}).get("MeshURL", ""))]
        non_base_children = [c for c in children if not is_base_mesh(c.get("CustomMesh", {}).get("MeshURL", ""))]

        if not base_children:
            continue  # no_child or other

        if len(base_children) != 1 or non_base_children:
            # Multiple children — skip
            skipped += 1
            nick = obj.get("Nickname") or "(unnamed)"
            print(f"  SKIP {obj['GUID']}  {nick[:60]}  ({len(children)} children)")
            continue

        base_child = base_children[0]

        # Swap meshes
        obj["CustomMesh"], base_child["CustomMesh"] = base_child["CustomMesh"], obj["CustomMesh"]

        # Negate child's local position and rotation so model sits above base
        t = base_child["Transform"]
        t["posX"] = -t["posX"]
        t["posY"] = -t["posY"]
        t["posZ"] = -t["posZ"]
        t["rotX"] = -t.get("rotX", 0.0)
        t["rotY"] = -t.get("rotY", 0.0)
        t["rotZ"] = -t.get("rotZ", 0.0)

        fixed += 1

    print(f"\nFixed {fixed}, skipped {skipped}")

    with open(SAVE_PATH, "w", encoding="utf-8") as f:
        json.dump(save, f, indent=2, ensure_ascii=False)
    print("Saved save.json")


if __name__ == "__main__":
    main()
