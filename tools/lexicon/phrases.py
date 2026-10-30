"""Appends multi-word phrases, sayings and proverbs to lexicon.tsv.

curl -s https://kaikki.org/dictionary/Spanish/kaikki.org-dictionary-Spanish.jsonl | python3 phrases.py ../../Flasher/Data/lexicon.tsv
Also merges phrases_curated.tsv (grammar patterns such as "acabar de" that Wiktionary lacks as entries).
Re-running replaces earlier phrase lines.
"""
import sys, json, re

PHRASE_POS = {'phrase', 'proverb', 'prep_phrase', 'adv_phrase', 'intj', 'particle'}
BAD = {'obsolete', 'archaic', 'rare', 'historical', 'nonstandard', 'misspelling', 'dated', 'error-misspelling', 'proscribed'}
LABEL = {'Spain': 'Spain', 'Chile': 'Chile', 'Argentina': 'Argentina', 'Rioplatense': 'Rioplatense', 'Colombia': 'Colombia',
         'Peru': 'Peru', 'Venezuela': 'Venezuela', 'Cuba': 'Cuba', 'Latin-America': 'Latin America',
         'colloquial': 'colloquial', 'slang': 'slang', 'vulgar': 'vulgar', 'derogatory': 'derogatory', 'informal': 'informal',
         'figuratively': 'figurative', 'offensive': 'offensive', 'formal': 'formal', 'humorous': 'humorous', 'idiomatic': 'idiomatic'}
SKIP_GLOSS = re.compile(r'^(alternative|pronominal|obsolete|misspelling|eye dialect|(first|second|third)-person|plural|feminine|masculine|apocopic|archaic)\b.*\b(of|form)\b', re.I)
path = sys.argv[1]
keep = [l for l in open(path, encoding='utf8') if not l.startswith('W\t') or '\tphrase\t' not in l]
seen = {}
for line in sys.stdin:
    try: e = json.loads(line)
    except Exception: continue
    w = e.get('word') or ''
    if e.get('lang_code') != 'es' or e.get('pos') not in PHRASE_POS or ' ' not in w.strip(): continue
    if len(w) > 60 or w[0].isupper() and e['pos'] == 'intj' or not re.fullmatch(r"[^\d_@/]+", w): continue
    senses = []
    for s in e.get('senses', []):
        g = [x for x in (s.get('glosses') or []) if x]
        if not g or s.get('form_of') or s.get('alt_of'): continue
        tags = set(s.get('tags') or []) | set(s.get('raw_tags') or [])
        if BAD & tags: continue
        text = re.sub(r'\s+', ' ', g[-1]).strip().rstrip('.')
        if not text or SKIP_GLOSS.match(text) or ' of ' in text[:25] and text.split()[0] in ('alternative', 'pronominal'): continue
        mex = 'Mexico' in tags or bool(re.search(r'\((?:Mexic|MX)', text))
        text = re.sub(r'\s*\((?:Mexican|Mexico|MX)[^)]*\)', '', text).strip()
        labels = [LABEL[t] for t in sorted(tags) if t in LABEL][:2]
        if labels: text = '(' + ', '.join(labels) + ') ' + text
        senses.append(('§' if mex else '') + text[:220])
    if not senses: continue
    senses.sort(key=lambda x: 0 if x.startswith('§') else 1)
    d = seen.setdefault(w, [])
    for s in senses:
        if s not in d: d.append(s)
for l in open('phrases_curated.tsv', encoding='utf8'):
    if not l.strip() or l.startswith('#'): continue
    w, g = l.rstrip('\n').split('\t')
    seen.setdefault(w, []).insert(0, g)
out = open(path, 'w', encoding='utf8')
out.writelines(keep)
n = 0
for w, ss in seen.items():
    mex = any(s.startswith('§') for s in ss)
    out.write('W\t%s\tphrase\t\t%d\t%s\n' % (w, 40000 if mex else 90000, ' ¦ '.join(ss[:6]).replace('\t', ' ')))
    n += 1
print('phrases', n, file=sys.stderr)
