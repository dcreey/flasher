import Foundation

extension SeedData {
    /// Maps a Spanish word → set of accepted synonyms (diacritic-insensitive comparison done at call site).
    /// Used to detect when a learner types a correct-meaning word that differs from the target.
    static let synonyms: [String: Set<String>] = [
        // ver / mirar
        "ver":          ["mirar", "observar", "contemplar"],
        "mirar":        ["ver", "observar", "contemplar"],
        // hablar / platicar / conversar
        "hablar":       ["platicar", "conversar", "charlar"],
        "platicar":     ["hablar", "conversar", "charlar"],
        "conversar":    ["hablar", "platicar", "charlar"],
        // comenzar / empezar / iniciar
        "comenzar":     ["empezar", "iniciar", "arrancar"],
        "empezar":      ["comenzar", "iniciar", "arrancar"],
        // terminar / acabar / finalizar
        "terminar":     ["acabar", "finalizar", "concluir"],
        "acabar":       ["terminar", "finalizar", "concluir"],
        // comprar → agarrar (Mexican: "agarras algo en la tienda")
        "comprar":      ["adquirir"],
        // buscar / encontrar
        "encontrar":    ["hallar", "localizar"],
        // regresar / volver
        "regresar":     ["volver", "retornar", "volver"],
        "volver":       ["regresar", "retornar"],
        // manejar / conducir
        "manejar":      ["conducir"],
        "conducir":     ["manejar"],
        // caminar / andar
        "caminar":      ["andar", "ir a pie"],
        // carro / auto
        "carro":        ["auto", "automovil", "vehiculo"],
        // bonito / hermoso / lindo
        "bonito":       ["hermoso", "lindo", "bello"],
        "hermoso":      ["bonito", "lindo", "bello"],
        "lindo":        ["bonito", "hermoso", "bello"],
        // enojado / molesto / enfadado
        "enojado":      ["molesto", "enfadado", "bravo"],
        // feliz / contento / alegre
        "feliz":        ["contento", "alegre"],
        "contento":     ["feliz", "alegre"],
        // triste / melancólico
        "triste":       ["melancolico", "apenado"],
        // grande / enorme / gigante
        "grande":       ["enorme", "gigante", "inmenso"],
        // pequeño / chico / mini
        "pequeño":      ["chico", "diminuto", "mini"],
        // rápido / veloz / ligero
        "rápido":       ["veloz", "ligero"],
        "rapido":       ["veloz", "ligero"],
        // ayudar / apoyar / auxiliar
        "ayudar":       ["apoyar", "auxiliar", "asistir"],
        // comer / alimentarse
        "comer":        ["alimentarse", "comer"],
        // agarrar / tomar / coger
        "agarrar":      ["tomar", "asir"],
        "tomar":        ["agarrar", "asir"],
        // preguntar / cuestionar
        "preguntar":    ["cuestionar", "interrogar"],
        // responder / contestar
        "responder":    ["contestar", "replicar"],
        "contestar":    ["responder", "replicar"],
        // mostrar / enseñar / demostrar
        "mostrar":      ["ensenar", "demostrar", "exhibir"],
        "enseñar":      ["mostrar", "demostrar"],
        // cuidar / proteger
        "cuidar":       ["proteger", "velar"],
        "proteger":     ["cuidar", "defender"],
        // elegir / escoger / seleccionar
        "elegir":       ["escoger", "seleccionar"],
        "escoger":      ["elegir", "seleccionar"],
        // jitomate / tomate
        "jitomate":     ["tomate"],
        // celular / teléfono / móvil
        "celular":      ["telefono", "movil", "smartphone"],
        // camión / autobús
        "camión":       ["autobus", "bus"],
        "autobus":      ["camion", "bus"],
    ]

    static func isSynonym(input: String, of target: String) -> Bool {
        guard let set = synonyms[target] else { return false }
        let norm = input.lowercased().folding(options: .diacriticInsensitive, locale: .current)
        return set.contains { $0.lowercased().folding(options: .diacriticInsensitive, locale: .current) == norm }
    }
}
