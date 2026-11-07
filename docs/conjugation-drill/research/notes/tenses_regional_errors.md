# Spanish Subjunctive: Tense Sequence, Forms, Regional Usage (Mexico/Colombia) and Learner Errors

Research notes. Status labels used throughout:
- **[NORM]** = normative / standard in educated speech and writing across the Spanish-speaking world.
- **[ACCEPTED-VAR]** = documented and not condemned by the RAE/ASALE descriptive grammar, but regionally or contextually limited.
- **[COLLOQ/REG]** = colloquial or regional; an app should accept it in recognition but not generate it as the default.
- **[ARCHAIC/FORMAL]** = restricted to legal, literary, journalistic or set phrases.
- **[ERROR]** = learner error to correct.

Note on access: rae.es pages (Glosario de términos gramaticales, DPD, Libro de estilo) returned HTTP 403 to the fetch tool. RAE content below comes from search-result snippets of those pages, or from secondary sources that quote the RAE. Where this matters it is flagged.

---

## 1. Sequence of tenses (correlación de tiempos / consecutio temporum)

### Takeaway
The base rule is "present zone with present zone, past zone with past zone": present, present perfect (in Spain), future and imperative main verbs take present or perfect subjunctive; preterite, imperfect, pluperfect and conditional main verbs take imperfect or pluperfect subjunctive. Real usage, especially in Latin America, breaks the rule in two directions: (a) past main verb + present subjunctive when the subordinate event is still future or still valid (*Me pidió que venga mañana*), which is widespread in the Andes and Southern Cone and found "to a lesser degree" in Mexico City; and (b) in Latin America the present perfect (*me ha pedido*) behaves like a past tense, so the imperfect subjunctive after it is common there. Normative/prescriptive sources (including a Colombian legal newspaper) still prefer the imperfect subjunctive after a past main verb.

### Cited Findings

**Base table [NORM]**
- Present zone (presente, pretérito perfecto in Spain, futuro simple, futuro perfecto, imperativo) → present subjunctive for simultaneous/later events (*hable*), perfect subjunctive for prior events (*haya hablado*). Past zone (pretérito, imperfecto, pluscuamperfecto, condicional, condicional compuesto) → imperfect subjunctive for simultaneous/later (*hablara/hablase*), pluperfect subjunctive for prior (*hubiera/hubiese hablado*). — [Elon.io, Concordancia de tiempos](https://elon.io/grammar/spanish-spain/verbs/subjunctive/other/sequence-of-tenses)
- Examples from that source:
  - Present + present subj: *Quiero que vengas mañana a comer.* / *Te lo digo para que estés tranquilo.*
  - Imperative + present subj: *Dile que me llame cuando pueda.*
  - Present + perfect subj (prior): *Me alegro mucho de que hayas venido.* / *Espero que no hayas perdido el tren.*
  - Past + imperfect subj: *Quería que vinieras a comer, pero ya tenías planes.* / *Le dije que me llamara cuando pudiera.*
  - Conditional + imperfect subj: *Me gustaría que vinieras a la inauguración.*
  - Past + pluperfect subj (prior): *Me alegré de que hubieras venido al final.* / *No creía que se hubiera atrevido a hacer algo así.*
  - Cascades: *Quiero que le digas que venga.* / *Quería que le dijeras que viniera.* / *Me alegro de que le hayas dicho que viniera.*
  - Decir: report of fact = indicative (*Dijo que venía*); report of command = subjunctive (*Te dijo que vinieras*).
  — [Elon.io](https://elon.io/grammar/spanish-spain/verbs/subjunctive/other/sequence-of-tenses)
- Traditional formulation: "Presente con presente, pasado con pasado"; with a past main verb, per the RAE *Esbozo* (1973, 519-520), "el [verbo] subordinado debe ir también en pasado". Verbs of will (mandar, rogar, desear) are "anteriores a su cumplimiento", so their complement is always posterior. — [Bröer 2024, *Signo y Seña* 46, quoting RAE 1973](https://dialnet.unirioja.es/descarga/articulo/9881110.pdf)

**Relaxation 1: present main verb + imperfect subjunctive for a past event [NORM]**
- After a present-tense trigger, the imperfect subjunctive is used for a specific past event, the perfect subjunctive for a past event with present relevance: *No creo que mintiera* vs *No creo que haya mentido*. — [Elon.io](https://elon.io/grammar/spanish-spain/verbs/subjunctive/other/sequence-of-tenses)
- Same source flags *Me alegro de que vinieras ayer* as "awkward" in Spain (prefers *hayas venido*). — [Elon.io](https://elon.io/grammar/spanish-spain/verbs/subjunctive/other/sequence-of-tenses). Note: this judgement is Spain-centred; in Latin America, where the preterite is preferred for past events, *Me alegro de que vinieras ayer* is the expected form (see Inferences).

**Relaxation 2: past main verb + present subjunctive [ACCEPTED-VAR in context; COLLOQ/REG when the event is already over]**
- Even the RAE *Esbozo* (§3.19.7) admits alternation by context and gives *Mandaron que estudie, que estudiara o estudiase* (RAE 1973, 519). — [Bröer 2024, quoting RAE 1973](https://dialnet.unirioja.es/descarga/articulo/9881110.pdf)
- Partial loss of consecutio temporum in the subjunctive "es un fenómeno común en diferentes partes de Hispanoamérica": Sessarego (2008) Peru and Bolivia; Gutiérrez (2008) Chile; Arrizabalaga Lizárraga (2009) Peru; Crespo del Río (2018) Peru. Rojo (1976) found past + present subjunctive common in parts of Peninsular Spanish too; Kempas (2008) says it is in decline but not unknown in Spain. — [Bröer 2024](https://dialnet.unirioja.es/descarga/articulo/9881110.pdf)
- The NGLE Manual (RAE/ASALE 2010, p. 457) describes differences between Río de la Plata and Andean Spanish in this respect (cited, not quoted, by Bröer). — [Bröer 2024](https://dialnet.unirioja.es/descarga/articulo/9881110.pdf)
- **Mexico:** Crespo del Río (2018) also found the phenomenon "aunque en menor medida, entre los hablantes del castellano en México" (Mexico City). — [Bröer 2024](https://dialnet.unirioja.es/descarga/articulo/9881110.pdf)
- In Argentina (Jujuy) the present subjunctive after a past verb reached 63.0% vs 29.9% imperfect subjunctive; over 50% in both regions studied; young and rural speakers use it even for completed past actions (*A los argentinos les encantó que ganemos el mundial*). The author claims a present subjunctive "con valor de anterioridad" not recorded in the NGLE. — [Bröer 2024](https://dialnet.unirioja.es/descarga/articulo/9881110.pdf)
- **Colombia, prescriptive stance:** A column in *Ámbito Jurídico* (Colombian legal publication) criticises a trend "que viene del Cono Sur" toward *pidió que se anule* and states the correct form is *pidió que se anulara*. — [Ámbito Jurídico, "Consecutio temporum"](https://www.ambitojuridico.com/noticias/etcetera/educacion-y-cultura/consecutio-temporum)
- Learner sources give *Quería que vengas* as "non-standard", correct *Quería que vinieras*. — [Elon.io](https://elon.io/grammar/spanish-spain/verbs/subjunctive/other/sequence-of-tenses)
- A WordReference thread on *me pidió que pongamos/pusiéramos* exists (forum, not authoritative; content not fetched). — [WordReference](https://forum.wordreference.com/threads/verbo-en-pasado-presente-del-subjuntivo-me-pidi%C3%B3-que-pongamos-pusi%C3%A9ramos.2447359/)

**Present perfect main verb [NORM in both forms, regionally distributed]**
- Spain: *Te ha pedido que vengas pronto* is standard (pretérito perfecto = present zone); *Te ha pedido que vinieras* "sounds displaced". Latin America: many varieties treat *he pedido* as past zone, so the imperfect subjunctive is more common. — [Elon.io](https://elon.io/grammar/spanish-spain/verbs/subjunctive/other/sequence-of-tenses)

**Conditional main verb [NORM]**
- Conditional belongs to the past zone: *Me gustaría que vinieras*; *Me gustaría que vienes* is an error. — [Elon.io](https://elon.io/grammar/spanish-spain/verbs/subjunctive/other/sequence-of-tenses)

**Future and imperative main verbs [NORM]**
- Both are present zone → present/perfect subjunctive (*Dile que me llame cuando pueda*). — [Elon.io](https://elon.io/grammar/spanish-spain/verbs/subjunctive/other/sequence-of-tenses)

### Inferences
- Recommended app policy for **generation**: always follow the strict table (past/conditional → imperfect or pluperfect subjunctive). For **Mexico/Colombia** targets, generate *me ha pedido que viniera* sparingly; the preterite *me pidió que viniera* is the natural Latin American choice anyway because the present perfect is used less for recent past there.
- Recommended app policy for **grading**: when the main verb is past and the subordinate event is still in the future relative to now (cue words *mañana*, *la próxima semana*, *el lunes que viene*), accept the present subjunctive (*Me pidió que venga mañana*) as a correct regional/contextual variant, with a note that the imperfect is the textbook form. When the subordinate event is clearly finished (*Me molestó que llegues tarde ayer*), mark the present subjunctive as non-standard.
- After a present main verb and a past subordinate event, accept both perfect and imperfect subjunctive (*Me alegro de que hayas venido / vinieras ayer*). For Mexico and Colombia, the imperfect with a past time adverb is natural. This is inferred from the preterite/perfect distribution described above, not from a Mexico/Colombia-specific source.

### Gaps
- Exact NGLE §24.7-24.9 wording on the relaxations could not be retrieved (rae.es returned 403 Forbidden).
- No quantitative Colombia study of past + present subjunctive was found. Koenig's Colombian subjunctive study is cited in the literature but was not retrieved.

---

## 2. Imperfect subjunctive -ra vs -se

### Takeaway
In ordinary subjunctive use -ra and -se are interchangeable [NORM]. In Latin America, including Mexico and Colombia, -ra is much more frequent and -se sounds formal or literary. Only -ra can (a) be used as a pluperfect/preterite indicative in journalistic or literary style, which is archaic and criticised (*el libro que escribiera en 1990*), and (b) replace the conditional in courtesy/modal verbs (*quisiera, debiera, pudiera*, *hubiera = habría*).

### Cited Findings
- Origin: -ra comes from the Latin pluperfect indicative (AMAVERAM > *amara*); -se comes from the Latin pluperfect subjunctive (AMAVISSEM). — [search-result summary of a Revista de Filología Española article](https://xn--revistadefilologiaespaola-uoc.revistas.csic.es/index.php/rfe/article/download/864/1271/1262)
- In current Spanish -ra mainly has the value of past subjunctive, like -se, but old pluperfect-indicative values survive in expressions like *Reseñaron el libro que publicara en 1980*. — [Rojo, "El libro que publicase", USC](https://gramatica.usc.es/~grojo/Publicaciones/El_libro_que_publicase.pdf) (from search snippet; title shows the -se substitution in this context is itself a topic of study)
- Gómez Torrego (*Manual de español correcto*) recommends avoiding, as pedantic and archaic, -ra used as preterite or pluperfect indicative: *Como indicara el testigo...* → *Como había indicado el testigo...* — [Trome, citing Gómez Torrego](https://trome.com/familia/evitemos-el-lenguaje-arcaico-y-pedante-imp-noticia/)
- The RAE (Libro de estilo, via search snippet) says -ra and -se are usually interchangeable in European Spanish. — [RAE Libro de estilo, tiempos verbales](https://www.rae.es/libro-estilo-lengua-espa%C3%B1ola/tiempos-verbales) (403 on fetch; snippet only)
- -se has lost ground to -ra in American Spanish since the colonial period (historical study of Mexican documents 1700-1833); -se forms are relatively less frequent in Spanish-American data; one Ecuadorian corpus gives -se a relative frequency of 8.9%. — search-result summaries of [Semas UAQ](https://semas.uaq.mx/index.php/ojs/article/download/173/356/1282) and [Redalyc](https://www.redalyc.org/journal/921/92153510007/92153510007.pdf) (summaries; exact articles not opened, attribution of each claim to each URL not fully verified)

### Inferences
- App generation for Mexico/Colombia: default to -ra (*viniera, hubiera*). Always accept -se in grading for subjunctive slots.
- Do not accept -se where -ra replaces the conditional or an indicative: *Quisiera un café* (courtesy) ≠ ?*Quisiese un café*; *el libro que escribiera en 1990* (literary pluperfect) is a -ra-only use. The courtesy *quisiera/debiera/pudiera* and the *hubiera = habría* rule come from standard grammar but were not verified against a primary source this session (see Gaps).

### Gaps
- No current percentage of -ra vs -se for Mexico or Colombia was found. PRESEEA or CORPES would be the place to check.
- DPD wording on -ra replacing the conditional (*quisiera, debiera, pudiera*) not retrieved (403).

---

## 3. Perfect and pluperfect subjunctive; hubiera vs habría

### Takeaway
*haya + participle* expresses a prior event relative to a present/future main clause, or an event completed before a future point (*Cuando hayas terminado, llámame*). *hubiera/hubiese + participle* expresses a prior event relative to a past main clause, and is the protasis of past counterfactuals. In the result clause, *habría* and *hubiera* alternate [NORM], but only *hubiera/hubiese* is possible after emotion/factive triggers, and *habría* is not possible in the *si* clause.

### Cited Findings
- Perfect subjunctive after present triggers for prior events: *Me alegro mucho de que hayas venido*; *Es una pena que no hayan podido venir*. Pluperfect after past triggers: *Me sorprendió que no me hubieras avisado antes*; error *Dudaba que ha estudiado* → *Dudaba que hubiera estudiado*. — [Elon.io](https://elon.io/grammar/spanish-spain/verbs/subjunctive/other/sequence-of-tenses)
- The compound conditional (*habría cantado*) alternates with the pluperfect subjunctive (*hubiera/hubiese cantado*) in most contexts: *Yo lo habría / hubiera / hubiese hecho de otro modo*. The alternation fails after emotive factive verbs: *Lamentó que a su jefe no le hubiera (hubiese) gustado*, not *...no le habría gustado*; *Se asombró de que hubiera llegado*, not *...habría llegado*. — [Castellano Actual, Universidad de Piura](https://www.udep.edu.pe/castellanoactual/duda-resuelta-habria-hubiera-hubiese/)
- Textbook pattern for type-3 conditionals: *si* + *hubiera* (condition), *habría* (result). — [Sublearn](https://sublearn.com/learn/es/grammar/es-conditional-sentences-type-3-pluperfect-subjunctive-conditional-perfect-si-hubiera-tenido-habria-comprado) (learner site)
- Reader comments on the Castellano Actual page cite the DPD *si* entry as allowing "si-subjuntivo, subjuntivo" and "si-subjuntivo, condicional" (comments, not editorial). — [Castellano Actual](https://www.udep.edu.pe/castellanoactual/duda-resuelta-habria-hubiera-hubiese/)

### Inferences
- Grading rule: in a past-counterfactual result clause accept *habría*, *hubiera* and *hubiese* (+ participle). Some prescriptive sources dispute *hubiese* in the result clause; accept it, but generate *habría* or *hubiera*. In the *si* clause accept only *hubiera/hubiese*. *Si habría...* is a learner error and also a stigmatised regional feature (see §6).
- In Mexican and Colombian speech, *hubiera* in both clauses (*Si hubiera sabido, hubiera ido*) is very common. This comes from general knowledge and was not verified with a source here.

### Gaps
- No Mexico/Colombia-specific frequency data for *hubiera* vs *habría* in apodosis found.

---

## 4. Future subjunctive (cantare, hubiere cantado)

### Takeaway
The future subjunctive is largely replaced by the present subjunctive [NORM]. It survives as an archaic feature in legal/administrative texts and in fixed formulas and proverbs [ARCHAIC/FORMAL]. An app should recognise it, never require it, and never generate it except inside set phrases.

### Cited Findings
- RAE Glosario: the future subjunctive "ha sido reemplazado en buena medida por el presente de subjuntivo"; it is kept, as an archaising feature, in legal and administrative texts; remnants survive in ritual formulas, proverbs and other fixed expressions (example *sea cual fuere el precio*); most frequent in conditional and concessive clauses (*aunque fuere bienintencionada*). — [RAE Glosario, futuro simple de subjuntivo](https://www.rae.es/gtg/futuro-simple-de-subjuntivo) (search snippet; page 403 on fetch)
- Still has "cierta vitalidad en algunas zonas americanas" and in legal-administrative language; survives in fossilised proverbs. — [Anuario de Estudios Filológicos (Unex)](https://revista-aef.unex.es/index.php/AEF/article/download/2319/2152/7723) (snippet)
- Idioms surviving in speech: *sea lo que fuere*, *venga de donde viniere*, certain proverbs; in writing reserved for solemn documents, often legislative; the Spanish Civil Code (1889) uses it a lot. — [European Commission, puntoycoma 47](https://ec.europa.eu/translation/bulletins/puntoycoma/47/pyc475.htm)
- Typical legal formulas: *el que quisiere*, *quienes fueren culpables*. — search summary of [aufutur.fr](https://aufutur.fr/revisions/futur-simple-futur-anterieur-subjonctif-espagnol-futuro-simple-futuro-perfecto-subjuntivo/) (secondary)

### Inferences
- Treatment: map *fuere → sea*, *hiciere → haga*, *hubiere cantado → haya cantado* when correcting modern text. Include *Adonde fueres, haz lo que vieres*, *sea lo que fuere* and *sea como fuere* as fixed phrases only.

### Gaps
- No source found on future-subjunctive survival specifically in Mexico or Colombia, beyond the general "algunas zonas americanas" claim.

---

## 5. Latin American usage: Mexico and Colombia specifics

### Takeaway
Both countries use *ustedes* only (no *vosotros*) and -ra as the default imperfect subjunctive. Colombia has regional verbal voseo (Antioquia/paisa, Valle del Cauca) with distinct present-subjunctive forms (*que vos tengás/podás*, stress on the last syllable), and Colombian *de pronto* = "maybe". Mood after epistemic adverbs: *a lo mejor* overwhelmingly takes the indicative everywhere; *quizá(s)/tal vez* alternate. Several items asked about (*capaz que*, *ojalá y*, *así* = even if, indicative after emotion verbs in Mexico) could not be confirmed with sources in this session.

### Cited Findings

**a lo mejor / quizá / tal vez**
- DPD: *a lo mejor* (and colloquial *a la mejor*) is almost always built with the indicative, though especially in American Spanish the subjunctive is also possible (it cites a Colombian subjunctive example); *quizá* and *tal vez* normally take the subjunctive but also admit the indicative. — [DPD, "mejor"](https://www.rae.es/dpd/mejor) (search snippet; page 403 on fetch)
- Corpus: *a lo mejor* + indicative 98.3%, subjunctive 1.7%; *quizá(s)* about 55% indicative and 45% subjunctive. — [Philologica Canariensia 2024](https://ojsspdc.ulpgc.es/ojs/index.php/PhilCan/article/download/1706/1783/7953) (search summary)
- Mexico City vernacular: the indicative is treated as innovative with doubt adverbs, but *a lo mejor* and *seguramente* favour the indicative. — [Moreira 2015, UFC](https://repositorio.ufc.br/ri/bitstream/riufc/19137/1/2015_art_jclmoreira.pdf) (search summary)
- *a la mejor* is a recognised colloquial variant (common in Mexico). — [DPD "mejor"](https://www.rae.es/dpd/mejor) (snippet mentions *a la mejor*; the Mexico association is general knowledge)

**de pronto (Colombia)**
- In Colombia (and Venezuela) *de pronto* chiefly means "maybe, perhaps" (synonyms *quizá, tal vez, a lo mejor*), not "suddenly"; *De pronto sí / De pronto no* are natural answers. — [Wiktionary via Kaikki](https://kaikki.org/dictionary/Spanish/meaning/d/de/de%20pronto.html); [Colombian Spanish: A Learner's Dictionary](https://colombianspanish.co/blog/colombian-spanish-learners-dictionary); [Tomisimo forum](https://forums.tomisimo.org/showthread.php?p=15258)

**Voseo in Colombia**
- Verbal voseo regions: the paisa region (Antioquia, Caldas, Risaralda, Quindío), Valle del Cauca (especially Cali), Andean Nariño, western Norte de Santander and others; centre/west Colombia use verbal voseo in present indicative, imperative and subjunctive; the Caribbean coast mostly uses *tuteo*, much of the rest uses *ustedeo*. — [Wikipedia, Voseo](https://es.wikipedia.org/wiki/Voseo)
- Paradigm (most non-Rioplatense voseo dialects): present subjunctive with final stress, *cantés*, *corrás*; outside Río de la Plata forms like *perdás*, *empecés* are normal and not class-marked. In Rioplatense the standard subjunctive equals the *tú* form (*cantes*), and *que vos comás/digás* is lower-register. — [Wikipedia, Voseo](https://es.wikipedia.org/wiki/Voseo)
- Paisa affirmative imperatives: *volá, comé, viví* (vs *vuela, come, vive*); *sos, podés, vení*. — [Weyers, Dialectologia (Medellín voseo)](https://raco.cat/index.php/Dialectologia/article/view/367614)
- Voseo is common in Medellín conversation but not prescribed for writing; it has stayed vital despite the spread of *tuteo*. — [Weyers, Hispanic Studies Review](https://hispanicstudiesreview.cofc.edu/article/32673); [Jang & García Tesoro 2023, Íkala](https://doaj.org/article/d7d12ecde94d4cc7882d2b7e9d6878aa)

**Subjunctive vitality**
- A Puerto Rico study compares its data with corpora from Mexico (Lastra and Martín Butragueño) and Colombia (Koenig) and finds subjunctive reduction is more pronounced in Puerto Rico. — [BAPLE, Academia Puertorriqueña](https://baple.academiapr.org/index.php/baple/article/download/16927/11845/72099) (search summary)
- Increased subjunctive use in *no sé qué* + verb questions is reported mainly in Mexico and, to a lesser degree, Colombia. — search summary (source among the -ra/-se results, exact URL not confirmed)

### Inferences
- Forms for generation: Mexico and Colombia → *ustedes* forms only for 2nd person plural; *tú* forms for the singular by default. For Colombian (Medellín/Cali) flavour, optionally accept voseo subjunctive *que vos tengás / podás / digás* and imperative *tené, vení, decí*. Negative imperatives in voseo areas use the subjunctive (*no digás*, also *no digas*). The paradigm supports this, but the specific paisa negative-imperative form was not confirmed by a source.
- The forms *tengás* and *podás* follow the documented -er pattern (*corrás*) but were not directly attested in a fetched source.
- Grading *de pronto* (Colombia = maybe): treat like *quizá(s)*, accepting both moods. This is inferred from the synonymy; no source on its mood behaviour was found.

### Gaps (not confirmed with sources this session; based on general knowledge, needs verification before use)
- *capaz que* (= maybe, common in Mexico and the Southern Cone): generally takes the indicative or the subjunctive; not sourced.
- *ojalá y* + subjunctive (Mexico): colloquial; *ojalá* + imperfect subjunctive for unlikely present/future wishes (*Ojalá tuviera tiempo*) is standard everywhere; *ojalá* + present for possible ones. Not sourced here.
- *así* + subjunctive = "even if" (*Así me paguen, no voy*) is widespread in Latin America including Mexico and Colombia; not sourced here.
- Indicative after emotion verbs in some Mexican speech (*me alegra que vienes*): not found.
- *no más / nomás* (Mexico) has no direct mood effect; not researched.
- The Instituto Caro y Cuervo and Academia Mexicana de la Lengua articles were not retrieved.

---

## 6. Common learner errors (English speakers) and corrections

### Takeaway
The highest-frequency errors are: indicative after volition/hope triggers; subjunctive after affirmative *creo que*; past-zone mismatches (*quería que vengas*, *me gustaría que vienes*); missing *que* and wrong analysis of the subject change; and treating *aunque* as always subjunctive. Several other classic errors (*si* + present subjunctive, *si* + conditional, *cuando* + future, *para* + infinitive vs *para que*, *como si* + present, *antes de* vs *antes de que*) are standard teaching points. They are listed below as rules but were not sourced in this session.

### Cited Findings
- Overcorrection: *Creo que sea fácil* ✗ → *Creo que es fácil* ✓. — [Gymglish blog](https://blog.gymglish.com/2021/04/20/10-most-common-spanish-grammar-mistakes-english-speakers) (search summary; exact source among results not confirmed); see also [FluentU](https://www.fluentu.com/spanish/blog/common-spanish-mistakes/)
- SLA research identifies missing *que* and incorrect analysis of the subject change as the two most common subjunctive errors among English-speaking learners. — [Verbpal blog](https://verbpal-web.pages.dev/blog/common-subjunctive-mistakes-advanced-learners/) (secondary blog; underlying study not named)
- Treating *aunque* as a one-size-fits-all subjunctive trigger is a common advanced mistake; mood depends on whether the speaker presents the fact as real/known (indicative) or hypothetical/irrelevant (subjunctive). — [Verbpal blog](https://verbpal-web.pages.dev/blog/common-subjunctive-mistakes-advanced-learners/)
- Indicative or imperative in a wish formula: *Que tienes un buen día* ✗ / *Ten un buen día* (curt) → *Que tengas un buen día* ✓. — [Lingoda](https://www.lingoda.com/blog/en/common-mistakes-with-subjuntivo-in-spanish/)
- Tense mismatches (from Elon.io's "common mistakes" list): *Quería que vengas* → *Quería que vinieras*; *Me gustaría que vienes conmigo* → *Me gustaría que vinieras conmigo*; *Dudaba que ha estudiado lo suficiente* → *Dudaba que hubiera estudiado*; *Le dije que viene el lunes* (as a command) → *Le dije que viniera el lunes*. — [Elon.io](https://elon.io/grammar/spanish-spain/verbs/subjunctive/other/sequence-of-tenses)
- Emotion/factive verbs require the subjunctive (and not the conditional): *Lamentó que no le hubiera gustado*, not *...habría gustado*. — [Castellano Actual](https://www.udep.edu.pe/castellanoactual/duda-resuelta-habria-hubiera-hubiese/)
- *a lo mejor* + subjunctive is not a learner error to flag harshly: it is rare (1.7%) but attested in American Spanish. — [DPD "mejor"](https://www.rae.es/dpd/mejor); [Philologica Canariensia](https://ojsspdc.ulpgc.es/ojs/index.php/PhilCan/article/download/1706/1783/7953)

### Inferences: correction rules for the app (standard grammar; items without a citation above need source verification)
| Error | Correction | Rule | Status |
|---|---|---|---|
| *Quiero que vienes* / *Espero que tienes* | *vengas / tengas* | volition/hope + different subject → subjunctive | NORM |
| *Quiero que yo vaya* | *Quiero ir* | same subject → infinitive | NORM |
| *Creo que sea* | *Creo que es* | affirmative belief → indicative; *No creo que sea* → subjunctive | NORM (cited) |
| *Es verdad que sea* | *Es verdad que es* | assertion of truth → indicative; *No es verdad que sea* → subjunctive | NORM |
| *Si tenga tiempo, voy* | *Si tengo tiempo, voy* | *si* never takes present subjunctive (conditional *si*) | NORM |
| *Si tendría dinero, viajaría* | *Si tuviera dinero, viajaría* | no conditional in the *si* clause; *si habría* is also a stigmatised regional feature, still an error for learners | NORM / COLLOQ-REG |
| *Cuando llegarás, llámame* | *Cuando llegues, llámame* | temporal conjunction + future event → present subjunctive | NORM |
| *Cuando llegues ayer...* | *Cuando llegaste ayer...* | past or habitual event → indicative | NORM |
| *Después de que llegara, comimos* | *Después de que llegó, comimos* (normative) | *después de que* + past fact → indicative; the -ra form is very common in journalism and accepted by many, so flag it softly | NORM vs common variant |
| *Antes de que llegó* | *Antes de que llegara/llegue* | *antes de que* always takes the subjunctive | NORM |
| *Antes de que yo salga, desayuno* | *Antes de salir, desayuno* | same subject → *antes de* + infinitive | NORM (preferred) |
| *Para que yo aprenda, estudio* | *Estudio para aprender* | same subject → *para* + infinitive; different subject → *para que* + subjunctive | NORM |
| *Para que vienes* | *para que vengas* | *para que* always takes the subjunctive | NORM |
| *Como si es rico* | *como si fuera rico* | *como si* takes only the imperfect or pluperfect subjunctive | NORM |
| *El hecho de que* + mood | both possible; subjunctive is the more common choice even for facts, indicative when asserting new information | — | NORM (both) |
| *Aunque llueva* vs *aunque llueve* | both correct; indicative = known fact, subjunctive = hypothetical or conceded | — | NORM (cited) |
| *Quizás* + always subjunctive | both moods (cited, DPD and corpus data); *quizá* placed after the verb → indicative (not sourced) | — | NORM |
| *Me alegro que vienes* | *me alegro de que vengas* (*me alegro que* without *de* is widely accepted in Latin America) | emotion → subjunctive | NORM |
| *Ojalá que vienes* | *Ojalá (que) vengas / vinieras* | *ojalá* always takes the subjunctive | NORM |

### Gaps
- The intended Kwiziq, SpanishDict, StudySpanish and Lingolia error lists were not fetched because of the tool-call budget. Rows above without a citation come from standard grammar and should be checked against those sources or the NGLE §25 before release.
- No learner-corpus statistics (for example CAES, Corpus de Aprendices de Español) were retrieved.
