import Foundation

/// The second sentence of a drill card, built from what the first sentence is about: the object of its verb.
/// "Ayer él compró el libro." gets "El libro era caro." or "Todos buscaban el libro.", not a scene that has
/// nothing to do with it. The describing adjectives come from the lexicon's tags for the kind of thing the object is.
enum DrillRelatedContext {
    /// The object of the verb, as the context sentence needs it.
    struct Thing: Equatable {
        /// As written after the verb: "a la maestra", "el libro", "un regalo".
        let phrase: String
        /// As a subject or after "de": "la maestra", "el libro", "el regalo" (no "a", always definite).
        let definite: String
        let feminine: Bool
        let plural: Bool
        /// The usage code's object kind ("t" thing, "p" person, "f" food…).
        let kind: Character
        /// The noun itself ("maestra", "libro").
        let noun: String

        /// As the object of "buscar" or "necesitar": people take "a".
        var direct: String {
            guard kind == "p" else { return definite }
            return definite.hasPrefix("el ") ? "al " + definite.dropFirst(3) : "a " + definite
        }
    }

    /// What the second sentence is built from.
    enum Source {
        /// The object of the verb, the place it goes to, the person it is done with, or the thing that is its subject.
        case thing(Thing)
        /// What is said, thought or asked: "que ya es tarde".
        case clause(String)
        /// What is wanted or begun: "comer", "trabajar".
        case action(String)
    }

    /// Reads the complement of a verb with an object. nil when it isn't a noun phrase with an object kind we describe.
    static func thing(from complement: String, kind: Character) -> Thing? {
        guard adjectives[kind] != nil else { return nil }
        let words = complement.split(separator: " ").map(String.init)
        guard !words.isEmpty else { return nil }
        // Mass nouns that go without an article, and "el agua" (feminine)
        switch complement {
        case "agua": return Thing(phrase: complement, definite: "el agua", feminine: true, plural: false, kind: kind, noun: "agua")
        default: break
        }
        var rest = words
        // "a la escuela", "con el jefe", "de casa", "del problema": the preposition belongs to the verb, not to the noun
        if let first = rest.first, ["a", "de", "con", "por", "contra", "en", "para"].contains(first) { rest.removeFirst() }
        if rest.first == "al" || rest.first == "del" { rest[0] = "el" }
        // "a casa", "de casa": the house, with no article
        if rest == ["casa"] { return Thing(phrase: complement, definite: "la casa", feminine: true, plural: false, kind: kind, noun: "casa") }
        guard rest.count >= 2 else { return nil }
        let articles: [String: (definite: String, feminine: Bool, plural: Bool)] = [
            "el": ("el", false, false), "la": ("la", true, false), "los": ("los", false, true), "las": ("las", true, true),
            "un": ("el", false, false), "una": ("la", true, false), "unos": ("los", false, true), "unas": ("las", true, true),
        ]
        guard let article = articles[rest[0]] else { return nil }
        let noun = rest.dropFirst().joined(separator: " ")
        // "luchar contra el tiempo" is not a person, and "volver al trabajo" is not a place that can be full or empty
        if noun == "tiempo" || ((kind == "l" || kind == "c") && noun == "trabajo") { return nil }
        return Thing(phrase: complement, definite: article.definite + " " + noun, feminine: article.feminine, plural: article.plural, kind: kind, noun: noun)
    }

    /// What kind of thing follows each preposition the verbs use ("con un amigo" a person, "de la ciudad" a place).
    static func kind(forPreposition key: String) -> Character? {
        ["con-": "p", "por-": "c", "contra-": "p", "de-": "l", "dea": "a", "ae": "e", "ai": "a", "enl": "l", "enp": "p", "ene": "e"][key]
    }

    /// What kind of thing a noun is, for the things that are the subject of a sentence ("la puerta", "el coche").
    static func kind(forNoun noun: String) -> Character? {
        let kinds: [String: Character] = [
            "puerta": "d", "tienda": "d", "ventanas": "d", "caja": "d", "coche": "v", "lavadora": "v", "teléfonos": "v", "teléfono": "v",
            "computadora": "v", "película": "m", "programa": "m", "serie": "m", "partido": "m", "reunión": "e", "concierto": "e",
            "fiesta": "e", "clases": "h", "tarea": "h", "libro": "t", "entrada": "t", "zapatos": "t", "mesa": "t", "paquete": "t",
            "sopa": "f", "comida": "f", "agua": "y", "casa": "l", "bosque": "l", "idea": "a", "problema": "a", "precios": "b",
            "perro": "p", "gatos": "p", "caballo": "p", "vaca": "p", "oveja": "p",
        ]
        return kinds[noun]
    }

    /// Adjectives for each kind of object, split into traits (ser) and states (estar). Every word carries the lexicon
    /// tag for the kind of thing it describes (checked by a test).
    static let adjectives: [Character: (ser: [String], estar: [String])] = [
        "f": (["rico", "sabroso", "fresco"], ["frío", "caliente", "fresco", "rico"]),
        "y": (["rico"], ["frío", "caliente"]),
        "t": (["grande", "pequeño", "bonito", "nuevo", "viejo", "caro", "barato"], ["sucio", "limpio", "listo", "roto", "mojado"]),
        "d": (["grande", "pequeño", "nuevo", "viejo"], ["abierto", "cerrado", "limpio", "roto"]),
        "p": (["amable", "simpático", "joven", "alto", "inteligente", "serio"],
              ["ocupado", "cansado", "contento", "nervioso", "tranquilo", "preocupado", "listo", "enfermo"]),
        "v": (["nuevo", "viejo", "caro", "barato", "pequeño", "rápido", "grande"], ["roto", "sucio", "limpio", "listo"]),
        "l": (["grande", "bonito", "famoso", "tranquilo", "antiguo", "moderno", "seguro"], ["lleno", "vacío", "limpio"]),
        "c": (["grande", "bonito", "famoso", "tranquilo", "antiguo", "moderno", "seguro"], ["lleno", "vacío", "limpio"]),
        "a": (["importante", "difícil", "simple", "normal", "extraño", "complejo", "absurdo"], []),
        "x": (["largo", "corto", "importante", "difícil", "simple"], ["listo"]),
        "h": (["difícil", "fácil", "largo", "importante", "simple"], ["listo"]),
        "e": (["largo", "importante", "especial"], ["listo"]),
        "m": (["largo", "corto", "famoso", "popular"], []),
        "n": (["fuerte"], ["fuerte"]),
        "b": (["caro"], []),
    ]

    private static let copulas: [String: (singular: String, plural: String)] = [
        "estaba": ("estaba", "estaban"), "era": ("era", "eran"), "está": ("está", "están"), "es": ("es", "son"),
        "fue": ("fue", "fueron"), "estuvo": ("estuvo", "estuvieron"), "será": ("será", "serán"), "estará": ("estará", "estarán"),
    ]

    /// Adjectives that would already say the result of the verb ("estaba roto" before "rompió"), so the second sentence
    /// never gives away or contradicts the first.
    private static func resultOf(_ infinitive: String) -> Set<String> {
        let table: [(prefix: String, adjectives: Set<String>)] = [
            ("romp", ["roto"]), ("rompe", ["roto"]), ("quebr", ["roto"]), ("abr", ["abierto"]), ("cerr", ["cerrado"]),
            ("limpi", ["limpio", "sucio"]), ("lav", ["limpio", "sucio"]), ("barr", ["limpio", "sucio"]), ("ensuci", ["sucio", "limpio"]),
            ("mancha", ["sucio", "limpio"]), ("moj", ["mojado"]), ("cans", ["cansado"]), ("preocup", ["preocupado"]),
            ("llen", ["lleno", "vacío"]), ("vaci", ["lleno", "vacío"]), ("enferm", ["enfermo"]), ("prepar", ["listo"]),
        ]
        return table.first { infinitive.hasPrefix($0.prefix) }?.adjectives ?? []
    }

    /// The tense each pool's second sentence is in.
    private enum Tense { case imperfect, present, preterite, future }
    private static func tense(of pool: String) -> Tense? {
        switch pool {
        case "imperfectScenes", "imperfectCloses": return .imperfect
        case "presentStates", "nowContrasts": return .present
        case "pastCloses": return .preterite
        case "futureCloses": return .future
        default: return nil
        }
    }

    /// Sentences about what was said, thought or asked, by topic and tense (imperfect, present, preterite, future).
    private static let clauseTopics: [(match: String, lines: [Tense: [String]])] = [
        ("tarde", [.imperfect: ["Ya era de noche.", "Eran más de las ocho."], .present: ["Ya es de noche.", "Son más de las ocho."],
                   .preterite: ["Fue un día largo."], .future: ["Pronto será de noche."]]),
        ("hora", [.imperfect: ["Ya casi eran las ocho.", "El reloj estaba parado."], .present: ["Ya casi son las ocho.", "El reloj está parado."],
                  .preterite: ["Fue más tarde de lo normal."], .future: ["Pronto serán las ocho."]]),
        ("todo está", [.imperfect: ["Todo parecía normal.", "Todo estaba tranquilo."], .present: ["Todo parece normal.", "Todo está tranquilo."],
                       .preterite: ["Todo salió bien."], .future: ["Todo saldrá bien."]]),
        ("todo estaba", [.imperfect: ["Todo parecía normal.", "Todo estaba tranquilo."], .present: ["Todo parece normal."],
                         .preterite: ["Todo salió bien."], .future: ["Todo saldrá bien."]]),
        ("tienda", [.imperfect: ["La tienda estaba cerrada.", "La tienda era pequeña."], .present: ["La tienda está cerrada.", "La tienda es pequeña."],
                    .preterite: ["La tienda estuvo cerrada."], .future: ["La tienda estará cerrada."]]),
        ("casa", [.imperfect: ["La casa estaba vacía.", "La casa era grande."], .present: ["La casa está vacía.", "La casa es grande."],
                  .preterite: ["La casa estuvo vacía."], .future: ["La casa estará vacía."]]),
    ]

    /// Sentences about an action that is wanted or begun, by verb and tense.
    private static let actionTopics: [String: [Tense: String]] = [
        "comer": [.imperfect: "Todos tenían hambre.", .present: "Todos tienen hambre.", .preterite: "Todos tuvieron hambre.", .future: "Todos tendrán hambre."],
        "salir": [.imperfect: "Hacía buen tiempo.", .present: "Hace buen tiempo.", .preterite: "Fue una buena idea.", .future: "Será una buena idea."],
        "trabajar": [.imperfect: "Había mucho trabajo.", .present: "Hay mucho trabajo.", .preterite: "Hubo mucho trabajo.", .future: "Habrá mucho trabajo."],
        "ayudar": [.imperfect: "Había mucho que hacer.", .present: "Hay mucho que hacer.", .preterite: "Hubo mucho que hacer.", .future: "Habrá mucho que hacer."],
        "viajar": [.imperfect: "El viaje era largo.", .present: "El viaje es largo.", .preterite: "El viaje fue largo.", .future: "El viaje será largo."],
        "estudiar": [.imperfect: "Había examen.", .present: "Hay examen.", .preterite: "Hubo examen.", .future: "Habrá examen."],
    ]

    /// The second sentence for any kind of source, nil when there is nothing related to say.
    static func sentence(pool: String, source: Source, seed: Int, infinitive: String, target: String) -> String? {
        let used = timeWords.filter { target.lowercased().contains($0) }
        func clean(_ list: [String]) -> String? {
            let usable = list.filter { candidate in !used.contains { candidate.lowercased().contains($0) } }
            return usable.isEmpty ? nil : usable[(seed / 5) % usable.count]
        }
        switch source {
        case .thing(let thing):
            return sentence(pool: pool, thing: thing, seed: seed, infinitive: infinitive, target: target)
        case .clause(let clause):
            guard let topic = clauseTopics.first(where: { clause.contains($0.match) }) else { return nil }
            if pool == "timeContrasts" { return clean((topic.lines[.imperfect] ?? []).map(yesterday)) }
            guard let tense = tense(of: pool) else { return nil }
            return clean(topic.lines[tense] ?? [])
        case .action(let action):
            guard let lines = actionTopics[action] else { return nil }
            if pool == "timeContrasts" { return clean(lines[.imperfect].map { [yesterday($0)] } ?? []) }
            guard let tense = tense(of: pool), let line = lines[tense] else { return nil }
            return clean([line])
        }
    }

    /// "Ya era de noche." as a then-and-now line: "Ayer ya era de noche."
    private static func yesterday(_ line: String) -> String { "Ayer " + line.prefix(1).lowercased() + line.dropFirst() }

    /// "de el libro" is "del libro".
    private static func de(_ definite: String) -> String { definite.hasPrefix("el ") ? "del " + definite.dropFirst(3) : "de " + definite }

    private static func capitalized(_ text: String) -> String { text.prefix(1).uppercased() + text.dropFirst() }

    private static let timeWords = ["ayer", "mañana", "hoy", "ahora", "antes", "luego", "después", "todavía"]

    /// The sentences that fit the pool's role (the tense the second sentence has to be in) and describe the object.
    /// `infinitive` and `target` keep it from repeating the verb of the first sentence or its time word.
    /// The pronoun that stands for the object: lo, la, los, las.
    private static func clitic(_ thing: Thing) -> String {
        thing.plural ? (thing.feminine ? "las" : "los") : (thing.feminine ? "la" : "lo")
    }

    /// Follow-ups that refer back to the object with a pronoun, so they make sense whatever the first verb did:
    /// "Compró el libro. Todos lo conocían." Each comes with the verb it uses, so the first sentence's verb is never repeated.
    /// What it says depends on the kind of object (you use a tool, you do not use a problem) and on the pool's tense.
    private static func followUps(pool: String, thing: Thing) -> [(verb: String, text: String)] {
        let it = clitic(thing)
        enum Group { case place, person, food, tool, idea }
        let group: Group = switch thing.kind {
        case "l", "c": .place
        case "p": .person
        case "f", "y": .food
        case "t", "d", "v": .tool
        default: .idea
        }
        // What can be said about anything, then what only fits some kinds
        var lines: [(String, String)]
        switch pool {
        case "imperfectScenes", "imperfectCloses":
            lines = [("conocer", "Todos \(it) conocían."), ("olvidar", "Nadie \(it) olvidaba."), ("recordar", "Siempre \(it) recordábamos.")]
            switch group {
            case .place: lines += [("esperar", "Allí nos esperaban."), ("ir", "Siempre íbamos allí.")]
            case .person: lines += [("querer", "Todos \(it) querían."), ("ayudar", "Siempre \(it) ayudábamos.")]
            case .food: lines += [("comer", "Siempre \(it) comíamos."), ("preparar", "Mi mamá \(it) preparaba.")]
            case .tool: lines += [("usar", "Siempre \(it) usábamos."), ("necesitar", "\(it.capitalized) necesitábamos mucho.")]
            case .idea: lines += [("entender", "Nadie \(it) entendía.")]
            }
        case "presentStates", "nowContrasts":
            lines = [("conocer", "Todos \(it) conocen."), ("recordar", "Todos \(it) recuerdan.")]
            switch group {
            case .place: lines += [("esperar", "Allí nos esperan."), ("visitar", "Casi nadie \(it) visita.")]
            case .person: lines += [("querer", "Todos \(it) queremos."), ("ayudar", "Siempre \(it) ayudamos.")]
            case .food: lines += [("comer", "\(it.capitalized) comemos mucho."), ("preparar", "Mi mamá \(it) prepara.")]
            case .tool: lines += [("usar", "\(it.capitalized) usamos mucho."), ("necesitar", "\(it.capitalized) necesitamos.")]
            case .idea: lines += [("entender", "Nadie \(it) entiende.")]
            }
        case "pastCloses":
            lines = [("conocer", "Todos \(it) conocieron."), ("olvidar", "Nadie \(it) olvidó."), ("recordar", "Todos \(it) recordaron.")]
            switch group {
            case .place: lines += [("esperar", "Allí nos esperaron."), ("visitar", "Después \(it) visitamos.")]
            case .person: lines += [("querer", "Todos \(it) quisieron."), ("ayudar", "Todos \(it) ayudaron.")]
            case .food: lines += [("probar", "Todos \(it) probaron."), ("comer", "\(it.capitalized) comimos.")]
            case .tool: lines += [("usar", "\(it.capitalized) usamos mucho."), ("necesitar", "\(it.capitalized) necesitamos.")]
            case .idea: lines += [("entender", "Nadie \(it) entendió.")]
            }
        case "futureCloses":
            lines = []
            switch group {
            case .place: lines += [("visitar", "Pronto \(it) visitamos."), ("esperar", "Allí nos esperan.")]
            case .person: lines += [("ayudar", "Después \(it) ayudamos."), ("llamar", "Luego \(it) llamamos."), ("recordar", "Siempre \(it) recordaremos.")]
            case .food: lines += [("probar", "Pronto \(it) probamos."), ("comer", "Luego \(it) comemos.")]
            case .tool: lines += [("usar", "Pronto \(it) usamos."), ("necesitar", "\(it.capitalized) vamos a necesitar.")]
            case .idea: lines += [("entender", "Pronto \(it) vamos a entender.")]
            }
        default:
            lines = []
        }
        return lines.map { (verb: $0.0, text: $0.1) }
    }

    /// A random state of the object ("La caja estará limpia") rarely follows from what the first sentence did, so it is off:
    /// the second sentence talks about the object, needs it or looks for it instead.
    private static let describeStates = false

    static func sentence(pool: String, thing: Thing, seed: Int, infinitive: String, target: String) -> String? {
        guard let words = adjectives[thing.kind] else { return nil }
        let subject = capitalized(thing.definite)
        let lower = thing.definite
        let avoided = resultOf(infinitive)
        func adjective(_ list: [String], _ index: Int) -> String? {
            let list = list.filter { !avoided.contains($0) }
            guard !list.isEmpty else { return nil }
            // The object is picked with seed % (number of objects); these use other parts of the seed so the choices vary independently
            return DrillAdjectives.inflect(list[(seed / 11 + index) % list.count], feminine: thing.feminine, plural: thing.plural)
        }
        func copula(_ form: String) -> String { thing.plural ? copulas[form]!.plural : copulas[form]!.singular }
        /// "El libro era caro.": a trait with ser, or a state with estar. Falls back to the other when a kind has only one.
        func describe(_ form: String, prefix: String = "", subjectText: String? = nil) -> String? {
            let isSer = ["era", "es", "fue", "será"].contains(form)
            // Only states (estar): "La tienda estaba cerrada" follows from the first sentence. A trait with ser ("La oficina
            // será antigua") says nothing about what just happened, so it is left out and the other sentence kinds are used.
            guard !isSer, describeStates else { return nil }
            let list = words.estar
            guard let adj = adjective(list, form.count) else { return nil }
            let form = words.estar.isEmpty && !isSer ? (["estaba": "era", "está": "es", "estuvo": "fue", "estará": "será"][form] ?? form) : form
            let usedForm = words.ser.isEmpty && isSer ? (["era": "estaba", "es": "está", "fue": "estuvo", "será": "estará"][form] ?? form) : form
            return prefix + (prefix.isEmpty ? subject : subjectText ?? lower) + " " + copula(usedForm) + " " + adj + "."
        }
        let wantNeeded = !(infinitive.hasPrefix("necesit") || infinitive.hasPrefix("busc"))
        let places = thing.kind == "l" || thing.kind == "c"
        let wantTalk = !infinitive.hasPrefix("habl") && !infinitive.hasPrefix("pregunt") && !infinitive.hasPrefix("coment")
        var found: [String?] = []
        let base = infinitive.hasSuffix("se") ? String(infinitive.dropLast(2)) : infinitive
        let referring = followUps(pool: pool, thing: thing).filter { $0.verb != base }.map { Optional($0.text) }
        switch pool {
        case "imperfectScenes":
            found = [describe("estaba"), describe("era"),
                     wantNeeded && !places ? "Se necesita\(thing.plural ? "ban" : "ba") \(thing.direct)." : nil,
                     wantNeeded ? "Todos buscaban \(thing.direct)." : nil,
                     wantTalk ? "Todos hablaban \(de(thing.definite))." : nil]
        case "presentStates":
            found = [describe("está"), describe("es"),
                     wantNeeded && !places ? "Se necesita\(thing.plural ? "n" : "") \(thing.direct)." : nil,
                     wantTalk ? "Todos hablan \(de(thing.definite))." : nil]
        case "pastCloses":
            found = [describe("fue"), describe("estuvo"),
                     wantTalk ? "Todos hablaron \(de(thing.definite))." : nil,
                     wantTalk ? "Nadie preguntó por \(thing.definite)." : nil]
        case "futureCloses":
            found = [describe("será"), describe("estará"),
                     wantTalk ? "Después hablaremos \(de(thing.definite))." : nil]
        case "nowContrasts":
            found = [describe("es", prefix: "Hoy ", subjectText: lower), describe("está", prefix: "Ahora ", subjectText: lower),
                     wantTalk ? "Hoy todos hablan \(de(thing.definite))." : nil]
        case "imperfectCloses":
            found = [describe("estaba"), describe("era"),
                     wantTalk ? "Todos hablaban \(de(thing.definite))." : nil,
                     wantTalk ? "Nadie preguntaba por \(thing.definite)." : nil]
        case "timeContrasts":
            found = [describe("era", prefix: "Antes ", subjectText: lower), describe("estaba", prefix: "Ayer ", subjectText: lower),
                     describe("estará", prefix: "Mañana ", subjectText: lower),
                     wantTalk ? "Antes todos hablaban \(de(thing.definite))." : nil]
        default:
            return nil
        }
        found += referring
        // Not the same time word as the first sentence ("Ayer … Ayer …")
        let used = timeWords.filter { target.lowercased().contains($0) }
        let usable = found.compactMap { $0 }.filter { candidate in !used.contains { candidate.lowercased().contains($0) } }
        guard !usable.isEmpty else { return nil }
        return usable[(seed / 5) % usable.count]
    }
}
