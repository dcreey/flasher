import Foundation

/// Explains por or para in a sentence with the simple rules the Learn guide teaches:
///
///   Para → where it ends up: the Place it's headed, the Person who gets it, the Point in time it's due, the Purpose,
///          the Perspective it's judged from.
///   Por  → what drives it, or what it passes through: the reason, the thing you're after, someone you do it for,
///          the route, the means, the price, the time.
///   Memorise: para siempre, para nada, no es para tanto.
///
/// It reads the words around each por, para or ___ and reports the first rule whose pattern matches, with how sure it
/// is. Foundation only, so a command-line harness can score it against the test sentences in docs/research.
enum PorParaEngine {

    enum Answer: String { case por, para, both }
    enum Certainty: String, Comparable {
        case low, medium, high
        private var rank: Int { self == .low ? 0 : self == .medium ? 1 : 2 }
        static func < (a: Certainty, b: Certainty) -> Bool { a.rank < b.rank }
    }

    enum Rule: String {
        case place, person, pointInTime, purpose, perspective, aboutTo                       // para
        case reason, after, forSomeone, route, means, price, time, agent, stillToDo          // por
        case memorised, setPhrase, fallback

        /// The line of the simple rules this answer comes from, in the guide's words.
        var title: String {
            switch self {
            case .place: "Para: where it ends up. The Place it's headed"
            case .person: "Para: where it ends up. The Person who gets it"
            case .pointInTime: "Para: where it ends up. The Point in time it's due"
            case .purpose: "Para: where it ends up. The Purpose"
            case .perspective: "Para: where it ends up. The Perspective it's judged from"
            case .reason: "Por: what drives it. The reason"
            case .after: "Por: what drives it. The thing you're after"
            case .forSomeone: "Por: someone you do it for"
            case .agent: "Por: what drives it. Who did it"
            case .route: "Por: what it passes through. The route"
            case .means: "Por: what it passes through. The means"
            case .price: "Por: what it passes through. The price or the swap"
            case .time: "Por: what it passes through. The time"
            case .memorised: "Memorise: para siempre, para nada, no es para tanto"
            case .aboutTo, .stillToDo, .setPhrase: "Not covered by the rules: memorise this one"
            case .fallback: "No clear pattern"
            }
        }

        /// The answer comes from a line of the simple rules (or the three memorised phrases), not from outside them.
        var inRules: Bool { ![.aboutTo, .stillToDo, .setPhrase, .fallback].contains(self) }
    }

    struct Verdict: Equatable {
        /// Index of the por, para or ___ among the sentence's words.
        let position: Int
        /// What the sentence has there: "por", "para" or "___".
        let found: String
        let answer: Answer
        let rule: Rule
        let certainty: Certainty
        /// Why, about this sentence.
        let why: String
        /// For medium or low certainty: the other reading and what would decide it.
        let alternative: String?

        /// The sentence uses the other preposition from the one the rules expect.
        var disagrees: Bool { found != "___" && answer != .both && found != answer.rawValue }
    }

    // MARK: Explain

    /// One verdict for every por, para or ___ in the text.
    static func explain(_ text: String) -> [Verdict] {
        let raw = tokens(text)
        let w = raw.map { $0.lowercased() }
        var out: [Verdict] = []
        for (i, word) in w.enumerated() where word == "por" || word == "para" || word == "___" {
            // "el bus para en la esquina", "no para de llover": para the verb (parar)
            if word == "para", let p = i > 0 ? w[i - 1] : nil, ["bus", "autobús", "camión", "tren", "metro", "carro", "coche", "no", "se", "nunca", "lluvia", "nadie"].contains(p),
               !(i + 1 < w.count && ["que", "mí", "ti"].contains(w[i + 1])) { continue }
            out.append(Context(w: w, raw: raw, i: i, text: text).judge())
        }
        return out
    }

    /// Words, with ___ kept as one word and the original capitals kept.
    private static func tokens(_ text: String) -> [String] {
        var out: [String] = []
        var current = ""
        func flush() { if !current.isEmpty { out.append(current.hasPrefix("_") ? "___" : current); current = "" } }
        for ch in text {
            if ch == "_" { if !current.isEmpty && !current.hasPrefix("_") { flush() }; current.append(ch) }
            else if ch.isLetter || ch.isNumber { if current.hasPrefix("_") { flush() }; current.append(ch) }
            else { flush() }
        }
        flush()
        return out
    }

    static func plain(_ w: String) -> String { w.folding(options: .diacriticInsensitive, locale: Locale(identifier: "es")) }

    // MARK: Word lists (accents ignored)

    static let numberWords: Set<String> = ["un", "una", "uno", "dos", "tres", "cuatro", "cinco", "seis", "siete", "ocho", "nueve", "diez", "once", "doce", "quince", "veinte", "treinta", "cuarenta", "cincuenta", "cien", "ciento", "doscientos", "trescientos", "quinientos", "mil", "millon", "millones", "medio", "media", "par", "unos", "unas", "varios", "varias", "pocos", "pocas", "muchos", "muchas"]
    static let timeUnits: Set<String> = ["segundo", "segundos", "minuto", "minutos", "hora", "horas", "dia", "dias", "semana", "semanas", "mes", "meses", "ano", "anos", "rato", "momento", "momentos", "instante", "tiempo", "noche", "noches", "temporada", "siglo", "siglos", "decada", "decadas", "vida", "turno"]
    static let pointsInTime: Set<String> = ["lunes", "martes", "miercoles", "jueves", "viernes", "sabado", "domingo", "enero", "febrero", "marzo", "abril", "mayo", "junio", "julio", "agosto", "septiembre", "octubre", "noviembre", "diciembre", "manana", "pasado", "ayer", "hoy", "entonces", "despues", "luego", "navidad", "cumpleanos", "mediodia", "elecciones", "eleccion", "celebracion", "graduacion", "ocasion", "medianoche", "proximo", "proxima", "siguiente", "fin", "final", "principios", "finales", "mediados", "fecha", "boda", "fiesta", "examen", "reunion", "cena", "comida", "desayuno", "verano", "invierno", "otono", "primavera", "vacaciones", "semana"]
    static let money: Set<String> = ["peso", "pesos", "dolar", "dolares", "euro", "euros", "yen", "yenes", "centavo", "centavos", "libra", "libras", "dinero", "precio", "cuanto", "millon", "millones", "mil", "cien", "doble", "mitad", "dineral", "fortuna", "nada", "poco", "mucho", "menos", "mas", "barato"]
    static let throughNouns: Set<String> = ["ventana", "ventanas", "puerta", "puertas", "aire", "cielo", "calle", "calles", "pasillo", "tunel", "puente", "carretera", "autopista", "camino", "bosque", "selva", "zona", "barrio", "orilla", "frontera", "suelo", "piso", "techo", "chimenea", "agujero", "alrededores", "afueras"]
    static let placeNouns: Set<String> = ["casa", "escuela", "colegio", "oficina", "trabajo", "playa", "ciudad", "pueblo", "centro", "aeropuerto", "estacion", "hospital", "tienda", "mercado", "super", "supermercado", "iglesia", "universidad", "campo", "montana", "pais", "extranjero", "norte", "sur", "este", "oeste", "arriba", "abajo", "adelante", "atras", "adentro", "afuera", "aca", "alla", "cine", "banco", "biblioteca", "estadio", "gimnasio", "plaza", "hotel", "restaurante", "cocina", "sala", "cuarto", "habitacion", "cama", "mar", "costa", "isla", "lago", "bosque", "frontera", "capital", "puerto", "salida", "entrada", "europa", "america", "africa", "asia"]
    static let meansNouns: Set<String> = ["telefono", "celular", "correo", "email", "mail", "internet", "radio", "television", "tele", "fax", "mensaje", "whatsapp", "avion", "barco", "tren", "autobus", "taxi", "skype", "computadora", "ordenador", "video", "carta", "casualidad", "accidente", "error", "equivocacion", "escrito", "intermedio", "medio", "mano", "senas", "nombre", "apellido", "voz", "television", "web"]
    static let reasonHeads: Set<String> = ["negocios", "motivos", "razones", "trabajo", "placer", "gusto", "curiosidad", "culpa", "causa", "falta", "miedo", "temor", "celos", "envidia", "amor", "odio", "costumbre", "necesidad", "obligacion", "suerte", "desgracia", "lluvia", "trafico", "nieve", "tormenta", "frio", "calor", "viento", "enfermedad", "edad", "eso", "esto", "ello", "aquello", "orgullo", "verguenza", "lastima", "pena", "ignorancia", "descuido", "ayuda", "apoyo", "consejo", "regalo", "invitacion", "comprension", "paciencia", "atencion", "molestia", "retraso", "tardanza", "ruido", "humo", "hambre", "sed", "sueno", "cansancio", "estres", "salud"]
    static let persons: Set<String> = ["mi", "ti", "el", "ella", "usted", "nosotros", "nosotras", "vosotros", "vosotras", "ellos", "ellas", "ustedes", "todos", "todas", "alguien", "nadie", "si", "dios"]
    static let personHeads = ["mama", "papa", "madre", "padre", "hijo", "hija", "hijos", "hijas", "hermano", "hermana", "hermanos", "abuelo", "abuela", "abuelos", "tio", "tia", "novio", "novia", "novios", "esposo", "esposa", "amigo", "amiga", "amigos", "amigas", "jefe", "jefa", "profesor", "profesora", "maestro", "maestra", "nino", "nina", "ninos", "ninas", "bebe", "familia", "gente", "cliente", "clientes", "vecino", "vecina", "vecinos", "companero", "companera", "mujer", "hombre", "chico", "chica", "senor", "senora", "doctor", "doctora", "medico", "alumno", "alumnos", "estudiante", "estudiantes", "suegro", "suegra", "suegros", "primo", "prima", "sobrino", "sobrina", "nieto", "nieta", "invitados", "visitas", "pacientes", "turistas", "jugadores", "hermanos", "padres", "humanidad", "pueblo", "empleados", "trabajadores", "mayores", "jovenes", "adultos", "mascota", "perro", "gato", "todos"]
    static let determiners: Set<String> = ["el", "la", "los", "las", "un", "una", "unos", "unas", "mi", "mis", "tu", "tus", "su", "sus", "nuestro", "nuestra", "nuestros", "nuestras", "vuestro", "vuestra", "este", "esta", "estos", "estas", "ese", "esa", "esos", "esas", "aquel", "aquella", "al", "del", "otro", "otra", "otros", "otras", "cada", "algun", "alguna", "ningun", "ninguna", "cualquier", "tal", "tan", "muy", "mas", "tanto", "tanta", "todo", "toda", "todos", "todas"]

    // Verb stems, matched against whole words
    static func form(_ w: String?, _ forms: Set<String>) -> Bool { w.map { forms.contains(plain($0)) } ?? false }
    static func stem(_ w: String?, _ stems: [String], except: Set<String> = []) -> Bool {
        guard let w else { return false }
        let s = plain(w)
        return !except.contains(s) && stems.contains { s.hasPrefix($0) }
    }

    static let ir: Set<String> = ["ir", "voy", "vas", "va", "vamos", "van", "fui", "fuiste", "fue", "fuimos", "fueron", "iba", "ibas", "ibamos", "iban", "ire", "ira", "iremos", "iran", "vaya", "vayas", "vayamos", "vayan", "ve", "id", "yendo", "ido", "irme", "irte", "irse", "irnos", "vete", "vamonos", "voyme", "venir", "vengo", "vienes", "viene", "venimos", "vienen", "vine", "vino", "vinimos", "vinieron", "ven", "venia", "vendre", "vendra", "volver", "vuelvo", "vuelve", "volvio", "volvi", "regresar", "regreso", "regresa", "regresamos", "mandar", "mando", "manda", "mande", "mandaron", "mandamos", "mandaste", "mandalo", "baja", "bajo", "sube", "subo", "corre", "corro"]
    static let routeStems = ["pasa", "pase", "paso", "pasamos", "pasaron", "pasando", "pasar", "pasee", "pasea", "camin", "viaj", "recorr", "cruz", "atraves", "anduv", "anda", "andab", "circul", "deambul", "vag", "manej", "conduc", "volamos", "volaron", "volo", "vuela", "vuelan", "volando", "volar", "navega", "pasear", "asom", "metio", "colo", "escap", "huy", "corr", "baj", "sub", "rod", "desliz", "arrastr"]
    static let routeExcept: Set<String> = ["pastel", "pasado", "pasada", "pasaporte", "pasta", "pasillo", "pasajero", "pasajeros", "nada", "nadal", "paseo", "mirada", "salud", "salsa", "sala", "salon", "andaluz", "entre", "entrada", "busca", "colombia", "corre"]
    static let destinationStems = ["sal", "part", "march", "dirig", "encamin", "mud", "regres", "volv", "vuelv", "zarp", "embarc", "llev", "tom", "vol"]
    static let afterStems = ["luch", "pele", "vot", "opt", "apost", "aboga", "preocup", "inquiet", "interes", "brind", "rez", "orar", "oro", "ora", "muri", "muer", "mori", "sacrific", "suspir", "desvivi", "pregunt", "intercedi", "intercede", "decant", "inclin", "decid", "compit", "compet", "esfuerz", "esforz", "trabaj", "pelea", "pide", "pido", "pidi", "pedi", "esper", "llor", "sufr", "sient", "senti", "siento", "apasion", "obsesion", "fascin", "enamor", "loc", "ansi", "desesper", "impacien"]
    static let afterNouns: Set<String> = ["carino", "amor", "afecto", "sentimiento", "sentimientos", "respeto", "admiracion", "pasion", "interes", "aficion", "obsesion", "odio", "desprecio", "debilidad", "lucha", "batalla", "guerra", "carrera", "competencia", "pelea", "afan", "ansia", "ansias", "deseo", "sed", "hambre", "preocupacion", "simpatia", "devocion", "lastima", "compasion", "fe", "gusto", "entusiasmo", "curiosidad", "celos", "envidia", "miedo", "temor", "preferencia", "voto", "votos", "apuesta"]
    static let causeStems = ["gracias", "perdon", "disculp", "agradec", "felicit", "culp", "castig", "mult", "premi", "conocid", "famos", "celebr", "arrest", "detuv", "detenid", "despid", "conden", "acus", "elogi", "critic", "regan", "sancion", "lament", "arrepient", "arrepent", "avergonz", "enoj", "enfad", "molest", "quej", "excus", "orgull", "sorprend", "asust", "cansad", "harto", "harta", "endeud", "agradecid", "felicidad", "contento", "contenta", "feliz", "triste", "furios", "nervios", "suspend", "cancel", "cerr", "retras", "aplaz", "llegue", "llego", "llegaste", "llegamos", "llegaron", "falt", "pague", "pago", "pagaste", "pagamos", "pagaron", "pagar", "cobr", "gan", "recompens", "desmay", "desmaya"]
    static let swapStems = ["cambi", "intercambi", "vend", "compr", "pag", "cobr", "ofrec", "sustitu", "reemplaz", "confund", "canje", "troc", "alquil", "rent", "dej"]
    static let giveForms: Set<String> = ["da", "das", "dan", "damos", "di", "dio", "dieron", "doy", "dar", "dame", "daria", "darias", "pides", "pide", "piden", "pediste", "pidio", "quieres", "quiere", "cobras", "cobra", "ofreces", "ofrece"]
    static let purposeHeads: Set<String> = ["examen", "viaje", "fiesta", "boda", "cena", "comida", "desayuno", "postre", "trago", "sopa", "cafe", "agua", "vino", "te", "dolor", "tos", "gripa", "gripe", "fiebre", "cabeza", "puesto", "trabajo", "entrevista", "partido", "carrera", "colision", "invierno", "verano", "ocasion", "evento", "visita", "visitas", "campana", "iglesia", "escuela", "casa", "cocina", "bano", "uso", "consumo", "venta", "regalo", "cumpleanos", "navidad", "boda", "aniversario", "futuro", "mañana", "manana", "vida", "salud", "piel", "pelo", "ojos", "todo", "todos", "eso", "esto", "algo", "ello"]
    static let suitedStems = ["bueno", "buena", "buenos", "buenas", "malo", "mala", "malos", "malas", "mejor", "peor", "util", "inutil", "necesari", "importante", "suficiente", "bastante", "demasiad", "list", "prepar", "dispuest", "apt", "capaz", "capac", "ideal", "perfect", "apropiad", "adecuad", "propi", "dificil", "facil", "imposible", "posible", "peligros", "danin", "nociv", "toxic", "amenaza", "popular", "famos", "conocid", "tarde", "temprano", "pronto", "joven", "viejo", "vieja", "alto", "alta", "bajo", "baja", "grande", "pequen", "caro", "cara", "barato", "lento", "rapido", "listo", "raro", "normal", "comun", "extran", "suficiente", "tiempo", "ganas", "fuerza", "fuerzas", "valor", "coraje", "permiso", "derecho", "razon", "razones", "motivo", "motivos", "excusa", "base", "fundamento", "dificultad", "dificultades", "problema", "problemas", "oportunidad", "forma", "manera", "modo", "truco", "clave", "consejo", "plan", "idea", "necesidad", "habilidad", "talento", "facilidad", "espacio", "sitio", "lugar", "experiencia", "requisito", "condicion", "papel", "material", "ingrediente", "herramienta", "maquina", "aparato", "producto", "medicina", "remedio", "pastilla", "crema", "receta", "libro", "pelicula", "cancion", "musica", "juego", "regalo", "regalos", "comida", "ropa", "dinero", "presupuesto", "ahorro", "ahorr", "prepar", "entren", "estudi", "sirv", "serv", "us", "utiliz", "emple", "necesit", "requier", "hac falta", "capacit", "preparac", "destin", "dise", "hech", "fabric", "reserv", "guard", "compr", "traj", "llev", "compre", "compro", "cocin", "escrib", "pint", "constru"]

    // MARK: One por / para / gap

    private struct Context {
        let w: [String]; let raw: [String]; let i: Int; let text: String
        var found: String { w[i] }
        func at(_ k: Int) -> String? { k >= 0 && k < w.count ? w[k] : nil }
        var next: String? { at(i + 1) }
        var next2: String? { at(i + 2) }
        var prev: String? { at(i - 1) }
        var prev2: String? { at(i - 2) }
        var before: [String] { Array(w[max(0, i - 4)..<i]) }
        var nextPlain: String? { next.map(plain) }
        var next2Plain: String? { next2.map(plain) }
        var prevPlain: String? { prev.map(plain) }
        var atStart: Bool { i == 0 || ["y", "pero", "e", "o", "que", "pues"].contains(prev ?? "") }

        /// The first content word after the gap, skipping articles and possessives.
        var headIndex: Int? {
            var j = i + 1
            while j < w.count, determiners.contains(plain(w[j])) && !(j == i + 1 && ["mi", "el"].contains(w[j]) && raw[j].count <= 2 && isPronounUse(j)) { j += 1 }
            return j < w.count ? j : nil
        }
        var head: String? { headIndex.map { plain(w[$0]) } }
        var headCapitalised: Bool { headIndex.map { raw[$0].first?.isUppercase == true && $0 > 0 } ?? false }

        /// mí / él written without the accent in some sentences: pronoun when nothing noun-like follows.
        func isPronounUse(_ j: Int) -> Bool { j + 1 >= w.count || [",", "y", "que", "no", "es", "lo", "la", "le", "me", "te", "se"].contains(w[j + 1]) }

        var isPerson: Bool {
            guard let n = next else { return false }
            if ["mí", "ti", "él", "ella", "usted", "ustedes", "nosotros", "nosotras", "vosotros", "vosotras", "ellos", "ellas", "todos", "todas", "alguien", "nadie", "sí", "dios"].contains(n) { return true }
            if raw.indices.contains(i + 1), raw[i + 1].first?.isUppercase == true, i + 1 > 0, !placeNouns.contains(plain(n)) { return true }
            guard let h = head else { return false }
            return personHeads.contains(h)
        }

        func v(_ a: Answer, _ r: Rule, _ c: Certainty, _ why: String, _ alt: String? = nil) -> Verdict {
            Verdict(position: i, found: found, answer: a, rule: r, certainty: c, why: why, alternative: alt)
        }

        func phrase(_ words: [String]) -> Bool {
            for (k, p) in words.enumerated() { guard let x = at(i + 1 + k), plain(x) == plain(p) else { return false } }
            return true
        }

        func isInfinitive(_ word: String?) -> Bool {
            guard var s = word.map(plain) else { return false }
            if ["ir", "ver", "dar", "ser", "oir", "reir", "irse", "irme", "irte", "verte", "verlo", "verla", "verme", "vernos", "darle", "darte", "dame", "decirte", "decirle"].contains(s) { return true }
            for clitic in ["selo", "sela", "selos", "selas", "melo", "mela", "telo", "tela", "noslo", "nos", "les", "los", "las", "me", "te", "se", "le", "lo", "la"] where s.hasSuffix(clitic) && s.count >= clitic.count + 3 {
                let base = String(s.dropLast(clitic.count))
                if base.hasSuffix("ar") || base.hasSuffix("er") || base.hasSuffix("ir") { s = base; break }
            }
            let nouns: Set<String> = ["lugar", "mujer", "hogar", "mar", "par", "bar", "ayer", "azucar", "dolar", "placer", "mayor", "menor", "mejor", "peor", "amor", "calor", "color", "flor", "dolor", "favor", "senor", "error", "interior", "exterior", "exterior", "alrededor", "cualquier", "tener", "poder", "deber", "ser"]
            if ["tener", "poder", "deber", "ser"].contains(s) { return true }
            if nouns.contains(s) || s.count < 4 { return false }
            return s.hasSuffix("ar") || s.hasSuffix("er") || s.hasSuffix("ir")
        }

        // MARK: The rules, in order

        func judge() -> Verdict {
            if let r = setPhrases() { return r }
            if let r = beforeAVerb() { return r }
            if let r = priceAndRate() { return r }
            if let r = agentAndMeans() { return r }
            if let r = perspective() { return r }
            if let r = causeAndAfter() { return r }
            if let r = placesAndRoutes() { return r }
            if let r = timeAndDeadline() { return r }
            if let r = people() { return r }
            if let r = whatItsFor() { return r }
            return v(.por, .fallback, .low, "No clear pattern. Por is the wider word: what drives it, or what it passes through.",
                     "If the action ends up there (a place, a person who gets it, a deadline, a purpose), it's para.")
        }

        // 1. Set phrases
        func setPhrases() -> Verdict? {
            if ["es", "era", "fue", "sera"].contains(prevPlain ?? ""), prev2 == "no", next == "tanto" { return v(.para, .memorised, .high, "No es para tanto: it's not that big a deal.") }
            if phrase(["siempre"]) { return v(.para, .memorised, .high, "Para siempre: forever.") }
            if phrase(["nada"]), before.contains("no") || prev == "no", !stem(prev, ["preocup", "hac", "hag", "pag", "cambi", "dej", "vend"]) {
                return v(.para, .memorised, .high, "No … para nada: not at all.", "Por nada (\"for nothing\", \"you're welcome\") also exists.")
            }
            // ¿por qué? (why) or ¿para qué? (what for)
            if let n = next, ["qué", "que"].contains(n), text.contains("¿") || n == "qué" {
                if before.contains(where: { stem($0, ["sirv", "sirve", "serv", "necesit"]) }) || after(i + 1).contains(where: { stem($0, ["sirv", "sirve", "serv", "necesit", "usa", "uso", "utiliz"]) }) {
                    return v(.para, .purpose, .high, "¿Para qué? asks what it's for: the Purpose.")
                }
                return v(.por, .reason, .medium, "¿Por qué? asks why: the reason that drives it.", "¿Para qué? would ask what it's for instead.")
            }
            if next == "que" { return v(.para, .purpose, .high, "Para que + subjunctive: so that, the Purpose.", "After luchar, rezar or preocuparse, por que (\"for … to happen\") is right too.") }
            if next == "quién" || next == "quien" {
                if (before + after(i + 1)).contains(where: { stem($0, afterStems) || stem($0, causeStems) }) { return v(.por, .after, .medium, "¿Por quién?: who someone's going after, voting for, asking about.") }
                return v(.para, .person, .medium, "¿Para quién?: the Person who gets it.", "¿Por quién? asks who it's done for or because of.")
            }
            if phrase(["cuando"]) || phrase(["cuándo"]) || phrase(["entonces"]) { return v(.para, .pointInTime, .high, "Para cuando / para entonces: by the time, the Point in time it's due.") }
            let porSet: [[String]] = [["favor"], ["fin"], ["supuesto"], ["ejemplo"], ["lo", "menos"], ["lo", "tanto"], ["lo", "general"], ["lo", "visto"], ["lo", "que"], ["cierto"], ["si"], ["ahora"], ["completo"], ["casualidad"], ["desgracia"], ["suerte"], ["primera", "vez"], ["ultima", "vez"], ["ultimo"], ["la", "manana"], ["la", "tarde"], ["la", "noche"], ["las", "mananas"], ["las", "tardes"], ["las", "noches"], ["ciento"], ["lo", "pronto"], ["otra", "parte"], ["otro", "lado"], ["un", "lado"], ["una", "parte"], ["lo", "comun"], ["lo", "demas"], ["mucho", "que"], ["mas", "que"], ["muy", "que"], ["mi", "parte"], ["su", "parte"], ["tu", "parte"], ["cuenta"], ["dentro"], ["fuera"], ["encima"], ["debajo"], ["detras"], ["delante"], ["adelantado"], ["igual"], ["separado"], ["escrito"], ["las", "buenas"], ["las", "malas"], ["fortuna"], ["lo", "mismo"], ["ende"], ["consiguiente"], ["aqui"], ["alli"], ["ahi"], ["aca"], ["todas", "partes"], ["todos", "lados"], ["doquier"], ["algun", "lado"], ["ningun", "lado"], ["alguna", "parte"], ["ninguna", "parte"], ["cualquier", "cosa"], ["el", "momento"], ["ahora"], ["si", "solo"], ["si", "sola"], ["si", "mismo"], ["si", "misma"], ["si", "mismos"], ["mas", "de"], ["menos", "de"], ["poco"], ["lo", "menos"], ["las", "dudas"], ["lo", "bajo"], ["norma"], ["regla"], ["lejos"], ["la", "mitad"], ["la", "fuerza"], ["mayoria"], ["unanimidad"], ["sorpresa"], ["turnos"], ["orden"], ["etapas"], ["partes"], ["primera"], ["una", "vez"], ["cada"], ["dia"], ["hora"], ["semana"], ["mes"], ["ano"], ["persona"], ["cabeza"]]
            for p in porSet where phrase(p) {
                let joined = p.joined(separator: " ")
                if p == ["fin"], next2 == "de" { continue }
                if p == ["poco"], !(before.contains(where: { stem($0, swapStems) }) || atStart || prev == "y" || stem(prev, ["me", "nos", "se"])) { continue }
                if p == ["ultimo"], !atStart { continue }
                if ["dia", "hora", "semana", "mes", "ano", "persona", "cabeza", "cada"].contains(p[0]) {
                    if prev.map({ $0.first?.isNumber == true || numberWords.contains(plain($0)) || ["veces", "vez", "kilometros", "km", "millas", "pesos", "dolares", "euros", "litros"].contains(plain($0)) }) ?? false || p[0] == "cada" { return v(.por, .price, .high, "A rate: so much per \(next!).") }
                    continue
                }
                if ["mas", "menos"].contains(p[0]), p.count == 2 { return v(.por, .time, .medium, "Por más de …: the time it fills, or an amount.") }
                if ["aqui", "alli", "ahi", "aca"].contains(p[0]) { return v(.por, .route, .high, "Por \(next!): around there, the area it moves through.") }
                if p.first == "la" || p.first == "las", p.count == 2, ["manana", "tarde", "noche", "mananas", "tardes", "noches"].contains(p[1]) {
                    if before.contains(where: { stem($0, ["reserv", "list", "prepar", "cita", "plan"]) }) { continue }
                    return v(.por, .time, .high, "Por \(joined): the part of the day, the time it fills.")
                }
                if p == ["el", "momento"] { return v(.por, .time, .high, "Por el momento: for now.") }
                if p == ["ciento"] { return v(.por, .price, .high, "Por ciento: per cent, a rate.") }
                if p == ["si"] || p == ["si", "acaso"] { return v(.por, .setPhrase, .high, "Por si: in case. A set phrase.") }
                if p.first == "si", p.count == 2 { return v(.por, .setPhrase, .high, "Por sí \(p[1]): by oneself. A set phrase.") }
                return v(.por, .setPhrase, .high, "Por \(joined) is a set phrase.")
            }
            // la razón por la que, el motivo por el cual
            if stem(prev, ["razon", "motivo", "causa"]), let n = nextPlain, ["la", "el", "lo", "las", "los"].contains(n), let n2 = next2Plain, ["que", "cual", "cuales"].contains(n2) { return v(.por, .reason, .high, "La razón por la que …: the reason, por + que.") }
            // eso: por eso (that's why) or para eso (for that)
            if next == "eso" || next == "esto" {
                if (next2.map { ["estan", "están", "son", "sirve", "sirven", "vine", "vino", "viniste"].contains($0) } ?? false) || stem(prev, suitedStems) || stem(prev, ["tiempo", "ganas", "list"]) {
                    return v(.para, .purpose, .high, "Para eso: for that, the Purpose.")
                }
                return v(.por, .reason, .high, "Por \(next!): because of that, the reason.")
            }
            let paraSet: [[String]] = [["colmo"], ["variar"], ["mi", "que"], ["bien", "o"], ["mal"], ["chuparse"], ["mi", "sorpresa"], ["su", "sorpresa"], ["mi", "gusto"], ["su", "gusto"], ["tu", "gusto"], ["nuestra", "sorpresa"], ["alla"], ["aca"], ["arriba"], ["abajo"], ["adelante"], ["atras"], ["adentro"], ["afuera"]]
            for p in paraSet where phrase(p) {
                if p == ["mal"], !before.contains("bien") { continue }
                if ["alla", "aca", "arriba", "abajo", "adelante", "atras", "adentro", "afuera"].contains(p[0]) {
                    if p[0] == "alla" || p[0] == "aca", stem(prev, routeStems, except: routeExcept) || form(prev, ["hace", "hay", "esta", "estan", "vive", "viven"]) {
                        return v(.por, .route, .medium, "Por \(p[0]): around there.", "Para \(p[0]) would mean toward there.")
                    }
                    return v(.para, .place, .high, "Para \(next!): the direction it's headed, a Place.")
                }
                return v(.para, .setPhrase, .high, "Para \(p.joined(separator: " ")) is a set phrase. Memorise it.")
            }
            if atStart, let n = next.map(plain), ["empezar", "comenzar", "terminar", "acabar", "resumir", "concluir"].contains(n) { return v(.para, .purpose, .high, "Para \(n): a set phrase built on Purpose (\"to begin with\", \"in short\").") }
            if next == "ser", let n2 = next2.map(plain), ["sincero", "sincera", "honesto", "honesta", "franco", "franca", "exactos", "precisos", "justos"].contains(n2) { return v(.para, .purpose, .high, "Para ser \(n2): to be \(n2), a set phrase.") }
            return nil
        }

        func after(_ k: Int) -> [String] { Array(w[min(w.count, k + 1)..<min(w.count, k + 5)]) }

        // 2. A verb right after
        func beforeAVerb() -> Verdict? {
            guard isInfinitive(next) else { return nil }
            let n = nextPlain!
            // Quedan dos cartas por escribir; ¿cuánto falta para llegar?
            if let q = before.lastIndex(where: { stem($0, ["qued", "falt"]) }) {
                let todoVerbs: Set<String> = ["hacer", "resolver", "terminar", "limpiar", "arreglar", "pagar", "leer", "escribir", "decidir", "descubrir", "aprender", "revisar", "corregir", "contestar", "ver", "investigar", "construir", "decir"]
                let directly = q == before.count - 1 || (q == before.count - 2 && ["poco", "mucho", "nada", "cuanto"].contains(prevPlain ?? ""))
                if !directly || (stem(before[q], ["qued"]) && todoVerbs.contains(n) && ["mucho", "nada", "poco"].contains(prevPlain ?? "")) { return v(.por, .stillToDo, .high, "\(before[q]) … por + verb: still to be done.") }
                return v(.para, .pointInTime, .medium, "Falta / queda para + verb: how long until it happens.", "With a thing in between (quedan dos cartas por escribir), it's por: still to be done.")
            }
            // Estar por / para + verb
            if let p = prevPlain, ["esta", "estan", "estaba", "estaban", "estoy", "estas", "estamos", "estuvo", "estare", "estara", "estaria"].contains(p) {
                if (prev2.map { plain($0) == "loco" || plain($0) == "loca" } ?? false) { return nil }
                return v(.both, .aboutTo, .medium, "Estar + \(found == "___" ? "por / para" : found) + verb: about to happen. Both work; Mexico prefers por. If a job is still waiting (la casa está por limpiar), it's por.")
            }
            let todo: Set<String> = ["hacer", "resolver", "terminar", "limpiar", "arreglar", "pagar", "leer", "escribir", "decidir", "descubrir", "aprender", "recorrer", "revisar", "corregir", "contestar", "responder", "explicar", "averiguar", "ver", "investigar", "construir", "pintar", "lavar", "planchar"]
            if todo.contains(n), let p = prevPlain, ["mucho", "mucha", "muchos", "muchas", "poco", "nada", "trabajo", "cosas", "tareas", "pendientes", "monton", "capitulos", "paginas", "cartas", "preguntas", "problemas", "platos", "kilometros", "camino"].contains(p) {
                if p == "trabajo", !(prev2.map { ["de", "mucho", "el", "un", "tengo", "hay", "tanto", "poco"].contains(plain($0)) } ?? false) { return nil == nil ? purposeVerb(n) : nil }
                return v(.por, .stillToDo, .medium, "\(p) por \(n): still to be done.", "If it's what the thing is for (algo para comer), it's para.")
            }
            // Too / enough … para + verb
            if before.contains(where: { stem($0, ["demasiad", "suficiente", "bastante"]) }) || prev == "como" { return v(.para, .purpose, .high, "Too / enough … para + verb: what it would take, the Purpose.") }
            // Crazy enough to: tienes que estar loco para …
            if stem(prev, ["loco", "loca"]), before.contains(where: { stem($0, ["ten", "hay", "hace"]) }) || before.contains("estar") { return v(.para, .purpose, .medium, "Estar loco para + verb: crazy enough to.", "Loco por + verb means dying to.") }
            // Going after: luchar por ser libres, loco por verte, me muero por saber
            if before.suffix(2).contains(where: { stem($0, ["luch", "pele", "esforz", "esfuerz", "desvivi", "muer", "mori", "suspir", "loco", "loca", "ansios", "desesper", "impacien", "deseos", "anhel", "rabi"]) || afterNouns.contains(plain($0)) && !["miedo", "temor", "gusto", "lastima"].contains(plain($0)) }) {
                return v(.por, .after, .medium, "\(before.last!) por + verb: the thing you're after (wanting it drives you).", "Para + verb would make it a plain purpose; with luchar, both work.")
            }
            // Cause first: perdón por llegar tarde, lo despidieron por robar, gracias por venir
            if before.contains(where: { stem($0, causeStems) && !stem($0, ["pag", "cobr", "gan", "falt", "llegue", "llego"]) }) {
                return v(.por, .reason, .high, "\(before.last(where: { stem($0, causeStems) })!) … por + verb: what caused it, the reason.")
            }
            // Because of being: me dieron descuento por ser estudiante
            if n == "ser" || n == "estar" || n == "tener" || n == "haber", let n2 = next2.map(plain) {
                if ["tan", "muy", "tan", "un", "una"].contains(n2) && n == "ser" && next2 == "tan" || (n == "ser" && ["tan", "muy"].contains(n2)) { return v(.para, .perspective, .high, "Para ser tan …: considering, the Perspective it's judged from.") }
                let earlier = w[..<i]
                if earlier.contains("no") && earlier.contains(where: { stem($0, ["pud", "pued", "fui", "vin", "vine", "particip", "asist", "fue"]) }) || before.contains(where: { stem($0, ["descuent", "castig", "mult", "despid", "rechaz", "discrimin", "premi"]) }) || ["mujer", "hombre", "estudiante", "extranjero", "menor", "mayor"].contains(n2) && n == "ser" {
                    return v(.por, .reason, .medium, "Por \(n) …: because of being, the reason.", "Para \(n) … would be the purpose: in order to be.")
                }
            }
            return purposeVerb(n)
        }

        func purposeVerb(_ n: String) -> Verdict {
            v(.para, .purpose, .medium, "Para + verb: the Purpose, in order to \(n).", "Por + verb also works when it's the motive pushing you (lo hice por ayudarte).")
        }

        // 3. Price, swaps and rates
        func priceAndRate() -> Verdict? {
            guard let n = nextPlain else { return nil }
            // Minutes para the hour: diez para las cinco
            if ["las", "la"].contains(n), let n2 = next2Plain, n2.first?.isNumber == true || numberWords.contains(n2), prev.map({ $0.first?.isNumber == true || numberWords.contains(plain($0)) || ["cuarto", "minutos", "poco"].contains(plain($0)) }) ?? false {
                return v(.para, .pointInTime, .high, "Minutes para the hour (\(prev!) para \(n) \(n2)): the time it's counting down to.")
            }
            if let p = prevPlain, ["mesa", "cuarto", "habitacion", "capacidad", "lugar", "espacio", "asientos", "comida", "boletos", "cupo", "suficiente", "alcanza", "alcanzar"].contains(p) { return v(.para, .person, .high, "\(prev!) para + a number of people: who it's for.") }
            let isAmount = n.first?.isNumber == true || (numberWords.contains(n) && !["un", "una", "unos", "unas", "medio", "media", "muchos", "muchas", "pocos", "pocas", "varios", "varias"].contains(n)) || ["un", "una", "medio", "media", "unos", "unas"].contains(n) && (next2Plain.map { money.contains($0) || $0 == "par" || $0.first?.isNumber == true || timeUnits.contains($0) || numberWords.contains($0) } ?? false)
            if isAmount {
                let unit = w[(i + 2)...].prefix(3).map(plain).first { timeUnits.contains($0) }
                if let unit, !before.contains(where: { stem($0, swapStems) }) {
                    if before.contains(where: { stem($0, ["reserv", "habitacion", "cuarto", "mesa", "boleto", "suficiente", "comida", "contrat", "alquil", "rent", "plan", "listo", "provision", "dinero", "permiso", "visa"]) }) {
                        return v(.para, .pointInTime, .medium, "Para + a period: what it's booked or meant for.", "If it's how long something lasts, por (or nothing).")
                    }
                    return v(.por, .time, .medium, "Por + a length of time (\(unit)): the time it fills. Often there's no preposition at all.", "A booking or plan for a period takes para (un cuarto para dos noches).")
                }
                return v(.por, .price, .high, "Por + an amount: the price, what it's traded for.")
            }
            if let p = prevPlain, p.first?.isNumber == true || ["veces", "vez", "kilometros", "km", "millas", "pesos", "dolares", "euros", "litros", "dos", "tres", "cuatro", "cinco"].contains(p), let h = head, timeUnits.contains(h) || ["persona", "cabeza", "ciento", "uno", "dos", "tres", "cuatro", "cinco", "seis", "siete", "ocho", "nueve", "diez"].contains(h) || h.first?.isNumber == true {
                return v(.por, .price, .high, "A rate or multiplication: \(p) por \(h).")
            }
            if n == "cuanto" || n == "cuánto" { return v(.por, .price, .high, "¿Por cuánto?: the price.") }
            if before.contains(where: { stem($0, ["cuant", "cuánto"]) }) && before.contains(where: { form($0, giveForms) || stem($0, ["pag", "cobr", "vend", "compr"]) }) { return v(.por, .price, .high, "How much … por it: what it's traded for.") }
            if before.contains(where: { stem($0, swapStems) && !stem($0, ["dej", "compr"]) }) || before.contains(where: { form($0, giveForms) }) && (head.map { money.contains($0) } ?? false) {
                if let h = head, money.contains(h) || ["otro", "otra", "uno", "una", "nuevo", "nueva", "algo", "talla", "modelo", "color", "camisa", "dinero", "efectivo", "cupon", "boleto", "articulo", "producto", "cambio", "dinero"].contains(h) || (headIndex.map { $0 == i + 1 && ["otro", "otra", "uno", "una"].contains(w[$0]) } ?? false) || ["otro", "otra"].contains(nextPlain ?? "") {
                    return v(.por, .price, .high, "Swapping, paying or selling: what it's traded for.")
                }
                if stem(before.last(where: { stem($0, swapStems) }), ["pag", "cobr"]) && !isPerson { return v(.por, .price, .high, "Pagar / cobrar por: what the money is for, traded.") }
            }
            if let h = head, ["peso", "pesos", "dolar", "dolares", "euro", "euros", "yen", "yenes", "centavos", "libras", "dineral", "fortuna"].contains(h) { return v(.por, .price, .high, "Por + money: the price.") }
            return nil
        }

        // 4. Who did it (passive) and the means
        func agentAndMeans() -> Verdict? {
            if let h = head, meansNouns.contains(h), !(prev.map { stem($0, ["pag", "compr", "fabric", "hech", "diseñ", "disen", "chips", "piezas"]) } ?? false), head != "carta" || before.contains(where: { stem($0, ["envi", "mand", "supe", "dijo", "conteste"]) }) {
                return v(.por, .means, .high, "Por \(h): the means, how it's done.")
            }
            guard let p = prevPlain else { return nil }
            let participle = ["ado", "ada", "ados", "adas", "ido", "ida", "idos", "idas"].contains { p.hasSuffix($0) } || ["escrito", "escrita", "escritos", "hecho", "hecha", "hechos", "dicho", "visto", "vista", "abierto", "descubierto", "descubierta", "compuesto", "compuesta", "puesto", "cubierto", "cubierta", "devuelto", "resuelto", "roto"].contains(p)
            let adjectives: Set<String> = ["cansado", "cansada", "preparado", "preparada", "listo", "lista", "dispuesto", "dispuesta", "agradecido", "agradecida", "preocupado", "preocupada", "interesado", "interesada", "ocupado", "ocupada", "pasado", "pasada", "acostumbrado", "acostumbrada", "obligado", "obligada", "destinado", "destinada", "reservado", "reservada", "disenado", "disenada", "pensado", "pensada", "invitado", "invitada", "apurado", "emocionado", "emocionada", "conocido", "conocida", "nada", "todo", "lado", "estado", "demasiado", "demasiada", "apropiado", "apropiada", "adecuado", "adecuada", "casado", "casada", "hadas", "cuidado", "partido", "sentido", "vestido", "helado", "pescado", "mercado", "abogado", "soldado", "comida", "bebida", "salida", "llegada", "vida", "medida", "querida", "querido", "ido", "sido", "nacido", "nacida", "muerto", "enamorado", "enamorada", "loco", "orgulloso", "famoso", "pesado", "pesada", "endeudado", "endeudada", "aburrido", "aburrida", "asustado", "asustada", "enfadado", "enojado", "molesto", "harto", "contento"]
            guard participle, !adjectives.contains(p), !(p.hasSuffix("s") && adjectives.contains(String(p.dropLast()))) else { return nil }
            let aux: Set<String> = ["fue", "fueron", "es", "son", "era", "eran", "sera", "seran", "sido", "ha", "han", "habia", "fui", "fuimos", "esta", "estan", "estaba", "estaban", "estuvo", "estoy", "estamos", "siendo", "resulto", "quedo", "quedaron", "fuiste", "eres", "soy", "somos", "seria", "hemos", "has", "he"]
            if (prev2.map { aux.contains(plain($0)) } ?? false) || (at(i - 3).map { aux.contains(plain($0)) } ?? false) || ["escrito", "escrita", "pintado", "pintada", "compuesto", "compuesta", "dirigido", "dirigida", "producido", "rodeado", "rodeada", "causado", "causada", "provocado", "provocada", "inventado", "inventada", "descubierto", "creado", "creada", "fundado", "fundada", "construido", "construida", "traducido", "traducida", "atacado", "atacada", "mordido", "mordida", "elegido", "elegida", "aprobado", "aprobada", "detenido", "arrestado", "perseguido", "seguido", "amado", "odiado", "respetado", "admirado", "apreciado", "afectado", "afectada", "golpeado", "herido", "herida", "atropellado", "atropellada", "contratado", "despedido", "rechazado", "rechazada", "aceptado", "aceptada", "motivado", "motivados", "impulsado", "inspirado", "inspirada", "patrocinado", "financiado", "apoyado", "apoyada", "criado", "criada", "educado", "educada", "visitado", "visitada", "habitado", "poblado", "dominado", "gobernado", "controlado", "ocupada"].contains(p) {
                if let h = head, pointsInTime.contains(h) || purposeHeads.contains(h) && !personHeads.contains(h) && !(headCapitalised) { return nil }
                return v(.por, .agent, .high, "\(prev!) por …: who did it.")
            }
            return nil
        }

        // 5. Causes and the thing you're after
        func causeAndAfter() -> Verdict? {
            // Learning something through someone: lo supe por mi prima, la conocí por un amigo
            if isPerson || (head.map { personHeads.contains($0) } ?? false), before.contains(where: { stem($0, ["conoc", "conoz", "sup", "enter", "escuch", "oi", "oyo", "dij", "contact", "localic", "llam", "recib"]) }) {
                return v(.por, .means, .high, "Knowing or hearing it through someone: the means.")
            }
            // Arrived late because of …
            if prevPlain == "tarde", stem(prev2, ["lleg"]) { return v(.por, .reason, .high, "Llegar tarde por …: what caused it, the reason.") }
            if let h = head, reasonHeads.contains(h), !before.contains(where: { stem($0, suitedStems) && !stem($0, ["gan", "tiempo"]) }) || ["motivos", "razones", "culpa", "causa", "falta", "lluvia", "trafico", "nieve", "tormenta", "enfermedad", "accidente"].contains(h) {
                if !["salud", "trabajo", "eso", "esto", "regalo", "ayuda", "apoyo", "consejo", "comida"].contains(h) || before.contains(where: { stem($0, causeStems) || stem($0, ["viaj", "fum", "dej", "lleg", "falt", "vin", "vine", "vino", "fue", "fui"]) }) {
                    if h == "trabajo", before.contains(where: { stem($0, ["prepar", "list", "ropa", "corbata", "traje", "vest"]) }) { return nil }
                    return v(.por, .reason, .medium, "Por \(h): what drives it, the reason (\"because of\").", "If it's what the action is meant to produce, it's para.")
                }
            }
            if before.contains(where: { stem($0, causeStems) && !stem($0, ["pag", "cobr", "gan", "llegue", "llego", "llegaste", "llegamos", "llegaron", "falt"]) }) {
                let w0 = before.last(where: { stem($0, causeStems) })!
                return v(.por, .reason, .high, "\(w0) … por: what caused it, the reason.")
            }
            // Fetching a thing or person: voy por pan, fui por los niños, mandaron por el médico
            if before.suffix(2).contains(where: { form($0, ir) }), let h = head, !placeNouns.contains(h), !pointsInTime.contains(h), !headCapitalised || isPerson, !throughNouns.contains(h) {
                if !["mi", "ti"].contains(next ?? "") || before.contains(where: { stem($0, ["mand", "vin", "ven", "vien", "pas"]) }) {
                    return v(.por, .after, .medium, "\(before.last(where: { form($0, ir) })!) por + \(h): going to get it, the thing you're after.", "If it's a place, para is where you're headed.")
                }
            }
            // Feelings, fights, choices, prayers, asking about
            if prevPlain == "pregunta" || prevPlain == "preguntas", !(prev2.map { determiners.contains(plain($0)) } ?? false) { return v(.por, .after, .high, "Preguntar por: asking about someone or something, the thing you're after.") }
            if before.suffix(3).contains(where: { afterNouns.contains(plain($0)) }) || stem(prev, afterStems, except: ["pregunta", "esperanza", "sentido", "lucha", "loca", "local", "locales", "orale", "orden", "oro", "pedido", "pedidos", "trabajo"]) || (prev.map { determiners.contains(plain($0)) == false } ?? true) && stem(prev2, afterStems, except: ["pregunta", "esperanza", "sentido", "orden", "oro", "trabajo", "pedido"]) && !["mucho", "duro", "tanto", "siempre", "mas", "menos", "bien", "mal", "juntos"].contains(prevPlain ?? "") {
                let verb = before.last { stem($0, afterStems) || afterNouns.contains(plain($0)) } ?? ""
                if stem(verb, ["trabaj"]) {
                    if isPerson || (head.map { ["empresa", "compania", "gobierno", "banco", "firma", "periodico", "revista", "cadena", "agencia", "familia", "padre", "tio"].contains($0) } ?? false) { return v(.para, .person, .medium, "Trabajar para + a person or company: who gets your work, the employer.", "Trabajo por Ana would mean in Ana's place.") }
                    if let h = head, ["paz", "causa", "bien", "libertad", "derechos", "justicia", "futuro", "pais", "patria", "comunidad"].contains(h) { return v(.por, .after, .high, "Working for a cause: the thing you're after.") }
                    return nil
                }
                if stem(verb, ["pide", "pido", "pidi", "pedi"]) && !isPerson { return nil }
                if stem(verb, ["esper"]) && !isPerson { return nil }
                return v(.por, .after, .high, "\(verb) por: the thing you're after, or the one it's for. Wanting it is what drives you.")
            }
            return nil
        }

        // 6. Places and routes
        func placesAndRoutes() -> Verdict? {
            guard let h = head else { return nil }
            let routeVerb = before.suffix(3).contains { stem($0, routeStems, except: routeExcept) }
            if throughNouns.contains(h) && !placeNouns.contains(h) || ["ventana", "puerta", "aire", "pasillo", "tunel", "puente", "chimenea", "agujero", "calle", "orilla"].contains(h) {
                if !(before.suffix(2).contains { stem($0, destinationStems) } && !routeVerb) || ["ventana", "puerta", "aire", "tunel", "puente", "chimenea", "agujero", "pasillo"].contains(h) {
                    return v(.por, .route, .high, "Por \(h): the route or area it passes through.")
                }
            }
            if routeVerb, !before.suffix(2).contains(where: { stem($0, destinationStems) && !stem($0, routeStems, except: routeExcept) }) || throughNouns.contains(h) {
                return v(.por, .route, .high, "\(before.last { stem($0, routeStems, except: routeExcept) }!) por: the route or area it passes through.")
            }
            let destination = before.suffix(3).contains { stem($0, destinationStems) || form($0, ir) }
            if destination, placeNouns.contains(h) || headCapitalised {
                return v(.para, .place, .medium, "\(before.last { stem($0, destinationStems) || form($0, ir) }!) para + a place: the Place it's headed.", "Por would mean through or around it.")
            }
            if let p = prevPlain, ["vuelo", "vuelos", "tren", "camion", "autobus", "bus", "boleto", "boletos", "pasaje", "billete", "carretera", "rumbo", "salida", "direccion", "camino"].contains(p) { return v(.para, .place, .high, "\(p) para + a place: the Place it's headed.") }
            return nil
        }

        // 7. Time: deadlines and lengths
        func timeAndDeadline() -> Verdict? {
            guard let h = head else { return nil }
            if pointsInTime.contains(h) || ["hoy", "manana", "ayer"].contains(nextPlain ?? "") {
                if ["examen", "reunion", "cena", "comida", "desayuno", "fiesta", "boda", "verano", "invierno", "otono", "primavera", "vacaciones"].contains(h) && !before.contains(where: { form($0, ["es", "son", "listo", "lista", "necesito", "tengo", "tienes", "termina", "terminar", "entregar"]) }) { return nil }
                if h == "semana" && !(at(i + 1).map { ["la", "el", "esta", "fin"].contains(plain($0)) } ?? false) { return nil }
                return v(.para, .pointInTime, .high, "Para \(next!) \(next == h ? "" : h): the Point in time it's due.")
            }
            if timeUnits.contains(h), let n = nextPlain, ["un", "una", "unos", "unas", "mucho", "mucha", "muchos", "muchas", "todo", "toda", "varios", "varias", "algun", "algunos", "poco", "pocos", "largo"].contains(n) || ["anos", "meses", "dias", "semanas", "horas", "minutos", "siglos"].contains(h) {
                return v(.por, .time, .medium, "Por + a length of time: the time it fills.", "A booking or plan for a period takes para.")
            }
            return nil
        }

        // 8. Perspective: para mí, es fácil; para ser tan joven; para su edad
        func perspective() -> Verdict? {
            guard let n = nextPlain else { return nil }
            let pronoun = ["mí", "ti", "él", "ella", "usted", "nosotros", "ellos", "ellas", "ustedes", "muchos", "muchas", "algunos"].contains(next ?? "") || (next == "mi" && isPronounUse(i + 1))
            if pronoun, atStart || i == 0, text.contains(",") || (next2.map { ["es", "era", "no", "la", "el", "lo", "que"].contains($0) } ?? false) {
                return v(.para, .perspective, .medium, "Para \(next!), …: the Perspective it's judged from, in \(next!)'s view.", "Por \(next!), … at the start means \"as far as I'm concerned\" (I don't mind).")
            }
            if (pronoun || isPerson), stem(prev, ["dificil", "facil", "importante", "imposible", "posible", "bueno", "buena", "malo", "mala", "mejor", "peor", "suficiente", "demasiad", "util", "necesari", "normal", "raro", "extran", "nuevo", "nueva", "fundamental", "esencial", "complicad", "duro", "dura", "comod", "interesante", "aburrid", "agradable", "fuerte", "caro", "cara", "barato", "lejos", "cerca", "tarde", "temprano", "pronto", "popular", "peligro", "amenaza", "obvio", "claro", "evidente", "triste", "divertid", "emocionante", "urgente", "ideal", "perfect", "suficiente", "grave", "serio", "importa"]) {
                return v(.para, .perspective, .high, "\(prev!) para \(next!): the Perspective it's judged from.")
            }
            if n == "ser" || (head.map { ["edad", "epoca", "tamano", "estatura"].contains($0) } ?? false) { return v(.para, .perspective, .high, "Para \(next!) …: considering, the Perspective it's judged from.") }
            return nil
        }

        // 9. People: someone you do it for, or the person who gets it
        func people() -> Verdict? {
            guard isPerson else { return nil }
            let n = next!
            if next2.map({ ["mismo", "misma", "mismos", "solo", "sola"].contains(plain($0)) }) ?? false, n == "sí" || before.contains(where: { stem($0, ["habl", "decid", "hac", "hag", "pens", "jug", "contest", "respond"]) }) { return v(.por, .forSomeone, .high, "Por \(n) mismo: on one's own behalf.") }
            if before.contains(where: { stem($0, ["hac", "hag", "hic", "hiz", "encarg", "habl", "decid", "firm", "vot", "intercedi", "sacrific", "arriesg", "cubr", "suplant", "sustitu", "reemplaz", "esper", "rez", "or", "luch", "pele", "muer", "mori", "preocup", "sient", "senti", "siento", "lo siento", "brind", "pase", "pasa", "tom", "segui", "sigu", "qued", "aguant", "sufr", "llor"]) && !stem($0, ["ora", "orden", "tom"]) && plain($0) != "tom" }) || ["abrazo", "beso", "saludo", "saludos", "besos", "abrazos"].contains(where: { before.contains($0) }) && before.contains("a") {
                return v(.por, .forSomeone, .medium, "Done for someone (\(n)), on their behalf or for their sake: por.", "If they end up getting a thing (es para ti), it's para.")
            }
            if before.contains(where: { form($0, ["es", "son", "era", "eran", "sera", "fue", "esta", "estan"]) }) || before.contains(where: { stem($0, ["regal", "compr", "traj", "hic", "hice", "cocin", "prepar", "guard", "escrib", "mand", "envi", "llev", "deje", "tengo", "tiene", "hay", "pregunta", "mensaje", "carta", "noticia", "sorpresa", "flores", "pastel", "libro"]) }) {
                return v(.para, .person, .medium, "Para \(n): the Person who gets it.", "If it's done on their behalf or for their sake (lo hice por ti), it's por.")
            }
            return v(.para, .person, .low, "Para \(n): the Person who gets it.", "If it's done on their behalf or for their sake (lo hice por ti), it's por. Ask: do they end up with it?")
        }

        // 10. What it's for: a thing, a use, a reason or ability noun before
        func whatItsFor() -> Verdict? {
            if before.suffix(3).contains(where: { stem($0, suitedStems) }) {
                return v(.para, .purpose, .medium, "\(before.last { stem($0, suitedStems) }!) para …: what it's for, the Purpose.", "If it's what caused it, it's por.")
            }
            if before.contains(where: { form($0, ["es", "son", "era", "eran", "sera", "seran", "fue", "fueron", "esta", "estan"]) }), head != nil {
                return v(.para, .purpose, .medium, "Is para …: what it's for, or who it's for.", "Es por … would give the reason instead (es por tu bien).")
            }
            if let h = head, purposeHeads.contains(h) {
                return v(.para, .purpose, .medium, "Para \(h): what it's for, the Purpose.", "If it's what caused it, it's por.")
            }
            if let p = prev, head != nil, !p.isEmpty, !looksLikeVerb(p) {
                return v(.para, .purpose, .low, "\(p) para …: a thing and what it's for, the Purpose.", "If it's what caused it, or what it's traded for, it's por.")
            }
            return nil
        }

        func looksLikeVerb(_ word: String) -> Bool {
            let s = plain(word)
            let nouns: Set<String> = ["casa", "cosa", "mesa", "caja", "taza", "vaso", "regalo", "libro", "carta", "comida", "agua", "medicina", "pastilla", "dinero", "ropa", "tiempo", "plan", "idea", "cuarto", "lugar", "sitio", "espacio", "algo", "nada", "todo", "pregunta", "mensaje", "noticia", "sorpresa", "flores", "pastel", "herramienta", "maquina", "producto", "cuenco", "plato", "olla", "bolsa", "papel", "corbata", "traje", "vestido", "hielo", "manzanas", "uvas", "aportes", "cancion", "canciones", "cuentos", "chips", "comida", "boleto", "boletos", "billete", "vuelo", "camion", "tren", "autobus", "destino", "amenaza", "peligro", "receta", "remedio", "crema", "pomada"]
            if nouns.contains(s) { return false }
            return ["o", "a", "e", "as", "es", "an", "en", "amos", "emos", "imos", "aba", "ia", "io", "ieron", "aron", "ado", "ido", "ar", "er", "ir", "on", "ste"].contains { s.hasSuffix($0) }
        }
    }
}
