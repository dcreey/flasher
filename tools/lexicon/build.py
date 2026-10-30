import json, re, collections, sys
SEED = '/Users/dcreey/dev/flasher/Flasher/Data/SeedData+Words.swift'
orig = set()
for l in open(SEED, encoding='utf8'):
    m = re.match(r'\s*\("([^"]+)",\s*"', l)
    if m: orig.add(m.group(1))
rank = {}
for i, l in enumerate(open('es_full.txt', encoding='utf8')):
    p = l.split()
    if len(p) == 2: rank[p[0]] = (i + 1, int(p[1]))
POS = {'verb':'infinitive','noun':'noun','adj':'adjective','adv':'adverb','intj':'interjection','pron':'pronoun',
       'det':'article','article':'article','prep':'preposition','conj':'conjunction','num':'numeral','contraction':'preposition'}
BAD = {'obsolete','archaic','rare','historical','nonstandard','misspelling','dated','error-misspelling','proscribed'}
LABEL = {'Mexico':'Mexico','Latin-America':'Latin America','Spain':'Spain','Chile':'Chile','Argentina':'Argentina','Rioplatense':'Rioplatense',
 'Colombia':'Colombia','Peru':'Peru','Venezuela':'Venezuela','Cuba':'Cuba','Guatemala':'Guatemala','El-Salvador':'El Salvador','Honduras':'Honduras',
 'Nicaragua':'Nicaragua','Bolivia':'Bolivia','Dominican-Republic':'Dominican Republic','Puerto-Rico':'Puerto Rico','Canary-Islands':'Canary Islands',
 'Ecuador':'Ecuador','Costa-Rica':'Costa Rica','Panama':'Panama','Paraguay':'Paraguay','Uruguay':'Uruguay',
 'colloquial':'colloquial','slang':'slang','vulgar':'vulgar','derogatory':'derogatory','informal':'informal','figuratively':'figurative',
 'offensive':'offensive','formal':'formal','literary':'literary','humorous':'humorous','euphemistic':'euphemism','idiomatic':'idiomatic'}
FREQ_MIN = 3
def merge_near_duplicates(senses):
    """Single-word senses where one extends the other (hill / hilltop) become one sense ("hill, hilltop")."""
    merged = []
    for sense in senses:
        plain = re.fullmatch(r"[a-zA-Z-]+", sense) is not None
        target = None
        if plain:
            for i, m in enumerate(merged):
                parts = [p.strip() for p in m.split(',')]
                if all(re.fullmatch(r"[a-zA-Z-]+", p) for p in parts):
                    a, b = sense.lower(), parts[-1].lower()
                    if a != b and len(min(a, b, key=len)) >= 4 and (a.startswith(b) or b.startswith(a)):
                        target = i; break
        if target is None:
            if sense not in merged: merged.append(sense)
        else:
            merged[target] = merged[target] + ', ' + sense
    return merged

CRUDE = {'vulgar','offensive','derogatory'}
OTHER_REGIONS = {'Spain','Chile','Argentina','Rioplatense','Colombia','Peru','Venezuela','Cuba','Guatemala','El-Salvador','Honduras',
 'Nicaragua','Bolivia','Dominican-Republic','Puerto-Rico','Canary-Islands','Ecuador','Costa-Rica','Panama','Paraguay','Uruguay','Philippines','Andalusia'}
entries = collections.OrderedDict()   # (word,pos) -> dict
deriv = {}
for l in open('es_compact.jsonl', encoding='utf8'):
    e = json.loads(l)
    w, p = e['w'], e['p']
    if p not in POS or not w: continue
    # derivations: diminutive / augmentative / superlative forms
    for s in e['s']:
        if s['fo']:
            for k in ('diminutive','augmentative','superlative'):
                if k in s['t']:
                    deriv.setdefault(w, (s['fo'][0], k))
    if w not in orig:
        if ' ' in w or not re.fullmatch(r"[a-záéíóúüñ]+", w): continue
        if w not in rank or rank[w][1] < FREQ_MIN: continue
    elif ' ' in w and False: continue
    if p == 'verb' and not re.search(r'(ar|er|ir|ír)(se)?$', w): continue
    senses = []
    for s in e['s']:
        gtext = ' '.join(s['g'][:1]).strip()
        dm = re.match(r'^(diminutive|augmentative|superlative|pejorative)(?: [a-z-]+)? of ([a-záéíóúüñ]+)\b', gtext)
        if dm and dm.group(1) != 'pejorative':
            deriv.setdefault(w, (dm.group(2), dm.group(1)))
            continue
        if s['fo'] or s['ao'] or 'form-of' in s['t'] or 'alt-of' in s['t']: continue
        if BAD & set(s['t']) or BAD & set(s['rt']): continue
        g = [x for x in s['g'] if x]
        if not g: continue
        text = ': '.join(g) if len(g) <= 2 else ': '.join(g[-2:])
        text = re.sub(r'\s+', ' ', text).strip().rstrip('.')
        if not text or len(text) > 220: text = text[:220]
        if text.lower().startswith(('alternative form of','obsolete','misspelling of','eye dialect')): continue
        tags = list(s['t']) + list(s['rt'])
        mex = 'Mexico' in tags
        inline = re.search(r'\s*\(Mexic(?:o|an)\b[^)]*\)', text)
        if inline:
            mex = True
            text = (text[:inline.start()] + text[inline.end():]).strip()
        labels = [LABEL[t] for t in tags if t in LABEL and t != 'Mexico'][:2]
        if mex:
            regional = {LABEL[t] for t in tags if t in OTHER_REGIONS | {'Latin-America'} and t in LABEL}
            plain = [l for l in labels if l not in regional]
            extra = [l for l in labels if l in regional]
            labels = plain + (['also ' + ', '.join(extra)] if extra else [])
        if labels: text = '(' + ', '.join(labels) + ') ' + text
        if mex: rank_ = 0
        elif OTHER_REGIONS & set(tags): rank_ = 3
        elif 'Latin-America' in tags: rank_ = 2 if CRUDE & set(tags) else 1
        else: rank_ = 2
        if not any(t == text for _, t, _ in senses): senses.append((rank_, text, mex))
    # Mexican meanings first, then general, Latin American, and other regions last
    senses.sort(key=lambda x: x[0])
    merged_texts = []
    flags = {}
    for r_, t_, m_ in senses: flags.setdefault(t_, m_)
    texts = merge_near_duplicates([t for _, t, _ in senses])
    senses = [('\u00a7' if flags.get(t.split(', ')[0], False) or flags.get(t, False) else '') + t for t in texts]
    if not senses: continue
    g = ''
    if p == 'noun':
        h = e['ht'][0] if e['ht'] else {}
        a = h.get('a') or {}
        raw = a.get('1') or a.get('g') or ''
        raw = str(raw)
        if raw.startswith('mf') or raw == 'm-f' or raw == 'f-m': g = 'mf'
        elif raw.startswith('m'): g = 'm'
        elif raw.startswith('f'): g = 'f'
    key = (w, POS[p])
    if key in entries:
        for s in senses:
            if s not in entries[key]['senses']: entries[key]['senses'].append(s)
    else:
        entries[key] = {'g': g, 'senses': senses}
out = open('lexicon.tsv', 'w', encoding='utf8')
n = 0
for (w, pos), d in entries.items():
    r = rank.get(w, (0, 0))[0]
    out.write('W\t%s\t%s\t%s\t%d\t%s\n' % (w, pos, d['g'], r, ' ¦ '.join(sorted(d['senses'], key=lambda x: 0 if x.startswith('\u00a7') else 1)[:8]).replace('\t',' ')))
    n += 1
dn = 0
for form, (base, kind) in deriv.items():
    if form in rank and rank[form][1] >= 2 or form in orig:
        out.write('D\t%s\t%s\t%s\n' % (form, base, kind)); dn += 1
out.close()
heads = {w for (w, _) in entries}
print('entries', n, 'headwords', len(heads), 'in originals', len(heads & orig), 'new', len(heads - orig), 'deriv', dn, 'orig total', len(orig), 'orig without lexicon', len(orig - heads))
