import Foundation

/// The second sentence on a drill card. Each pool holds 50 short, general sentences in a tense that contrasts with the
/// target, so the card reads like a bit of talk and the learner has to pick the tense for the blank.
/// Nothing in them depends on the verb or the subject. Which pool a drill uses is chosen in `DrillSentences.context`.
enum DrillContexts {
    /// Scene-setters in the imperfect that go before a sudden event or a plan ("Hacía calor. Ayer él ___").
    static let imperfectScenes = """
    Era una tarde tranquila.|Hacía mucho calor.|Todo estaba normal.|Llovía a cántaros.|Hacía frío en la calle.|\
    Era un lunes cualquiera.|La casa estaba en silencio.|Ya era de noche.|Había mucha gente en el centro.|El día estaba tranquilo.|\
    Hacía buen tiempo.|Era temprano por la mañana.|La calle estaba vacía.|Todo parecía fácil.|Era una noche larga.|\
    El sol brillaba fuerte.|Había mucho ruido afuera.|Todavía era temprano.|La tienda estaba llena.|Soplaba un viento frío.|\
    Era un domingo tranquilo.|El cielo estaba despejado.|No había nadie en el parque.|Hacía un poco de fresco.|Era la hora de la comida.|\
    Había mucho tráfico.|El ambiente estaba relajado.|Era una mañana soleada.|Todo estaba listo.|La noche estaba oscura.|\
    Eran las ocho de la noche.|Hacía mucho viento.|El mercado estaba abierto.|Había poca luz.|Era un día de fiesta.|\
    La ciudad estaba tranquila.|Hacía un calor insoportable.|Era mediodía.|Todavía llovía.|Había neblina en las calles.|\
    Era una tarde de verano.|El café estaba lleno.|Se sentía el cansancio del día.|Era un viernes por la noche.|Todo estaba en calma.|\
    Hacía un día precioso.|La plaza estaba llena de gente.|Era una mañana fría.|Ya casi era hora de cenar.|Había música en la calle.
    """

    /// Plain statements about now, before a future, a command or a "would" ("Hoy es viernes. Mañana ella ___").
    static let presentStates = """
    Hoy es viernes.|Ya es tarde.|Hay mucho trabajo.|Ahora estamos ocupados.|No hay tiempo.|\
    Todo está listo.|Hoy hace buen tiempo.|Es lunes por la mañana.|La reunión es mañana.|Estamos en marzo.|\
    Hoy es martes.|Es un día importante.|Hay mucha gente en la calle.|Todavía es temprano.|Esta semana hay mucho que hacer.|\
    Hoy es un día largo.|Ya casi es la hora.|Es mitad de mes.|El fin de semana está cerca.|La situación es complicada.|\
    Hoy está lloviendo.|Estamos en temporada alta.|Es la hora de la comida.|Es de noche.|La casa está tranquila.|\
    Hay prisa.|Es un momento difícil.|Hoy hay mucho tráfico.|La fiesta es el sábado.|Estamos a mitad de semana.|\
    Es época de exámenes.|Hay muchas cosas pendientes.|Hoy es el primer día.|Es primavera.|Está todo en orden.|\
    Todos están cansados.|No hay nada listo.|Es el mes más ocupado.|Esta noche hay luna llena.|La semana es larga.|\
    Hay buen ambiente.|Hay mucho por hacer.|Hoy es domingo.|Es un buen momento.|No es fácil.|\
    Hace mucho frío hoy.|Hoy no hay clases.|Es la semana de vacaciones.|Esta mañana hace sol.|El horario es apretado.
    """

    /// What happened next, in the preterite ("Una vez él ___. Luego llegó la noche.").
    static let pastCloses = """
    Pero no fue así.|Todo terminó bien.|Luego llegó la noche.|Eso fue a las ocho.|Nadie dijo nada.|\
    Al final todo salió bien.|Fue un día largo.|Después todo cambió.|Nadie contestó.|Eso pasó muy rápido.|\
    Fue un momento especial.|Nadie se dio cuenta.|Después hubo silencio.|La noche llegó pronto.|Todo ocurrió en un instante.|\
    Fue una sorpresa para todos.|Esa fue la última vez.|Eso fue hace un rato.|Nadie lo esperaba.|Todo se calmó después.|\
    Fue una buena tarde.|Pasó sin que nadie lo notara.|Luego sonó el teléfono.|Después llegaron los demás.|Fue algo inesperado.|\
    Fue el principio de todo.|Eso fue lo que pasó.|Al día siguiente todo siguió igual.|Fue un buen día.|Hubo muchos cambios.|\
    Todo ocurrió por la tarde.|Llegó la hora de irse.|Luego se hizo de noche.|Fue una semana intensa.|Eso sucedió el lunes.|\
    Nadie lo vio venir.|Poco después empezó a llover.|Fue más tarde de lo normal.|Todo quedó en silencio.|Al rato llegó la cena.|\
    Esa noche hubo luna.|Eso fue el sábado.|La cosa no pasó a más.|Fue una mañana tranquila.|Todo pasó muy rápido.|\
    Luego se fueron todos.|Entonces sonó la campana.|Fue un día como cualquier otro.|Nada cambió después.|Así terminó la historia.
    """

    /// What is coming, in the future or the conditional ("Espero que él ___. Pronto lo sabremos.").
    static let futureCloses = """
    Pronto lo sabremos.|Eso sería ideal.|Mañana veremos.|Ya veremos qué pasa.|Todos lo estaremos esperando.|\
    Pronto habrá noticias.|Eso ayudaría mucho.|Sería una buena noticia.|Mañana habrá más información.|Después hablaremos de eso.|\
    Pronto llegará el momento.|Todo saldrá bien.|Eso cambiaría las cosas.|En unos días lo sabremos.|Sería un gran alivio.|\
    La semana que viene habrá novedades.|Todos estarían contentos.|Pronto se acabará la espera.|Eso facilitaría todo.|Mañana será otro día.|\
    Más tarde lo veremos.|Pronto habrá una respuesta.|Sería lo mejor para todos.|Eso nos daría más tiempo.|Dentro de poco terminará todo.|\
    En una hora sabremos más.|Nos haría mucha falta.|El resultado llegará pronto.|Eso traería buenas noticias.|Después lo hablaremos con calma.|\
    Pronto habrá cambios.|Esperaremos a ver.|Sería un buen comienzo.|Dentro de un rato se sabrá.|Mañana nos enteraremos.|\
    Eso sería suficiente.|Ya llegará el día.|En breve tendremos noticias.|Todo se aclarará pronto.|Eso ayudaría a todos.|\
    Más adelante habrá tiempo.|Pronto terminará esta etapa.|Eso mejoraría la situación.|Mañana se verá mejor.|Pronto cambiará todo.|\
    Sería una gran ayuda.|En unos minutos sabremos.|Lo sabremos esta noche.|Eso sería un alivio.|Todo estará claro pronto.
    """

    /// How things are now compared with then, in the present ("Antes ___. Hoy ya no es así.").
    static let nowContrasts = """
    Hoy ya no es así.|Pero ahora todo cambió.|Ahora todo es distinto.|Pero ya es tarde.|Hoy las cosas son otras.|\
    Pero ahora no se puede.|Eso ya no pasa.|Hoy todo es diferente.|Pero ya pasó el momento.|Ahora ya es imposible.|\
    Hoy ya no queda nada de eso.|Pero el tiempo pasó.|Ahora todo está distinto.|Hoy no es lo mismo.|Pero ahora hay más trabajo.|\
    Hoy hay otras prioridades.|Pero eso ya es pasado.|Ahora ya no hay tiempo.|Hoy las cosas ya son otras.|Pero ahora es otra época.|\
    Ya nada es igual.|Pero esos tiempos terminaron.|Hoy ya es otra historia.|Ahora hay que seguir adelante.|Pero ya no hay vuelta atrás.|\
    Hoy ya casi nadie lo recuerda.|Pero ahora todo es más difícil.|Hoy hay más ruido.|Pero la vida siguió.|Ahora es muy tarde para eso.|\
    Hoy ya es otro día.|Pero ahora hay otras cosas.|Ya no se puede cambiar.|Hoy casi todo es diferente.|Pero ya nada se puede hacer.|\
    Ahora solo queda esperar.|Hoy ya es otra cosa.|Pero eso fue hace mucho.|Hoy no hay forma de volver.|Pero ahora ya pasó.|\
    Hoy hay menos tiempo.|Ahora todo va más rápido.|Hoy ya nadie lo hace.|Pero ya es historia.|Hoy las cosas van mejor.|\
    Ahora ya no es posible.|Pero hoy es distinto.|Hoy estamos en otro punto.|Ahora todo cambió.|Hoy todo es más sencillo.
    """

    /// What the scene was like at that moment, in the imperfect ("Cuando llegué, ya ___. Todo estaba en silencio.").
    static let imperfectCloses = """
    Ya era tarde.|Todo estaba en silencio.|Hacía mucho frío.|Ya era de noche.|Todo estaba tranquilo.|\
    Nadie hablaba.|La casa estaba vacía.|Llovía con fuerza.|Había poca gente.|Todo parecía normal.|\
    Era casi mediodía.|Las luces estaban apagadas.|Hacía buen tiempo.|Reinaba la calma.|Ya casi eran las ocho.|\
    El sol ya se ocultaba.|La calle estaba vacía.|Todo estaba en orden.|Se oía la lluvia.|No había nadie más.|\
    Todavía era temprano.|La música sonaba bajito.|El lugar estaba lleno.|Hacía calor en la sala.|Todo seguía igual.|\
    Era una tarde fría.|Ya oscurecía.|Había mucho ruido.|Parecía un día cualquiera.|Nadie sabía nada.|\
    El ambiente era tenso.|La mañana estaba fresca.|Eran más de las nueve.|Todos estaban cansados.|Había un olor a café.|\
    Se escuchaba el tráfico.|El día estaba por terminar.|Ya amanecía.|La puerta estaba abierta.|La luz seguía encendida.|\
    No se veía a nadie.|Casi nadie estaba despierto.|Todo olía a lluvia.|El teléfono no dejaba de sonar.|Todos esperaban en silencio.|\
    Había una calma extraña.|Nadie tenía prisa.|Todo marchaba bien.|Ya nadie hablaba.|La tarde caía despacio.
    """

    /// Then and now: a time before or after the target sentence ("Ellos ___ todos los días. Ayer fue igual.").
    static let timeContrasts = """
    Ayer fue igual.|Antes era distinto.|Hace un año no era así.|Mañana será otro día.|Ayer todo fue más tranquilo.|\
    La semana pasada fue distinto.|Antes no pasaba esto.|El año pasado era peor.|Hace tiempo no era así.|Ayer hubo menos trabajo.|\
    Antes teníamos más tiempo.|Mañana habrá más.|Hace un mes todo era distinto.|Ayer fue un día normal.|Antes se hacía de otra manera.|\
    El mes pasado fue más fácil.|Hace años era diferente.|Ayer hizo más calor.|Antes había más gente.|La semana que viene será distinto.|\
    Ayer no fue así.|Antes todo era más lento.|Hace poco era peor.|Ayer fue más largo.|Antes éramos menos.|\
    El año que viene será otra cosa.|Ayer estuvo todo tranquilo.|Hace mucho todo era más lento.|Ayer fue un buen día.|\
    Antes no había tanto ruido.|Mañana todo cambiará.|Hace una semana era imposible.|Ayer salió todo bien.|Antes pasaba más seguido.|\
    El año pasado fue diferente.|Hace tiempo era muy raro.|Ayer fue más corto.|Antes se veía menos.|Hace unos meses no existía.|\
    Ayer hubo más calma.|Mañana será distinto.|Ayer fue lo contrario.|\
    Hace años todo era más simple.|El verano pasado fue distinto.|Ayer fue mejor.|Antes no se veía esto.|Pasado mañana será igual.
    """

    // MARK: Matching a sentence to the verb

    /// The kind of verb a card is about, which decides which context sentences fit closely.
    enum Category: String {
        case weather, thing, talk, food, work, move, sudden, state, plain
    }

    private static let talkVerbs: Set<String> = [
        "hablar", "platicar", "conversar", "discutir", "charlar", "gritar", "cantar", "rezar", "llamar", "preguntar", "contestar",
        "responder", "decir", "contar", "explicar", "comentar", "opinar", "murmurar", "susurrar", "quejar", "saludar", "avisar",
        "anunciar", "presentar", "negociar", "debatir", "argumentar", "protestar", "bromear", "reír", "gritar",
    ]
    private static let foodVerbs: Set<String> = ["comer", "beber", "cenar", "desayunar", "almorzar", "cocinar", "merendar", "tomar", "probar", "hornear", "freír"]
    private static let moveVerbs: Set<String> = [
        "caminar", "correr", "andar", "viajar", "salir", "entrar", "llegar", "volver", "subir", "bajar", "ir", "venir", "pasear", "nadar", "manejar", "conducir",
    ]

    static func category(_ infinitive: String, usage: VerbUsage, subjectIsPerson: Bool) -> Category {
        let base = infinitive.hasSuffix("se") ? String(infinitive.dropLast(2)) : infinitive
        if usage.valency == "W" { return .weather }
        if !subjectIsPerson { return .thing }
        if usage.valency == "S" || talkVerbs.contains(base) { return .talk }
        if usage.object == "f" || foodVerbs.contains(base) { return .food }
        if usage.valency == "T", "hjgb".contains(usage.object) { return .work }
        if usage.valency == "M" || moveVerbs.contains(base) { return .move }
        if usage.aspect == "k" { return .sudden }
        if usage.aspect == "s" { return .state }
        return .plain
    }

    /// Words in a sentence that make it fit a kind of verb more closely.
    private static let fits: [Category: [String]] = [
        .food: ["comida", "café", "cena", "mercado", "olor"],
        .work: ["trabajo", "reunión", "horario", "examen", "pendiente", "prisa", "ocupad", "hacer", "lunes", "martes", "viernes"],
        .move: ["calle", "tráfico", "parque", "plaza", "centro", "viento", "soleada", "ciudad", "afuera"],
        .talk: ["gente", "ambiente", "fiesta", "tenso", "ruido", "música", "plaza", "café", "esperaban"],
        .sudden: ["calma", "tranquil", "silencio", "normal", "vacía", "cualquiera"],
        .state: ["distinto", "igual", "cambi", "antes", "ya no", "diferente", "otra", "mismo", "más difícil", "más sencillo"],
        .thing: ["casa", "luces", "puerta", "teléfono", "ciudad", "tienda", "lugar", "mercado", "calle"],
    ]

    /// Words that make a sentence clash with a kind of verb ("Todo estaba en silencio" with hablar, rain with llover).
    private static let clashes: [Category: [String]] = [
        .talk: ["silencio", "nadie", "callad"],
        .weather: ["llov", "lluvia", "frío", "calor", "viento", "sol ", "sol.", "cielo", "neblina", "hacía", "hace ", "amanecía", "oscurecía", "soplaba", "buen tiempo", "temporada", "primavera", "verano", "luna"],
        .thing: ["cansad", "nadie", "gente", "despiert", "esperaban", "prisa", "hablaba", "dijo", "contestó", "se dio cuenta", "ocupad"],
        .work: ["vacaciones", "fiesta", "domingo", "fin de semana", "sábado", "luna"],
        .food: ["amanecía"],
    ]

    /// Time words that would repeat if the target sentence already has them ("Mañana vamos a… Mañana la puerta…").
    private static let timeWords = ["ayer", "mañana", "hoy", "ahora", "antes", "luego", "después"]

    /// A sentence from the pool, for a verb of this category and a target sentence.
    /// - Sentences that clash with the verb are never used, and neither are ones that repeat a time word of the target.
    /// - About 60% of the time it is one that fits the verb closely (when the pool has any). For a thing as the subject,
    ///   that means a sentence about the same thing.
    /// - Otherwise it is a neutral sentence, one that is not about food, work, travel, talk, calm or things, so a
    ///   sentence about the market never ends up beside a verb that has nothing to do with it.
    static func pick(_ pool: String, for category: Category, seed: Int, subject: String = "", avoiding target: String = "") -> String {
        let list = all[pool] ?? []
        guard !list.isEmpty else { return "" }
        func has(_ words: [String]?, _ sentence: String) -> Bool {
            let lower = sentence.lowercased()
            return (words ?? []).contains { lower.contains($0) }
        }
        let used = timeWords.filter { target.lowercased().contains($0) }
        var usable = list.filter { !has(clashes[category], $0) && !has(used, $0) }
        if usable.isEmpty { usable = list.filter { !has(clashes[category], $0) } }
        if usable.isEmpty { usable = list }
        // A thing that is the subject (la puerta, las luces) is only helped by a sentence about that same thing;
        // the other nouns in the pools would be about something unrelated
        var thingNoun = subject.lowercased()
        for article in ["el ", "la ", "los ", "las "] where thingNoun.hasPrefix(article) { thingNoun.removeFirst(article.count) }
        if thingNoun.hasSuffix("s") { thingNoun.removeLast() }
        let close = category == .thing
            ? (thingNoun.isEmpty ? [] : usable.filter { $0.lowercased().contains(thingNoun) })
            : usable.filter { sentence in
                // A then-and-now sentence about the market or the weather isn't "close" to a state verb just because it says "antes"
                has(fits[category], sentence) && !(category == .state && fits.contains { $0.key != .state && has($0.value, sentence) })
            }
        if !close.isEmpty, seed % 5 < 3 { return close[(seed / 5) % close.count] }
        // "state" words (distinto, antes, cambió) belong to every then-and-now sentence, so they don't make one specific
        let neutral = usable.filter { sentence in !fits.contains { $0.key != .state && has($0.value, sentence) } }
        let open = neutral.isEmpty ? usable : neutral
        return open[seed % open.count]
    }

    static func list(_ pool: String) -> [String] {
        pool.replacingOccurrences(of: "\n", with: "").split(separator: "|").map { $0.trimmingCharacters(in: .whitespaces) }
    }

    /// Every pool: the first fifty sentences plus the ones added in DrillContextsMore.
    static let all: [String: [String]] = [
        "imperfectScenes": list(imperfectScenes) + list(moreImperfectScenes),
        "presentStates": list(presentStates) + list(morePresentStates),
        "pastCloses": list(pastCloses) + list(morePastCloses),
        "futureCloses": list(futureCloses) + list(moreFutureCloses),
        "nowContrasts": list(nowContrasts) + list(moreNowContrasts),
        "imperfectCloses": list(imperfectCloses) + list(moreImperfectCloses),
        "timeContrasts": list(timeContrasts) + list(moreTimeContrasts),
    ]

    /// How many sentences in a pool fit a kind of verb closely and don't clash with it.
    static func closeCount(_ pool: String, for category: Category) -> Int {
        (all[pool] ?? []).filter { sentence in
            let lower = sentence.lowercased()
            return (fits[category] ?? []).contains { lower.contains($0) } && !(clashes[category] ?? []).contains { lower.contains($0) }
        }.count
    }
}
