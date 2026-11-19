# Por and para: when to use each, when to use neither, and the exceptions

The rules the app should follow for *por* and *para*: in Learn lessons, in dictionary tags, and in the Spanish checker. Nothing here is built yet.
Section 12 says where each part would live.

**Sources.** The rules come from two rounds of research. The first is [research/reports/Por vs para rules.md](../research/reports/Por%20vs%20para%20rules.md),
with notes in [research/research_notes/Por vs para rules/](../research/research_notes/Por%20vs%20para%20rules/). The second,
[research/reports/Por vs para rules challenge.md](../research/reports/Por%20vs%20para%20rules%20challenge.md), with notes in
[research/research_notes/Por vs para rules challenge/](../research/research_notes/Por%20vs%20para%20rules%20challenge/), was written to challenge
the first: it tested the first round's rule against counterexamples, rival theories and regional data. **Where the two disagree, this file follows
the challenge report.** One limit applies to both: **rae.es (NGLE, DPD, Ortografía), Fundéu, the Butt & Benjamin full text and the Instituto
Cervantes Plan curricular could not be read.** rae.es and fundeu.es returned HTTP 403, the B&B mirrors were dead, and the Cervantes site showed a
maintenance page. Every RAE, DPD or Fundéu point below came in through a search snippet or a page quoting it. B&B §34.14 (and §34.14.8, the main
contrasts) was identified from an index snippet but not read.

Each rule carries a grade:

| Grade | Meaning |
|---|---|
| **F** | Read on a page that was fetched: a university handout (Bowdoin, KU, Warwick), the *Diccionario del español de México* (DEM), a journal article or abstract page, Wiktionary, a university language column (UDEP) or a Fundéu-quoting news page. The research notes grade the three handouts as pedagogical [L]; here they count as F because their text was read. D'Antonio et al. 2025 is F, but it is a position paper with no data (section 0). |
| **SN** | Seen only in a search snippet or a summary. This includes **every claim taken from rae.es** (NGLE, DPD, Ortografía, Buen uso) and every abstract that was not fetched. |
| **L** | Learner, tutor or forum site (Kwiziq, FluentU, SpanishDict, WordReference, Colanguage) |
| **RK** | Standard reference-grammar knowledge. No source was found. Check it against B&B §34.14, the NGLE or the DPD before it ships as a checker rule. Every RK item is listed in section 11. |
| **S** | The reports' own synthesis or design: the three-branch procedure, the paraphrase tests, the error/suggest tiers, the narrow checker patterns, and native judgements in the notes with no source behind them. Reasoned from sources, but no source states it. |

## The simple rules the app teaches and checks

After the third round ([notes](../research/research_notes/Por%20vs%20para%20single%20rule/)) and blind tests on real
sentences ([results](../research/por-para-two-step-test-100.md)), the Learn guide (`Flasher/Data/PorParaCourse.swift`) and
the Check a sentence engine (`Flasher/Data/PorParaEngine.swift`) both use these rules and nothing else:

> **Para → where it ends up.** The five P's: the **Place** it's headed, the **Person** who gets it, the **Point in time**
> it's due, the **Purpose**, the **Perspective** it's judged from.
>
> **Por → what drives it, or what it passes through.** The reason, the thing you're after, someone you do it for (on
> their behalf or for their sake), the route, the means, the price, the time.
>
> **Reason or purpose?** Already there and pushing → por. Not yet, and it's what you're aiming to produce → para.
>
> **Memorise:** *para siempre, para nada, no es para tanto*.

Where they come from: Delbecque's "in contact vs projected beyond", Matte Bon's "given vs new" (his own wording,
*Geométrica explosión* p. 310: "PARA presenta un elemento como nuevo… POR lo presenta como previo"), Melis ("meta y móvil
al mismo tiempo", for *luchar por*) and Company & Flores (in *ir por*, por introduces the cause of the movement), and the
history: para = por + *a* "to", and purpose moved from por to para from the 18th century. No grammar states the rules
in this form (S).

How well they do: a blind reader using only the shorter wording got 468 of 494 real Tatoeba sentences right (95%). The
engine gets 93.4% on 500 held-out sentences, and 98.3% when it says it's sure.

Anything the rules don't cover is labelled **"Not covered by the rules: memorise this one"** in the engine, and **"Not in
the rules"** in the guide: *estar/quedar por + verb*, *está por llover*, *un cuarto para las ocho*, *ir a por*, "for" verbs
with no preposition (*buscar, esperar, pedir*), and other set phrases.

The three-branch procedure below is the research version, with the full catalogue behind it.

## What changed after the challenge

- **The one-question rule is gone.** "Is there an endpoint ahead? Yes → *para*, otherwise → *por*" failed in three ways (below). It is replaced by a
  lexicon check plus three branches.
- **"*Por* is the default" is dropped.** In the one slot where the two compete freely, purpose + infinitive, *para* is the neutral form and *por*
  is the marked one.
- ***Por* of the goal sought is now a rule, not a list of exceptions.** *Voy por agua* ("I'm going for water"), *luchar por* ("fight for"),
  *optar por* ("opt for") and *lo hice por ti* ("I did it for your sake") form branch 2.
- **The uses are renumbered** to the challenge report's P1–P14 and R1–R26, each tagged with its branch. New: clock time (P9), *para con* (P13),
  choice and inclination verbs (R2), purpose *por que / porque* after a *por* verb (R8), concessive *por más que* (R26).
- **Etymology corrected.** The first element of *para* is disputed; "built to mark the endpoint" holds only for destination and recipient; purpose
  *por* is the older layer.
- **The teaching evidence is weaker** than the first round said.
- **Newly sourced DPD positions:** *agradecer por* is accepted in America; *luchar por que* and *luchar porque* are both accepted; purpose
  *porque* is fading; *esperar por* is common in much of America; *pedir por* = *preguntar por* is the only "debe evitarse" (should be avoided)
  found in the challenge pass's DPD checks.
- **Regional corrections:** *por mientras* is the preferred form in Colombia and Honduras; Mexico uses both *por mientras* and *para mientras*;
  *estar por* "about to" and duration *por* are confirmed for Mexico; *de a poquito* and *de a uno* are general Latin American, not Colombian.
- **The checker never flags** the purpose overlap zone, *por* of goal or sake, or regional variants. App copy says "in Latin America" or "in Spain",
  not "wrong", except where the RAE says to avoid a form.

## The procedure: a lexicon check, then three branches

**There is no single rule like the assertion test.** The assertion test works because mood is grammaticalised on one semantic feature, and the
subjunctive trigger lists agree with that feature. *Por* and *para* are two networks of meanings layered by history, and the same situation (a
wanted goal ahead) is coded both ways, depending on whether it is presented as delivered to (*para*) or gone after (*por*). So the honest answer is
**a test plus a lexicon** (S, challenge report).

**Why the first round's rule failed.** The first round asked: *is there an endpoint ahead that the event is headed for?* Yes → *para*, otherwise →
*por*. The challenge found three failures:

1. **A whole productive class of *por* names a goal that is plainly ahead**: the thing fetched, fought for, voted for, chosen, desired, or the
   person for whose sake something is done. *Voy por pan* ("I'm going for bread"): the bread is where the trip ends. The NGLE itself says these
   verbs express "tendencia o inclinación hacia algo" ("tendency or inclination toward something") (SN). The class takes new nouns freely, so it
   cannot be filed as a short list of exceptions.
2. **"*Por* is the default" is backwards where the two compete.** Before an infinitive of purpose, *para* is "la forma neutra" ("the neutral form")
   and *por* is the marked, motive-framing choice (D'Antonio et al. 2025, F). Historically *por* was Spanish's main purpose marker until *para*
   displaced it from the 18th century (Torres Cacoullos & Bauman 2018, F abstract).
3. **"Endpoint" had to be stretched** to "standard of judgement" and "recipient" to catch *para mí* ("in my view") and *para su edad* ("for his
   age"). At that width it also covers *gracias por el regalo* ("thanks for the gift") and *lo cambié por otro* ("I swapped it for another"),
   which take *por*. And *para siempre* ("forever") is a duration with *para*, which contradicts the rule's "duration → *por*" clause outright.

**The revised procedure** (S, challenge report). *Para* marks where the action is delivered or measured. *Por* marks what the action goes after,
or what drives or carries it.

| Step | Question | Answer | Examples |
|---|---|---|---|
| **0. Lexicon** | Does the word before pick the preposition (a governed preposition)? Is it a fixed phrase? Does the verb already mean "for" and take a bare object? | Use the lexicon (sections 5, 6) | *preocuparse por* ("worry about"), *servir para* ("be good for"), *por favor* ("please"), *para colmo* ("to top it all"), *buscar trabajo* ("look for work"), *esperar el bus* ("wait for the bus") |
| **1. Delivered or measured** → ***para*** | Is X the destination, deadline, recipient or user, intended function, or the norm or viewpoint the judgement is made against? | *para* | *sale para Madrid* ("she's leaving for Madrid"), *para el lunes* ("by Monday"), *es para ti* ("it's for you"), *taza para café* ("coffee cup"), *alto para su edad* ("tall for his age"), *para mí* ("in my view") |
| **2. Gone after** → ***por*** | Is X the thing fetched, sought, fought, voted or opted for, desired, or the person or cause for whose sake the act is done? | *por* | *voy por pan* ("I'm going for bread"), *luchar por la libertad* ("fight for freedom"), *optar por* ("opt for"), *ansioso por verte* ("eager to see you"), *lo hice por ti* ("I did it for your sake") |
| **3. Driven or carried** → ***por*** | Otherwise: is X the cause or motive, route or area, means, price or exchange, rate, time span, or agent? | *por* | *por la lluvia* ("because of the rain"), *por el parque* ("through the park"), *por correo* ("by post"), *por cinco euros* ("for five euros"), *por hora* ("per hour"), *por la mañana* ("in the morning"), *escrito por* ("written by") |
| **Overlap zone** | Purpose + infinitive, or a *que*-clause after effort, desire or benefit predicates | **both**: *para* is neutral, *por* frames the aim as a motive. **Never flag either.** | *se esfuerza por / para levantar la piedra* ("he strains to lift the stone"); *me quedé por / para terminar* ("I stayed on to finish") |

**Paraphrase tests** make the branches usable (S, challenge report). If X can be glossed *con destino a* ("bound for"), *antes de* ("before"),
*destinado a* ("meant for") or *en comparación con* ("compared with"), it is branch 1. *En busca de* ("in search of") or *a favor de* ("in favour
of"): branch 2. *A causa de* ("because of"), *a través de* ("through") or *a cambio de* ("in exchange for"): branch 3.

| Sentence | Prep | Branch | What it shows |
|---|---|---|---|
| *Salgo mañana para Madrid* ("I leave for Madrid tomorrow") / *Entró por la puerta trasera* ("he came in through the back door") | para / por | 1 / 3 | A place the trip delivers you to vs a place passed through. (F) |
| *Voy por agua* ("I'm going for water") / *Voy para casa* ("I'm heading home") | por / para | 2 / 1 | Both have something ahead. The water is what the trip goes after; home is where it delivers you. **The old rule failed here.** (F for *voy por agua*, DEM; the pair is S) |
| *Luchan por la independencia* ("they fight for independence") | por | 2 | Independence is the goal fought for. **The old rule failed here** and filed it as an exception; branch 2 predicts it. (F; NGLE regime, SN) |
| *Votar por un candidato* ("vote for a candidate") / *votar para presidente* ("vote for president", the office) | por / para | 2 / 1 | The choice gone after vs the office the vote fills. (S, challenge report) |
| *Lo hice por ti* ("I did it for your sake") / *Lo hice para ti* ("I made it for you") | por / para | 2 / 1 | The person for whose sake vs the recipient. (F, KU) |
| *Hay que hacerlo para el lunes* ("it has to be done by Monday") / *por la mañana* ("in the morning") | para / por | 1 / 3 | A deadline vs an open stretch of time. (F) |
| *Recibimos dinero para la investigación* ("we got money for research to come") / *…por la investigación* ("…for research already done") | para / por | 1 / 3 | Same noun: funding delivered to work to come vs payment for work done. The best teaching pair. (F, Bowdoin) |
| *Gracias por la ayuda* ("thanks for the help") | por | 3 | The help is the cause of the thanks. The old rule needed "no endpoint"; the help is in fact the reference point of the thanks, so "endpoint" could have claimed it. **The old rule failed here.** (F) |
| *Te doy cinco dólares por el libro* ("I'll give you five dollars for the book") | por | 3 | Exchange. (F) |
| *Es muy alto para su edad* ("he's very tall for his age"); *Para mí, la política es interesante* ("to me, politics is interesting") | para | 1 | The norm or viewpoint the judgement is measured against. (F) |
| *Te quiero para siempre* ("I'll love you forever") | para | lexicon | A duration with *para*. **The old rule's "duration → *por*" failed here.** Treat it as a fixed phrase. (RK: standard, but no fetched source attests it) |
| *Por eso* ("that's why") / *para eso* ("that's what it's for") | por / para | 3 / 1 | Cause behind vs function, in two words. (F, KU) |
| *Te devuelvo el dinero para / por cumplir mi promesa* ("I'm paying you back to keep my promise" / "out of my promise") | para / por | overlap | Both are correct. *Para* presents the result the act should produce; *por* the motive already there. (F, D'Antonio) |

**What the procedure still does not decide.** Some cases are natural both ways and the branches only explain them after the fact:
*trabajar por / para el bien común* ("work for the common good"), *hacer lo posible por / para llegar a tiempo* ("do everything possible to arrive on
time"), *rezar por / para que llueva* ("pray for rain"; but *rezar por los enfermos*, "pray for the sick", takes only *por*). These are judgements in
the challenge notes, not sourced data (S). Brea's caveat that the cause/purpose split "no se haya observado con un rigor absoluto" ("has not been
observed with absolute rigour") argues against presenting any test as exceptionless (via D'Antonio, F). What the revision buys is that its residue
is lexical (governed words, fixed phrases, *estar por / para*, "for"-verbs), the same shape as the subjunctive's trigger lists. The old rule's
residue was a whole meaning.

**Word tags** (proposed, not built; would show in search results and on the word page, like the subjunctive's trigger tags):

| Tag | Meaning | Examples |
|---|---|---|
| **+ por** | the word fixes *por* | *gracias* ("thanks"), *luchar* ("fight"), *votar* ("vote"), *optar* ("opt"), *apostar* ("bet on, back"), *decantarse* ("lean toward"), *decidirse* ("decide on"), *inclinarse* ("lean toward"), *interceder* ("intercede"), *abogar* ("advocate"), *preocuparse* ("worry"), *preocupado* ("worried"), *preguntar* (ask after someone), *brindar* ("toast"), *tener por* ("consider"), *aceptar por* ("accept as"), *acabar por* + inf. ("end up"), *pasar por* ("drop in"), *ir por* ("go and get") |
| **+ para** | the word fixes *para* | *servir* ("be good for"), *tener … para* (aptitude: *tiene oído para la música*, "he has an ear for music"), *bueno / malo para* ("good / bad for") |
| **por or para, meaning changes** | both work, with different meanings | *trabajar* ("work on behalf of / work for an employer"), *hacer* (*lo hice por / para ti*, "for your sake / for you as a gift"), *comprar* (same), *salir* ("via / bound for"), *estar* + inf. (section 9) |
| **no preposition** | the verb already means "for" | *buscar* ("look for"), *esperar* ("wait for"; *esperar por* is common in much of America), *pedir* ("ask for"), *pagar* ("pay for"), *agradecer* ("be grateful for"; *agradecer por* is accepted in America) |

Grades for the tag rows follow sections 5 and 6. *Interesarse por* ("take an interest in"), *disculparse por* ("apologise for"), *felicitar por*
("congratulate on"), *prepararse para* ("prepare for"), *alcanzar para* ("be enough for") and *bastar para* ("suffice for") belong in the tags too,
but they are RK only, so they wait for the section 11 check.

---

## 0. What the procedure predicts, and where it stops

| # | Rule | Examples | Grade |
|---|---|---|---|
| 0.1 | **Most uses take only one preposition.** Swapping it is either ungrammatical or gives a different use, not a nuance. Only *por*: thanks, price, rate, means, agent, route, fixed phrases. Only *para*: deadline, norm, viewpoint, intended use, suitability, good/bad for. | *Gracias por todo* ("thanks for everything"); *Hay que hacerlo para el lunes* ("it must be done by Monday") | F (catalogue) / S (the count) |
| 0.2 | **Real competition happens in a few slots:** sake vs recipient with a person; goal sought vs destination (*voy por pan / para casa*); route vs destination with a place; motive vs purpose with an infinitive (the overlap zone); "about to" with *estar*. | *Lo hice por ti / para ti* ("for your sake / for you"); *estar por / para llover* ("be about to rain") | F / S |
| 0.3 | **Run the lexicon check first.** Governed words, fixed phrases and "for"-verbs override the branches. | *preocuparse por* ("worry about"); *por favor* ("please"); *busco trabajo* ("I'm looking for work") | SN (NGLE §36.10) / F |
| 0.4 | **Branch 2 replaces most of the old exception list.** *Luchar por*, *votar por*, *ir por*, *optar por* are one regular meaning of *por* (the thing gone after), not exceptions. | *luchar por la libertad* ("fight for freedom"); *ir por agua* ("go for water") | SN (NGLE "tendencia o inclinación") / F (DEM) / S (the branch) |
| 0.5 | **The overlap zone is a construction, not a verb list.** Purpose + infinitive (or a *que*-clause after effort, desire or benefit) accepts both. | *para / por llegar antes* ("so as to arrive sooner") | F (D'Antonio; Nebrija) / S |
| 0.6 | ***Para* is the neutral purpose form, not the marked one.** D'Antonio et al. call *para* "la forma neutra" and *por* "probablemente más subjetiva" ("probably more subjective"). D'Antonio is a data-free position paper by two secondary-school teachers and a university lecturer, written from classroom experience; it gives two images, not one test, and concludes that beginners may do better with simple rules or lists. | *me he quedado en la oficina para / por terminar mi trabajo* ("I stayed at the office to finish my work") | F (D'Antonio, position paper) |
| 0.7 | **Neither is "the default".** The cognitive literature gives *por* a positive core (a path through a place; Funes 2020, SN), and models both as networks with a spatial central sense (Kissling et al. 2018, SN). Raw frequency favours *por* (190,975 to 126,061 tokens in one list whose corpus is not stated), but the passive agent and fixed phrases inflate that count. | | SN / S |
| 0.8 | **Coverage is unknown.** No corpus study measured what share of real *por / para* uses falls in each branch, the lexicon or the overlap zone, so "the residue is small" is untested. | | S |

**What the branches rest on.** Several traditions point toward the branches, though none states them. Cognitive grammar: *por* profiles the path
or process, *para* the goal or recipient (attributed to De Bruyne 1999 and Delbecque 1996, but known only through D'Antonio's general paraphrase,
so the attribution is second-hand; F). Teaching grammar: *para* looks forward to the goal, *por* looks back to the source (KU, F; KU reports this
"really clicks" with some learners, a testimonial, not evidence). Matte Bon's meta-operational grammar: what *para* introduces is a new, open datum;
what *por* introduces already exists, which is why *por* reads as cause (via D'Antonio, F).

**Etymology.** All accounts give *para* (via older *pora*) a second element from Latin AD, "to, toward" (Cadiñanos & Enrique-Arias 2022, F).
**The first element is disputed:** PRO + AD or PER + AD (Penny; Alvar & Pottier; Riiho calls the choice pointless outside Portuguese); *per a*
spreading from Leonese *pera* (Fernández-Ordóñez 2022); or fusion of *por* + *a* (Torres Cacoullos & Bauman 2018) (all via Cadiñanos &
Enrique-Arias, F). The vowel change *pora* > *para* is put down to analogy with the oath word *par* or to assimilation (F). Wiktionary gives
"earlier *pora* (a combination of *por* and *a*, or from Latin *prō ad*)" (F). D'Antonio garbles this, presenting *par* + *a* as the source of
*pora*, so it is not cited for etymology. **"Built to mark the endpoint" holds only for destination and recipient *para*.** Purpose *por* is the
older layer: *por* + infinitive was the majority purpose form until *para* took over from the 18th century, through a long period of variation
(Torres Cacoullos & Bauman, F abstract). Old purpose *por* survives where a sought or championed thing is named (branch 2), while *para* won the
free purpose clause (S).

For the checker this means: lexicon uses can be deterministic rules; the competing slots need meaning, so the checker should only suggest there; and
the overlap zone is accepted both ways (S).

## 1. *Para* uses

The numbering follows the challenge report's P1–P14, which is the report's own, not any grammar's. Branch numbers refer to the procedure above.

| # | Rule | Examples | Grade |
|---|---|---|---|
| 1.1 (P1) | **Purpose + infinitive** (overlap). *Para* is the neutral form; *por* + infinitive is also correct, as motive (section 4). | *Estudié medicina para ayudar* ("I studied medicine to help") | F |
| 1.2 (P2) | **Purpose question** (branch 1; this file's assignment, S). Contrasts with *¿por qué?* ("why?"). | *¿Para qué quiere mi número?* ("what do you want my number for?") | F |
| 1.3 (P3) | ***Para que* + subjunctive** (overlap; this file's assignment, S): a purpose clause with a different subject. The mood rule is the standard one, already in `subjunctive-rules.md`. | *para que lo sepas* ("so that you know") | RK (mood rule: see the subjunctive rules) |
| 1.4 (P4) | **Intended use** (branch 1). Only *para*. | *taza para café* ("coffee cup"); *una mesa para dos* ("a table for two") | F |
| 1.5 (P5) | **Recipient** (branch 1). Pairs with *por* = for your sake (branch 2). | *Este libro es para usted* ("this book is for you") | F |
| 1.6 (P6) | **Employer** (branch 1). Pairs with *por* = on behalf of. | *Trabaja para la OTAN* ("she works for NATO") | F |
| 1.7 (P7) | **Destination, direction** (branch 1). Pairs with *por* = via (branch 3) and *por* = to fetch (branch 2). | *Salgo mañana para Madrid* ("I leave for Madrid tomorrow"); *para allá* ("that way") | F (*para allá*: RK) |
| 1.8 (P8) | **Deadline, point in time ("by")** (branch 1). Only *para*. | *Hay que hacerlo para el lunes* ("it has to be done by Monday"); *Necesito tu decisión para fin de mes* ("I need your decision by the end of the month"); *Para septiembre, me estaré quedando atrás* ("by September I'll be falling behind"); *¿Para cuándo es?* ("when is it due?") | F (KU; Wiktionary) |
| 1.9 (P9) | **Clock time, America** (branch 1). | *Faltan 10 minutos para las 5* ("it's ten to five"); *un cuarto para las ocho* ("a quarter to eight") | F (DEM, the *faltan … para las* frame) / SN (RAE Ortografía, *cuarto para*) |
| 1.10 (P10) | **Measured against a norm** (branch 1). Only *para*. | *Es muy alto para su edad* ("he's very tall for his age"); *Para ser extranjero, habla muy bien* ("for a foreigner, he speaks very well") | F |
| 1.11 (P11) | **Viewpoint** (branch 1). Contrasts with *por mí* ("I don't mind"). | *Para mí, la política es interesante* ("to me, politics is interesting"); *Para la ley, todos somos iguales* ("in the eyes of the law we are all equal") | F |
| 1.12 (P12) | **Good or bad for; suitability, aptitude, function** (branch 1). Only *para*. | *No fumar es bueno para la salud* ("not smoking is good for your health"); *Había espacio para todos* ("there was room for everyone"); *Tiene oído para la música* ("he has an ear for music"); *¿Para qué sirve un martillo?* ("what is a hammer for?") | F |
| 1.13 (P13) | ***Para con*: attitude toward** someone (lexicon; this file's assignment, S). Alternates with plain *con* with very little difference. | *Fue buena para con sus padres* ("she was good to her parents"); *amable con / para con todos* ("kind to everyone") | SN (RAE Buen uso; NGLE) |
| 1.14 (P14) | ***Estar para* + infinitive = "about to"** (lexicon). The DPD calls it the more general form; *estar por* is also used in some American countries (section 9). | *¿Está para llover?* ("is it about to rain?") | SN (DPD *estar*) |

## 2. *Por* uses

The numbering follows the challenge report's R1–R26.

| # | Rule | Examples | Grade |
|---|---|---|---|
| 2.1 (R1) | **Fetch, go for** (branch 2). Open across verbs of motion (*ir, venir, bajar, subir, salir*). Spain also says *a por* (section 9). | *Voy por agua* ("I'm going for water"); *Salió por pan* ("he went out for bread"); *Subió por el libro* ("she went up for the book"); *Ve por ayuda* ("go get help") | F (DEM; UDEP) / SN (Fundéu summary) |
| 2.2 (R2) | **Choice, support, inclination** (branch 2). Verb-governed; the NGLE groups these as verbs of "tendencia o inclinación hacia algo". *Optar a* ("apply for") vs *optar por* ("choose"). | *optar por* ("opt for"), *apostar por* ("bet on, back"), *votar por* ("vote for"), *decantarse por* ("lean toward"), *inclinarse por* ("lean toward"), *interceder por* ("intercede for"), *abogar por* ("advocate") | SN (NGLE; DPD *apostar*; Fundéu-style column) |
| 2.3 (R3) | **Struggle, contest** (branch 2). | *Luchan por la independencia* ("they fight for independence"); *la carrera por la vacuna* ("the race for the vaccine") | F (*luchar*) / S (contest nouns: judgement, no count) |
| 2.4 (R4) | **Toast, favour** (branch 2). | *Brindo por tu felicidad* ("I toast to your happiness") | F (DEM) |
| 2.5 (R5) | **Sake, on behalf of** (branch 2). Pairs with *para* = recipient. | *Hoy por ti, mañana por mí* ("today for you, tomorrow for me"); *Lo hice por ti* ("I did it for your sake"); *pedir por los enfermos* ("pray for the sick"); *morir por la patria* ("die for one's country") | F (Warwick) / SN (DPD *pedir*) / S (*morir por*) |
| 2.6 (R6) | **Concern, asking after** (branch 2). Verb-governed. | *Se preocupan por mí* ("they worry about me"); *Me pregunta por ti* ("she asks after you") | F |
| 2.7 (R7) | **Purpose + infinitive as motive** (overlap). Correct; never flag (section 4). | *Viene al cine con nosotros por distraerse un poco* ("he's coming to the cinema with us to take his mind off things"); *me quedé por terminar el trabajo* ("I stayed on to finish the work") | SN (Ministry of Education document) / F (D'Antonio) |
| 2.8 (R8) | **Purpose clause *por que* / *porque* + subjunctive after a *por* verb** (lexicon: needs a *por* regime; this file's assignment, S). The DPD accepts both spellings (section 7). | *luchar por que haya paz* ("fight for there to be peace"); *Me preocupo por que los más desprotegidos estudien* ("I make sure the most vulnerable get an education") | SN (DPD *porque*) |
| 2.9 (R9) | **Cause, reason** (branch 3). | *No jugaron por la lluvia* ("they didn't play because of the rain"); *por no estudiar* ("through not studying") | F (*por no estudiar*: RK) |
| 2.10 (R10) | **Gratitude, apology, congratulation** (branch 3). Only *por*. | *Gracias por todo* ("thanks for everything") | F (*disculparse / felicitar por*: RK) |
| 2.11 (R11) | **Cause with a participle** (branch 3). | *Está afectada por la noticia* ("she's affected by the news") | F |
| 2.12 (R12) | **Price, exchange** (branch 3). Only *por*. | *Lo vendió por $1 000* ("he sold it for $1,000"); *Cambio pesos por tostones* ("I swap pesos for coins") | F |
| 2.13 (R13) | **Rate, percent, distribution, multiplication** (branch 3). Only *por*. | *veinte kilómetros por hora* ("twenty kilometres an hour"); *el diez por ciento* ("ten percent"); *por cabeza* ("per head"); *dos por tres* ("two times three") | F (*dos por tres*: RK) |
| 2.14 (R14) | **Taken as, considered** (branch 3). Only *por*. | *No me tomes por idiota* ("don't take me for an idiot"); *Lo tiene por sabio* ("she considers him wise"); *Te acepto por amigo* ("I accept you as a friend"); *lo dieron por muerto* ("they gave him up for dead") | F (*dar por*: RK) |
| 2.15 (R15) | **Duration, often left out** (branch 3). See section 8. | *Salió por un mes* ("he left for a month"); *esperó por tres horas* ("he waited for three hours"); *Estuvo en México (por) seis semanas* ("he was in Mexico for six weeks") | F (DEM; Fundéu via Panamá América; Bowdoin) |
| 2.16 (R16) | **Part of the day, approximate date** (branch 3). | *por la mañana* ("in the morning"); *Regresa por Navidad* ("he's coming back around Christmas") | F |
| 2.17 (R17) | **Route, through, along** (branch 3). Pairs with *para* = toward. | *Entró por la puerta trasera* ("he came in through the back door"); *pasear por el parque* ("stroll through the park") | F |
| 2.18 (R18) | **Dropping in** (branch 3). | *Pasa por mi oficina* ("drop by my office") | F |
| 2.19 (R19) | **Spread over an area; vague place** (branch 3). | *He viajado por Brasil* ("I've travelled around Brazil"); *por aquí* ("around here"); *por allí* ("over there somewhere") | F |
| 2.20 (R20) | **Means, channel, transport** (branch 3). | *Lo supe por un amigo* ("I heard it from a friend"); *Llámame por teléfono* ("call me on the phone"); *llegó por avión* ("it came by plane"); *por email* ("by email") | F |
| 2.21 (R21) | **Passive agent** (branch 3). Some participles take *de* instead (RK, section 11). | *América fue descubierta por Colón* ("America was discovered by Columbus") | F |
| 2.22 (R22) | **Still to be done** (lexicon; *por* + infinitive). | *aún está por escribirse* ("it is yet to be written"); *un trabajo por entregar* ("a piece of work still to hand in") | SN (DPD *estar*) / F (DEM) |
| 2.23 (R23) | ***Estar por* + infinitive = "about to"** (lexicon), America. Alternates with *estar para*. | *Es martes y está por llover* ("it's Tuesday and it's about to rain"); *estar por terminar una novela* ("be about to finish a novel") | SN (DPD *estar*) / F (DEM *estar* sense 7) |
| 2.24 (R24) | **Outcome with *acabar por*** (lexicon). | *Acabó por llorar* ("he ended up crying") | F (DEM) |
| 2.25 (R25) | **For its own sake** (lexicon: the fixed pattern *X por X*; this file's assignment, S). | *hablar por hablar* ("talking for the sake of talking"); *el arte por el arte* ("art for art's sake") | F |
| 2.26 (R26) | **Concessive *por más / mucho que*** (lexicon: fixed phrase; this file's assignment, S). Indicative presents the obstacle as fact; subjunctive as a hypothesis. **Both moods are correct.** A learner site (Colanguage) says the indicative is wrong for a failed attempt; that claim is not followed. | *Por más que estudia, no aprueba* ("however much he studies, he doesn't pass"); *Por más que estudie, no aprobará* ("however much he studies, he won't pass"); *Por más que lo intenté, no pude* ("try as I might, I couldn't") | SN (Masaryk Univ. handout) / L (the rejected claim) |

Desire nouns and adjectives (*afán por*, "eagerness for"; *ansioso por verte*, "eager to see you"; *loco por*, "crazy about") and contest nouns
belong in branch 2 on the challenge researchers' judgement. The pattern takes new nouns freely, but there is no corpus count behind it (S).

## 3. Minimal pairs: both work, with different meanings

**Attested whole.** These appear as pairs in the fetched sources:

| Pair | *por* | *para* | Branches | Grade |
|---|---|---|---|---|
| *Recibimos dinero por / para la investigación* | "money for research already done" | "money for research still to come" | 3 / 1 | F (Bowdoin). The best teaching pair. |
| *Compré esto por ti / para ti* | "I bought this because you wanted me to" | "I bought this as a present for you" | 2 / 1 | F (Bowdoin) |
| *Lo hice por ti / para ti* | "because of you, for your sake" | "for you, as recipient" | 2 / 1 | F (KU) |
| *Trabajo por / para mi jefe* | the boss as cause, or the person whose place I fill | the boss as employer | 3 / 1 | F (D'Antonio et al. 2025) |
| *Te devuelvo el dinero por / para cumplir mi promesa* | "out of my promise" | "so as to keep my promise" | overlap | F (D'Antonio) |
| *Lo han llamado por / para esa tarea* | "they called him because of that task" | "they called him to do that task" | 3 / 1 | F (D'Antonio, quoting Matte Bon) |
| *¿Por qué? / ¿Para qué?*; *por eso / para eso* | "why?"; "that's why" | "what for?"; "that's what it's for" | 3 / 1 | F (KU) |
| *Por mí / para mí* | "I don't mind"; "for my sake" | "in my opinion"; "for me" | 2 / 1 | F (KU) |
| *Estar por / para* + inf. | "still to do"; "about to" (America); "inclined to" (section 9) | "about to"; "in the mood for" | lexicon | SN (DPD *estar*) |

**Built from halves.** Each half is attested on its own; the pair is not. They follow from the branches, but no source gives them as pairs.

| Pair | *por* | *para* | Halves from | Grade |
|---|---|---|---|---|
| *Salgo por / para Madrid* | "I leave via Madrid" | "I leave for Madrid" | 2.17 / 1.7 | S (pair); F (halves) |
| *Voy por pan / Voy para casa* | "I'm going for bread" | "I'm heading home" | 2.1 / 1.7 | S (pair); F (halves) |
| *Caminar por / para el parque* | "walk through the park" | "walk toward the park" | 2.17 / 1.7 | S (pair); F (halves) |
| *Por / para la tarde* | "in the afternoon" | "by the afternoon" | 2.16 / 1.8 | S (pair); F (halves) |
| *Votar por un candidato / votar para presidente* | "vote for a candidate" | "vote for president" (the office) | 2.2 / none | S (pair and *votar para*) |
| *Trabajo por / para mis hijos* | "I work for my children's sake" | "my children receive what I earn" | 2.5 / 1.5 | S (pair) |

Pairs the app should **not** use until checked (no source): *hablo por / para ella*, *lo cambié por / para otro*, *vino por / para el libro*,
*estudia para médico* (and never offer *por médico*). Their meanings are unconfirmed (RK, section 11).

## 4. Purpose with an infinitive: the overlap zone

This is the one place where both prepositions do nearly the same job. It is a construction, not a verb list.

| # | Rule | Examples | Grade |
|---|---|---|---|
| 4.1 | **Both can express purpose with an infinitive.** Batchelor & San José: "por, like para, may be used with the idea of intention". The GDLE, as quoted, says *por* "expresa la finalidad cuando va acompañada de infinitivo" ("expresses purpose when it takes an infinitive"). Nebrija authors call the two interchangeable where the difference becomes almost imperceptible. | *para / por llegar antes* ("so as to arrive sooner"); *por distraerse un poco* ("to take his mind off things") | SN (abstract; Ministry document) / F (D'Antonio quoting GDLE; Nebrija) |
| 4.2 | ***Para* is the neutral form; *por* frames the aim as a motive.** *Por* = a motive already there, which pushes the act. *Para* = a result the act should produce, after it. *Por* "nunca presenta el fin de forma contundente" ("never presents the aim forcefully"). | *Te devuelvo el dinero para cumplir con mi promesa* ("I'm paying you back to keep my promise": the result comes after) / *…por cumplir con mi promesa* (the promise drives the act) | F (D'Antonio) |
| 4.3 | **Cause and purpose can rub together.** | *Pasa por la ciudad por / para no pasar por la Vía de Cintura* ("he goes through the city so as not to take the ring road") | F (D'Antonio) |
| 4.4 | **After effort, desire or benefit predicates, both work with an infinitive or a *que*-clause.** | *El niño se esfuerza por / para levantar la piedra* ("the boy strains to lift the stone"); *hacer lo posible por / para llegar a tiempo* ("do everything possible to arrive on time") | SN (thesis snippet: "intercambiables en el lenguaje, pero no en el concepto", "interchangeable in use, but not in concept") / S |
| 4.5 | **The Learn test:** is this something the subject already wants, which pushes the act (*por*)? Or a result the act should produce (*para*)? | | S |
| 4.6 | **The app generates *para* for purpose**, because it is the neutral form. | *Estudié medicina para ayudar* ("I studied medicine to help") | F (D'Antonio) / S |
| 4.7 | **Never flag *por* + infinitive of purpose**, not even as a suggestion (section 10). | *por llegar antes* | S (challenge report) |
| 4.8 | **After motion verbs, natives often use *a*, not *para*.** Learners overuse *para* here. Both are grammatical; this is a style point, not an error. | *Voy a la biblioteca a trabajar* ("I'm going to the library to work") vs *…para trabajar* | F (Jiménez 2017 review, in the first round's learner-error note) |

## 5. Words that govern *por* or *para*, and "for" verbs that take neither

The NGLE treats verb-governed *por / para* as *complementos de régimen* (governed complements) (§36.10, SN). That is why these are a lexicon,
checked before the branches. Most *por* regimes fall in branch 2 in meaning, which makes them easy to explain, but the lexicon still decides.

**+ por**

| Word | Meaning | Example | Grade |
|---|---|---|---|
| *luchar por* | fight for | *Luchan por la independencia* ("they fight for independence"). *Luchar para* + inf. survives for concrete aims: *luchar para sobrevivir* ("fight to survive"). | SN (NGLE §36.10) / F |
| *votar por* | vote for | *Voté por la libertad* ("I voted for freedom"). *Votar a* + candidate in Spain is RK. | F / SN (NGLE) |
| *optar, apostar, decantarse, decidirse, inclinarse, interceder por* | opt for, bet on or back, lean toward, decide on, lean toward, intercede for | *Optó por quedarse* ("she chose to stay"; constructed, S). *Optar a* = "apply for". *Apostar por* = "opt for" or "show confidence in" (DPD). | SN (NGLE; DPD *apostar*) |
| *abogar por* | advocate | *abogar por la paz* ("advocate peace"; constructed, S) | SN (Fundéu-style column; UCM) |
| *preocuparse por*, *preocupado por* | worry about, worried about | *Se preocupan por mí* ("they worry about me") | F |
| *preguntar por* | ask after someone | *Me pregunta por ti* ("she asks after you") | F |
| *brindar por* | toast to | *Brindo por tu felicidad* ("I toast to your happiness") | F (DEM) |
| *tener por*, *tomar por* | consider, take for | *Lo tiene por sabio* ("she considers him wise"); *No me tomes por idiota* ("don't take me for an idiot") | F |
| *aceptar por* | accept as | *Te acepto por amigo* ("I accept you as a friend") | F (DEM) |
| *acabar por* + inf. | end up doing | *Acabó por llorar* ("he ended up crying") | F (DEM) |
| *ir por* (Spain also *ir a por*) | go and get | *Voy por agua* ("I'm going for water") | F (DEM; UDEP) / SN (Fundéu summary) |
| *pasar por* | drop in at | *Pasa por mi oficina* ("drop by my office") | F |
| *esforzarse por*, *desvivirse por* | strive to, do everything for | *El niño se esfuerza por levantar la piedra* ("the boy strains to lift the stone"). With an infinitive this is the overlap zone: *para* also works (section 4). | SN (thesis snippet) |

After any of these, a purpose clause can be *por que* or *porque* + subjunctive (section 7).

**+ para**

| Word | Meaning | Example | Grade |
|---|---|---|---|
| *servir para* | be good for | *¿Para qué sirve un martillo?* ("what is a hammer for?") | F (DEM) |
| *tener … para* | have an aptitude for | *Tiene oído para la música* ("he has an ear for music") | F (DEM) |
| *bueno / malo para* | good / bad for | *No fumar es bueno para la salud* ("not smoking is good for your health") | F |
| *para con* | toward (attitude) | *Fue buena para con sus padres* ("she was good to her parents") | SN (RAE Buen uso) |

Not yet sourced (RK, section 11): *disculparse por* ("apologise for"), *felicitar por* ("congratulate on"), *interesarse por* ("take an interest
in"); *prepararse para* ("prepare for"), *alcanzar para* ("be enough for": *no alcanza para todos*, "there isn't enough for everyone"), *bastar para*
("suffice for"); *responsable de* ("responsible for", the norm) vs American *responsable por*; *listo para* ("ready to"), *apto para* ("fit for"),
*útil para* ("useful for").

**"For" verbs that take neither.** The verb already contains English "for", so the thing is a direct object. Where the DPD records a regional
*por* form, the app accepts it and says where it is used.

| Verb | Rule | Examples | Grade |
|---|---|---|---|
| *buscar* | look for: direct object | *Busco trabajo* ("I'm looking for work"); *busco mis llaves* ("I'm looking for my keys"). But *lo busqué por toda la casa* ("I looked for it all over the house") is a place *por* and is fine. | L |
| *esperar* | wait for: direct object in general Spanish (*esperar a alguien*, "wait for someone"). The DPD says *esperar por* is common in much of America, especially the Caribbean, partly through English "wait for". Fundéu calls it a calque but accepts *por* for cause or duration. Purists in Colombia object to it (an *El Tiempo* column). The DEM has only the transitive verb. Not specifically Mexican. | *Espero el autobús* ("I'm waiting for the bus"; constructed, S). *Esperó por tres horas* ("he waited for three hours") is duration and fine. *Esperé para hablar con él* ("I waited to speak to him") is purpose *para* and fine. | SN (DPD *esperar*; *El Tiempo*) / F (Fundéu via Panamá América; DEM) |
| *pedir* | ask for: direct object. **The DPD says *pedir por* meaning *preguntar por* (ask after someone) "debe evitarse" (should be avoided)**, attributing it to Catalan speakers and parts of America, probably via English "ask for". It accepts *pedir por* for a price, for praying for someone, and in the Southern Cone for asking on someone's behalf. | *Pedí ayuda* ("I asked for help"). *Le piden seis mil liras por un simple afeitado* ("they charge him six thousand lire for a shave"), *pedir por los enfermos* ("pray for the sick") and *te lo pido por favor* ("I'm asking you, please") are fine. | L / SN (DPD *pedir*) |
| *pagar* | pay for: the thing paid for is a direct object. *Pagar X por Y* is price. | *Pagué la cena* ("I paid for dinner") | L |
| *agradecer* | be grateful for: in general Spanish a direct object, usually with an indirect object (*agradecer algo a alguien*). The DPD says that in American Spanish it is also often used with *por* (*agradecer a alguien por algo*) and does not condemn it. **Accept *agradecer por*; tag it "Latin America".** A learner site calls it a mistake; that is stricter than the DPD and is not followed. | *Te agradezco la ayuda* ("I'm grateful for your help"); *Le agradezco por su ayuda* ("I thank you for your help", American; constructed, S) | SN (DPD *agradecer*) / L (the rejected claim) |

## 6. Fixed phrases

No choice to make. All glosses below are standard meanings; the phrases themselves are attested where graded.

**With *por*** (F: Bowdoin, Warwick, DEM)

| Phrase | Meaning |
|---|---|
| *por fin* | at last |
| *por ejemplo* | for example |
| *por desgracia* | unfortunately |
| *por supuesto* | of course |
| *por eso* | that's why |
| *por lo menos* | at least |
| *por favor* | please |
| *por primera vez* | for the first time |
| *por casualidad* | by chance |
| *por otra parte* | on the other hand |
| *por lo tanto* | therefore |
| *por lo general* | generally |
| *por lo pronto* | for now |
| *por ahora* | for now |
| *por más que* | however much (section 2.26) |
| *por poco* | almost |
| *por si acaso* | just in case |
| *por si las dudas* | just in case (DEM, unmarked in Mexico) |
| *por si no* | in case not |

**With *para*** (F: DEM)

| Phrase | Meaning |
|---|---|
| *para colmo* | to top it all |
| *para su desgracia* | unfortunately for him / her |
| *para sí* | to himself / herself |

**Unsourced, RK (section 11):** *por cierto* ("by the way"), *por lo visto* ("apparently"), *por completo* ("completely"), *por si las moscas*
("just in case", Spain, colloquial), *para siempre* ("forever"), *para nada* ("not at all"), *para variar* ("for a change"), *no es para tanto*
("it's not that big a deal"), *para que sepas* ("just so you know"), *no estoy para bromas* ("I'm not in the mood for jokes"), *para mí que* ("I
reckon"). *Para siempre* matters for teaching: it is the duration-with-*para* counterexample, so it goes in the fixed-phrase list, not the branches.
(The DEM *nada* page has no *para nada* subentry.)

***Por eso* / *para eso* should anchor the fixed-phrase lesson** (S). It is the cleanest single picture of branch 3 against branch 1: cause behind,
function ahead.

## 7. *Porque*, *por que*, *por qué*, *porqué*

Four spellings, four jobs (F: El Universal; Acento, quoting Fundéu Guzmán Ariza).

| Form | Job | Example | Note |
|---|---|---|---|
| *porque* | causal conjunction, "because" | *No vino porque estaba enfermo* ("he didn't come because he was ill"; constructed, S) | With the subjunctive it can mean purpose (= *para que*); see below. |
| *por qué* | interrogative, direct and indirect questions | *¿Por qué no viniste?* ("why didn't you come?"); *No sé por qué lo hizo* ("I don't know why he did it") | |
| *porqué* | noun, "reason"; takes a determiner, plural *porqués* | *el porqué de su decisión* ("the reason for her decision") | Common error: *porqué* for *por qué*. |
| *por que* | preposition + relative *que* | *Ese es el motivo por (el) que decidió no ir* ("that's the reason he decided not to go") | Test: an article fits between them. |

**Purpose *porque* + subjunctive** (SN, DPD *porque*):
- The DPD says *porque* is also a purpose conjunction with the subjunctive, meaning *para que*. It was normal in earlier periods but "hoy está
  decayendo" ("is now in decline"). One-word *porque* is accepted for purpose only when the verb is subjunctive and the clause reads as purpose.
- **After a word that governs *por*, the DPD accepts both *por que* and *porque*** + subjunctive: *luchar por que haya paz* and *luchar porque haya
  paz* ("fight for there to be peace"); «Rogué porque su agonía no fuera larga» ("I prayed that his agony would not be long"). *Por que* is the
  more transparent spelling; neither is wrong.
- The app accepts both spellings after *por* regimes, teaches *porque* + indicative as "because", and does not generate purpose *porque* elsewhere.

## 8. Time and duration

| # | Rule | Examples | Grade |
|---|---|---|---|
| 8.1 | **Part of the day: *por*.** | *por la mañana* ("in the morning"); *por la tarde* ("in the afternoon") | F |
| 8.2 | **Approximate time: *por*.** | *Regresa por Navidad* ("he's coming back around Christmas"). Other dates (*por abril*, "around April") are RK. | F (DEM) / RK |
| 8.3 | **Deadline or point in time: *para*.** | *para el lunes* ("by Monday"); *para fin de mes* ("by the end of the month"); *Para septiembre…* ("by September…"); *¿Para cuándo es?* ("when is it due?"). *Para entonces* ("by then") is RK but follows the same pattern. | F (KU; Wiktionary) / RK |
| 8.4 | **Duration usually takes no preposition; *por* + duration is also correct.** The DEM lists *Salió por un mes* ("he left for a month") as ordinary Mexican usage, and Fundéu accepts *esperó por tres horas*. *Durante* as the neutral "for, during" is RK. | *Estuvo en México (por) seis semanas* ("he was in Mexico for six weeks"); *Estuve por tres semanas en Argentina* ("I was in Argentina for three weeks"); *Estudié tres horas* ("I studied for three hours"; constructed) | F (DEM; Fundéu via Panamá América; Bowdoin: "often omitted") / RK (*durante*) |
| 8.5 | ***Para siempre* ("forever") is a duration with *para*.** A fixed phrase; it breaks the old "duration → *por*" rule. *Por siempre* exists but is literary or set (*por siempre jamás*, "for ever and ever"). | *Te quiero para siempre* ("I'll love you forever") | RK |
| 8.6 | **"Have been doing for": *desde hace* or *llevar*, never *por* or *para*.** | *Vivo aquí desde hace año y medio* / *Llevo año y medio aquí* ("I've lived here for a year and a half"), not *\*Vivo por un año y medio* | F (Jiménez 2017) |
| 8.7 | ***Para* + a span can be a deadline**, so *para dos horas* is not automatically wrong. (The first round's *voy para dos semanas*, "I'm going for two weeks", is unverified and is not taught.) | *para dentro de dos horas* ("for two hours from now"; constructed, S) | S |
| 8.8 | ***Por* vs *durante* by region** (more American *por*, more *durante* or nothing in Spain) is plausible but untested; no corpus comparison was found. | *me voy por dos semanas* ("I'm going away for two weeks") | RK |

The app generates no preposition (or *durante*) for duration, accepts duration *por*, and generates *desde hace* / *llevar* for "have been doing
for" (S).

## 9. Regional variation: Mexico, Colombia, Spain

Mexico has the best sources, because the DEM, built from a corpus of contemporary Mexican Spanish, was fetched. When the DEM lists a phrase with no
regional or "Popular" label, that is good evidence it is ordinary Mexican usage; when it leaves one out, that is weak evidence (S, notes). Spain's
forms come through DPD and Fundéu snippets. **Colombia is still thinly sourced**, and the one new Colombian finding overturns the first round. The
Colombia column is not filled by analogy with Mexico. The app has Mexico and Colombia modes only; for Spain, the column says what to accept and tag
"Spain" (and what a Spain mode would generate, if one is added).

In every case where the DPD speaks, it is **descriptive and regional, not prohibitive.** App copy should say "in Latin America" or "in Spain",
never "wrong". The two exceptions found are *pedir por* = *preguntar por* (DPD: "debe evitarse", the only one in the challenge pass's DPD
checks) and *un cuarto a las ocho* (RAE Ortografía: "no debe decirse"). The first round also reported, from a snippet, that the DPD advises
against *por lo mientras* in educated speech; the app accepts it in casual input, tagged colloquial.

| Feature | Mexico | Colombia | Spain | Grade |
|---|---|---|---|---|
| "Go and get" | generate *ir por agua*, *salió por pan* ("went out for bread"); the DEM has no *a por* | not sourced; *ir por* assumed from pan-American statements; generate *ir por* | accept *ir a por*; *ir por* also used. A UDEP column, paraphrasing the 2005 DPD, says Latin Americans find *a por* odd, that educated usage prefers *por*, and that *a por* should not be censured. The exact DPD wording (entry *a*, §2) was not obtained. | F (DEM; UDEP) / SN (DPD *ir* cross-reference) |
| Quarter to the hour | generate *un cuarto para las ocho* ("quarter to eight"), *faltan 10 para las 5* ("ten to five"). The DEM attests the *faltan … para las* frame; its *cuarto* entry has no *cuarto para las* example. | "almost all of America" uses *para*, per the RAE; generate *un cuarto para*. No Colombian source. | generate *las ocho menos cuarto* | F (DEM) / SN (RAE Ortografía, DPD *hora*) |
| *estar por* + inf. = "about to" | accept and generate: DEM *estar* sense 7, unmarked (*estar por comer*, "be about to eat") | not sourced | *estar para* is the more general "about to"; *estar por* = still to be done. The notes disagree on whether the DPD limits Spanish "about to" *estar por* to *caer* and *llegar* (*está por llegar*, "he's about to arrive"), or whether that limit belongs to *estar al* + inf. (*está al caer*, "it's about to happen"). Unresolved (section 11). An "inclined to" sense (*estoy por irme*, "I'm tempted to leave") has only an RILCE mention behind it. | F (DEM) / SN (DPD *estar*; RILCE) |
| "Meanwhile" | *por mientras* coexists with *para mientras*; accept both. The DEM lists neither. *Por lo mientras* is colloquial; the DPD advises against it in educated speech. | ***por mientras* is the preferred variant**; accept and generate | not sourced | SN (del Barrio de la Rosa 2026, abstract) / F (DEM *mientras*; UDEP) / SN (DPD *mientras*) |
| *esperar por* | absent from the DEM (transitive only) | occurs; purists object (*El Tiempo* column) | prescriptively avoided | F (DEM) / SN (*El Tiempo*; DPD *esperar*) |
| *agradecer por* | American, frequent: accept | American, frequent: accept | *agradecer algo* | SN (DPD *agradecer*) |
| "Just in case" | accept and generate *por si las dudas* (unmarked) | not sourced | not sourced | F (DEM *duda*) |
| *pa'*, *pa'l*, *pa' lante* | "Popular" (informal) in the DEM: accept in casual input | colloquial: accept (not sourced) | colloquial: accept | F (DEM *pa*; Wiktionary; UDEP on the apostrophe) |
| Duration *por* | unmarked: *Salió por un mes* ("he left for a month") | not sourced | accepted (*esperó por tres horas*) | F (DEM; Fundéu via Panamá América) |

Rules that apply in every mode:
- **Never accept *un cuarto a las ocho*.** The RAE says "no debe decirse" ("should not be said"); the American formula must use *para* (SN, RAE
  Ortografía).
- **The verb agrees with *un cuarto*:** *Es un cuarto para las cuatro* ("it's a quarter to four") (SN, UDEP).
- **In Mexico and Colombia modes, tag *ir a por* and *menos cuarto* as "Spain", never as wrong.** Correcting *ir a por* would contradict the DPD as
  the UDEP column reports it (S).
- **Tag *agradecer por*, *estar por* "about to", *por mientras* and *esperar por* as "Latin America" usages, not errors** (S).
- **Normalise *pa'* to *para* only when correcting toward the formal register** (S).
- *Pedir por* = "ask on someone's behalf" is Southern Cone, not Mexico or Colombia (SN, DPD *pedir*).
- *De a poquito* ("little by little") and *de a uno* ("one at a time") are general Latin American *de a*, not Colombian features (RK, challenge
  notes). *Mandar por* ("send for") and *votar a* + candidate in Spain are unsourced (RK).

## 10. Learner errors and checker patterns

**What learners do** (F, Jiménez 2017, re-tabulating Guntermann 1992, Lafford & Ryan 1995, Pinto & Rex 2006):
- English speakers produce *para* in **64–68% of *por/para* tokens**, rising to **83% at intermediate level** (Lafford & Ryan). No native baseline
  was given, so "overuse" is an inference.
- Error rates in Guntermann: *por* 83% → 32% → 21% (beginning, intermediate, advanced); *para* 0% → 33% → 16%. In Lafford & Ryan: *por* 40% → 48% → 18%;
  *para* flat at 34 / 37 / 33%. Jiménez calls both curves U-shaped, but **his own table shows a U in only two of the four series**. Pinto & Rex
  figures are left out because the table's row labels are misaligned.
- The story: beginners map *por* to "for", find it fails, and fall back on *para*. At intermediate level they also "utilizan por en contextos donde
  se requiere para" ("use *por* where *para* is needed").
- *Para* of purpose is the most stable use (55–77% of correct *para*). Purpose plus recipient is 94% of *para* uses in Lafford & Ryan.
- Early *por* is mostly chunks (*por favor* "please", *por eso* "that's why", *gracias por* "thanks for") and exchange. Route, means and vague location
  come late. *Para mí* as opinion is almost absent (learners say *creo que*). Learners go notional → temporal → spatial, **the reverse of L1 children**.
  So Learn should teach spatial *por* (route, through, around) deliberately.
- Error research on another L1 points the same way: a UAB thesis on Chinese learners finds *por* the top error source and *para* the next (F).
- **Branch 2 targets the main error.** It gives learners a positive reason for *por* exactly where English "for" pulls them toward *para* (*luchar
  para*, *votar para*, *ir para pan*). "Make every *para* earn its place" is fine as a teaching stance, given the overuse data, as long as it is not
  presented as a fact about which preposition is marked (S, challenge report).

**Teaching evidence is weak and mixed.**
- Pinto & Rex (2006), a cross-sectional study of classroom learners at four levels, warn that textbook explanations presenting the two
  prepositions **as opposites** may not match learners' difficulties or how the prepositions work in discourse (F, abstract page). A one-question
  rule is the most extreme form of that framing.
- Lam (2009) found intermediate learners taught a cognitive description confused the two less in free writing than a list-taught group (F, abstract), but
  **Lam later described the result as improvement in only specific aspects** (Lam 2018, SN).
- A follow-up with intact classes (list instruction n = 32; incremental polysemy networks n = 34) found the network approach helped most **on a
  multiple-choice test, but not on a fill-in-the-blank test**, which is the measure closest to production (SN). Kissling & Arnold (2022, SN)
  report preliminary gains for novices.
- No study tests a single heuristic against full networks. So the evidence modestly supports **connected meaning networks over a memorised list**,
  not a single binary question. PERDE / PODER-style acronyms built on English "for" give no way to handle the verbs that take no preposition.

**Checker tiers.** The split is the reports' design (S). The error tier is kept as narrow as the challenge report says: lexical patterns only.

*Flag as error*

| Pattern | Correction | Basis |
|---|---|---|
| *gracias para* + noun or infinitive | *gracias por* | F (2.10; Jiménez) |
| *para favor*, *para supuesto*, *para ejemplo* | *por favor*, *por supuesto*, *por ejemplo* | F (fixed phrases, section 6) |
| *pagar* + amount + *para* + noun | *por* (price) | F (2.12) / S (pattern) |
| *preocupado/a(s) para* + noun | *preocupado por* | F (regime, section 5) / S (pattern) |
| *esperar / buscar* + *para* + determiner + noun | direct object: *espero el autobús*, *busco las llaves* | F/L (verbs) / S (narrow pattern) |
| *para que* + indicative in a purpose clause | *para que* + subjunctive | Already flagged by the existing subjunctive checker (`["para", "que"]` is in `subjunctiveTriggers` in `Flasher/Data/SpanishRules.swift`), so not repeated here. |

*Suggest only* (non-blocking hints)

| Pattern | Suggestion | Why only a suggestion |
|---|---|---|
| *pedir por* + person (= ask after) | *preguntar por* | The DPD says to avoid it, but *pedir por* is valid for price, prayer and (Southern Cone) on someone's behalf, so the reading must be checked. |
| *pregunté por* + food, drink or object | *pedí …* | Learner-site summary only (L). |
| *esperar por* + noun | "Common in much of Latin America; general Spanish and formal writing use *esperar* + object" | Kept as a hint, not silence, because there is a sourced norm preference: the DPD prefers transitive *esperar* and Fundéu advises against *esperar por*. Fine for cause or duration: skip the hint when *por* + a time span follows. |
| *vivo aquí por dos años* | *desde hace* / *llevar* | Sourced learner error, but a past or future framing is fine (*viví allí por dos años*, "I lived there for two years"). Needs tense. |
| *estudié para dos horas* | no preposition, or *durante* | *Para* + span may be a deadline. (Never hint on duration *por*: it is accepted.) |
| *salgo por* + city | depends on meaning | Both readings are grammatical (via / bound for). |

*Never flag*
- **The overlap zone:** *por* + infinitive of purpose (*por llegar antes*, "so as to arrive sooner"), and *por / para* + infinitive or *que*-clause
  after effort, desire or benefit predicates (*se esfuerza por / para*, "strains to"; *luchar para sobrevivir*, "fight to survive").
- ***Por* of goal or sake:** *ir por* + noun (*voy por agua*), *luchar / votar / optar / apostar por*, *rezar / pedir por los enfermos* ("pray for
  the sick"), *morir por* ("die for"), *trabajo por* + person ("I work for X's sake").
- **Regional variants:** *ir a por*, *menos cuarto*, *agradecer por*, *estar por* + infinitive, *por mientras*, *para mientras*, *pa'*, duration
  *por*. Tag them by region instead (section 9).
- ***Luchar porque* + subjunctive** and *luchar por que* + subjunctive: the DPD accepts both (section 7).
- ***Por más que* + indicative**, which presents the obstacle as fact (*Por más que lo intenté, no pude*, "try as I might, I couldn't"). A learner
  site (Colanguage) claims it is wrong; that claim is not followed.

**Valid look-alikes every error rule must let through** (S): *te lo pido por favor* ("I'm asking you, please"), *pedir por los enfermos* ("pray for
the sick"), *lo busqué por toda la casa* ("I looked for it all over the house"), *buscar por internet* ("search online"), *esperé para hablar con él*
("I waited to speak to him"). So each error rule must require the preposition to sit right after the verb and introduce its object, and must
exclude *por favor*, place and means nouns, and *para* + infinitive.

No precision or recall figures exist for Spanish *por/para* error detection, and no English-L1 error study on CEDEL2 or CAES was found. Tune the
patterns on real learner text before shipping.

## 11. Verification queue

These are standard in reference grammars but appear in no fetched source (RK), or the sources conflict. **They should not ship as checker rules**
until checked against B&B §34.14 / §34.14.8, the NGLE or the DPD. They are safe as Learn content only after that check.

| Item | Expected value |
|---|---|
| *quedar por* + inf. | *Quedan tres capítulos por leer* ("there are three chapters left to read"); parallels DPD "still to be done" *estar por* |
| Multiplication | *dos por tres son seis* ("two times three is six") |
| Negative cause | *por no estudiar* ("through not studying") |
| Unexpected result | *salió para no volver* ("he left, never to return"); NGLE §46 not checked |
| *dar por* + participle or adjective | *lo dieron por muerto* ("they gave him up for dead"); *lo doy por hecho* ("I take it as done") |
| Agent with *de* | *conocido de todos* ("known to everyone"); *rodeado de amigos* ("surrounded by friends") |
| *por* vs *durante* by region | *durante* as neutral "for"; duration *por* more American; *durante* or nothing in Spain |
| Time and place adverbs | *para entonces* ("by then"); *para allá* ("that way", direction) vs *por allá* ("around there"); *por abril* ("around April") |
| Other regimes | *disculparse por* ("apologise for"), *felicitar a alguien por algo* ("congratulate someone on something"), *interesarse por* ("take an interest in"); *prepararse para* ("prepare for"), *alcanzar para* ("be enough for"), *bastar para* ("suffice for"); *responsable de / por* ("responsible for"); *votar a* + candidate ("vote for", Spain) |
| *estar para* idiom | *no estoy para bromas* ("I'm not in the mood for jokes") |
| ***estar por* "only with *caer* / *llegar*"** | The notes disagree: one DPD snippet says Spain allows "about to" *estar por* only with *caer* and *llegar*; the other attaches that limit to *estar al* + inf. (*está al caer*). Read the DPD *estar* entry in full. |
| *estar por* "inclined to" | *estoy por irme* ("I'm tempted to leave"); only an RILCE mention, no DPD support |
| *ir a por*: exact DPD wording | DPD entry *a*, §2 (cross-referenced from *ir*); current 2nd-edition wording not obtained |
| *por mientras* / *para mientras* by country | full text of del Barrio de la Rosa 2026 (only the abstract was seen) |
| Unchecked pairs | *hablo por / para ella*, *lo cambié por / para otro*, *vino por / para el libro*, *estudia para médico* |
| Colombian features | *cuarto para las* in Colombia; *estar por*, *pa'*, duration *por* in Colombia; *mandar por* ("send for"); *de a poquito* ("little by little") and *de a uno* ("one at a time") as general Latin American *de a* |
| Unsourced fixed phrases | *por cierto, por lo visto, por completo, por si las moscas, para siempre, para nada, para variar, no es para tanto, para que sepas, para mí que* |
| Branch 2 membership | desire and contest nouns (*afán por*, *ansioso por*, *la carrera por*) beyond the NGLE-named verbs rest on native judgement |
| **No frequency data** | No corpus figure says what share of real *por / para* tokens falls in each branch, the lexicon or the overlap zone, or what the ratio of purpose *por* + inf. to *para* + inf. is today. |

The fastest ways to close the gaps: a library check of B&B §34.14.8 and the DPD entries *estar*, *porque* and *a* §2; a CORPES XXI count of the
branch-2 frames (*ir / venir por* + noun, *luchar / optar / apostar por*, desire nouns + *por*) against branch-1 *para*, and of *esperar por* and
duration *por* by country; a full reading of the 2026 *por mientras* study; the Caro y Cuervo *Diccionario de colombianismos* for Colombia; and a
pass over CEDEL2 English-L1 essays to tune the checker tiers.

## 12. Where it would live in the app

**None of this is built.** No *por/para* code exists today. The only related logic is the subjunctive checker's *para que* rule (section 10). The
homes below are proposals. File names marked "proposed" do not exist. The challenge report suggests three data structures rather than one list: a
three-branch decision tree for explanations, a regime and phrase lexicon for deterministic checks, and an overlap flag on purpose-infinitive slots
that tells the checker to accept both.

| Part | Home | What it would do |
|---|---|---|
| Learn lesson | Learn tab, alongside the mood lessons (`Flasher/Data/MoodMapRules.swift`, `Flasher/Views/MoodMapView.swift` hold the existing ones) | The procedure first (lexicon check, then the three branches), then *para* uses, *por* uses, the minimal pairs (attested pairs first, with *por / para la investigación* as the anchor, and *voy por pan / para casa* for branch 2), the overlap zone, the "for" verbs lesson, and fixed phrases anchored on *por eso / para eso*. Spatial *por* taught deliberately (section 10). Cards as choices between neighbours, like the mood lessons. RK items stay out until checked. |
| Word tags | Dictionary search results and the word page, like the subjunctive trigger tags (`Flasher/Data/MoodTriggers.swift`); data in a proposed `PorParaTags.swift` | The four tags near the top of this file, with a rule and an example for each word. |
| Checker | `Flasher/Data/SpanishRules.swift` / `SpanishChecker.swift`, or a proposed `PorParaRules.swift` called from them | The section 10 error tier only, with the narrow patterns and look-alike exclusions. The suggest tier as non-blocking hints. The never-flag list enforced. Regional forms tagged, not flagged (section 9). |
| Country modes | The existing `Country` setting (`Flasher/Views/SettingsView.swift`), which has Mexico and Colombia only | What to generate and accept per section 9. Colombia uses the American defaults until Colombian sources exist, except *por mientras*, which is now sourced as Colombia's preferred form. There is no Spain mode, so the Spain column says what to accept and tag "Spain", not what to generate. |
