import Foundation

/// Spain's words → what Mexico says, for putting Apple's translations (which come out in Spain's Spanish) into Mexican wording.
/// From the vocabulary research checked against the Diccionario del Español de México (docs/research/reports/
/// Mexican vs Spain Spanish vocabulary.md). Words Spain and Mexico share (coche aside, autobús, despacho, chisme...) are
/// left out, and so are words that only differ in one sense (piso, billete, pendiente, tomate...), since a swap would be
/// wrong half the time. Nouns come with every article so "el ordenador" turns into "la computadora"; verbs come in every form.
enum MexicoWords {
    /// Every swap, longest first so a phrase is swapped before a word inside it.
    static let pairs: [(String, String)] = {
        var seen = Set<String>()
        var all: [(String, String)] = []
        for pair in echarDeMenos + phrases + nounPairs + verbPairs where pair.0 != pair.1 && seen.insert(pair.0).inserted { all.append(pair) }
        return all.enumerated().sorted { $0.element.0.count != $1.element.0.count ? $0.element.0.count > $1.element.0.count : $0.offset < $1.offset }.map(\.element)
    }()

    /// A Spain word's dictionary headword → what Mexico says instead: "zumo" → "el jugo", "coger" → "agarrar; tomar (a bus...)".
    /// The word page shows it, and search puts the Mexican word ahead of Spain's.
    static let insteadOf: [String: String] = {
        var map: [String: String] = [:]
        let the = ["m": "el", "f": "la", "mp": "los", "fp": "las"]
        for line in nounTable.split(separator: "\n") {
            let fields = line.trimmingCharacters(in: .whitespaces).split(separator: "|").map(String.init)
            guard fields.count >= 4, let article = the[fields[3]], map[fields[0]] == nil else { continue }
            // Words that are also adjectives or verb forms (portátil, intermitente) only change as the noun
            map[fields[0]] = (fields.count > 4 ? "as a noun: " : "") + "\(article) \(fields[2])"
        }
        let verbs: [(String, String)] = [
            ("coger", "agarrar; for a bus, train or taxi: tomar (coger is sexual in Mexico)"),
            ("conducir", "manejar"), ("alquilar", "rentar"), ("charlar", "platicar"), ("chequear", "checar"),
            ("aparcar", "estacionar"), ("currar", "trabajar"), ("encender", "prender"), ("enfadar", "enojar"),
            ("enfadarse", "enojarse"), ("cabrear", "enojar"), ("cabrearse", "enojarse"), ("afeitar", "rasurar"),
            ("afeitarse", "rasurarse"), ("atar", "amarrar"), ("estropear", "descomponerse (when it breaks down)"),
            ("estropearse", "descomponerse"), ("averiar", "descomponerse"), ("averiarse", "descomponerse"),
            ("atascar", "atorar"), ("atascarse", "atorarse"), ("pinchar", "for a flat tire: ponchar (se me ponchó una llanta)"),
            ("suspender", "for failing an exam or class: reprobar"), ("tirar", "for pulling: jalar (tira de la puerta → jala la puerta)"),
            ("molar", "gustar (me mola → me gusta)"), ("guay", "chido, padre (qué guay → qué padre)"),
        ]
        for (es, mx) in verbs { map[es] = mx }
        return map
    }()

    /// Spain's "echar de menos": Mexico (and Colombia) say "extrañar". "te echo de menos" → "te extraño".
    static let echarDeMenos: [(String, String)] =
        verbForms("echar", "extrañar", esTail: " mucho de menos", mxTail: " mucho") + verbForms("echar", "extrañar", esTail: " de menos", mxTail: "")

    // MARK: Phrases

    private static let phrases: [(String, String)] = [
        ("qué guay", "qué padre"), ("muy guay", "muy padre"), ("guay", "chido"),
        ("me mola", "me gusta"), ("te mola", "te gusta"), ("le mola", "le gusta"), ("nos mola", "nos gusta"), ("les mola", "les gusta"),
        ("me molan", "me gustan"), ("te molan", "te gustan"), ("le molan", "le gustan"), ("nos molan", "nos gustan"), ("les molan", "les gustan"),
        ("mola mucho", "está padrísimo"), ("es la leche", "está padrísimo"),
        ("me importa un pimiento", "me vale"), ("te importa un pimiento", "te vale"), ("le importa un pimiento", "le vale"),
        ("nos importa un pimiento", "nos vale"), ("les importa un pimiento", "les vale"),
        ("uña y carne", "uña y mugre"), ("al loro", "pendiente"),
        ("hacer cola", "hacer fila"), ("hago cola", "hago fila"), ("hacemos cola", "hacemos fila"), ("hacen cola", "hacen fila"), ("hice cola", "hice fila"),
        ("hicimos cola", "hicimos fila"), ("haciendo cola", "haciendo fila"), ("la cola del", "la fila del"), ("la cola para", "la fila para"),
        ("mando a distancia", "control remoto"), ("el mando de la tele", "el control de la tele"),
        ("zapatillas de deporte", "tenis"), ("zapatillas deportivas", "tenis"), ("pantalones vaqueros", "jeans"),
        ("unos vaqueros", "unos jeans"), ("mis vaqueros", "mis jeans"), ("tus vaqueros", "tus jeans"), ("sus vaqueros", "sus jeans"),
        ("tirar de la cadena", "jalarle al baño"), ("tira de la cadena", "jálale al baño"),
        ("carné de conducir", "licencia de manejo"), ("carnet de conducir", "licencia de manejo"), ("permiso de conducir", "licencia de manejo"),
        ("carné de identidad", "credencial"), ("baja médica", "incapacidad"), ("en el paro", "sin trabajo"),
        ("maquinilla de afeitar", "rastrillo"), ("cubo de la basura", "bote de basura"), ("cubo de basura", "bote de basura"),
        ("darse prisa", "apurarse"), ("darte prisa", "apurarte"), ("darme prisa", "apurarme"), ("darnos prisa", "apurarnos"),
        ("date prisa", "apúrate"), ("dese prisa", "apúrese"), ("dése prisa", "apúrese"), ("daos prisa", "apúrense"), ("dense prisa", "apúrense"),
        ("démonos prisa", "apurémonos"), ("dándome prisa", "apurándome"), ("dándote prisa", "apurándote"), ("dándose prisa", "apurándose"),
    ]

    // MARK: Nouns

    /// "spain|gender|mexico|gender[|articled]". Gender is m, f, mp or fp (only used in the plural). "articled" swaps the word
    /// only after an article, for words that are also adjectives or verb forms (portátil, intermitente, batido).
    private static let nounTable = """
    zumo|m|jugo|m
    patata|f|papa|f
    melocotón|m|durazno|m
    albaricoque|m|chabacano|m
    cacahuete|m|cacahuate|m
    guisante|m|chícharo|m
    judía verde|f|ejote|m
    judía|f|frijol|m|articled
    calabacín|m|calabacita|f
    remolacha|f|betabel|m
    boniato|m|camote|m
    batata|f|camote|m
    pomelo|m|toronja|f
    anacardo|m|nuez de la India|f
    tarta|f|pastel|m
    nata|f|crema|f
    carne picada|f|carne molida|f
    beicon|m|tocino|m
    bacon|m|tocino|m
    bocadillo|m|torta|f
    panecillo|m|bolillo|m
    pan de molde|m|pan de caja|m
    pajita|f|popote|m
    batido|m|malteada|f|articled
    golosina|f|dulce|m
    aperitivo|m|botana|f
    chupito|m|caballito|m
    frigorífico|m|refrigerador|m
    nevera|f|refrigerador|m
    grifo|m|llave|f
    bombilla|f|foco|m
    dormitorio|m|recámara|f
    armario|m|clóset|m
    moqueta|f|alfombra|f
    percha|f|gancho|m
    telefonillo|m|interfón|m
    ascensor|m|elevador|m
    fregona|f|trapeador|m
    estropajo|m|fibra|f
    interruptor|m|apagador|m
    fontanero|m|plomero|m
    fontanera|f|plomera|f
    cerilla|f|cerillo|m
    mechero|m|encendedor|m
    lavavajillas|m|lavaplatos|m
    manta|f|cobija|f
    trastero|m|bodega|f
    autocar|m|autobús|m
    maletero|m|cajuela|f
    capó|m|cofre|m
    parachoques|m|defensa|f|articled
    neumático|m|llanta|f
    pinchazo|m|ponchadura|f
    aparcamiento|m|estacionamiento|m
    parking|m|estacionamiento|m
    atasco|m|tráfico|m
    furgoneta|f|camioneta|f
    rotonda|f|glorieta|f
    acera|f|banqueta|f
    intermitente|m|direccional|f|articled
    salpicadero|m|tablero|m
    embrague|m|clutch|m
    gasóleo|m|diesel|m
    alquiler|m|renta|f
    carril bici|m|ciclovía|f
    camiseta|f|playera|f
    chaqueta|f|chamarra|f
    cazadora|f|chamarra|f
    jersey|m|suéter|m
    chándal|m|pants|mp
    bragas|fp|calzones|mp
    sujetador|m|brasier|m
    cremallera|f|cierre|m
    bolso|m|bolsa|f
    pijama|m|pijama|f|articled
    chubasquero|m|impermeable|m
    pintalabios|m|lápiz labial|m
    peto|m|overol|m
    ordenador|m|computadora|f
    portátil|m|laptop|f|articled
    móvil|m|celular|m
    bolígrafo|m|pluma|f
    boli|m|pluma|f
    rotulador|m|plumón|m
    típex|m|corrector|m
    grapadora|f|engrapadora|f
    folio|m|hoja|f
    archivador|m|archivero|m
    auriculares|mp|audífonos|mp
    altavoz|m|bocina|f
    vídeo|m|video|m
    calderilla|f|cambio|m
    mercadillo|m|tianguis|m
    chollo|m|ganga|f
    hucha|f|alcancía|f
    escaparate|m|aparador|m
    pizarra|f|pizarrón|m
    tiza|f|gis|m
    camarero|m|mesero|m
    camarera|f|mesera|f
    moflete|m|cachete|m
    mariquita|f|catarina|f|articled
    piscina|f|alberca|f
    polideportivo|m|deportivo|m|articled
    césped|m|pasto|m
    váter|m|inodoro|m
    aseos|mp|baños|mp
    ducha|f|regadera|f
    bañera|f|tina|f
    albornoz|m|bata de baño|f
    compresa|f|toalla sanitaria|f
    tirita|f|curita|f
    chupete|m|chupón|m
    biberón|m|mamila|f
    papelera|f|bote de basura|m
    cometa|f|papalote|m|articled
    tobogán|m|resbaladilla|f
    coche|m|carro|m
    gafas|fp|lentes|mp
    chaval|m|muchacho|m
    chavala|f|muchacha|f
    resaca|f|cruda|f
    pijo|m|fresa|m
    pija|f|fresa|f
    """

    /// Articles in the same order for each gender and number, contractions first so "de la" is swapped before "la".
    private static let articles: [String: [String]] = [
        "m": ["del", "al", "el", "un", "este", "ese", "aquel", "nuestro", "vuestro"],
        "f": ["de la", "a la", "la", "una", "esta", "esa", "aquella", "nuestra", "vuestra"],
        "mp": ["de los", "a los", "los", "unos", "estos", "esos", "aquellos", "nuestros", "vuestros"],
        "fp": ["de las", "a las", "las", "unas", "estas", "esas", "aquellas", "nuestras", "vuestras"],
    ]

    private static let nounPairs: [(String, String)] = {
        var result: [(String, String)] = []
        for line in nounTable.split(separator: "\n") {
            let fields = line.trimmingCharacters(in: .whitespaces).split(separator: "|").map(String.init)
            guard fields.count >= 4 else { continue }
            let (es, esGender, mx, mxGender) = (fields[0], fields[1], fields[2], fields[3])
            let articled = fields.count > 4 && fields[4] == "articled"
            // Each number the Spain word comes in, and what it becomes: a plural-only word on either side stays plural
            var forms: [(es: String, esKey: String, mx: String, mxKey: String)] = []
            let esOnlyPlural = esGender.hasSuffix("p"), mxOnlyPlural = mxGender.hasSuffix("p")
            let esBase = String(esGender.prefix(1)), mxBase = String(mxGender.prefix(1))
            if !esOnlyPlural { forms.append((es, esBase, mx, mxOnlyPlural ? mxBase + "p" : mxBase)) }
            forms.append((esOnlyPlural ? es : plural(of: es), esBase + "p", mxOnlyPlural ? mx : plural(of: mx), mxBase + "p"))
            for form in forms {
                if form.esKey != form.mxKey || articled, let from = articles[form.esKey], let to = articles[form.mxKey] {
                    for (a, b) in zip(from, to) { result.append(("\(a) \(form.es)", "\(b) \(form.mx)")) }
                }
                if !articled { result.append((form.es, form.mx)) }
            }
        }
        return result
    }()

    /// Plural of a noun or noun phrase: the words before "de"/"para" change ("judía verde" → "judías verdes", "pan de molde" → "panes de molde").
    static func plural(of phrase: String) -> String {
        var words = phrase.split(separator: " ").map(String.init)
        for index in words.indices {
            if ["de", "para", "con", "a"].contains(words[index]) { break }
            words[index] = pluralWord(words[index])
        }
        return words.joined(separator: " ")
    }

    private static func pluralWord(_ word: String) -> String {
        guard let last = word.last else { return word }
        let accented: [Character: Character] = ["á": "a", "é": "e", "í": "i", "ó": "o", "ú": "u"]
        if "aeiouáéó".contains(last) { return word + "s" }
        if last == "z" { return String(word.dropLast()) + "ces" }
        // An accent on the last syllable goes away when a syllable is added: camión → camiones, interfón → interfones
        if "nsl".contains(last), word.count >= 2, let vowel = word.dropLast().last, let plain = accented[vowel] {
            return String(word.dropLast(2)) + String(plain) + String(last) + "es"
        }
        // Unstressed -s or -x doesn't change: lavavajillas, tianguis, típex
        if last == "s" || last == "x" { return word }
        // Spanish endings take -es (ascensor → ascensores); borrowed ones take -s (clóset → clósets, parking → parkings)
        return word + ("dlrnjy".contains(last) || word.hasSuffix("ch") ? "es" : "s")
    }

    // MARK: Verbs

    private static let clitics = ["me", "te", "se", "nos", "os"]

    private static let verbPairs: [(String, String)] = {
        var result: [(String, String)] = []
        // Taking transport is "tomar"; everything else "coger" means is "agarrar" (coger is sexual in Mexico)
        for object in ["el autobús", "un autobús", "el tren", "un tren", "el metro", "un taxi", "el taxi", "el avión", "un avión", "el camión", "el ferry", "el barco"] {
            result += verbForms("coger", "tomar", esTail: " " + object, mxTail: " " + object)
        }
        result += verbForms("coger", "agarrar")
        result += verbForms("conducir", "manejar", skipPersons: [2, 5])  // "conduce a" also means "leads to"
        result += verbForms("alquilar", "rentar")
        result += verbForms("charlar", "platicar")
        result += verbForms("chequear", "checar")
        result += verbForms("aparcar", "estacionar")
        result += verbForms("currar", "trabajar")
        result += verbForms("encender", "prender")
        result += verbForms("enfadar", "enojar")
        result += verbForms("cabrear", "enojar")
        result += verbForms("afeitar", "rasurar")
        result += verbForms("atar", "amarrar")
        result += verbForms("aguantar", "aguantar", esTail: " mecha", mxTail: " vara")
        // Not "una tira de papel"
        result += verbForms("tirar", "jalar", esTail: " del", mxTail: " el", keepWords: false)
        result += verbForms("tirar", "jalar", esTail: " de", mxTail: "", keepWords: false)
        for exam in [" el examen", " un examen", " los exámenes", " el curso", " la asignatura"] {
            result += verbForms("suspender", "reprobar", esTail: exam, mxTail: exam)
        }
        // These only change when the thing breaks down or gets stuck by itself: "se estropeó el coche", "se me atascó"
        result += verbForms("estropear", "descomponer", before: ["se"])
        result += verbForms("averiar", "descomponer", before: ["se"])
        result += verbForms("atascar", "atorar", before: clitics)
        result += verbForms("pinchar", "ponchar", before: ["se", "me", "te", "le", "nos", "les"], onlyPersons: [2, 5])
        result += verbForms("hacer", "lastimar", esTail: " daño", mxTail: "", before: clitics + ["le", "les"])
        for state in [" enfermo", " enferma", " enfermos", " enfermas"] {
            result += verbForms("poner", "enfermar", esTail: state, mxTail: "", before: clitics)
        }
        result += verbForms("dar", "apurar", esTail: " prisa", mxTail: "", before: clitics)
        return result
    }()

    /// Every form of one verb paired with the same form of the other: tenses, participles (and their -a/-os/-as), gerund, and
    /// the infinitive with a pronoun attached. `before` keeps only the forms that follow one of those words ("se estropeó");
    /// a bare form that is also an ordinary word (cojo, charla, enfado) is left alone.
    static func verbForms(_ es: String, _ mx: String, esTail: String = "", mxTail: String = "", before: [String] = [],
                          skipPersons: Set<Int> = [], onlyPersons: Set<Int>? = nil, keepWords: Bool? = nil) -> [(String, String)] {
        guard let a = Conjugator.conjugate(es), let b = Conjugator.conjugate(mx) else { return [] }
        var pairs: [(String, String)] = []
        // A skipped person's form stays skipped where it shows up again (the tú command "conduce" is the él form)
        let skipped = Set(Tense.allCases.flatMap { tense in skipPersons.compactMap { a.form(tense, $0) } })
        for tense in Tense.allCases {
            for person in 0..<6 where !skipPersons.contains(person) && (onlyPersons?.contains(person) ?? true) {
                guard let x = a.form(tense, person), let y = b.form(tense, person), !x.contains(" "), !skipped.contains(x) else { continue }
                pairs.append((x, y))
            }
        }
        if onlyPersons == nil {
            pairs.append((a.gerund, b.gerund))
            pairs.append((a.participle, b.participle))
            if a.participle.hasSuffix("o"), b.participle.hasSuffix("o") {
                for ending in ["a", "os", "as"] { pairs.append((String(a.participle.dropLast()) + ending, String(b.participle.dropLast()) + ending)) }
            }
            pairs.append((es, mx))
            for pronoun in ["me", "te", "se", "lo", "la", "le", "nos", "los", "las", "les"] { pairs.append((es + pronoun, mx + pronoun)) }
        }
        let words = Lexicon.shared.wordsByID
        var result: [(String, String)] = []
        for (x, y) in pairs {
            if before.isEmpty {
                if !(keepWords ?? !esTail.isEmpty), let word = words[x], word.partOfSpeech != .infinitive { continue }
                result.append((x + esTail, y + mxTail))
            } else {
                for word in before { result.append(("\(word) \(x)\(esTail)", "\(word) \(y)\(mxTail)")) }
            }
        }
        return result
    }
}
