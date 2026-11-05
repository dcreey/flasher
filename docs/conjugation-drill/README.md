# Conjugation drill: sentence rules engine

Design for the 4th tab ("Study tense"). Instead of storing sentences for every verb, the app **builds** a sentence from three things:

```
sentence = frame(tense)  +  verb profile(verb)  +  complement(verb class)
```

- **Frame**: a sentence skeleton that is correct for a tense, with slots for subject, verb and complement.
- **Verb profile**: one short tag set per verb (what kind of verb it is, what it needs after it).
- **Complement bank**: a few dozen phrases per verb class that fit that class.

This replaces ~106,000 stored sentences (~13 MB) with roughly 4,432 profiles + a few hundred frames and phrases (~100 KB). Variety comes from combining: frames × persons × complements.

---

## 1. Verb profile

One line per verb, generated once by a script and then reviewed. Fields:

| Field | Values | Used for |
|---|---|---|
| `valency` | `T` transitive (needs object), `I` intransitive, `TI` either, `M` motion (needs a + place or de + place), `C` copula (ser/estar-like, needs adjective/noun), `W` weather (3rd singular only), `P` psych/gustar-type (indirect object + 3rd person subject), `Q` speech/thought (takes que-clause), `X` modal/aspectual (takes infinitive) | Which complements fit |
| `reflexive` | `none`, `optional`, `only` (quejarse, arrepentirse) | Add `me/te/se/nos/se` |
| `stative` | yes/no (saber, tener, ser, conocer, querer, vivir) | Preterite/imperfect rules, progressive |
| `controllable` | yes/no (a person can choose to do it: comer yes, olvidar no, llover no) | Commands, "te pido que", "quiero que" |
| `animate` | subject must be a person/animal | Subject slot |
| `persons` | allowed persons, default all six; W/P restrict to 3rd | Skip person drills that make no sense |
| `object` | `thing`, `person` (a + person), `place`, `food`, `text`, `abstract` | Picks the complement bank |
| `special` | `preterite-shift` (saber, conocer, querer, poder, tener), `defective`, `pronominal-meaning` (ir/irse, dormir/dormirse) | Edge cases in section 5 |

Defaults come from existing data: part-of-speech and glosses in the lexicon, the reflexive detection already in `VerbForms.baseVerb`, and a short hand-tag list for the ~800 most frequent verbs. A verb with no profile gets the safest class: `TI`, `object: abstract`, which only produces the "generic" frames (section 3.x, frames marked `any`).

If a verb has no safe frame in a tense, the tense is **skipped for that verb** instead of showing a bad sentence. The drill screen says "No example sentences for this tense, showing the chart".

### 1.1 Subject kinds (implemented)

Every one of the 4,432 verbs has a subject kind in `Flasher/Data/VerbProfiles.swift`. Plain person verbs are the default; only the exceptions (300) are listed in `VerbProfileData.swift`.

| Kind | Meaning | Subjects the drill uses | Examples |
|---|---|---|---|
| `person` | people only (about 4,130 verbs) | yo, tú, él, ella, usted, nosotros, ellos, ustedes, mi hermana, mis padres… | pensar, hablar, comprar |
| `living` | people and animals | the people above + el perro, los gatos | comer, dormir, morir |
| `thing` | things or events, third person only | la puerta, el coche, las luces… | funcionar, gustar, ocurrir, haber |
| `any` | people or things | both lists | abrir, cambiar, empezar, ser |
| `weather` | no subject, third singular | none (the sentence has no subject) | llover, nevar, amanecer |

Narrow pools: `ladrar` takes only dogs, `hervir` only liquids, `costar` only priced things, `funcionar` only machines, `florecer` only plants. In every tense: commands go only to tú/usted/nosotros/ustedes (never to things or weather); vosotros is off unless asked for.

The tags come from the English gloss of each verb plus a hand list of the most common ones. They need a review pass: `python3` script output is a first draft and unusual verbs default to `person`.

---

## 2. Frame format

```
tense:      preterite
id:         pret.time-marker
template:   "{cue} {s} {v} {obj}."
cue:        ayer | anoche | la semana pasada | el lunes | hace dos días | una vez
requires:   valency ∈ {T, TI, I, M}; not stative unless special ok
forbids:    cue from other tenses
persons:    all
```

Slots:
- `{s}` subject pronoun or noun (can drop for pro-drop frames: the app shows the pronoun in the card prompt).
- `{v}` the form from `Conjugator`, always from the engine, never typed by hand.
- `{obj}` / `{place}` / `{que}` complement from the bank for the verb's class.
- `{cue}` time words that fit the tense.

Agreement is handled by the frame. Reflexive pronouns, object pronouns (`lo`, `la`, `le`) and `a` before persons are inserted by small functions, so `se lavó las manos` and `me lavé las manos` come from the same frame.

---

## 3. What is correct per tense

### 3.1 Present (indicative)
- **Uses**: now, habit, general truth, near future with a cue.
- **Frames**:
  1. `{s} {v} {obj} todos los días / siempre / a veces / normalmente.` (habit)
  2. `Ahora {s} {v} {obj}.` (now; avoid for non-progressive stative verbs only if ambiguous)
  3. `Mañana {s} {v} {obj}.` (near future, only for verbs with `controllable`)
  4. `{s} {v} {obj} desde hace {tiempo}.` (only for `stative` or continuing actions: vivir, trabajar, estudiar)
- **Cues**: siempre, nunca, todos los días, normalmente, a veces, ahora, hoy, cada semana.
- **Never**: ayer, anoche, la semana pasada (these force the preterite).

### 3.2 Preterite (pretérito indefinido)
- **Uses**: a finished event, a sequence, an action with a clear start or end.
- **Frames**:
  1. `Ayer / Anoche / El lunes {s} {v} {obj}.`
  2. `{s} {v} {obj} hace {tiempo}.`
  3. `La semana pasada {s} {v} {obj} y después {…}` (only used when the engine can pair two verbs, otherwise skip)
  4. `Una vez {s} {v} {obj}.`
  5. `{s} {v} {obj} durante {duración}.` (for activity verbs: trabajar, estudiar, esperar)
- **Cues**: ayer, anoche, anteayer, el año pasado, el lunes, hace dos días, una vez, de repente, en 2019, durante tres horas.
- **Never**: siempre, todos los días, mientras (imperfect cues).
- **Edge**: stative and mental verbs change meaning (section 5.1). Use only the preterite-shift frames for them.
- **Progressive**: handled by the gerund tab, not here.

### 3.3 Imperfect
- **Uses**: habit in the past, description, ongoing background, age/time/weather in the past.
- **Frames**:
  1. `Cuando era niño, {s} {v} {obj} todos los días.` (habit)
  2. `Antes {s} {v} {obj} cada semana.`
  3. `Mientras {s} {v} {obj}, …` is only used with a second clause from a fixed bank of backgrounds: `llovía`, `sonaba el teléfono`, `yo cocinaba`.
  4. `{s} {v} {obj} cuando {evento en pretérito}.` (interrupted action, event picked from a bank of short interrupters: `llamaste`, `llegó mi madre`, `empezó a llover`)
  5. `Era… / Estaba… / Tenía…` description frames for `C` and `stative` verbs.
- **Cues**: siempre, a menudo, de niño, antes, cada verano, mientras, en aquel entonces.
- **Never**: ayer, anoche, hace dos días, de repente.

### 3.4 Future (simple)
- **Uses**: plans, predictions, guesses about now ("estará en casa").
- **Frames**:
  1. `Mañana / El próximo año / La semana que viene {s} {v} {obj}.`
  2. `Algún día {s} {v} {obj}.`
  3. `Seguro que {s} {v} {obj}.` is allowed only because *seguro que* takes the indicative (section 4.4).
  4. Guess frame: `Ahora {s} {v} {obj}, creo.` limited to `stative` and `C` verbs.
- **Cues**: mañana, pronto, el año que viene, dentro de dos horas, algún día, el lunes (with future context).
- **Never**: a past cue. Do not use `ir a + infinitive` as a card, only as a hint in the notes.

### 3.5 Conditional (simple)
- **Uses**: politeness, hypotheticals, advice, future-in-the-past.
- **Frames**:
  1. `Yo en tu lugar {v} {obj}.` (advice, 1st person only)
  2. `{s} {v} {obj} si {imperfect subjunctive clause}.` and `Si {imperfect subjunctive}, {s} {v} {obj}.` The subordinate clause comes from the si-clause bank (section 4.6).
  3. `¿{v} {s} {obj}?` polite request, for `controllable` verbs with 2nd/3rd person and the modals `poder`, `querer`, `gustar`.
  4. `{Dijo} que {s} {v} {obj}.` (future-in-the-past), the main clause comes from a bank of past speech verbs.
- **Cues**: en tu lugar, si pudiera, con más tiempo, tal vez, me gustaría.
- **Never**: `si` + conditional in the same clause (*si tendría* is an error and the checker already flags it).

### 3.6 Subjunctive present
Built from trigger frames, so see section 4. Frame shape: `{trigger} que {s2} {v} {obj}.` where `{s2}` is a **different** subject from the trigger's subject.

### 3.7 Subjunctive imperfect
- **Frames**:
  1. Sequence of tenses: past trigger + `que {s2} {v}`: `Quería que {s2} {v} {obj}.`
  2. `Si {s} {v} {obj}, {main clause in conditional}.` main clause from the bank.
  3. `Ojalá {s} {v} {obj}` (a wish that is unlikely or contrary to fact).
  4. `Como si {s} {v} {obj}.`
  5. Polite 1st person: `Quisiera / Pudiera / Debiera …` (only for the three verbs that use it).
- **Never**: present-tense trigger (*quiero que vinieras* is wrong unless the trigger is itself past or conditional).

### 3.8 Imperative
- **Affirmative (tú, usted, nosotros, ustedes)**: `{v} {clitic}…` plus `{obj}`: `Cómelo ahora.` Needs `controllable` and an addressee.
  - Clitics attach and accents move: `dime`, `dámelo`, `siéntate`. The engine builds the accent.
  - Irregular tú imperatives (di, haz, ve, pon, sal, sé, ten, ven) come from the conjugator table, not from rules.
- **Negative**: uses the **present subjunctive**, clitics go before: `No lo comas.` `No te sientes.`
- **Skip** for `W`, `P`, and non-controllable verbs (*no llueva* only exists as a wish).
- **vosotros** is hidden by default for Mexico/Colombia.

### 3.9 Compound tenses (later, optional)
These are already in the participle table and need only a helper-verb frame:
- Present perfect: `Hoy / Esta semana / Ya / Todavía no {s} he {part} …` Cues: ya, todavía no, nunca, alguna vez, esta semana, hoy. Mexico and Colombia often use the preterite for the same meaning, so these cards say "also common: preterite".
- Pluperfect: `Cuando {event}, ya {s} había {part} …`. It needs an anchor, as in the Translate cards.
- Future perfect: `Para las cinco, {s} habrá {part} …`
- Conditional perfect: `Si hubiera …, {s} habría {part}`
- Subjunctive perfect: `Espero que {s2} haya {part} …`, `Si hubiera {part} …`

---

## 4. Subjunctive: which triggers take it, which do not

The drill never uses a trigger the app has not got a tested rule for. The same lists feed `SpanishChecker`, so drill and checker cannot disagree.

### 4.1 Always subjunctive (when the subject changes)
Use WEIRDO as the memory aid: **W**ishes, **E**motions, **I**mpersonal expressions, **R**ecommendations, **D**oubt/Denial, **O**jalá.

| Group | Triggers (verb + que) |
|---|---|
| Wishes / wants | querer, desear, esperar, preferir, necesitar, ojalá |
| Influence (commands, requests, advice) | pedir, rogar, suplicar, exigir, sugerir, recomendar, aconsejar, proponer, insistir en, permitir, prohibir, dejar, impedir, evitar, mandar, ordenar, decir (as an order), hacer (as cause) |
| Emotion | alegrarse de, me alegra, me gusta / encanta / molesta / fastidia / sorprende / da miedo / da pena, sentir (= lamentar), temer, tener miedo de, lamentar, odiar, esperar |
| Doubt / denial | dudar, negar, no creer, no pensar, no parecer, no estar seguro de, no es verdad, no es cierto |
| Impersonal opinion/value | es importante, es necesario, es mejor, es bueno, es malo, es posible, es probable, es increíble, es una lástima, es raro, basta, hace falta, conviene, vale la pena |

### 4.2 Never subjunctive (indicative) after
Certainty, knowledge, perception, and reporting: creer, pensar, opinar, suponer, saber, ver, notar, oír, darse cuenta de, decir (reporting), contar, explicar, afirmar, asegurar, recordar, es verdad, es cierto, es obvio, es evidente, está claro, parecer que, no dudar que, no negar que, seguro que.

The existing `indicativeRules` flag *creo que tengas* and *sé que vengas*.

### 4.3 The negative and question flips
| Pattern | Mood |
|---|---|
| `creo que` + indicative | indicative |
| `no creo que` + subjunctive | subjunctive |
| `¿crees que …?` | indicative by default, subjunctive possible if the speaker doubts: both accepted, so the drill avoids it |
| `dudo que` + subjunctive | subjunctive |
| `no dudo que` + indicative | indicative |
| `no es verdad que` + subjunctive; `es verdad que` + indicative | flips |
| `no sé si` + indicative or conditional | indicative (it is "if/whether", not a trigger) |

### 4.4 Same subject, no subjunctive
If the subject does not change, Spanish uses the infinitive:
- `Quiero comer` (not *quiero que yo coma*).
- `Espero llegar a tiempo`.
- `Es importante estudiar` (general), `Es importante que estudies` (specific person).

Drill rule: subjunctive frames **must** pick `{s2}` different from `{s}`.

### 4.5 Influence verbs that take an object + infinitive instead of que
`permitir`, `dejar`, `prohibir`, `mandar`, `hacer`, `impedir`, `aconsejar` accept both: *Te permito salir* and *Te permito que salgas*. Drill uses the **que** version for subjunctive cards, and the notes mention the infinitive.

### 4.6 Conjunctions
| Group | Rule | Triggers |
|---|---|---|
| Always subjunctive | The event may not happen or is a purpose or condition | para que, a fin de que, antes de que, sin que, a menos que, con tal (de) que, siempre que (= provided that), en caso de que, a no ser que, a condición de que |
| Time conjunctions | Subjunctive if the event is in the future or not yet true; indicative if habitual or past | cuando, en cuanto, tan pronto como, apenas, hasta que, después de que, mientras (que), siempre que (= whenever) |
| Concessive | Indicative when the fact is known; subjunctive when it is hypothetical or unimportant | aunque, a pesar de que, por más que, por mucho que |
| Manner | Subjunctive for an unknown way | como (= however), según, como si (always imperfect/pluperfect subjunctive) |
| Si-clauses | `si` + imperfect subjunctive → conditional; `si` + present indicative → present/future; `si` + pluperfect subjunctive → conditional perfect | si |

Examples:
- `Cuando llegues, llámame.` (future, not yet) / `Cuando llego, siempre saludo.` (habit).
- `Aunque llueve, salgo.` (it is raining, I know) / `Aunque llueva, saldré.` (even if it rains).
- `Hasta que no termines, no te vas.`

### 4.7 Relative clauses
Subjunctive when the thing is **unknown or does not exist**; indicative when it is known and real:
- `Busco una persona que hable inglés.` (any, unknown) / `Conozco a una persona que habla inglés.` (known).
- `No hay nadie que sepa.` / `Hay alguien que sabe.`
- `¿Hay algo que te guste?` (open) / `Hay algo que me gusta.` (known).

Drill triggers: busco, necesito, quiero + indefinite article/algún/cualquier; no hay nadie/nada que; no conozco a nadie que; ¿hay alguien que…?

### 4.8 Other triggers
| Trigger | Mood |
|---|---|
| quizá, quizás, tal vez, acaso | subjunctive (doubt) or indicative (the speaker is sure): the drill uses subjunctive |
| a lo mejor, igual (= maybe) | indicative |
| posiblemente, probablemente | either, avoid |
| que + 3rd-person present subjunctive (*Que descanses*, *Que Dios te bendiga*) | wishes |
| lo que sea, quien sea, donde sea, cualquiera | subjunctive |
| ojalá (que) | subjunctive; present for possible, imperfect for unlikely |
| por si acaso | subjunctive or indicative; avoid |

### 4.9 Sequence of tenses
The tense of the trigger decides the subjunctive tense in the clause:

| Trigger | Subordinate subjunctive |
|---|---|
| Present, present perfect, future, imperative | Present: *Quiero / He querido / Querré / Dime que vengas* |
| Preterite, imperfect, conditional, pluperfect | Imperfect: *Quería / Quise / Querría que vinieras* |
| Statement about the past that is still true | Present is allowed (*Me pidió que venga mañana*), so the drill avoids this |

### 4.10 Verb-specific rules for the frame picker
| Rule | Why |
|---|---|
| `te pido / te ruego / quiero que` need a **controllable** subordinate verb for the second subject | *Te pido que llueva* is odd |
| Impersonal triggers (`es importante que`) take any verb | |
| `ojalá` takes any verb, including `W` (weather) | *Ojalá llueva* is natural |
| `P` verbs (gustar) as the subordinate verb use 3rd person: *Espero que te guste*, *Espero que te gusten* | Subject is the thing liked |
| `only` reflexives need the pronoun for the second subject: *Quiero que te arrepientas* | |
| `X` modals as the subordinate verb need an infinitive after them: *Espero que puedas venir* | |
| Stative verbs in the imperfect subjunctive are fine (*Quería que supieras*) | Meaning shift is only in the indicative preterite |
| Subjunctive after `no creo que` needs a clause the speaker can doubt, so avoid `C` verbs with fixed truths (*no creo que sea martes* is fine, *no creo que el sol sea una estrella* is odd) | Complement bank for `C` uses neutral adjectives |

---

## 5. Edge cases

### 5.1 Preterite vs imperfect meaning shift
| Verb | Preterite means | Imperfect means |
|---|---|---|
| saber | found out (*Supe la verdad*) | knew (*Sabía la verdad*) |
| conocer | met | knew (a person) |
| querer | tried (*Quise abrirla*) / refused (negative) | wanted |
| poder | managed to (*Pude abrirla*) / failed (negative) | was able to, could |
| tener | received / got (*Tuve una carta*) | had |
| costar | cost (one time) | was costing / used to cost |

Drill: the frames for these verbs in the preterite use the dedicated shift frames, and the card note shows the English difference.

### 5.2 Defective and impersonal verbs
- Weather (`llover`, `nevar`, `amanecer`, `anochecer`, `granizar`, `tronar`): 3rd singular only.
- `haber` (impersonal): *hay, había, hubo, habrá, habría, haya, hubiera* only, never plural: *Había muchas personas*.
- `gustar`, `encantar`, `doler`, `faltar`, `sobrar`, `importar`, `interesar`, `molestar`, `parecer`: indirect object pronoun + 3rd person, plural when the thing is plural.
- `ocurrir`, `suceder`, `pasar` (= happen): 3rd person.
- `soler` has no preterite or future in practice: only present, imperfect.
- `abolir`, `balbucir` (rare): skip.

### 5.3 Irregular stems and spelling changes
Those come from `Conjugator`. The drill must never reimplement them. Test: for every verb × tense × person, the form in the sentence **equals** `Conjugator.conjugate(verb).form(tense, person)`.

### 5.4 Reflexive and pronominal
- Add the pronoun before the verb, or after the infinitive/gerund/affirmative imperative.
- Verbs that change meaning: `ir/irse`, `dormir/dormirse`, `poner/ponerse`, `llamar/llamarse`, `quedar/quedarse`, `volver/volverse`. Drill prefers the base verb unless the user opened the reflexive entry.
- Reciprocal (`se abrazan`) needs plural persons, skip other persons.

### 5.5 Object `a`
Direct objects that are specific persons need `a`: *Veo a María*. The bank keeps `object: person` complements with `a` already inserted. Never pair `tener` with a personal `a` (*Tengo dos hermanos*).

### 5.6 Verbs followed by a preposition
Tag with the preposition (`pensar en`, `soñar con`, `depender de`, `acordarse de`, `casarse con`, `enamorarse de`, `confiar en`, `insistir en`), the complement bank gives `{prep} + noun`.

### 5.7 Verbs with an infinitive or gerund
`X` verbs (`poder`, `deber`, `querer`, `soler`, `tener que`, `ir a`, `acabar de`, `empezar a`, `volver a`, `seguir + gerund`): complement is an infinitive from a small bank of common controllable verbs: *comer, hablar, salir, venir, trabajar, ayudar*. Check the infinitive differs from the verb itself.

### 5.8 Subjects and persons
- Default drill persons: yo, tú, él/ella/usted, nosotros, ellos/ellas/ustedes.
- `vosotros` hidden for Mexico and Colombia, with a setting to show it.
- `usted` in Colombia is common for polite use, the frames use él/ella/usted as the same card.
- Pro-drop: the prompt shows the pronoun in brackets (*(yo) comer → …*) but the sentence may omit it.

### 5.9 Time cue conflicts
A frame's cue words and the verb must not clash. Examples to forbid:
- `estar` + `de repente` in the preterite is allowed but changes meaning, so skip.
- `saber` + `ahora mismo` in the preterite: forbid.
- `morir` in the imperfect with `siempre`: forbid (you only die once).
- `nacer`, `morir`, `casarse` in the present with a habit cue: forbid.

A small `once-only` tag handles that: `morir, nacer, casarse, divorciarse, graduarse, jubilarse`. They are only valid with preterite/future/cond. cues, or with *se* for narration.

---

## 6. Complement banks (examples)

Each class has 30 to 60 short complements. They are checked with the same checker as everything else, and they should be neutral for every tense.

| Class | Examples |
|---|---|
| `T/food` | el desayuno, una manzana, pollo con arroz, café, la cena |
| `T/thing` | el libro, la puerta, mis llaves, un correo, el coche |
| `T/person` | a mi hermana, a los niños, a tu amigo, a la profesora |
| `T/text` | una carta, la receta, el artículo, un mensaje |
| `T/abstract` | un problema, la verdad, una idea, mucho trabajo |
| `I` | en casa, por la mañana, mucho, bien, sin parar, con calma |
| `M` | al mercado, a la escuela, de la oficina, hasta el parque |
| `C` | cansado, listo, en la cocina, de buen humor |
| `Q` | que es tarde (indicative), que vengas (subjunctive; the frame picks) |
| `X` | an infinitive from the controllable bank |

---

## 7. Card flow

1. User taps "Study this tense" next to the highlighted conjugation example (verb + tense saved).
2. The drill generator picks a **frame** compatible with tense and verb profile.
3. The generator picks a **person**, weighting persons the user got wrong.
4. It builds the sentence and the English hint (frame gives a template with the English tense, the verb's English gloss supplies the verb).
5. The card shows the sentence with a blank for the verb form and the infinitive in brackets. The user types the answer.
6. Accent forgiveness: an unaccented answer is accepted, with a note showing the accent.
7. After the answer the card shows the full sentence and the rule behind it ("preterite: ayer = finished event").

Cards do not need to be stored. The seed + frame id + person is enough to rebuild the same card, so progress tracking is small (a counter per verb/tense/person).

---

## 8. Testing

The generator is deterministic, so all of the following run as unit tests over **every verb × every tense × every person × every compatible frame**:

1. **Form check**: the verb in the sentence equals the conjugator's form.
2. **Checker check**: `SpanishChecker` reports zero mistakes (tips allowed).
3. **Tense check**: the existing form index (`VerbForms.index`) finds the verb in the generated sentence and reports the intended tense, and `TenseAlternatives` raises no contradicting card.
4. **Cue check**: no cue from another tense appears in a frame (cue lists are tagged).
5. **Profile check**: the frame's `requires` and `forbids` hold for the verb's profile.
6. **Agreement check**: reflexive and object pronouns match the person.
7. **Duplicate check**: no two sentences for a verb are identical across frames.
8. **Subjunctive check**: for every trigger frame, `{s2} ≠ {s}`, the sequence of tenses is correct, and the trigger is in the allowed list from section 4.
9. **Golden sample**: 200 randomly chosen sentences saved to `docs/conjugation-drill/review.md` on each run so you can read them quickly. Any reviewed bad sentence goes onto a deny list `(verb, frame)` that the generator honours.

Because the generator and `SpanishChecker` share trigger tables, a rule change in one automatically updates the other. A rule that passes in drills but fails in the checker (or the other way round) fails the build.

---

## 9. Data and code size

| Item | Size |
|---|---|
| Verb profiles (4,432 verbs, ~6 bytes each) | ~30 KB |
| Frames (≈150) | ~15 KB |
| Complement banks (≈400 phrases) | ~15 KB |
| Trigger and cue tables (shared with checker) | ~10 KB |
| Deny list | <5 KB |
| **Total data** | **~75 KB** |
| Code | ~1,500 lines Swift + ~600 lines tests |

Compared to ~13 MB for stored sentences, and every sentence is correct by construction for any new verb added to the lexicon.

---

## 10. Rollout

1. **Phase 1**: profiles for the ~800 most frequent verbs, frames for present, preterite, imperfect, future, conditional. Ship with a "Study tense" button and the 4th tab. The less frequent verbs fall back to the generic frames.
2. **Phase 2**: subjunctive present and imperfect (trigger tables from section 4), imperative.
3. **Phase 3**: compound tenses and the remaining profiles; typing mode with accent forgiveness; spaced repetition per (verb, tense, person).
4. **Throughout**: golden-sample review, deny list, and the test matrix in section 8.

## 11. Known limits

- A rule engine makes **safe** sentences, not literary ones. They will feel repetitive after a while, so frames are added to the bank over time.
- Some verbs (about 5–8% of the lexicon) have no safe frame in some tenses, and are skipped for that tense.
- Verb profiles are tagged by script and need review. The first 800 are reviewed by hand; later ones fall back to generic frames until reviewed.
- English hints for the frame and the verb are templates, so they may sound stiff (*Yesterday you ate the breakfast*). Plan on article/phrase tweaks per class.

---

## 12. Drill tenses (28) and what the 50-verb run taught us

`DrillTense` in `Flasher/Data/DrillSentences.swift` lists everything a drill can ask for:

| Group | Tenses |
|---|---|
| Simple (8) | present, preterite, imperfect, future, conditional, subjunctive present, subjunctive imperfect, imperative |
| Progressive, estar + gerund (7) | present, preterite, imperfect, future, conditional, subjunctive present, subjunctive imperfect |
| Perfect, haber + participle (6) | present perfect, pluperfect, future perfect, conditional perfect, subjunctive perfect, subjunctive pluperfect |
| acabar de + infinitive (2) | present, imperfect |
| ir a + infinitive (2) | present, imperfect |
| estar por + infinitive (3) | present, imperfect, preterite |

Rules the 50-verb run (≈1,370 sentences, all clean in `SpanishChecker`) added:

1. **Complements never contain possessives** (*su*, *mi*, *tu*): they clash with the subject (*mi amigo y yo traicionaríamos a su amigo*). Use *el/la/un* or *al*.
2. **Si-clauses are subject-free** (*si hubiera tiempo*, *si hubiera habido tiempo*): *si tuviera tiempo* is wrong after a plural subject.
3. **Pronoun drop**: yo, tú, nosotros, vosotros are dropped; él, ella, usted, ellos, ustedes and noun subjects stay.
4. **Same subject**: after *espero que* a subject that includes the speaker uses *es importante que* / *era importante que* instead.
5. **Pools are needed for things**: a generic list of things gave *la película abriría*, *el precio arde*. Now `any` and `thing` verbs name a pool (generic, event, openable, burn, shaky, light, sound, body, flow, priced, machine, liquid, plant, bird); an `any` verb without a pool takes people only.
6. **Stative verbs** (saber, tener, ser, depender, costar…) skip the progressive, *acabar de* and *estar por*. **Momentary verbs** (empezar, terminar, llegar, morir…) skip the progressive only.
7. **Rare verbs** (placer, acaecer, acontecer) are excluded.
8. **Cue words need to be per verb class**: *La casa arde todos los días* comes from the one generic "todos los días" cue.

---

## 13. Fixes for the weak sections (usage codes)

The three weak points from the 50-verb run are fixed by one idea: every verb gets a **usage code** (`Flasher/Data/VerbUsage.swift`, data in `VerbUsageData.swift`), and sentences are built from the code, not from hand-picked complements.

Code = valency + object + aspect (+ preposition):

| Part | Values |
|---|---|
| Valency | **T** object · **S** que-clause (*digo que…*) · **M** motion + place · **P** fixed preposition (*hablar con*) · **X** + infinitive (*poder comer*, *empezar a comer*) · **C** linking (*ser, estar, parecer*) · **I** intransitive · **D** gustar-type (*me gusta la película*) · **W** weather · **Z** skipped |
| Object | food, thing, person (with *a*), text, device, abstract, media, task, job/permit, something awaited, place, sound, event, money, que-clause, si-clause, origin, adverb |
| Aspect | **a** activity (can be in progress) · **c** accomplishment · **k** instant · **s** state · **e** event |

1. **Cue words per verb class.** The aspect picks the cue: activities get *todos los días / cada semana*, instants get *a veces* and *De repente* in the preterite, states get no habit cue (*Creo que ya es tarde*, not *…todos los días*). States and instants also skip the progressive; states skip *acabar de* and *estar por*.
2. **Complement banks for every verb.** One bank per (valency, object): 14 object banks, 10 preposition banks, motion, linking, adverb and infinitive banks. The pick is deterministic per verb, tense and person, so a card is always the same card. Things as subjects use a separate bank per pool (*La película empieza a las ocho*, *El libro cuesta mucho*). Gustar-type verbs build *Me/Te/Le/Nos/Les + verb + thing*. No bank contains a possessive (tested).
3. **All 4,432 verbs have a code.** About 500 of the most common were tagged by hand (`reviewed`). The other ~3,900 are guessed from the English gloss (default: transitive on a thing) and marked `reviewed == false`; 22 stay skipped (haber, seguir, vulgar and rare verbs).

Tests: the hand-tagged verbs run in all 28 drill tenses with zero checker mistakes (≈14,000 sentences). The guessed verbs, ≈100,000 sentences, are checked for form, spacing, capitals and checker mistakes.

**Still open:** the guessed verbs are well-formed but not necessarily natural (an intransitive verb guessed as transitive gets an object it shouldn't have). They need a review pass by frequency band, which is what the `reviewed` flag is for.
