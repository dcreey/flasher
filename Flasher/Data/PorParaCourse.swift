import Foundation

/// One step of the por/para course: the simple rules at the top, then a lesson per line of the rules, each with its watch-outs.
/// The rules and their sources are in docs/conjugation-drill/por-para-rules.md and docs/research/reports.
struct PorParaStep: Identifiable, Hashable {
    let id: String
    /// 1 the simple rules, 2 a lesson, 4 a watch-out, 5 a fine point (the same scale as the subjunctive course).
    let level: Int
    let parent: String?
    let title: String
    let rule: String
    /// The answer to "Why?" on a card from this step.
    let reason: String
    /// Why the rule works the way it does.
    let why: String
    let examples: [PorParaExample]
    /// Where the idea comes from, in a line.
    let source: String

    static let levelNames = [1: "The simple rules", 2: "Lesson", 4: "Watch out", 5: "Fine point"]
    var levelName: String { Self.levelNames[level] ?? "" }
}

struct PorParaExample: Hashable {
    let spanish: String
    let english: String
}

/// A card: a sentence with a gap and the prepositions to choose from.
struct PorParaCard: Identifiable, Hashable {
    let id: String
    let step: String
    /// The situation, in English.
    let context: String
    /// The sentence with ___ for the gap.
    let sentence: String
    let choices: [String]
    let correct: Set<Int>
    /// Why the answer is right, shown after answering.
    let note: String
    /// Reasons written for this card (the simple rules' own cards), with the index of the right one.
    var why: [String] = []
    var whyRight = 0

    var bothWork: Bool { correct.count > 1 }

    /// The sentence with an answer in place; "nothing" leaves the gap out.
    func filled(_ choice: Int) -> String {
        let word = choices[choice] == PorParaCourse.nothing ? "" : choices[choice]
        return sentence.replacingOccurrences(of: "___", with: word)
            .replacingOccurrences(of: "  ", with: " ")
            .replacingOccurrences(of: " .", with: ".")
            .replacingOccurrences(of: " ,", with: ",")
    }
}

enum PorParaCourse {
    static let nothing = "(nothing)"

    /// The simple rules, as the guide teaches them.
    static let question = "Para → where it ends up: the Place it's headed, the Person who gets it, the Point in time it's due, the Purpose, the Perspective it's judged from. Por → what drives it, or what it passes through: the reason, the thing you're after, someone you do it for, the route, the means, the price, the time."

    // MARK: Steps

    static let steps: [PorParaStep] = [
        PorParaStep(id: "root", level: 1, parent: nil, title: "The simple rules",
                    rule: question,
                    reason: "The simple rules",
                    why: "Para is por with a added on, and a means \"to\". It was made to point where something ends up, and it still does. That gives the five P's: the Place it's headed, the Person who gets it, the Point in time it's due, the Purpose, and the Perspective it's judged from. Por is the older, wider word: what drives the action (the reason, the thing you're after, someone you do it for) or what it passes through (the route, the means, the price, the time). Reason or purpose? If it's already there and pushing, it's por. If it's not there yet and it's what you're aiming to produce, it's para. Memorise three phrases: para siempre, para nada, no es para tanto.",
                    examples: [
                        PorParaExample(spanish: "Salgo para Guadalajara.", english: "I'm leaving for Guadalajara. (the Place it's headed: para)"),
                        PorParaExample(spanish: "Este regalo es para ti.", english: "This present is for you. (the Person who gets it: para)"),
                        PorParaExample(spanish: "Gracias por la ayuda.", english: "Thanks for the help. (the reason that drives it: por)"),
                        PorParaExample(spanish: "Caminamos por el centro.", english: "We walked around downtown. (what it passes through: por)")],
                    source: "This app's summary of Delbecque (por in contact with the action, para projected beyond it), Matte Bon (por already there, para new) and the history of para (por + a, \"to\"). Tested blind on 500 real Tatoeba sentences."),

        // Para: where it ends up (the five P's)
        PorParaStep(id: "dest", level: 2, parent: "root", title: "Place: where it's headed",
                    rule: "Para + a place is where the action is headed: the destination.",
                    reason: "Place: where it's headed",
                    why: "This is para's first job, and the oldest one: the a inside it means \"to\". Salir, partir, irse, el tren, el vuelo: when you name where they're going, use para. With ir and llegar, plain a is the everyday way (voy a Monterrey); para stresses the direction (ya voy para allá, \"I'm on my way there\").",
                    examples: [
                        PorParaExample(spanish: "Mañana salimos para Oaxaca.", english: "Tomorrow we leave for Oaxaca."),
                        PorParaExample(spanish: "¿Este camión va para el centro?", english: "Does this bus go downtown?"),
                        PorParaExample(spanish: "Ya voy para allá.", english: "I'm on my way there.")],
                    source: "Every grammar lists it first (destination). History: para began as a destination marker (Torres Cacoullos & Bauman 2018)."),
        PorParaStep(id: "dest.route", level: 2, parent: "root", title: "The route: through or around a place",
                    rule: "Por + a place is the route or the area the action moves through, not where it ends.",
                    reason: "Por: the route it passes through",
                    why: "Para looks ahead to the end of the trip. Por is in the middle of it: the street you walk along, the town you pass through, the area you wander around. Compare: salimos para Puebla (Puebla is where we're going) and pasamos por Puebla (we went through Puebla on the way).",
                    examples: [
                        PorParaExample(spanish: "Paseamos por el parque.", english: "We strolled through the park."),
                        PorParaExample(spanish: "Pasamos por Puebla.", english: "We went through Puebla."),
                        PorParaExample(spanish: "Las llaves están por aquí.", english: "The keys are around here somewhere.")],
                    source: "Path vs destination: every grammar; cognitive grammar's core image (Delbecque 1996; Kissling & Tyler 2018)."),

        PorParaStep(id: "who", level: 2, parent: "root", title: "Person: who gets it",
                    rule: "Para + a person is who gets it or uses it. It's also who you work for.",
                    reason: "Person: who gets it",
                    why: "The thing or the work ends up with that person. A present para ti is yours. Trabajo para una empresa: the company gets my work. It's the same with things made for a kind of user: un libro para niños.",
                    examples: [
                        PorParaExample(spanish: "Estas flores son para mi mamá.", english: "These flowers are for my mom."),
                        PorParaExample(spanish: "Trabajo para una empresa de Monterrey.", english: "I work for a company in Monterrey."),
                        PorParaExample(spanish: "Es un libro para niños.", english: "It's a book for children.")],
                    source: "Recipient and employer uses: every grammar (Butt & Benjamin §34.14 via university handouts)."),
        PorParaStep(id: "who.sake", level: 2, parent: "root", title: "Someone you do it for",
                    rule: "Por + a person is who you do it for the sake of, or in place of. They don't get anything; they're the reason.",
                    reason: "Por: someone you do it for",
                    why: "Ask: does the person get it, or are they the reason? Lo hice para ti: you get it (a cake, a song). Lo hice por ti: you're why I did it, or I did it in your place. Moms, causes and countries get por: lo hago por mis hijos, murió por su país. This is por's old Latin sense, \"on behalf of\".",
                    examples: [
                        PorParaExample(spanish: "Lo hice por ti.", english: "I did it for you. (for your sake)"),
                        PorParaExample(spanish: "Lo hice para ti.", english: "I made it for you. (you get it)"),
                        PorParaExample(spanish: "Hoy trabajo por Ana, que está enferma.", english: "Today I'm working in Ana's place; she's sick.")],
                    source: "Minimal pair lo hice por / para ti (KU handout). For-whose-sake por as its own class: challenge round, from Latin pro (Cadiñanos & Enrique-Arias 2022)."),

        PorParaStep(id: "when", level: 2, parent: "root", title: "Point in time: when it's due",
                    rule: "Para + a time is the deadline: by then.",
                    reason: "Point in time: when it's due",
                    why: "A deadline is a point in time the work is aimed at, so it gets para: la tarea es para el lunes. Para entonces means \"by then\". It never means how long something lasts: that's por, or no preposition at all.",
                    examples: [
                        PorParaExample(spanish: "La tarea es para el lunes.", english: "The homework is due Monday."),
                        PorParaExample(spanish: "Lo necesito para mañana.", english: "I need it by tomorrow."),
                        PorParaExample(spanish: "Para entonces ya habremos terminado.", english: "By then we'll have finished.")],
                    source: "Deadline use: every grammar; Wiktionary para (para fin de mes)."),
        PorParaStep(id: "when.span", level: 2, parent: "root", title: "The time: how long, and parts of the day",
                    rule: "For how long something lasts, use nothing or por: estuve dos horas, or por dos horas. Parts of the day take por: por la mañana.",
                    reason: "Por: the time it passes through",
                    why: "A stretch of time is something the action passes through, the way a walk passes through a street, so it's por. Most often Spanish uses no preposition at all: viví tres años en Puebla. Por is normal in Mexico (salió por un mes). English \"for two hours\" is never para.",
                    examples: [
                        PorParaExample(spanish: "Estudié dos horas.", english: "I studied for two hours."),
                        PorParaExample(spanish: "Se fue por un mes.", english: "He went away for a month."),
                        PorParaExample(spanish: "Trabajo por la mañana.", english: "I work in the morning.")],
                    source: "Duration with por: Diccionario del español de México (salió por un mes); Fundéu accepts it. Learner data: duration is a frequent English-speaker error (Lafford & Ryan 1995, via Jiménez 2017)."),
        PorParaStep(id: "when.clock", level: 5, parent: "when", title: "Not in the rules: un cuarto para las ocho",
                    rule: "In Mexico and most of Latin America, minutes before the hour take para: son diez para las cinco. Spain says las cinco menos diez.",
                    reason: "It's the hour the minutes count down to",
                    why: "This isn't covered by the rules: learn it as a pattern. Spain counts down with menos instead.",
                    examples: [
                        PorParaExample(spanish: "Son diez para las cinco.", english: "It's ten to five."),
                        PorParaExample(spanish: "Llegó a un cuarto para las ocho.", english: "She arrived at a quarter to eight.")],
                    source: "RAE Ortografía and DPD hora (via quoting pages): used in almost all of America. DEM: faltan diez minutos para las cinco."),
        PorParaStep(id: "when.siempre", level: 4, parent: "when.span", title: "Memorise: para siempre",
                    rule: "Forever is para siempre, even though it's a length of time.",
                    reason: "It's the set phrase para siempre",
                    why: "Learn it as a phrase. You can picture it as a deadline pushed out to the end of time. Por siempre exists too, but only in poems and songs (por siempre jamás).",
                    examples: [
                        PorParaExample(spanish: "Te voy a querer para siempre.", english: "I'll love you forever."),
                        PorParaExample(spanish: "Se fue para siempre.", english: "He left for good.")],
                    source: "Flagged as a contradiction of \"duration: por\" in the challenge round."),

        PorParaStep(id: "use", level: 2, parent: "root", title: "Purpose: what it's meant to produce",
                    rule: "Para + a verb is the purpose: in order to. Para + a thing is its use. Para que + subjunctive is \"so that\".",
                    reason: "Purpose: what it's meant to produce",
                    why: "A purpose is where the action ends up: the result it's meant to produce. Estudio para aprender: learning is what the studying produces. Sirve para abrir latas: that's its use. ¿Para qué? asks what something is for; ¿por qué? asks what caused it.",
                    examples: [
                        PorParaExample(spanish: "Ahorro para comprar un carro.", english: "I'm saving to buy a car."),
                        PorParaExample(spanish: "¿Para qué sirve esto?", english: "What's this for?"),
                        PorParaExample(spanish: "Te lo explico para que lo entiendas.", english: "I'm explaining it so that you understand.")],
                    source: "Purpose and use: every grammar. Para que + subjunctive: see the subjunctive course."),
        PorParaStep(id: "use.motive", level: 4, parent: "use", title: "Por + a verb: both can work",
                    rule: "Before a verb, por can also give a purpose: lo hice por ayudarte. Para is the neutral choice; por makes the aim sound like a motive pushing you.",
                    reason: "It's a purpose before a verb: both work",
                    why: "Until about the 1700s, por was Spanish's purpose word; para took over later, so por still turns up. Para ayudarte presents helping as the goal. Por ayudarte presents it as what moved you to act. Use para when in doubt. Nobody will mark por wrong here.",
                    examples: [
                        PorParaExample(spanish: "Lo hice para ayudarte.", english: "I did it to help you. (the goal)"),
                        PorParaExample(spanish: "Lo hice por ayudarte.", english: "I did it to help you. (that's what moved me)"),
                        PorParaExample(spanish: "Luchan por ser libres.", english: "They're fighting to be free.")],
                    source: "Para as \"la forma neutra\" for purpose (D'Antonio, Albiol-Martín & Priego-Casanova 2025). Purpose moving from por to para from the 18th century (Torres Cacoullos & Bauman 2018)."),
        PorParaStep(id: "use.porque", level: 5, parent: "use", title: "Para que (so that) or porque (because)",
                    rule: "Para que + subjunctive gives the purpose: so that. Porque + indicative gives the cause: because.",
                    reason: "Para que is the purpose; porque is the cause",
                    why: "It's reason vs purpose again. Para que points ahead to a result you want (subjunctive, since it hasn't happened). Porque points back to what caused it (indicative, since you claim it's true).",
                    examples: [
                        PorParaExample(spanish: "Hablo despacio para que me entiendas.", english: "I speak slowly so that you understand me."),
                        PorParaExample(spanish: "Hablo despacio porque estoy cansado.", english: "I'm speaking slowly because I'm tired.")],
                    source: "DPD porque, por que (via quoting pages). Mood: the subjunctive course."),

        PorParaStep(id: "measure", level: 2, parent: "root", title: "Perspective: what it's judged from",
                    rule: "Para + a person or a standard is what something is judged against: para mí (in my opinion), para su edad, para ser tan joven.",
                    reason: "Perspective: what it's judged from",
                    why: "Here it ends up as a yardstick. Para mí lands the judgement on me: that's how it looks from where I stand. Para ser tan joven compares him with what you'd expect at that age.",
                    examples: [
                        PorParaExample(spanish: "Para mí, es la mejor película.", english: "For me, it's the best movie."),
                        PorParaExample(spanish: "Habla muy bien para ser tan joven.", english: "He speaks very well for someone so young."),
                        PorParaExample(spanish: "Hace calor para ser enero.", english: "It's hot for January.")],
                    source: "Opinion and comparison uses: Butt & Benjamin §34.14.2(d) (via search snippet); university handouts."),
        PorParaStep(id: "measure.estar", level: 5, parent: "fixed", title: "Not in the rules: estar para / por + verb",
                    rule: "Estar para + verb means \"about to\"; no estar para means \"not in the mood for\". In Mexico, estar por + verb also means \"about to\".",
                    reason: "Estar para (or por in Mexico) + a verb: about to",
                    why: "Something about to happen is just ahead, so para fits. Mexico and much of Latin America say está por llover too, and the RAE accepts it. Outside these phrases, estar por + verb means \"still to be done\" (the next lessons).",
                    examples: [
                        PorParaExample(spanish: "El tren está para salir.", english: "The train is about to leave."),
                        PorParaExample(spanish: "Está por llover.", english: "It's about to rain. (Mexico)"),
                        PorParaExample(spanish: "Hoy no estoy para bromas.", english: "I'm not in the mood for jokes today.")],
                    source: "DPD estar (via search snippet): estar para is the general form, estar por in some American countries. DEM: estar por = a punto de."),

        // Part 2: por, behind the action or along the way
        PorParaStep(id: "cause", level: 2, parent: "root", title: "The reason: what drives it",
                    rule: "Por + a thing or a verb is the cause or the reason: because of.",
                    reason: "Por: the reason that drives it",
                    why: "A cause comes before the action and pushes it, so it's behind the action, not ahead. Gracias por: the favour caused the thanks. Por la lluvia: the rain caused it. ¿Por qué? asks for the cause, and por eso means \"that's why\".",
                    examples: [
                        PorParaExample(spanish: "Gracias por todo.", english: "Thanks for everything."),
                        PorParaExample(spanish: "Cancelaron el partido por la lluvia.", english: "They called off the game because of the rain."),
                        PorParaExample(spanish: "Lo despidieron por llegar tarde.", english: "They fired him for being late.")],
                    source: "Cause: every grammar. Por as \"what comes before\" (Matte Bon, Geométrica explosión, p. 310: \"las causas son lo que hay antes\")."),

        PorParaStep(id: "means", level: 2, parent: "root", title: "The means, and who did it",
                    rule: "Por + a thing is the means: por teléfono, por correo. In the passive, por names who did it: escrito por.",
                    reason: "Por: the means, or who did it",
                    why: "The means is the channel the action passes through, like a route. The doer in a passive is the force behind the action. Both sit inside or behind the action, so they're por.",
                    examples: [
                        PorParaExample(spanish: "Te llamo por teléfono.", english: "I'll call you on the phone."),
                        PorParaExample(spanish: "Te lo mando por correo.", english: "I'll send it to you by mail."),
                        PorParaExample(spanish: "Fue escrito por García Márquez.", english: "It was written by García Márquez.")],
                    source: "Means and passive agent: every grammar; KU and Bowdoin handouts."),

        PorParaStep(id: "swap", level: 2, parent: "root", title: "The price: what it's traded for",
                    rule: "Por + a price or a thing is what it's exchanged for. It's also rates: por hora, por ciento, dos por tres.",
                    reason: "Por: the price or the swap",
                    why: "In a trade, the two sides stand in for each other: the money for the book, one shirt for another. That's por's Latin sense \"in exchange for, in place of\". Rates are the same: so much for each hour.",
                    examples: [
                        PorParaExample(spanish: "Lo compré por 200 pesos.", english: "I bought it for 200 pesos."),
                        PorParaExample(spanish: "Cambié la camisa por otra.", english: "I swapped the shirt for another one."),
                        PorParaExample(spanish: "Iba a 100 kilómetros por hora.", english: "He was going 100 kilometres an hour.")],
                    source: "Exchange, price and rate: every grammar. From Latin pro, \"in exchange for\"."),
        PorParaStep(id: "swap.pay", level: 4, parent: "swap", title: "Pagar: the money, then por + what you bought",
                    rule: "Pagar takes the money or the bill directly, then por + what it bought: pagué 200 pesos por el libro; pagué la cena.",
                    reason: "It's what the money paid for",
                    why: "English \"pay for\" tempts para, but the thing bought is what the money was traded for, so it's por. With no amount, the bill is the plain object: pagar la cuenta, pagar la cena.",
                    examples: [
                        PorParaExample(spanish: "Pagué 200 pesos por el libro.", english: "I paid 200 pesos for the book."),
                        PorParaExample(spanish: "Yo pago la cena.", english: "I'll pay for dinner.")],
                    source: "Pagar + price + por: learner-error data (pagué diez dólares para el libro is a frequent error; challenge round)."),

        // Part 3: going after something
        PorParaStep(id: "after", level: 2, parent: "root", title: "The thing you're after",
                    rule: "Por names what you go and get, fight for, vote for, choose or long for: voy por pan, luchan por la libertad, voté por ella, estoy loco por verte.",
                    reason: "Por: the thing you're after",
                    why: "Wanting something is a reason: it drives you. The bread is why you go to the store, so it's por, even though it can look like where things end up. It's por's oldest sense, from before para existed. Grammarians call it \"goal and motive at once\". It covers ir, venir and mandar por (to fetch), luchar, pelear and votar por, optar and apostar por, preguntar por (ask about), and loco, ansioso por.",
                    examples: [
                        PorParaExample(spanish: "Voy por las tortillas.", english: "I'm going to get the tortillas."),
                        PorParaExample(spanish: "Luchan por la libertad.", english: "They're fighting for freedom."),
                        PorParaExample(spanish: "Voté por ella.", english: "I voted for her."),
                        PorParaExample(spanish: "Pregunté por ti.", english: "I asked about you.")],
                    source: "Melis (1992): por is \"meta y móvil al mismo tiempo\". Company & Flores (2014): in ir por, por introduces the cause of the movement. NGLE: votar, optar, apostar por denote \"inclinación hacia algo\" (via search snippet)."),
        PorParaStep(id: "after.spain", level: 5, parent: "after", title: "Not in the rules: ir a por in Spain",
                    rule: "In Spain you'll hear voy a por pan. In Mexico and Colombia it's voy por pan.",
                    reason: "Spain adds a; Latin America says ir por",
                    why: "Spain added a to mark the destination that por leaves out. The RAE doesn't call it wrong, but in Latin America it sounds odd, so say voy por.",
                    examples: [
                        PorParaExample(spanish: "Voy por pan. (Mexico, Colombia)", english: "I'm going to get bread."),
                        PorParaExample(spanish: "Voy a por pan. (Spain)", english: "I'm going to get bread.")],
                    source: "DPD ir and a (via quoting pages); FundéuRAE; DEM (voy por agua)."),

        // Part 4: neither, and set phrases
        PorParaStep(id: "none", level: 2, parent: "root", title: "Not in the rules: English \"for\" with no preposition",
                    rule: "Buscar, esperar, pedir and agradecer already mean \"look for, wait for, ask for, thank for\". The thing goes straight after the verb.",
                    reason: "The verb already means \"for\": no preposition",
                    why: "English needs \"for\" with these verbs; Spanish builds it into the verb. Busco mis llaves, te espero, pido un café, te agradezco la ayuda. (Agradecer por is common in Latin America too, and the RAE accepts it, but the plain object is the standard form.)",
                    examples: [
                        PorParaExample(spanish: "Busco mis llaves.", english: "I'm looking for my keys."),
                        PorParaExample(spanish: "Te espero aquí.", english: "I'll wait for you here."),
                        PorParaExample(spanish: "Pedí un café.", english: "I asked for a coffee."),
                        PorParaExample(spanish: "Te agradezco la ayuda.", english: "Thank you for the help.")],
                    source: "DPD esperar, pedir, agradecer (via search snippets); learner-error data on the \"for\" trap."),

        PorParaStep(id: "fixed", level: 2, parent: "root", title: "Not in the rules: set phrases",
                    rule: "Some phrases are fixed: por favor, por fin, por supuesto, por si acaso, por lo menos, por cierto, por ejemplo; para colmo, para nada, no es para tanto.",
                    reason: "It's a set phrase",
                    why: "Some of these fit the rules if you squint (por si acaso: in case, a cause; para colmo: on top of it all, the last step), but it's quicker to learn them as phrases.",
                    examples: [
                        PorParaExample(spanish: "Por fin llegaste.", english: "You finally got here."),
                        PorParaExample(spanish: "Lleva un suéter, por si acaso.", english: "Take a sweater, just in case."),
                        PorParaExample(spanish: "No es para tanto.", english: "It's not that big a deal."),
                        PorParaExample(spanish: "Y para colmo, empezó a llover.", english: "And to top it all off, it started raining.")],
                    source: "Diccionario del español de México (por fin, por si acaso, por lo menos, para colmo)."),
        PorParaStep(id: "fixed.quedar", level: 4, parent: "fixed", title: "Not in the rules: está por hacer",
                    rule: "Estar por or quedar por + a verb means the job is still to be done: la casa está por limpiar.",
                    reason: "Por + a verb: still to be done",
                    why: "This one isn't covered by the rules: the job is still ahead, yet it takes por. Learn it as a pattern: quedan tres capítulos por leer, \"three chapters left to read\".",
                    examples: [
                        PorParaExample(spanish: "La cocina está por barrer.", english: "The kitchen still needs sweeping."),
                        PorParaExample(spanish: "Quedan tres capítulos por leer.", english: "There are three chapters left to read.")],
                    source: "DPD estar (via search snippet): aún está por escribirse. The strongest counterexample to every single rule in the research."),
    ]

    static let byID: [String: PorParaStep] = Dictionary(uniqueKeysWithValues: steps.map { ($0.id, $0) })
    static func children(of id: String) -> [PorParaStep] { steps.filter { $0.parent == id } }

    static let chapters: [(title: String, note: String, lessons: [String])] = [
        ("Para: where it ends up", "The five P's: Place, Person, Point in time, Purpose, Perspective.", ["dest", "who", "when", "use", "measure"]),
        ("Por: what drives it", "The reason, the thing you're after, someone you do it for.", ["cause", "after", "who.sake"]),
        ("Por: what it passes through", "The route, the means, the price, the time.", ["dest.route", "means", "swap", "when.span"]),
        ("Not in the rules", "Phrases and patterns to learn as they are.", ["none", "fixed"]),
    ]

    static let lessons: [PorParaStep] = [byID["root"]!] + chapters.flatMap(\.lessons).compactMap { byID[$0] }

    /// A lesson and its watch-outs and fine points, in order.
    static func steps(of lesson: PorParaStep) -> [PorParaStep] {
        lesson.id == "root" ? [lesson] : [lesson] + children(of: lesson.id).sorted { $0.level < $1.level }
    }

    // MARK: Cards

    private static let pp = ["por", "para"]
    private static func card(_ step: String, _ n: Int, _ context: String, _ sentence: String, _ answer: String, _ note: String,
                             choices: [String] = pp, also: String? = nil, why: [String] = [], whyRight: Int = 0) -> PorParaCard {
        var correct: Set<Int> = [choices.firstIndex(of: answer)!]
        if let also { correct.insert(choices.firstIndex(of: also)!) }
        return PorParaCard(id: "\(step).\(n)", step: step, context: context, sentence: sentence, choices: choices, correct: correct,
                           note: note, why: why, whyRight: whyRight)
    }

    private static let rootWhy = ["Para: where it ends up", "Por: what drives it, or what it passes through"]
    private static let none3 = ["por", "para", nothing]

    static let cards: [PorParaCard] = [
        // The simple rules
        card("root", 1, "Telling a friend about your trip.", "El viernes salgo ___ Mérida.", "para", "Mérida is where the trip ends up: the Place.", why: rootWhy, whyRight: 0),
        card("root", 2, "Handing over a present.", "Toma, esto es ___ ti.", "para", "You're the one who gets it: the Person.", why: rootWhy, whyRight: 0),
        card("root", 3, "Thanking a neighbour.", "Muchas gracias ___ la ayuda.", "por", "The help caused the thanks. It's behind the thanks, not ahead of it.", why: rootWhy, whyRight: 1),
        card("root", 4, "Describing a Sunday walk.", "Caminamos ___ el malecón.", "por", "The malecón is the route you walk along, not where you end up.", why: rootWhy, whyRight: 1),
        card("root", 5, "Your teacher reminds the class.", "El ensayo es ___ el jueves.", "para", "Thursday is the deadline the work is aimed at.", why: rootWhy, whyRight: 0),
        card("root", 6, "At the market.", "Compré tres mangos ___ veinte pesos.", "por", "The price is what the mangoes were traded for: por.", why: rootWhy, whyRight: 1),
        card("root", 7, "Explaining why you're saving.", "Ahorro ___ comprar una casa.", "para", "Buying a house is the result the saving is aimed at.", why: rootWhy, whyRight: 0),
        card("root", 8, "The match was called off.", "Suspendieron el partido ___ la lluvia.", "por", "The rain caused it: behind the action.", why: rootWhy, whyRight: 1),

        // Where it's headed
        card("dest", 1, "At the bus station.", "¿A qué hora sale el camión ___ Querétaro?", "para", "Querétaro is where the bus is headed."),
        card("dest", 2, "Your brother texts that he's coming.", "Ya voy ___ tu casa.", "para", "Your house is where he's headed."),
        card("dest", 3, "Announcing your move.", "Nos mudamos ___ Bogotá en marzo.", "para", "Bogotá is the destination of the move."),
        card("dest", 4, "Airport screen.", "Vuelo 302 ___ Cancún: puerta 12.", "para", "Cancún is where the flight is going."),
        card("dest", 5, "Leaving the office.", "Me voy ___ la casa, ya es tarde.", "para", "Home is where you're headed."),
        // Through or around
        card("dest.route", 1, "Giving directions.", "Sigue ___ esta calle hasta el semáforo.", "por", "The street is the route you follow, not the end of the trip."),
        card("dest.route", 2, "A road trip to Puebla.", "De camino pasamos ___ Cholula.", "por", "Cholula is a place you went through on the way."),
        card("dest.route", 3, "Looking for your phone.", "Mi celular debe estar ___ aquí.", "por", "Por aquí: somewhere around here, an area, not a destination."),
        card("dest.route", 4, "Weekend plans.", "Vamos a pasear ___ el centro.", "por", "Downtown is the area you'll wander around."),
        card("dest.route", 5, "Packing for a trip to the coast.", "Mañana salimos ___ la playa.", "para", "The beach is where you're headed. Mixed in so you tell the two apart."),

        // Who gets it
        card("who", 1, "At a birthday party.", "Este pastel es ___ la abuela.", "para", "Grandma gets the cake."),
        card("who", 2, "Talking about your job.", "Trabajo ___ una empresa de software.", "para", "The company gets your work: it's who you work for."),
        card("who", 3, "In a bookshop.", "Busco un libro ___ niños de cinco años.", "para", "Five-year-olds are the readers it's meant for."),
        card("who", 4, "Leaving a note.", "Hay un mensaje ___ ti en la mesa.", "para", "The message is meant for you."),
        // For their sake
        card("who.sake", 1, "A mother explains why she works so hard.", "Todo lo que hago, lo hago ___ mis hijos.", "por", "Her kids are the reason, not the ones receiving each thing she does."),
        card("who.sake", 2, "A colleague is sick.", "Hoy trabajo ___ Ana; está enferma.", "por", "You work in Ana's place. She doesn't receive the work."),
        card("who.sake", 3, "Pointing to a cake you baked.", "Lo hice ___ ti. ¿Te gusta?", "para", "You get the cake: para. Mixed in so you tell the two apart."),
        card("who.sake", 4, "About a national hero.", "Dio la vida ___ su país.", "por", "His country was the cause he died for."),
        card("who.sake", 5, "Making a toast.", "¡Brindemos ___ los novios!", "por", "You drink in their honour: for their sake."),

        // When it's due
        card("when", 1, "Your boss asks for a report.", "Necesito el informe ___ el viernes.", "para", "Friday is the deadline."),
        card("when", 2, "Planning ahead.", "___ diciembre ya vamos a estar en la casa nueva.", "Para", "Para diciembre: by December, a point the plan is aimed at.", choices: ["Por", "Para"]),
        card("when", 3, "Booking a table.", "Quiero una mesa ___ las ocho.", "para", "Eight o'clock is the time the booking is for."),
        card("when", 4, "A friend is late with a favour.", "¿Lo tienes ___ mañana?", "para", "Tomorrow is the deadline."),
        // How long
        card("when.span", 1, "Your schedule.", "Tengo clases ___ la mañana.", "por", "The morning is the stretch of time the classes fill."),
        card("when.span", 2, "About a trip.", "Se fue a Chicago ___ un mes.", "por", "A month is how long the trip lasted, not a deadline. (No preposition works too.)"),
        card("when.span", 3, "What you did yesterday.", "Estudié ___ tres horas.", "por", "How long you studied: por, or nothing at all. Never para.", choices: none3, also: nothing),
        card("when.span", 4, "A homework reminder.", "La tarea es ___ el lunes.", "para", "Monday is the deadline, not a stretch of time. Mixed in so you tell the two apart."),
        card("when.span", 5, "Evening plans.", "Nos vemos ___ la noche.", "por", "The night is the part of the day when it happens."),
        // Clock
        card("when.clock", 1, "Someone asks the time in Mexico City.", "Son diez ___ las cinco.", "para", "The minutes count down to five: in Latin America that's para."),
        card("when.clock", 2, "Telling a friend when the movie starts.", "Empieza a un cuarto ___ las nueve.", "para", "Un cuarto para las nueve: a quarter to nine."),
        card("when.clock", 3, "Your bus leaves soon.", "Sale a veinte ___ las siete.", "para", "Twenty to seven."),
        // Para siempre
        card("when.siempre", 1, "A love song.", "Te voy a querer ___ siempre.", "para", "Forever is para siempre: a set phrase."),
        card("when.siempre", 2, "He moved away.", "Se fue del pueblo ___ siempre.", "para", "For good: para siempre."),
        card("when.siempre", 3, "How long you were in line.", "Esperé en la fila ___ una hora.", "por", "An ordinary length of time takes por or nothing. Only siempre takes para.", choices: none3, also: nothing),

        // What it's for
        card("use", 1, "Why you're learning Spanish.", "Estudio español ___ hablar con mis suegros.", "para", "Talking with your in-laws is what the studying is aimed at."),
        card("use", 2, "In the kitchen drawer.", "Esto sirve ___ abrir latas.", "para", "Opening cans is what it's for."),
        card("use", 3, "Asking about a gadget.", "¿___ qué es esto?", "Para", "¿Para qué? asks what something is for.", choices: ["Por", "Para"]),
        card("use", 4, "You need to buy something.", "Necesito una caja ___ los libros.", "para", "The books are what the box is for."),
        card("use", 5, "You're calling a friend.", "Te llamo ___ invitarte a la fiesta.", "para", "Inviting you is the purpose of the call."),
        // Both work before a verb
        card("use.motive", 1, "Explaining a favour.", "Lo hice ___ ayudarte.", "para", "Both work. Para: helping was the goal. Por: helping is what moved you.", also: "por"),
        card("use.motive", 2, "A protest.", "Luchan ___ ser libres.", "por", "Both work. Por: freedom is what drives them. Para: it's the goal.", also: "para"),
        card("use.motive", 3, "Working late.", "Me quedé en la oficina ___ terminar el trabajo.", "para", "Both work: para is neutral, por makes finishing sound like the motive.", also: "por"),
        card("use.motive", 4, "Why he skipped the party.", "No vino ___ no molestar.", "por", "Both work. Por no molestar (so as not to bother anyone) is very common.", also: "para"),
        // Para que or porque
        card("use.porque", 1, "Speaking slowly to a learner.", "Hablo despacio ___ me entiendas.", "para que", "So that you understand: a purpose, with the subjunctive.", choices: ["para que", "porque"]),
        card("use.porque", 2, "Explaining why you're tired.", "Hablo despacio ___ estoy cansado.", "porque", "Because you're tired: a cause, with the indicative.", choices: ["para que", "porque"]),
        card("use.porque", 3, "Leaving the key.", "Te dejo la llave ___ puedas entrar.", "para que", "So that you can get in: a purpose.", choices: ["para que", "porque"]),
        card("use.porque", 4, "Why you didn't come.", "No fui ___ estaba enfermo.", "porque", "The cause: you were sick.", choices: ["para que", "porque"]),

        // What it's measured against
        card("measure", 1, "Giving your opinion.", "___ mí, es la mejor película del año.", "Para", "Para mí: from where I stand, in my opinion.", choices: ["Por", "Para"]),
        card("measure", 2, "Praising a young singer.", "Canta muy bien ___ ser tan joven.", "para", "Compared with what you'd expect at her age."),
        card("measure", 3, "Weather talk.", "Hace mucho calor ___ ser enero.", "para", "January is the standard you're comparing with."),
        card("measure", 4, "About a kid.", "Es muy alto ___ su edad.", "para", "His age is the yardstick."),
        // About to
        card("measure.estar", 1, "Grumpy after a long day.", "Hoy no estoy ___ bromas.", "para", "No estar para: not in the mood for."),
        card("measure.estar", 2, "Dark clouds over Mexico City.", "Está ___ llover.", "por", "In Mexico, estar por + verb means \"about to\". Estar para works too.", also: "para"),
        card("measure.estar", 3, "At the platform.", "El tren está ___ salir.", "para", "About to leave. In Mexico, está por salir is just as common.", also: "por"),

        // What caused it
        card("cause", 1, "Apologising.", "Perdón ___ llegar tarde.", "por", "Being late is what caused the apology."),
        card("cause", 2, "Bad news at work.", "Lo despidieron ___ faltar tanto.", "por", "Missing work so often is the reason he was fired."),
        card("cause", 3, "Asking a friend.", "¿___ qué no viniste?", "Por", "¿Por qué? asks for the cause.", choices: ["Por", "Para"]),
        card("cause", 4, "Explaining a choice.", "Llovía mucho; ___ eso no salimos.", "por", "Por eso: because of that."),
        card("cause", 5, "At the office party.", "Felicitaciones ___ el ascenso.", "por", "The promotion is what the congratulations are for: the cause."),
        // Means and agent
        card("means", 1, "Making plans.", "Te llamo ___ teléfono más tarde.", "por", "The phone is the channel the call goes through."),
        card("means", 2, "About a famous novel.", "Cien años de soledad fue escrita ___ García Márquez.", "por", "In the passive, por names who did it."),
        card("means", 3, "Sending documents.", "Te mando los papeles ___ correo.", "por", "The mail is the means."),
        card("means", 4, "Watching a game.", "Lo vimos ___ la tele.", "por", "The TV is the channel."),

        // Traded for
        card("swap", 1, "At a market stall.", "Me lo dejó ___ cien pesos.", "por", "A hundred pesos is what it was traded for."),
        card("swap", 2, "Returning a shirt.", "¿Me la puede cambiar ___ una talla más grande?", "por", "One shirt in exchange for another."),
        card("swap", 3, "On the highway.", "Iba a 120 kilómetros ___ hora.", "por", "A rate: so many kilometres for each hour."),
        card("swap", 4, "Maths homework.", "Dos ___ tres son seis.", "por", "Multiplication is por: \"two times three\"."),
        card("swap", 5, "A sale sign.", "Todo con 30 ___ ciento de descuento.", "por", "Por ciento: per cent."),
        // Pagar
        card("swap.pay", 1, "Talking about a purchase.", "Pagué 300 pesos ___ los boletos.", "por", "The tickets are what the money was traded for."),
        card("swap.pay", 2, "At dinner with friends.", "Hoy yo pago ___ la cena.", nothing, "The everyday way is yo pago la cena, with the bill as the plain object. Pago por la cena is fine too.", choices: none3, also: "por"),
        card("swap.pay", 3, "You overpaid.", "¿Cuánto pagaste ___ ese celular?", "por", "The phone is what the money paid for."),

        // Going after something
        card("after", 1, "Heading to the corner shop.", "Voy ___ las tortillas, ahorita vuelvo.", "por", "The tortillas are what you're going to get: por, the reason you're going."),
        card("after", 2, "A news report.", "Miles de personas luchan ___ sus derechos.", "por", "Fighting for something takes por."),
        card("after", 3, "After the election.", "¿___ quién votaste?", "Por", "Votar por: vote for someone.", choices: ["Por", "Para"]),
        card("after", 4, "Meeting your friend's mother.", "Tu mamá preguntó ___ ti.", "por", "Preguntar por: ask about someone."),
        card("after", 5, "Texting someone you miss.", "Estoy loco ___ verte.", "por", "Loco por: dying to, crazy about."),
        card("after", 6, "A tough decision.", "Al final optó ___ la carrera de medicina.", "por", "Optar por: opt for, choose."),
        card("after", 7, "Someone's sick at home.", "Mandaron ___ el médico.", "por", "Mandar por: send for, send someone to fetch."),
        // Ir a por
        card("after.spain", 1, "You're in Madrid.", "Voy ___ pan.", "a por", "Both are heard in Spain; voy a por pan is very common there.", choices: ["por", "a por"], also: "por"),
        card("after.spain", 2, "You're in Monterrey.", "Voy ___ pan.", "por", "In Mexico it's voy por pan. A por sounds Spanish.", choices: ["por", "a por"]),
        card("after.spain", 3, "You're in Medellín.", "Ya vengo, voy ___ el carro.", "por", "In Colombia, too: voy por el carro.", choices: ["por", "a por"]),

        // Nothing
        card("none", 1, "You can't find them.", "Busco ___ mis llaves.", nothing, "Buscar already means \"look for\": busco mis llaves.", choices: none3),
        card("none", 2, "Meeting a friend.", "Te espero ___ en la entrada.", nothing, "Esperar already means \"wait for\": te espero en la entrada.", choices: none3),
        card("none", 3, "Ordering at a café.", "Voy a pedir ___ un café con leche.", nothing, "Pedir already means \"ask for\": pedir un café.", choices: none3),
        card("none", 4, "A thank-you note.", "Le agradezco ___ su paciencia.", nothing, "The standard form is le agradezco su paciencia. Agradecer por is common in Latin America and the RAE accepts it.", choices: none3, also: "por"),
        card("none", 5, "Mixed in.", "Gracias ___ tu paciencia.", "por", "Gracias does take por: the patience caused the thanks.", choices: none3),
        card("none", 6, "Mixed in.", "Pagué mucho ___ este sofá.", "por", "Pagar + an amount takes por + the thing bought.", choices: none3),

        // Set phrases
        card("fixed", 1, "Ordering.", "Dos tacos, ___ favor.", "por", "Por favor: please."),
        card("fixed", 2, "The bus is very late.", "¡___ fin llegó el camión!", "Por", "Por fin: finally.", choices: ["Por", "Para"]),
        card("fixed", 3, "Before a trip.", "Llévate un paraguas, ___ si acaso.", "por", "Por si acaso: just in case."),
        card("fixed", 4, "Calming someone down.", "Tranquilo, no es ___ tanto.", "para", "No es para tanto: it's not that big a deal."),
        card("fixed", 5, "A terrible day.", "Perdí el camión y, ___ colmo, empezó a llover.", "para", "Para colmo: to top it all off."),
        card("fixed", 6, "Agreeing.", "¿Vienes? —¡___ supuesto!", "Por", "Por supuesto: of course.", choices: ["Por", "Para"]),
        card("fixed", 7, "Disagreeing strongly.", "¿Te molesta? —No, ___ nada.", "para", "Para nada: not at all."),
        // Still to be done
        card("fixed.quedar", 1, "Looking around the house.", "La cocina todavía está ___ barrer.", "por", "Estar por + verb: still to be done."),
        card("fixed.quedar", 2, "Reading for class.", "Me quedan dos capítulos ___ leer.", "por", "Quedar por + verb: left to do."),
        card("fixed.quedar", 3, "Before the guests arrive.", "Todavía hay mucho ___ hacer.", "por", "Mucho por hacer: a lot still to do."),
    ]

    static func cards(for step: String) -> [PorParaCard] { cards.filter { $0.step == step } }

    /// The reasons offered on a card: its own, or its step's reason plus two from steps it's easy to confuse with.
    static func reasons(for card: PorParaCard) -> [(id: String, title: String)] {
        if !card.why.isEmpty { return card.why.enumerated().map { ("why\($0.offset)", $0.element) } }
        guard let step = byID[card.step] else { return [] }
        // Prefer steps whose answer is the other preposition, so the reason has to be thought through
        let rightWord = card.choices[card.correct.min() ?? 0].lowercased()
        let others = steps.filter { $0.id != step.id && $0.id != "root" }
        let opposite = others.filter { other in cards(for: other.id).first.map { c in c.choices[c.correct.min() ?? 0].lowercased() != rightWord } ?? false }
        let pool = (opposite.isEmpty ? others : opposite)
        let seed = stableHash(card.id) % 997
        var picked: [PorParaStep] = []
        if let sibling = pool.first(where: { $0.parent == step.id || $0.id == step.parent }) { picked.append(sibling) }
        for offset in 0..<pool.count where picked.count < 2 {
            let candidate = pool[(seed + offset * 7) % pool.count]
            if !picked.contains(candidate) { picked.append(candidate) }
        }
        let options = ([step] + picked).map { ($0.id, $0.reason) }
        // A fixed order per card, so the right one isn't always first
        return options.sorted { stableHash(card.id + $0.0) < stableHash(card.id + $1.0) }
    }

    /// The same number on every launch (String.hashValue changes per launch).
    static func stableHash(_ text: String) -> Int {
        text.unicodeScalars.reduce(5381) { (($0 << 5) &+ $0 &+ Int($1.value)) & 0x7fffffff }
    }
}
