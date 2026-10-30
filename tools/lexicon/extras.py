"""Builds extras.tsv (examples, synonyms, antonyms, derived/related terms, etymology) for the words in lexicon.tsv.
Usage: curl -s https://kaikki.org/dictionary/Spanish/kaikki.org-dictionary-Spanish.jsonl | python3 extras.py lexicon.tsv extras.tsv"""
import sys, json, re, collections
lex, outpath = sys.argv[1], sys.argv[2]
heads = {}
for l in open(lex, encoding='utf8'):
    if l.startswith('W\t'):
        c = l.split('\t'); heads.setdefault(c[1], int(c[4] or 0))
POS = {'verb','noun','adj','adv','intj','pron','det','prep','conj','num','article','contraction'}
ex = collections.defaultdict(list); syn = collections.defaultdict(list); ant = collections.defaultdict(list)
der = collections.defaultdict(list); rel = collections.defaultdict(list); ety = {}
def words(items):
    out = []
    for it in items or []:
        w = it.get('word') if isinstance(it, dict) else it
        if w and isinstance(w, str): out.append(w.strip())
    return out
def add(lst, items, limit, self_w, only=None):
    for w in items:
        if w == self_w or w in lst or '\t' in w or '¦' in w or len(w) > 40: continue
        if only is not None and w not in only: continue
        if lst is not None and len(lst) < limit: lst.append(w)
def clean(t): return re.sub(r'\s+', ' ', t).strip()
for line in sys.stdin:
    try: e = json.loads(line)
    except Exception: continue
    if e.get('lang_code') != 'es' or e.get('pos') not in POS: continue
    w = e['word']
    if w not in heads: continue
    senses = [s for s in e.get('senses', []) if not (s.get('form_of') or s.get('alt_of'))]
    if not senses: continue
    for s in senses:
        for x in s.get('examples') or []:
            es, en = clean(x.get('text') or ''), clean(x.get('english') or x.get('translation') or '')
            if not es or not en or not (8 <= len(es) <= 130) or len(en) > 150: continue
            if any(ch in es + en for ch in '→[]\n') or '+' in es: continue
            pri = 0 if x.get('type') != 'quotation' else 1
            if all(es != p[1] for p in ex[w]): ex[w].append((pri, es, en, e['pos']))
        add(syn[w], words(s.get('synonyms')), 8, w)
        add(ant[w], words(s.get('antonyms')), 5, w)
        add(der[w], words(s.get('derived')), 10, w, heads)
        add(rel[w], words(s.get('related')), 10, w, heads)
    add(syn[w], words(e.get('synonyms')), 8, w)
    add(ant[w], words(e.get('antonyms')), 5, w)
    add(der[w], words(e.get('derived')), 10, w, heads)
    add(rel[w], words(e.get('related')), 10, w, heads)
    t = clean(e.get('etymology_text') or '')
    if t and w not in ety and len(t) >= 12:
        m = re.search(r'(Inherited from|Borrowed from|Learned borrowing from|Semi-learned borrowing from|From|Derived from|Compound of|Univerbation of|Clipping of|Blend of|Back-formation from|Calque of|Onomatopoeic|Of imitative|Of unknown|Uncertain|Unknown)', t)
        if t.startswith('Etymology tree') and m: t = t[m.start():]
        if t.startswith('Etymology tree'): continue
        r = heads.get(w, 0)
        if r > 120000: continue
        parts = re.split(r'(?<=[.!?])\s+', t)
        short = parts[0]
        if len(short) < 60 and len(parts) > 1: short += ' ' + parts[1]
        if len(short) > 170: short = short[:170].rsplit(' ', 1)[0] + '…'
        ety[w] = short
out = open(outpath, 'w', encoding='utf8')
n = collections.Counter()
for w in heads:
    for pri, es, en, pos in sorted(ex.get(w, []), key=lambda x: (x[0], len(x[1])))[:3]:
        out.write(f'X\t{w}\t{pos}\t{es}\t{en}\n'); n['X'] += 1
    for tag, d in (('Y', syn), ('N', ant), ('V', der), ('R', rel)):
        if d.get(w): out.write(f'{tag}\t{w}\t' + '¦'.join(d[w]) + '\n'); n[tag] += 1
    if w in ety: out.write(f'T\t{w}\t{ety[w]}\n'); n['T'] += 1
out.close(); print(dict(n))
