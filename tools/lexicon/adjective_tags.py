"""Writes the adjective category rows (A) into extras.tsv from adjective_tags.tsv.

Row: A<TAB>word<TAB>cats of sense 0 ¦ cats of sense 1 ¦ ...   (cats comma separated, empty = fits anything)
Usage: python3 tools/lexicon/adjective_tags.py
"""
import os

root = os.path.join(os.path.dirname(__file__), "..", "..", "Flasher", "Data")
senses = {}
for line in open(os.path.join(root, "lexicon.tsv"), encoding="utf-8"):
    p = line.rstrip("\n").split("\t")
    if p[0] == "W" and p[2] == "adjective":
        senses[p[1]] = len(p[5].split("¦"))

rows = []
for line in open(os.path.join(os.path.dirname(__file__), "adjective_tags.tsv"), encoding="utf-8"):
    if line.startswith("#") or not line.strip():
        continue
    p = line.rstrip("\n").split("\t")
    word, n = p[0], senses.get(p[0])
    if n is None:
        print("skipped (not an adjective):", word)
        continue
    cats = [""] * n
    for spec in p[1:]:
        index, _, c = spec.partition(":")
        targets = range(n) if index == "*" else [int(index)] if int(index) < n else []
        for i in targets:
            cats[i] = c
    rows.append("A\t%s\t%s" % (word, "¦".join(cats)))

path = os.path.join(root, "extras.tsv")
kept = [l for l in open(path, encoding="utf-8").read().split("\n") if l and not l.startswith("A\t")]
open(path, "w", encoding="utf-8").write("\n".join(kept + rows) + "\n")
print(len(rows), "adjectives tagged")
