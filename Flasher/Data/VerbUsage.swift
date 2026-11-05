import Foundation

/// How a verb is used in a sentence: what follows it and what kind of event it describes. This is what lets the drill
/// build a sentence for ANY verb without hand-written examples.
///
/// Code = valency + object + aspect (+ "/preposition"):
///   valency  T takes an object · S takes a que-clause · M motion (+ place) · P fixed preposition · X + infinitive ·
///            C linking verb (ser, estar) · I intransitive · D gustar-type (me gusta la película) · W weather · Z skip
///   object   f food · t thing · p person · x text · v vehicle or device · a abstract · m media · h task · j job/permit ·
///            w something awaited · l place · n sound or song · e event · g money · q que-clause · i si-clause · o origin · u adverb
///   aspect   a activity (can be in progress) · c accomplishment · k achievement (instant) · s state · e event
struct VerbUsage: Hashable {
    let valency: Character
    let object: Character
    let aspect: Character
    let preposition: String?
    /// True when a person tagged the verb; false when the code was guessed from the English gloss.
    let reviewed: Bool

    private static let table: [String: VerbUsage] = {
        var result: [String: VerbUsage] = [:]
        func load(_ text: String, reviewed: Bool) {
            for line in text.split(separator: "\n") {
                guard let colon = line.firstIndex(of: ":") else { continue }
                let code = String(line[..<colon])
                guard let usage = parse(code, reviewed: reviewed) else { continue }
                for verb in line[line.index(after: colon)...].split(separator: " ") { result[String(verb)] = usage }
            }
        }
        load(guessed, reviewed: false)
        load(reviewed, reviewed: true)   // hand tags win
        return result
    }()

    static func parse(_ code: String, reviewed: Bool) -> VerbUsage? {
        let parts = code.split(separator: "/", maxSplits: 1).map(String.init)
        let chars = Array(parts[0])
        guard let valency = chars.first, valency != "Z" else { return nil }
        let prep = parts.count > 1 ? parts[1] : nil
        switch valency {
        case "T", "S", "C", "M":
            guard chars.count == 3 else { return nil }
            return VerbUsage(valency: valency, object: chars[1], aspect: chars[2], preposition: prep, reviewed: reviewed)
        case "I":
            if chars.count == 3 { return VerbUsage(valency: valency, object: chars[1], aspect: chars[2], preposition: prep, reviewed: reviewed) }
            guard chars.count == 2 else { return nil }
            return VerbUsage(valency: valency, object: "-", aspect: chars[1], preposition: prep, reviewed: reviewed)
        case "P", "X":
            guard chars.count >= 2 else { return nil }
            return VerbUsage(valency: valency, object: chars.count > 2 ? chars[2] : "-", aspect: chars[1], preposition: prep, reviewed: reviewed)
        case "D", "W":
            return VerbUsage(valency: valency, object: "-", aspect: "e", preposition: nil, reviewed: reviewed)
        default:
            return nil
        }
    }

    /// nil for verbs the drill skips (auxiliary haber, vulgar or rare verbs, verbs that need a gerund).
    static func of(_ infinitive: String) -> VerbUsage? {
        let base = infinitive.hasSuffix("se") ? String(infinitive.dropLast(2)) : infinitive
        return table[infinitive] ?? table[base]
    }

    // MARK: - Complements

    private static let objectBanks: [Character: [String]] = [
        "f": ["la comida", "el desayuno", "una manzana", "un taco", "la cena"],
        "y": ["un café", "agua", "un jugo", "un té"],
        "d": ["la puerta", "la ventana", "la caja", "la tienda", "el libro"],
        "t": ["el libro", "la mesa", "un regalo", "las llaves", "el paquete"],
        "p": ["a la maestra", "al vecino", "a los niños", "a un amigo", "a la doctora"],
        "x": ["la carta", "el mensaje", "el informe", "la receta", "el correo"],
        "v": ["el coche", "la bicicleta", "el teléfono", "la computadora", "la moto"],
        "a": ["el problema", "la idea", "el plan", "la respuesta", "el error"],
        "m": ["la película", "el partido", "el programa", "la serie"],
        "h": ["la tarea", "el trabajo", "la lección", "el ejercicio"],
        "r": ["un problema", "un accidente", "una pérdida", "un golpe"],
        "c": ["la calle", "el parque", "la plaza", "la ciudad"],
        "z": ["un mosquito", "una mosca", "el tiempo", "un insecto"],
        "j": ["un trabajo", "un boleto", "el permiso", "ayuda"],
        "w": ["el autobús", "la respuesta", "a un amigo", "el tren"],
        "l": ["la ciudad", "el parque", "la casa", "el centro", "el museo"],
        "n": ["la música", "una canción", "el ruido"],
        "e": ["la fiesta", "el cumpleaños", "la reunión", "el viaje"],
        "g": ["dinero", "un premio", "el partido"],
        "b": ["la cuenta", "el alquiler", "la comida"],
    ]

    private static let infinitives = ["comer", "salir", "trabajar", "ayudar", "viajar", "estudiar"]

    private static let prepositionBanks: [String: [String]] = [
        "con-": ["con un amigo", "con la familia", "con el jefe"],
        "por-": ["por el parque", "por la ciudad", "por el centro"],
        "contra-": ["contra el equipo", "contra el tiempo"],
        "de-": ["de la ciudad", "de casa", "de la escuela"],
        "dea": ["del problema", "de la situación", "de otras cosas"],
        "ae": ["a la reunión", "a la clase", "a la fiesta"],
        "ai": ["a la información", "a los datos"],
        "enl": ["en el centro", "en la ciudad", "en una casa pequeña"],
        "enp": ["en un amigo", "en la familia", "en el equipo"],
        "ene": ["en la reunión", "en el concierto", "en la fiesta"],
    ]

    /// What follows the verb when the subject is a person or an animal. `seed` varies the choice but stays the same for the same card.
    /// Meals a verb already names, so "cenar la cena" and "almorzar el desayuno" never come up.
    private static let cognates: [String: Set<String>] = [
        "cenar": ["la cena", "el desayuno"], "desayunar": ["el desayuno", "la cena"], "almorzar": ["el desayuno", "la cena"],
        "merendar": ["el desayuno", "la cena"],
    ]

    /// `past` is true when the sentence is told in the past, so a clause after the verb moves back too
    /// ("dijo que ya era tarde", not "dijo que ya es tarde").
    func complement(for infinitive: String, seed: Int, past: Bool = false) -> String {
        func pick(_ list: [String]) -> String { list.isEmpty ? "" : list[seed % list.count] }
        let base = infinitive.hasSuffix("se") ? String(infinitive.dropLast(2)) : infinitive
        switch valency {
        case "T": return pick((Self.objectBanks[object] ?? []).filter { !(Self.cognates[base]?.contains($0) ?? false) })
        case "S":
            if object == "i" { return pick(past ? ["si ya era tarde", "qué hora era", "dónde estaba la casa"] : ["si ya es tarde", "qué hora es", "dónde está la casa"]) }
            return pick(past ? ["que ya era tarde", "que todo estaba bien", "que la tienda abría a las nueve"] : ["que ya es tarde", "que todo está bien", "que la tienda abre a las nueve"])
        case "M": return pick(object == "o" ? ["de casa", "de la oficina", "del trabajo", "de la escuela"] : ["a la escuela", "al mercado", "a casa", "al trabajo", "a la oficina"])
        case "C":
            switch object {
            case "s": return pick(["importante", "amable", "feliz"])
            case "e": return pick(["bien", "aquí", "en casa"])
            case "q": return pick(["aquí", "en casa", "cerca"])
            default: return pick(["importante", "fácil", "difícil"])
            }
        case "I":
            if object == "u" { return pick(["mucho", "bien", "poco"]) }
            return aspect == "a" ? pick(["mucho", "bien", "con calma"]) : ""
        case "X":
            let choices = Self.infinitives.filter { $0 != infinitive }
            let verb = choices[seed % choices.count]
            return preposition.map { "\($0) \(verb)" } ?? verb
        case "P":
            let key = (preposition ?? "") + (object == "-" ? "-" : String(object))
            return pick(Self.prepositionBanks[key] ?? Self.prepositionBanks[(preposition ?? "") + "-"] ?? [])
        default:
            return ""
        }
    }

    /// What follows the verb when the subject is a thing ("La película empieza a las ocho", "El libro cuesta mucho").
    static func thingComplement(pool: String?, seed: Int) -> String {
        let list: [String]
        switch pool {
        case "openable": list = ["a las nueve", "a las ocho"]
        case "event": list = ["a las ocho", "a las nueve", "tarde"]
        case "happening": list = ["de repente", "otra vez", "a veces"]
        case "priced": list = ["mucho", "poco"]
        case "shaky": list = ["un poco", "mucho"]
        case "machine": list = ["bien", "mal"]
        case "sound": list = ["muy fuerte", "mucho"]
        case "light", "body": list = ["mucho"]
        default: list = [""]
        }
        return list[seed % list.count]
    }

    // MARK: - Cue words

    /// A time word that fits the tense AND the kind of event: "Ayer" for most, "De repente" for an instant, nothing for a state.
    func cue(_ tense: Tense) -> (lead: String, trail: String) {
        switch tense {
        case .present:
            switch aspect {
            case "a", "c": return ("", "todos los días")
            case "k", "e": return ("", "a veces")
            default: return ("", "")
            }
        case .preterite: return aspect == "k" ? ("De repente", "") : ("Ayer", "")
        case .imperfect:
            switch aspect {
            case "a", "c": return ("Antes", "cada semana")
            case "k": return ("A veces", "")
            case "s": return ("En esa época", "")
            default: return ("Antes", "")
            }
        case .future: return (aspect == "s" ? "Algún día" : "Mañana", "")
        default: return ("", "")
        }
    }
}
