# Mexico rewrites Spain's Spanish, but selectively

The biggest and most reliable differences between Mexican and Spain Spanish are grammatical. Mexico uses **ustedes for every plural "you"** and never vosotros. It uses the **preterite for finished events, including events earlier today** ("hoy comí", "¿ya terminaste?"). It uses **lo, not le, for a male direct object**. A machine translator can apply these three rules almost mechanically. Vocabulary is less simple than learner lists suggest. The verification passes against the *Diccionario del Español de México* (DEM, El Colegio de México) confirmed the Mexican word in nearly every common noun pair. They also found that **about 30 of the roughly 245 "Spain-only" words checked, about one in eight, are in DEM as ordinary words used in Mexico** (nevera, acera, ordenador, ducha, piscina, camarero, pendiente, despacho). Rewriting those words makes the text more natural, but leaving them is not an error. A smaller set of Spain words means something else, or something risky, in Mexico: **coger** (sex), **grifo** (marijuana user), **cerilla** (earwax), **chaqueta** (masturbation, in an idiom), **pajita**, **pinche**, **correrse**. Those are the rewrites that matter most. For register, DEM's labels give a usable ladder. *Popular* words (órale, padre, chamba, lana, neta, chela) are informal but safe. *Groser* words (pedo, pinche, hueva, pendejo, the whole madre family) are for friends only. *Ofensivo* words should never be produced: chingar; **naco**, which DEM defines first as a slur for Indigenous people; and the noun **chale**, a slur for Chinese people. The safe design for the app's Mexico mode is a **three-tier rewrite table** (must rewrite, should rewrite, leave alone), plus a list of words whose rewrite depends on which sense is meant. The final section gives these tables.

Each claim below is tagged by how strong its support is. DEM means the claim was checked against a DEM entry on 2026-11-07; the three DEM verification files override the earlier notes where they disagree. Wiktionary and the ASALE *Diccionario de americanismos* (DAMER) are dictionary-level but secondary. Learner/press means learner sites or newspapers only. Model knowledge means the researchers' own knowledge, with no source opened. The RAE's sites (DLE, DPD) blocked every request, so RAE positions appear only through quoted snippets. DEM gives no frequency data: when it lists a word, that shows the word is used in Mexico, not how often.

## Three grammar rules separate Mexico from Spain more reliably than any word list

**Plural "you" is always ustedes.** The RAE's *Diccionario panhispánico de dudas* says vosotros forms are not used in the Americas, or in Canarias and parts of Andalusia ([RAE DPD, via snippet](https://www.rae.es/dpd/vosotros)). In Mexico they are heard as a Spain form or an archaism ([units.it handout, from es.wikipedia](https://moodle2.units.it/pluginfile.php/760127/mod_resource/content/1/Caracteristicas%20de%20la%20variante%20mexicana%20del%20espanol.docx)). A Spain-style sentence with vosotros is understood but sounds foreign, not wrong. The rewrite has to cover the whole paradigm, or it leaves broken agreement behind:

| Spain form | Mexico form | Example |
|---|---|---|
| 2nd-person plural verb | 3rd-person plural verb | venís → vienen |
| -ad / -aos imperative | -en / -ense imperative | venid → vengan; sentaos → siéntense |
| os | los/las (direct), les (indirect), se (reflexive, or before lo/la) | os quiero → los quiero |
| vuestro/a | su, or "de ustedes" if ambiguous | vuestro coche → su coche |

**Finished events take the preterite, even today's.** Peninsular Spanish uses the present perfect for events earlier today ("esta mañana he comido") and the preterite for earlier days ([Moreno Burgos](https://eriac.univ-rouen.fr/wp-content/uploads/2017/04/10TMAp163MorenoBurgos.pdf)). This varies within Spain: northwest Spain and Canarias prefer the preterite ([Moenia, USC](https://revistas.usc.gal/index.php/moenia/article/view/3137/3503)). The Americas show a **clear predominance of the simple preterite** ([USC Minerva](https://minerva.usc.gal/bitstreams/02bf1d4c-1eb0-437a-9160-b3978c5bc9b5/download)). In Mexico the compound perfect survives for situations still connected to the present: continuing states, experience up to now, and "not yet" ([Henderson 2022, Cuadernos de Lingüística, Colmex](https://cuadernoslinguistica.colmex.mx/index.php/cl/article/download/257/426/2588); [García Fajardo, NRFH](https://www.redalyc.org/pdf/602/60224200002.pdf)). The rewrite rule therefore needs a boundary. Rewrite "hoy he comido" and "¿has terminado ya?" to the preterite. Keep "he vivido aquí diez años", "¿has comido chapulines alguna vez?" and "todavía no he comido". A blanket conversion would break correct Mexican sentences.

**No leísmo.** Spain often says "le vi" for "I saw him", the one leísmo the RAE accepts ([RAE glossary](https://www.rae.es/gtg/le%C3%ADsmo)). American Spanish keeps "lo vi" ([UDEP Castellano Actual](https://www.udep.edu.pe/castellanoactual/se-dice-lo-vi-o-le-vi/)), and Mexico has no leísmo for direct objects ([units.it handout](https://moodle2.units.it/pluginfile.php/760127/mod_resource/content/1/Caracteristicas%20de%20la%20variante%20mexicana%20del%20espanol.docx)). Indirect "le" stays correct ("le di el libro"), so the rule applies only when "le" is the direct object of a verb such as ver, conocer or llamar.

Four narrower features complete the grammar picture. The most dangerous is **"hasta" without "no"**. In Mexico "abren hasta las 10" means **they don't open until 10**, while a Spaniard reads it as "they're open until 10" ([units.it handout](https://moodle2.units.it/pluginfile.php/760127/mod_resource/content/1/Caracteristicas%20de%20la%20variante%20mexicana%20del%20espanol.docx)). Because it misleads in both directions, Mexico mode should turn Spain's "no abren hasta las 10" into "abren a las 10". Mexico says **"¿qué tan…?"** where Spain says "¿cómo de…?", and **"entre más / mientras más"** for "cuanto más" (same source). With plural recipients, Mexicans say **"se los dije"**. Moreno de Alba documented it "in every register and social level" in Mexico, while in Spain it is not said, let alone written ([UDEP quoting Moreno de Alba](https://www.udep.edu.pe/castellanoactual/duda-resuelta-se-los-dijo-o-se-lo-dijo/)). It is still non-normative in writing, so the app should accept it without producing it. The same holds for agreeing **"media cansada"**: common in speech, but the DPD advises against it ([UDEP](https://www.udep.edu.pe/castellanoactual/medio-cansada-y-no-media-cansada/)).

Two widely cited "Mexicanisms" should stay out of generated text. **Ocupar = necesitar** is northern, strongest around Monterrey, and the Academia Mexicana de la Lengua discourages it as ambiguous ([Tovilla-Loza 2021](https://septentrio.uit.no/index.php/borealis/article/view/6627)). **Aplicar a un puesto** is an anglicism that DEM does not record and style authorities reject ([SEA terminology bulletin](https://www.sea-astronomia.es/sites/default/files/2024_12.pdf)).

## Mexican courtesy habits soften what Spain says directly

Several Mexican usage habits turn Spain's direct style into softer requests and replies. The best documented is **ahorita**. DEM gives it three senses: right now, in a little while, and whenever possible ([DEM ahorita](https://dem.colmex.mx/ver/ahorita)). Colmex lexicographer Luis Fernando Lara explains it as a politeness device: a bare "hazlo ahora" sounds brusque in Mexico, so "ahorita" agrees without committing to a time ([BBC Mundo via Prensa Libre](https://www.prensalibre.com/?p=9801363)). Its non-immediate uses are spreading among young Mexico City speakers ([Granados 2021](https://cuadernoslinguistica.colmex.mx/index.php/cl/article/view/202)). **¡Mande!** is DEM's "courtesy expression" for answering someone who calls you or asking them to repeat, where Spain says ¿qué?, ¿cómo? or dime ([DEM mande](https://dem.colmex.mx/ver/mande)). **¡Bueno!** answers the phone and is unmarked in DEM, unlike Spain's ¿diga? ([DEM bueno](https://dem.colmex.mx/ver/bueno)). Much of Mexico adds an intensifying **-le to imperatives** ("córrele, que se va el camión", "muévanle bien a la harina"); ándale is the model ([units.it handout](https://moodle2.units.it/pluginfile.php/760127/mod_resource/content/1/Caracteristicas%20de%20la%20variante%20mexicana%20del%20espanol.docx)). The same handout notes **article habits**: "me salí de la casa" where Spain says "me fui de casa", and dropping the indefinite article in "es ladrona".

Several discourse markers belong in informal Mexico-mode output: **nomás** = "just, only" ([DEM nomás](https://dem.colmex.mx/ver/nom%C3%A1s)), **luego luego** = "right away" ([DEM luego](https://dem.colmex.mx/ver/luego)), **¿a poco?** for surprise or doubt ([DEM poco](https://dem.colmex.mx/ver/poco)) and **se me hace que** = "I reckon" ([DEM hacer](https://dem.colmex.mx/ver/hacer)).

One habit needs correcting. **¿Me regalas…?** ("can I have…?") is often taught as Mexican, but DAMER records that request sense only for Guatemala and central Colombia, with **no Mexico sense** ([DAMER regalar](https://www.asale.org/damer/regalar)). It should not be presented as a defining Mexicanism.

Other courtesy habits rest on **model knowledge only**. Mexicans order with "¿me da…?" or "¿me puede traer…?" where Spain's "ponme una caña" can sound abrupt. They say *con permiso* when passing someone and *provecho* to people eating, strangers included. They use diminutives such as un cafecito and un momentito heavily, and use usted more with strangers and service staff. These patterns are widely reported but unsourced here, so the app should present them as cultural tips, not rewrite rules.

## Nouns split into three strength tiers, and learner lists overstate the gap

Nearly every common pair checked against DEM confirmed the Mexican side. The exceptions were a few slang or brand clippings DEM does not list: refri, compu, depa, jocho, lavatrastes, chequera, cotonete, and INE as a noun. A few phrases were also missing, such as "papel de baño" and "licencia de manejo". The weak point of the learner lists is the other column, which says whether the Spain word exists in Mexico. DEM shows three different situations, and they map onto three rewrite strengths:

| Tier | What DEM shows about the Spain word | Examples | What the app should do |
|---|---|---|---|
| **1. Must rewrite** | Absent, has another meaning, or is risky | zumo (citrus-peel liquid only), móvil (no phone sense), grifo (*Popular*: marijuana user), cerilla (earwax), bombilla (lamp chimney or mate straw), mechero (Bunsen burner), frigorífico (industrial cold store), rotonda (circular monument), jersey (knit fabric), tiza (tailor's chalk), percha (bird perch), folio (numbered book leaf), maletero, capó, aparcamiento, calabacín, pomelo, moqueta | Always rewrite |
| **2. Should rewrite** | Listed with no label, defined by the Mexican word | nevera = refrigerador, acera = banqueta, ordenador = computadora, ducha = regadera, piscina = alberca, chupete = chupón, camarero = mesero, pizarra = pizarrón, cometa (f) = papalote, pendiente (n) = arete, sujetador = brassier, escaparate = aparador, gamba = camarón, patata = papa | Rewrite for naturalness; don't mark a learner wrong |
| **3. Leave alone** | Its own ordinary entry with the same meaning | coche, despacho, papel higiénico, chisme (both senses), sofá, lavabo, aula, camping, smoking, spot, tupper, ticket | Do not rewrite |

Sources for the table: [nevera](https://dem.colmex.mx/ver/nevera), [acera](https://dem.colmex.mx/ver/acera), [ordenador](https://dem.colmex.mx/ver/ordenador), [ducha](https://dem.colmex.mx/ver/ducha), [piscina](https://dem.colmex.mx/ver/piscina), [grifo](https://dem.colmex.mx/ver/grifo), [cerilla](https://dem.colmex.mx/ver/cerilla), [bombilla](https://dem.colmex.mx/ver/bombilla), [rotonda](https://dem.colmex.mx/ver/rotonda).

The verification passes reversed several claims in the earlier notes, and the reversals affect the app directly. **Manta does mean blanket** in Mexico (DEM sense 2), alongside the everyday cobija ([DEM manta](https://dem.colmex.mx/ver/manta)). **Pendiente** as a noun means arete ([DEM pendiente](https://dem.colmex.mx/ver/pendiente)). **Chisme** keeps both "gossip" and "thingamajig" ([DEM chisme](https://dem.colmex.mx/ver/chisme)). **Cola** works for "hacer cola", though it also has a *Popular* sense (buttocks) and an *Ofensivo y Popular* one (young woman) ([DEM cola](https://dem.colmex.mx/ver/cola)). **Bizcocho** in Mexico is pan dulce, not sponge cake, and *Popular* for an attractive person ([DEM bizcocho](https://dem.colmex.mx/ver/bizcocho)). **Polo** has no ice-pop sense ([DEM polo](https://dem.colmex.mx/ver/polo)). **Despacho** is ordinary for a professional's office, as in *despacho de abogados* ([DEM despacho](https://dem.colmex.mx/ver/despacho)).

Several "Mexican" targets in the earlier notes are wrong or unsupported. **Cisterna → tanque** fails: tanque has no toilet sense in DEM, and cisterna is a building's underground water tank ([DEM tanque](https://dem.colmex.mx/ver/tanque); [DEM cisterna](https://dem.colmex.mx/ver/cisterna)). For compresa, DEM gives **toalla sanitaria / higiénica**, not "toalla femenina" ([DEM toalla](https://dem.colmex.mx/ver/toalla)). Lipstick is **lápiz labial**; bare "labial" is only an adjective in DEM ([DEM labial](https://dem.colmex.mx/ver/labial)). **Cotonete** is not in DEM, which gives **hisopo** for a cotton swab ([DEM hisopo](https://dem.colmex.mx/ver/hisopo)). **Troca** is northern and means a cargo truck, not an SUV ([DEM troca](https://dem.colmex.mx/ver/troca)). For junk, DEM has **trique** with the example "el cuarto de los triques" ([DEM trique](https://dem.colmex.mx/ver/trique)), so the only error was "el triques" with a singular article. Spain's leisure anglicisms mostly exist in Mexico too (camping, smoking, spot, tupper), so the claim that Spain borrows where Mexico stays native is largely overstated ([DEM camping](https://dem.colmex.mx/ver/camping); [DEM tupper](https://dem.colmex.mx/ver/tupper)).

Gender and spelling matter for an app that shows articles. DEM confirms **la laptop** ([DEM](https://dem.colmex.mx/ver/laptop)), **la pijama / la piyama** ([DEM](https://dem.colmex.mx/ver/pijama)) and **los lentes** ([DEM](https://dem.colmex.mx/ver/lente)). **Sartén** is "s m o f", and Mexican examples use "un sartén" ([DEM](https://dem.colmex.mx/ver/sartén)). **Curita** is also both genders ([DEM](https://dem.colmex.mx/ver/curita)). The police force is **la tira**, and one officer is **un/una tira** (Caló) ([DEM](https://dem.colmex.mx/ver/tira)). **Los pants**, **el/los tianguis** and **los abarrotes** are plural.

DEM's headword spellings are **diesel** (no accent), **brassier** (also brasier), **durex®** (also diurex), **bóiler**, **interfono** (also interfón), **garage** (also garaje) and **video** ([DEM diesel](https://dem.colmex.mx/ver/diesel); [DEM brasier](https://dem.colmex.mx/ver/brasier); [DEM diurex](https://dem.colmex.mx/ver/diurex)).

The article often flips across a pair (el ordenador → la computadora, el maletero → la cajuela, la bombilla → el foco, la pajita → el popote), so the app should show it on both sides.

Some popular pairs are really the same word with a narrower meaning. **Camión** in Mexico covers both bus and truck ([DEM camión](https://dem.colmex.mx/ver/camión)), and **autobús** stays normal for intercity coaches ([DEM autobús](https://dem.colmex.mx/ver/autobús)). **Maíz** is the standard word for the plant and grain, while **elote** is the tender ear eaten as food ([DEM elote](https://dem.colmex.mx/ver/elote)). DEM's first sense of **tomate** is the green husked tomatillo; its third equals **jitomate**, the central-Mexican word for the red fruit ([DEM tomate](https://dem.colmex.mx/ver/tomate); [DEM jitomate](https://dem.colmex.mx/ver/jitomate)). Rewriting Spain's tomate as jitomate is therefore a central-Mexico preference, not a correction.

## Mexican verbs differ mostly by preference, with a few dangerous exceptions

The verb contrasts most visible in everyday speech are below. DEM confirms the Mexican side of each.

| Spain | Mexico | Evidence |
|---|---|---|
| conducir | **manejar** | DEM's conducir has no driving sense ([DEM manejar](https://dem.colmex.mx/ver/manejar); [DEM conducir](https://dem.colmex.mx/ver/conducir)) |
| echar de menos | **extrañar** | [DEM extrañar](https://dem.colmex.mx/ver/extrañar) |
| alquilar | **rentar** | [DEM rentar](https://dem.colmex.mx/ver/rentar) |
| charlar | **platicar** | DEM defines charlar through platicar ([DEM platicar](https://dem.colmex.mx/ver/platicar)) |
| tirar de | **jalar** | [DEM jalar](https://dem.colmex.mx/ver/jalar) |
| lanzar | **aventar** | [DEM aventar](https://dem.colmex.mx/ver/aventar) |
| enfadarse | **enojarse** | [DEM enojarse](https://dem.colmex.mx/ver/enojarse) |
| aparcar | **estacionar** | DEM's aparcar only redirects ([DEM estacionar](https://dem.colmex.mx/ver/estacionar)) |
| darse prisa | **apurarse** | [DEM apurarse](https://dem.colmex.mx/ver/apurarse) |
| ponerse de pie | **pararse** | [DEM pararse](https://dem.colmex.mx/ver/pararse) |
| encender | **prender** | [DEM prender](https://dem.colmex.mx/ver/prender) |
| adelantar | **rebasar** | road signs say "No rebase" ([DEM rebasar](https://dem.colmex.mx/ver/rebasar)) |
| suspender (exam) | **reprobar** | DEM's suspender has no exam sense ([DEM reprobar](https://dem.colmex.mx/ver/reprobar)) |
| pinchar (tyre) | **ponchar** | [DEM ponchar](https://dem.colmex.mx/ver/ponchar) |
| afeitarse | **rasurarse** | [DEM rasurar](https://dem.colmex.mx/ver/rasurar) |
| estropearse | **descomponerse** | [DEM descomponer](https://dem.colmex.mx/ver/descomponer) |
| atascarse | **atorarse** | [DEM atorar](https://dem.colmex.mx/ver/atorar) |
| atar | **amarrar** | [DEM amarrar](https://dem.colmex.mx/ver/amarrar) |
| hacerse daño | **lastimarse** | [DEM lastimar](https://dem.colmex.mx/ver/lastimar) |
| ponerse enfermo | **enfermarse** | [DEM enfermar](https://dem.colmex.mx/ver/enfermar) |

Several Spain verbs are missing from DEM entirely: **currar**, **cabrear**, **chequear**, and **molar** as a verb (DEM has only the noun, a molar tooth). Their Mexican counterparts are trabajar (or *Popular* chambear, [DEM chambear](https://dem.colmex.mx/ver/chambear)), enojarse, and gustar. For chequear, Mexico says **checar**, an unlabelled, fully normal verb that also means "clock in" (*checar tarjeta*) ([DEM checar](https://dem.colmex.mx/ver/checar)).

**Jalar** is the most productive Mexican verb: pull, work or have a job, function ("todavía jala"), join in, head somewhere, and flush ("jalarle al baño"). The *Groser* *jalársela* means to masturbate ([DEM jalar](https://dem.colmex.mx/ver/jalar)).

Mexico also prefers pronominal and prepositional variants, as in "no te tardes" ([DEM tardar](https://dem.colmex.mx/ver/tardar)), "echarle ganas" ([DEM gana](https://dem.colmex.mx/ver/gana)), and "quedar **de** vernos" alongside "quedar en" ([DEM quedar](https://dem.colmex.mx/ver/quedar)).

The verb traps are where a Spain-style translation does real damage.

**Coger** keeps its neutral senses in DEM but has *Groser* and *Popular* sexual senses ("¿Vamos a coger?"), and even "coger el autobús" is labelled *Popular* ([DEM coger](https://dem.colmex.mx/ver/coger)). Every coger in a Spain translation should become **agarrar** or **tomar**.

**Correrse and venirse** swap danger. In Mexico, *venirse* is the *Groser* word for orgasm ([DEM venir](https://dem.colmex.mx/ver/venirse)), while *correrse* is what ink does, and *correr* also means "to fire someone" ([DEM correr](https://dem.colmex.mx/ver/correr)).

**Pararse** means chiefly "to stand up" in Mexico, and *parársele* (*Popular*) means to get an erection ([DEM pararse](https://dem.colmex.mx/ver/pararse)).

**Pelar**: *Popular* "no me pela" means "pays me no attention" in Mexico ([DEM pelar](https://dem.colmex.mx/ver/pelar)). In Spain, vulgar "me la pela" means "I don't give a damn" ([Wiktionary pelar](https://en.wiktionary.org/wiki/pelar#Spanish)).

**Fregar** adds a *Popular* "annoy, ruin" sense ("¡no la friegues!") to washing dishes ([DEM fregar](https://dem.colmex.mx/ver/fregar)).

**Chupar** commonly means to drink alcohol ([DEM chupar](https://dem.colmex.mx/ver/chupar)).

**Mamar** is *Groser* (get drunk; oral sex), and its negative is the root of *no mames* ([DEM mamar](https://dem.colmex.mx/ver/mamar)).

**Dar pena** means "to embarrass" in Mexico ([DEM apenar](https://dem.colmex.mx/ver/apenar)), so a Spaniard's "me da pena" ("I feel sorry") can be misread.

Two common warnings are myths. *Pisar*'s sexual sense is labelled for Cuba, El Salvador and the Dominican Republic, not Mexico ([Wiktionary pisar](https://en.wiktionary.org/wiki/pisar#Spanish)). *Pinchar* is not vulgar in Mexico; Mexicans simply say ponchar.

## DEM's register labels turn Mexican slang into a safety ladder

DEM marks most Mexican slang *(Popular)*: informal but not coarse. Greetings and reactions in this tier include **¡qué onda!**, with buena/mala onda, sacar de onda and tirar la onda ([DEM onda](https://dem.colmex.mx/ver/onda)), **¡órale!** ([DEM](https://dem.colmex.mx/ver/órale)), **¡ándale!** ([DEM](https://dem.colmex.mx/ver/ándale)), **¡híjole!** ([DEM](https://dem.colmex.mx/ver/híjole)), **neta** ([DEM](https://dem.colmex.mx/ver/neta)), **¡aguas!** ([DEM](https://dem.colmex.mx/ver/aguas)) and **padre** = great ([DEM](https://dem.colmex.mx/ver/padre)). Everyday nouns include **chamba** ([DEM](https://dem.colmex.mx/ver/chamba)), **lana** ([DEM](https://dem.colmex.mx/ver/lana)), **varo** ([DEM](https://dem.colmex.mx/ver/varo)) and **chela** ([DEM](https://dem.colmex.mx/ver/chela)). People words include **cuate** ([DEM](https://dem.colmex.mx/ver/cuate)), **carnal** ([DEM](https://dem.colmex.mx/ver/carnal)), **chavo** ([DEM](https://dem.colmex.mx/ver/chavo)), **chamaco** ([DEM](https://dem.colmex.mx/ver/chamaco)), **jefe/jefa** for one's parents ([DEM](https://dem.colmex.mx/ver/jefa)) and **fresa**, Spain's pijo ([DEM](https://dem.colmex.mx/ver/fresa)). Set phrases include **hacer el oso** ([DEM](https://dem.colmex.mx/ver/oso)), **desmadre** ([DEM](https://dem.colmex.mx/ver/desmadre)), **¡está cañón!** ([DEM](https://dem.colmex.mx/ver/cañón)), **estar hasta el gorro** ([DEM](https://dem.colmex.mx/ver/gorro)), **pedir un aventón** ([DEM](https://dem.colmex.mx/ver/aventón)) and **echar los perros** = flirt ([DEM perro](https://dem.colmex.mx/ver/perro)). DAMER marks **chido** Mexico-only and *pop.* ([DAMER chido](https://www.asale.org/damer/chido)), and **cruda** (hangover) *pop.* ([DAMER cruda](https://www.asale.org/damer/cruda)).

A few items carry no label at all, so they are neutral: ¡mande!, ¡bueno! on the phone, **de pilón** (a bit extra, thrown in free) ([DEM pilón](https://dem.colmex.mx/ver/pilón)), **dar lata** ([DEM lata](https://dem.colmex.mx/ver/lata)), **güero** (also a vendor's friendly "¡pásele, güero!") ([DEM güero](https://dem.colmex.mx/ver/güero)), cachucha and mecate.

The *Groser* tier is narrower than learners fear but broader than young speakers assume. It covers:
- **pedo** and all its phrases (qué pedo, no hay pedo, ni pedo, andar pedo, peda) ([DEM pedo](https://dem.colmex.mx/ver/pedo))
- **pinche** ([DEM](https://dem.colmex.mx/ver/pinche))
- **hueva** ([DEM](https://dem.colmex.mx/ver/hueva))
- **pendejo**, labelled *Groser* only, not *Ofensivo*, though still the strongest common insult ([DEM](https://dem.colmex.mx/ver/pendejo))
- **buey** = stupid or cuckold ([DEM](https://dem.colmex.mx/ver/buey))
- **encabronarse** ([DEM](https://dem.colmex.mx/ver/encabronar))
- all of section IV of **madre**, including the positive *a toda madre* and the shrugging *me vale madre(s)* ([DEM madre](https://dem.colmex.mx/ver/madre))
- **no mames**, through DAMER's *vulg.* label on Mexican *mamar* = exaggerate ([DAMER mamar](https://www.asale.org/damer/mamar))

**Desmadre** and **chingón** are only *Popular* in DEM, though their roots make them feel coarser in practice.

At the top sit **chingar** ([DEM](https://dem.colmex.mx/ver/chingar)), **a la chingada** ([DEM](https://dem.colmex.mx/ver/chingada)) and **culo** ([DEM](https://dem.colmex.mx/ver/culo)), all *Groser y Ofensivo*.

Three slurs need explicit warnings. **Naco** is *Popular y Ofensivo*: its first sense is "Indigenous person", with "ignorant" and "tacky" after it ([DEM naco](https://dem.colmex.mx/ver/naco)). Learner glosses of "tacky" hide an ethnic slur. **Chale** the interjection (= "darn") is harmless *Popular*, but a separate noun *chale* is a *Popular y Ofensivo* slur for a Chinese person ([DEM chale](https://dem.colmex.mx/ver/chale)). **Güey** is a *Popular* address term among young people, but *Ofensivo* in its "despised stranger" and "fool" senses ([DEM güey](https://dem.colmex.mx/ver/güey)). The same word is friendly between peers and insulting to a stranger.

Several famous items have weaker support than their fame suggests. **¡No manches!** has no sense in DEM's *manchar* entry ([DEM manchar](https://dem.colmex.mx/ver/manchar)). Only learner sources gloss it, as the mild euphemism for no mames ([Mexico News Daily](https://mexiconewsdaily.com/?p=357505)). **Sale** (= OK) rests only on Wiktionary's Mexico label ([Wiktionary sale](https://en.wiktionary.org/wiki/sale)). **Va** (= OK) is labelled for **both Mexico and Spain**, so it is not a Mexicanism ([Wiktionary va](https://en.wiktionary.org/wiki/va)). The greeting is spelled **¿qué transa?**, not "tranza" ([DEM transa](https://dem.colmex.mx/ver/transa)).

These items are model knowledge only and need a lower confidence flag:
- ¿qué hongo? and ¿quiubo?
- simón / nel
- ¡no inventes! and ¡sobres!
- codo (stingy), chafa (cheap), mordida (bribe), reventón (party)
- the softened substitutes: me vale gorro/queso, no hay bronca, qué flojera
- the claim that *poca madre* is turning positive

On the Spain side, Wiktionary confirms the items the app must recognize and rewrite: **tío/tía** = guy/girl ([Wiktionary](https://en.wiktionary.org/wiki/tío)), **guay** ([Wiktionary](https://en.wiktionary.org/wiki/guay)), **molar** ([Wiktionary](https://en.wiktionary.org/wiki/molar)), **vale** ([Wiktionary](https://en.wiktionary.org/wiki/vale)), **en plan** ([Wiktionary](https://en.wiktionary.org/wiki/en_plan)), **ser la leche** ([Wiktionary](https://en.wiktionary.org/wiki/ser_la_leche)), **enchufe** = connections ([Wiktionary](https://en.wiktionary.org/wiki/enchufe)) and **pijo**, which also has a vulgar "penis" sense ([Wiktionary](https://en.wiktionary.org/wiki/pijo)). A learner source reports that guay sounds odd to Mexicans ([StreetTongue](https://streettongue-website.pages.dev/mexican-spanish-vs-spain-spanish)). In Mexico, tío means only uncle.

## Mexicans pick their own idiom over the shared one by large margins

A 2019 El Colegio de México study produced the only hard preference figures in this research. It tested competing idiom variants with a questionnaire built from real tweets, cross-checked against dictionaries and corpora ([Fajardo Rojas 2019](https://linguisticamexicana-amla.colmex.mx/index.php/Linguistica_mexicana/article/download/324/328/1203)).

| Idiom | Meaning | Preference |
|---|---|---|
| **ser uña y mugre** | be inseparable | 95.4%, vs **4.6%** for the pan-Hispanic *uña y carne* |
| **aguantar vara** | tough it out | 89%, ahead of *aguantar mecha* (also in the DLE) |
| **botársele la canica** | go crazy | 94.6% |
| **ponerse trucha** | look sharp | 91%; *ponerse chango* is in three dictionaries but got 2% |
| haber gato encerrado | something's fishy | 97.8%; shared with Spain |
| tapar el sol con un dedo | hide the obvious | 97.4%; shared with Spain |

When a Mexican variant competes with a shared form, Mexicans overwhelmingly choose their own. Being in a dictionary is also a poor sign that an idiom is still current.

Food and nature mark Mexican idioms most clearly, and they have no peninsular counterparts. Mexico News Daily documents, with examples:
- **no se puede chiflar y comer pinole** ("you can't do two things at once")
- **sale más caro el caldo que las albóndigas** ("the fix costs more than it's worth")
- **echarle mucha crema a los tacos** ("exaggerate")
- **regar el tepache** ("spill a secret")
- **ser el ajonjolí de todos los moles** ("have a finger in every pie")
- **del año del caldo** ("ancient")

([Mexico News Daily](https://mexiconewsdaily.com/culture/mx-expressions-inspired-by-dinner-table)). Speaking Latino adds **dar atole con el dedo** ("fob someone off"), **no son enchiladas** ("it's not easy"), **ni maíz** ("no way") and **de lengua me como un taco** ("yeah, right") ([Speaking Latino](https://www.speakinglatino.com/mexican-spanish-phrases/)). UnoTV lists **hacerse guaje** ("play dumb"), **estar más verde que un aguacate** ("very inexperienced"), **me importa un cacahuate** ("I don't care") and **me lleva la tostada** (annoyance) ([UnoTV](https://www.unotv.com/cultura/mejores-frases-con-frutas-y-verduras-que-usan-los-mexicanos-en-su-vocabulario/)). Inklingo tags **caerle el veinte** ("finally get it"), **echar carrilla** ("tease") and **hazme el paro** ("do me a favour") as Mexico-specific, and *flipar en colores*, *estar al loro* and *ser la leche* as Spain-specific ([Inklingo](https://www.inklingo.app/spanish/idioms/category/mexico)). **Dar el avión** ("brush someone off") and **se me fue el avión** ("I lost my train of thought") complete the core set ([Mexico News Daily](https://mexiconewsdaily.com/mexico-living/mexican-expressions-for-your-real-and-figurative-travels)).

DEM confirms **echarle ganas** ([DEM gana](https://dem.colmex.mx/ver/gana)), **quedarse de a seis** ("be stunned") ([DEM quedar](https://dem.colmex.mx/ver/quedar)), **estar en la luna** ([DEM luna](https://dem.colmex.mx/ver/luna)) and **la coperacha** ("pooled money") ([DEM coperacha](https://dem.colmex.mx/ver/coperacha)). It also narrows two idioms. **Valer gorro** means only "matter very little"; the "be ruined" sense (*ya valió*) belongs to *valer madre*. **Estar hasta el gorro** can also mean "very drunk or high" ([DEM gorro](https://dem.colmex.mx/ver/gorro)). **Leche** is a true false friend: *Popular* "¡qué leche tienes!" means "how lucky you are" in Mexico ([DEM leche](https://dem.colmex.mx/ver/leche)), while Spain's *ser la leche* means "to be amazing".

Shared refranes often take Mexican wording: *a falta de pan, tortillas* (Spain: *buenas son tortas*) and *a todo puerquito le llega su San Martín* ([TV Azteca](https://www.tvazteca.com/aztecauno/especiales-azteca/lista-38-refranes-y-dichos-mexicanos-que-todos-deberian-tener-a-la-mano)), and *a caballo regalado no se le ve colmillo* (Spain: *no le mires el diente*) ([Inklingo](https://www.inklingo.app/spanish/idioms/category/mexico)). *No hay mal que por bien no venga* is pan-Hispanic ([Wiktionary](https://en.wiktionary.org/wiki/no_hay_mal_que_por_bien_no_venga)).

Three well-known refranes rest only on press sources: **al nopal sólo se le arriman cuando tiene tunas** ([Chilango](https://www.chilango.com/agenda/otros/conoce-el-significado-detras-de-estos-refranes-chilangos/)), **el que es perico donde quiera es verde** ([USC Folklore Archive](https://folklore.usc.edu/?p=43112)) and **a darle que es mole de olla** ([El Imparcial](https://www.elimparcial.com/locurioso/2026/08/05/que-significa-en-mexico-el-refran-a-darle-que-es-mole-de-olla-y-cual-es-su-historia/)). **Hacer la vaquita** ("chip in") appears only in a learner source ([Speaking Latino](https://www.speakinglatino.com/word/hacer-una-vaquita)).

Two kinds of saying need care in learning material. **El que no transa no avanza** is studied as a corruption refrán and is used ironically, as social critique, not as advice ([Redalyc](https://www.redalyc.org/pdf/137/13718501002.pdf)). Sayings with ethnic content, such as *cuando el tecolote canta, el indio muere*, should be left out ([TV Azteca](https://www.tvazteca.com/aztecauno/especiales-azteca/lista-38-refranes-y-dichos-mexicanos-que-todos-deberian-tener-a-la-mano)).

## The trap list: innocent in one country, loaded in the other

The table ranks the words a Spain speaker, or a translator trained on Spain Spanish, is most likely to get wrong in Mexico.

| Word | Spain sense | Mexico sense | Risk | Evidence |
|---|---|---|---|---|
| coger | take, catch | *Groser* / *Popular*: have sex | High | [DEM](https://dem.colmex.mx/ver/coger) |
| chaqueta | jacket | jacket, but *Popular* "hacerse una chaqueta" = masturbate; everyday word is chamarra | High | [DEM](https://dem.colmex.mx/ver/chaqueta) |
| correrse | orgasm (coarse) | ink running; the MX coarse word is *venirse* (*Groser*) | High, both ways | [DEM venir](https://dem.colmex.mx/ver/venirse) |
| pinche | kitchen helper | *Groser*: lousy, contemptible | High | [DEM](https://dem.colmex.mx/ver/pinche) |
| madre (in idioms) | mother | the *Groser* madre family; say *mamá* for one's mother | Medium | [DEM](https://dem.colmex.mx/ver/madre) |
| culo | bum (coarse) | *Groser y Ofensivo*; say pompas or nalgas | Medium | [DEM](https://dem.colmex.mx/ver/culo) |
| grifo | tap | curly hair; *Popular*: marijuana user | Medium | [DEM](https://dem.colmex.mx/ver/grifo) |
| cerilla | match | earwax | Medium (comic) | [DEM](https://dem.colmex.mx/ver/cerilla) |
| pararse | stop | chiefly stand up; *parársele* = erection | Medium | [DEM](https://dem.colmex.mx/ver/pararse) |
| pajita | straw | avoided; Mexico says popote | Low–medium | [DEM popote](https://dem.colmex.mx/ver/popote) |
| cola | queue, tail | also *Popular* buttocks; *Ofensivo y Popular* young woman | Low–medium | [DEM](https://dem.colmex.mx/ver/cola) |
| torta | flat cake; slap | sandwich; *Popular* girlfriend | Low | [DEM](https://dem.colmex.mx/ver/torta) |
| dar pena | feel sorry | be embarrassed | Low (meaning) | [DEM apenar](https://dem.colmex.mx/ver/apenar) |
| hasta (no negation) | until | not until | Low, but misleading | [units.it](https://moodle2.units.it/pluginfile.php/760127/mod_resource/content/1/Caracteristicas%20de%20la%20variante%20mexicana%20del%20espanol.docx) |
| leche | *ser la leche* = amazing | *qué leche* = what luck | Low | [DEM](https://dem.colmex.mx/ver/leche) |
| paro | unemployment | stoppage or strike; *hacer el paro* = help | Low | [DEM](https://dem.colmex.mx/ver/paro) |

Some neutral Mexican food and household words hide coarse senses a learner should know: **chile** (*Popular* = penis) ([DEM](https://dem.colmex.mx/ver/chile)), **tortilla** (*Ofensivo* idioms about lesbian sex) ([DEM](https://dem.colmex.mx/ver/tortilla)), **chesco** (an oral-sex idiom) ([DEM](https://dem.colmex.mx/ver/chesco)) and **sartén** (a *Caló* sense) ([DEM](https://dem.colmex.mx/ver/sartén)).

Two warnings repeated on learner sites are wrong for Mexico. **Concha** means shell and sweet bread there; its vulgar sense belongs to the Southern Cone ([DEM concha](https://dem.colmex.mx/ver/concha)). **Bicho** means a bug, or *Popular* a cat ([DEM bicho](https://dem.colmex.mx/ver/bicho)). That **mariquita** is a slur in Mexico is model knowledge only. DEM has no headword for it, so the app should simply use **catarina** ([DEM catarina](https://dem.colmex.mx/ver/catarina)).

## Rewrite tables for the app's Mexico mode

No independent benchmark of Apple or Google output by Spanish variety was found. A 2025 MT Summit proposal to adapt generic machine translation into Mexican and Argentine Spanish implies that baseline output is not variety-specific ([MT Summit 2025, snippet](https://preview.aclanthology.org/mtsummit-25-ingestion/2025.mtsummit-2.7.pdf)). The tables below are built from the evidence above and include only DEM-level rows, except where a row's note says otherwise.

Three engineering rules follow from the data:
- **Rewrite in a single pass.** Otherwise *neumático → llanta* gets rewritten again by *llanta (rim) → rin*.
- **Handle sense-dependent words with context rules.** A plain string replacement turns *piso* "floor" and *billete* "banknote" into nonsense.
- **Preserve register.** A Spain colloquialism may map to a Mexican *Popular* word (guay → padre), but neutral text never gains slang.

### Grammar rewrites (high confidence)

| Spain-style output | Mexico rewrite | Boundary |
|---|---|---|
| ¿Vosotros venís? · Venid · Sentaos · Os quiero · vuestro libro | ¿Ustedes vienen? · Vengan · Siéntense · Los/Las quiero · su libro (de ustedes) | Always; rewrite the whole paradigm |
| Hoy he comido pollo · ¿Has terminado ya? · Esta mañana he visto a Ana | Hoy comí pollo · ¿Ya terminaste? · Esta mañana vi a Ana | Finished events only. Keep the perfect for experience ("¿has ido a Oaxaca?"), continuing states ("he vivido aquí") and "todavía no he…" |
| Le vi ayer (a Juan) · Le conozco | Lo vi ayer · Lo conozco | Only when le is a masculine direct object |
| ¿Cómo de lejos está? | ¿Qué tan lejos está? | Always |
| Cuanto más estudias, más sabes | Mientras más estudias… / Entre más estudias… | Always (entre más is informal) |
| No abren hasta las 10 | Abren a las 10 | Avoids Mexican "hasta" ambiguity |
| ¿Diga? / ¿Dígame? (phone) | ¿Bueno? | Phone dialogue only |
| ¿Qué? (when called by someone) | ¿Mande? | Replying to being called |
| Me parece que va a llover | Se me hace que va a llover | Informal register only (*Popular*) |
| Ahora vuelvo | Ahorita regreso / Ahorita vengo | Informal |
| Solo quería saludar | Nomás quería saludar | Informal only |
| Os lo dije (to several people) | Se lo dije (output); accept "se los dije" in input | "Se los" is spoken Mexican but non-normative in writing |

### Noun rewrites (articles shown)

| Spain | Mexico | Strength | Note |
|---|---|---|---|
| el zumo | el jugo | Must | zumo = citrus-peel liquid in MX |
| la patata | la papa | Should | patata redirects to papa |
| el melocotón | el durazno | Must | DEM: a variety not grown in Mexico |
| el albaricoque | el chabacano | Should | |
| el cacahuete | el cacahuate | Must | |
| el guisante | el chícharo | Should | |
| la judía verde | el ejote | Must | |
| la judía (bean) | el frijol | Must | alubia is in DEM; leave it |
| el calabacín | la calabacita | Must | |
| la remolacha | el betabel | Should | |
| el boniato / la batata | el camote | Must | |
| el pomelo | la toronja | Must | |
| el anacardo | la nuez de la India | Must | |
| la tarta | el pastel | Must | tarta = pie or tart in MX |
| la nata | la crema | Must | nata = skin on boiled milk |
| la carne picada | la carne molida | Must | |
| el beicon / el bacon | el tocino | Must | |
| el bocadillo | la torta | Must | |
| el panecillo | el bolillo | Must | |
| el pan de molde | el pan de caja | Must | |
| la pajita | el popote | Must | |
| el polo (ice pop) | la paleta (helada) | Must | |
| el batido | la malteada / el licuado | Should | malteada for a milkshake, licuado for a blended fruit drink |
| la golosina | el dulce | Should | golosina is in DEM |
| el aperitivo / la tapa (snack) | la botana | Must | aperitivo = pre-meal drink in MX |
| el chupito | el caballito | Must | caballito is *Popular* |
| el frigorífico | el refrigerador | Must | nevera → refrigerador is Should |
| el grifo | la llave (del agua) | Must | |
| la bombilla | el foco | Must | |
| el dormitorio | la recámara | Must | dormitorio = dormitory |
| el armario (built-in) | el clóset | Should | armario is in DEM |
| la moqueta | la alfombra | Must | |
| la percha | el gancho | Must | |
| el telefonillo | el interfón | Must | DEM headword: interfono |
| el ascensor | el elevador | Should | |
| la fregona | el trapeador | Must | |
| el estropajo | la fibra | Must | |
| el interruptor (light) | el apagador | Should | |
| el fontanero | el plomero | Should | fontanero is regional in MX |
| la cerilla | el cerillo | Must | cerilla = earwax |
| el mechero | el encendedor | Must | |
| el lavavajillas | el lavaplatos | Should | |
| el cubo de la basura | el bote de basura | Must | |
| el cubo (bucket) | la cubeta | Should | cubo is regional |
| la manta | la cobija | Should | manta does mean blanket in DEM |
| el trastero | la bodega / el cuarto de los triques | Must | |
| el autocar | el autobús | Must | |
| el maletero | la cajuela | Must | |
| el capó | el cofre | Must | |
| el parachoques | la defensa | Should | |
| el neumático | la llanta | Should | do not chain into rin |
| el pinchazo | la ponchadura | Must | |
| el aparcamiento / el parking | el estacionamiento | Must | |
| el carné de conducir | la licencia para manejar | Must | DEM form; "de manejo" not found |
| el atasco | el tráfico / el embotellamiento | Must | |
| la furgoneta | la camioneta | Must | |
| la rotonda | la glorieta | Must | rotonda = circular monument |
| la acera | la banqueta | Should | |
| el intermitente | la direccional | Must | |
| el salpicadero | el tablero | Must | |
| el peaje (booth) | la caseta (de cobro) | Should | peaje for the toll payment is fine |
| el embrague | el clutch | Should | |
| el gasóleo | el diesel | Must | no accent |
| el alquiler | la renta | Should | |
| el carril bici | la ciclovía | Must | |
| la camiseta | la playera | Should | camiseta = undershirt or sports jersey |
| la chaqueta | la chamarra | Must | trap |
| la americana | el saco | Must | |
| el jersey | el suéter | Must | |
| el chándal | los pants | Must | |
| los vaqueros | los jeans | Must | |
| las bragas | los calzones / las pantaletas | Must | |
| el sujetador | el brasier | Should | DEM headword: brassier |
| las gafas | los lentes | Should | gafas leans toward sunglasses |
| las zapatillas (de deporte) | los tenis | Must | |
| la cremallera | el cierre | Must | |
| el bolso | la bolsa | Should | |
| el pijama | la pijama | Must | gender only |
| el chubasquero | el impermeable | Must | |
| el pintalabios | el lápiz labial | Must | not bare "labial" |
| el peto | el overol | Must | |
| el ordenador | la computadora | Should | |
| el portátil | la laptop | Must | |
| el móvil | el celular | Must | |
| el ratón (computer) | el mouse | Should | |
| el bolígrafo / el boli | la pluma | Must | |
| el rotulador | el plumón | Should | |
| el típex | el corrector | Must | |
| la grapadora | la engrapadora | Must | |
| el celo | el diurex / la cinta adhesiva | Must | celo = zeal, or animal heat |
| el folio | la hoja | Must | |
| el archivador | el archivero | Must | |
| los cascos / los auriculares | los audífonos | Must | |
| el altavoz | la bocina | Must | |
| el vídeo | el video | Must | |
| la calderilla | el cambio | Must | morralla is *Popular* |
| el escaparate | el aparador | Should | |
| el mercadillo | el tianguis | Must | |
| el chollo | la ganga | Must | |
| la hucha | la alcancía | Must | |
| la cola (queue) | la fila | Should | cola has *Popular* senses |
| la pizarra | el pizarrón | Should | |
| la tiza | el gis | Must | |
| la baja (médica) | la incapacidad | Must | |
| el carné (ID card) | la credencial | Must | |
| el camarero | el mesero | Should | |
| los mofletes | los cachetes | Must | |
| la mariquita (insect) | la catarina | Must | |
| la piscina | la alberca | Should | |
| el polideportivo | el deportivo | Must | |
| el césped | el pasto | Should | |
| el váter | el excusado / el inodoro / el baño | Must | |
| los aseos | los baños / los sanitarios | Must | |
| la ducha | la regadera | Should | |
| la bañera | la tina | Should | |
| el albornoz | la bata (de baño) | Must | |
| la maquinilla (de afeitar) | el rastrillo | Must | |
| la compresa (sanitary) | la toalla sanitaria | Must | compresa = medical compress |
| la tirita | la curita | Must | el/la curita |
| el chupete | el chupón | Should | |
| el biberón | la mamila | Should | |
| la papelera | el cesto (de basura) | Should | |
| la cometa (kite) | el papalote | Should | |
| el tobogán | la resbaladilla | Should | |

### Verb and phrase rewrites

| Spain | Mexico | Strength | Confidence / note |
|---|---|---|---|
| coger (take, grab, catch) | agarrar / tomar | Must | DEM trap |
| coger el autobús | tomar el camión / el autobús | Must | DEM |
| conducir (a vehicle) | manejar | Must | DEM: conducir has no driving sense |
| echar de menos | extrañar | Should | DEM |
| alquilar | rentar | Should | DEM |
| charlar | platicar | Should | DEM |
| chequear | checar | Must | chequear absent from DEM; comprobar is fine as is |
| tirar de (pull) | jalar | Must | DEM; leave "tirar a la basura" alone |
| aparcar | estacionar | Must | DEM |
| darse prisa | apurarse | Should | DEM |
| encender (light, TV) | prender | Should | DEM |
| enfadarse / cabrearse | enojarse | Should / Must | DEM; cabrear absent |
| afeitarse | rasurarse | Should | DEM |
| estropearse / averiarse | descomponerse | Must | DEM |
| atascarse | atorarse | Should | DEM |
| atar | amarrar | Should | DEM |
| hacerse daño | lastimarse | Should | DEM |
| ponerse enfermo | enfermarse | Should | DEM |
| currar | trabajar | Must | currar absent from DEM; chambear is *Popular* |
| molar / mola | gustar / está padre | Must | molar (verb) absent; padre is *Popular* |
| ¡Vale! | Está bien / Sale / Va | Should | Wiktionary; va is shared with Spain |
| ¡Qué guay! | ¡Qué padre! / ¡Qué chido! | Must | DEM / DAMER, *Popular* |
| ¿Qué pasa? (greeting) | ¿Qué onda? / ¿Qué tal? | Should | DEM *Popular*; ¿qué tal? is neutral |
| tío / tía (guy, girl) | amigo, or omit; güey only between peers | Must | Wiktionary (Spain); DEM (güey *Ofensivo* as an insult) |
| la resaca | la cruda | Should | DAMER *pop.* |
| ser uña y carne | ser uña y mugre | Should | Colmex 95.4% vs 4.6% |
| aguantar mecha | aguantar vara | Should | Colmex 89% |
| írsele la olla | botársele la canica | Should | Colmex (Mexican side only) |
| estar al loro | ponerse trucha | Should | Inklingo (Spain tag); Colmex 91% |
| el pijo / la pija | el / la fresa | Should | DEM *Popular* |
| el enchufe (connections) | las palancas | Should | Wiktionary (Spain); Redalyc (Mexico) |
| me importa un pimiento | me vale / me importa un cacahuate | Should | learner sources only |
| ser la leche | estar padrísimo | Should | Wiktionary / Inklingo; never map to MX "qué leche" (= what luck) |

### Sense-dependent words: rewrite only in the stated sense

| Spain word | Rewrite when it means | Leave alone when it means |
|---|---|---|
| el piso | apartment → el departamento | floor or storey |
| el billete | ticket → el boleto | banknote |
| la nota | school grade → la calificación | note, written message |
| el pendiente | earring → el arete | pending (adj.), slope |
| la llanta | wheel rim → el rin | (MX already uses llanta for tire) |
| el mando | remote or game controller → el control | command, leadership |
| la cocina | stove → la estufa | kitchen |
| la estufa | room heater → el calentador | (in MX estufa = stove) |
| el termo | water heater → el bóiler | vacuum flask |
| la matrícula | number plate → la placa | enrolment |
| la plaza | parking space → el cajón / el lugar | town square |
| el sello | postage stamp → el timbre / la estampilla | rubber stamp, seal |
| la goma | rubber band → la liga | eraser (goma in MX too) |
| las zapatillas | sneakers → los tenis; slippers → las pantuflas | (in MX zapatillas = women's shoes) |
| el instituto | secondary school → la secundaria / la preparatoria (by age) | research institute |
| el paro | unemployment → el desempleo | strike, stoppage |
| el becario | intern → el practicante | scholarship holder |
| el salón | living room → la sala | hall, salón de clases |
| el tomate | red tomato → el jitomate (central Mexico only) | (northern Mexico uses tomate for red) |
| suspender | fail an exam → reprobar | suspend, postpone |
| adelantar | overtake a car → rebasar | move forward, advance |
| pinchar | puncture → ponchar | click, prick |
| despedir | fire from a job → correr (colloquial), or keep despedir | say goodbye |
| tirar | pull → jalar | throw, throw away |

### Do NOT rewrite: the Spain word is normal in Mexico, or the "Mexican" target is wrong

| Spain word | Why it stays | Evidence |
|---|---|---|
| el coche | DEM coche 1 = car; carro and auto are equal options | [DEM](https://dem.colmex.mx/ver/coche) |
| el autobús | normal for intercity coaches; camión is the colloquial city bus | [DEM](https://dem.colmex.mx/ver/autobús) |
| el maíz | plant and grain; elote is only the tender ear | [DEM](https://dem.colmex.mx/ver/elote) |
| el despacho | ordinary for a professional's office | [DEM](https://dem.colmex.mx/ver/despacho) |
| el papel higiénico | DEM's own sub-entry; "papel de baño" not found | [DEM](https://dem.colmex.mx/ver/papel) |
| el chisme | both "gossip" and "small thing" | [DEM](https://dem.colmex.mx/ver/chisme) |
| la cisterna | a building's water tank; tanque has no toilet sense | [DEM](https://dem.colmex.mx/ver/cisterna) |
| la barriga | *Popular* but used; panza is an alternative, not a fix | [DEM](https://dem.colmex.mx/ver/barriga) |
| el barrio | used (often a humbler area); colonia is not an exact synonym | [DEM](https://dem.colmex.mx/ver/barrio) |
| el ayuntamiento | the municipal government or its seat | [DEM](https://dem.colmex.mx/ver/ayuntamiento) |
| volver, devolver | normal in Mexico; regresar is an option, not a fix | [DEM](https://dem.colmex.mx/ver/regresar) |
| el aula, el sofá, el lavabo, la cuerda, el pegamento, el pimiento, el champiñón, el cerdo, el búho, el buitre, el colibrí, el bicho, la concha | unmarked DEM entries with the same meaning | [DEM sofá](https://dem.colmex.mx/ver/sofá); [DEM aula](https://dem.colmex.mx/ver/aula); [DEM bicho](https://dem.colmex.mx/ver/bicho) |
| el camping, el smoking, el spot, el tupper, el ticket | DEM headwords (tupper is pronounced tóper) | [DEM camping](https://dem.colmex.mx/ver/camping); [DEM smoking](https://dem.colmex.mx/ver/smoking) |
| el fregadero, la pinza, el garaje, el bolsillo, las rebajas, la alubia, la mazorca, el café solo | present in DEM with the Spain meaning | [DEM fregadero](https://dem.colmex.mx/ver/fregadero); [DEM rebaja](https://dem.colmex.mx/ver/rebaja) |
| el chucho (dog) | *Popular* in Mexico too | [DEM](https://dem.colmex.mx/ver/chucho) |
| el trasto, el cachivache | both used in Mexico; tiliche (*Popular*) is an alternative | [DEM cachivache](https://dem.colmex.mx/ver/cachivache) |
| el todoterreno | no good target: troca is northern and means a cargo truck; camioneta is the safe fallback | [DEM troca](https://dem.colmex.mx/ver/troca) |
| el autónomo | no clean noun target: independiente is only an adjective; use "trabajador independiente" or "freelance" | [DEM](https://dem.colmex.mx/ver/independiente) |
| el bastoncillo | don't output "cotonete" (not in DEM); use hisopo | [DEM hisopo](https://dem.colmex.mx/ver/hisopo) |
| "va" (= OK) | shared with Spain | [Wiktionary](https://en.wiktionary.org/wiki/va) |

Mexico mode should never produce **ocupar = necesitar**, **aplicar a un puesto**, **media cansada**, **parquear** (DEM lists it, but central Mexico says estacionar), **botar** = to fire someone (a sense DEM does not list), the clippings **refri, compu and depa**, or any *Groser* or *Ofensivo* item, even though learners will hear all of them.

## Conclusion

Most of the vocabulary gap in learner lists is a difference in frequency, not in meaning. DEM records about one in eight supposedly Spain-only nouns as ordinary words in Mexico. So the job of a Mexico mode is not translation between two lexicons. It is choosing the most natural Mexican option while never letting through the dozen or so words that change meaning or turn coarse: coger, chaqueta, grifo, cerilla, pinche, correrse, pajita. A tiered table with a separate sense-dependent list does this far better than a flat substitution dictionary, which would turn *piso* "floor" and *nota* "note" into nonsense and chain *neumático → llanta → rin*. The grammar rules are the high-yield core, because they apply to almost every sentence and are close to deterministic: ustedes, the preterite for finished events, no leísmo, *qué tan*, and *a las 10* instead of ambiguous *hasta*. Only the perfect-to-preterite rule needs semantic judgment.

On register, the evidence calls for a conservative stance. DEM's *Popular* tier is safe to teach as vocabulary, but Mexico mode should not insert slang into neutral translations. Three widely taught words carry slurs (naco, the noun chale, insulting güey), and the app should label them as slurs, not as local color. Three questions remain open: how often Mexicans actually use each Spain synonym, which model-knowledge slang items are still current, and what the app's own translation engine outputs. A corpus check (CORPES XXI by country), the Academia Mexicana's *Diccionario de mexicanismos*, and a direct test of the engine on the sample sentences above are the next steps.
