import Foundation

/// The mood map: the subjunctive taught as a tree of decisions, from the one rule at the top (is the clause asserted?)
/// down through families, triggers, switches and exceptions. Every card is a choice between neighbours, and every answer
/// is followed by "why?", so the learner practises the rule and not only the form.
/// The rules and grades come from docs/conjugation-drill/subjunctive-rules.md.
struct MoodNode: Identifiable, Hashable {
    let id: String
    /// 1 the top rule, 2 a family, 3 a rule, 4 a switch that flips it, 5 an exception or a regional use.
    let level: Int
    let parent: String?
    let title: String
    let rule: String
    let example: String

    static let levelNames = [1: "The big rule", 2: "Lesson", 3: "Rule", 4: "Watch out", 5: "Fine point"]
    var levelName: String { Self.levelNames[level] ?? "" }
}

struct MoodItem: Identifiable, Hashable {
    enum Kind: String { case form, meaning, flip }
    let id: String
    let node: String
    let kind: Kind
    /// The situation, in English, so the learner can decide whether the content is a fact, a wish, a guess...
    let context: String
    /// The Spanish sentence, with ___ for the gap on form cards, or the question on meaning and flip cards.
    let prompt: String
    let choices: [String]
    /// Every choice that is right. Two of them means both moods work, and the note says what changes.
    let correct: Set<Int>
    let note: String
    /// Reasons written for this card instead of node names, for the top rule where the families would give the answer away.
    var why: [String] = []
    var whyRight = 0

    var bothWork: Bool { correct.count > 1 }
    var heading: String {
        switch kind {
        case .form: bothWork ? "Pick the verb (more than one can work)" : "Pick the verb"
        case .meaning: "What does it mean?"
        case .flip: "Which change makes the other mood right?"
        }
    }
}

enum MoodMap {
    /// Verbs on the cards that the drill's verb list doesn't have, so their tenses can still be named.
    static let extraVerbs = ["llover", "haber", "pasar", "sentarse", "sentar"]

    private static let baseNodes: [MoodNode] = [
        MoodNode(id: "root", level: 1, parent: nil, title: "Asserted or not",
                 rule: "Indicative: you put the clause forward as news, something you claim is so. Subjunctive: you don't. Either nobody claims it (it's wanted, doubted, denied, not real yet), or it's already given and you only react to it (feelings, judgements).",
                 example: "Sé que viene (I know he's coming) · Espero que venga (I hope he comes)"),

        // Families
        MoodNode(id: "want", level: 2, parent: "root", title: "Wanting and asking", rule: "Wanting, asking, ordering, advising or allowing something of someone else takes the subjunctive.", example: "Quiero que vengas."),
        MoodNode(id: "feel", level: 2, parent: "root", title: "Feelings and judgements", rule: "A feeling or a judgement about something takes the subjunctive, even when it is true: the fact is given, and the point is your reaction.", example: "Me alegra que estés aquí."),
        MoodNode(id: "doubt", level: 2, parent: "root", title: "Doubt and denial", rule: "Doubting or denying takes the subjunctive.", example: "Dudo que sea verdad."),
        MoodNode(id: "belief", level: 2, parent: "root", title: "Believing and knowing", rule: "Saying what you believe, know, see or say, affirmed, takes the indicative: you claim it. Negated or doubted, it can take the subjunctive (next steps).", example: "Creo que tiene razón."),
        MoodNode(id: "impersonal", level: 2, parent: "root", title: "Es + adjective + que", rule: "Es + adjective follows the same three cases: truth and evidence are a claim (indicative); need and possibility claim nothing (subjunctive); judgements react to it (subjunctive). With an infinitive instead of que it's about people in general.", example: "Es posible que llueva · Es verdad que llueve"),
        MoodNode(id: "unknown", level: 2, parent: "root", title: "Known or unknown things", rule: "Describing something known takes the indicative. Something wanted, unknown or that doesn't exist takes the subjunctive.", example: "Busco un piso que tenga balcón."),
        MoodNode(id: "time", level: 2, parent: "root", title: "Time words", rule: "Cuando, hasta que, en cuanto…: the subjunctive for what is still to come, the indicative for habits and the past.", example: "Cuando llegues, cenamos · Cuando llego, ceno"),
        MoodNode(id: "condition", level: 2, parent: "root", title: "Conditions", rule: "Si takes the indicative (real) or the imperfect subjunctive (unlikely or unreal), never the present subjunctive. Most other condition words (en caso de que, a menos que, con tal de que) take the subjunctive; por si takes the indicative or the imperfect subjunctive.", example: "Si llueve… · En caso de que llueva…"),
        MoodNode(id: "purpose", level: 2, parent: "root", title: "Purpose and other fixed connectors", rule: "Para que, sin que, antes de que, como si always take the subjunctive.", example: "Te lo digo para que lo sepas."),
        MoodNode(id: "concession", level: 2, parent: "root", title: "Even though, even if", rule: "Aunque and its relatives: the indicative for a fact, the subjunctive for a possibility or a point waved away.", example: "Aunque llueve, salgo · Aunque llueva, saldré"),
        MoodNode(id: "alone", level: 2, parent: "root", title: "On its own: ojalá, maybe, que…", rule: "With no main verb: ojalá always takes the subjunctive, the 'maybe' words depend on the word and where it goes, and que + subjunctive is a wish.", example: "Ojalá llueva · Quizás venga · ¡Que te vaya bien!"),
        MoodNode(id: "sequence", level: 2, parent: "root", title: "Haya and hubiera: something done earlier", rule: "Each subjunctive has a form with haber for something already done: venga → haya venido (present), viniera → hubiera venido (imperfect). The main verb still picks present or past.", example: "Espero que hayan llegado · Esperaba que hubieran llegado"),
        MoodNode(id: "imperfect", level: 2, parent: "root", title: "Present or imperfect subjunctive", rule: "The subjunctive has two simple tenses. The present subjunctive (venga) points to now or later. The imperfect subjunctive (viniera) is the same mood moved back: the reason for the subjunctive stays the same, only the time or the reality changes. You need it after a main verb in the past (quería que vinieras), after the conditional (me gustaría que vinieras), and for things that aren't real or are unlikely (si tuviera tiempo, ojalá fuera viernes).", example: "Quiero que vengas · Quería que vinieras"),

        // Rules, switches and exceptions
        MoodNode(id: "want.same", level: 3, parent: "subject", title: "Same person: infinitive", rule: "When the one who wants is the one who does it, use the infinitive, not que.", example: "Quiero ir (not quiero que yo vaya)."),
        MoodNode(id: "want.decir", level: 4, parent: "want", title: "Decir: telling or ordering", rule: "Decir que + indicative passes on information. Decir que + subjunctive gives an order.", example: "Me dice que viene · Me dice que venga"),
        MoodNode(id: "want.meaning", level: 5, parent: "want.decir", title: "Verbs that change meaning", rule: "Sentir, pensar, decidir, comprender, insistir, recordar, quejarse de: the indicative and the subjunctive mean different things.", example: "Siento que hace frío (I feel) · Siento que te vayas (I'm sorry)"),

        MoodNode(id: "feel.true", level: 3, parent: "feel", title: "Even when it's true", rule: "The feeling doesn't make it less real: it is still the subjunctive.", example: "Me molesta que llegues tarde."),
        MoodNode(id: "feel.temerse", level: 5, parent: "feel.true", title: "Me temo que, menos mal que", rule: "Me temo que (I suspect) and menos mal que (thank goodness) take the indicative.", example: "Me temo que vamos a llegar tarde."),

        MoodNode(id: "doubt.nodudo", level: 4, parent: "doubt", title: "No dudo que: both work", rule: "Not doubting is close to certainty: the indicative is normal, the subjunctive also works.", example: "No dudo que es / sea verdad."),
        MoodNode(id: "doubt.certain", level: 4, parent: "doubt", title: "No cabe duda: certainty", rule: "No cabe duda de que, no hay duda de que, estoy seguro de que: indicative.", example: "No cabe duda de que es él."),

        MoodNode(id: "belief.no", level: 3, parent: "belief", title: "Negated: subjunctive", rule: "No creo que, no pienso que, no parece que take the subjunctive: you don't vouch for the clause (you doubt it), so nobody claims it.", example: "No creo que tenga razón."),
        MoodNode(id: "belief.claim", level: 4, parent: "belief.no", title: "Who claims it? Not the word no", rule: "The mood follows who stands behind the clause, not whether there's a no. Creo que no viene: you claim “he isn't coming” (indicative). No sabía que estabas: it was true and you say so, so the indicative is usual. Dudo que: no no, still subjunctive.", example: "Creo que no viene · No creo que venga · Espero que no venga (a wish stays subjunctive)"),
        MoodNode(id: "belief.question", level: 4, parent: "belief.no", title: "¿No crees que…? and no creas que", rule: "A question asking you to agree, and a 'don't think that…' command, take the indicative.", example: "¿No crees que ya es tarde? · No creas que me gusta."),

        MoodNode(id: "impersonal.truth", level: 3, parent: "impersonal", title: "Truth: indicative", rule: "Es verdad, es cierto, es obvio, está claro que: indicative. Negated (no es verdad que): subjunctive.", example: "Es verdad que llueve · No es verdad que llueva"),
        MoodNode(id: "impersonal.puede", level: 4, parent: "impersonal", title: "Puede que vs a lo mejor", rule: "Puede que always takes the subjunctive. A lo mejor (maybe) takes the indicative in about 98% of uses; a lo mejor + subjunctive is heard, mostly in Latin America, and the RAE doesn't rule it out.", example: "Puede que llueva · A lo mejor llueve"),

        MoodNode(id: "unknown.none", level: 3, parent: "unknown", title: "Nadie, nada, no hay", rule: "Something that doesn't exist takes the subjunctive.", example: "No hay nadie que sepa la respuesta."),
        MoodNode(id: "unknown.superlative", level: 5, parent: "unknown", title: "The best… that", rule: "After a superlative or el único / el primero que, about something known, the indicative is the plain statement and the subjunctive adds emphasis: both work. About someone not yet known, the subjunctive is required: el primero que llegue abre.", example: "Es la mejor película que he / haya visto."),

        MoodNode(id: "time.before", level: 3, parent: "time", title: "Antes de que: always", rule: "Antes de que always takes the subjunctive, even in the past.", example: "Salí antes de que llegara."),
        MoodNode(id: "time.question", level: 4, parent: "time", title: "¿Cuándo…? is a question", rule: "A question with ¿cuándo?, direct or inside a sentence (no sé cuándo vendrá), isn't a time clause: it takes the future like any question.", example: "¿Cuándo llegarás?"),
        MoodNode(id: "time.despues", level: 5, parent: "time", title: "Después de que in the past", rule: "In the past después de que takes the indicative, and the imperfect subjunctive is also accepted, mostly in news writing.", example: "Después de que llegó / llegara, comimos."),

        MoodNode(id: "condition.si", level: 3, parent: "condition", title: "Si: never the present subjunctive", rule: "Si + present indicative for real conditions, si + imperfect subjunctive for unlikely or unreal ones. Never si + present subjunctive or conditional.", example: "Si tengo tiempo… · Si tuviera tiempo…"),
        MoodNode(id: "condition.como", level: 4, parent: "condition", title: "Como + subjunctive = if", rule: "Como + subjunctive is a condition, usually a warning. Como + indicative means because.", example: "Como no vengas, me enojo · Como no viniste, me enojé"),
        MoodNode(id: "condition.porsi", level: 4, parent: "condition.si", title: "Por si: in case", rule: "Por si takes the indicative (or the imperfect subjunctive if less likely), never the present subjunctive. En caso de que takes the subjunctive.", example: "Llévate un paraguas por si llueve."),

        MoodNode(id: "purpose.comosi", level: 3, parent: "purpose", title: "Como si: past subjunctive only", rule: "Como si always takes the imperfect (or pluperfect) subjunctive, never the present.", example: "Habla como si fuera el jefe."),
        MoodNode(id: "purpose.demodo", level: 4, parent: "purpose", title: "De modo que: purpose or result", rule: "De modo que + subjunctive says the purpose. + indicative says the result.", example: "Habla alto, de modo que te oigan · Llovía, de modo que nos quedamos"),
        MoodNode(id: "purpose.deahi", level: 5, parent: "purpose.demodo", title: "De ahí que", rule: "De ahí que (that's why) takes the subjunctive, even though the result is known.", example: "Llovió mucho; de ahí que se suspendiera el partido."),

        MoodNode(id: "concession.waved", level: 4, parent: "concession", title: "Aunque with a known fact", rule: "A known fact can still take the subjunctive when the speaker waves it away: both are right.", example: "Aunque es / sea tu hermano, no tiene derecho."),
        MoodNode(id: "concession.pormas", level: 3, parent: "concession", title: "Por más que, por difícil que", rule: "No matter how much / how hard: usually subjunctive. For a real effort that keeps failing, the indicative is also correct: por más que estudio, no apruebo; por más que lo intenté, no pude.", example: "Por más que insistas, no voy."),

        MoodNode(id: "alone.ojala", level: 3, parent: "alone", title: "Ojalá and its tenses", rule: "Present: it can happen. Imperfect: unlikely. Pluperfect: it didn't happen.", example: "Ojalá venga · Ojalá viniera · Ojalá hubiera venido"),
        MoodNode(id: "alone.quizas", level: 4, parent: "alone", title: "Quizás: before or after", rule: "Before the verb quizás, tal vez, probablemente take either mood. After the verb, the indicative. ¿Acaso…? in a question takes the indicative.", example: "Quizás venga / viene · Viene, quizás."),
        MoodNode(id: "alone.que", level: 3, parent: "alone", title: "¡Que…! wishes", rule: "Que + subjunctive on its own is a wish or an order passed on. Que + indicative on its own is a warning or an emphatic repeat: ¡que viene el lobo!, ¡que no lo sé!", example: "¡Que tengas buen día!"),
        MoodNode(id: "alone.mexico", level: 5, parent: "alone", title: "Mexico and Colombia: what you'll hear", rule: "What you'll hear in Mexico and Colombia: ojalá y, a la mejor, qué bueno que viniste, no sé qué haga, capaz que, hasta = not until, and voseo in Antioquia (no digás). Understand them; the app teaches the standard forms.", example: "Ojalá y llueva · A la mejor viene"),

        MoodNode(id: "sequence.conditional", level: 4, parent: "sequence.past", title: "Me gustaría que: the conditional too", rule: "The conditional counts like a past main verb: me gustaría que vinieras, sería mejor que te fueras, preferiría que no lo dijeras.", example: "Me gustaría que vinieras."),
        MoodNode(id: "sequence.pending", level: 5, parent: "sequence.past", title: "Me pidió que venga: still to come", rule: "After a past verb, the present subjunctive is common (mostly in Latin America, but also in Spain) when the thing is still to come. The imperfect is the safe form.", example: "Me pidió que venga mañana · Me pidió que viniera mañana"),
    ]

    /// The top rule's reason is always one of two plain statements.
    private static func root(_ item: MoodItem, _ right: Int) -> MoodItem {
        var item = item
        item.why = ["You claim it's so", "You don't claim it: it's wanted, doubted, not real yet, or just reacted to"]
        item.whyRight = right
        return item
    }

    static func form(_ id: String, _ node: String, _ context: String, _ prompt: String, _ choices: [String], _ correct: Set<Int>, _ note: String) -> MoodItem {
        MoodItem(id: id, node: node, kind: .form, context: context, prompt: prompt, choices: choices, correct: correct, note: note)
    }
    static func meaning(_ id: String, _ node: String, _ context: String, _ prompt: String, _ choices: [String], _ correct: Int, _ note: String) -> MoodItem {
        MoodItem(id: id, node: node, kind: .meaning, context: context, prompt: prompt, choices: choices, correct: [correct], note: note)
    }
    static func flip(_ id: String, _ node: String, _ context: String, _ prompt: String, _ choices: [String], _ correct: Int, _ note: String) -> MoodItem {
        MoodItem(id: id, node: node, kind: .flip, context: context, prompt: prompt, choices: choices, correct: [correct], note: note)
    }

    private static let baseItems: [MoodItem] = [
        // The big rule: the same verb, asserted or not
        root(form("root.1", "root", "You're sure he's coming.", "Sé que él ___ mañana.", ["viene", "venga"], [0], "Sé que states it as a fact: indicative."), 0),
        root(form("root.2", "root", "You only hope he's coming.", "Espero que él ___ mañana.", ["viene", "venga"], [1], "Espero que is a wish, not a fact: subjunctive."), 1),
        root(form("root.3", "root", "You saw it: the shop is open.", "Veo que la tienda ___ abierta.", ["está", "esté"], [0], "Veo que reports what you see: indicative."), 0),
        root(form("root.4", "root", "You want the shop to be open.", "Necesito que la tienda ___ abierta.", ["está", "esté"], [1], "Necesito que asks for something that isn't a fact yet: subjunctive."), 1),
        root(form("root.6", "root", "You're not sure it's true.", "Dudo que ___ verdad.", ["es", "sea"], [1], "Dudo que holds it back: subjunctive."), 1),
        root(form("root.7", "root", "It's obvious.", "Está claro que ___ verdad.", ["es", "sea"], [0], "Está claro que states it: indicative."), 0),
        root(form("root.8", "root", "You want him to call.", "Le pido que me ___.", ["llama", "llame"], [1], "Asking for something that hasn't happened: subjunctive."), 1),
        root(form("root.9", "root", "He did call, you're telling someone.", "Te cuento que me ___ ayer.", ["llamó", "llamara"], [0], "Telling what happened: indicative."), 0),
        MoodItem(id: "root.5", node: "root", kind: .flip, context: "Right now it takes the indicative (tiene). Make the subjunctive (tenga) right.", prompt: "Creo que tiene razón.",
                 choices: ["Creo → No creo", "Creo → Sé", "tiene → tenía"], correct: [0], note: "With creo que you claim “he's right”. With no creo que you don't vouch for it (you doubt it), so nobody claims it: No creo que tenga razón. It isn't the word no: creo que no tiene razón keeps the indicative, because now you claim “he isn't right”.",
                 why: ["Now nobody claims the clause is true", "Sé is stronger than creo", "The past tense changes the mood"], whyRight: 0),

        // Wanting
        form("want.1", "want", "You want your friend to help.", "Quiero que me ___.", ["ayudas", "ayudes"], [1], "A wish about someone else: subjunctive."),
        form("want.2", "want", "Your boss asks you to arrive early.", "Mi jefe me pide que ___ temprano.", ["llego", "llegue"], [1], "Pedir que asks something of someone: subjunctive."),
        form("want.3", "want", "The doctor's advice.", "El médico me recomienda que ___ más agua.", ["tomo", "tome"], [1], "Advice about what someone should do: subjunctive."),
        form("want.same.1", "want.same", "You want to go yourself.", "Quiero ___ al cine.", ["ir", "que vaya"], [0], "Same person wants and does: the infinitive, quiero ir."),
        form("want.same.2", "want.same", "You want your sister to go.", "Quiero ___ al cine mi hermana.", ["ir", "que vaya"], [1], "A different person: que + subjunctive."),
        form("want.same.3", "want.same", "You study so you pass.", "Estudio para ___ el examen.", ["aprobar", "que apruebe"], [0], "Same person: para + infinitive."),
        meaning("want.decir.1", "want.decir", "Your mom on the phone.", "Me dijo que viniera.", ["She told me to come.", "She told me she was coming."], 0, "Decir que + subjunctive is an order: she told me to come."),
        meaning("want.decir.2", "want.decir", "Your mom on the phone.", "Me dijo que venía.", ["She told me to come.", "She told me she was coming."], 1, "Decir que + indicative passes on news: she said she was coming."),
        form("want.decir.3", "want.decir", "You order your brother to be quiet.", "Te digo que te ___.", ["callas", "calles"], [1], "An order through decir: subjunctive."),
        meaning("want.meaning.1", "want.meaning", "A friend is leaving the city.", "Siento que te vayas.", ["I'm sorry you're leaving.", "I can feel that you're leaving."], 0, "Sentir que + subjunctive is regret. With the indicative it is feeling or sensing: siento que hace frío."),
        meaning("want.meaning.2", "want.meaning", "Talking about a decision at work.", "Hemos decidido que vayas tú.", ["We've decided you'll go (we're telling you to).", "We've realized that you went."], 0, "Decidir que + subjunctive imposes a decision. With the indicative it is reaching a conclusion: he decidido que voy."),
        meaning("want.meaning.3", "want.meaning", "Your friend turned down a job.", "Comprendo que rechaces la oferta.", ["I understand why you'd turn it down.", "I've just realized you turned it down."], 0, "Comprender que + subjunctive: I find it reasonable. With the indicative: I realize."),

        // Who claims it
        form("belief.claim.1", "belief.claim", "You think he isn't coming.", "Creo que no ___.", ["viene", "venga"], [0], "You claim “he isn't coming”: indicative. The no is inside the clause."),
        form("belief.claim.2", "belief.claim", "You doubt he's coming, without claiming he won't.", "No creo que ___.", ["viene", "venga"], [1], "Now nobody vouches for “he comes”: you doubt it, so subjunctive. Close to creo que no viene, but weaker: you aren't claiming he won't come, only that you don't think he will."),
        form("belief.claim.3", "belief.claim", "Your friend was there; you hadn't noticed.", "No me di cuenta de que ___ ahí.", ["estabas", "estuvieras"], [0], "There's a no, but it was true, and you're saying so: indicative. Knowing and realizing keep the indicative."),
        form("belief.claim.4", "belief.claim", "Surprise: your friend is here.", "No sabía que ___ aquí.", ["estabas", "estuvieras"], [0, 1], "Both are correct. Estabas: you're telling them it's true, you just didn't know (the usual way). Estuvieras: you don't vouch for it."),
        meaning("belief.claim.5", "belief.claim", "About someone who denies science.", "Juan no cree que la Tierra es redonda.", ["The speaker knows it's round; Juan doesn't believe it.", "The speaker isn't sure it's round either."], 0, "The indicative after no cree que means the speaker stands behind the clause. With sea, the speaker takes no side."),
        flip("belief.claim.6", "belief.claim", "Right now it takes the subjunctive (sea). Make the indicative (es) right.", "Dudo que sea verdad.", ["Dudo → No dudo", "Dudo → Quiero", "sea → fuera"], 0, "Dudo que rejects it: subjunctive. No dudo que claims it, so the indicative comes back: no dudo que es verdad. Here the no works the other way."),
        form("belief.claim.7", "belief.claim", "You hope he stays away.", "Espero que no ___.", ["viene", "venga"], [1], "Moving the no into the clause doesn't help a wish: espero que no venga and no espero que venga are both subjunctive. A wish never claims anything, so there's nothing for the no to flip. Compare creo que no viene (indicative)."),
        flip("belief.claim.8", "belief.claim", "Right now it takes the subjunctive (venga). Make the indicative (viene) right.", "No espero que venga.", ["No espero → Creo", "No espero que venga → Espero que no venga", "No espero → No quiero"], 0, "Only a claim verb brings the indicative: creo que viene. Espero que no venga is still a wish, so still subjunctive."),
        meaning("belief.claim.9", "belief.claim", "You've just met your new neighbour.", "No creía que eras tan simpático.", ["You doubted it before; now you're saying he is.", "You still aren't sure he's nice."], 0, "Your past self doubted it, but you're claiming it now, so the indicative works. No creía que fueras tan simpático is the neutral version."),

        // Feelings
        form("feel.1", "feel", "Your friend is here and you're happy about it.", "Me alegra que ___ aquí.", ["estás", "estés"], [1], "A feeling about it: subjunctive, even though it's true."),
        form("feel.2", "feel", "It's sad that they can't come.", "Es una lástima que no ___ venir.", ["pueden", "puedan"], [1], "Es una lástima is a feeling: subjunctive."),
        form("feel.true.1", "feel.true", "Your roommate is late again. It's a fact.", "Me molesta que ___ tarde.", ["llegas", "llegues"], [1], "Facts behind a feeling still take the subjunctive."),
        form("feel.true.2", "feel.true", "Your team won, and that surprised you.", "Me sorprendió que ___ el partido.", ["ganaron", "ganaran"], [1], "A past feeling about a real event: imperfect subjunctive."),
        form("feel.temerse.1", "feel.temerse", "You suspect you'll be late.", "Me temo que ___ tarde.", ["vamos a llegar", "vayamos a llegar"], [0], "Me temo que means 'I'm afraid that' (I suspect): indicative."),
        form("feel.temerse.2", "feel.temerse", "Thank goodness you came.", "Menos mal que ___.", ["viniste", "vinieras"], [0], "Menos mal que states a relief about a fact: indicative."),

        // Doubt
        form("doubt.1", "doubt", "You don't believe the rumor.", "Dudo que ___ verdad.", ["es", "sea"], [1], "Doubt: subjunctive."),
        form("doubt.2", "doubt", "He says he didn't do it.", "Niega que ___ la ventana.", ["rompió", "rompiera"], [1], "Denying: subjunctive."),
        form("doubt.nodudo.1", "doubt.nodudo", "You trust her completely.", "No dudo que ___ la verdad.", ["dice", "diga"], [0, 1], "Both work. The indicative states it, the subjunctive holds back a little."),
        form("doubt.certain.1", "doubt.certain", "There's no doubt: it's him in the photo.", "No cabe duda de que ___ él.", ["es", "sea"], [0], "Certainty: indicative only."),
        form("doubt.certain.2", "doubt.certain", "You're sure she's right.", "Estoy seguro de que ___ razón.", ["tiene", "tenga"], [0], "Estar seguro: indicative. No estoy seguro de que tenga: subjunctive."),

        // Belief
        form("belief.1", "belief", "Your opinion.", "Creo que ___ razón.", ["tienes", "tengas"], [0], "Saying what you believe: indicative."),
        form("belief.2", "belief", "You know it.", "Sé que ___ mucho.", ["trabajas", "trabajes"], [0], "Knowing: indicative."),
        form("belief.no.1", "belief.no", "You don't think so.", "No creo que ___ razón.", ["tienes", "tengas"], [1], "Negated belief: subjunctive."),
        form("belief.no.2", "belief.no", "It doesn't look like rain.", "No parece que ___ a llover.", ["va", "vaya"], [1], "No parece que: subjunctive."),
        flip("belief.no.3", "belief.no", "Right now it takes the subjunctive (llueva). Make the indicative (llueve) right.", "No creo que llueva.", ["No creo → Creo", "llueva → llueve mañana", "No creo → No quiero"], 0, "Creo que asserts: Creo que llueve. No quiero que still takes the subjunctive."),
        form("belief.question.1", "belief.question", "You want your friend to agree it's late.", "¿No crees que ya ___ tarde?", ["es", "sea"], [0], "Asking for agreement presents it as obvious: indicative."),
        form("belief.question.2", "belief.question", "Don't think I like it.", "No creas que me ___.", ["gusta", "guste"], [0], "No creas que (a command) takes the indicative."),

        // Impersonal
        form("impersonal.1", "impersonal", "The forecast isn't sure.", "Es posible que ___ mañana.", ["llueve", "llueva"], [1], "Possibility: subjunctive."),
        form("impersonal.2", "impersonal", "You must arrive on time.", "Es importante que ___ a tiempo.", ["llegas", "llegues"], [1], "Need and importance: subjunctive."),
        form("impersonal.truth.1", "impersonal.truth", "Look outside.", "Es verdad que ___.", ["llueve", "llueva"], [0], "Truth: indicative."),
        form("impersonal.truth.2", "impersonal.truth", "Someone said it's raining, but it isn't.", "No es verdad que ___.", ["llueve", "llueva"], [1], "Denied truth: subjunctive."),
        form("impersonal.puede.1", "impersonal.puede", "Maybe it'll rain.", "Puede que ___.", ["llueve", "llueva"], [1], "Puede que always takes the subjunctive."),
        form("impersonal.puede.2", "impersonal.puede", "Maybe it'll rain, the everyday way.", "A lo mejor ___.", ["llueve", "llueva"], [0], "A lo mejor takes the indicative almost always. A lo mejor llueva is heard in Latin America, but it's rare."),

        // Known or unknown
        form("unknown.1", "unknown", "You're looking for any apartment with a balcony.", "Busco un piso que ___ balcón.", ["tiene", "tenga"], [1], "Not a specific one yet: subjunctive."),
        form("unknown.2", "unknown", "You found it: that apartment has a balcony.", "Busco el piso que ___ balcón.", ["tiene", "tenga"], [0], "A specific, known apartment: indicative."),
        form("unknown.3", "unknown", "You need someone who speaks Japanese (anyone).", "Necesito a alguien que ___ japonés.", ["habla", "hable"], [1], "Unknown person: subjunctive, even with the a."),
        form("unknown.none.1", "unknown.none", "Nobody knows the answer.", "No hay nadie que ___ la respuesta.", ["sabe", "sepa"], [1], "Doesn't exist: subjunctive."),
        form("unknown.none.2", "unknown.none", "There's someone who knows.", "Hay alguien que ___ la respuesta.", ["sabe", "sepa"], [0], "Exists: indicative."),
        form("unknown.superlative.1", "unknown.superlative", "Your favorite film.", "Es la mejor película que ___ visto.", ["he", "haya"], [0, 1], "Both work: he visto is the plain statement, haya visto adds emphasis."),

        // Time
        form("time.1", "time", "Tomorrow, when you arrive.", "Cuando ___, te llamo.", ["llegas", "llegues"], [1], "Still to come: subjunctive."),
        form("time.2", "time", "Every day, when you get home.", "Cuando ___ a casa, ceno.", ["llego", "llegue"], [0], "A habit: indicative."),
        form("time.3", "time", "Yesterday, when you arrived.", "Cuando ___, te llamé.", ["llegaste", "llegaras"], [0], "The past: indicative."),
        form("time.4", "time", "Wait here until she arrives.", "Espera hasta que ___.", ["llega", "llegue"], [1], "Still to come: subjunctive."),
        form("time.before.1", "time.before", "You left; he arrived later.", "Salí antes de que él ___.", ["llegó", "llegara"], [1], "Antes de que always takes the subjunctive, even in the past."),
        form("time.before.2", "time.before", "You'll leave before he arrives.", "Saldré antes de que él ___.", ["llega", "llegue"], [1], "Antes de que: subjunctive."),
        form("time.question.1", "time.question", "Asking your friend.", "¿Cuándo ___?", ["llegarás", "llegues"], [0], "A question isn't a time clause: the future is fine."),
        form("time.despues.1", "time.despues", "Yesterday: he arrived, then we ate.", "Después de que ___, comimos.", ["llegó", "llegara"], [0, 1], "Both work in the past. Llegó is the everyday choice, llegara is common in news writing."),

        // Conditions
        form("condition.1", "condition", "Real possibility: you might have time.", "Si ___ tiempo, te llamo.", ["tengo", "tenga"], [0], "Si never takes the present subjunctive: si tengo."),
        form("condition.2", "condition", "You don't have time; imagining.", "Si ___ tiempo, te llamaría.", ["tendría", "tuviera"], [1], "Unreal now: si + imperfect subjunctive, never si + conditional."),
        form("condition.3", "condition", "In case it rains.", "En caso de que ___, nos quedamos.", ["llueve", "llueva"], [1], "En caso de que always takes the subjunctive."),
        form("condition.4", "condition", "Unless you're in a hurry.", "Quédate, a menos que ___ prisa.", ["tienes", "tengas"], [1], "A menos que always takes the subjunctive."),
        form("condition.si.1", "condition.si", "If you had studied (you didn't).", "Si ___ estudiado, habrías aprobado.", ["habrías", "hubieras"], [1], "Unreal past: si + pluperfect subjunctive."),
        form("condition.si.2", "condition.si", "Asking whether he'll come.", "No sé si ___ mañana.", ["vendrá", "venga"], [0], "Here si means 'whether': it takes the future like any question. (No sé si venga is also heard in Mexico.)"),
        meaning("condition.como.1", "condition.como", "Your mom, warning you.", "Como no vengas, me enojo.", ["If you don't come, I'll be mad.", "Since you didn't come, I'm mad."], 0, "Como + subjunctive is a condition, usually a warning."),
        meaning("condition.como.2", "condition.como", "Your mom, afterwards.", "Como no viniste, me enojé.", ["If you don't come, I'll be mad.", "Since you didn't come, I got mad."], 1, "Como + indicative means because."),
        form("condition.porsi.1", "condition.porsi", "Take an umbrella, just in case.", "Llévate un paraguas por si ___.", ["llueve", "llueva"], [0], "Por si never takes the present subjunctive: por si llueve (or por si lloviera)."),

        // Purpose and fixed connectors
        form("purpose.1", "purpose", "You tell her so she knows.", "Te lo digo para que lo ___.", ["sabes", "sepas"], [1], "Para que: always subjunctive."),
        form("purpose.2", "purpose", "He left without anyone seeing him.", "Salió sin que nadie lo ___.", ["vio", "viera"], [1], "Sin que: always subjunctive."),
        form("purpose.comosi.1", "purpose.comosi", "He acts like the boss.", "Habla como si ___ el jefe.", ["es", "sea", "fuera"], [2], "Como si takes only the imperfect (or pluperfect) subjunctive."),
        form("purpose.comosi.2", "purpose.comosi", "She looked at me like she knew me.", "Me miró como si me ___ antes.", ["había visto", "haya visto", "hubiera visto"], [2], "Something earlier: pluperfect subjunctive."),
        meaning("purpose.demodo.1", "purpose.demodo", "Choose the meaning.", "Habla alto, de modo que todos te oigan.", ["Speak up so that everyone hears you.", "You spoke up, so everyone heard you."], 0, "De modo que + subjunctive is the purpose."),
        form("purpose.demodo.2", "purpose.demodo", "It rained, so we stayed home.", "Llovía, de modo que nos ___ en casa.", ["quedamos", "quedáramos"], [0], "The result: indicative."),
        form("purpose.deahi.1", "purpose.deahi", "It rained a lot; that's why the game was called off.", "Llovió mucho; de ahí que se ___ el partido.", ["suspendió", "suspendiera"], [1], "De ahí que takes the subjunctive, though the result is known."),

        // Concession
        form("concession.1", "concession", "It's raining right now.", "Aunque ___, salgo.", ["llueve", "llueva"], [0], "A fact: indicative."),
        form("concession.2", "concession", "You don't know tomorrow's weather.", "Aunque ___ mañana, saldré.", ["llueve", "llueva"], [1], "A possibility: subjunctive."),
        form("concession.waved.1", "concession.waved", "He is your brother, but that's beside the point.", "Aunque ___ tu hermano, no tiene derecho.", ["es", "sea"], [0, 1], "Both work. Es states the fact, sea waves it away as irrelevant."),
        form("concession.pormas.1", "concession.pormas", "No matter how much you insist.", "Por más que ___, no voy.", ["insistes", "insistas"], [1], "Por más que: subjunctive."),
        form("concession.pormas.2", "concession.pormas", "However hard it is.", "Por difícil que ___, lo haré.", ["es", "sea"], [1], "Por + adjective + que: subjunctive."),

        // On its own
        form("alone.1", "alone", "Hoping for good weather.", "Ojalá no ___ hoy.", ["llueve", "llueva"], [1], "Ojalá: always subjunctive."),
        form("alone.ojala.1", "alone.ojala", "You wish you had more time, but you don't.", "Ojalá ___ más tiempo.", ["tenga", "tuviera"], [0, 1], "Both are wishes. Tuviera says it's unlikely or untrue, tenga that it could happen."),
        form("alone.ojala.2", "alone.ojala", "The exam was yesterday; you didn't study.", "Ojalá ___ estudiado.", ["haya", "hubiera"], [1], "Something that didn't happen: pluperfect. (Ojalá haya estudiado hopes about someone else's past you don't know.)"),
        form("alone.quizas.1", "alone.quizas", "Maybe she's coming.", "Quizás ___.", ["viene", "venga"], [0, 1], "Before the verb both work: venga is less sure."),
        form("alone.quizas.2", "alone.quizas", "She forgot the meeting, maybe.", "Se ___, quizás, de la reunión.", ["olvidó", "olvidara"], [0], "After the verb, quizás only takes the indicative."),
        form("alone.que.1", "alone.que", "Saying goodbye.", "¡Que ___ un buen día!", ["tienes", "tengas"], [1], "A wish with que: subjunctive."),
        form("alone.mexico.1", "alone.mexico", "In Mexico, hoping it rains.", "Ojalá y ___.", ["llueve", "llueva"], [1], "Ojalá y is heard in Mexico; it still takes the subjunctive."),

        // Tense
        form("sequence.1", "imperfect", "Now.", "Quiero que ___.", ["vengas", "vinieras"], [0], "Present main verb: present subjunctive. Yesterday it would be quería que vinieras."),
        form("sequence.past.1", "sequence.past", "Yesterday.", "Quería que ___.", ["vengas", "vinieras"], [1], "Past main verb: imperfect subjunctive."),
        form("sequence.past.2", "sequence.past", "You doubted he had studied.", "Dudaba que ___ estudiado.", ["haya", "hubiera"], [1], "Past doubt about something earlier: pluperfect subjunctive."),
        form("sequence.conditional.1", "sequence.conditional", "A polite wish.", "Me gustaría que ___ a la fiesta.", ["vengas", "vinieras"], [1], "After the conditional: imperfect subjunctive."),
        form("sequence.pending.1", "sequence.pending", "Yesterday he asked you to come tomorrow.", "Me pidió que ___ mañana.", ["venga", "viniera"], [0, 1], "Viniera is the standard. Venga is common in Latin America when the thing is still to come."),
    ]

    static let nodes: [MoodNode] = baseNodes + moreNodes
    static let items: [MoodItem] = baseItems + moreItems
    /// The lessons in teaching order, after the top rule.
    static let lessons: [MoodNode] = [byID["root"]!] + lessonOrder.compactMap { byID[$0] }

    static let byID: [String: MoodNode] = Dictionary(uniqueKeysWithValues: nodes.map { ($0.id, $0) })
    static func children(of id: String) -> [MoodNode] { nodes.filter { $0.parent == id } }
    static func items(for node: String) -> [MoodItem] { items.filter { $0.node == node } }

    /// The cards a briefing works through before practice, kept out of the round that follows so the exercises are new.
    /// At least three cards stay for practice.
    static func workedExamples(for step: MoodNode, progress: MoodMapProgress) -> [MoodItem] {
        let cards = items(for: step.id, progress: progress).shuffled()
        return Array(cards.prefix(min(2, max(1, cards.count - 3))))
    }

    /// The step that introduces the imperfect subjunctive; steps that use it open after it.
    static let imperfectIntro = "sequence.past"
    /// Cards outside the imperfect lesson that use the imperfect or pluperfect subjunctive (viniera, hubiera): they wait for it.
    static let imperfectItems: Set<String> = {
        let own = imperfectSteps
        var found = Set<String>()
        for item in items where !own.contains(item.node) {
            let sentences = item.kind == .form
                ? item.choices.map { item.prompt.replacingOccurrences(of: "___", with: $0) }
                : [item.prompt] + item.choices + [MoodTenseLabels.changed(item)].compactMap { $0 }
            // The note, the situation and the reasons count too: "No creía que fueras tan simpático is the neutral version"
            if (sentences + [item.note, item.context] + item.why).contains(where: mentionsImperfect) { found.insert(item.id) }
        }
        return found
    }()
    /// Steps with fewer than two cards left without the imperfect: the whole step waits.
    /// Also any step whose own title, rule or example uses it (si lo hubiera sabido, Lamentó que no le hubiera gustado).
    static let usesImperfect: Set<String> = Set(nodes.filter { node in
        guard node.id != "root", !imperfectSteps.contains(node.id) else { return false }
        return items(for: node.id).filter { !imperfectItems.contains($0.id) }.count < 2
            || [node.title, node.rule, node.example].contains(where: mentionsImperfect)
    }.map(\.id))

    /// The imperfect lesson's own steps, which teach it.
    static let imperfectSteps: Set<String> = Set(steps(of: byID["imperfect"]!).map(\.id))

    /// Whether a text uses the imperfect or pluperfect subjunctive (viniera, tuviese, hubiera venido).
    static func mentionsImperfect(_ text: String) -> Bool {
        MoodTenseLabels.verbs(in: text).contains { $0.base == .subjunctiveImperfect }
    }
    private static let titlesWithImperfect: Set<String> = Set(nodes.filter { !imperfectSteps.contains($0.id) && mentionsImperfect($0.title) }.map(\.id))

    /// A step's title as the learner may see it: one that names an imperfect form stays hidden until the imperfect lesson.
    static func title(of node: MoodNode, progress: MoodMapProgress) -> String {
        progress.hidesImperfect && titlesWithImperfect.contains(node.id) ? "A step that uses the imperfect subjunctive" : node.title
    }

    /// The cards of a step the learner can see now: imperfect ones only once it has been introduced.
    static func items(for node: String, progress: MoodMapProgress) -> [MoodItem] {
        let all = items(for: node)
        guard progress.of(imperfectIntro).right < MoodMapProgress.opensChildren else { return all }
        let plain = all.filter { !imperfectItems.contains($0.id) }
        return plain.isEmpty ? all : plain
    }
    /// A lesson's steps in order: the lesson itself, then its rules, things to watch out for and fine points.
    /// Each rule is followed by the caveats that hang off it, so the page reads from the rule down to its fine points.
    static func steps(of lesson: MoodNode) -> [MoodNode] {
        guard lesson.level <= 2 else { return [lesson] }
        var out = [lesson]
        func walk(_ node: MoodNode) {
            out.append(node)
            children(of: node.id).sorted { $0.level < $1.level }.forEach(walk)
        }
        children(of: lesson.id).filter { $0.level > 2 }.sorted { $0.level < $1.level }.forEach(walk)
        return out
    }

    /// The nodes in tree order: each family followed by its rules, switches and exceptions.
    static var treeOrder: [MoodNode] {
        lessons.flatMap { $0.id == "root" ? [$0] : steps(of: $0) }
    }

    /// Three reasons to pick from after an answer: the right node and two neighbours (siblings first), in an order that is the same every time.
    /// Before the imperfect lesson, no reason names an imperfect form or a step that waits for it.
    static func reasons(for item: MoodItem, hideImperfect: Bool = false) -> [MoodNode] {
        guard let node = byID[item.node] else { return [] }
        let pool = hideImperfect && !imperfectSteps.contains(node.id)
            ? nodes.filter { !titlesWithImperfect.contains($0.id) && !usesImperfect.contains($0.id) && !imperfectSteps.contains($0.id) }
            : nodes
        let siblings = pool.filter { $0.parent == node.parent && $0.id != node.id }
        let sameLevel = pool.filter { $0.level == node.level && $0.id != node.id && $0.parent != node.parent }
        let fallback = pool.filter { $0.id != node.id && !siblings.contains($0) && !sameLevel.contains($0) }
        let seed = item.id.hashValueStable
        func rotated(_ list: [MoodNode]) -> [MoodNode] { list.isEmpty ? [] : Array(list[(seed % list.count)...] + list[..<(seed % list.count)]) }
        let picks = Array((rotated(siblings) + rotated(sameLevel) + fallback).prefix(2))
        let all = picks + [node]
        let shift = seed % all.count
        return Array(all[shift...] + all[..<shift])
    }
}

private extension String {
    /// A hash that is the same on every launch (Swift's own hashValue is seeded per run).
    var hashValueStable: Int { unicodeScalars.reduce(5381) { ($0 &* 33 &+ Int($1.value)) & 0x7fffffff } }
}
