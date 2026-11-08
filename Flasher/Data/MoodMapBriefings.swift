import Foundation

/// What the learner reads before practising a step: the idea behind the rule in plain words, and examples with English.
/// Steps whose rule is already written out in full only add examples here, or nothing; the briefing screen also shows
/// worked cards, the rule the step qualifies, and its watch-outs and fine points.
struct MoodBriefing {
    /// Why the rule works the way it does, in a few sentences.
    let why: String
    /// Spanish → English.
    let examples: [(spanish: String, english: String)]
}

extension MoodMap {
    static let briefings: [String: MoodBriefing] = [
        "root": MoodBriefing(
            why: "Spanish asks one question about every clause after que (and after words like cuando, para que, aunque): is anyone putting this forward as true? If you are telling someone a fact, a belief or news, use the indicative. If the clause is something wanted, doubted, denied, not real yet, or something you only react to, use the subjunctive. The verb before que is what usually decides it.",
            examples: [("Sé que viene.", "I know he's coming. (a fact you claim: indicative)"),
                       ("Espero que venga.", "I hope he comes. (a wish, nobody claims it: subjunctive)"),
                       ("Me alegra que venga.", "I'm glad he's coming. (you react to it: subjunctive)")]),
        "want": MoodBriefing(
            why: "When you want, ask, tell, advise or allow someone else to do something, the thing hasn't happened: it only exists in your wish. Nobody is claiming it's true, so it takes the subjunctive. It's the same with every verb of influence: querer, pedir, necesitar, preferir, aconsejar, recomendar, permitir, prohibir, exigir, rogar.",
            examples: [("Quiero que me esperes.", "I want you to wait for me."),
                       ("Te pido que me llames.", "I'm asking you to call me."),
                       ("El médico me recomienda que descanse.", "The doctor recommends that I rest."),
                       ("No permiten que fumemos aquí.", "They don't allow us to smoke here.")]),
        "feel": MoodBriefing(
            why: "With a feeling or a judgement, the fact is usually true and everyone knows it. But you aren't telling it as news: it's given, and what you're saying is how you feel about it. That reaction is what puts the clause in the subjunctive. It covers alegrarse, gustar, encantar, molestar, sentir (be sorry), temer, sorprender, and es bueno, es una pena, es raro que.",
            examples: [("Me alegra que te guste.", "I'm glad you like it."),
                       ("Me molesta que hablen tan alto.", "It bothers me that they talk so loudly."),
                       ("Es una pena que no puedas venir.", "It's a shame you can't come."),
                       ("Siento que estés enfermo.", "I'm sorry you're sick.")]),
        "doubt": MoodBriefing(
            why: "When you doubt or deny something, you are saying it may not be true, so you are the opposite of claiming it. That takes the subjunctive: dudar que, negar que, no es cierto que, es imposible que. Watch for no dudo que and no niego que: taking the doubt away turns them back into a claim (the next steps).",
            examples: [("Dudo que llegue a tiempo.", "I doubt she'll arrive on time."),
                       ("Niega que lo haya dicho.", "He denies having said it."),
                       ("Es imposible que llegue a tiempo.", "There's no way she'll arrive on time.")]),
        "belief": MoodBriefing(
            why: "Creer, pensar, saber, ver, decir, parecer and estar seguro say what you hold to be true. Saying it is a claim, so the indicative follows. The subjunctive only comes in when you take the claim back: no creo que, no pienso que. Many learners expect creer to take the subjunctive because it sounds uncertain, but believing something is still putting it forward as true.",
            examples: [("Creo que está en casa.", "I think she's at home."),
                       ("Veo que estás cansado.", "I see you're tired."),
                       ("Dice que viene mañana.", "She says she's coming tomorrow."),
                       ("No creo que esté en casa.", "I don't think she's at home. (no claim: subjunctive)")]),
        "unknown": MoodBriefing(
            why: "A que clause can describe a noun: the flat that has a balcony. If you know that thing exists and which one it is, you describe it as a fact: indicative. If you're only looking for something like it, or it doesn't exist, or you don't know whether it does, nobody can claim anything about it: subjunctive. The verb in the main clause is often the same; what changes is whether the thing is real and known.",
            examples: [("Busco el libro que tiene tapas rojas.", "I'm looking for the book with the red cover. (a known one)"),
                       ("Busco un libro que tenga tapas rojas.", "I'm looking for a book with a red cover. (any one, if it exists)"),
                       ("No hay ningún libro que me guste.", "There's no book I like.")]),
        "time": MoodBriefing(
            why: "Time words (cuando, hasta que, en cuanto, tan pronto como, mientras, después de que) can talk about something that already happened, something that always happens, or something that is still to come. The first two are facts: indicative. Something still to come hasn't happened, so it can't be claimed: subjunctive. Ask: has it happened, or does it happen as a rule? Then indicative. Not yet? Subjunctive.",
            examples: [("Cuando tengo hambre, como.", "When I'm hungry, I eat. (a habit)"),
                       ("Cuando llegó, cenamos.", "When he arrived, we had dinner. (it happened)"),
                       ("Cuando llegues, cenamos.", "When you arrive, we'll have dinner. (still to come)"),
                       ("Espera hasta que te llame.", "Wait until I call you.")]),
        "purpose": MoodBriefing(
            why: "Some connectors only ever introduce something that isn't a fact. Para que gives a purpose, which is still to be reached. Sin que names something that doesn't happen. Antes de que points at something that hasn't happened yet at that moment. Since none of these can be a claim, they always take the subjunctive, whatever the time.",
            examples: [("Habla despacio para que te entiendan.", "Speak slowly so they understand you."),
                       ("Sale sin que nadie lo vea.", "He leaves without anyone seeing him."),
                       ("Llámame antes de que salgas.", "Call me before you leave.")]),
        "concession": MoodBriefing(
            why: "Aunque can mean 'even though' or 'even if'. Even though (it's raining, and I'm telling you so): a fact, indicative. Even if (it might rain, I don't know): a possibility, subjunctive. The subjunctive can also wave a fact away as beside the point: aunque sea tu hermano = he may be your brother, but that doesn't matter.",
            examples: [("Aunque hace frío, vamos a la playa.", "Even though it's cold, we're going to the beach."),
                       ("Aunque llueva, saldré.", "Even if it rains, I'll go out."),
                       ("Aunque es caro, lo compro.", "Even though it's expensive, I'm buying it.")]),
        "alone": MoodBriefing(
            why: "Sometimes there's no main verb at all, and a word at the start sets the mood. Ojalá (I hope, if only) is a wish, so always subjunctive. Quizás, tal vez and posiblemente say 'maybe': the indicative makes it a likelier guess, the subjunctive a more doubtful one. And que + subjunctive on its own is a wish or an order passed on: ¡que te vaya bien!",
            examples: [("Ojalá llueva.", "I hope it rains."),
                       ("Quizás llueve.", "Maybe it's raining. (likely)"),
                       ("Quizás llueva.", "Maybe it'll rain. (less sure)"),
                       ("¡Que te diviertas!", "Have fun!")]),
        "fixed": MoodBriefing(
            why: "A few set phrases are in the subjunctive with no trigger in sight, so learn them as whole phrases. Doubled verbs mean 'no matter what': pase lo que pase, digas lo que digas. Hedges like que yo sepa limit what you claim to what you know.",
            examples: [("Pase lo que pase, no me rindo.", "Whatever happens, I won't give up."),
                       ("Quieras o no, vamos.", "Like it or not, we're going."),
                       ("Que yo sepa, está cerrado.", "As far as I know, it's closed.")]),
        "want.same": MoodBriefing(
            why: "Que + subjunctive is for wanting something of someone else. When the person who wants is the one who will do it, Spanish drops que and uses the infinitive, just like English 'I want to go'. Quiero que yo vaya is wrong; quiero ir is right.",
            examples: [("Quiero aprender a nadar.", "I want to learn to swim."),
                       ("Quiero que aprendas a nadar.", "I want you to learn to swim."),
                       ("Necesito salir un rato.", "I need to go out for a bit.")]),
        "want.decir": MoodBriefing(
            why: "Decir can report information or pass on an order. 'She says he's coming' is news: indicative. 'She tells him to come' is an order, a kind of wanting: subjunctive. The same happens with escribir, avisar, gritar and insistir: the mood shows which one you mean.",
            examples: [("Me dice que viene.", "She tells me she's coming. (news)"),
                       ("Me dice que venga.", "She tells me to come. (an order)"),
                       ("Le escribo que me llame.", "I'm writing to tell him to call me.")]),
        "want.meaning": MoodBriefing(
            why: "A few verbs have two meanings, and the mood picks one. Sentir que + indicative = to feel or sense; + subjunctive = to be sorry. Pensar que + indicative = to think; pensar en que + subjunctive = to consider. Insistir en que + indicative = to insist it's true; + subjunctive = to insist someone does it.",
            examples: [("Siento que hace frío.", "I feel that it's cold."),
                       ("Siento que no puedas venir.", "I'm sorry you can't come."),
                       ("Insiste en que no lo sabía.", "He insists he didn't know."),
                       ("Insiste en que comamos con ella.", "She insists that we eat with her.")]),
        "feel.true": MoodBriefing(
            why: "Learners often think the subjunctive means 'not true'. It doesn't: with feelings, the fact is plainly true and still takes the subjunctive, because the point of the sentence is your reaction, not the news.",
            examples: [("Me molesta que no me llames.", "It bothers me that you don't call me. (you don't)"),
                       ("Me alegra que hayas aprobado.", "I'm glad you passed. (you did pass)")]),
        "feel.temerse": MoodBriefing(
            why: "Some phrases look like feelings but really pass on news. Me temo que means 'I'm afraid that' in the sense of 'I suspect': you're telling someone something, so indicative. Menos mal que (thank goodness) also states the fact it is relieved about.",
            examples: [("Me temo que no hay entradas.", "I'm afraid there are no tickets."),
                       ("Menos mal que llegaste a tiempo.", "Thank goodness you made it on time."),
                       ("Temo que no llegue.", "I fear he won't arrive. (a real fear: subjunctive)")]),
        "doubt.nodudo": MoodBriefing(
            why: "No dudo que takes the doubt away, which leaves something close to a claim. So the indicative is normal. The subjunctive is also correct and sounds a little more formal or cautious.",
            examples: [("No dudo que lo intenta.", "I don't doubt he's trying."),
                       ("No dudo que sea verdad.", "I don't doubt that it's true. (also correct)")]),
        "doubt.certain": MoodBriefing(
            why: "Phrases of certainty are claims: no cabe duda de que, no hay duda de que, estoy seguro de que, sin duda. They take the indicative, even though they contain the word duda.",
            examples: [("No cabe duda de que es el mejor.", "There's no doubt he's the best."),
                       ("Estoy seguro de que lo sabe.", "I'm sure she knows.")]),
        "belief.no": MoodBriefing(
            why: "Creer que claims the clause. No creo que takes the claim back: you don't vouch for it any more. With nobody claiming it, the subjunctive follows. Note that it's the main verb that is negated; creo que no viene keeps the indicative, because you're claiming 'he isn't coming'.",
            examples: [("No creo que sepa la verdad.", "I don't think she knows the truth."),
                       ("Creo que no tiene razón.", "I think he's not right. (a claim: indicative)"),
                       ("No parece que esté enfermo.", "He doesn't seem to be sick.")]),
        "belief.question": MoodBriefing(
            why: "¿No crees que…? isn't really doubting: it asks the other person to agree with something you think is true, so the indicative stays. No creas que… (don't think that…) is a command, and what follows is something you're pointing out as true.",
            examples: [("¿No crees que hace frío?", "Don't you think it's cold?"),
                       ("No creas que es fácil.", "Don't think it's easy.")]),
        "impersonal.truth": MoodBriefing(
            why: "Es verdad, es cierto, es obvio, está claro and es evidente que all say 'this is true': a claim, so indicative. Negated (no es verdad que), they say it isn't true, and the subjunctive follows. Most other impersonal phrases (es importante, es posible) take the subjunctive.",
            examples: [("Es verdad que trabaja mucho.", "It's true that she works a lot."),
                       ("No es verdad que trabaje mucho.", "It isn't true that she works a lot."),
                       ("Está claro que es caro.", "It's clear that it's expensive.")]),
        "unknown.none": MoodBriefing(
            why: "If nothing like it exists, there's nothing to describe as a fact. No hay nadie que, no hay nada que and no conozco a nadie que all take the subjunctive.",
            examples: [("No hay nadie que pueda ayudarte.", "There's nobody who can help you."),
                       ("No conozco a nadie que hable ruso.", "I don't know anyone who speaks Russian."),
                       ("Hay alguien que puede ayudarte.", "There's someone who can help you. (exists: indicative)")]),
        "time.before": MoodBriefing(
            why: "Antes de que always points at something that hasn't happened yet at that moment, even in a story about the past. So it always takes the subjunctive.",
            examples: [("Llámame antes de que salgas.", "Call me before you leave."),
                       ("Salgo antes de que llegue.", "I leave before he arrives.")]),
        "time.question": MoodBriefing(
            why: "¿Cuándo…? with an accent is a question, not a time clause. Questions take the indicative, including the future, whether direct or inside a sentence: no sé cuándo vendrá.",
            examples: [("¿Cuándo vuelves?", "When are you coming back?"),
                       ("No sé cuándo vendrá.", "I don't know when he'll come."),
                       ("Cuando llegues, avísame.", "When you arrive, let me know. (a time clause: subjunctive)")]),
        "time.despues": MoodBriefing(
            why: "Después de que about the past tells what happened, so it normally takes the indicative. In news writing you will also see the subjunctive here; both are accepted.",
            examples: [("Después de que se fue, limpiamos.", "After he left, we cleaned up."),
                       ("Después de que llegues, comemos.", "After you arrive, we'll eat.")]),
        "condition.si": MoodBriefing(
            why: "Si (if) is unusual: it never takes the present subjunctive. A real, possible condition uses the present indicative, even about the future: si llueve, no salgo. An unlikely or unreal one uses the imperfect subjunctive with the conditional: si lloviera, no saldría.",
            examples: [("Si tengo dinero, viajo este verano.", "If I have money, I'll travel this summer."),
                       ("Si llueve, no salimos.", "If it rains, we won't go out."),
                       ("Si tuviera dinero, viajaría más.", "If I had money, I'd travel more.")]),
        "condition.como": MoodBriefing(
            why: "Como at the start of a sentence has two meanings. With the indicative it means 'since, because': como no viniste = since you didn't come. With the subjunctive it's a condition, usually a warning: como no vengas = if you don't come.",
            examples: [("Como no estudies, no vas a aprobar.", "If you don't study, you won't pass."),
                       ("Como no estudiaste, no aprobaste.", "Since you didn't study, you didn't pass.")]),
        "condition.porsi": MoodBriefing(
            why: "Por si means 'in case'. Like si, it never takes the present subjunctive: use the indicative. En caso de que, which also means 'in case', does take the subjunctive.",
            examples: [("Llévate un abrigo por si hace frío.", "Take a coat in case it's cold."),
                       ("En caso de que no venga, empezamos sin él.", "In case he doesn't come, we'll start without him.")]),
        "purpose.comosi": MoodBriefing(
            why: "Como si (as if) compares with something that isn't so. It only takes a past subjunctive, never the present: habla como si fuera el jefe, even though the sentence is about now.",
            examples: [("Gasta como si fuera rico.", "He spends as if he were rich."),
                       ("Me mira como si no me conociera.", "She looks at me as if she didn't know me.")]),
        "purpose.demodo": MoodBriefing(
            why: "De modo que and de manera que can give a purpose or a result. A purpose (so that someone does it) is still to be reached: subjunctive. A result (so, therefore) is a fact: indicative.",
            examples: [("Habla alto, de modo que te oigan.", "Speak up so that they hear you."),
                       ("Estaba cansado, de modo que me acosté.", "I was tired, so I went to bed.")]),
        "purpose.deahi": MoodBriefing(
            why: "De ahí que (hence, that's why) introduces a result everyone already knows, and it takes the subjunctive anyway: the point is the link to the cause, not the news.",
            examples: [("Llueve mucho; de ahí que se suspenda el partido.", "It's raining a lot; hence the game is called off.")]),
        "concession.waved": MoodBriefing(
            why: "With a known fact, aunque + indicative grants it. Aunque + subjunctive also works: it treats the fact as beside the point. Both are correct; the subjunctive sounds more dismissive.",
            examples: [("Aunque es tu jefe, no puede gritarte.", "Even though he's your boss, he can't shout at you."),
                       ("Aunque sea tu jefe, no puede gritarte.", "He may be your boss, but he can't shout at you.")]),
        "alone.ojala": MoodBriefing(
            why: "Ojalá always takes the subjunctive, and the tense says how likely the wish is. Present: it can still happen. Imperfect: unlikely, or impossible now. Pluperfect: it didn't happen, and you wish it had.",
            examples: [("Ojalá venga.", "I hope he comes."),
                       ("Ojalá viniera.", "I wish he'd come. (unlikely)"),
                       ("Ojalá hubiera venido.", "I wish he had come. (he didn't)")]),
        "alone.quizas": MoodBriefing(
            why: "Quizás, tal vez and probablemente before the verb allow both moods: indicative for a likelier guess, subjunctive for a doubtful one. Put after the verb, they take the indicative only.",
            examples: [("Tal vez está en casa.", "Maybe she's at home."),
                       ("Tal vez esté en casa.", "Maybe she's at home, but I'm not sure."),
                       ("Viene, quizás.", "He's coming, maybe.")]),
        "sequence.conditional": MoodBriefing(
            why: "The conditional (me gustaría, sería mejor, preferiría) works like a past main verb: the subjunctive after it moves back to the imperfect.",
            examples: [("Me gustaría que vinieras.", "I'd like you to come."),
                       ("Sería mejor que te fueras.", "It would be better for you to leave.")]),
        "subject.perfect": MoodBriefing(
            why: "When you feel something about what you yourself already did, use haber + participle in the infinitive: me alegro de haber venido. For what someone else did: que + haya + participle.",
            examples: [("Me alegro de haber estudiado.", "I'm glad I studied."),
                       ("Siento no haber escrito.", "I'm sorry I didn't write."),
                       ("Me alegro de que hayas aprobado.", "I'm glad you passed.")]),
        "want.esperaA": MoodBriefing(
            why: "Esperar a que means 'wait for, wait until'. What you wait for hasn't happened yet, so it always takes the subjunctive.",
            examples: [("Espera a que termine la película.", "Wait until the film ends."),
                       ("Esperamos a que deje de llover.", "We're waiting for it to stop raining.")]),
        "belief.askdoubt": MoodBriefing(
            why: "A question with creer normally keeps the indicative: you're just asking. The subjunctive is also correct, and it shows that you doubt it.",
            examples: [("¿Crees que gana el Madrid?", "Do you think Madrid will win?"),
                       ("¿Crees que gane el Madrid?", "Do you really think Madrid will win?")]),
        "impersonal.agree": MoodBriefing(
            why: "No es verdad que rejects the clause: subjunctive. But ¿no es verdad que…? as a question asks the listener to agree with something you think is true: indicative.",
            examples: [("¿No es verdad que canta muy bien?", "Isn't it true that she sings really well?"),
                       ("No es verdad que lo haya roto.", "It isn't true that he broke it.")]),
        "unknown.quiera": MoodBriefing(
            why: "Quienquiera que, dondequiera que, cualquier… que and todo el que point at anyone or anything at all, not a known one. That openness takes the subjunctive.",
            examples: [("Quienquiera que llame, di que no estoy.", "Whoever calls, say I'm not in."),
                       ("Dondequiera que vayas, llévalo contigo.", "Wherever you go, take it with you.")]),
        "sequence.feelpast": MoodBriefing(
            why: "A feeling about something that happened earlier takes the pluperfect subjunctive (hubiera + participle), never the conditional habría.",
            examples: [("Sintió que no hubieran venido.", "She was sorry they hadn't come.")]),
        "fixed.hedge": MoodBriefing(
            why: "Que yo sepa and que yo recuerde limit your claim to what you know or remember, and they're always subjunctive. Que digamos at the end adds 'not exactly'.",
            examples: [("Que yo sepa, nadie llamó.", "As far as I know, nobody called."),
                       ("No es barato, que digamos.", "It's not exactly cheap.")]),
        "fixed.frozen": MoodBriefing(
            why: "A few wishes are frozen in the subjunctive and used as whole phrases.",
            examples: [("¡Viva el rey!", "Long live the king!"),
                       ("Que Dios te bendiga.", "May God bless you."),
                       ("Que sea lo que Dios quiera.", "Whatever will be, will be.")]),
    ]
}
