Regenerates `Flasher/Data/lexicon.tsv`.

1. `curl -s https://kaikki.org/dictionary/Spanish/kaikki.org-dictionary-Spanish.jsonl | python3 extract.py` → `es_compact.jsonl`
2. Download `es_full.txt` from hermitdave/FrequencyWords (content/2018/es).
3. `python3 build.py` → `lexicon.tsv` (copy it into `Flasher/Data/`).

Sources: Wiktionary via Kaikki.org (CC BY-SA 4.0); OpenSubtitles word frequencies.
A word is included when it is a Wiktionary dictionary entry (not an inflected form) and appears 3+ times in the subtitle corpus,
or is already in the flashcard set.

`extras.tsv` (examples, synonyms, antonyms, derived/related terms, etymology):
`curl -s https://kaikki.org/dictionary/Spanish/kaikki.org-dictionary-Spanish.jsonl | python3 extras.py lexicon.tsv extras.tsv`

Phrases, sayings and proverbs (run after build.py; appends `phrase` rows to lexicon.tsv, merging hand-written grammar patterns from `phrases_curated.tsv`):
`curl -s https://kaikki.org/dictionary/Spanish/kaikki.org-dictionary-Spanish.jsonl | python3 phrases.py ../../Flasher/Data/lexicon.tsv`
