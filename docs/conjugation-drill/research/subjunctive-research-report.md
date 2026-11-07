# Assertion decides mood: a subjunctive audit catalogue

Spanish mood comes down to one test applied over and over. **The indicative asserts the content of the clause. The subjunctive suspends that assertion**: the content is wished, ordered, doubted, denied, evaluated, presupposed, hypothetical, or not yet realized ([Wikipedia (es), Modo subjuntivo](https://es.wikipedia.org/wiki/Modo_subjuntivo); [Kwiziq](https://spanish.kwiziq.com/questions/view/subjuntivo-indicativo)). Almost every rule below is a case of that test, and most of the hard cases are places where both moods are correct and carry different meanings. Examples include *aunque llueve / llueva*, *no dudo que es / sea*, *después de que llegó / llegara*, *quizá viene / venga*, *el hecho de que* plus either mood, and *me pidió que venga / viniera*. For an app, the practical result is that **a lot of rules have to be "generate X, accept X and Y"**, not one right answer. The catalogue below gives, for each trigger, the mood or moods, the conditions, examples, a generate/accept recommendation, and a source-status grade. **The key caveat for the audit: no rule here was checked against the text of the RAE's *Nueva gramática* (NGLE).** rae.es (NGLE, DPD, Glosario) returned HTTP 403 to every automated fetch, and the Centro Virtual Cervantes Plan Curricular was down for maintenance. RAE material therefore appears only through search-engine snippets or through secondary sources that quote it. A large share of the catalogue, especially the adverbial and noun-clause tables, is standard reference-grammar knowledge (NGLE ch. 25, 46, 47; Butt & Benjamin ch. 16, 25). It is high-confidence, but it stays marked for verification until someone checks it against the NGLE. The final section is a prioritized verification queue for that check.

## How to read the catalogue: four grades of evidence

Each row has a **Status** column. The grade describes the best evidence found in this research, not how confident a grammarian would be.

| Grade | Meaning | How to treat it in the app |
|---|---|---|
| **F** | Stated on a page that was actually fetched and read. A URL is given. These include university handouts, teaching sites (ver-taal, Tu Escuela, Kwiziq lessons, Todoele), Wikipedia, and secondary pages that quote the RAE, such as UDEP *Castellano Actual* (NGL básica) and Bröer 2024 (the *Esbozo*). "Fetched" describes access, not authority. | Usable. Still spot-check before quoting it as "RAE". |
| **SN** | Seen only in a search-engine snippet or summary of the page. This includes **every claim read directly from rae.es (DPD, Glosario, NGLE online, Libro de estilo)**, because those pages returned 403. | Probably accurate, but the wording is unverified. Read the full entry before citing the RAE. |
| **L** | Comes from a site the notes flag as learner, tutor, or forum grade (elon.io, SpanishDict, Kwiziq Q&A, Sublearn, Verbpal, Lingoda, WordReference), even if the page was fetched. | Fine for teaching defaults. Not authoritative. |
| **RK** | Reference knowledge. No source was found this session. The NGLE/DPD location to check is named (section numbers are approximate). | Must be verified before it is shipped as an RAE-backed explanation. |

Examples marked *(c)* were constructed by the researchers. They are not quoted from the cited source, even when the rule itself is graded F. Abbreviations: **I** = indicative, **S** = subjunctive, **Inf** = infinitive, **impf S / plpf S** = imperfect or pluperfect subjunctive.

One structural fact runs through the whole catalogue. Wherever Spanish has a clause-introducing preposition or connector (*para, sin, antes de, después de, hasta, a fin de, con tal de, en caso de, a pesar de*), or a verb of volition, it uses the **infinitive when the two subjects are the same** and **que + finite verb when they differ**. A same-subject subjunctive in those slots (*\*Estudio para que (yo) apruebe*) is ungrammatical, not merely odd. The Todoele worksheet confirms this for *hasta* and *después de* ([Todoele, Oraciones temporales](https://www.todoele.net/sites/default/files/2025-05/oraciones_temporales_i_ii.pdf)). Wikipedia confirms it for volition verbs ([Wikipedia (en), Spanish subjunctive](https://en.wikipedia.org/wiki/Spanish_subjunctive)). The NGLE notes are searchable by this map, taken from a snippet of a Universidad de La Laguna article: indicative in noun clauses §§25.3d–i, subjunctive §§25.3k–y, modal alternation §§25.4–25.6, negated *saber* §25.5o. The same snippet reports that the NGLE itself says the line between the moods "is not always precise" ([ULL, Revista de Filología](https://www.ull.es/revistas/index.php/filologia/article/download/7656/5256/), SN).

## Noun clauses split by what the main predicate does to the content

Noun clauses (*sustantivas*) are the core of the system. The main predicate either asserts the complement (I) or acts on it: it wants it, evaluates it, doubts it, or denies it (S). The lists of trigger verbs are long, but each family is internally consistent.

### Volition and influence: subjunctive with a different subject, infinitive with the same one

| Trigger | Mood | Conditions | Examples | Status / source |
|---|---|---|---|---|
| Volition, request, order, advice, permission, prohibition, causation: *querer, desear, preferir, necesitar, pedir, rogar, exigir, mandar, ordenar, aconsejar, recomendar, sugerir, proponer, permitir, prohibir, impedir, evitar, hacer, lograr, conseguir, esperar* (hope), *obligar a, invitar a, ayudar a*, etc. | S | Different subject. The tense follows the sequence rules. | *Quiero que venga a verme mañana*; *La lluvia hizo que los ríos se desbordaran*; *Necesito que te comas eso* | F ([Wikipedia (en)](https://en.wikipedia.org/wiki/Spanish_subjunctive); [Wikipedia (es)](https://es.wikipedia.org/wiki/Modo_subjuntivo)). Full verb list: RK (NGLE §25.3k ff.) |
| Same verbs, same subject | Inf (obligatory) | *\*Quiero que (yo) vaya* is ungrammatical | *Quiero ir*; *Logré terminar* / *Logré que terminaran* (c) | F for the rule ([Wikipedia (en)](https://en.wikipedia.org/wiki/Spanish_subjunctive)); examples RK |
| Object-controlled verbs: *dejar, hacer, mandar, permitir, prohibir, impedir, aconsejar, obligar a, invitar a* | S or Inf | The infinitive is possible when the object pronoun is the lower subject | *Te dejo que me invites / Te dejo invitarme* (F); *Te prohíbo salir = que salgas* (c) | F for the alternation ([Wikipedia (en)](https://en.wikipedia.org/wiki/Spanish_subjunctive)); per-verb list RK (NGLE ch. 26) |
| *hacer, dejar* (causative) | Inf preferred | S mainly with an inanimate or non-pronominal causer, or for emphasis | *Me hizo reír*; *Déjame pensar*; *La lluvia hizo que se cancelara el partido* (c) | RK |
| *pedir, rogar, exigir, sugerir* + infinitive with a different subject | S normal; Inf formal | *Te ruego guardar silencio* is formal style. *Pidió salir* = same subject. | *Te pido que me escuches* (c) | RK |
| *esperar a que* (wait until) | S always | — | *Espera a que llegue tu padre* (c) | RK |
| *convencer de que* = persuade to do | S | Compare *estar convencido de que* + I (certainty) | *Me convenció de que comprara la moto* / *Estoy convencido de que oculta algo* | F ([Tu Escuela de Español](https://www.tuescueladeespanol.es/blogs/verbos-con-distinto-significado-indicativo-y-subjuntivo/)) |

App note: check whether the subjects are the same before generating any *que* + S. Generate the infinitive for object-controlled verbs in casual registers and accept both forms.

### Emotion and evaluation: subjunctive even for known facts

| Trigger | Mood | Conditions | Examples | Status / source |
|---|---|---|---|---|
| Emotion predicates: *gustar, encantar, molestar, preocupar, sorprender, alegrar(se de), lamentar, sentir* (regret), *temer, odiar, agradecer, dar pena / miedo / rabia*, etc. | S | Used even when the content is objectively true. The RAE frames this as the subjunctive marking evaluated, not asserted, content. | *Me alegra que estés aquí*; *Siento que te hayas roto la muñeca*; *Lo que me da miedo es que tenga una pistola* | F ([Wikipedia (es)](https://es.wikipedia.org/wiki/Modo_subjuntivo); [Tu Escuela](https://www.tuescueladeespanol.es/blogs/verbos-con-distinto-significado-indicativo-y-subjuntivo/)). Full trigger list RK |
| Emotion + indicative (*Me alegra que estás aquí*) | I (non-standard) | Survives in some Latin American speech. Not normative. | *Me alegra que estás aquí* | F that it exists ([Wikipedia (en)](https://en.wikipedia.org/wiki/Spanish_subjunctive)); no frequency data for Mexico or Colombia |
| Evaluative impersonals: *es una pena / lástima, es raro, es normal / lógico, es bueno / mejor, es increíble, me parece bien / mal que, qué pena / bien que, lo lógico es que* | S | Evaluation, not assertion | *Es una pena que no hayan podido venir* ([Elon.io](https://elon.io/grammar/spanish-spain/verbs/subjunctive/other/sequence-of-tenses), L); *Me parece bien que vengas* (c) | List RK (NGLE §25.3) |
| *temer(se)* = suspect, "I'm afraid that" (polite) | I | Genuine fear takes S | *Me temo que voy a suspender el examen*; *Temía que no vendríais* vs *Temo que mi mujer deje de quererme* | F ([Wikipedia (en)](https://en.wikipedia.org/wiki/Spanish_subjunctive); [Tu Escuela](https://www.tuescueladeespanol.es/blogs/verbos-con-distinto-significado-indicativo-y-subjuntivo/)) |
| *menos mal que* | I | Fixed evaluative phrase | *Menos mal que llegaste* (c) | RK |
| *lo bueno / malo / peor es que* | I when stating a fact | Compare prescriptive *lo importante es que* + S | *Lo malo es que no tenemos dinero* / *Lo importante es que estés bien* (c) | RK |
| *quejarse de que* (reporting a complaint) | I possible | S is the default | *Se queja de que nadie lo ayuda* (c) | RK |
| *qué bueno que* + I (Mexico, colloquial) | I colloquial | The standard is *qué bueno que hayas venido / vinieras* | *Qué bueno que viniste* (c) | RK, unsourced; the tenses note found no source for Mexican indicative-after-emotion |
| *alegrarse de que* vs *me alegra que* | S | The pronominal verb needs *de*. Dropping it (*me alegro que*) is widespread queísmo, tolerated in speech. | — | RK (DPD "queísmo") |

App note: generate S for every emotion trigger. Accept I only for *temerse* (suspect), *menos mal que*, factual *lo malo es que*, and *sentir* = perceive.

### Doubt and denial: subjunctive; their negation tilts back to the indicative

| Trigger | Mood | Conditions | Examples | Status / source |
|---|---|---|---|---|
| *dudar (de) que, negar que, es dudoso que, es mentira que, no estar seguro de que, descartar que* | S | — | *Dudo que alcancen la victoria*; *Dudo que sea un problema*; *Niego que sea un problema* | SN ([RAE GTG "modo subjuntivo"](https://www.rae.es/gtg/modo-subjuntivo)); F ([ver-taal](https://www.ver-taal.com/gr_subjuntivo_opinion.htm)) |
| *no dudar que, no negar que* | I taught; S also attested | I declares. S avoids full commitment. Grammarians "still differ". Corpus variation in CREA. | *No dudo que es un problema*; *No niego que es un problema*; García Márquez: *no dudo de que fuera belga* | F ([ver-taal](https://www.ver-taal.com/gr_subjuntivo_opinion.htm); [Kwiziq](https://spanish.kwiziq.com/questions/view/subjuntivo-indicativo); [Lu & Pai 2004](https://www.uv.es/ajl/pdf/94.pdf), abstract only) |
| *¿Niegas que…?* | I | Same logic as *¿No crees que…?* | *¿Niegas que Juan dice la verdad?* | F ([ver-taal](https://www.ver-taal.com/gr_subjuntivo_opinion.htm)) |
| *negar que* + I | I possible | When the speaker presupposes the content is true | *Negó que lo había robado* (c) | RK |
| *no cabe duda de que, no hay duda de que, sin duda, es indudable / innegable que* | I always | Fixed certainty | *No cabe duda de que es él* (c) | RK |
| *dudar que* vs *dudar de que* | both correct | — | — | L (forum quoting the RAE, [SpanishDict](https://www.spanishdict.com/answers/200832/no-dudo-de-que)) |

App note: *dudar / negar* → S only. *No dudar / no negar* → generate I, accept both. *No hay duda* → I only.

### Belief, knowledge, perception, communication: affirmed I, negated S, questioned both

| Trigger | Mood | Conditions | Examples | Status / source |
|---|---|---|---|---|
| Affirmed *creer, pensar, opinar, suponer, parecer* (*me parece que*), *saber, recordar, darse cuenta, ver, oír, notar, decir, afirmar, asegurar, contar, explicar, prometer, jurar*, etc. | I | Assertion | *Creo que tiene razón*; *Creo que Juan vendrá* | F ([ver-taal](https://www.ver-taal.com/gr_subjuntivo_opinion.htm)); SN (Bello / NGLE via [RAE GTG](https://www.rae.es/gtg/oración-subordinada-sustantiva)). Full verb list RK |
| Negated *no creer / no pensar / no decir / no parecer que* | S default; I possible | I signals that **the speaker** holds the content true | *No creo que tenga razón*; *Michael no cree que Panamá sea / es un país hispanohablante* | F ([ver-taal](https://www.ver-taal.com/gr_subjuntivo_opinion.htm); [Wikipedia (en)](https://en.wikipedia.org/wiki/Spanish_subjunctive)) |
| Person and tense effect under negation | 1sg present strongly S; other persons and the past allow I more | The speaker can disagree with someone else's non-belief | *Tú no crees que soy capaz, pero lo soy* (c) | RK |
| *No dijo que* | S = he didn't say it; I = it's true, he didn't mention it | — | *No dijo que fuera a venir* / *No dijo que venía* (c) | RK |
| Factive knowledge verbs negated: *no saber, no darse cuenta, no recordar* | I when the content is presupposed true; S possible when not | NGLE §25.5o covers negated *saber* | *No sabía que estabas aquí*; *No sabía que hubiera / había otra salida* (c) | SN (section ref via [ULL](https://www.ull.es/revistas/index.php/filologia/article/download/7656/5256/)); rule RK |
| Negated perception: *no vi que* | I or S | — | *No vi que hubiera / había nadie* (c) | RK |
| Negative question seeking agreement: *¿No crees que…?* | I | The content is presented as evident. Whether S is also possible is debated. | *¿No crees que Juan dice la verdad?*; *¿No crees que ya es tarde?* | F ([ver-taal](https://www.ver-taal.com/gr_subjuntivo_opinion.htm)); SN ([Spanish Unicorn](https://www.spanishunicorn.com/ejercicios-subjuntivo-o-indicativo-opinion/); [CVC forum](https://cvc.cervantes.es/foros/leer_asunto1.asp?vCodigo=42573)) |
| Plain yes/no question: *¿Crees que…?* | I default; S adds doubt | Said to be more frequent with S in Mexico and Central America | *¿Crees que va / vaya a llover?* (c) | RK (regional claim unsourced) |
| Negative imperative: *no creas / no pienses que* | I typical | Excludes the opposite reading. The subordinate verb "admite muy mal el subjuntivo". | *No creas que me gusta*; *No pienses que te voy a esperar* (c) | F ([ver-taal](https://www.ver-taal.com/gr_subjuntivo_opinion.htm)); SN ([WordReference](https://forum.wordreference.com/threads/no-creas-que-indicativo-o-subjuntivo.3406967/)) |
| Hypothetical or hesitant belief | S possible | — | — | F ([Wikipedia (en)](https://en.wikipedia.org/wiki/Spanish_subjunctive)) |
| *parece que* / *no parece que* / *parece mentira que* | I / S / S | — | *Parece que llueve*; *No parece que tengas razón*; *Parece mentira que lo hayas hecho* (c) | RK |

The NGLE's own explanation, from a snippet, is that Spanish thinking verbs admit the indicative because they are very close to verbs of knowledge and so to assertion. Negating them removes the assertion ([RAE GTG](https://www.rae.es/gtg/oración-subordinada-sustantiva), SN).

### Verbs whose meaning changes with the mood

For these verbs the app should identify the meaning first and choose the mood second. The explanation card should name the meaning ("*decir* = order → S"). The RAE glossary's own pair is *Te digo que lo haces bien* (report) vs *Te digo que lo hagas bien* (instruction) ([RAE GTG "modo indicativo"](https://www.rae.es/gtg/modo-indicativo), SN).

| Verb | + I means | + S means | Examples | Status / source |
|---|---|---|---|---|
| *decir* (and *escribir, gritar, telefonear, repetir*) | inform | order / ask | *Me dijo que había hecho los deberes* / *Me dijo que hiciera los deberes* | F ([Tu Escuela](https://www.tuescueladeespanol.es/blogs/verbos-con-distinto-significado-indicativo-y-subjuntivo/)); *escribir* etc. RK |
| *decidir* | reach a conclusion | impose | *He decidido que voy a ir* / *Hemos decidido que vayas en autobús* | F (Tu Escuela) |
| *comprender / entender* | realize | find reasonable | *Comprendí que eran novios* / *Comprendo que rechaces la oferta* | F (Tu Escuela) |
| *pensar* | opinion | plan / decide | *Pienso que trabajas demasiado* / *He pensado que vayas tú* | F (Tu Escuela) |
| *suponer* | assume | entail | *Supongo que pasaré la Navidad…* / *…supondrán que haya despidos* | F (Tu Escuela) |
| *sentir* | perceive | regret | *Siento que hace frío* / *Siento que te hayas roto la muñeca* | F (Tu Escuela) |
| *temer / temerse* | suspect (*temerse*) | fear | see emotion table | F (Tu Escuela) |
| *insistir en* | assert | demand | *Insiste en que es inocente* / *Insiste en que vengamos* (c) | RK |
| *recordar, avisar, advertir* | remind of a fact | warn / tell to | *Te recuerdo que mañana hay examen* / *Recuérdale que compre pan* (c) | RK |
| *acordar, establecer, disponer, determinar* | agreed fact / stated norm | decision / mandate | *La ley establece que los menores no pueden votar* / *…que se pague un impuesto* (c) | RK |
| *esperar* | expect (formal, with future) | hope | *Espero que vendrá* / *Espero que vengas* (c) | RK |
| *parecer, soñar, imaginar* | seem / dream narrative / assume | evaluation / wish / hypothesis | *Soñé que volaba* / *Sueño con que mis hijos sean felices* (c) | SN for the list ([ihdemu](https://ihdemu.com/verbos-doble-significado-espanol/)); examples RK |

### Impersonal expressions: necessity, possibility and value take S; truth takes I until negated

| Trigger | Mood | Conditions | Examples | Status / source |
|---|---|---|---|---|
| Necessity and importance: *es necesario / preciso / importante / conveniente / mejor, hace falta, conviene, más vale, es hora de que, basta (con) que* | S | — | *Es necesario que vengas* (c) | RK (NGLE §25.3) |
| Possibility and probability: *es posible / imposible / probable / difícil que, puede (ser) que* | S | The adverbs *posiblemente / probablemente* are different (both moods) | *Es posible que llueva* (c); *Posiblemente ya lo sabe / lo sepa* | F for the adverb contrast ([Wikipedia (es)](https://es.wikipedia.org/wiki/Modo_subjuntivo)); list RK |
| Truth and evidence: *es cierto / verdad / evidente / obvio / claro / seguro que, está demostrado que, se nota / se ve que* | I | — | *Es verdad que es tarde*; *Está claro que miente* (c) | RK |
| Event presenters: *resulta que, sucede / pasa que, es que* (explanation) | I | — | *Es que no tengo tiempo* (c) | RK |
| Negated truth: *no es cierto / verdad / evidente que* | S (I is rare: the speaker contradicts while presupposing) | — | *No es verdad que lo haya dicho* (c) | RK |
| Questioned truth: *¿Es cierto que…?* | I default; S skeptical | — | — | RK |
| *es mentira que* / *no es mentira que* | S / I | — | — | RK |
| *lo + adjective + es que* | follows the adjective | *lo importante* → S; *lo cierto / lo malo* → I | *Lo cierto es que…* (c) | RK |
| *no basta que* | variation in corpus use | — | — | F (abstract, [Lu & Pai](https://www.uv.es/ajl/pdf/94.pdf)) |

### Presupposed and preposed clauses: *el hecho de que*, initial *que*, *el que*, *lo de que*

No source for this area was found in this research. Every row is RK and should be checked first against NGLE §25.3 and §25.6.

| Trigger | Mood | Conditions | Examples | Status |
|---|---|---|---|---|
| *el hecho de que* | S default; I accepted | I when the fact itself is asserted as new information, especially with *demostrar / probar* | *El hecho de que sea joven no le impide…*; *El hecho de que llegó tarde demuestra que no le importa* (c) | RK |
| *que*-clause preposed as subject | S, regardless of the predicate | The clause is thematic or presupposed. Even assertion predicates allow S: *Que la situación sea / es grave es evidente*. | *Que sea rico no significa nada*; *Que estés aquí me alegra* (c) | RK |
| Same predicate postposed | its normal mood | — | *Es evidente que la situación es grave* (c) | RK |
| *el que* + clause (nominalized) | like *el hecho de que* | — | *El que no hayas venido me molestó* (c) | RK |
| *lo de que* | I usually (reported content); S with an emotion predicate | — | *Lo de que te vas a mudar, ¿es verdad?*; *Me molesta lo de que no nos avisaran* (c) | RK |

The learner-error table in the tenses note also lists *el hecho de que* as "both possible, subjunctive the more common choice even for facts". That is consistent, but it is also unsourced.

### Rejected explanations, indirect questions, and noun and adjective complements

| Trigger | Mood | Conditions | Examples | Status / source |
|---|---|---|---|---|
| *no es que* | S | Introduces an explanation the speaker rejects | *No es que no quiera, es que no puedo* (c) | SN ([Spanish Unicorn](https://www.spanishunicorn.com/ejercicios-subjuntivo-o-indicativo-opinion/)) |
| *es que* | I | Gives an explanation | *Es que estoy cansado* (c) | RK |
| *no porque… sino porque* | S in the denied cause, I in the real one | — | *Lo hago no porque me guste, sino porque es necesario* (c) | RK |
| Indirect questions (*si, qué, dónde, cuándo, quién*) | I; Inf for "what to do" | *si* = "whether" can take the future and conditional | *No dice cuándo va a llegar Mónica*; *No sé si viene*; *No sé qué hacer* | F ([ver-taal](https://www.ver-taal.com/gr_subjuntivo_opinion.htm)) for the I rule; others RK |
| *No sé qué haga* (deliberative S) | S colloquial | Reported mainly in Mexico, less in Colombia. The standard is *No sé qué hacer*. | *No sé qué haga* (c) | RK (the tenses note's search summary had no confirmed URL) |
| Noun/adjective heads of wish, need, possibility, fear, emotion: *la posibilidad / necesidad / esperanza / el miedo / el riesgo / la condición / la orden de que, estar contento / harto / dispuesto a que, tener ganas de que* | S | Mood follows the related verb | *Tengo ganas de que llegue el verano* (c) | RK |
| Heads of information or certainty: *la noticia / el rumor / la prueba / la certeza / la impresión de que, estar seguro / convencido / consciente de que* | I | — | *Estoy convencido de que oculta algo* | F ([Tu Escuela](https://www.tuescueladeespanol.es/blogs/verbos-con-distinto-significado-indicativo-y-subjuntivo/)) for one item; list RK |
| *la idea de que* | I = belief content; S = proposal | — | *la idea de que la Tierra es plana* / *la idea de que vengas tú* (c) | RK |

## Relative clauses hinge on whether the antecedent is known to exist

In restrictive (*especificativa*) relatives, the indicative goes with an antecedent that is specific, known, or presented as existing. The subjunctive goes with one that is "indeterminado, desconocido o inexistente" ([Todoele, relativos](https://www.todoele.net/sites/default/files/2025-05/relativos.pdf)). Non-restrictive (*explicativa*) relatives generally do not take the subjunctive ([USC Verba](https://revistas.usc.gal/index.php/verba/article/view/8511/14101), SN). The NGLE grounds this in nonspecific noun phrases, §15.9–15.10 ([RAE GTG](https://www.rae.es/gtg/sintagma-nominal-inespecífico), SN). Personal *a* is not a reliable cue. *Busco a alguien que hable ruso* takes S even with *a*, so the app should key mood on definiteness and existence, not on *a* (RK).

| Trigger | Mood | Conditions | Examples | Status / source |
|---|---|---|---|---|
| Specific or known antecedent | I | — | *Conozco una chica griega que sabe japonés*; *Busco al hombre que habla japonés* | F ([Todoele](https://www.todoele.net/sites/default/files/2025-05/relativos.pdf)); L ([SpanishDict](https://www.spanishdict.com/guide/subjunctive-in-relative-clauses)) |
| Nonspecific or desired antecedent (*buscar, necesitar, querer* + *un/una*; *me gustaría vivir en una ciudad donde…*) | S | Indefinite article → usually S. Definite → usually I. | *Necesito una secretaria que sepa japonés*; *Busco un hombre que hable japonés* | F ([Todoele](https://www.todoele.net/sites/default/files/2025-05/relativos.pdf); [Princeton Contextos](https://commons.princeton.edu/contextos/?p=3980)); L (SpanishDict) |
| Denied antecedent: *no hay, nadie, nada, ningún*, negated *tener / conocer / existir* | S | The subjunctive comes from denying that the antecedent exists, not from *no* itself | *No hay nadie por aquí que te pueda ayudar*; *No hay nada que odie más que las arañas*; *Nadie que yo conozca tiene una serpiente* | L (SpanishDict); SN ([Units Trieste](https://moodle2.units.it/pluginfile.php/463420/mod_resource/intro/oraciones%20adjetivas.pdf)) |
| Negated main verb, definite antecedent | I | — | *No conozco al chico que vive aquí* (c) | RK (the main-verb vs antecedent distinction is SN, [Masaryk](https://is.muni.cz/el/econ/podzim2018/BPJ_JI3S/Oraciones_de_relativo.pdf?lang=cs)) |
| Question about existence | S (open); I (confirming) | The answer flips the mood: *Sí, hay alguien que tiene…* / *No, no hay nadie que tenga…* | *¿Conoces a alguien que viva en Fiji?* / *…que vive en Fiji?*; *¿Hay alguien que tenga dos hijos?* | L (SpanishDict); F ([LibreTexts Redes 2](https://human.libretexts.org/Bookshelves/Languages/Spanish/Second-year_Spanish_Bookshelf/Redes_2%3A_Curso_de_espanol_intermedio_(Warnock)/04%3A_Modulo_Cuatro._Un_mundo_sin_fronteras./4.02%3A_Leccion_18._El_presente_de_subjuntivo_en_clausulas_relativas_(adjetivales))) |
| Scarce antecedent: *pocos / pocas … que* | S | Classroom material only | *Hay pocas personas que hagan la paella como Rafa* | SN ([Charles Univ.](https://dl1.cuni.cz/mod/resource/view.php?id=575914)) |
| Superlatives, *el único / primero / último que* | I default; S emphatic or hypothetical | *Es el mejor libro que he leído* is "not wrong" | *Es la mejor película que haya visto*; *el único que pueda ayudarnos* (unidentified) (c) | L ([Sublearn](https://sublearn.com/learn/es/grammar/using-subjunctive-with-superlatives)); construction defined in NGLE §45.13 ([RAE GTG](https://www.rae.es/gtg/construcción-superlativa), SN, no mood rule); *el único* RK |
| Free relatives: *lo que, quien, el que, donde, como, cuando, cuanto* | I known / past; S unknown / future | **Not always S.** elon.io says "always subjunctive" and contradicts its own examples. Reject that claim. | *Hice lo que me dijiste* / *Haz lo que quieras*; *Quien llegue primero gana*; *como tú digas* / *como tú dices* | L for the *como* pair ([elon.io](https://elon.io/grammar/spanish-spain/complex/subjunctive-fixed-expressions)); others RK |
| *todo el que / todos los que* | S future or open; I factual | — | *Todo el que quiera venir, que venga* / *Todos los que vinieron ayer se divirtieron* (c) | RK |
| *-quiera* forms: *quienquiera, dondequiera, comoquiera, cuandoquiera, cualquiera que* | que + S | Past frame → impf S. Colloquial *quien / donde sea que*. *Quienquiera* (whoever) ≠ *quien quiera* (whoever wants). | *Quienquiera que sea, no abras*; *Quienquiera que fuera, no quiso identificarse*; *\*dondequiera que vas* → *vayas* | F for the category ([UDEP, citing NGL básica 2010](https://www.udep.edu.pe/castellanoactual/duda-resuelta-relativos-inespecificos/)); L for usage ([elon.io](https://elon.io/grammar/spanish-latin-america/complex/free-relatives)) |
| *comoquiera que* as a causal conjunction (= *dado que*) | I | Formal. Set off by a comma. Not to be confused with the relative *comoquiera*. | *Comoquiera que no llegaba, nos fuimos* (c) | SN ([DPD comoquiera](https://rae.es/dpd/comoquiera); [RAE causales explicativas](https://www.rae.es/gram%C3%A1tica/sintaxis/las-causales-explicativas)) |

## Adverbial clauses: every connector family and its mood

Adverbial mood is the area where the research was thinnest. Primary sources were blocked, so apart from the specific rows marked F or SN, **the adverbial tables are RK built from NGLE ch. 24–25 (temporal), 46 (causal, final, consecutive) and 47 (conditional, concessive)**. The section numbers given are approximate and from memory. These are still the most stable rules in Spanish grammar. The open questions are a few alternations.

### Purpose: always subjunctive, except *de modo que* meaning result

| Connector | Mood | Conditions | Examples | Status |
|---|---|---|---|---|
| *para que, a fin de que, con el fin / objeto / propósito de que* | S always | Same subject → *para / a fin de* + Inf. A passive or impersonal main clause counts as a different subject. | *Te lo explico para que lo entiendas*; *Se modificó la ley a fin de que nadie quedara excluido*; *Estudio para aprobar* | RK (NGLE §46.5–7) |
| *de modo / manera / forma que* = so that (purpose) | S | An intended goal | *Habla alto, de modo que todos te oigan* | RK |
| *de modo / manera / forma que* = so, therefore (result) | I | Often after a comma | *Llovía, de modo que nos quedamos en casa* | RK |
| *no sea que, no vaya a ser que, no fuera a ser que* (lest) | S | *fuera* after a past main clause | *Llévate el paraguas, no sea que llueva* | RK |
| *a que* after motion verbs (*venir, ir, salir*) | S | Same subject → *a* + Inf | *Vengo a que me ayudes*; *Fue a que le cortaran el pelo* | RK |
| Colloquial *que* after an imperative | S | — | *Ven aquí, que te vea* | RK |
| *porque* = purpose | S | Less common | *Hice lo posible porque no se enterara* | RK (NGLE §46) |

### Temporal: indicative for habitual and past, subjunctive for pending; *antes de que* always S

The rule is sourced. Temporal clauses take I for a habitual action in the present or a past action, and S for a future action ([Todoele, Oraciones temporales](https://www.todoele.net/sites/default/files/2025-05/oraciones_temporales_i_ii.pdf), F). For the app, the best algorithm is the **"pending" test**: is the subordinate event still in the future relative to the main-clause reference time? This also covers future-in-the-past (*Dijo que me llamaría cuando llegara*). Temporal *cuando* never takes the future or conditional indicative. Interrogative *¿cuándo vendrás?* is a different word use.

| Connector | Mood | Conditions | Examples | Status / source |
|---|---|---|---|---|
| *cuando* | I habitual / past; S pending | *\*cuando tendré* → *cuando tenga*; *\*cuando tendría* → *cuando tuviera* | *Cuando llego, ceno*; *Cuando llegues, cenaremos*; *Dijo que me llamaría cuando llegara* | F rule ([Todoele](https://www.todoele.net/sites/default/files/2025-05/oraciones_temporales_i_ii.pdf)); examples (c) |
| *en cuanto, tan pronto como, apenas* | same split | *Apenas* is common in Latin America | *Tan pronto como terminaron de cocinar, se pusieron a comer*; *En cuanto le cuentes la verdad…, podrás descansar*; *…en cuanto le cuento algo, se lo dice a su novia* (habitual) | F ([Todoele](https://www.todoele.net/sites/default/files/2025-05/oraciones_temporales_i_ii.pdf)) |
| *hasta que* | same split | Same subject → *hasta* + Inf. Expletive *no* is accepted: *hasta que no nos lo pida* = *hasta que nos lo pida*. | *Espera hasta que llegue*; *No recibiremos a los conferenciantes hasta que no nos lo pida el director* | F ([Todoele](https://www.todoele.net/sites/default/files/2025-05/oraciones_temporales_i_ii.pdf)) |
| *mientras* = while | same split | — | *Mientras yo cocinaba, él leía*; *Mientras estés aquí, no te faltará nada* (c) | F (rule lists *mientras*, Todoele); examples RK |
| *mientras* = as long as | S always | Conditional value | *Mientras hagas lo que te dice tu jefe, no tendrás problema* | F (Todoele item) |
| *después de que / después que* | S if pending. Past: I is normal, **impf S also accepted** | Same subject → *después de* + Inf. The DPD treats *después de que* and *después que* as equally correct. | *Después de que te fuiste, llegó Ana*; *El ministro dimitió después de que la prensa publicara el informe* (c); *María perdonó a su pareja después de hablar con él* | F ([Todoele](https://www.todoele.net/sites/default/files/2025-05/oraciones_temporales_i_ii.pdf)); SN ([DPD después](https://www.rae.es/dpd/después); [FFZG thesis](https://repozitorij.ffzg.unizg.hr/islandora/object/ffzg%3A6380/datastream/PDF/view)) |
| *antes de que* | **S always**, even in the past | The event has not yet happened at the reference point. Same subject → *antes de* + Inf. | *No nos iremos antes de que llegues*; *Antes de que él me lo dijera, yo ya había visto…* | F ([Todoele](https://www.todoele.net/sites/default/files/2025-05/oraciones_temporales_i_ii.pdf)); SN (FFZG thesis) |
| *desde que* (since) | I | S only marginally, for a future starting point (unverified) | *Desde que la conocí, soy feliz* (c) | RK |
| *siempre que / cada vez que* = whenever | same split | *Siempre que* = provided that is conditional and S | *Siempre que viene, trae flores* (c) | RK |
| *una vez que, a medida que, conforme, según* (progressive) | same split | — | *Conforme vayan llegando, siéntenlos* (c) | RK |
| *así que, luego que* (literary "as soon as"); *luego de que* (LatAm) | same split | Ordinary *así que* = "so" + I | *Luego que termine, saldremos* (c) | RK |
| *al* + Inf; *nada más* + Inf (Spain) | Inf | A subject is possible: *al llegar yo* | *Al salir, cerró la puerta* (c) | RK |

On the *después de que* + -ra question, the researchers recall the NGLE explanation as the event being presented as background rather than asserted, plus analogy with *antes de que*. The construction is often described as journalistic and formal in Spain and the Americas. That recollection is RK. App recommendation: **generate I for past *después de que*, accept impf S without penalty.**

### Concessive: fact vs hypothesis vs "granted but irrelevant"

| Connector | Mood | Conditions | Examples | Status / source |
|---|---|---|---|---|
| *aunque* | I / S / impf-plpf S | **I** = a fact the speaker asserts. **Present S** = a hypothesis (even if), or a known fact dismissed as irrelevant (the "polemic" subjunctive). **Impf / plpf S** = unlikely or counterfactual. | *Aunque llueve, salgo*; *Aunque llueva, saldré*; *Aunque sea tu hermano, no tiene derecho*; *Aunque me lo hubieras dicho, no habría ido* (c) | Rule: L ([Verbpal](https://verbpal-web.pages.dev/blog/common-subjunctive-mistakes-advanced-learners/)); detail RK (NGLE §47.12–16, DPD "aunque") |
| *a pesar de que, pese a que* | like *aunque*; I more frequent | Same subject → *a pesar de / pese a* + Inf | *A pesar de que estaba cansado, siguió*; *Pese a tener dinero, vive mal* (c) | RK |
| *aun cuando* | like *aunque*, more often S | — | *Aun cuando lo supiera, no lo diría* (c) | RK |
| *por más / mucho / poco que*; *por (muy) + adj / adv + que*; *por más + noun + que* | S strongly preferred | I possible for an asserted fact, but rare | *Por poco que me paguen, me encanta mi trabajo*; *Por más que insistas, no cambiaré*; *Por difícil que sea, lo haré* (c) | SN ([A por el DELE](https://www.aporeldele.com/en/blog/estructuras-con-subjuntivo-para-la-prueba-oral-del-dele-c1); [Prepara ENEM](https://www.preparaenem.com/amp/espanhol/conjunciones-subordinantes-conjuncoes-subordinadas-em-espanhol.htm)) |
| *si bien* | I always | Formal, factual. Not conditional *si*. | *Si bien es caro, merece la pena* (c) | RK |
| *y eso que* | I always | Follows the main clause. Colloquial. | *Suspendió, y eso que estudió mucho* (c) | RK |
| *mal que* | S | Fixed phrase | *Mal que te pese, tiene razón* (c) | RK |
| *así* = even if | S | Said to be frequent in Latin America (Colombia, Mexico, the Andes) and standard. **Not confirmed.** | *No voy así me paguen*; *Así llueva, salimos* (c) | RK (DPD "así" blocked; two searches found nothing) |
| *ni aunque*; literary *siquiera* | S | — | *Ni aunque me lo pidas de rodillas*; *Dame algo, siquiera sea un vaso de agua* (c) | RK |
| *con lo que* (concessive-exclamative) | I | Colloquial | *Con lo que trabaja, y no le suben el sueldo* (c) | RK |

The polemic subjunctive is the main place where generated content goes wrong. With the same facts, *aunque es tu hermano* and *aunque sea tu hermano* are both correct. They differ in what the speaker intends. **Accept both unless the context forces a hypothesis**, such as an unknown future event.

### Causal: indicative, unless the cause is denied

| Connector | Mood | Conditions | Examples | Status / source |
|---|---|---|---|---|
| *porque, ya que, puesto que, dado que, visto que, debido a que, en vista de que, gracias a que, pues*; colloquial *que* after an imperative | I | The cause is asserted | *No vino porque estaba enfermo*; *Ya que estás aquí, ayúdame*; *Abrígate, que hace frío* (c) | RK (NGLE §46.2–4) |
| *como* (causal) | I | Must precede the main clause | *Como salí del trabajo tarde, no pude ir al cine* | F ([Kwiziq](https://spanish.kwiziq.com/my-languages/spanish/view/7267)) |
| *no porque … sino porque*; *no es porque* | S in the denied cause | — | *No lo dejé porque fuera difícil, sino porque me aburría* (c) | RK |
| *porque* under a negated main verb (scope) | S = "not for that reason" | With I: he didn't do it, and that was the reason | *No se casó con ella porque tuviera dinero* (c) | RK |
| Literary *como* + impf S (cause) | recognize only | Archaic | *Como fuese tarde, se marchó* (c) | RK |

### Consecutive: indicative, unless the result is denied, plus the odd *de ahí que*

| Connector | Mood | Conditions | Examples | Status |
|---|---|---|---|---|
| *así que, de modo que* (result), *conque, luego, por (lo) tanto, por eso* | I | — | *Estaba cansado, así que me fui*; *Pienso, luego existo* (c) | RK (NGLE §45.14, §46.10–12) |
| *tan / tanto … que, tal … que* (affirmative) | I | — | *Comió tanto que se enfermó* (c) | RK |
| Negated or questioned intensive (*no … tan … que*) | S | The result is denied | *No es tan rico que pueda comprarlo todo*; *¿Es tan difícil que no puedas hacerlo?* (c) | RK |
| *de ahí que* | S (normative, dominant) | Counter-intuitive: the result is a known fact. I also occurs, but whether it is accepted is unverified. | *Llovió mucho; de ahí que se suspendiera el partido* (c) | RK. Worth its own card. |

### Manner, place and quantity: the specificity rule again; *sin que* and *como si* are fixed

| Connector | Mood | Conditions | Examples | Status / source |
|---|---|---|---|---|
| *como, según, tal (y) como, conforme* (manner) | I known; S open | — | *Hazlo como te dije* / *Hazlo como quieras*; *Lo dejé tal como lo encontré* (c) | RK (NGLE §22.8–9); *como tú digas / dices* L ([elon.io](https://elon.io/grammar/spanish-spain/complex/subjunctive-fixed-expressions)) |
| *donde, adonde, por donde* | I known place; S any place | — | *Vivo donde trabajas tú* / *Pon la caja donde quieras* (c) | RK |
| *cuanto*, quantity *lo que* | I known; S open | — | *Comió cuanto quiso* / *Come cuanto quieras* (c) | RK |
| *cuanto más … más* | I factual; S future | — | *Cuanto más estudies, más aprenderás* (c) | RK |
| *más / menos … de lo que*, *tanto … como* | I normally | S only for an open quantity (fringe) | *Es más listo de lo que parece* (c) | RK |
| *sin que* | **S always** | Same subject → *sin* + Inf | *Salió sin que nadie lo viera*; *Salió sin hacer ruido* (c) | RK |
| *como si, igual que si, cual si, ni que* (exclamative) | **impf / plpf S only** | Never present S, never I. Impf = simultaneous, plpf = prior. | *Habla como si fuera el jefe*; *Me miró como si me hubiera visto antes*; *¡Ni que fuera millonario!* (c) | RK |

Colloquial and Caribbean Spanish uses an infinitive with an explicit different subject (*antes de yo llegar*, *para yo entender*). It is reported as less common in Mexico and Colombia. *Al* + Inf + subject is standard everywhere (RK; no source found). Do not generate it.

## Conditionals: *si* never takes the present subjunctive; every other condition connector does

The *si* system is the most rule-governed part of Spanish mood. Most of its detail is still RK (NGLE ch. 47, DPD "si"), because the DPD entry was blocked.

| *si* pattern | Protasis (*si* clause) | Apodosis (result) | Examples | Status |
|---|---|---|---|---|
| Real / open, present or future | present I | present, future, imperative, *ir a* | *Si llueve, no salgo / saldré / no salgas* | RK |
| Real, habitual or past | impf / pret / perfect I | I | *Si llovía, nos quedábamos en casa*; *Si has terminado, puedes irte* | RK |
| Potential / unreal present | impf S (-ra or -se) | conditional | *Si tuviera dinero, viajaría*; *Si fuese rico, compraría una casa* | RK |
| Unreal past | plpf S (*hubiera / hubiese*) | cond. perfect **or** *hubiera* + participle | *Si lo hubiera sabido, habría / hubiera venido* | L ([Sublearn](https://sublearn.com/learn/es/grammar/es-conditional-sentences-type-3-pluperfect-subjunctive-conditional-perfect-si-hubiera-tenido-habria-comprado)); alternation F ([UDEP](https://www.udep.edu.pe/castellanoactual/duda-resuelta-habria-hubiera-hubiese/)) |
| Mixed: past condition, present result | plpf S | conditional | *Si hubiera estudiado, ahora tendría trabajo* | RK |
| Mixed: permanent condition, past result | impf S | cond. perfect | *Si fuera más prudente, no habría tenido el accidente* | RK |

**Forbidden after conditional *si*:** the present subjunctive (*\*si tenga*), the future (*\*si tendrá*) and the conditional (*\*si tendría*, *\*si habría sabido*). *Si* + conditional is a stigmatized regional feature, reported for the Basque Country, Navarre, La Rioja, Cantabria, and parts of Argentina and Paraguay. The DPD rejects it (RK). *Si* = "whether" in indirect questions freely takes the future and conditional (*No sé si vendrá*; *Me preguntó si iría*). The app must not parse those as conditionals. In the apodosis, *hubiera* = *habría* is fully standard. *Hubiese* there is less accepted: accept it, don't generate it. In the *si* clause only *hubiera / hubiese* is possible ([UDEP Castellano Actual](https://www.udep.edu.pe/castellanoactual/duda-resuelta-habria-hubiera-hubiese/), F for the alternation; reader comments there cite the DPD as allowing "si-subjuntivo, subjuntivo"). Simple *-ra* for *-ría* with non-modal verbs (*si pudiera, lo hiciera*) is archaic or literary, still heard in some American varieties: don't generate it (RK). Colloquial *si* + impf I for unreal conditions (*Si lo sabía, no venía*; *Yo que tú, me iba*) is spoken-register only (RK).

| Other conditional connector | Mood | Conditions | Examples | Status / source |
|---|---|---|---|---|
| *como* (condition, usually a threat or warning, clause first) | **S only** | *Como* + I = cause. *\*Te vas a arrepentir como no vienes* is wrong. | *Como no apruebes el examen, no te llevo a McDonalds*; *Como llueva ahora, toda la ropa se mojará*; *Me iba a enfadar con ella como se lo dijera a Paco* | F ([Kwiziq](https://spanish.kwiziq.com/my-languages/spanish/view/7267)); SN ([MUNI](https://is.muni.cz/el/econ/podzim2018/BPJ_JI3S/Oraciones_condicionales.pdf)) |
| *por si / por si acaso* (in case) | I (likely) or impf / plpf S (less likely); **never present S** | Past frame: *por si* + impf I or plpf S | *Me voy a llevar el paraguas por si llueve / lloviera*; *Llamé al médico por si la fiebre subía*; ✗ *por si haga frío* | F ([Kwiziq](https://spanish.kwiziq.com/my-languages/Spanish/view/7526)) |
| *en caso de que, en el supuesto de que, suponiendo que* | S (the present S is fine, unlike *si*) | Same subject → *en caso de* + Inf | *En caso de que llueva, se suspende*; *En caso de necesitar ayuda, llame* (c) | RK |
| *a menos que, a no ser que, salvo que, excepto que* (unless) | S | *salvo / excepto que* + I = "except the fact that" | *Iré a menos que llueva*; *Todo bien, salvo que llegó tarde* (c) | RK |
| *con tal (de) que, a condición de que, siempre que / siempre y cuando* (provided) | S | *siempre que* + I = whenever | *Te lo presto con tal de que me lo devuelvas*; *Puedes salir siempre que vuelvas antes de las diez* (c) | RK |
| *mientras* (= as long as) | S | — | *Mientras me paguen, sigo* (c) | F for the value (Todoele) |
| *solo si, salvo si, excepto si, menos si* | like *si* | Never present S | *Iré, salvo si llueve* (c) | RK |
| Implicit conditions: *de* + Inf, gerund, *con* + Inf, imperative + *y*, *yo que tú* | non-finite / conditional | — | *De haberlo sabido, habría venido*; *Estudiando más, aprobarías*; *Insiste y lo conseguirás* (c) | RK |

## Independent subjunctive: *ojalá*, the "maybe" words, *que* + wish, and commands

In main clauses the subjunctive appears without a governing verb. **Ojalá always takes the subjunctive, and its tense signals how likely the wish is.** The "maybe" words, by contrast, split into three groups by how they select mood. Sources disagree on several of them, and those conflicts are shown openly below.

### *Ojalá* and other optatives

| Trigger | Mood | Conditions | Examples | Status / source |
|---|---|---|---|---|
| *ojalá (que)* + present S | S | Possible wish, present or future | *Ojalá que no llueva hoy* | SN ([DPD ojalá](https://www.rae.es/dpd/ojal%C3%A1)); F ([UDEP](https://www.udep.edu.pe/castellanoactual/ojala/); [Milano-Bicocca handout](https://elearning.unimib.it/pluginfile.php/1380444/mod_resource/content/1/USOS%20DEL%20SUBJUNTIVO%20EN%20ORACIONES%20INDEPENDIENTES.pdf)) |
| *ojalá* + perfect S | S | Possible wish about a recent past whose outcome is unknown | *Ojalá haya aprobado* (c) | F (Milano-Bicocca) |
| *ojalá* + impf S | S | Hard-to-fulfil or contrary-to-fact wish, present or future. Also a merely less likely future: *Ojalá ganáramos mañana*. | *Ojalá tuviera más tiempo* (c) | F (Milano-Bicocca) |
| *ojalá* + plpf S | S | Impossible wish about the past | *Ojalá hubiera estudiado* (c) | F (Milano-Bicocca) |
| *que* after *ojalá* | optional | Cultured usage tends to omit it. *Ojalá que* is very common in Latin America and Mexico. | — | L ([SpanishDict forum](https://www.spanishdict.com/answers/290129/ojal-que-vs-ojal-solo); [Kwiziq Q&A](https://spanish.kwiziq.com/questions/view/ojala-que-1)) |
| *ojalá y* | S | "Sobre todo en México, Centroamérica y el área caribeña". In Spain, popular speech only. | *Ojalá y venga* (c) | SN ([DPD ojalá](https://www.rae.es/dpd/ojal%C3%A1)) |
| *ojalá* + infinitive or noun; *ojalá Dios quiera que* | avoid | The RAE Libro de estilo advises against *ojalá* + infinitive or noun. UDEP calls *ojalá Dios quiera* redundant. | *Dios quiera que llegue bien* (c) | SN ([RAE Libro de estilo](https://www.rae.es/libro-estilo-lengua-espa%C3%B1ola/o)); F (UDEP) |
| Bare *que* + present S (wish, third-person or relayed order, echo command) | S | Echo *que* repeats an ignored order | *¡Que tengas un buen día!*; *¡Que aproveche!*; *¡Que pase el siguiente!*; *¡Que te calles!* (c) | F for wishes (Milano-Bicocca); L ([elon.io](https://elon.io/grammar/spanish-spain/complex/subjunctive-fixed-expressions)); orders and echo RK |
| Frozen optatives: *¡Viva(n)…!, así sea, en paz descanse, Dios mediante*; curse or oath *así* + S | S (frozen) | *¡Vivan los novios!* agrees in number. *¡Vaya!* is now an interjection. | *Así me muera*; *¡Así te parta un rayo!* (c) | L (elon.io for *así sea, en paz descanse, Dios mediante, así me muera*); rest RK |

### The "maybe" family: three behaviors, several source conflicts

| Trigger | Mood | Conditions | Examples | Status / source |
|---|---|---|---|---|
| *quizá(s), tal vez, acaso, probablemente, posiblemente* **before the verb** | I or S | S = more doubt. Many contexts show neutralization. A subjunctive verb requires *quizá* before it, with no pause (NGLE via UDEP). | *Quizás sea (es) un poco tarde para actuar*; *Quizás él te haya engañado* / *te engañó* | F ([UDEP Quizás](https://www.udep.edu.pe/castellanoactual/quizas-quizas-quizas/); [Milano-Bicocca](https://elearning.unimib.it/pluginfile.php/1380444/mod_resource/content/1/USOS%20DEL%20SUBJUNTIVO%20EN%20ORACIONES%20INDEPENDIENTES.pdf)); SN ([UDEP tiempo verbal](https://www.udep.edu.pe/castellanoactual/duda-resuelta-quizas-y-el-tiempo-verbal/); [REDELE](https://redined.educacion.gob.es/xmlui/bitstream/handle/11162/72184/00820083000304.pdf?sequence=1)) |
| Same adverbs **after the verb** or parenthetical | I only | — | *Se olvidó, quizás, de la cita* | F ([UDEP](https://www.udep.edu.pe/castellanoactual/quizas-quizas-quizas/)) |
| *quizá* frequency | conflict | The DPD says it "normally" takes S. A corpus found about 55% I and 45% S. | — | SN ([DPD mejor](https://www.rae.es/dpd/mejor); [Philologica Canariensia 2024](https://ojsspdc.ulpgc.es/ojs/index.php/PhilCan/article/download/1706/1783/7953)) |
| *a lo mejor* (colloquial *a la mejor*, common in Mexico); *igual, lo mismo* | I (generate) | **Conflict**: the DPD says S is "also possible, especially in American Spanish" and cites a Colombian example. Łódź says these "cannot select the subjunctive". Corpus: 98.3% I, 1.7% S. **Do not penalize S harshly.** | *A lo mejor llueve*; *Igual no viene*; *Lo mismo se ha perdido* (c) | SN ([DPD mejor](https://www.rae.es/dpd/mejor); [Philologica Canariensia](https://ojsspdc.ulpgc.es/ojs/index.php/PhilCan/article/download/1706/1783/7953)); F ([Łódź](https://press.uni.lodz.pl/index.php/wul/catalog/download/412/1828/862?inline=1); Milano-Bicocca); L ([Kwiziq](https://spanish.kwiziq.com/questions/view/quiza-tal-vez-or-a-lo-mejor)) |
| *seguramente, seguro que, lo más seguro es que* | I default | **Conflict**: Milano-Bicocca lists *seguramente* with I only. Łódź groups it with *probablemente* (S possible). In Mexico City *seguramente* favors I. | *Seguramente está en casa* (c) | F (Milano-Bicocca; Łódź); SN ([Moreira 2015](https://repositorio.ufc.br/ri/bitstream/riufc/19137/1/2015_art_jclmoreira.pdf)) |
| *puede (ser) que, es posible que* | S (not optional) | An impersonal main clause + *que*, not an adverb | *Puede que llueva*; *Puede que ya hayan llegado* (c) | F (Milano-Bicocca) |
| *capaz (que)* (= maybe, colloquial in many American countries) | I generally; S almost always in Chile | **Conflict**: UDEP says impersonal *es capaz que* admits both moods, present tense only (*\*fue capaz que*), with no quantifier (*\*es muy capaz que*). | *Es capaz que consigue boletos*; *Capaz mañana venga a visitarnos mi abuela* | SN ([DPD capaz](https://www.rae.es/dpd/capaz)); F ([UDEP](https://www.udep.edu.pe/castellanoactual/es-capaz-que-en-el-dia-del-padre-ningun-papa-se-queda-en-casa/)) |
| *de pronto* (Colombia, Venezuela = maybe) | treat like *quizá* (both) | The mood behavior is inferred, not sourced | *De pronto llueve / llueva* (c) | F for the meaning ([Kaikki/Wiktionary](https://kaikki.org/dictionary/Spanish/meaning/d/de/de%20pronto.html); [Colombian Spanish dictionary](https://colombianspanish.co/blog/colombian-spanish-learners-dictionary)); mood RK |
| Future or conditional of probability | I | Present or past conjecture | *Estará en casa*; *Serían las tres* (c) | F for the category (Milano-Bicocca) |

### Commands and polite *-ra*

| Form | Mood | Conditions | Examples | Status / source |
|---|---|---|---|---|
| All negative commands; all *usted / ustedes* commands | present S | Clitics follow an affirmative verb and precede a negative one | *Siéntese*; *No se siente*; *no hables / no habléis* (c) | RK (paradigm); negative command in Milano-Bicocca, F |
| *nosotros* "let's" | present S | Final *-s* drops before *nos*: *callémonos, vámonos*. *vayámonos*, not *\*vayámosnos*. Also before *se*: *digámoselo* (RK). Negative: *no nos vayamos*. | *Sentémonos*; *No nos vayamos* | SN (NGLE §42.3m quoted via [123teachme](https://123teachme.com/learn_spanish/imperative_nosotros_commands)); L ([Kwiziq](https://spanish.kwiziq.com/questions/view/vamos-vayamos)) |
| *ir* "let's go" | *vamos* (old subjunctive value) | *vayamos* in this sense is nearly literary | *¡Vamos!*; *Vamos a + Inf* | L (forum quoting the DPD, [SpanishDict](https://www.spanishdict.com/answers/284321/vayamos-vs-vamos)) |
| Voseo negative command | *no hablés* (voseo regions) / *no hables* | Normative in voseo areas is debated; both occur | *no digás / no digas* (c) | RK |
| Polite *quisiera* (≈ *querría*); *debiera, pudiera* | -ra only | Only *querer* is fully general. For *deber / poder*, generate the conditional. *Pudiera* as a polite form is said to be more common in Mexico and Venezuela. **-se is not used here.** | *Quisiera un café, por favor*; *Debieras descansar* (c) | RK (NGLE §24) |
| *Me gustaría / querría / quisiera que* + impf S | impf S | *Me gustaría que vengas* is heard in Latin America but is non-normative | *Me gustaría que vinieras a la inauguración* | L ([Elon.io](https://elon.io/grammar/spanish-spain/verbs/subjunctive/other/sequence-of-tenses)) |

## Fixed and reduplicative formulas are frozen and need no mood choice

Reduplicatives are concessive ("no matter…"). They use the present S in present or future frames and the impf S in past frames, and **both verbs must match in person, number and tense** ([elon.io](https://elon.io/grammar/spanish-spain/complex/subjunctive-fixed-expressions), L). *Que yo sepa*-type hedges are semi-lexicalized segments at the edge of subordination ([Asterisco, Salamanca 2023](https://revistas.usal.es/dos/index.php/asterisco/article/download/29622/29053/115442), SN). *Digamos / que digamos* are idiomatized discourse markers ([Grande Alija 2010, Onomázein](https://www.redalyc.org/pdf/1345/134513546004.pdf), SN).

| Formula | Pattern | Examples | Status |
|---|---|---|---|
| V *lo que* V | *pase lo que pase, diga lo que diga, cueste lo que cueste, venga lo que venga*; past *pasara lo que pasara* | *Pase lo que pase, mañana cojo el tren a Madrid* | L (elon.io) |
| *sea* + wh-word + *sea* | *sea quien / cuando / donde / como / cual sea*; *sean cuales sean*; past *fuera como fuera* | — | L (elon.io) |
| V wh-word V | *venga quien venga, digan lo que digan, vaya donde vaya* | *Venga quien venga, no abriremos* (c) | RK |
| V *o no* (V) | *quieras o no (quieras), te guste o no, llueva o no* | *Quieras o no, vendrás* (c) | L for *quieras o no* (elon.io); rest RK |
| Epistemic hedges | *que yo sepa / recuerde / vea*, *que él sepa*; past *que yo supiera* | *El museo está cerrado los lunes, que yo sepa* | L (elon.io); SN (Asterisco) |
| Negative-emphatic tag | *que digamos* | *No es muy listo, que digamos* (c) | SN (Onomázein) for the marker |
| Discourse markers | *digamos, o sea*; *es decir, como quien dice* (not S triggers) | *Llegaremos, digamos, a las ocho* (c) | L (elon.io for *o sea*); SN (Onomázein) |
| Future-subjunctive fossils | *sea lo que fuere, sea como fuere, venga de donde viniere, adonde fueres haz lo que vieres* | — | SN ([RAE GTG futuro de subjuntivo](https://www.rae.es/gtg/futuro-simple-de-subjuntivo)); F ([puntoycoma 47](https://ec.europa.eu/translation/bulletins/puntoycoma/47/pyc475.htm)) |
| *como tú digas* (whatever you say) | concessive S vs *como tú dices* (as you say) | — | L (elon.io) |

## Sequence of tenses is strict on paper and relaxed in the Americas

The base rule is "present with present, past with past". The RAE *Esbozo* (1973) states that with a past main verb, "el [verbo] subordinado debe ir también en pasado" ([Bröer 2024, *Signo y Seña*](https://dialnet.unirioja.es/descarga/articulo/9881110.pdf), F, quoting the RAE). The present zone covers the present, the Spanish present perfect, the future, the future perfect and the imperative. It takes the present S (simultaneous or later) or the perfect S (prior). The past zone covers the preterite, imperfect, pluperfect, conditional and conditional perfect. It takes the impf S or the plpf S ([Elon.io](https://elon.io/grammar/spanish-spain/verbs/subjunctive/other/sequence-of-tenses), L).

| Main verb | Subordinate (simultaneous / later) | Subordinate (prior) | Examples | Status / source |
|---|---|---|---|---|
| Present / future / imperative | present S | perfect S | *Quiero que vengas mañana*; *Dile que me llame cuando pueda*; *Me alegro mucho de que hayas venido* | L ([Elon.io](https://elon.io/grammar/spanish-spain/verbs/subjunctive/other/sequence-of-tenses)) |
| Preterite / imperfect / pluperfect | impf S | plpf S | *Quería que vinieras a comer*; *Le dije que me llamara cuando pudiera*; *No creía que se hubiera atrevido* | L (Elon.io); F (Bröer) |
| Conditional | impf S | plpf S | *Me gustaría que vinieras*; ✗ *me gustaría que vienes* | L (Elon.io) |
| Present perfect (*me ha pedido*) | Spain: present S. Latin America: often impf S, because the perfect behaves as a past tense there | — | *Te ha pedido que vengas pronto* (Spain) / *…que vinieras* (LatAm) | L (Elon.io) |
| Cascades | each level follows its own governing verb | — | *Quería que le dijeras que viniera*; *Me alegro de que le hayas dicho que viniera* | L (Elon.io) |

The relaxations below are where an app's grader most needs nuance.

**Relaxation 1, normative.** A present main verb takes the impf S for a specific past event, or the perfect S for a past event with present relevance: *No creo que mintiera* / *No creo que haya mentido*. Elon.io calls *Me alegro de que vinieras ayer* "awkward" in Spain. That judgment is Spain-centered. In Latin America, where the preterite is preferred for past events, the impf S with a past time adverb is natural. Accept both ([Elon.io](https://elon.io/grammar/spanish-spain/verbs/subjunctive/other/sequence-of-tenses), L; the Latin American inference is RK).

**Relaxation 2, past main verb + present S.** Even the *Esbozo* admits it by context: *Mandaron que estudie, que estudiara o estudiase* ([Bröer](https://dialnet.unirioja.es/descarga/articulo/9881110.pdf), F). It is documented as common across Spanish America: Peru, Bolivia, Chile, Argentina. In Jujuy the present S reached **63.0% vs 29.9%** impf S after a past verb, even for completed events (*A los argentinos les encantó que ganemos el mundial*). Crespo del Río (2018) found it "en menor medida" in Mexico City ([Bröer 2024](https://dialnet.unirioja.es/descarga/articulo/9881110.pdf), F). In Colombia the prescriptive press pushes back. *Ámbito Jurídico* calls *pidió que se anule* a Southern Cone import and prescribes *pidió que se anulara* ([Ámbito Jurídico](https://www.ambitojuridico.com/noticias/etcetera/educacion-y-cultura/consecutio-temporum), F). App policy: **generate the strict table**. When grading, accept the present S after a past verb when the subordinate event is still in the future relative to now (*Me pidió que venga mañana*), with a note. Mark it non-standard when the event is clearly over (*Me molestó que llegues tarde ayer*).

**Hubiera vs habría.** In past-counterfactual apodoses these alternate, but **after emotive factive verbs only *hubiera / hubiese* works**: *Lamentó que a su jefe no le hubiera gustado*, not *…habría gustado* ([UDEP](https://www.udep.edu.pe/castellanoactual/duda-resuelta-habria-hubiera-hubiese/), F). *Dudaba que ha estudiado* → *hubiera estudiado* ([Elon.io](https://elon.io/grammar/spanish-spain/verbs/subjunctive/other/sequence-of-tenses), L). The perfect S also marks completion before a future point: *Cuando hayas terminado, llámame* (RK). *Hubiera* in both clauses (*Si hubiera sabido, hubiera ido*) is said to be very common in Mexico and Colombia (RK, unsourced).

## *-ra* and *-se* are interchangeable except where *-ra* is not subjunctive at all

In subjunctive slots *-ra* and *-se* are interchangeable. The RAE Libro de estilo says they "usually" are in European Spanish ([RAE Libro de estilo](https://www.rae.es/libro-estilo-lengua-espa%C3%B1ola/tiempos-verbales), SN). The difference is historical: *-ra* descends from the Latin pluperfect *indicative* (AMAVERAM), and *-se* from the pluperfect subjunctive (AMAVISSEM) ([RFE article](https://xn--revistadefilologiaespaola-uoc.revistas.csic.es/index.php/rfe/article/download/864/1271/1262), SN). That is why only *-ra* can (a) work as a literary pluperfect or preterite indicative, as in *el libro que publicara en 1980* ([Rojo, USC](https://gramatica.usc.es/~grojo/Publicaciones/El_libro_que_publicase.pdf), SN), which Gómez Torrego calls pedantic and archaic (*Como indicara el testigo* → *Como había indicado*) ([Trome, citing Gómez Torrego](https://trome.com/familia/evitemos-el-lenguaje-arcaico-y-pedante-imp-noticia/), F). It is also why only *-ra* can (b) replace the conditional: *quisiera, debiera, pudiera*, *hubiera* = *habría* (RK). *-se* has lost ground in the Americas since the colonial period. One Ecuadorian corpus puts it at **8.9%** ([Semas UAQ](https://semas.uaq.mx/index.php/ojs/article/download/173/356/1282); [Redalyc](https://www.redalyc.org/journal/921/92153510007/92153510007.pdf), SN; which claim comes from which URL is not fully verified). No Mexico or Colombia percentage was found. App policy: **generate -ra for Mexico and Colombia, and accept -se in every true subjunctive slot**. Do not accept *-se* in the courtesy or literary-indicative uses.

## The future subjunctive survives only in law and proverbs

The RAE Glosario says the future subjunctive "ha sido reemplazado en buena medida por el presente de subjuntivo". It survives, as an archaism, in legal and administrative texts, and in ritual formulas and proverbs (*sea cual fuere el precio*). It is most frequent in conditional and concessive clauses (*aunque fuere bienintencionada*) ([RAE GTG](https://www.rae.es/gtg/futuro-simple-de-subjuntivo), SN). It keeps "cierta vitalidad en algunas zonas americanas" ([Anuario de Estudios Filológicos](https://revista-aef.unex.es/index.php/AEF/article/download/2319/2152/7723), SN). The 1889 Spanish Civil Code uses it heavily ([puntoycoma 47](https://ec.europa.eu/translation/bulletins/puntoycoma/47/pyc475.htm), F). Typical legal formulas are *el que quisiere* and *quienes fueren culpables* (SN, secondary). Map *fuere → sea*, *hiciere → haga*, *hubiere cantado → haya cantado*. **Recognize it, never require it, and generate it only inside fixed phrases.**

## Mexico and Colombia: same core grammar, different defaults

Neither country uses *vosotros*, so second-person plural is *ustedes* + subjunctive. *-ra* is the default (sourced above). Most Mexico- and Colombia-specific features are either documented by a snippet or still RK.

| Feature | Region | Rule | Status / source |
|---|---|---|---|
| *ojalá y* + S | Mexico, Central America, Caribbean | Colloquial, standard in the region | SN ([DPD](https://www.rae.es/dpd/ojal%C3%A1)) |
| *ojalá que* frequent | Latin America incl. Mexico | — | L (Kwiziq Q&A) |
| *a la mejor* | Mexico (colloquial) | Variant of *a lo mejor*, + I | SN ([DPD mejor](https://www.rae.es/dpd/mejor)) for the variant; the Mexico association is RK |
| *a lo mejor / seguramente* favor I | Mexico City | Indicative with doubt adverbs is treated as innovative there | SN ([Moreira 2015](https://repositorio.ufc.br/ri/bitstream/riufc/19137/1/2015_art_jclmoreira.pdf)) |
| *capaz que* + I | many American countries (Chile: S) | Colloquial. Mark as such. | SN ([DPD capaz](https://www.rae.es/dpd/capaz)); F ([UDEP](https://www.udep.edu.pe/castellanoactual/es-capaz-que-en-el-dia-del-padre-ningun-papa-se-queda-en-casa/)) |
| *de pronto* = maybe | Colombia, Venezuela | Mood: treat like *quizá* (RK) | F ([Kaikki](https://kaikki.org/dictionary/Spanish/meaning/d/de/de%20pronto.html); [colombianspanish.co](https://colombianspanish.co/blog/colombian-spanish-learners-dictionary)) |
| Verbal voseo with stressed present-S forms (*cantés, corrás*; imperatives *volá, comé, viví, vení*) | Colombia: paisa region, Valle del Cauca, Andean Nariño, parts of Norte de Santander. The Caribbean coast uses *tú*. | Outside the Río de la Plata, *perdás / empecés* are normal, not class-marked. Common in conversation but not prescribed for writing. *tengás / podás* follow the pattern but were not directly attested. | F ([Wikipedia Voseo](https://es.wikipedia.org/wiki/Voseo); [Weyers, Dialectologia](https://raco.cat/index.php/Dialectologia/article/view/367614); [Weyers, HSR](https://hispanicstudiesreview.cofc.edu/article/32673)) |
| Past + present S | Mexico City (less than the Andes and Southern Cone) | Accept in grading when the event is still pending | F ([Bröer](https://dialnet.unirioja.es/descarga/articulo/9881110.pdf)) |
| Prescriptive pushback on past + present S | Colombia | *pidió que se anulara* | F ([Ámbito Jurídico](https://www.ambitojuridico.com/noticias/etcetera/educacion-y-cultura/consecutio-temporum)) |
| Subjunctive vitality | Mexico, Colombia vs Puerto Rico | Subjunctive reduction is more pronounced in Puerto Rico than in the Mexican and Colombian corpora | SN ([BAPLE](https://baple.academiapr.org/index.php/baple/article/download/16927/11845/72099)) |
| *no sé qué haga* | Mexico > Colombia | Deliberative S, colloquial | RK (no confirmed URL) |
| *así* + S = even if | Latin America incl. Mexico, Colombia | Standard-sounding | RK |
| *qué bueno que* + I; indicative after emotion | Mexico (colloquial) | Non-normative | RK; F only for the general Latin American claim ([Wikipedia (en)](https://en.wikipedia.org/wiki/Spanish_subjunctive)) |
| *¿Crees que* + S | Mexico, Central America | More frequent than in Spain | RK |
| *pudiera* (polite) | Mexico, Venezuela | More common than in Spain | RK |
| *luego de que* | Latin America | Common for "after" | RK |

## Learner errors cluster in five places

The sourced high-frequency errors are listed here. Overcorrection after affirmative belief: *Creo que sea fácil* → *es* ([Gymglish](https://blog.gymglish.com/2021/04/20/10-most-common-spanish-grammar-mistakes-english-speakers), SN, the exact source was not confirmed). Missing *que* and misreading the subject change are the two most common errors per SLA research cited secondhand by a blog that does not name the study ([Verbpal](https://verbpal-web.pages.dev/blog/common-subjunctive-mistakes-advanced-learners/), L). Treating *aunque* as always subjunctive (Verbpal, L). An indicative in wish formulas: *Que tienes un buen día* → *tengas* ([Lingoda](https://www.lingoda.com/blog/en/common-mistakes-with-subjuntivo-in-spanish/), L). Past-zone mismatches: *Quería que vengas*, *Me gustaría que vienes*, *Dudaba que ha estudiado*, *Le dije que viene* (as a command) ([Elon.io](https://elon.io/grammar/spanish-spain/verbs/subjunctive/other/sequence-of-tenses), L). The rest of the table is standard teaching, graded RK.

| Error | Correction | Rule | Status |
|---|---|---|---|
| *Quiero que vienes* / *Espero que tienes* | *vengas / tengas* | volition + different subject → S | RK |
| *Quiero que yo vaya* | *Quiero ir* | same subject → Inf | F rule ([Wikipedia](https://en.wikipedia.org/wiki/Spanish_subjunctive)) |
| *Creo que sea* | *Creo que es* | affirmed belief → I | SN (Gymglish) |
| *Es verdad que sea* | *es* | truth → I; negated → S | RK |
| *Quería que vengas* / *Me gustaría que vienes* | *vinieras* | past or conditional → impf S | L (Elon.io) |
| *Dudaba que ha estudiado* | *hubiera estudiado* | past doubt → plpf S | L (Elon.io) |
| *Lamentó que no le habría gustado* | *hubiera gustado* | no conditional after factive emotion verbs | F ([UDEP](https://www.udep.edu.pe/castellanoactual/duda-resuelta-habria-hubiera-hubiese/)) |
| *Que tienes un buen día* | *Que tengas…* | optative *que* → S | L (Lingoda) |
| *Si tenga tiempo* / *Si tendría dinero* | *Si tengo* / *Si tuviera* | no present S or conditional after *si* | RK |
| *por si haga frío* | *por si hace / hiciera* | never present S after *por si* | F ([Kwiziq](https://spanish.kwiziq.com/my-languages/Spanish/view/7526)) |
| *Como no vienes, te arrepentirás* (as a threat) | *Como no vengas* | conditional *como* → S | F ([Kwiziq](https://spanish.kwiziq.com/my-languages/spanish/view/7267)) |
| *Cuando llegarás* / *Cuando llegues ayer* | *llegues* / *llegaste* | pending → S; past → I | F rule (Todoele) |
| *Antes de que llegó* | *llegara / llegue* | *antes de que* → S always | F (Todoele) |
| *Antes de que (yo) salga, desayuno*; *Para que (yo) aprenda, estudio* | *Antes de salir*; *Estudio para aprender* | same subject → Inf | RK (Todoele for *hasta*) |
| *para que vienes* | *vengas* | *para que* → S always | RK |
| *como si es rico* | *como si fuera* | *como si* → impf / plpf S only | RK |
| *dondequiera que vas* | *vayas* | *-quiera* + S | L (elon.io) |
| *Ojalá que vienes* | *vengas / vinieras* | *ojalá* → S | SN (DPD) |
| *Me alegro que vienes* | *me alegro de que vengas* | emotion → S; *de* dropping tolerated | RK |
| *Después de que llegara, comimos* | soft flag only | I is the default; -ra is accepted (Todoele) | F |
| *Aunque* always S; *quizá* always S | both moods | see the concessive and "maybe" tables | L / F |
| *a lo mejor* + S | do not penalize harshly | rare (1.7%) but attested in America | SN (DPD; Philologica Canariensia) |

## What to verify against the NGLE before shipping

The rows below carry the most app-facing risk. Either they decide what the app marks wrong, or they rest only on RK or a conflicting snippet. Section numbers are approximate.

| Claim to verify | Where to check | Priority |
|---|---|---|
| *si* never + present S; *si* + conditional as a regional error; *hubiese* in the apodosis; simple *-ra* for *-ría* | DPD "si"; NGLE ch. 47 | High |
| *aunque* I / S semantics, incl. the polemic subjunctive | DPD "aunque"; NGLE §47.12–16 | High |
| The *después de que* + -ra norm | DPD "después"; NGLE §24 / §25.13–14 | High |
| Adverbial connector table (final, causal, consecutive, *de ahí que*, *sin que*, *como si*) | NGLE ch. 46, §22.8–9 | High |
| Impersonal expression lists and their negation | NGLE §25.3 | High |
| *el hecho de que*, preposed *que*-clauses, *lo de que* | NGLE §25.3, §25.6 | High |
| *no dudar / no negar* (frequency of S) | NGLE §25.5 | Medium |
| Person and tense effect under negated *creer*; *¿No crees que* + S | NGLE §25.5 | Medium |
| Negated *saber* and factive verbs | NGLE §25.5o | Medium |
| Superlatives, *el único que*, *pocos que* | NGLE §25 (relatives), §45.13 | Medium |
| *a lo mejor* / *seguramente* / *capaz que* conflicts | DPD "mejor", "capaz"; NGLE §25.5 | Medium |
| Concessive *así* + S standard status and region | DPD "así" | Medium |
| Polite *quisiera / debiera / pudiera*; -se excluded | NGLE §24; DPD | Medium |
| *vamos / vayamos*; *-s* drop before *se*; vosotros *-d* drop; voseo negative command | NGLE §42; DPD "voseo" | Low |
| Mexico / Colombia: *qué bueno que* + I, *no sé qué haga*, *¿Crees que* + S, *hubiera… hubiera* | Academia Mexicana / Caro y Cuervo; PRESEEA / CORPES | Low (regional colour) |

## Conclusion

This audit shows that a Spanish mood engine cannot be a lookup table from trigger to mood. **A large share of the triggers above are bimodal**, and the mood carries meaning: commitment (*no dudo que es / sea*), speaker endorsement (*no cree que es / sea*), hypothesis versus fact (*aunque*), known versus unknown referent (relatives, *como, donde*), or plain register and region (*después de que llegara*, *me pidió que venga*). The app's data model therefore needs three fields per rule, not one: a **generated** mood, a set of **accepted** moods, and the **meaning or condition** that switches between them. The explanation card should name that meaning ("*decir* = order") instead of naming the trigger word. Two cheap algorithmic checks carry much of the load. The **subject-identity check** sends same-subject cases to the infinitive. The **pending-event test** decides temporal clauses, future-in-the-past, and the grading of loosened tense sequence.

The weaker point is authority. The rules most likely to be stated as absolute in the app (*si* + present S forbidden, *antes de que* always S, *como si* only impf / plpf, *sin que* always S) are almost certainly right. In this research, though, they rest on teaching sources or reference knowledge, because the RAE's own text could not be read. The rules where sources openly conflict (*a lo mejor*, *seguramente*, *capaz que*, *quizá* frequency, *no dudar*) are exactly where the app should be most lenient in grading until the NGLE and DPD entries in the verification queue have been read in full. For a Mexico and Colombia audience, the largest practical changes are leniency on tense sequence with pending events, *-ra* as the default, *ojalá (y) que*, and optional voseo forms for Colombian content. None of them changes the core assertion-versus-non-assertion logic.
