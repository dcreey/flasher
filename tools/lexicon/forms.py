"""Appends noun-form rows to extras.tsv: F <word> <plural> <feminine> <feminine plural> <masculine> <masculine plural> (¦ between alternatives).
Words that are one form for both sexes (el/la estudiante) get themselves as the feminine.
Usage: python3 forms.py lexicon.tsv extras.tsv < kaikki.jsonl"""
import sys, json, re
lex, outpath = sys.argv[1], sys.argv[2]
heads = set()
for l in open(lex, encoding='utf8'):
    if l.startswith('W\t') and l.split('\t')[2] == 'noun': heads.add(l.split('\t')[1])
found = {}
for line in sys.stdin:
    if '"es-noun"' not in line: continue
    try: e = json.loads(line)
    except Exception: continue
    w = e.get('word')
    if e.get('lang_code') != 'es' or e.get('pos') != 'noun' or w not in heads or w in found or ' ' in w: continue
    forms = {'pl': [], 'f': [], 'fpl': [], 'm': [], 'mpl': []}
    for f in e.get('forms', []):
        tags = set(f.get('tags', [])); t = f.get('form', '')
        if not t or ' ' in t or tags & {'alternative', 'obsolete', 'rare', 'archaic'}: continue
        key = ('f' if 'feminine' in tags else 'm' if 'masculine' in tags else None)
        if 'plural' in tags: forms[(key + 'pl') if key else 'pl'].append(t)
        elif key: forms[key].append(t)
    expansion = ' '.join(h.get('expansion', '') for h in e.get('head_templates', []))
    if ('m or f by sense' in expansion or 'm or f' in expansion or ' mf' in expansion) and forms['pl'] and not forms['f']:
        forms['f'] = [w]; forms['fpl'] = list(forms['pl']); forms['m'] = [w]; forms['mpl'] = list(forms['pl'])
    if any(forms.values()): found[w] = forms
with open(outpath, 'a', encoding='utf8') as out:
    for w, f in found.items():
        out.write('F\t' + w + '\t' + '\t'.join('¦'.join(dict.fromkeys(f[k])) for k in ('pl', 'f', 'fpl', 'm', 'mpl')) + '\n')
print(len(found))
