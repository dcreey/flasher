# Which tenses can replace each other in the drill

The drill asks for one tense per card, but some sentences are completed just as well by another. When that is so, the
card says so, lets the learner pick the tense (`DrillAlternates`), and counts the answer for the tense they answered in.
Target variety: Mexico and Colombia.

Confidence: **R** = backed by the sources below. **G** = general grammar knowledge, not found in the sources.

## The audit

| Card (target tense and cue) | Also fits | Condition | Status |
|---|---|---|---|
| Pretérito + "ayer" | Pretérito perfecto | A recent past. In Mexico the simple past is the usual choice (about 80–88% of past-tense uses), the compound is also used. | R, and confirmed by a Mexican speaker |
| Pretérito + "de repente" | nothing | A sudden event is one finished moment. | G |
| Pretérito perfecto + "hoy" | Pretérito | "Hoy" is unfinished. In American Spanish both can refer to today, and in Mexico the preterite is more common. | R |
| Imperfecto + "antes… cada semana" | nothing | Habit in the past. | G |
| Futuro + "mañana" | Ir a (ahora), Presente | In everyday American speech ir a is the preferred form; the future is for writing and guesses; the present works with a time word. | R |
| Futuro + "algún día" | Ir a (ahora) | Distant time: the plain present does not fit. | R / G |
| Ir a (ahora) + "mañana" | Futuro, Presente | As above. | R |
| Condicional + "si hubiera tiempo" | Imperfecto, *colloquial* | The imperfect often replaces the conditional in the result part, but it is not standard. | R (a course handout, not a normative source) |
| Condicional perfecto + "si hubiera habido tiempo" | Pluscuamperfecto de subjuntivo | The result part of an unreal past condition accepts both "habría" and "hubiera" (never "si habría"). | R |
| Pluscuamperfecto + "cuando llegué, ya" | **nothing** | Not interchangeable with the preterite: it changes the sense (a before/after becomes a sequence). | R |
| Pretérito perfecto + "todavía no" | Pretérito | Still open up to now. In Mexico the preterite is also common: "todavía no lo compró". | R (same Mexican-usage sources) |
| Pluscuamperfecto + "todavía no" | **nothing** | Up to that past moment it had not happened: not interchangeable with the preterite. | R |
| Pretérito perfecto de subjuntivo + "no creo que … todavía" | nothing | Doubt triggers the subjunctive; "todavía" is up to now. | G |
| Presente progresivo + "ahora" | Presente | The simple present can say what is happening now; the progressive stresses that it is in progress. | R |
| Pretérito progresivo + "toda la tarde" | Pretérito | A limited stretch of time takes the preterite. Not the imperfect. | R |
| Imperfecto progresivo + "cuando llamaste" | Imperfecto | The simple imperfect says it was going on too. | G |
| Futuro progresivo + "mañana a esta hora" | Futuro | Stresses "in the middle of it". | G |
| Condicional progresivo + "si hubiera tiempo" | Condicional | The progressive nuance is lost. | G |
| Futuro perfecto + "para el viernes" | Futuro, Ir a (ahora) | "Terminaré para el viernes" is common; the future perfect stresses it will already be done. | G |
| Imperativo, subject "nosotros" | Ir a (ahora) | "Vamos a + infinitive" for "let's". Tone tells suggestion from statement. | R |
| Estar por (ahora) + "ahora" | Ir a (ahora) | Estar por is closer to "about to". | R |
| Estar por (antes) + "cuando llamaste" | Ir a (antes) | Iba a: planned or about to. | R / G |
| Estar por (pretérito) + "no pasó nada" | Ir a (antes) | Iba a also says what almost happened. | G |
| Acabar de (antes) | nothing | "Acababa de" stresses immediacy, "había + participio" does not. | R |
| Subjuntivo imperfecto, same tense | the **-se form** | "-ra" and "-se" are interchangeable, except when "-ra" stands for the conditional. Accepted as the same answer. | R |
| Subjuntivo presente after "espero que" / "es importante que" | nothing | The trigger requires the subjunctive. | G |

## The moment of the perfect

The perfect looks back from a moment, and it covers two readings: done by then ("ya lo ha hecho") and **still open up to then**
("todavía no lo ha hecho", "ha vivido aquí desde 2010"). So in the selector the perfect tenses count as both **Before** and **During**
(`DrillTense.moments`). "Acabar de" is only Before, and "ir a" and "estar por" are only After.

## Rules the code follows

- A card offers a choice only when its sentence matches one of the rows above (the cue word is in the sentence).
- A "colloquial" option is accepted but labelled as not the standard form.
- Answering in another tense that fits counts for that tense, not for the one the round asked for, so a queued verb still needs the exact tense that was queued.
- The -se forms are accepted as correct, with a note, and are not a different tense.
- Anything not in the table has one answer, and a different tense is marked wrong with an explanation of why.

## Not covered (no card has the cue)

- Present perfect with "esta semana", "este año", "ya", "todavía no", "nunca".
- Pretérito anterior ("hube comido"): rare today.
- Present subjunctive for a future time in "cuando" and "aunque" clauses.
- "Estar para + infinitive".
- The imperfect indicative for polite requests ("quería pedirle…").

## Sources

- Mexico simple past vs compound past rates: [Spanish Wikipedia, "Pretérito perfecto simple"](https://es.wikipedia.org/wiki/Pret%C3%A9rito_perfecto_simple); [Redalyc study of Hispanic American texts](https://www.redalyc.org/pdf/1734/173413835006.pdf).
- Both tenses can refer to "today" in American Spanish: the same Wikipedia article; [Universidad de Valladolid thesis](https://uvadoc.uva.es/bitstream/handle/10324/14580/TFG_F_2015_7.pdf?sequence=1).
- Simple vs compound as a speaker's view of the event: [Masaryk University handout](https://is.muni.cz/el/phil/jaro2017/CJVSGR/um/2_preterito_perfecto.pdf).
- Ir a preferred in spoken American Spanish: [Borealis, Argentine Spanish](https://new.eludamos.org/index.php/borealis/article/download/2337/2222/9112); [Colombian Spanish study](https://core.ac.uk/download/51405179.pdf); future, ir a and present largely interchangeable: [REDELE, Ministerio de Educación](https://educacionfpydeportes.gob.es/dam/jcr:32d4e732-fdfe-4d29-96ae-c113c693bcfe/2006-redele-6-09mattebon-pdf.pdf).
- Hubiera / habría in the result part: [Castellano Actual, Universidad de Piura](https://www.udep.edu.pe/castellanoactual/duda-resuelta-hubiera-y-habria/); "si + conditional" is wrong: [RAE, el condicional simple](https://www.rae.es/gram%C3%A1tica/sintaxis/el-condicional-simple-cantar%C3%ADa).
- Imperfect in place of the conditional: [Universidad de São Paulo course handout](https://edisciplinas.usp.br/mod/resource/view.php?id=3302534) (colloquial).
- -ra and -se: [Castellano Actual](https://www.udep.edu.pe/castellanoactual/duda-resuelta-preterito-imperfecto-de-subjuntivo/); [SpanishDict](https://www.spanishdict.com/answers/138865/imperfect-subjunctivepast-perfect-subjunctive-two-forms).
- Pluperfect vs preterite after "cuando llegué, ya": [Castellano Actual, uso del pluscuamperfecto](https://www.udep.edu.pe/castellanoactual/duda-resuelta-uso-del-preterito-pluscuamperfecto/).
- Estar por: [DPD, entrada "estar"](https://rae.es/dpd/estar).
- Nosotros commands: [SpanishDict](https://www.spanishdict.com/guide/nosotros-commands).
- Bounded durations take the preterite: a teaching worksheet ([todoele](https://todoele.net/sites/default/files/actividades/ficha_indefinido_e_imperfecto.pdf)); no normative source found.
- Present progressive vs simple present: [Happy Languages](https://www.happylanguages.co.uk/presente-and-estar-mas-gerundio/) and learner sources; no normative source found.

The searches did not reach the RAE's Nueva gramática text itself, so every "R" above is from secondary sources that cite it.


## Second audit: one tense, several moments

A tense is not tied to one moment. `Flasher/Data/DrillReadings.swift` now lists every reading of each of the 28 tenses
(time it is anchored to, where the action sits, example, note); the first is the main one. The Time and Moment filters, the
selector summary and the "why this tense" card all use these readings.

| Tense | Readings beyond the main one |
|---|---|
| Presente | future with a time word (mañana viajo); still true since (vivo aquí desde 2010); historical present |
| Imperfecto | future of the past in reported speech (dijo que venía), informal |
| Futuro | guess about now (estará durmiendo) |
| Condicional | future of the past (dijo que vendría); guess about the past (serían las ocho) |
| Subj. presente | present and future (cuando llegue) |
| Subj. imperfecto | past, and unreal present or future (si tuviera, ojalá viniera mañana) |
| Imperativo | now, or later (mañana llámame) |
| Perfect tenses | done by the moment, or still open up to it (todavía no); futuro perfecto and condicional perfecto also guess/future of the past |
| Subj. presente perfecto | done before a future moment (cuando hayas terminado) |

Sources: RAE (Gramática, presente/futuro compuesto de subjuntivo), Castellano Actual (udep.edu.pe), Gutiérrez Araus on the
imperfect, Yepes on future and conditional, SpanishDict/Lawless Spanish on the progressive. The pluperfect to preterite
swap stays out of the alternates: it is only acceptable when context fixes the order.
