# Spanish checker

A small, deliberately conservative rules engine that points out mistakes in Spanish text. It runs offline, on the device, using only the data already bundled with the app: the dictionary, the verb conjugator and a handful of curated lists.

It is used in two places:

- **Translate tab.** After a translation, the Spanish side of the screen is checked: the text you typed (Spanish → English) or Apple's Spanish output (English → Spanish). Flagged words are highlighted in the text and each one is explained in a "Spanish check" card, with a suggested fix where there is one.
- **Dictionary search.** Pronoun and command mistakes are explained above the results ("le lo" isn't used, it becomes "se lo"), and queries like "nos veo" or "yo me veo" find the verb.

It can be switched off with **Show Spanish checks** in Settings (`AppSettings.showSpanishChecksKey`).

## Design principles

1. **A false alarm on correct Spanish is worse than a missed mistake.** Every rule only fires when the dictionary data or a fixed pattern says the text is wrong, never merely unusual. Anything ambiguous is skipped.
2. **Static checks only.** The engine looks at forms and patterns. It cannot judge meaning, so it does not try to decide `ser` vs `estar`, `por` vs `para`, tone, or regional preference.
3. **Explain, don't just flag.** Each issue carries a plain-language message and, where possible, the corrected text.
4. **Real text is the test.** Besides unit tests for each rule, the suite runs the engine over every example sentence in the dictionary and fails if the grammar rules start firing on them (see [Testing](#testing)).

## Where the code lives

| File | What it holds |
| --- | --- |
| `Flasher/Data/SpanishChecker.swift` | `SpanishIssue`, the tokenizer, and the rules that need token context: pronoun windows, spelling, article/noun and noun/adjective agreement, subject/verb agreement, contractions, repeated words. `SpanishChecker.check(_:)` is the entry point. |
| `Flasher/Data/SpanishRules.swift` | Fixed-phrase rules (regular expressions), the subjunctive rule, wrong irregular conjugations, pronoun order, adjective inflection helpers and the false-friend tips. |
| `Flasher/Views/PhraseVerb.swift` | `SpanishStress` (syllables, stress and accent placement), `Clitics` (verbs with attached pronouns, pronoun + conjugated verb, commands) and `VerbForms` (an index of every conjugated form). |
| `Flasher/Views/TranslateView.swift` | The "Spanish check" card, the text highlighting and the toolbar toggle. |
| `FlasherTests/SpanishCheckerTests.swift` | The test suite. |

### The data it relies on

- **`Lexicon`**: parts of speech and noun gender for ~80,000 entries.
- **`Extras.nounForms`**: plural, feminine and masculine forms of nouns.
- **`VerbForms.index`**: every conjugated form of every verb, with its tense and person. Participles and gerunds are in `VerbForms.nonFiniteForms`.
- **`Conjugation.regularForms`**: what each form would be if the verb were regular, which is how wrongly regularised forms (`tenió`) are detected.
- **`SpanishStress`**: accent logic that decides where a written accent goes when pronouns are attached (`di + me + lo` → `dímelo`).

## What it checks

`Kind` is the label shown on the issue. ✅ marks text that looks similar but is correct and is deliberately **not** flagged.

### Pronouns

| Rule | Flagged | Not flagged |
| --- | --- | --- |
| `le`/`les` before `lo`/`la`/`los`/`las` becomes `se` | *le lo dije* → *se lo dije* | ✅ *se lo dije* |
| A direct pronoun cannot come before an indirect one | *lo me dijo* → *me lo dijo* | ✅ *lo sé* (and *lo se* without the accent) |
| Fixed pronoun order: `se`, `te`/`os`, `me`/`nos`, `le`/`les` | *me se cayó* → *se me cayó*, *me te* → *te me* | ✅ *yo me se la lección* (`se` is the verb *sé* typed without its accent) |
| Pronouns do not go in front of an affirmative command | *me haz un favor* → *hazme un favor* | ✅ *la sal* (`la` is an article) |
| Pronouns do not attach to a negative command | *no dímelo* → *no me lo digas* | ✅ *dímelo*, *no me lo digas* |
| Pronouns do not attach to a conjugated verb | *digome* → *me digo* | ✅ *dame*, *decírtelo* |

### Spelling and accents

| Rule | Flagged | Not flagged |
| --- | --- | --- |
| Attached pronouns need the accent that keeps the stress | *hablame* → *háblame*, *dimelo* → *dímelo* | ✅ *háblame*, *vernos*, *vámonos* |
| A word that only exists with an accent or tilde | *telefono* → *teléfono* | ✅ *esta* (a real word), capitalised words (they may be names) |
| "Why" in a question is two words with an accent | *¿porque lloras?* → *¿por qué lloras?* | ✅ *lloro porque estoy triste* |

### Agreement

| Rule | Flagged | Not flagged |
| --- | --- | --- |
| Article and noun gender | *un casa* → *una casa*, *la problema* → *el problema* | ✅ *el agua*, *un alma* (feminine nouns with stressed *a*), *el capital / la capital* |
| Article and noun number | *las flor* → *las flores* | ✅ *los lunes*, *las crisis* (same singular and plural), *la canto* (`la` is "it": *I sing it*) |
| Noun and adjective gender and number | *la casa bonito* → *la casa bonita*, *los niños pequeñas* | ✅ *las casas rosa* (colors taken from nouns never change), *la cultura pueblo* |
| Subject pronoun and verb person | *yo tiene*, *ellos va* | ✅ *mi hermano y yo vamos*, *entre tú y yo*, *tú ven* (`ven` is also a command), *uno de ellos es* |

Gender is only trusted when the dictionary's gender agrees with what the ending suggests (`-o` masculine, `-a` feminine, `-ción`, `-dad`... feminine) or the word is on a short list of known exceptions (`problema`, `día`, `mano`, `foto`...). Words that take both genders (`capital`, `cura`, `policía`...), numerals, one- and two-letter words and nouns the dictionary does not agree with are skipped.

### Grammar

| Rule | Flagged | Not flagged |
| --- | --- | --- |
| Contractions | *voy a el mercado* → *al* | ✅ *vive en El Salvador*, *es de él* |
| Repeated articles, prepositions and possessives | *el el perro* | ✅ *no, no quiero* |
| Age uses `tener` | *soy 25 años* → *tengo 25 años* | ✅ *hace 25 años que vivo aquí* |
| Doubled comparative | *más mejor* → *mejor* | ✅ *más bueno* |
| Dequeísmo (extra `de`) | *pienso de que* → *pienso que* | ✅ *dudo de que*, *la espera de que* |
| Queísmo (missing `de`) | *me alegro que* → *me alegro de que*, *me di cuenta que*, *estoy seguro que* | ✅ *me alegra que*, *seguro que viene* |

### Verbs

| Rule | Flagged | Not flagged |
| --- | --- | --- |
| Subjunctive after a trigger that always takes it: wishes (`quiero que`, `pide que`, `sugiero que`, `espera a que`), feelings (`me alegro de que`, `me molesta que`, `me sorprende que`, `es una lástima que`, `temo que`), doubt (`dudo que`, `niego que`, `no creo que`, `no es verdad que`), need and possibility (`es importante que`, `hace falta que`, `más vale que`, `puede que`, `es imposible que`), `no es que`, and connectors (`para que`, `a fin de que`, `antes de que`, `sin que`, `a menos que`, `a no ser que`, `con tal (de) que`, `en caso de que`, `no sea que`, `ojalá`, `ojalá y`) | *quiero que vienes* → *vengas*, *puede que viene* → *venga*, *no es que no quiero* → *quiera* | ✅ *quiero que vengas*, *creo que viene*, *¿para que sirve?* (`para qué` without its accent), *me temo que perderemos* and *temo que sea tarde*, *no dudo que es / sea*, *no niego que sea*, *¿no es verdad que viene?*, *no es mentira que es caro* |
| A wish with the same subject (*quiero que yo vaya*) | → *quiero ir* (the infinitive) | ✅ *quiero que vayas*, *quiero ir* |
| Present subjunctive after *si* or *por si* (they never take it) | *si tengas tiempo* → *tienes*, *por si llueva* → *llueve* (the note offers the imperfect subjunctive for something unlikely) | ✅ *si tengo*, *si tuviera*, *como si fuera*, *si bien es caro*, *no sé si vaya* (whether, heard in Mexico) |
| An irregular verb conjugated as if it were regular | *tenió* → *tuvo*, *hací* → *hice* | ✅ *tuvo*, *vos tenés*, capitalised words |

| The subjunctive after a statement of belief or certainty (*creo que*, *pienso que*, *me parece que*, *es verdad que*, *sé que*, *no cabe duda de que*, *estoy seguro de que*, *está demostrado que*, *resulta que*, *menos mal que*, *si bien*) | *creo que tengas* → *tienes*, *no cabe duda de que sea él* → *es* | ✅ *no creo que tengas*, *¿crees que tengas…?*, *creo que tienes*, *no estoy seguro de que venga*. Left out on purpose because both moods are right: *decir que* (*te digo que vengas* is an order), *no dudo que* and *no niego que*, *me temo que*, *es que* (it sits inside *lo importante es que estés bien*), and every two-mood connector (*aunque*, *cuando*, *mientras*, *después de que*, *siempre que*, *de modo que*, *quizás*, *a lo mejor*, *el hecho de que*) |

The rules come from the research in [docs/conjugation-drill/subjunctive-rules.md](../conjugation-drill/subjunctive-rules.md). The subjunctive rule only looks at the verb right after the trigger (skipping `no`, subject and object pronouns). If a noun phrase comes first (*quiero que los niños vengan*) it stays silent.

### Style

| Rule | Flagged |
| --- | --- |
| Redundant phrases | *subir para arriba*, *bajar para abajo*, *entrar adentro*, *volver a repetir* |

### Punctuation

Not checked. A missing `¿` or `¡` is common in informal writing, so the engine ignores it.

### Heads-up tips (not mistakes)

False friends that look like English but mean something else. They are shown separately, with a yellow highlight, and are never counted as mistakes: *embarazada*, *constipado*, *éxito*, *actualmente*, *carpeta*, *librería*, *sensible*, *asistir*, *realizar*, *soportar*, *decepción*, *disgusto*, *largo*, *fábrica*, *introducir*, *pretender*, *molestar*, *lectura*, *colegio*, *campo*, *preservativo*, *arena* (and their plurals).

## Tense alternatives (not mistakes)

`Flasher/Data/TenseAlternatives.swift` adds an "Also possible" card to Translate when a sentence has a close neighbour tense. The sentence is correct as written; the card shows the rewrite, how the meaning shifts, and a link to that tense in the verb's conjugation chart.

| Sentence has | Card offers |
| --- | --- |
| One preterite (*ya terminé*), no definite past time (*ayer*, *hace dos años*, *cuando*) | Present perfect (*ya he terminado*): completed but relevant to now |
| A present perfect (*no he comido*) | Preterite (*no comí*): finished, without the link to now |
| Two preterites in sequence joined by *y*, *luego*, *después* (*comí tacos y salí*) | Past perfect (*ya había comido tacos cuando salí*) |
| A past perfect anchored by *cuando* (*cuando llegué, ya se había ido*) | Two preterites in the order things happened, reordered (*se fue y después llegué*), noting it loses the "already before" nuance. A past perfect with no other past verb (*ya había comido*) gets a "Good to know" note: it is correct, but only after a clause that introduced another past event, with an example (*cuando llamaste, ya había comido*) |

Three or more preterites in a row, or several *luego* / *después*, get a "Good to know" note instead of a rewrite (a chain is best told in plain preterites). *Cuando* with two preterites gets a note that the second happened right after the first, with the past-perfect version (*cuando llegué, ya había salido*) as the example.

### Subjunctive cards

`Flasher/Data/SubjunctiveRules.swift` adds "Tense match" cards, each with the corrected sentence and why:

| Sentence has | Card offers |
| --- | --- |
| Past verb of wishing + *que* + present subjunctive (*quería que vengas*) | Imperfect subjunctive (*vinieras*) |
| The same with the perfect subjunctive (*esperaba que hayas llegado*) | Pluperfect subjunctive (*hubieras llegado*) |
| Present volition verb + *que* + imperfect subjunctive (*quiero que vinieras*) | Present subjunctive (*vengas*) |
| The same with the pluperfect (*quiero que hubieras venido*) | Perfect subjunctive (*hayas venido*) |
| Present trigger + present subjunctive + a finished time (*dudo que llegue ayer*) | Perfect subjunctive (*haya llegado*) |
| *Si* + conditional (*si tendría tiempo*), or *si habría sabido* | Imperfect (*tuviera*) or pluperfect (*hubiera sabido*) subjunctive. Skipped after *no sé si*, *me pregunto si*, *como si* |
| *Cuando*, *en cuanto*, *hasta que*, *después de que*… + future (*cuando llegaré*) | Present subjunctive (*cuando llegue*) |
| *Como si* + indicative (*habla como si es el jefe*) | Imperfect subjunctive (*fuera*), or pluperfect (*hubiera ganado*) |
| *Buscar / necesitar / querer* + *un*, *algún*, *alguien*… + *que* + present indicative (*busco un coche que tiene*) | Present subjunctive (*tenga*). Silent with a definite thing (*el coche que tiene*) |
| *Aunque* + present indicative + a future word like *mañana* (*aunque llueve mañana*) | "Good to know": present subjunctive (*llueva*) when it isn't certain; the indicative is fine for a known fact |
| -se imperfect subjunctive (*tuviese*) | The -ra form (*tuviera*), noting -se feels formal |
| Future subjunctive (*si hubiere*, *sea lo que fuere*) | A note that it is archaic (laws, set phrases). Its modern equivalent is the present subjunctive (*fuere* → *sea*), and after *si* the present indicative (*si hubiere* → *si hay*) |

Only forms that are unambiguously one preterite person are used (*fue*, *di*, *vivimos* are skipped), and sentences with *cuando*, *porque*, *que*, *si*... are left alone for the sequence rule. At most two cards are shown.

## Dictionary search

The same pronoun logic powers the dictionary search:

- `vernos`, `dímelo`, `dándomelo` open the verb's page with the pronouns explained, the right tense selected, and example sentences that place the pronouns correctly.
- `nos veo`, `yo me veo`, `me lo dice`, `no te vayas` find the verb (a leading subject pronoun is dropped, and it picks the person when a form could be several).
- Mistakes in the query show the same explanations as the Translate tab (`Clitics.correction(forQuery:)`).

## Limits

- Checks forms and patterns, not meaning. It will not catch a correct-looking sentence that says the wrong thing.
- Capitalised words are never accent-checked or tested as irregular forms, because they may be names. Mistakes at the start of a sentence in those two rules are therefore missed.
- The dictionary's noun data is incomplete in places, which is why gender is only trusted in the cases described above.
- Archaic and literary spellings (`puſieronla`, `buscábanle`) are not flagged.
- Written for Latin American Spanish; the target country (Settings) only changes Translate's regional wording. Forms from other regions (voseo, vosotros) are tolerated rather than corrected.

## Testing

```bash
xcodebuild test -scheme Flasher \
  -destination 'platform=iOS Simulator,name=iPhone 17' \
  -only-testing:FlasherTests
```

`FlasherTests/SpanishCheckerTests.swift` is hosted inside the app, so it uses the real dictionary and conjugator. It has:

- a **flagged and not-flagged pair for every rule**, so a rule can neither stop working nor start over-firing unnoticed;
- a **long paragraph of tricky correct Spanish** that must produce no mistakes at all;
- **unit tests for the pieces** the rules are built on: accent placement when pronouns are attached, syllable stress, pronoun resolution, and the search corrections;
- a **real-text regression test** that runs the engine over every dictionary example sentence (about 4,000) and fails if the grammar rules fire more than a handful of times.

When you add or change a rule, run the suite, then look at what the real-text test reports. The hits that remain on that corpus are almost all genuine omissions in informal text (missing `¿`, missing accents).

## Adding a rule

1. Decide how a *correct* sentence could look similar, and write that test first.
2. Put the rule in `SpanishRules.swift` (or `SpanishChecker.swift` if it needs the token list) and call it from `SpanishChecker.check(_:)`.
3. Report it with `add(kind, range, message, suggestion)`. Overlapping issues are dropped automatically, first one wins.
4. If it is a fixed phrase, a `PhraseRule` entry (regular expression plus message builder) is all it takes.
5. Add the rule to the tables in this file.
