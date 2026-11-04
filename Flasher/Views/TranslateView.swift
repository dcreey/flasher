import SwiftUI
import Translation

/// Things that are easy to say wrong, or that a translator gets wrong, because the obvious word means something else.
/// Each trap is shown as a heads-up when the English or the Spanish in the translation matches; the text is never changed.
enum TranslationTraps {
    struct Trap: Identifiable {
        let id: String
        /// Matches the English side ("I am hot").
        let english: String?
        /// Matches the Spanish side ("estoy caliente").
        let spanish: String?
        let message: String
        /// Rewrites the Spanish translation when the English clearly means the intended thing, so the wrong form never shows.
        var fix: ((String) -> String)?
        /// Shown instead of `message` when the Spanish was typed in (Spanish → English).
        var typedMessage: String?
        /// Corrects Apple's English when the Spanish typed in has a hidden meaning ("I'm hot" → "I'm aroused").
        var englishFix: ((String) -> String)?
        /// Only shown when the target country is one of these (nil: every country).
        var countries: Set<Country>?

        func matchesSpanish(_ text: String) -> Bool {
            guard let spanish else { return false }
            return text.lowercased().range(of: spanish, options: .regularExpression) != nil
        }
    }

    // "I'm", "we are", "I feel", "I was getting": a first-person subject with its verb
    private static let me = #"\b(?:i|we)(?:'m|'re|\s*m\b|\s+am|\s+are|\s+was|\s+were|\s+feel|\s+felt|\s+feeling|\s+get|\s+getting|\s+got)"#
    // The same for anyone: "he's", "you are", "they were"
    private static let anyone = #"\b(?:i|we|you|he|she|they|everyone|everybody|people|kids|children|the kids|the children|the baby|my (?:son|daughter|kids|wife|husband|mom|dad|friend|baby))(?:'m|'re|'s|\s*m\b|\s+am|\s+are|\s+is|\s+was|\s+were|\s+feel|\s+feels|\s+felt|\s+feeling|\s+get|\s+gets|\s+getting|\s+got|\s+looks|\s+seems)"#
    // Up to two filler words in between: "very", "so", "really", "a little bit"
    private static let gap = #"\s+(?:\w+\s+){0,3}"#
    // Spanish: "estoy", "ando", "me siento", with up to two filler words after
    private static let esMe = #"\b(?:estoy|estamos|ando|andamos|me siento|nos sentimos)\s+(?:\p{L}+\s+){0,2}"#
    private static let esEstar = #"\b(?:estoy|estás|está|estamos|están|ando|anda|me siento|se siente)\s+(?:\p{L}+\s+){0,2}"#
    private static let esSer = #"\b(?:soy|eres|es|somos|son)\s+(?:\p{L}+\s+){0,2}"#
    private static let numbers = #"(?:\d+|(?:eleven|twelve|thirteen|fourteen|fifteen|sixteen|seventeen|eighteen|nineteen|twenty|thirty|forty|fifty|sixty|seventy|eighty|ninety)(?:[- ](?:one|two|three|four|five|six|seven|eight|nine))?)"#
    private static let esNumbers = #"(?:\d+|once|doce|trece|catorce|quince|dieciséis|diecisiete|dieciocho|diecinueve|veinte|veinti\p{L}*|treinta|cuarenta|cincuenta|sesenta|setenta|ochenta|noventa)(?:\s+y\s+\p{L}+)?"#

    /// "estoy muy caliente" → "tengo mucho calor": a feeling said with *estar* + adjective becomes *tener* + noun.
    private static func tener(_ adjectives: String, _ noun: String, feminine: Bool = false) -> (String) -> String {
        { spanish in
            let pattern = #"(?<![\p{L}])(estoy|estamos)( muy| tan| demasiado| bastante| un poco)?\s+(?:"# + adjectives + #")s?(?![\p{L}])"#
            guard let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) else { return spanish }
            var result = spanish
            for match in regex.matches(in: spanish, range: NSRange(spanish.startIndex..., in: spanish)).reversed() {
                guard let whole = Range(match.range, in: result), let verb = Range(match.range(at: 1), in: result) else { continue }
                let have = result[verb].lowercased() == "estoy" ? "tengo" : "tenemos"
                var amount = Range(match.range(at: 2), in: result).map { String(result[$0]).trimmingCharacters(in: .whitespaces).lowercased() } ?? ""
                let many = feminine ? ["muy": "mucha", "tan": "tanta", "demasiado": "demasiada"] : ["muy": "mucho", "tan": "tanto", "demasiado": "demasiado"]
                amount = many[amount] ?? (amount == "un poco" ? "un poco de" : amount)
                let replacement = ([have] + (amount.isEmpty ? [] : [amount]) + [noun]).joined(separator: " ")
                result.replaceSubrange(whole, with: CountryTranslation.matchingCapital(of: String(result[whole]), in: replacement))
            }
            return result
        }
    }

    /// Replaces one wrong form with the right one, keeping a leading capital.
    private static func swap(_ pattern: String, _ replacement: String) -> (String) -> String {
        { spanish in
            guard let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) else { return spanish }
            var result = spanish
            for match in regex.matches(in: spanish, range: NSRange(spanish.startIndex..., in: spanish)).reversed() {
                guard let range = Range(match.range, in: result) else { continue }
                var text = replacement
                for group in 1..<max(match.numberOfRanges, 1) {
                    let captured = Range(match.range(at: group), in: result).map { String(result[$0]) } ?? ""
                    text = text.replacingOccurrences(of: "$\(group)", with: captured)
                }
                result.replaceSubrange(range, with: CountryTranslation.matchingCapital(of: String(result[range]), in: text))
            }
            return result
        }
    }

    /// Fixes the Spanish when the English says clearly what was meant ("I am hot" → "Tengo calor").
    static func fixing(_ spanish: String, english: String) -> String {
        let en = english.lowercased().replacingOccurrences(of: "’", with: "'")
        var result = spanish
        for trap in all {
            guard let fix = trap.fix, let pattern = trap.english, en.range(of: pattern, options: .regularExpression) != nil else { continue }
            result = fix(result)
        }
        return result
    }

    /// Fixes Apple's English when the Spanish typed in says something other than it looks ("estoy caliente" is not "I'm hot").
    static func fixingEnglish(_ english: String, spanish: String) -> String {
        var result = english
        for trap in all {
            guard let fix = trap.englishFix, trap.matchesSpanish(spanish) else { continue }
            result = fix(result)
        }
        return result
    }

    static let all: [Trap] = [
        Trap(id: "hot", english: #"\#(me)\#(gap)(?:hot|warm|boiling|overheated|burning up)\b"#, spanish: #"\#(esMe)calientes?\b"#,
             message: "A common mistake is to say **“estoy caliente,”** which actually means you're sexually aroused. To say you feel hot, it's **“tengo calor.”**", fix: tener("caliente|cálid[oa]|acalorad[oa]", "calor"), typedMessage: "“Estoy caliente” actually means you're sexually aroused, not that you feel hot. To say you feel hot, it's **“tengo calor.”**", englishFix: swap(#"\b(i am|i'm|im|we are|we're)(\s+(?:very|so|really|too|extremely|a little|a bit))?\s+(?:hot|warm)\b"#, "$1$2 aroused")),
        Trap(id: "hotPerson", english: #"\b(?:he|she|they|you)(?:'s|'re|\s+is|\s+are|\s+looks|\s+look)\#(gap)hot\b"#, spanish: #"\b(?:él|ella|ellos|ellas|tú|usted)\s+(?:está|estás|están|es|eres)\s+(?:\p{L}+\s+)?calientes?\b"#,
             message: "A common mistake is calling a person **“caliente,”** which actually means aroused. For attractive say **“guapo/guapa”**; for feeling hot, **“tiene calor.”**"),
        Trap(id: "cold", english: #"\#(anyone)\#(gap)(?:cold|chilly|freezing|frozen)\b"#, spanish: #"\#(esMe)fr[ií][oa]s?\b"#,
             message: "A common mistake is to say **“estoy frío,”** which actually means you're cold-hearted. To say you feel cold, it's **“tengo frío.”**", fix: tener("fr[ií][oa]", "frío"), typedMessage: "“Estoy frío” actually means you're cold-hearted, not that you feel cold. To say you feel cold, it's **“tengo frío.”**", englishFix: swap(#"\b(i am|i'm|im|we are|we're)(\s+(?:very|so|really|too|extremely|a little|a bit))?\s+cold\b"#, "$1$2 cold-hearted")),
        Trap(id: "tener", english: #"\#(anyone)\#(gap)(?:hungry|starving|thirsty|scared|afraid|terrified|frightened)\b"#, spanish: #"\#(esEstar)(?:hambrient[oa]s?|sedient[oa]s?|asustad[oa]s?|aterrad[oa]s?)\b"#,
             message: "Hunger, thirst and fear use *tener*. A common mistake is **“estoy hambriento / asustado,”** which sounds stiff. Say **“tengo hambre / sed / miedo.”**", fix: tener("hambrient[oa]", "hambre", feminine: true)),
        Trap(id: "sleepy", english: #"\#(anyone)\#(gap)(?:sleepy|drowsy)\b"#, spanish: #"\#(esEstar)dormid[oa]s?\b"#,
             message: "A common mistake is to say **“estoy dormido,”** which actually means you're asleep. Sleepy is **“tengo sueño.”**", fix: tener("dormid[oa]", "sueño"), typedMessage: "“Estoy dormido” actually means you're asleep, not sleepy. Sleepy is **“tengo sueño.”**"),
        Trap(id: "right", english: #"\#(anyone)\#(gap)(?:right|correct)\b"#, spanish: #"\#(esEstar)correct[oa]s?\b|\#(esSer)correct[oa]s?\b"#,
             message: "To say someone is right, say **“Tiene razón.”**"),
        Trap(id: "age", english: #"\#(anyone)\s+(?:\#(numbers)\s+years?\s+old|\d+)\b"#, spanish: #"\b(?:soy|eres|somos|son|estoy|estás|estamos)\s+\#(esNumbers)\s+años\b|\bes\s+\#(esNumbers)\s+años\b"#,
             message: "A common mistake is **“soy 25 años”** or **“estoy 25 años.”** Age uses *tener*: **“tengo 25 años.”**", fix: swap(#"\b(?:soy|estoy)\s+(\d+\s+años)\b"#, "tengo $1")),
        Trap(id: "embarrassed", english: #"\bembarrass"#, spanish: #"\bembarazad[oa]s?\b"#,
             message: "A common mistake is to say **“embarazada,”** which actually means **pregnant**. Embarrassed is **“avergonzado/a,”** or *me da pena / vergüenza*.", fix: swap(#"\bembarazad([oa]s?)\b"#, "avergonzad$1"), typedMessage: "“Embarazada” means **pregnant**, not embarrassed. Embarrassed is **“avergonzado/a,”** or *me da pena / vergüenza*."),
        Trap(id: "excited", english: #"\bexcited\b|\bexcitement\b|\bexciting\b"#, spanish: #"\bexcitad[oa]s?\b|\bexcitante\b"#,
             message: "A common mistake is to say **“excitado,”** which is sexual. Excited is **“emocionado/a”** or **“entusiasmado/a.”**", fix: swap(#"\bexcitad([oa]s?)\b"#, "emocionad$1"), typedMessage: "“Excitado” is sexual, not just excited. Excited is **“emocionado/a”** or **“entusiasmado/a.”**", englishFix: swap(#"\bexcited\b"#, "aroused")),
        Trap(id: "constipated", english: #"\bconstipat"#, spanish: #"\bconstipad[oa]s?\b"#,
             message: "“Constipado” means you have a **cold** (in Spain). Constipated is **“estreñido/a.”**"),
        Trap(id: "preservative", english: #"\bpreservatives?\b"#, spanish: #"\bpreservativos?\b"#,
             message: "“Preservativo” means **condom**. A food preservative is **“conservante.”**"),
        Trap(id: "good", english: #"\#(anyone)\#(gap)(?:good|fine|well)\b"#, spanish: #"\#(esEstar)buen[oa]s?\b"#,
             message: "A common mistake is to say **“estoy bueno/a,”** which actually says you're attractive. To say you're fine, it's **“estoy bien.”**", fix: swap(#"\bestoy\s+buen[oa]\b"#, "estoy bien"), typedMessage: "“Estoy bueno/a” actually says you're attractive, not that you're fine. To say you're fine, it's **“estoy bien.”**", englishFix: swap(#"\b(i am|i'm|im)(\s+(?:very|so|really))?\s+(?:good|fine|well)\b"#, "$1$2 attractive")),
        Trap(id: "rich", english: #"\#(anyone)\#(gap)(?:rich|wealthy)\b"#, spanish: #"\#(esEstar)ric[oa]s?\b"#,
             message: "“Estoy rico/a” says you're sexy or tasty. Rich is **“Soy rico/a”** (or *tengo mucho dinero*).", typedMessage: "“Estoy rico/a” says you're sexy or tasty, not rich. Rich is **“soy rico/a”** (or *tengo mucho dinero*).", englishFix: swap(#"\b(i am|i'm|im)(\s+(?:very|so|really))?\s+(?:rich|wealthy)\b"#, "$1$2 sexy")),
        Trap(id: "bored", english: #"\#(anyone)\#(gap)bored\b"#, spanish: #"\#(esSer)aburrid[oa]s?\b"#,
             message: "A common mistake is **“soy aburrido,”** which actually means you're a boring person. Bored is **“estoy aburrido/a.”**", fix: swap(#"\bsoy(\s+(?:\p{L}+\s+)?aburrid[oa]s?)\b"#, "estoy$1"), typedMessage: "“Soy aburrido” means you're a boring person, not bored. Bored is **“estoy aburrido/a.”**"),
        Trap(id: "ready", english: #"\#(anyone)\#(gap)ready\b"#, spanish: #"\#(esSer)list[oa]s?\b"#,
             message: "A common mistake is **“soy listo,”** which actually means you're clever. Ready is **“estoy listo/a.”**", fix: swap(#"\bsoy(\s+list[oa]s?)\b"#, "estoy$1"), typedMessage: "“Soy listo” means you're clever, not ready. Ready is **“estoy listo/a.”**"),
        Trap(id: "sick", english: #"\#(anyone)\#(gap)(?:sick|ill|bad|unwell)\b"#, spanish: #"\#(esSer)(?:enferm[oa]s?|mal[oa]s?)\b"#,
             message: "“Soy malo / enfermo” describes your character or a lasting condition. Feeling bad or sick is **“Estoy mal / enfermo/a.”**"),
        Trap(id: "done", english: #"\#(anyone)\#(gap)(?:done|finished)\b"#, spanish: #"\#(esEstar)acabad[oa]s?\b"#,
             message: "A common mistake is to say **“estoy acabado,”** which actually means you're wrecked or ruined. Finished is **“ya terminé.”**", fix: swap(#"\bestoy\s+acabad[oa]\b"#, "ya terminé"), typedMessage: "“Estoy acabado” actually means you're wrecked or ruined, not just finished. Finished is **“ya terminé.”**", englishFix: swap(#"\b(i am|i'm|im)\s+(?:done|finished)\b"#, "$1 wrecked")),
        Trap(id: "coming", english: #"\b(?:i|we)(?:'m|'re|\s*m\b|\s+am|\s+are)\s+(?:\w+\s+)?(?:coming|cumming)\b"#, spanish: #"\bme vengo\b|\bme vine\b|\bnos venimos\b|\bme corrí\b"#,
             message: "A common mistake is to say **“me vengo,”** which is sexual. For “I'm coming,” it's **“ya voy.”**", fix: swap(#"\bme vengo\b"#, "ya voy"), typedMessage: "“Me vengo” is sexual, not “I'm coming.” For “I'm coming,” it's **“ya voy.”**", englishFix: swap(#"\b(i am|i'm|im)\s+(?:coming|cumming)\b|\bi come\b"#, "I climax")),
        Trap(id: "polla", english: nil, spanish: #"\bpollas?\b"#,
             message: "“Polla” is **vulgar** in Spain, but in Colombia it's a betting pool or lottery."),
        Trap(id: "paja", english: nil, spanish: #"\bpajas?\b"#,
             message: "“Paja” is straw, but also slang for **masturbation** in many countries. In Colombia it can mean a lie."),
        Trap(id: "library", english: #"\blibrar(?:y|ies)\b"#, spanish: #"\blibrerías?\b"#,
             message: "“Librería” is a **bookstore**. A library is **“biblioteca.”**"),
        Trap(id: "sensible", english: #"\bsensible\b"#, spanish: #"\bsensibles?\b"#,
             message: "“Sensible” means **sensitive**. Sensible is **“sensato/a”** or **“razonable.”**"),
        Trap(id: "actually", english: #"\bactually\b"#, spanish: #"\bactualmente\b"#,
             message: "“Actualmente” means **currently**. Actually is **“en realidad”** or **“de hecho.”**"),
        Trap(id: "assist", english: #"\bassist(?:ed|ing|s)?\b"#, spanish: #"\basist(?:ir|o|e|en|ió|ieron|imos|ía)\b"#,
             message: "“Asistir” means **to attend**. To assist is **“ayudar.”**"),
        Trap(id: "realize", english: #"\brealiz(?:e|ed|es|ing)\b"#, spanish: #"\brealiz(?:ar|o|a|an|ó|aron|amos)\b"#,
             message: "“Realizar” means **to carry out**. To realize (understand) is **“darse cuenta.”**"),
        Trap(id: "exit", english: #"\b(?:exit|way out)\b"#, spanish: #"\béxitos?\b"#,
             message: "“Éxito” means **success**. An exit is **“salida.”**"),
        Trap(id: "support", english: #"\bsupport(?:s|ed|ing)?\s+(?:him|her|them|me|us|you)\b"#, spanish: #"\bsoport(?:ar|o|a|an|aba|ó)\b|\bno soporto\b"#,
             message: "“Soportar” means **to put up with**. To support (back up) is **“apoyar.”**"),
        Trap(id: "record", english: #"\brecord(?:s|ed|ing)?\b"#, spanish: #"\brecord(?:ar|ó|é|ando|amos|aba)\b"#,
             message: "“Recordar” means **to remember**. To record is **“grabar.”**"),
        Trap(id: "lecture", english: #"\blectures?\b"#, spanish: #"\blecturas?\b"#,
             message: "“Lectura” means **reading**. A lecture is **“conferencia”** or **“clase.”**"),
        Trap(id: "carpet", english: #"\bcarpets?\b"#, spanish: #"\bcarpetas?\b"#,
             message: "“Carpeta” means **folder**. A carpet is **“alfombra.”**"),
        Trap(id: "parents", english: #"\bparents\b"#, spanish: #"\bparientes\b"#,
             message: "“Parientes” means **relatives**. Parents are **“padres.”**"),
        Trap(id: "cogerMX", english: #"\b(?:take|takes|took|taking|catch|catches|caught|grab|grabs|grabbed|get|gets|got)\s+(?:the|a|an|my|your|our)\s+(?:bus|train|taxi|cab|metro|subway|plane|flight|ball|keys?)\b"#, spanish: #"\b(?:cog(?:er|e|es|emos|en|ía|ías|ían|í|iste|ió|imos|ieron|iendo|ido)|coj(?:o|a|as|amos|an))(?:l[oa]s?|me|te|se|nos)?\b|\bcógel[oa]s?\b|\bcógeme\b"#,
             message: "In Mexico **“coger”** is vulgar for sex, not “to take.” Say **“tomar,” “agarrar”** or **“pillar.”**", countries: [.mexico]),
        Trap(id: "cogerCO", english: #"\b(?:take|takes|took|taking|catch|catches|caught|grab|grabs|grabbed|get|gets|got)\s+(?:the|a|an|my|your|our)\s+(?:bus|train|taxi|cab|metro|subway|plane|flight|ball|keys?)\b"#, spanish: #"\b(?:cog(?:er|e|es|emos|en|ía|ías|ían|í|iste|ió|imos|ieron|iendo|ido)|coj(?:o|a|as|amos|an))(?:l[oa]s?|me|te|se|nos)?\b|\bcógel[oa]s?\b|\bcógeme\b"#,
             message: "In Colombia **“coger”** mostly means “to take,” but it can be heard as sexual, and it is vulgar in nearby countries. **“Tomar”** or **“agarrar”** are safer.", countries: [.colombia]),
        Trap(id: "conchaMX", english: nil, spanish: #"\bconchas?\b"#,
             message: "In Mexico **“concha”** is a shell or a sweet bread. In Colombia and much of South America it is **vulgar slang**.", countries: [.mexico]),
        Trap(id: "conchaCO", english: nil, spanish: #"\bconchas?\b"#,
             message: "In Colombia **“concha”** is **vulgar slang** (and a shell in the dictionary sense). In Mexico it is also a sweet bread.", countries: [.colombia]),
        Trap(id: "chimba", english: nil, spanish: #"\bchimbas?\b"#,
             message: "In Colombia **“chimba”** is crude slang that can mean awesome (*qué chimba*) or worthless (*una chimba*), depending on the sentence. **“Bacano”** is the polite way to say cool.", countries: [.colombia]),
        Trap(id: "pedo", english: nil, spanish: #"\bpedos?\b"#,
             message: "In Mexico **“pedo”** means a fart, but also drunk (*estoy pedo*), a problem (*¿qué pedo?*, *no hay pedo*). It is informal and can be rude.", countries: [.mexico]),
        Trap(id: "chingar", english: nil, spanish: #"\bching(?:ar|o|a|an|ó|ada|adas|ado|ados|ón|ona|ones|onas|aquedito|ue|ues|aste)\b"#,
             message: "In Mexico the **“chingar”** family is the F-word: *chingón* can mean awesome, *chingar* to screw or mess up. Fine with close friends, offensive otherwise.", countries: [.mexico]),
        Trap(id: "verga", english: nil, spanish: #"\bvergas?\b"#,
             message: "**“Verga”** is vulgar for penis in Mexico (*a toda verga* means very fast). It is also a strong curse in Colombia (*qué verga*)."),
        Trap(id: "pinche", english: nil, spanish: #"\bpinches?\b"#,
             message: "In Mexico **“pinche”** is a rude intensifier meaning damn or lousy. In Spain it only means a kitchen helper.", countries: [.mexico]),
        Trap(id: "nomames", english: nil, spanish: #"\bno mames\b|\bmam[oó]n\b|\bmamadas?\b"#,
             message: "In Mexico **“no mames”** is the vulgar version of *no manches* (no way!). Fine with friends, rude otherwise.", countries: [.mexico]),
        Trap(id: "cabron", english: nil, spanish: #"\bcabr[oó]n(?:es|a|as)?\b"#,
             message: "In Mexico **“cabrón”** can be a friendly “dude,” an insult, or praise (*es un cabrón*), depending on tone. Avoid it with strangers.", countries: [.mexico]),
        Trap(id: "naco", english: nil, spanish: #"\bnac[oa]s?\b"#,
             message: "In Mexico **“naco”** is a classist insult for someone tacky or low-class.", countries: [.mexico]),
        Trap(id: "culo", english: nil, spanish: #"\bculos?\b"#,
             message: "In Mexico **“culo”** is more vulgar than in other countries, where it is a milder word for butt.", countries: [.mexico]),
        Trap(id: "aguas", english: nil, spanish: #"¡\s*aguas\b|\baguas con\b"#,
             message: "In Mexico **“¡Aguas!”** means “watch out!” and has nothing to do with water.", countries: [.mexico]),
        Trap(id: "ahorita", english: nil, spanish: #"\bahorita\b"#,
             message: "In Mexico **“ahorita”** can mean right now, in a bit, or never. Don't count on it being soon.", countries: [.mexico]),
        Trap(id: "peladoMX", english: nil, spanish: #"\bpelad[oa]s?\b"#,
             message: "In Mexico **“pelado”** can be an insult for a crude, low-class person. In Colombia it just means a young guy or kid.", countries: [.mexico]),
        Trap(id: "peladoCO", english: nil, spanish: #"\bpelad[oa]s?\b"#,
             message: "In Colombia **“pelado/a”** just means a young guy or kid. In Mexico it can be an insult for a crude person.", countries: [.colombia]),
        Trap(id: "maricaMX", english: nil, spanish: #"\bmaric(?:a|as|ón|ones)\b"#,
             message: "In Mexico **“marica”** is a homophobic slur. In Colombia friends use it as “dude.”", countries: [.mexico]),
        Trap(id: "maricaCO", english: nil, spanish: #"\bmaric(?:a|as|ón|ones)\b"#,
             message: "In Colombia **“marica”** is used among friends like “dude,” but it is also a slur and can offend. In Mexico it is only a slur.", countries: [.colombia]),
        Trap(id: "mamarCO", english: nil, spanish: #"\bmamar(?:\s+gallo)?\b|\bmamando\b"#,
             message: "In Colombia **“mamar gallo”** means to joke around or tease. On its own **“mamar”** is vulgar.", countries: [.colombia]),
        Trap(id: "tinto", english: nil, spanish: #"\btintos?\b"#,
             message: "In Colombia **“un tinto”** is a small black coffee. Red wine is **“vino tinto.”**", countries: [.colombia]),
        Trap(id: "gonorrea", english: nil, spanish: #"\bgonorreas?\b"#,
             message: "In Colombia **“gonorrea”** is a strong insult or exclamation (*qué gonorrea*), not just the illness. Very crude.", countries: [.colombia]),
        Trap(id: "berraco", english: nil, spanish: #"\bberrac[oa]s?\b"#,
             message: "In Colombia **“berraco/a”** can mean tough or impressive (*es muy berraco*), or very angry. Context decides.", countries: [.colombia]),
        Trap(id: "pola", english: nil, spanish: #"\bpolas?\b"#,
             message: "In Colombia **“una pola”** is a beer.", countries: [.colombia]),
        Trap(id: "vaina", english: nil, spanish: #"\bvainas?\b"#,
             message: "In Colombia **“vaina”** means thing or hassle (*qué vaina*). It is vulgar in some other countries.", countries: [.colombia]),
        Trap(id: "puto", english: nil, spanish: #"\bput[oa]s?\b"#,
             message: "**“Puto/a”** is a vulgar insult in most countries, including Mexico (a slur) and Colombia."),
        Trap(id: "pendejo", english: nil, spanish: #"\bpendej[oa]s?\b"#,
             message: "**“Pendejo/a”** is an insult for an idiot in Mexico; in Colombia it can also mean a naive kid. Offensive either way."),
    ]

    /// Apple turns a command or subjunctive into a plain statement ("te vaya" → "You go"). When the Spanish starts with a verb
    /// that can only be a command or subjunctive, and the English reads as a statement, point that out.
    static func moodNote(spanish: String, english: String) -> String? {
        let firstSentence = spanish.split(whereSeparator: { ".!?¡¿\n".contains($0) }).first.map(String.init) ?? spanish
        guard let regex = try? NSRegularExpression(pattern: "\\p{L}+") else { return nil }
        var words = regex.matches(in: firstSentence, range: NSRange(firstSentence.startIndex..., in: firstSentence))
            .compactMap { Range($0.range, in: firstSentence).map { String(firstSentence[$0]).lowercased() } }
        while let first = words.first, ["me", "te", "se", "nos", "os", "no"].contains(first) { words.removeFirst() }
        guard let verb = words.first, let slots = VerbForms.index[verb], !slots.isEmpty,
              slots.allSatisfy({ $0.tense == .subjunctivePresent || $0.tense == .imperative }),
              english.range(of: #"^\s*(?:you|he|she|they|we|i|it)\b"#, options: [.regularExpression, .caseInsensitive]) != nil else { return nil }
        return "**“\(verb)”** is a command or subjunctive form, so the English statement may be wrong. It could be an order (“Go to…!”) or a wish (“I want you to…”)."
    }

    /// The traps that apply to this English and Spanish text.
    static func find(english: String, spanish: String) -> [Trap] {
        let en = english.lowercased().replacingOccurrences(of: "’", with: "'")
        let es = spanish.lowercased()
        func hits(_ pattern: String?, in text: String) -> Bool {
            guard let pattern, !text.isEmpty else { return false }
            return text.range(of: pattern, options: .regularExpression) != nil
        }
        let country = Country.current
        return all.filter { ($0.countries?.contains(country) ?? true) && (hits($0.english, in: en) || hits($0.spanish, in: es)) }
    }
}

/// Apple's translator knows nothing about regional Spanish, so the text is prepared before it goes in and fixed after it comes out.
/// The wording comes from the target country (`Country.current`).
enum CountryTranslation {
    /// One country's wording.
    struct Dialect {
        /// The country's words and phrases → plain Spanish the translator understands.
        let plainer: [(String, String)]
        /// Spain's wording → what is said in the country.
        let spain: [(String, String)]
        /// Plain Spanish phrases the country says another way, wherever they appear.
        let phrases: [(String, String)]
        /// Short reactions, swapped only when they are a whole sentence ("No puede ser." but not "No puede ser tan difícil.").
        let reactions: [(String, String)]
    }

    private static var dialect: Dialect { dialects.current }
    private static let dialects = PerCountry<Dialect> { $0 == .mexico ? mexico : colombia }

    private static let mexico = Dialect(plainer: mexicoPlainer, spain: mexicoSpain, phrases: mexicoPhrases, reactions: mexicoReactions)

    private static let colombia = Dialect(
        plainer: [
            ("qué chimba", "qué bien"), ("chimba", "genial"), ("bacano", "genial"), ("bacana", "genial"), ("chévere", "genial"),
            ("parcero", "amigo"), ("parcera", "amiga"), ("parce", "amigo"), ("pelado", "muchacho"), ("pelada", "muchacha"),
            ("pelao", "muchacho"), ("plata", "dinero"), ("camellar", "trabajar"), ("camello", "trabajo"), ("rumbear", "salir de fiesta"),
            ("rumba", "fiesta"), ("guayabo", "resaca"), ("no joda", "no puede ser"), ("qué pena", "lo siento"), ("de una", "claro"),
            ("ya mismo", "ahora mismo"), ("vaina", "cosa"), ("sumercé", "usted"), ("pilas", "cuidado"), ("mono", "rubio"),
            ("tinto", "café"), ("cuadrar", "acordar"), ("hágale", "vamos"), ("chino", "niño"), ("a la orden", "a sus órdenes"),
        ],
        spain: [
            ("del ordenador", "del computador"), ("el ordenador", "el computador"), ("los ordenadores", "los computadores"),
            ("el grifo", "la llave"), ("un grifo", "una llave"), ("del grifo", "de la llave"),
            ("ordenadores", "computadores"), ("ordenador", "computador"), ("coches", "carros"), ("coche", "carro"),
            ("móviles", "celulares"), ("móvil", "celular"), ("zumos", "jugos"), ("zumo", "jugo"), ("patatas", "papas"), ("patata", "papa"),
            ("aparcamiento", "parqueadero"), ("aparcar", "parquear"), ("conducir", "manejar"), ("autobús", "bus"),
            ("jersey", "suéter"), ("resaca", "guayabo"), ("melocotón", "durazno"), ("grifo", "llave"), ("chaval", "pelado"),
            ("guay", "chévere"), ("cacahuete", "maní"), ("judías verdes", "habichuelas"), ("bolígrafo", "esfero"),
            ("pendientes", "aretes"), ("cazadora", "chaqueta"), ("tarta", "torta"), ("piso", "apartamento"), ("vale", "listo"),
        ],
        phrases: [
            ("ahora mismo", "ya mismo"), ("de nada", "con gusto"), ("lo siento", "qué pena"), ("de acuerdo", "listo"),
            ("qué bien", "qué chévere"), ("qué genial", "qué bacano"),
        ],
        reactions: [
            ("no puede ser", "no joda"), ("de ninguna manera", "ni de fundas"), ("ni hablar", "ni de fundas"),
            ("ni de broma", "ni de fundas"), ("qué increíble", "qué chimba"), ("genial", "chévere"), ("estupendo", "bacano"),
        ])

    private static let mexicoPlainer: [(String, String)] = [
        ("no manches", "no puede ser"), ("no mames", "no puede ser"), ("qué padre", "qué bien"), ("está padre", "está muy bien"),
        ("qué chido", "qué bien"), ("está chido", "está muy bien"), ("chido", "genial"), ("chida", "genial"), ("padrísimo", "estupendo"),
        ("la neta", "la verdad"), ("neta", "verdad"), ("chambear", "trabajar"), ("chamba", "trabajo"), ("güey", "amigo"), ("wey", "amigo"),
        ("ahorita", "ahora mismo"), ("órale", "vamos"), ("ándale", "vamos"), ("cuate", "amigo"), ("carnal", "hermano"), ("lana", "dinero"),
        ("chavo", "muchacho"), ("chava", "muchacha"), ("chamaco", "niño"), ("ni modo", "qué le vamos a hacer"), ("a poco", "de verdad"),
        ("me vale", "no me importa"), ("no hay bronca", "no hay problema"), ("bronca", "problema"), ("aguas", "cuidado"),
        ("chela", "cerveza"), ("güero", "rubio"), ("chafa", "de mala calidad"), ("cruda", "resaca"), ("pinche", "maldito"),
    ]

    private static let mexicoSpain: [(String, String)] = [
        // Words whose gender changes come first, so the article follows
        ("del ordenador", "de la computadora"), ("el ordenador", "la computadora"), ("un ordenador", "una computadora"),
        ("los ordenadores", "las computadoras"), ("unos ordenadores", "unas computadoras"),
        ("el grifo", "la llave"), ("un grifo", "una llave"), ("del grifo", "de la llave"),
        ("las gafas", "los lentes"), ("unas gafas", "unos lentes"), ("de las gafas", "de los lentes"),
        ("ordenadores", "computadoras"), ("ordenador", "computadora"), ("coches", "carros"), ("coche", "carro"),
        ("móviles", "celulares"), ("móvil", "celular"), ("zumos", "jugos"), ("zumo", "jugo"), ("patatas", "papas"), ("patata", "papa"),
        ("gafas", "lentes"), ("aparcamiento", "estacionamiento"), ("aparcar", "estacionar"), ("conducir", "manejar"),
        ("autobús", "camión"), ("jersey", "suéter"), ("resaca", "cruda"), ("melocotón", "durazno"), ("grifo", "llave"), ("chaval", "muchacho"), ("guay", "chido"),
    ]

    static func replacing(_ pairs: [(String, String)], in text: String) -> (text: String, changes: [(String, String)]) {
        var result = text
        var changes: [(String, String)] = []
        for (from, to) in pairs {
            guard let regex = try? NSRegularExpression(pattern: "(?<![\\p{L}])" + NSRegularExpression.escapedPattern(for: from) + "(?![\\p{L}])", options: .caseInsensitive) else { continue }
            let matches = regex.matches(in: result, range: NSRange(result.startIndex..., in: result))
            guard !matches.isEmpty else { continue }
            for match in matches.reversed() {
                guard let range = Range(match.range, in: result) else { continue }
                // A capital at the start of what was replaced carries over ("No puede ser" → "No manches")
                result.replaceSubrange(range, with: Self.matchingCapital(of: String(result[range]), in: to))
            }
            changes.append((from, to))
        }
        return (result, changes)
    }

    static func matchingCapital(of original: String, in replacement: String) -> String {
        guard original.first?.isUppercase == true, let first = replacement.first else { return replacement }
        return first.uppercased() + replacement.dropFirst()
    }

    static func prepare(_ text: String) -> (text: String, changes: [(String, String)]) { replacing(dialect.plainer, in: text) }
    static func localize(_ text: String) -> (text: String, changes: [(String, String)]) { replacing(dialect.spain, in: text) }

    struct Slang: Identifiable {
        let term: String
        let word: Word
        let meaning: String
        var id: String { term }
    }

    /// Words and phrases in the Spanish text that the dictionary marks for the target country, longest phrases first.
    static func slang(in text: String) -> [Slang] {
        guard let regex = try? NSRegularExpression(pattern: "\\p{L}+") else { return [] }
        let tokens = regex.matches(in: text, range: NSRange(text.startIndex..., in: text)).compactMap { Range($0.range, in: text).map { String(text[$0]).lowercased() } }
        var found: [Slang] = []
        var used = Set<Int>()
        for size in stride(from: min(4, tokens.count), through: 1, by: -1) {
            guard tokens.count >= size else { continue }
            for start in 0...(tokens.count - size) {
                let range = start..<start + size
                guard used.isDisjoint(with: range) else { continue }
                let phrase = tokens[range].joined(separator: " ")
                if size == 1, phrase.count <= 2 { continue }
                guard let word = Lexicon.shared.wordsByID[phrase], let meaning = Lexicon.shared.localMeanings(for: word).first?.text else { continue }
                used.formUnion(range)
                found.append(Slang(term: phrase, word: word, meaning: meaning))
            }
        }
        return Array(found.prefix(6))
    }

    /// Other ways to say a word in the Spanish text that the target country uses: its synonyms that carry a local meaning.
    static func alternatives(in text: String) -> [(String, String)] {
        guard let regex = try? NSRegularExpression(pattern: "\\p{L}+") else { return [] }
        var result: [(String, String)] = []
        var seen = Set<String>()
        for match in regex.matches(in: text, range: NSRange(text.startIndex..., in: text)) {
            guard let range = Range(match.range, in: text) else { continue }
            let token = String(text[range]).lowercased()
            guard seen.insert(token).inserted, let word = WordLinks.resolve(token),
                  let synonym = Extras.shared.synonyms[word.spanish]?.first(where: { Lexicon.shared.wordsByID[$0].map(Lexicon.shared.hasLocalMeaning) ?? false }) else { continue }
            result.append((token, synonym))
            if result.count == 5 { break }
        }
        return result
    }

    private static let mexicoPhrases: [(String, String)] = [
        ("ahora mismo", "ahorita"), ("no hay problema", "no hay bronca"), ("de mala calidad", "chafa"),
        ("no me importa", "me vale"), ("qué le vamos a hacer", "ni modo"), ("no hay remedio", "ni modo"),
        ("qué bien", "qué padre"), ("qué genial", "qué chido"),
    ]

    private static let mexicoReactions: [(String, String)] = [
        ("no puede ser", "no manches"), ("de ninguna manera", "ni de chiste"), ("ni hablar", "ni de chiste"),
        ("ni de broma", "ni de chiste"), ("qué increíble", "no manches"), ("genial", "chido"), ("estupendo", "padrísimo"),
    ]

    /// Replaces whole sentences that are just a reaction, keeping the sentence's own punctuation.
    private static func swappingReactions(in text: String) -> (text: String, changes: [(String, String)]) {
        guard let regex = try? NSRegularExpression(pattern: "[^.!?¡¿\\n]+") else { return (text, []) }
        var result = text
        var changes: [(String, String)] = []
        for match in regex.matches(in: text, range: NSRange(text.startIndex..., in: text)).reversed() {
            guard let range = Range(match.range, in: result) else { continue }
            let segment = String(result[range])
            let key = segment.trimmingCharacters(in: .whitespaces).lowercased()
            guard let pair = dialect.reactions.first(where: { $0.0 == key }) else { continue }
            let leading = segment.prefix { $0 == " " }
            result.replaceSubrange(range, with: leading + matchingCapital(of: String(segment.drop { $0 == " " }), in: pair.1))
            changes.append(pair)
        }
        return (result, changes)
    }

    /// The text with the target country's wording: Spain's words swapped, then each plain noun or adjective that has a local synonym replaced by it.
    /// Only dictionary headwords are swapped, never words that are already local, and a noun only becomes a noun of the same
    /// gender, so "el", "la" and adjectives still agree. Verbs, adverbs and prepositions are left alone. `replaced` lists what changed.
    static func slangVersion(of text: String) -> (text: String, replaced: [(String, String)]) {
        let reactions = swappingReactions(in: text)
        let phrases = replacing(dialect.phrases, in: reactions.text)
        let local = localize(phrases.text)
        var result = local.text
        // Everything swapped so far counts, so the bottom card doesn't repeat it
        var replaced: [(String, String)] = (reactions.changes + phrases.changes + local.changes)
            .flatMap { change in change.0.split(separator: " ").map { (String($0), change.1) } }
        func gender(_ word: Word) -> String? { Lexicon.shared.meanings(for: word.spanish).first?.gender }
        for (token, synonym) in alternatives(in: result) {
            guard let word = WordLinks.resolve(token), word.spanish == token, [.noun, .adjective].contains(word.partOfSpeech),
                  !Lexicon.shared.hasLocalMeaning(word),
                  let other = Lexicon.shared.wordsByID[synonym], other.partOfSpeech == word.partOfSpeech, !synonym.contains(" "),
                  word.partOfSpeech == .adjective || (gender(word) != nil && gender(word) == gender(other)) else { continue }
            result = replacing([(token, synonym)], in: result).text
            replaced.append((token, synonym))
        }
        if let first = text.first, first.isUppercase, let now = result.first, now.isLowercase { result = result.prefix(1).uppercased() + result.dropFirst() }
        return (result, replaced)
    }
}

@available(iOS 18.0, *)
struct TranslateView: View {
    private enum Direction: String, CaseIterable, Identifiable {
        case toEnglish = "Spanish → English", toSpanish = "English → Spanish"
        var id: String { rawValue }
        var source: Locale.Language { Locale.Language(identifier: self == .toEnglish ? "es" : "en") }
        var target: Locale.Language { Locale.Language(identifier: self == .toEnglish ? "en" : "es") }
    }

    private struct Output {
        let input: String
        let direction: Direction
        let translation: String
        let readAs: String?
        let adjusted: [(String, String)]
    }

    @State private var direction: Direction = .toEnglish
    @State private var input = ""
    @State private var output: Output?
    @State private var errorText: String?
    @State private var needsDownload = false
    @Environment(\.openURL) private var openSystemURL
    @State private var isWorking = false
    @State private var configuration: TranslationSession.Configuration?
    @State private var request: (text: String, direction: Direction, readAs: String?, source: String)?
    /// Translating waits until typing has paused for this long.
    private static let typingPause: Duration = .milliseconds(500)
    @State private var pending: Task<Void, Never>?
    /// What was last sent to the translator, so the same text isn't translated twice.
    @State private var lastSent = ""
    /// The English translation put back into Spanish, to show how a natural speaker would say the same thing.
    @State private var backText: String?
    @State private var backConfiguration: TranslationSession.Configuration?
    @State private var backRequest: String?
    @FocusState private var focused: Bool
    @Environment(AppRouter.self) private var router: AppRouter?
    @AppStorage(AppSettings.showSpanishChecksKey) private var showChecks = true  // switched in Settings
    /// What the Spanish checks found in the Spanish text on screen: the typed text, or the translation into Spanish.
    @State private var issues: [SpanishIssue] = []
    /// False right after translating Spanish, when the input shows as tappable words instead of an editor.
    @State private var isEditing = true

    private var showsLinkedInput: Bool { !isEditing && output?.direction == .toEnglish && output?.input == input && !input.isEmpty }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Picker("Direction", selection: $direction) {
                    ForEach(Direction.allCases) { Text($0.rawValue).tag($0) }
                }
                .pickerStyle(.segmented)

                combinedBox

                if isWorking {
                    HStack(spacing: 8) { ProgressView(); Text("Translating…").font(.footnote).foregroundStyle(.secondary) }
                }

                if let errorText {
                    VStack(alignment: .leading, spacing: 8) {
                        Label(errorText, systemImage: "exclamationmark.triangle")
                            .font(.footnote)
                            .foregroundStyle(.orange)
                        if needsDownload {
                            Text("Open Settings › Apps › Translate › Languages, download Spanish and English, then come back and try again.")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                            Button("Open Settings") {
                                if let url = URL(string: UIApplication.openSettingsURLString) { openSystemURL(url) }
                            }
                            .buttonStyle(.bordered)
                        }
                    }
                }
                if let output { results(output).padding(.top, 8) }
            }
            .padding()
        }
        .scrollDismissesKeyboard(.interactively)
        .onChange(of: input) { scheduleTranslation() }
        .onChange(of: focused) {
            // Once the keyboard is away, translated Spanish turns into tappable words
            if !focused, let done = output, done.direction == .toEnglish, done.input == input { isEditing = false }
        }
        .onChange(of: direction) {
            if let done = output, done.direction != direction, done.input == input {
                // A finished, unedited translation: flip the languages, so the result becomes the new input
                input = done.direction == .toSpanish ? CountryTranslation.localize(done.translation).text : done.translation
                output = nil
                translate()
            } else if output != nil || errorText != nil || !input.isEmpty {
                // Nothing trustworthy to flip (edited text or an error): translate the same text the other way
                translate()
            }
        }
        .navigationTitle("El Pie")
        .keyboardDoneButton()
        .navigationBarTitleDisplayMode(.inline)
        .translationTask(configuration) { session in
            guard let request else { return }
            do {
                // Missing language packs: the system asks to download them
                try await session.prepareTranslation()
                let response = try await session.translate(request.text)
                // Typing carried on while this was translating: the newer text has its own translation coming
                guard request.source == input.trimmingCharacters(in: .whitespacesAndNewlines) else { isWorking = false; return }
                var text = response.targetText
                if request.direction == .toSpanish { text = TranslationTraps.fixing(text, english: request.source) }
                if request.direction == .toEnglish { text = TranslationTraps.fixingEnglish(text, spanish: request.source) }
                var adjusted: [(String, String)] = []
                if request.direction == .toSpanish { adjusted = CountryTranslation.localize(text).changes }
                output = Output(input: input, direction: request.direction, translation: text, readAs: request.readAs, adjusted: adjusted)
                errorText = nil
                if !focused { isEditing = false }
                checkSpanish(request.direction == .toEnglish ? input : text)
                backText = nil
                if request.direction == .toEnglish { startBackTranslation(of: text) }
            } catch {
                needsDownload = error is TranslationError
                errorText = needsDownload ? "Spanish and English need to be downloaded for offline translation." : error.localizedDescription
            }
            isWorking = false
        }
        .translationTask(backConfiguration) { session in
            guard let source = backRequest else { return }
            // A failure here only hides the extra card; the main translation is already on screen
            guard let response = try? await session.translate(source), backRequest == source else { return }
            backText = response.targetText
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) { AboutButton() }
        }
        .opensWordLinks(inDictionary: true)
    }

    /// The input and its direct translation share one box, with a short line between them.
    private var combinedBox: some View {
        let flagged = showChecks && showsCheckResult && issues.contains { $0.kind != .tip }
        return VStack(alignment: .leading, spacing: 0) {
            inputField
            if let output {
                Divider().padding(.horizontal, 28)
                directTranslation(output)
            }
        }
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.red.opacity(0.6), lineWidth: flagged ? 1 : 0))
    }

    private var inputField: some View {
        VStack(alignment: .leading, spacing: 0) {
            inputText
            if showsCheckFooter && output?.direction == .toEnglish { checkFooter.padding(.horizontal, 13).padding(.bottom, 10) }
        }
        .overlay(alignment: .topTrailing) {
            if !input.isEmpty {
                Button { input = ""; output = nil; errorText = nil; isEditing = true } label: { Image(systemName: "xmark.circle.fill") }
                    .foregroundStyle(.secondary)
                    .padding(10)
            }
        }
    }

    private func directTranslation(_ output: Output) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(output.direction == .toEnglish ? "English" : "Spanish · tap a word")
                    .font(.caption2.weight(.semibold)).foregroundStyle(.secondary).textCase(.uppercase)
                Spacer()
                CopyButton(text: output.translation)
            }
            if output.direction == .toSpanish {
                Text(showChecks ? SpanishChecker.highlighted(WordLinks.linked(output.translation), text: output.translation, issues: issues) : WordLinks.linked(output.translation))
                    .font(.callout).textSelection(.enabled)
                if showsCheckFooter { checkFooter.padding(.top, 4) }
            } else {
                Text(output.translation).font(.callout).textSelection(.enabled)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 12).padding(.vertical, 10)
    }

    /// The Spanish checks only describe the text on screen once its translation has finished.
    private var showsCheckResult: Bool { output != nil && output?.input == input && !isWorking }

    /// The notes only take room when the checks found something to say.
    private var showsCheckFooter: Bool { showChecks && showsCheckResult && !issues.isEmpty }

    /// What the checks found, small, right under the text: a red list of mistakes and orange tips.
    @ViewBuilder
    private var checkFooter: some View {
        let mistakes = issues.filter { $0.kind != .tip }
        let tips = issues.filter { $0.kind == .tip }
        VStack(alignment: .leading, spacing: 3) {
            ForEach(mistakes) { inlineIssue($0, color: .red, icon: "exclamationmark.circle.fill") }
            ForEach(tips) { inlineIssue($0, color: .orange, icon: "lightbulb.fill") }
        }
    }

    private func inlineIssue(_ issue: SpanishIssue, color: Color, icon: String) -> some View {
        HStack(alignment: .top, spacing: 5) {
            Image(systemName: icon).font(.system(size: 9)).foregroundStyle(color).padding(.top, 2)
            Text("**“\(issue.found)”** \(issue.message)\(issue.suggestion.map { " → \($0)" } ?? "")")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }

    private var inputText: some View {
        ZStack(alignment: .topLeading) {
            if showsLinkedInput {
                // Translated Spanish becomes tappable words; tapping anywhere else turns it back into the editor
                Text(showChecks ? SpanishChecker.highlighted(WordLinks.linked(input), text: input, issues: issues) : WordLinks.linked(input))
                    .font(.body)
                    .frame(maxWidth: .infinity, minHeight: 24, alignment: .topLeading)
                    .padding(.leading, 13).padding(.vertical, 14).padding(.trailing, 34)
                    .contentShape(Rectangle())
                    .onTapGesture { isEditing = true; focused = true }
            } else {
                // The invisible text sizes the box, so it starts small and grows with what is typed
                Text(input + "\u{200B}")
                    .font(.body)
                    .opacity(0)
                    .frame(maxWidth: .infinity, minHeight: 24, alignment: .topLeading)
                    .padding(.leading, 13).padding(.vertical, 14).padding(.trailing, 34)
                    .overlay { TextEditor(text: $input).focused($focused).autocorrectionDisabled().scrollContentBackground(.hidden).padding(.leading, 8).padding(.vertical, 6).padding(.trailing, 26) }
            }
            if input.isEmpty {
                Text(direction == .toEnglish ? "Type or paste Spanish" : "Type or paste English")
                    .foregroundStyle(.tertiary)
                    .padding(.horizontal, 13)
                    .padding(.vertical, 14)
                    .allowsHitTesting(false)
            }
        }
    }

    @ViewBuilder
    /// The re-worded Spanish cards. Each only appears when it says something different from what was typed (ignoring case, accents and punctuation).
    private func alternateTexts(_ output: Output) -> (natural: String?, local: String?, slang: Set<String>) {
        if output.direction == .toEnglish, let backText {
            let typed = Self.comparable(output.input)
            let natural = Self.comparable(backText) != typed ? backText : nil
            let version = CountryTranslation.slangVersion(of: backText)
            let showLocal = Self.comparable(version.text) != typed && Self.comparable(version.text) != Self.comparable(backText)
            return (natural, showLocal ? version.text : nil, showLocal ? Set(version.replaced.map(\.0)) : [])
        }
        if output.direction == .toSpanish {
            let version = CountryTranslation.slangVersion(of: output.translation)
            let show = Self.comparable(version.text) != Self.comparable(output.translation)
            return (nil, show ? version.text : nil, show ? Set(version.replaced.map(\.0)) : [])
        }
        return (nil, nil, [])
    }

    @ViewBuilder
    private func results(_ output: Output) -> some View {
        let spanish = output.direction == .toEnglish ? output.input : output.translation
        let alternates = alternateTexts(output)
        let slang = CountryTranslation.slang(in: spanish)
        let alternatives = CountryTranslation.alternatives(in: spanish).filter { !alternates.slang.contains($0.0) }
        let hasNatural = alternates.natural != nil || alternates.local != nil
        let english = output.direction == .toSpanish ? output.input : output.translation
        let traps = Array(TranslationTraps.find(english: english, spanish: spanish).prefix(3))
        let mood = output.direction == .toEnglish ? TranslationTraps.moodNote(spanish: spanish, english: output.translation) : nil
        // With mistakes in the text (a missing accent) the rewrite would repeat them, so the cards wait until they are fixed
        let tenses = showChecks && issues.contains { $0.kind != .tip } ? [] : TenseAlternatives.suggestions(for: spanish)
        let hasWords = output.readAs != nil || !output.adjusted.isEmpty || !slang.isEmpty || !alternatives.isEmpty || !traps.isEmpty || mood != nil || !tenses.isEmpty
        VStack(alignment: .leading, spacing: 24) {
            // Lines only separate sections that both have something in them
            if hasNatural || hasWords { Divider().padding(.horizontal, 28) }
            if let natural = alternates.natural {
                card(title: "Another way to say it", copy: natural) {
                    Text(WordLinks.linked(natural)).font(.callout).textSelection(.enabled)
                }
            }
            if let mexican = alternates.local { countryCard(mexican) }
            if hasNatural && hasWords { Divider().padding(.horizontal, 28) }
            ForEach(traps.map { ($0.id, output.direction == .toEnglish && $0.matchesSpanish(spanish) ? $0.typedMessage ?? $0.message : $0.message) } + (mood.map { [("mood", $0)] } ?? []), id: \.0) { _, message in
                Label { Text(.init(message)) } icon: { Image(systemName: "exclamationmark.triangle.fill").foregroundStyle(.orange) }
                    .font(.footnote)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 12).padding(.vertical, 10)
                    .background(Color.orange.opacity(0.12), in: RoundedRectangle(cornerRadius: 12))
            }
            ForEach(tenses) { tenseCard($0) }
            if let readAs = output.readAs {
                note("Read as", readAs, symbol: "text.magnifyingglass")
            }
            if !output.adjusted.isEmpty {
                note("Adjusted for \(Country.current.name)", output.adjusted.map { "\($0.0) → \($0.1)" }.joined(separator: "  ·  "), symbol: "mappin.and.ellipse")
            }
            if !slang.isEmpty {
                card(title: "\(Country.current.demonym) words in this text") {
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(slang) { item in
                            Button { router?.showWord(item.word) } label: {
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(item.term).font(.headline)
                                        Text(item.meaning).font(.subheadline).foregroundStyle(.secondary)
                                    }
                                    Spacer()
                                    Image(systemName: "chevron.right").font(.caption).foregroundStyle(.tertiary)
                                }
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
            if !alternatives.isEmpty {
                card(title: "In \(Country.current.name) you'd also say") {
                    VStack(alignment: .leading, spacing: 4) {
                        ForEach(alternatives, id: \.0) { Text("\($0.0) → **\($0.1)**") }
                    }
                }
            }
        }
    }

    /// A neighbouring tense that would also fit, with how the meaning shifts and a link to that tense in the verb's chart.
    private func tenseCard(_ suggestion: TenseSuggestion) -> some View {
        card(title: "\(suggestion.heading ?? (suggestion.isNote ? "Good to know" : "Also possible")) · \(suggestion.title)", copy: suggestion.rewritten.isEmpty ? nil : suggestion.rewritten) {
            VStack(alignment: .leading, spacing: 8) {
                if !suggestion.rewritten.isEmpty { Text(WordLinks.linked(suggestion.rewritten)).font(.callout).textSelection(.enabled) }
                Text(.init(suggestion.note)).font(.footnote).foregroundStyle(.secondary)
                Button { router?.showWord(suggestion.verb, focus: suggestion.focus) } label: {
                    HStack(spacing: 4) {
                        Text("See “\(suggestion.verb.spanish)” in \(suggestion.focus.form.title(of: suggestion.focus.tense).lowercased())")
                        Image(systemName: "chevron.right").font(.caption2)
                    }
                    .font(.footnote.weight(.semibold))
                }
                .buttonStyle(.plain)
                .foregroundStyle(Color.accentColor)
            }
        }
    }

    private func card(title: String, copy: String? = nil, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(title).font(.caption2.weight(.semibold)).foregroundStyle(.secondary).textCase(.uppercase)
                Spacer()
                if let copy { CopyButton(text: copy) }
            }
            content()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 12).padding(.vertical, 10)
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 12))
    }

    private func note(_ title: String, _ text: String, symbol: String) -> some View {
        Label { Text("**\(title):** \(text)") } icon: { Image(systemName: symbol) }
            .font(.footnote)
            .foregroundStyle(.secondary)
    }

    /// Runs the Spanish checks off the main thread; the result replaces what was shown before.
    private func checkSpanish(_ text: String) {
        Task {
            let found = await Task.detached(priority: .userInitiated) { SpanishChecker.check(text) }.value
            issues = found
        }
    }

    private func countryCard(_ text: String) -> some View {
        card(title: "More natural in \(Country.current.name)", copy: text) {
            Text(WordLinks.linked(text)).font(.callout).textSelection(.enabled)
        }
    }

    private static func comparable(_ text: String) -> String {
        text.searchKey.split(whereSeparator: { !$0.isLetter && !$0.isNumber }).joined(separator: " ")
    }

    private func startBackTranslation(of english: String) {
        backRequest = english
        let next = TranslationSession.Configuration(source: Locale.Language(identifier: "en"), target: Locale.Language(identifier: "es"))
        if backConfiguration == next { backConfiguration?.invalidate() } else { backConfiguration = next }
    }

    /// Translates once typing has paused; clears the results when the text is emptied.
    private func scheduleTranslation() {
        pending?.cancel()
        let text = input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else {
            output = nil; errorText = nil; issues = []; backText = nil; isWorking = false; lastSent = ""
            return
        }
        guard "\(direction.rawValue)|\(text)" != lastSent else { return }
        pending = Task {
            try? await Task.sleep(for: Self.typingPause)
            guard !Task.isCancelled else { return }
            translate()
        }
    }

    private func translate() {
        let text = input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        pending?.cancel()
        lastSent = "\(direction.rawValue)|\(text)"
        isWorking = true
        errorText = nil
        needsDownload = false
        issues = []
        backText = nil
        var sent = text
        var readAs: String?
        if direction == .toEnglish {
            let prepared = CountryTranslation.prepare(text)
            sent = prepared.text
            if !prepared.changes.isEmpty { readAs = prepared.text }
        }
        request = (sent, direction, readAs, text)
        let next = TranslationSession.Configuration(source: direction.source, target: direction.target)
        if configuration == next { configuration?.invalidate() } else { configuration = next }
    }
}

/// A small "copy" button that confirms with a checkmark for a moment.
struct CopyButton: View {
    let text: String
    @State private var copied = false

    var body: some View {
        Button {
            UIPasteboard.general.string = text
            copied = true
            Task { try? await Task.sleep(for: .seconds(1.5)); copied = false }
        } label: {
            Image(systemName: copied ? "checkmark" : "doc.on.doc")
                .font(.footnote.weight(.semibold))
                .frame(minWidth: 24, minHeight: 20)
        }
        .buttonStyle(.plain)
        .foregroundStyle(copied ? Color.green : Color.accentColor)
        .accessibilityLabel(copied ? "Copied" : "Copy text")
    }
}
