import Foundation

/// The adjective after ser, estar, resultar and quedar. Each one is tagged in the lexicon for the kind of subject it can
/// describe (p person, t thing, f food, l place), so a door is never "tired" and soup is never "tall". `ser` lists are
/// traits, `estar` lists are states. The forms agree with the subject in gender and number.
enum DrillAdjectives {
    enum Kind { case ser, estar }

    /// Category tag → adjectives, in the masculine singular. Every word here carries that tag in the lexicon (checked by a test).
    static let bank: [Character: [Kind: [String]]] = [
        "p": [
            .ser: ["alto", "bajo", "joven", "viejo", "fuerte", "guapo", "gracioso", "paciente", "responsable", "amable", "simpático",
                   "inteligente", "trabajador", "honesto", "famoso", "serio", "tonto"],
            .estar: ["enfermo", "cansado", "contento", "feliz", "casado", "enamorado", "seguro", "ocupado", "listo", "triste",
                     "nervioso", "tranquilo", "preocupado", "sano"],
        ],
        "t": [
            .ser: ["grande", "largo", "corto", "bonito", "azul", "rojo", "blanco", "negro", "verde", "fuerte", "duro", "normal",
                   "especial", "simple", "sencillo", "pequeño", "caro", "barato", "pesado", "ligero", "nuevo", "viejo", "útil", "importante"],
            .estar: ["roto", "abierto", "cerrado", "limpio", "sucio", "listo", "mojado"],
        ],
        "f": [
            .ser: ["dulce", "picante", "rico", "casero", "fresco", "sabroso", "salado", "amargo"],
            .estar: ["frío", "caliente", "fresco", "rico", "frito", "congelado"],
        ],
        "l": [
            .ser: ["grande", "bonito", "famoso", "popular", "seguro", "ideal", "estrecho", "ancho", "tranquilo", "moderno", "antiguo"],
            .estar: ["abierto", "cerrado", "vacío", "limpio", "lleno"],
        ],
    ]

    /// What kind of thing the subject is, as a lexicon tag.
    static func category(of subject: DrillSubject) -> Character {
        let text = subject.text
        if subject.isPerson || text.isEmpty { return "p" }
        let noun = text.split(separator: " ").last.map(String.init) ?? text
        if ["sopa", "agua", "café", "comida"].contains(noun) { return "f" }
        if ["casa", "tienda", "ciudad", "parque", "museo", "oficina"].contains(noun) { return "l" }
        return "t"
    }

    /// Agreement with the subject: feminine for "ella", "la casa", "mi hermana"; plural for the plural persons and nouns.
    static func agreement(of subject: DrillSubject) -> (feminine: Bool, plural: Bool) {
        let text = subject.text
        let feminine = text == "ella" || text.hasPrefix("la ") || text.hasPrefix("las ") || text == "mi hermana"
        let plural = [3, 4, 5].contains(subject.person) && subject.isPerson || text.hasPrefix("los ") || text.hasPrefix("las ")
        return (feminine, plural)
    }

    private static let irregularPlural: [String: String] = ["joven": "jóvenes"]

    /// The adjective in the form the subject needs: bonito → bonita, bonitos, bonitas; feliz → felices; trabajador → trabajadora.
    static func inflect(_ adjective: String, feminine: Bool, plural: Bool) -> String {
        var word = adjective
        if word.hasSuffix("o") {
            if feminine { word = String(word.dropLast()) + "a" }
        } else if word.hasSuffix("or") || word.hasSuffix("ón") {
            if feminine { word = word.hasSuffix("ón") ? String(word.dropLast(2)) + "ona" : word + "a" }
        }
        guard plural else { return word }
        if let special = irregularPlural[word] { return special }
        if word.hasSuffix("z") { return String(word.dropLast()) + "ces" }
        if let last = word.last, "aeiouáéíóú".contains(last) { return word + "s" }
        return word + "es"
    }

    /// "Ha sido alta", "ha sido azul" say nothing: a trait that does not change is not something that "has been" a certain
    /// way. After ser in the perfect only what can be judged over time stays: behaviour, usefulness, quality.
    private static let judgedOverTime: [Character: Set<String>] = [
        "p": ["paciente", "responsable", "amable", "simpático", "honesto", "serio", "gracioso", "trabajador", "inteligente", "famoso"],
        "t": ["útil", "importante", "caro", "barato", "normal", "especial", "sencillo", "simple"],
        "f": ["rico", "sabroso", "casero", "fresco"],
        "l": ["popular", "famoso", "seguro", "tranquilo", "ideal"],
    ]

    /// An adjective for the subject and the verb, or nil when the verb takes something else (a place, an adverb).
    /// `perfect` is true for the perfect tenses, where ser only takes adjectives that can be judged over time.
    static func complement(verb base: String, subject: DrillSubject, seed: Int, perfect: Bool = false) -> String? {
        let kind: Kind
        switch base {
        case "ser", "resultar": kind = .ser
        case "estar", "quedar": kind = .estar
        default: return nil
        }
        let category = category(of: subject)
        var list = bank[category]?[kind] ?? []
        if perfect, kind == .ser { list = list.filter { judgedOverTime[category]?.contains($0) == true } }
        guard !list.isEmpty else { return nil }
        let agree = agreement(of: subject)
        return inflect(list[seed % list.count], feminine: agree.feminine, plural: agree.plural)
    }
}
