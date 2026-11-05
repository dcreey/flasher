import Foundation

/// Who or what can be the subject of a verb. Used to pick target subjects for drill sentences, so the app never
/// asks for "el coche come" or "yo llueve".
enum SubjectKind: String, Hashable {
    /// People only: pensar, hablar, comprar. Most verbs.
    case person
    /// People and animals: comer, dormir, correr.
    case living
    /// Things or events only: funcionar, costar, gustar, ocurrir, haber.
    case thing
    /// People or things: abrir, cambiar, empezar, ser, estar.
    case any
    /// Weather: llover, nevar. No subject, third person singular only.
    case weather
}

struct VerbProfile: Hashable {
    var kind: SubjectKind
    /// A narrower group than the kind allows ("dog" for ladrar, "liquid" for hervir), nil for the whole kind.
    var pool: String?
}

enum VerbProfiles {
    private static let table: [String: VerbProfile] = {
        var result: [String: VerbProfile] = [:]
        for item in exceptions.split(whereSeparator: { $0 == " " || $0 == "\n" }) {
            let parts = item.split(separator: "=", maxSplits: 1)
            guard parts.count == 2 else { continue }
            let spec = parts[1].split(separator: "/", maxSplits: 1)
            let kind: SubjectKind
            switch spec.first {
            case "l": kind = .living
            case "t": kind = .thing
            case "a": kind = .any
            case "w": kind = .weather
            default: kind = .person
            }
            result[String(parts[0])] = VerbProfile(kind: kind, pool: spec.count > 1 ? String(spec[1]) : nil)
        }
        return result
    }()

    private static func words(_ text: String) -> Set<String> {
        Set(text.split(whereSeparator: { $0 == " " || $0 == "\n" }).map(String.init))
    }

    private static func base(_ infinitive: String) -> String { infinitive.hasSuffix("se") ? String(infinitive.dropLast(2)) : infinitive }

    /// Literary or archaic verbs whose forms nobody says: kept out of drills.
    static func isRare(_ infinitive: String) -> Bool { words("placer acaecer acontecer").contains(base(infinitive)) }

    /// The profile of an infinitive ("levantarse" resolves to "levantar"). Verbs without an entry are person verbs.
    static func profile(_ infinitive: String) -> VerbProfile {
        if let found = table[infinitive] { return found }
        if infinitive.hasSuffix("se"), let found = table[String(infinitive.dropLast(2))] { return found }
        return VerbProfile(kind: .person, pool: nil)
    }
}

/// One target subject for a drill: the words to show and the column of the conjugation chart it needs.
struct DrillSubject: Hashable {
    let text: String
    /// True for people ("yo", "mi hermana"); false for animals and things, which get different sentence frames.
    var isPerson: Bool { ["yo", "tú", "él", "ella", "usted", "nosotros", "vosotros", "ellos", "ustedes"].contains(text) || text.hasPrefix("mi ") || text.hasPrefix("mis ") }
    /// 0 yo, 1 tú, 2 él/ella/usted, 3 nosotros, 4 vosotros, 5 ellos/ustedes.
    let person: Int
}

enum DrillSubjects {
    /// The subjects that make sense for this verb in this tense. Empty when a drill can't use the tense for the verb
    /// (a command to a thing or to the weather). Weather verbs give one subject with no words ("").
    /// vosotros is left out unless asked for; Mexico and Colombia use ustedes.
    static func subjects(for infinitive: String, tense: Tense, includeVosotros: Bool = false) -> [DrillSubject] {
        let profile = VerbProfiles.profile(infinitive)
        let command = tense == .imperative
        let people = Self.people(command: command, includeVosotros: includeVosotros)

        switch profile.kind {
        case .weather:
            return command ? [] : [DrillSubject(text: "", person: 2)]
        case .thing:
            return command ? [] : things(pool: profile.pool ?? "generic")
        case .living:
            if command { return people }
            // A narrow animal pool ("ladrar") means only that animal
            if let pool = profile.pool, let list = animalPools[pool] { return list }
            return people + animals
        case .any:
            if command { return people }
            // Only verbs with a thing pool ("abrir": doors, "empezar": events) accept things; the rest stay with people
            guard let pool = profile.pool, thingPools[pool] != nil else { return people }
            return (thingOnlyPools.contains(pool) ? [] : people) + things(pool: pool)
        case .person:
            return people
        }
    }

    /// Pools where people can't be the subject at all: prices vary, birds fly, fires burn.
    private static let thingOnlyPools: Set<String> = ["priced", "bird", "burn", "light", "flow", "sound", "body"]

    private static func people(command: Bool, includeVosotros: Bool) -> [DrillSubject] {
        if command {
            var list = [DrillSubject(text: "tú", person: 1), DrillSubject(text: "usted", person: 2),
                        DrillSubject(text: "nosotros", person: 3), DrillSubject(text: "ustedes", person: 5)]
            if includeVosotros { list.append(DrillSubject(text: "vosotros", person: 4)) }
            return list
        }
        var list = [
            DrillSubject(text: "yo", person: 0), DrillSubject(text: "tú", person: 1), DrillSubject(text: "él", person: 2),
            DrillSubject(text: "ella", person: 2), DrillSubject(text: "usted", person: 2), DrillSubject(text: "nosotros", person: 3),
            DrillSubject(text: "ellos", person: 5), DrillSubject(text: "ustedes", person: 5),
            DrillSubject(text: "mi hermana", person: 2), DrillSubject(text: "mis padres", person: 5), DrillSubject(text: "mi amigo y yo", person: 3),
        ]
        if includeVosotros { list.append(DrillSubject(text: "vosotros", person: 4)) }
        return list
    }

    private static let animals = [DrillSubject(text: "el perro", person: 2), DrillSubject(text: "los gatos", person: 5)]

    private static let animalPools: [String: [DrillSubject]] = [
        "dog": [DrillSubject(text: "el perro", person: 2), DrillSubject(text: "los perros", person: 5)],
        "cat": [DrillSubject(text: "el gato", person: 2), DrillSubject(text: "los gatos", person: 5)],
        "horse": [DrillSubject(text: "el caballo", person: 2), DrillSubject(text: "los caballos", person: 5)],
        "cow": [DrillSubject(text: "la vaca", person: 2), DrillSubject(text: "las vacas", person: 5)],
        "sheep": [DrillSubject(text: "la oveja", person: 2), DrillSubject(text: "las ovejas", person: 5)],
    ]

    private static let thingPools: [String: [DrillSubject]] = [
        "generic": [DrillSubject(text: "la película", person: 2), DrillSubject(text: "el libro", person: 2), DrillSubject(text: "la idea", person: 2),
                    DrillSubject(text: "las clases", person: 5), DrillSubject(text: "los precios", person: 5)],
        // Things that can be described with an adjective: "La puerta está abierta", "La sopa es picante"
        "adjectival": [DrillSubject(text: "la puerta", person: 2), DrillSubject(text: "el libro", person: 2), DrillSubject(text: "la casa", person: 2),
                       DrillSubject(text: "la sopa", person: 2), DrillSubject(text: "las ventanas", person: 5), DrillSubject(text: "los zapatos", person: 5)],
        "happening": [DrillSubject(text: "el accidente", person: 2), DrillSubject(text: "el cambio", person: 2), DrillSubject(text: "los problemas", person: 5)],
        "event": [DrillSubject(text: "la película", person: 2), DrillSubject(text: "la reunión", person: 2), DrillSubject(text: "el concierto", person: 2),
                  DrillSubject(text: "las clases", person: 5)],
        "openable": [DrillSubject(text: "la puerta", person: 2), DrillSubject(text: "la tienda", person: 2), DrillSubject(text: "las ventanas", person: 5)],
        "burn": [DrillSubject(text: "la casa", person: 2), DrillSubject(text: "el bosque", person: 2), DrillSubject(text: "las velas", person: 5)],
        "shaky": [DrillSubject(text: "la tierra", person: 2), DrillSubject(text: "las luces", person: 5), DrillSubject(text: "la casa", person: 2)],
        "light": [DrillSubject(text: "la luna", person: 2), DrillSubject(text: "el sol", person: 2), DrillSubject(text: "las estrellas", person: 5)],
        "sound": [DrillSubject(text: "el teléfono", person: 2), DrillSubject(text: "la alarma", person: 2), DrillSubject(text: "las campanas", person: 5)],
        "body": [DrillSubject(text: "la cabeza", person: 2), DrillSubject(text: "el pie", person: 2), DrillSubject(text: "las manos", person: 5)],
        "flow": [DrillSubject(text: "el agua", person: 2), DrillSubject(text: "el río", person: 2), DrillSubject(text: "las lágrimas", person: 5)],
        "machine": [DrillSubject(text: "el coche", person: 2), DrillSubject(text: "la lavadora", person: 2), DrillSubject(text: "los teléfonos", person: 5)],
        "liquid": [DrillSubject(text: "el agua", person: 2), DrillSubject(text: "la sopa", person: 2), DrillSubject(text: "las lágrimas", person: 5)],
        "priced": [DrillSubject(text: "el libro", person: 2), DrillSubject(text: "la entrada", person: 2), DrillSubject(text: "los zapatos", person: 5)],
        "plant": [DrillSubject(text: "el árbol", person: 2), DrillSubject(text: "las flores", person: 5)],
        // Things and animals that fly
        "bird": [DrillSubject(text: "el pájaro", person: 2), DrillSubject(text: "el avión", person: 2), DrillSubject(text: "los aviones", person: 5)],
    ]

    private static func things(pool: String) -> [DrillSubject] { thingPools[pool] ?? thingPools["generic"]! }
}
