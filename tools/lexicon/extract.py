import sys, json
out = open('es_compact.jsonl', 'w')
n = 0
for line in sys.stdin:
    try:
        e = json.loads(line)
    except Exception:
        continue
    if e.get('lang_code') != 'es':
        continue
    senses = []
    for s in e.get('senses', []):
        gl = s.get('glosses') or []
        senses.append({
            'g': gl,
            't': s.get('tags') or [],
            'rt': s.get('raw_tags') or [],
            'fo': [x.get('word') for x in (s.get('form_of') or [])],
            'ao': [x.get('word') for x in (s.get('alt_of') or [])],
        })
    ht = e.get('head_templates') or []
    out.write(json.dumps({
        'w': e.get('word'), 'p': e.get('pos'), 't': e.get('tags') or [],
        'ht': [{'n': h.get('name'), 'a': h.get('args'), 'e': h.get('expansion')} for h in ht[:1]],
        's': senses,
    }, ensure_ascii=False) + '\n')
    n += 1
print('entries', n, file=sys.stderr)
