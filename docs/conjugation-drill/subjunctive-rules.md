# Subjunctive: when to use it, when not to, and the exceptions

The rules the app follows for the subjunctive, in the drill (sentences, explanations, accepted answers, Mood/Time/Moment readings) and in the
Spanish checker. Section 11 lists where each rule lives in the code.

**Sources.** Every rule here comes from the research in [research/subjunctive-research-report.md](research/subjunctive-research-report.md),
with the researchers' notes in [research/notes/](research/notes/). That report has full tables, links and a verification queue.
One limit applies to all of it: **the RAE's own text (Nueva gramática, Diccionario panhispánico de dudas) could not be read**, because rae.es
blocked every automated fetch. RAE material only came in through search snippets and through pages that quote it.

Each rule carries a grade:

| Grade | Meaning |
|---|---|
| **F** | Read on a page that was fetched: a university handout, a teaching site, Wikipedia, or a page quoting the RAE |
| **SN** | Seen only in a search snippet. This includes every claim taken directly from rae.es. |
| **L** | Learner, tutor or forum site |
| **RK** | Standard reference-grammar knowledge (NGLE ch. 25, 46, 47; Butt & Benjamin). No source was found, so check it against the NGLE before quoting it as the RAE's. |

**The one test behind everything.** Ask whether the speaker puts the clause forward as information, something they claim is so.
Yes → indicative. No → subjunctive. Spanish grammars use this test (the NGLE's *aserción*; in teaching grammars, Ruiz Campillo's
*declarar / no declarar*) (RK). The test is about being **asserted**, not being **true**. A clause misses being asserted in two ways:

1. **Nobody claims it.** It is wished, ordered, doubted, denied, assumed, hypothetical, or still to come: *Quiero que venga. Dudo que venga. Cuando venga…*
2. **It is already given, and the speaker only reacts to it.** It is known or presupposed, and the point of the sentence is the feeling
   or the judgement, not the news: *Me alegra que hayas venido. Es normal que estés cansado. El hecho de que sea joven no importa. Aunque sea tu hermano…*

A truth-based rule ("subjunctive for things that aren't real") breaks on every feeling verb. The assertion test doesn't. Many triggers take
**both** moods, and the mood then changes the meaning. So each rule below says what the app **generates**, what it **accepts**, and what decides between them.

**Why *no creo que* takes the subjunctive: it isn't the *no*.** The easy explanation is "the negative removes the assertion". Taken
literally it is false, as these pairs show:

| Sentence | Mood | What it shows |
|---|---|---|
| *Creo que **no** viene.* / *No creo que **venga**.* | ind / subj | Nearly the same meaning, different mood. So the mood isn't about how negative the content is. |
| *No sabía que estabas aquí. No me di cuenta de que estabas.* | ind | A *no* with no subjunctive. Knowing verbs keep the clause true, so the speaker still vouches for it. |
| *Dudo que venga.* / *No dudo que viene.* | subj / ind | No *no* at all, yet subjunctive; adding *no* brings the **indicative** back. The *no* works in both directions. |
| *Juan no cree que la Tierra **es** redonda.* / *…**sea** redonda.* | ind / subj | Same main clause. The indicative means the speaker vouches for "it's round"; with *sea* the speaker stays neutral (F, Michael/Panamá example in 1.4). |
| *No creas que **es** fácil. ¿No crees que **es** tarde?* | ind | A *no* that tells you something is so, or asks you to agree: the speaker vouches, so the indicative stays. |
| *No creía que **eras** tan simpático.* / *…**fueras**…* | ind / subj | The doubter is the speaker's past self. The indicative means "I doubted it, and I now say it's true". It works for the same reason as the Juan sentence: the person not believing isn't the speaker now. With *yo* in the present the subjunctive is the normal form, because you can't reject and claim the same clause at once. Ruiz Campillo accepts *No pienso que estoy enfermo* only in a marked sense ("it's true, I just don't think about it") (F). |
| *Espero que **no** venga.* / *No espero que **venga**.* | subj / subj | Moving the *no* changes nothing for a wish. *No* only flips verbs about truth: creer (a claim) and dudar (a rejection, "believe not" in one word). A wish never claims the clause, so negating it can't make it a claim. Wanting and feeling verbs stay subjunctive with or without *no*. |
| *No esperaba que **vinieras**.* | subj | True (they came), but it's a reaction (surprise), the second way a clause misses being claimed. Compare *No sabía que **estabas***, which reports the fact. (RK) |

What decides is **who stands behind the clause**. *Creo que X* commits you to X (hedged, but a claim). *No creo que X* asserts
something about your belief. X itself is only brought up to be rejected, so nobody in the sentence claims it, and it takes the subjunctive.
*Creo que no X* commits you to "not X", so it is indicative again. The Learn tab teaches this as the step "Who claims it? Not the word no".

**Where the subjunctive comes from.** Not every verb triggers it. It comes from two places:
- **A trigger**: a word or phrase whose meaning does one of the two things above. These are verbs of influence and feeling, doubt and denial, the
  *es + adjective* phrases of need, value and possibility, and the fixed connectors (*para que, antes de que, sin que…*). The Learn tab's
  **Trigger words** list tags each one (below).
- **The situation, whatever the verb**: a relative clause about something unknown or nonexistent (*busco un piso que tenga…*), and a time
  clause about something still to come (*cuando llegues*). No word triggers these, so they have no tag.

**Trigger word tags** (`Flasher/Data/MoodTriggers.swift`, about 120 entries; shown in search results, on the word page and in Learn → Trigger words):

| Tag | Meaning | Examples |
|---|---|---|
| **+ subjunctive** | always | *querer, pedir, ojalá, para que, antes de que, sin que, es necesario que, puede que, me alegra que, no es que, de ahí que* |
| **subjunctive with no** | plain: indicative; negated: subjunctive | *creer, pensar, parecer, opinar, considerar, suponer, imaginar, estar seguro, es verdad / cierto / obvio / evidente / seguro, está claro* |
| **indicative with no** | plain: subjunctive; negated: indicative (subjunctive still works) | *dudar, negar, es mentira que* |
| **mood changes meaning** | both are right, with different meanings | *decir, sentir, temer, comprender, entender, decidir, insistir, recordar, avisar, escribir* |
| **either mood** | the situation decides | *cuando, hasta que, en cuanto, después de que, mientras, siempre que, aunque, a pesar de que, por más que, si, por si, como, de modo que, lo que, donde, quizás, tal vez, probablemente, el hecho de que* |
| **+ indicative** | traps: they look like they should take it but don't | *a lo mejor, seguramente, menos mal que, no cabe duda de que, porque, ya que, puesto que, así que, si bien, desde que, es que, saber que, darse cuenta de que, ver que* |

No word must be used with *no*. The "with no" tags mark the words whose mood switches when they are negated.

---

## 0. One person or two: infinitive or *que*

Where a trigger asks for the subjunctive and **one person** does both things, Spanish usually uses the **infinitive**. With **two
people** it uses *que* + subjunctive: *Quiero ir* / *Quiero que vayas*; *Estudio para aprobar* / *…para que apruebes* (F). The rule
has limits, in order of how often they matter:

| # | Rule | Examples | Grade |
|---|---|---|---|
| 0.1 | **Wanting, needing, preferring: a must.** One person → infinitive. | *Quiero ir* (not *\*quiero que yo vaya*). *Necesito dormir.* | F |
| 0.2 | **Feelings: the same.** | *Me alegro de estar aquí. Siento llegar tarde. Tengo miedo de perderme.* / *Me alegro de que estés aquí.* | F/RK |
| 0.3 | **Para, sin, antes de, a fin de: the same.** | *Salió sin decir nada* / *sin que nadie lo viera.* *Lávate las manos antes de comer.* | F |
| 0.4 | **Impersonal phrases have no person of their own.** *Es importante / necesario / mejor, hace falta, conviene, más vale*: the infinitive is about people in general (or obvious from context); *que* + subjunctive is about a particular person. **Both are correct**; choose by who you mean. *Que* is fine even about yourself. | *Es importante dormir bien* (anyone) / *Es importante que duermas bien* (you). *Es mejor irme = Es mejor que me vaya.* | RK |
| 0.5 | **"Same person" means who does it, not the grammatical subject.** With *gustar, encantar, importar* the one who feels is *me, te, le*. | *Me gusta bailar* (I dance) / *Me gusta que bailes.* *¿Te importa esperar?* (you wait) / *¿Te importa que espere?* (I wait). | RK |
| 0.6 | **Overlapping people are different subjects.** *Yo* ≠ *nosotros*, and an impersonal subject (*me va bien*) isn't *yo*. | *Quiero que vayamos juntos. Me alegro de que hayamos ganado. Espero que me vaya bien.* | RK |
| 0.7 | **Verbs with an object allow both.** *Dejar, permitir, prohibir, hacer, mandar, impedir, aconsejar*: the object is the one who acts. *Pedir, decir* prefer *que* (*pido venir* = I ask to come myself). | *Te dejo salir = Te dejo que salgas. Te prohíbo salir = …que salgas.* | F |
| 0.8 | **Where the same person with *que* is allowed.** *Esperar* (*espero poder ir* is tidiest; *espero que pueda ir* is very common, above all for what you don't control); **time words** (*trabajé hasta que me cansé, te llamo cuando llegue*; the infinitive versions *hasta cansarme, al llegar* are just as standard); impersonal phrases (0.4). *Para, sin, antes de* still want the infinitive. | *Espero que pueda ir. Trabajé hasta que me cansé (= hasta cansarme). Te llamo cuando llegue (= al llegar).* | RK/L |
| 0.9 | **Believing and saying keep *que* for the same person**: indicative when affirmed, subjunctive when negated or doubted. *Creer* + infinitive exists but is formal. | *Creo que tengo razón. No creo que tenga razón. No digo que lo haga bien. (Creo tener razón.)* | F |
| 0.10 | **Something already done: haber + participle.** | *Me alegro de haber venido. Siento no haber llamado.* | RK |

The checker flags only 0.1 (*quiero / prefiero / necesito / deseo que yo…*). It never flags 0.4, 0.6, 0.8 or a negated belief (*no creo que (yo)…*).

**Stress test (research/notes/Subjunctive rules stress test/same_subject.md).** Key source: Luján (1996), *Obviación y control en los complementos de subjuntivo e infinitivo* (F): same-subject *que* + subjunctive is blocked only after wanting and feeling verbs, not after believing or saying.
- *Quiero que me operen / No quiero que me vean / Espero que me den el trabajo* aren't exceptions: their subject is "they" (F/RK). *\*Quiero que yo sea el primero* stays wrong even for emphasis: *Quiero ser yo el primero, Quiero que sea yo quien lo diga* (RK).
- **"I am part of we" does not make them the same person, and never allows the indicative.** *Quiero que vayamos juntos* is right; *Queremos que vayamos* is wrong (we = we → *queremos ir*). An infinitive works when nothing in it says "we": a team member's *Me alegro de haber ganado* is fine; *Quiero ir juntos, Prefiero hacerlo juntos* are heard but marginal (RK). Spanish does allow a subset subject in some infinitives: *No sabemos si firmar los lingüistas la carta* (Rodrigues 2007, F).
- 0.3 is a preference: same-subject *antes de que, hasta que* are avoided, not ungrammatical; *para que yo pueda* for oneself is non-standard. Caribbean: *para yo poder, antes de yo llegar* (F).
- 0.7: with a reflexive only the infinitive works (*Ana no se permite salir*, *\*…que salga*); *prometer* is controlled by the subject and its *que* form is indicative (*le promete que saldrá*) (F).
- 0.8: *al llegar, hasta cansarme* are standard infinitive versions; *espero que pueda* is accepted mainly with *poder*; *dudo que pueda llegar a tiempo* with one person is accepted (L).
- 0.9: believing and saying take the subjunctive when negated, same subject allowed: *Ana no cree que (ella) venga, No digo que (yo) lo haga bien* (F).

---

## 1. Noun clauses (after *que*)

### 1.1 Wanting, asking, ordering, advising, allowing, causing → subjunctive (F)
*querer, desear, preferir, necesitar, pedir, rogar, exigir, mandar, ordenar, aconsejar, recomendar, sugerir, proponer, permitir, prohibir,
impedir, evitar, hacer, lograr, conseguir, esperar* (hope), *obligar a, invitar a, ayudar a, insistir en* (demand).
- *Quiero que vengas mañana. Necesito que te comas eso. La lluvia hizo que los ríos se desbordaran.*
- Same subject → infinitive: *Quiero ir. Logré terminar.*
- Verbs with an object (*dejar, hacer, mandar, permitir, prohibir, impedir, aconsejar*) take either form: *Te dejo invitarme / que me invites. Te prohíbo salir / que salgas.*
- *Esperar a que* (wait until) → always subjunctive: *Espera a que llegue tu padre* (RK).
- *Convencer de que* = persuade to do → subjunctive, but *estar convencido de que* (be sure) → indicative (F).

### 1.2 Feelings and judgements → subjunctive, even for known facts (F)
*gustar, encantar, molestar, preocupar, sorprender, alegrarse de, lamentar, sentir* (regret), *temer, odiar, agradecer, dar pena / miedo / rabia,
es una pena / lástima, es raro / normal / lógico / bueno / mejor / increíble, me parece bien / mal que, qué pena / bien que.*
- *Me alegra que estés aquí. Siento que te hayas roto la muñeca. Es una pena que no hayan podido venir.*
- **Exceptions that take the indicative:** *temerse que* = suspect (*Me temo que voy a suspender*) (F); *menos mal que* (RK); factual
  *lo malo / lo bueno es que* (*Lo malo es que no tenemos dinero*) (RK); *sentir* = perceive (*Siento que hace frío*) (F).
- **The indicative after a feeling** (*Me alegro de que terminaron ya el trabajo*, *Qué bueno que viniste*) is recorded by the NGLE "en ocasiones…
  más frecuentemente en el español americano", to highlight the information (F, quoted on hispanoteca). Mexico: Lope Blanch (1990), *Me da coraje que lo hizo
  sin permiso*, only for past or present real facts, never the future (F). The app generates the subjunctive and never marks the indicative wrong in the Learn tab.
- **Verbs of complaint and praise** (*quejarse de, reprochar, echar en cara, censurar, presumir de, jactarse de*) change meaning with the mood: the indicative
  reports the fact and judges it; the subjunctive only judges it (NGLE quote, Borrego et al. 1987, F).
- *Me alegro de que* is the full form. *Me alegro que* drops the *de* (queísmo), which is common in speech (RK).

### 1.3 Doubt and denial → subjunctive; negated, it leans back to the indicative
- *dudar (de) que, negar que, es dudoso que, es mentira que, no estar seguro de que, descartar que* → subjunctive: *Dudo que sea un problema* (SN/F).
- *no dudar que, no negar que* → **both moods**. The indicative states it, the subjunctive holds back: *No dudo que es / sea un problema* (F).
  The app generates the indicative and accepts both.
- *no cabe duda de que, no hay duda de que, es indudable / innegable que* → indicative only (RK).
- *¿Niegas que…?* → indicative (F).

### 1.4 Believing, knowing, seeing, saying
| Form | Mood | Example | Grade |
|---|---|---|---|
| Affirmed: *creer, pensar, opinar, suponer, parecer, saber, recordar, darse cuenta, ver, oír, notar, decir, afirmar, asegurar, prometer* | indicative | *Creo que tiene razón* | F |
| Negated: *no creer, no pensar, no parecer* | subjunctive normally; indicative if the speaker holds it true | *No creo que tenga razón*; *Michael no cree que Panamá sea / es…* | F |
| Negative question asking for agreement: *¿No crees que…?* | indicative | *¿No crees que ya es tarde?* | F |
| Plain question: *¿Crees que…?* | indicative normally; subjunctive adds doubt (a Mexico preference is claimed but unverified) | *¿Crees que va / vaya a llover?* | RK |
| Negative command: *no creas / no pienses que* | indicative | *No creas que me gusta* | F |
| Knowing, negated: *no sabía que* | indicative when it is true | *No sabía que estabas aquí* | SN/RK |
| *parece que* / *no parece que* / *parece mentira que* | ind / subj / subj | *Parece que llueve*; *No parece que tengas razón* | RK |

### 1.5 Verbs whose meaning changes with the mood
Work out the meaning first, then the mood. The explanation names the meaning.

| Verb | + indicative | + subjunctive | Example | Grade |
|---|---|---|---|---|
| *decir* (*escribir, gritar, repetir*) | inform | order | *Me dijo que había hecho los deberes* / *que hiciera los deberes* | F |
| *decidir* | conclude | impose | *He decidido que voy* / *Hemos decidido que vayas en autobús* | F |
| *comprender, entender* | realize | find reasonable | *Comprendí que eran novios* / *Comprendo que rechaces la oferta* | F |
| *pensar* | opinion | plan | *Pienso que trabajas demasiado* / *He pensado que vayas tú* | F |
| *suponer* | assume | entail | *Supongo que pasaré la Navidad aquí* / *…supondrá que haya despidos* | F |
| *sentir* | perceive | regret | *Siento que hace frío* / *Siento que te vayas* | F |
| *temer(se)* | suspect | fear | *Me temo que llegaremos tarde* / *Temo que deje de quererme* | F |
| *insistir en* | assert | demand | *Insiste en que es inocente* / *Insiste en que vengamos* | RK |
| *recordar, avisar, advertir* | remind of a fact | tell to | *Te recuerdo que hay examen* / *Recuérdale que compre pan* | RK |
| *acordar, establecer, disponer* | agreed fact | mandate | *La ley establece que los menores no votan* / *…que se pague un impuesto* | RK |
| *esperar* | expect (formal) | hope | *Espero que vendrá* / *Espero que vengas* | RK |
| *soñar, imaginar* | narrative / assume | wish | *Soñé que volaba* / *Sueño con que mis hijos sean felices* | SN/RK |

### 1.6 Impersonal expressions
- **Need, value, possibility → subjunctive:** *es necesario / preciso / importante / conveniente / mejor / posible / imposible / probable / difícil,
  hace falta, conviene, más vale, es hora de que, basta (con) que, puede (ser) que* (RK; F for *puede que*).
- **Truth and evidence → indicative:** *es cierto / verdad / evidente / obvio / claro / seguro, está demostrado, se nota, se ve, resulta que, sucede que, es que* (RK).
- **Negated truth → subjunctive:** *No es verdad que lo haya dicho* (RK). *¿No es verdad que…?* asking for agreement → indicative.
- *es mentira que* → subjunctive, *no es mentira que* → indicative (RK).
- *lo + adjective + es que* follows the adjective: *lo importante es que estés bien* (subj) but *lo cierto / lo malo es que* (ind) (RK).

### 1.7 *El hecho de que*, a *que* clause first, *lo de que* (all RK, check first)
- *el hecho de que* → subjunctive by default, indicative accepted when the fact is new information: *El hecho de que sea joven no le impide…*
- A *que* clause at the start of the sentence → subjunctive, whatever comes after: *Que sea rico no significa nada. Que estés aquí me alegra.*
- *el que* + clause works like *el hecho de que*: *El que no hayas venido me molestó.*
- *lo de que* → either mood: the indicative is the norm for reported or questioned content (*Lo de que te vas, ¿es verdad?*), the subjunctive typical with a reaction (*Me molesta lo de que no nos avisaran*) (L).

### 1.8 Rejected reasons, indirect questions, nouns and adjectives
- *no es que* → subjunctive; *es que* → indicative: *No es que no quiera, es que no puedo* (SN).
- *no porque … sino porque* → subjunctive in the rejected cause (RK).
- Indirect questions (*si, qué, dónde, cuándo*) → indicative, or the infinitive for "what to do": *No sé si viene. No sé qué hacer* (F).
  *No sé qué haga* is colloquial, mainly Mexico (RK).
- Nouns and adjectives of wish, need, fear or possibility → subjunctive: *la posibilidad / necesidad / esperanza / el miedo de que, estar harto / dispuesto a que, tener ganas de que* (RK).
- Nouns and adjectives of information or certainty → indicative: *la noticia / el rumor / la prueba de que, estar seguro / convencido de que* (F for one item, RK for the list).
- *la idea de que* → indicative for a belief, subjunctive for a proposal (RK).

## 2. Relative clauses: is the thing known to exist?
| Case | Mood | Example | Grade |
|---|---|---|---|
| Known, specific | indicative | *Busco al hombre que habla japonés. Conozco una chica que sabe japonés.* | F |
| Wanted, not known (*busco, necesito, quiero* + *un/una*) | subjunctive | *Necesito una secretaria que sepa japonés.* | F |
| Doesn't exist (*no hay, nadie, nada, ningún*) | subjunctive | *No hay nadie que te pueda ayudar. Nadie que yo conozca tiene una serpiente.* | L/SN |
| Asking whether it exists | subjunctive (open) / indicative (confirming) | *¿Conoces a alguien que viva en Fiji?* | L/F |
| Scarce: *pocos … que* | subjunctive when *pocos* = almost none; **either mood** otherwise | *Sé de pocos que hayan venido. Hay pocas personas que hagan / hacen la paella como Rafa. Los pocos invitados que han llegado…* | F (forum quoting Borrego) |
| Superlative, *el único / primero que* | known referent: indicative normally, subjunctive for emphasis; **not yet known: subjunctive required** | *Es la mejor película que he visto / haya visto. El primero que llegue abre.* | L/RK |
| Free relatives (*lo que, quien, donde, como, cuando, cuanto*) | indicative known or past; subjunctive open or future | *Hice lo que me dijiste* / *Haz lo que quieras. Quien llegue primero gana.* | L/RK |
| *todo el que* | subjunctive future, indicative fact | *Todo el que quiera venir, que venga.* | RK |
| *-quiera* words: *quienquiera, dondequiera, comoquiera, cuandoquiera, cualquiera que* | subjunctive | *Quienquiera que sea, no abras.* | F |
| *comoquiera que* = since (formal) | indicative | *Comoquiera que no llegaba, nos fuimos.* | SN |

The personal *a* does **not** show the person is known: *Busco a alguien que hable ruso* still takes the subjunctive (RK).

## 3. Adverbial clauses (mostly RK, see the report's verification queue)

### 3.1 Purpose → subjunctive
*para que, a fin de que, con el fin / objeto de que, no sea que, no vaya a ser que, a que* (after *venir, ir, salir*), colloquial *que* after a command.
- *Te lo explico para que lo entiendas. Llévate el paraguas, no sea que llueva. Vengo a que me ayudes. Ven aquí, que te vea.*
- *de modo / manera / forma que*: **purpose → subjunctive** (*Habla alto, de modo que todos te oigan*), **result → indicative** (*Llovía, de modo que nos quedamos*).

### 3.2 Time: indicative for habits and the past, subjunctive for what is still to come (F)
The test: is the event still pending at the time the main verb is about?
| Connector | Rule | Example |
|---|---|---|
| *cuando, en cuanto, tan pronto como, apenas, hasta que, mientras* (while), *siempre que / cada vez que* (whenever), *una vez que, a medida que, conforme, luego (de) que* | pending → subj; habit or past → ind | *Cuando llegues, cenaremos. Cuando llego, ceno. Dijo que me llamaría cuando llegara.* |
| *antes de que* | **always subjunctive**, past included | *Antes de que él me lo dijera, ya lo sabía.* |
| *después de que* | pending → subj; past → ind, **impf subj also accepted** | *Después de que te fuiste, llegó Ana / …después de que la prensa publicara el informe.* |
| *desde que* | past starting point → indicative; **future starting point → subjunctive** | *Desde que la conocí, soy feliz. Desde que aterrices hasta que llegues al hotel…* (F, learner site) |
| *hasta que no* | same as *hasta que* (the *no* adds nothing) | *No salimos hasta que no nos lo pida.* |
| *¿cuándo…?* (question) | not a time clause; any tense | *¿Cuándo vendrás?* |
Never *cuando* + future or conditional: *\*cuando tendré → cuando tenga*.

### 3.3 Concessive
| Connector | Rule | Example |
|---|---|---|
| *aunque* | fact → ind; hypothesis **or** a known fact waved away → present subj; unlikely or unreal → impf / pluperf subj | *Aunque llueve, salgo. Aunque llueva, saldré. Aunque sea tu hermano, no tiene derecho. Aunque me lo hubieras dicho, no habría ido.* |
| *a pesar de que, pese a que, aun cuando* | like *aunque* | *A pesar de que estaba cansado, siguió.* |
| *por más / mucho / poco que*, *por (muy) + adj + que* | usually subjunctive; **indicative for a real effort**, like *aunque* | *Por más que insistas, no cambiaré. Por difícil que sea, lo haré. Por más que estudia, no aprueba. Por más que lo intenté, no pude.* (SN) |
| *si bien, y eso que, con lo que* | indicative | *Si bien es caro, merece la pena. Suspendió, y eso que estudió.* |
| *mal que, ni aunque, así* (= even if; *así* is everyday speech in Mexico and Colombia) | subjunctive | *Mal que te pese… Ni aunque me lo pidas… Así llueva, salimos.* |
With *aunque* and a known fact both moods are right, so the app accepts both unless the sentence forces a hypothesis.

### 3.4 Cause → indicative, unless the cause is rejected
- *porque, ya que, puesto que, dado que, visto que, debido a que, en vista de que, pues, como* (before the main clause) → indicative: *Como salí tarde, no pude ir* (F).
- *no porque … sino porque*, *no es porque* → subjunctive in the rejected cause: *No lo dejé porque fuera difícil, sino porque me aburría.*

### 3.5 Result → indicative, unless denied
- *así que, de modo que, conque, luego, por (lo) tanto, por eso, tan / tanto … que* → indicative: *Comió tanto que se enfermó.*
- Denied result → subjunctive: *No es tan rico que pueda comprarlo todo.*
- *de ahí que* → subjunctive even though the result is known: *Llovió mucho; de ahí que se suspendiera el partido.*

### 3.6 Manner, place, amount
- *como, según, tal como, donde, cuanto* → indicative if known, subjunctive if open: *Hazlo como te dije / como quieras. Pon la caja donde quieras.*
- *cuanto más … más*: indicative for a fact, subjunctive for the future: *Cuanto más estudies, más aprenderás.*
- *sin que* → always subjunctive: *Salió sin que nadie lo viera.* Same subject → *sin* + infinitive.
- *como si, igual que si, cual si, ni que* → **only the imperfect or pluperfect subjunctive**: *Habla como si fuera el jefe. ¡Ni que fuera millonario!*

## 4. Conditions

### 4.1 *Si*: never the present subjunctive (RK; alternation F)
| Type | *si* clause | Result | Example |
|---|---|---|---|
| Real, now or future | present indicative | present, future, command | *Si llueve, no salgo / no saldré / no salgas.* |
| Real, habit or past | past indicative | indicative | *Si llovía, nos quedábamos en casa.* |
| Unlikely or unreal now | imperfect subjunctive (-ra or -se) | conditional | *Si tuviera dinero, viajaría.* |
| Unreal past | pluperfect subjunctive | perfect conditional **or** *hubiera* + participle | *Si lo hubiera sabido, habría / hubiera venido.* |
| Mixed | pluperf subj / imperf subj | conditional / perfect conditional | *Si hubiera estudiado, ahora tendría trabajo.* |
- **Never after *si*:** present subjunctive (*\*si tenga*), future (*\*si tendrá*), conditional (*\*si tendría*). *Si* + conditional is a regional, stigmatized feature.
- *Si* meaning "whether" is not a condition and takes any tense: *No sé si vendrá. Me preguntó si iría.*
- *si bien* means "although" and takes the indicative.
- Spoken only: *Si lo sabía, no venía* (imperfect indicative for unreal), *Yo que tú, me iba*.

### 4.2 Other condition connectors → subjunctive
| Connector | Note | Example | Grade |
|---|---|---|---|
| *como* + subj (clause first) | a warning; *como* + ind means "because" | *Como no apruebes, no te llevo.* | F |
| *por si / por si acaso* | indicative (likely) or imperf / pluperf subj (less likely); **never present subj** | *Llévate el paraguas por si llueve / lloviera.* | F |
| *en caso de que, en el supuesto de que, suponiendo que* | present subj is fine here, unlike *si* | *En caso de que llueva, se suspende.* | RK |
| *a menos que, a no ser que, salvo que, excepto que* | *salvo / excepto que* + ind = "except that" | *Iré a menos que llueva.* | RK |
| *con tal (de) que, a condición de que, siempre que, siempre y cuando* (provided) | *siempre que* + ind = whenever | *Te lo presto con tal de que me lo devuelvas.* | RK |
| *mientras* (as long as) | subjunctive | *Mientras me paguen, sigo.* | F |
| *de* + infinitive, gerund, *con* + inf, command + *y* | no clause | *De haberlo sabido, habría venido. Insiste y lo conseguirás.* | RK |

## 5. Without a main verb

### 5.1 *Ojalá*: always subjunctive; the tense says how likely (F/SN)
| *ojalá* + | Meaning | Example |
|---|---|---|
| present subj | possible, now or later | *Ojalá que no llueva hoy.* |
| perfect subj | possible, recent past, outcome unknown | *Ojalá haya aprobado.* |
| imperfect subj | unlikely or untrue now / later | *Ojalá tuviera más tiempo.* |
| pluperfect subj | impossible, past | *Ojalá hubiera estudiado.* |
*Ojalá que* is very common in Latin America. *Ojalá y* is mainly Mexico, Central America and the Caribbean (SN). Avoid *ojalá* + infinitive.

### 5.2 "Maybe" words: three behaviours
| Word | Mood | Note | Grade |
|---|---|---|---|
| *quizá(s), tal vez, acaso, probablemente, posiblemente* **before the verb** | both | subjunctive = less sure | F |
| the same **after the verb** or set off by commas | indicative only | *Se olvidó, quizás, de la cita.* | F |
| *a lo mejor* (*a la mejor* in Mexico), *igual, lo mismo* | indicative (98.3%) | the NGLE says the subjunctive is "no excluido, especialmente en América" (*a lo mejor sea…*). The Learn tab accepts it. | F |
| *seguramente, seguro que* | indicative (95%) | *seguramente sea…* makes up about 5% in CORPES and isn't a mere slip (García Pérez 2024). Don't mark it wrong. | F |
| *puede (ser) que, es posible que* | subjunctive, always | *Puede que llueva.* | F |
| *capaz (que)* (Latin America, colloquial) | mostly indicative; almost always subjunctive in Chile | *Es capaz que consigue boletos.* | SN/F |
| *de pronto* = maybe (Colombia, Venezuela) | mostly indicative in examples found (*De pronto nos vemos mañana*) | the subjunctive isn't documented either way; accept it. Closer to *a lo mejor* than to *quizás*. | SN/L |

### 5.3 Wishes and orders with *que*, commands, polite forms
- *que* + subjunctive: *¡Que tengas un buen día! ¡Que aproveche! ¡Que pase el siguiente! ¡Que te calles!* (F for wishes, RK for orders).
- Frozen: *¡Viva(n)…! así sea, en paz descanse, Dios mediante, ¡Así te parta un rayo!* (L/RK).
- Commands: every negative command and every *usted / ustedes* command is the present subjunctive (*No hables. Siéntese. No se siente.*).
  *Nosotros* (let's) drops the *-s* before *nos*: *sentémonos, vámonos*; for "let's go" people mostly say *vamos*, but *vayamos* is normal in set uses and negatives (*vayamos por partes, no vayamos*) (SN/L/RK).
- Colombian voseo (paisa, Valle del Cauca, Nariño): stressed endings, *cantés, corrás, no digás*; commands *volá, comé, viví* (F). The app uses *tú*.
- Polite *-ra*: *Quisiera un café* (≈ *querría*); *debiera, pudiera* (more common in Mexico). Only the *-ra* form is accepted here: the NGLE calls *-se* unacceptable, though it is attested (*¡Qué más quisieses tú!*) (F, quoting NGLE p. 1804). *Quisiera* beats *querría* everywhere, but *podría / debería* are more frequent than *pudiera / debiera*, Mexico included (Vázquez Laslop 2007, F; CEMC 503 *podría* vs 194 *pudiera*).
- *Me gustaría / querría / quisiera que* + **imperfect** subjunctive: *Me gustaría que vinieras.* *Me gustaría que vengas* is heard in Latin America but isn't standard (L).

## 6. Fixed phrases (no choice to make)
- Doubled verbs, "no matter…": *pase lo que pase, diga lo que diga, cueste lo que cueste, sea como sea, sea quien sea, venga quien venga,
  digan lo que digan, quieras o no, te guste o no*. Both verbs match; past: *pasara lo que pasara* (L/RK).
- Hedges: *que yo sepa, que yo recuerde, que yo vea* (past *que yo supiera*) (L/SN). *que digamos* (negative emphasis), *digamos*, *o sea* (SN/L).
- Future-subjunctive fossils: *sea lo que fuere, sea como fuere, venga de donde viniere, adonde fueres haz lo que vieres* (SN/F).
- *como tú digas* (whatever you say) vs *como tú dices* (as you say) (L).

## 7. Tense sequence
| Main verb | Same time or later | Earlier | Example | Grade |
|---|---|---|---|---|
| present, future, command | present subj | perfect subj | *Quiero que vengas. Me alegro de que hayas venido.* | L |
| preterite, imperfect, pluperfect | imperfect subj | pluperfect subj | *Quería que vinieras. No creía que se hubiera atrevido.* | L/F |
| conditional | imperfect subj | pluperfect subj | *Me gustaría que vinieras.* | L |
| present perfect | Spain: present subj; Latin America: often imperfect | | *Te ha pedido que vengas / vinieras.* | L |
Relaxations:
- A present main verb + imperfect subjunctive for a past event is standard: *No creo que mintiera / haya mentido* (L/RK).
- **Past main verb + present subjunctive** for something still to come is common in Latin America (63% in Jujuy, less in Mexico City)
  and even the RAE's *Esbozo* allows *Mandaron que estudie*. In Colombia the style guides still prefer *pidió que se anulara* (F).
  The app generates the strict form and accepts the present when the event is still pending (*Me pidió que venga mañana*).
- *hubiera* = *habría* in the result of an unreal past condition (F). **After a feeling only *hubiera* works:** *Lamentó que no le hubiera gustado*, never *habría* (F).

## 8. Forms
- **-ra and -se** are interchangeable as subjunctives. Mexico and Colombia use *-ra*; *-se* is rare in Latin America (about 9% in one Ecuadorian corpus) (SN/F).
  Only *-ra* also works as a literary past indicative (*el libro que publicara en 1980*, considered pedantic) and in place of the conditional
  (*quisiera, hubiera = habría*). The app generates *-ra* and accepts *-se* in every real subjunctive slot.
- **The future subjunctive** (*hablare, hubiere*) survives only in laws, set phrases and some American regions. Its modern equivalent is the
  **present subjunctive** (*fuere → sea*), and after *si* the **present indicative** (*si fuere necesario → si es necesario*) (SN). The app
  recognizes it and never asks for it.

## 9. Mexico and Colombia
| Feature | Where | App |
|---|---|---|
| *ustedes*, no *vosotros* | both | *vosotros* only when asked |
| *-ra*, not *-se* | both | generate *-ra*, accept *-se* |
| *ojalá que*, *ojalá y* | *ojalá y* mainly Mexico | accept both |
| *a la mejor* + ind | Mexico, colloquial | accept |
| *capaz que* + ind | many Latin American countries | accept |
| *de pronto* = maybe | Colombia | treat like *quizás* |
| voseo: *cantés, no digás* | Antioquia, Valle del Cauca, Nariño | not generated |
| past verb + present subj | less in Mexico City, resisted in Colombian style guides | accept when still pending |
| *qué bueno que* + ind; ind after feelings | several Latin American cities and the River Plate, colloquial (SN) | generate subj |
| *no sé qué haga, no sé si los protejan* | Mexico: the present subjunctive replaces the future after *no sé si / qué / quién* for now or later (never the past), about 1 in 5 cases in 1960s–70s Mexico City speech, educated and popular alike, 0% in Madrid (Nieuwenhuijsen 2001, F); the majority form for *no sé si* in Mexico City (DeMello 1995 via Gerards, F). Same-subject *no sé qué te diga* exists in Spain too. | not flagged |
| *hubiera … hubiera* in both halves | standard everywhere (F) | accepted |

## 10. Common mistakes
| Mistake | Correct | Rule |
|---|---|---|
| *Quiero que vienes. Espero que tienes.* | *vengas, tengas* | wanting + different subject → subj |
| *Quiero que yo vaya.* | *Quiero ir.* | same subject → infinitive |
| *Creo que sea fácil.* | *es* | affirmed belief → ind |
| *Es verdad que sea.* | *es* | truth → ind |
| *Quería que vengas. Me gustaría que vienes.* | *vinieras* | past or conditional → imperf subj |
| *Dudaba que ha estudiado.* | *hubiera estudiado* | past doubt about earlier → pluperf subj |
| *Lamentó que no le habría gustado.* | *hubiera gustado* | no conditional after a feeling |
| *Que tienes un buen día.* | *Que tengas* | wish with *que* → subj |
| *Si tenga tiempo. Si tendría dinero.* | *Si tengo. Si tuviera.* | *si* never present subj or conditional |
| *por si haga frío* | *por si hace / hiciera* | *por si* never present subj |
| *Como no vienes, te arrepentirás* (threat) | *Como no vengas* | condition *como* → subj |
| *Cuando llegarás* | *Cuando llegues* | pending → subj |
| *Antes de que llegó* | *llegara / llegue* | *antes de que* → always subj |
| *Para que (yo) aprenda, estudio.* | *Estudio para aprender.* | same subject → infinitive |
| *como si es rico* | *como si fuera* | *como si* → imperf / pluperf subj |
| *dondequiera que vas* | *vayas* | *-quiera* → subj |
| *Ojalá que vienes* | *vengas / vinieras* | *ojalá* → subj |
| *Aunque* always subjunctive; *quizás* always subjunctive | both moods | see 3.3 and 5.2 |
| *Después de que llegara, comimos* | fine (soft note at most) | past *después de que* accepts -ra |
| *a lo mejor* + subj | rare but attested | don't penalize harshly |

## 11. Where the app uses these rules
| Area | File | What it does |
|---|---|---|
| Learn tab | `Flasher/Data/MoodMapRules.swift`, `MoodMapProgress.swift`, `Flasher/Views/MoodMapView.swift` | The rules of this document as a short course: the big rule, then 14 lessons, each with steps (the rule, "watch out", "fine point"), every caveat opening after the rule it qualifies; 89 steps in all, with about 307 hand-written cards (section 12 lists them by README section). The screen shows one "Up next" step, the lessons with progress dots, and each lesson's steps in order with the rule written out. Each card is a choice between neighbours (minimal pairs, "what does it mean?", "which change flips the mood?"), followed by "why?". A node counts a right answer only when both are right; two open its children, three master it, and mastered nodes come back after 1, 3, 7 and 14 days. Rounds mix a rule with its siblings. Every right answer is run through the Spanish checker in the tests. |
| Trigger words | `Flasher/Data/MoodTriggers.swift`, `Flasher/Views/MoodTriggerViews.swift` | About 120 words and phrases, each tagged with what it does to the mood (the six tags above), with a rule, an example in each mood and the Learn step that teaches it. The tag shows in dictionary search results and on the word page (with the examples), and Learn → Trigger words lists them all with a filter per tag. The tests check that each tagged headword is in the dictionary and that every example passes the Spanish checker. |
| Drill sentences | `Flasher/Data/DrillSentences.swift` (`trigger(past:)`, `reactions`) | Picks a trigger by tense and subject: about 27 present triggers (wishes, doubt, feelings, necessity, *puede que*, *hace falta*, *más vale*, *en caso de que*, *con tal de que*, *a menos que*, *espera a que*, *no es que*, time words), about 18 past ones (*me sorprendió, me molestó, fue una lástima, me gustaría, sería mejor, para que, sin que, antes de que, como si*…). Same subject leaves out triggers that would need an infinitive; *usted / ustedes* leave out tú commands and *te*. Feelings and regrets get a reaction as the second sentence instead of a forward-looking one. *No es que* goes with *no* (*No es que no quiera*). |
| Explanations | `Flasher/Data/DrillExplainer.swift` (`markers`) | Quotes the trigger in the sentence and says why it takes that mood and tense. |
| Accepted answers | `Flasher/Data/DrillAlternates.swift` | *Quizás* cards accept the indicative. *Ojalá* cards accept the other tense (present ↔ imperfect, perfect ↔ pluperfect), with the difference in meaning. *Espero que* + perfect accepts the simple subjunctive when nothing says it is done. |
| Mood / Time / Moment | `Flasher/Data/DrillReadings.swift` | Every use above has a reading, so the filters list the subjunctive tenses that can say it. |
| Checker: mood after a trigger | `Flasher/Data/SpanishRules.swift` (`subjunctiveTriggers`, `indicativeTriggers`) | Flags the indicative after triggers that always take the subjunctive (wishes, feelings, doubt, necessity, *puede que, no es que, en caso de que, a no ser que, no sea que, espera a que*…). Flags the subjunctive after certainty (*creo que, es verdad que, no cabe duda de que, estoy seguro de que, si bien*…) and the present subjunctive after *si / por si*. Flags *quiero que yo…* (use the infinitive). Two-mood triggers stay silent: *no dudo que, no niego que, decir que, me temo que, aunque, cuando, quizás, a lo mejor, no sé si vaya*. |
| Checker: tense match | `Flasher/Data/SubjunctiveRules.swift` | Tense after *que* matching the main verb, *si* + conditional, time words + future, *como si*, unknown things, *aunque*, -se forms, and the future subjunctive (modern equivalent: present subjunctive, or the present after *si*). |

**Not drilled as cards yet** (documented and in the readings): relative clauses (*busco a alguien que…*), *aunque* fact vs hypothesis,
*si*-clauses with the indicative, *por si*, condition *como*, *de modo que*, *de ahí que*, the "no matter" phrases, *que* + wish, commands.
They need sentence frames with their own second clause, which the generator doesn't build yet.

## 12. Where each rule is taught (Learn tab)

The course runs from the most useful rule to the finest point. Each caveat is a child of the rule it qualifies, so it only opens after
that rule (two right answers). `MoodMap.coverage` holds this table, and a test fails if a README section has no step or a step has no section.

**Lesson order and why.** After *Start here* (asserted or not), the course is in four parts, grouped the way the NGLE and Butt & Benjamin
group the subjunctive: by the kind of clause. The big rule runs through every part, and inside a part the most useful lesson comes first.

1. **A verb + *que*: claimed or not.** Wanting and asking (nothing is claimed) → One person or two (infinitive or *que*, needed as soon as
   you want anything) → Believing and knowing (a claim) → Doubt and denial (a claim rejected) → Feelings and judgements (a fact given, and
   reacted to) → Es + adjective (all three cases in one shape). This order builds the big rule in steps: no claim, claim, rejected claim, reaction.
2. **Connectors and relatives.** Time words (*cuando llegues*, the commonest subjunctive in speech) → Purpose → Conditions → Known or unknown
   things → Even though. In each, "not real yet" or "not known" means subjunctive; a fact you state means indicative.
3. **No main verb.** On its own (*ojalá*, maybe, *que* wishes, commands) → Set phrases.
4. **Which subjunctive.** Tense sequence, *haya / hubiera*, the polite *-ra* and the *-ra / -se* forms.

Each lesson's caveats are children of the rule they qualify ("watch out" under a rule, "fine point" under a watch-out), so the lesson page
reads from the rule down and a caveat opens only after its rule.

| README section | Learn steps |
|---|---|
| 0 | One person or two; Same person: infinitive; Feelings: me alegro de estar; Para, sin, antes de + infinitive; Es importante: everyone or someone; Me gusta bailar: who does it; Quiero que vayamos: I and we; Te dejo salir: both forms work; When que is fine with one person; Creo que tengo razón: no infinitive needed; Me alegro de haber venido |
| 1.1 | Wanting and asking; Esperar a que: wait until; Te dejo salir: both forms work; Convencer de que, estar convencido |
| 1.2 | Feelings and judgements; Even when it's true; Me temo que, menos mal que; Lo malo es que, lo importante es que; Mexico and Colombia: what you'll hear |
| 1.3 | Doubt and denial; No dudo que: both work; No cabe duda: certainty; Es mentira que, ¿niegas que…? |
| 1.4 | Believing and knowing; Negated: subjunctive; Who claims it? Not the word no; ¿No crees que…? and no creas que; ¿Crees que venga? A doubtful question; Parece que, parece mentira que |
| 1.5 | Decir: telling or ordering; Verbs that change meaning; Convencer de que, estar convencido; Me temo que, menos mal que |
| 1.6 | Es + adjective + que; Truth: indicative; Puede que vs a lo mejor; ¿No es verdad que…? Asking to agree; Es importante: everyone or someone; Lo malo es que, lo importante es que |
| 1.7 | El hecho de que, que at the start; La noticia de que, la posibilidad de que |
| 1.8 | No es que, no porque: a rejected reason; No sé si…, no sé qué…; La noticia de que, la posibilidad de que |
| 2 | Known or unknown things; Nadie, nada, no hay; The best… that; ¿Conoces a alguien que…? Pocos que; Lo que, donde, como: whatever you like; Quienquiera, cualquiera, todo el que |
| 3.1 | Purpose and other fixed connectors; No sea que, vengo a que; De modo que: purpose or result |
| 3.2 | Time words; Antes de que: always; ¿Cuándo…? is a question; Después de que in the past; Never cuando + future; Mientras, siempre que: two meanings; Desde que; hasta que no |
| 3.3 | Even though, even if; Aunque with a known fact; Por más que, por difícil que; Aunque me lo hubieras dicho; Si bien, y eso que |
| 3.4 | No es que, no porque: a rejected reason; Como + subjunctive = if |
| 3.5 | Tan… que, así que: a result; De ahí que; De modo que: purpose or result |
| 3.6 | Lo que, donde, como: whatever you like; Como si: past subjunctive only; Para, sin, antes de + infinitive |
| 4.1 | Conditions; Si: never the present subjunctive; Si lo hubiera sabido: the unreal past; De haberlo sabido, yo que tú; No sé si…, no sé qué… |
| 4.2 | En caso de que, a menos que, con tal de que; Como + subjunctive = if; Por si: in case; Mientras, siempre que: two meanings; De haberlo sabido, yo que tú |
| 5.1 | Ojalá and its tenses |
| 5.2 | On its own: ojalá, maybe, que…; Quizás: before or after; Puede que vs a lo mejor; Mexico and Colombia: what you'll hear |
| 5.3 | ¡Que…! wishes; No hables: commands; Quisiera un café: polite -ra; Me gustaría que; ¡Viva…!, que en paz descanse |
| 6 | Set phrases: pase lo que pase; Diga lo que diga: no matter what; Que yo sepa, que digamos; Tuviera or tuviese; fuere; Lo que, donde, como: whatever you like |
| 7 | Which subjunctive tense; Past main verb: imperfect subjunctive; Me gustaría que; Haya, hubiera: something earlier; No creo que mintiera; Me pidió que venga (Latin America); Lamentó que no le hubiera gustado |
| 8 | Tuviera or tuviese; fuere; Quisiera un café: polite -ra |
| 9 | Mexico and Colombia: what you'll hear; Me pidió que venga (Latin America); ¿Crees que venga? A doubtful question; No sé si…, no sé qué… |
| 10 | Same person: infinitive; Believing and knowing; Truth: indicative; Past main verb: imperfect subjunctive; Haya, hubiera: something earlier; Lamentó que no le hubiera gustado; ¡Que…! wishes; Si: never the present subjunctive; Por si: in case; Como + subjunctive = if; Never cuando + future |

## 13. Stress test: what the research changed

A second, adversarial research pass (notes in [research/notes/Subjunctive rules stress test/](research/notes/Subjunctive%20rules%20stress%20test/))
tried to disprove every rule above. rae.es still blocked fetching, so NGLE and DPD text came only through pages that quote it. Most rules held.
These were wrong or overstated, and the app (Learn cards, trigger tags) now follows the corrected version:

| Rule as it was | Corrected | Grade |
|---|---|---|
| The big idea: subjunctive when the clause is presupposed | Presupposed **and only reacted to**. Known information alone doesn't bring the subjunctive: *Ya sé que trabajas* (Aletá). Assertion is the NGLE's notion (§25.6); the "reacting" half comes from Bybee & Terrell / Ruiz Campillo, not from the NGLE. | F/SN |
| Feelings + indicative "isn't standard" | Recorded by the NGLE, more in Latin America, to highlight the fact; Mexico: real past or present facts only (Lope Blanch 1990). | F |
| *Lo + adjective + es que* follows the adjective | Evaluative ones (*lo malo, lo raro, lo importante, lo que me preocupa*) take either mood: *Lo raro es que no vi / viera huellas.* | F/SN |
| *Ver que* is always indicative | Negated in the present it takes the subjunctive: *No veo que estés enferma*; past *No veía que estaba enferma* stays indicative (Ruiz Campillo). Tagged "subjunctive with no". | F |
| A *que* clause at the start is always subjunctive | Strongly favours it; *Que la Tierra es redonda lo sabe todo el mundo* is normal. *El hecho de que* is indicative 36% of the time (Nowikow, CORPES XXI). | F/RK |
| *No sabía que estabas* (only the indicative) | *No sabía que estuvieras* is also correct; the speaker doesn't vouch for it. | SN/L |
| *¿Niegas que lo dijiste?* only indicative | The subjunctive is also fine as a neutral question. | RK |
| With *yo* in the present only the subjunctive works after *no creer* | Normal, but *No pienso que estoy enfermo* exists in a marked sense. | F |
| Same-subject *que* after believing is never used | Negated or doubted belief takes the subjunctive with the same subject: *No creo que (yo) tenga razón, No digo que lo haga bien* (Luján 1996). | F |
| "I am part of we" | Doesn't make them one person, and never allows the indicative: *Quiero que vayamos* is right, *Queremos que vayamos* wrong. A team member's *Me alegro de haber ganado* is fine; *Quiero ir juntos* is marginal. | F/RK |
| *Cuando* has no infinitive form | *Al llegar, hasta cansarme* are standard infinitive versions. The checker no longer flags *espero que (yo)…*. | RK/L |
| *Pocos … que* → subjunctive | Required only when *pocos* = almost none (*Sé de pocos que hayan venido*); otherwise either mood. | F |
| *Por más / mucho que* → subjunctive | The indicative is correct for a real effort: *Por más que estudia, no aprueba. Por más que lo intenté, no pude.* | SN |
| *Desde que* → indicative | A future starting point takes the subjunctive: *desde que aterrices hasta que llegues al hotel.* | F (learner) |
| Asking whether something exists → subjunctive | Both: the subjunctive asks openly, the indicative assumes it exists. | L/SN |
| Superlative: subjunctive only for emphasis | A referent not yet known requires it: *El primero que llegue abre.* | RK |
| *A lo mejor, seguramente* → indicative | Indicative 98% / 95%; the subjunctive is "no excluido, especialmente en América" (NGLE) and about 5% with *seguramente* (García Pérez 2024). Not marked wrong. | F |
| Polite *-ra* only, never *-se* | The NGLE calls *-se* unacceptable here, but it's attested (*¡Qué más quisieses tú!*). | F |
| *Vayamos* is nearly literary | Normal in set uses and negatives: *vayamos por partes, no vayamos.* | RK/L |
| *No sé qué haga* is Mexican | Growing in Latin America, especially Mexico; the infinitive still predominates. | SN |

Caveats added without changing a rule:
- *Que* + **indicative** on its own is a warning or emphatic repeat: *¡Que viene el lobo! ¡Que no lo sé!* (RK). After a command *que* can mean *because*: *Abrígate, que hace frío* (RK).
- *¿Acaso…?* in a question takes the indicative (F). After the verb, *quizá* takes the indicative, except literary *-ra* (*hablara quizá*), which is really the old indicative (NGLE via UDEP, F, unresolved).
- *Mientras, siempre que* + subjunctive also covers any future time, not only "as long as / provided": *Siempre que vengas, tráeme pan* (RK).
- *Si* never takes the future or conditional in a real condition; *¡Si será tonto!* (exclamation) and *si* = whether aren't conditions. *Si* + conditional is regional to northern Spain and parts of Argentina, not Mexico or Colombia (SN/RK).
- *No sé cuándo vendrá*: an indirect question, like *¿cuándo?*, isn't a time clause (RK).
- *De ahí que* + indicative turns up but is non-standard (SN/RK). *No lo dejé porque era difícil* is grammatical but ambiguous; the subjunctive removes the ambiguity (RK).
- *Ojalá* + imperfect also means a less likely future (*Ojalá aprobara*) (SN). *No* + infinitive for signs and general orders: *No fumar* (RK).
- After a feeling about something earlier, *hubiese* works as well as *hubiera*; the rule is "subjunctive, not conditional" (RK). *Sea lo que fuere* mixes present and future subjunctive; past doubled phrases also take *-se* (*pasase lo que pasase*).
- *-ra* also has a simple-past indicative use in journalism (*el que fuera presidente*) (F). The future subjunctive survived historically in the Caribbean, Panama to Venezuela and the Canaries; today it's legal style (SN).
- Past main verb + present subjunctive for something still pending probably occurs in Spain too (the *Esbozo*'s *Mandaron que estudie*) (RK).
- Mexico and Colombia: bare *hasta* often means "not until" (*Abren hasta las diez* = they open at ten) (RK); concessive *así* + subjunctive is everyday speech; *después de que* + *-ra* in the past is common in the press.
- *Quiero que me operen, No quiero que me vean, Espero que me den el trabajo* aren't same-subject exceptions: their subject is "they" (F/RK). With a reflexive only the infinitive works: *Ana no se permite salir* (F). *Prometer* is controlled by its subject and its *que* form is indicative (F).

Checked in a third pass (notes: `unsourced_mexico.md`, `unsourced_general.md`):
- *No porque … sino porque*: the subjunctive is the normal choice in the rejected cause ("lo propio"); the indicative is unusual but possible and presents the cause as true (Blesa, *Las causales inefectivas*, F). The Learn tab accepts both.
- *No creas que es fácil*: indicative after a negative command, 2/2 in spoken Spain and 24/24 in Mexico City (Torres Cacoullos et al. 2017, *Moenia* 23, F; Aragonés 2010 via UDEP, F).
- *Lo de que*: either mood; the indicative is the norm for reported or questioned content, the subjunctive typical with a reaction (L only).
- *Puede que* + indicative: no source records it as standard or regional; keep "subjunctive, always" (SN).
- *De pronto* (Colombia, maybe): only indicative examples found (SN/L).
- *No sé qué haga*: not colloquial and not new; see section 9.
- Polite *pudiera*: not more common in Mexico; see 5.3.

Still unverified:
- *¿Crees que venga?* being more common in Mexico: only forum posts; Blake (1981, via summary) points the other way (L/SN).
- *Ojalá llegara bien* = "I hope he arrived well": learner sites only. The standard is *Ojalá haya llegado bien* (L/RK).
- Per-city figures for the indicative after feelings: DeMello 1996 (NRFH 44:2, 12 cities incl. Mexico City) has them but couldn't be fetched (DOI 10.24201/nrfh.v44i2.1943).
- *No es porque* (only by analogy with *no es que*).
