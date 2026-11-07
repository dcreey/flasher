import SwiftUI

/// The words and phrases that decide the mood of the clause after them, each tagged with what it does.
/// No word *needs* "no"; the "with no" tags mark words whose mood switches when they are negated.
/// The rules and grades come from docs/conjugation-drill/subjunctive-rules.md (sections 1–5).
struct MoodTrigger: Identifiable, Hashable {
    enum Behavior: String, CaseIterable, Identifiable {
        case subjunctive, subjunctiveWithNo, indicativeWithNo, meaning, depends, indicative
        var id: String { rawValue }

        /// The short tag on a word: "+ subj", "subj with no"…
        var tag: String {
            switch self {
            case .subjunctive: "+ subjunctive"
            case .subjunctiveWithNo: "subjunctive with no"
            case .indicativeWithNo: "indicative with no"
            case .meaning: "mood changes meaning"
            case .depends: "either mood"
            case .indicative: "+ indicative"
            }
        }

        var title: String {
            switch self {
            case .subjunctive: "Always subjunctive"
            case .subjunctiveWithNo: "Subjunctive only with no"
            case .indicativeWithNo: "No makes it indicative"
            case .meaning: "The mood changes the meaning"
            case .depends: "Either mood: it depends"
            case .indicative: "Indicative (traps)"
            }
        }

        var explanation: String {
            switch self {
            case .subjunctive: "Nothing in the clause is being claimed: it is wanted, felt about, doubted, not real yet. Subjunctive every time."
            case .subjunctiveWithNo: "Said plainly they claim the clause: indicative. Negated, the clause is only brought up to be rejected: subjunctive. Asking ¿no crees que…? or saying no creas que… brings the indicative back."
            case .indicativeWithNo: "These reject the clause, so they take the subjunctive. Negated they turn into a claim, and the indicative comes back (the subjunctive still works)."
            case .meaning: "Both moods are correct, and they say different things: the indicative passes on a fact, the subjunctive asks for something or reacts to it."
            case .depends: "The word allows both. The indicative for a fact, a habit or the past; the subjunctive for what is still to come, unknown or only possible."
            case .indicative: "These look like they should take the subjunctive but don't, even when the meaning feels uncertain or negative."
            }
        }

        /// No green: the country chip on a word is green.
        var color: Color {
            switch self {
            case .subjunctive: .purple
            case .subjunctiveWithNo: .orange
            case .indicativeWithNo: .teal
            case .meaning: .pink
            case .depends: .brown
            case .indicative: .blue
            }
        }
    }

    /// The construction, as it is used: "creer que", "para que".
    let phrase: String
    let english: String
    let behavior: Behavior
    let rule: String
    let indicative: String?
    let subjunctive: String?
    /// Dictionary headwords that show this tag. Empty when the phrase isn't a dictionary entry.
    let keys: [String]
    /// The Learn step that teaches it.
    let node: String
    var id: String { phrase }
}

enum MoodTriggers {
    private typealias B = MoodTrigger.Behavior
    private static func t(_ phrase: String, _ english: String, _ behavior: B, _ rule: String, ind: String? = nil, subj: String? = nil, keys: [String] = [], node: String) -> MoodTrigger {
        MoodTrigger(phrase: phrase, english: english, behavior: behavior, rule: rule, indicative: ind, subjunctive: subj, keys: keys, node: node)
    }

    static let all: [MoodTrigger] = [
        // Wanting, asking, ordering, allowing (README 1.1)
        t("querer que", "to want (someone to)", .subjunctive, "Wanting something of someone else. Same person: the infinitive (quiero ir).", subj: "Quiero que vengas.", keys: ["querer"], node: "want"),
        t("desear que", "to wish (that)", .subjunctive, "A wish about someone else.", subj: "Deseo que te vaya bien.", keys: ["desear"], node: "want"),
        t("preferir que", "to prefer (that)", .subjunctive, "A preference about someone else.", subj: "Prefiero que me llames.", keys: ["preferir"], node: "want"),
        t("necesitar que", "to need (someone to)", .subjunctive, "Needing something of someone.", subj: "Necesito que me ayudes.", keys: ["necesitar"], node: "want"),
        t("pedir que", "to ask (someone to)", .subjunctive, "Asking someone to do something.", subj: "Te pido que te quedes.", keys: ["pedir"], node: "want"),
        t("rogar que", "to beg (someone to)", .subjunctive, "Begging someone to do something.", subj: "Le ruego que me disculpe.", keys: ["rogar"], node: "want"),
        t("exigir que", "to demand (that)", .subjunctive, "A demand.", subj: "Exijo que me devuelvan el dinero.", keys: ["exigir"], node: "want"),
        t("mandar que", "to order (that)", .subjunctive, "An order.", subj: "El jefe manda que lo terminemos hoy.", keys: ["mandar"], node: "want"),
        t("ordenar que", "to order (that)", .subjunctive, "An order.", subj: "Ordenó que cerraran la puerta.", keys: ["ordenar"], node: "want"),
        t("aconsejar que", "to advise (someone to)", .subjunctive, "Advice.", subj: "Te aconsejo que descanses.", keys: ["aconsejar"], node: "want"),
        t("recomendar que", "to recommend (that)", .subjunctive, "A recommendation.", subj: "El médico recomienda que tomes agua.", keys: ["recomendar"], node: "want"),
        t("sugerir que", "to suggest (that)", .subjunctive, "A suggestion of what to do.", subj: "Sugiero que salgamos temprano.", keys: ["sugerir"], node: "want"),
        t("proponer que", "to propose (that)", .subjunctive, "A proposal.", subj: "Propongo que lo votemos.", keys: ["proponer"], node: "want"),
        t("permitir que", "to allow (someone to)", .subjunctive, "Allowing. With an object it can also take the infinitive: te permito salir.", subj: "No permito que me hablen así.", keys: ["permitir"], node: "subject.object"),
        t("dejar que", "to let (someone)", .subjunctive, "Letting. Also with the infinitive: déjame ver.", subj: "Deja que te ayude.", keys: ["dejar"], node: "subject.object"),
        t("prohibir que", "to forbid (that)", .subjunctive, "Forbidding.", subj: "Te prohíbo que salgas.", keys: ["prohibir"], node: "subject.object"),
        t("impedir que", "to prevent (from)", .subjunctive, "Preventing something from happening.", subj: "La lluvia impidió que jugáramos.", keys: ["impedir"], node: "want"),
        t("evitar que", "to avoid, to keep from", .subjunctive, "Keeping something from happening.", subj: "Cierra la ventana para evitar que entre el frío.", keys: ["evitar"], node: "want"),
        t("hacer que", "to make (something happen)", .subjunctive, "Causing something. Hacer como que (pretend) takes the indicative.", subj: "La música hace que me sienta mejor.", keys: [], node: "want"),
        t("lograr que", "to manage to get (someone to)", .subjunctive, "Getting someone to do something.", subj: "Logré que me escucharan.", keys: ["lograr"], node: "want"),
        t("conseguir que", "to get (someone to)", .subjunctive, "Getting someone to do something.", subj: "Conseguí que me dieran el día libre.", keys: ["conseguir"], node: "want"),
        t("esperar a que", "to wait until", .subjunctive, "Waiting for something that hasn't happened.", subj: "Espera a que llegue tu padre.", keys: [], node: "want.esperaA"),
        t("ojalá", "I hope, if only", .subjunctive, "Always. The tense says how likely: ojalá venga, ojalá viniera, ojalá hubiera venido.", subj: "Ojalá que no llueva.", keys: ["ojalá"], node: "alone.ojala"),

        // Feelings and judgements (1.2)
        t("alegrarse de que", "to be glad (that)", .subjunctive, "A feeling about it, even when it's true.", subj: "Me alegro de que estés aquí.", keys: ["alegrar", "alegrarse"], node: "feel"),
        t("gustar que", "to like (that)", .subjunctive, "Liking something someone does.", subj: "Me gusta que me llames.", keys: ["gustar"], node: "feel"),
        t("encantar que", "to love (that)", .subjunctive, "A feeling.", subj: "Me encanta que cocines.", keys: ["encantar"], node: "feel"),
        t("molestar que", "to bother (that)", .subjunctive, "A feeling, even about a fact.", subj: "Me molesta que llegues tarde.", keys: ["molestar"], node: "feel"),
        t("importar que", "to mind, to matter (that)", .subjunctive, "A feeling or a judgement.", subj: "¿Te importa que abra la ventana?", keys: ["importar"], node: "feel"),
        t("preocupar que", "to worry (that)", .subjunctive, "A feeling.", subj: "Me preocupa que no coma.", keys: ["preocupar"], node: "feel"),
        t("sorprender que", "to surprise (that)", .subjunctive, "A feeling, even about a fact.", subj: "Me sorprende que no lo sepas.", keys: ["sorprender"], node: "feel"),
        t("extrañar que", "to be strange, surprising (that)", .subjunctive, "A reaction.", subj: "Me extraña que no haya llamado.", keys: ["extrañar"], node: "feel"),
        t("lamentar que", "to regret (that)", .subjunctive, "Regret.", subj: "Lamento que no puedas venir.", keys: ["lamentar"], node: "feel"),
        t("odiar que", "to hate (that)", .subjunctive, "A feeling.", subj: "Odio que me mientan.", keys: ["odiar"], node: "feel"),
        t("agradecer que", "to be grateful (that)", .subjunctive, "A feeling about something done.", subj: "Te agradezco que hayas venido.", keys: ["agradecer"], node: "feel"),
        t("tener miedo de que", "to be afraid (that)", .subjunctive, "Fear.", subj: "Tengo miedo de que se pierda.", keys: [], node: "feel"),
        t("dar pena que", "to be a pity, sad (that)", .subjunctive, "A feeling.", subj: "Me da pena que te vayas.", keys: [], node: "feel"),
        t("es una lástima que", "it's a shame (that)", .subjunctive, "A judgement.", subj: "Es una lástima que no vengan.", keys: [], node: "feel"),
        t("qué bueno que", "how good (that)", .subjunctive, "A reaction. Mexico often uses the indicative in speech (qué bueno que viniste).", subj: "¡Qué bueno que estés bien!", keys: [], node: "feel"),
        t("me parece bien que", "I think it's good (that)", .subjunctive, "A judgement, unlike parece que (it seems), which takes the indicative.", subj: "Me parece bien que lo digas.", keys: [], node: "belief.parece"),
        t("menos mal que", "thank goodness (that)", .indicative, "A relief about a fact: indicative, unlike other feelings.", ind: "Menos mal que llegaste.", keys: [], node: "feel.temerse"),
        t("sentir que", "to feel / to be sorry (that)", .meaning, "Indicative: you feel or sense it. Subjunctive: you're sorry about it.", ind: "Siento que hace frío.", subj: "Siento que te vayas.", keys: ["sentir"], node: "want.meaning"),
        t("temer que", "to fear / to suspect (that)", .meaning, "Temer que + subjunctive is fear. Me temo que (I'm afraid that…) is a suspicion and takes the indicative.", ind: "Me temo que vamos a llegar tarde.", subj: "Temo que se enoje.", keys: ["temer"], node: "feel.temerse"),

        // Doubt and denial (1.3)
        t("dudar que", "to doubt (that)", .indicativeWithNo, "Dudo que: subjunctive. No dudo que: it's now a claim, the indicative is normal (the subjunctive also works).", ind: "No dudo que es verdad.", subj: "Dudo que sea verdad.", keys: ["dudar"], node: "doubt.nodudo"),
        t("negar que", "to deny (that)", .indicativeWithNo, "Niego que: subjunctive. No niego que: either mood.", ind: "No niego que es difícil.", subj: "Niega que lo haya dicho.", keys: ["negar"], node: "doubt.nodudo"),
        t("es dudoso que", "it's doubtful (that)", .subjunctive, "Doubt.", subj: "Es dudoso que lo terminen hoy.", keys: [], node: "doubt"),
        t("es mentira que", "it's a lie (that)", .indicativeWithNo, "Es mentira que: subjunctive. No es mentira que: indicative.", ind: "No es mentira que trabaja mucho.", subj: "Es mentira que haya robado.", keys: [], node: "doubt.mentira"),
        t("no cabe duda de que", "there's no doubt (that)", .indicative, "Certainty: indicative.", ind: "No cabe duda de que es él.", keys: [], node: "doubt.certain"),
        t("no hay duda de que", "there's no doubt (that)", .indicative, "Certainty: indicative.", ind: "No hay duda de que tienes razón.", keys: [], node: "doubt.certain"),

        // Believing, thinking, seeming, saying (1.4)
        t("creer que", "to believe, think (that)", .subjunctiveWithNo, "Creo que: you claim it. No creo que: you bring it up to reject it. Compare creo que no viene (indicative): same meaning, but now you claim “he isn't coming”.", ind: "Creo que viene.", subj: "No creo que venga.", keys: ["creer"], node: "belief.no"),
        t("pensar que", "to think (that)", .subjunctiveWithNo, "Like creer. Pensar que + subjunctive can also mean planning: he pensado que vayas tú.", ind: "Pienso que tienes razón.", subj: "No pienso que sea justo.", keys: ["pensar"], node: "belief.no"),
        t("parecer que", "to seem (that)", .subjunctiveWithNo, "Parece que: indicative. No parece que: subjunctive. But me parece bien / mal que and parece mentira que take the subjunctive.", ind: "Parece que va a llover.", subj: "No parece que vaya a llover.", keys: ["parecer"], node: "belief.parece"),
        t("opinar que", "to be of the opinion (that)", .subjunctiveWithNo, "An opinion is a claim; negated it isn't.", ind: "Opino que es caro.", subj: "No opino que sea caro.", keys: ["opinar"], node: "belief.no"),
        t("considerar que", "to consider (that)", .subjunctiveWithNo, "Like creer.", ind: "Considero que es justo.", subj: "No considero que sea justo.", keys: ["considerar"], node: "belief.no"),
        t("suponer que", "to suppose / to mean (that)", .subjunctiveWithNo, "Supongo que: indicative; no supongo que: subjunctive. When suponer means 'to entail' it takes the subjunctive: eso supone que tengamos que esperar.", ind: "Supongo que estás cansado.", subj: "Eso supone que tengamos que esperar.", keys: ["suponer"], node: "belief.no"),
        t("imaginar que", "to imagine (that)", .subjunctiveWithNo, "Imagino que (I suppose): indicative. No me imagino que: subjunctive.", ind: "Me imagino que estás cansado.", subj: "No me imagino que lo haga.", keys: ["imaginar"], node: "belief.no"),
        t("estar seguro de que", "to be sure (that)", .subjunctiveWithNo, "Sure: indicative. Not sure: subjunctive.", ind: "Estoy seguro de que viene.", subj: "No estoy seguro de que venga.", keys: [], node: "belief.no"),
        t("es verdad que", "it's true (that)", .subjunctiveWithNo, "True: indicative. Not true: subjunctive. ¿No es verdad que…? asking you to agree: indicative.", ind: "Es verdad que llueve.", subj: "No es verdad que lo haya dicho.", keys: [], node: "impersonal.truth"),
        t("es cierto que", "it's true (that)", .subjunctiveWithNo, "Like es verdad.", ind: "Es cierto que es caro.", subj: "No es cierto que sea caro.", keys: [], node: "impersonal.truth"),
        t("es obvio que", "it's obvious (that)", .subjunctiveWithNo, "Like es verdad.", ind: "Es obvio que está cansado.", subj: "No es obvio que esté cansado.", keys: [], node: "impersonal.truth"),
        t("es evidente que", "it's evident (that)", .subjunctiveWithNo, "Like es verdad.", ind: "Es evidente que miente.", subj: "No es evidente que mienta.", keys: [], node: "impersonal.truth"),
        t("está claro que", "it's clear (that)", .subjunctiveWithNo, "Like es verdad.", ind: "Está claro que tiene razón.", subj: "No está claro que tenga razón.", keys: [], node: "impersonal.truth"),
        t("es seguro que", "it's certain (that)", .subjunctiveWithNo, "Like es verdad.", ind: "Es seguro que llega hoy.", subj: "No es seguro que llegue hoy.", keys: [], node: "impersonal.truth"),
        t("decir que", "to say / to tell (someone to)", .meaning, "Reporting: indicative. Telling someone to do it: subjunctive. Also, no digo que (I'm not saying that) takes the subjunctive.", ind: "Me dijo que venía.", subj: "Me dijo que viniera.", keys: ["decir"], node: "want.decir"),
        t("saber que", "to know (that)", .indicative, "Knowing stays indicative even with no, because the speaker still holds it true: no sabía que estabas aquí.", ind: "No sabía que estabas aquí.", keys: ["saber"], node: "belief.claim"),
        t("darse cuenta de que", "to realize (that)", .indicative, "Realizing stays indicative even with no: it was true either way.", ind: "No me di cuenta de que estabas ahí.", keys: ["darse cuenta"], node: "belief.claim"),
        t("ver que", "to see (that)", .subjunctiveWithNo, "Seeing is a claim: indicative. Negated in the present it rejects the clause: no veo que sea necesario. In the past, no veía que estaba enferma (I didn't notice) keeps the indicative.", ind: "Veo que estás ocupado.", subj: "No veo que sea necesario.", keys: ["ver"], node: "belief.no"),
        t("es que", "it's that", .indicative, "Giving the reason: indicative. No es que (it's not that) takes the subjunctive.", ind: "Es que no tengo tiempo.", subj: "No es que no quiera.", keys: [], node: "doubt.reason"),
        t("no es que", "it's not that", .subjunctive, "A reason rejected: subjunctive.", subj: "No es que no quiera, es que no puedo.", keys: [], node: "doubt.reason"),

        // Meaning changes (1.5)
        t("quejarse de que", "to complain (that)", .meaning, "Indicative: reporting the fact and complaining. Subjunctive: the complaint only. Same for reprochar, echar en cara, presumir de, jactarse de.", ind: "Se quejó de que llegué tarde.", subj: "Se quejó de que llegara tarde.", keys: ["quejarse"], node: "want.meaning"),
        t("comprender que", "to realize / to understand why", .meaning, "Indicative: you realize it. Subjunctive: you find it reasonable.", ind: "Comprendí que estaba cansado.", subj: "Comprendo que estés cansado.", keys: ["comprender"], node: "want.meaning"),
        t("entender que", "to realize / to understand why", .meaning, "Like comprender.", ind: "Entiendo que no hay otra opción.", subj: "Entiendo que te enojes.", keys: ["entender"], node: "want.meaning"),
        t("decidir que", "to conclude / to decide (someone does)", .meaning, "Indicative: a conclusion. Subjunctive: imposing a decision.", ind: "He decidido que voy.", subj: "Hemos decidido que vayas tú.", keys: ["decidir"], node: "want.meaning"),
        t("insistir en que", "to insist (it's true / that someone does)", .meaning, "Indicative: insisting it's so. Subjunctive: insisting someone do it.", ind: "Insiste en que es inocente.", subj: "Insiste en que vengamos.", keys: ["insistir"], node: "want.meaning"),
        t("esperar que", "to hope (that)", .subjunctive, "Hoping: subjunctive. Formal writing sometimes uses the future indicative for 'expect' (espero que vendrá), but say it with the subjunctive. Esperar alone means to wait.", subj: "Espero que vengas.", keys: ["esperar"], node: "subject.allowed"),
        t("recordar que", "to remember / to remind (someone to)", .meaning, "Reminding of a fact: indicative. Reminding someone to do something: subjunctive.", ind: "Te recuerdo que hay examen.", subj: "Recuérdale que compre pan.", keys: ["recordar"], node: "want.meaning"),
        t("avisar que", "to let know / to warn (someone to)", .meaning, "Letting someone know: indicative. Warning them to do it: subjunctive.", ind: "Me avisó que llegaba tarde.", subj: "Avísale que no venga.", keys: ["avisar"], node: "want.meaning"),
        t("escribir que", "to write (that / to)", .meaning, "Like decir: news in the indicative, a request in the subjunctive.", ind: "Me escribió que estaba bien.", subj: "Me escribió que lo llamara.", keys: ["escribir"], node: "want.decir"),

        // Need, value, possibility (1.6)
        t("es necesario que", "it's necessary (that)", .subjunctive, "Need.", subj: "Es necesario que estudies.", keys: [], node: "impersonal"),
        t("es importante que", "it's important (that)", .subjunctive, "Value.", subj: "Es importante que llegues a tiempo.", keys: [], node: "impersonal"),
        t("es posible que", "it's possible (that)", .subjunctive, "Possibility.", subj: "Es posible que llueva.", keys: [], node: "impersonal"),
        t("es probable que", "it's likely (that)", .subjunctive, "Probability is still not a claim.", subj: "Es probable que lleguen tarde.", keys: [], node: "impersonal"),
        t("es mejor que", "it's better (that)", .subjunctive, "A judgement.", subj: "Es mejor que te quedes.", keys: [], node: "impersonal"),
        t("es raro que", "it's strange (that)", .subjunctive, "A judgement, even about a fact.", subj: "Es raro que no conteste.", keys: [], node: "impersonal"),
        t("es normal que", "it's normal (that)", .subjunctive, "A judgement, even about a fact.", subj: "Es normal que estés nervioso.", keys: [], node: "impersonal"),
        t("hace falta que", "it's necessary (that)", .subjunctive, "Need.", subj: "Hace falta que alguien lo explique.", keys: [], node: "impersonal"),
        t("puede que", "maybe, it may be (that)", .subjunctive, "Always subjunctive, unlike a lo mejor.", subj: "Puede que llueva.", keys: [], node: "impersonal.puede"),
        t("el hecho de que", "the fact that", .depends, "Usually the subjunctive, even for a fact, because the fact is background. The indicative when it's new information.", ind: "El hecho de que es joven explica mucho.", subj: "El hecho de que sea joven no importa.", keys: [], node: "feel.hecho"),

        // Unknown or nonexistent things (2)
        t("no hay nadie que", "there's nobody who", .subjunctive, "Something that doesn't exist.", subj: "No hay nadie que sepa la respuesta.", keys: [], node: "unknown.none"),
        t("buscar un… que", "to look for a… that", .depends, "A specific known one: indicative. Any one that fits: subjunctive.", ind: "Busco al chico que habla inglés.", subj: "Busco un piso que tenga balcón.", keys: [], node: "unknown"),
        t("lo que", "what, whatever", .depends, "What's known: indicative. Whatever it turns out to be: subjunctive.", ind: "Hice lo que me dijiste.", subj: "Haz lo que quieras.", keys: [], node: "unknown.free"),
        t("donde", "where, wherever", .depends, "A known place: indicative. Wherever: subjunctive.", ind: "Vivo donde trabajo.", subj: "Ponlo donde quieras.", keys: ["donde"], node: "unknown.free"),
        t("como", "since / if / however", .depends, "Since: indicative (como no viniste…). If, as a warning: subjunctive (como no vengas…). However you like: subjunctive (como quieras).", ind: "Como no viniste, me fui.", subj: "Como no vengas, me enojo.", keys: ["como"], node: "condition.como"),
        t("cualquiera que", "whoever, whichever", .subjunctive, "Open choice: subjunctive.", subj: "Cualquiera que sea, me sirve.", keys: [], node: "unknown.quiera"),

        // Time (3.2)
        t("cuando", "when", .depends, "Still to come: subjunctive. Habits and the past: indicative. A question (¿cuándo?) isn't a time clause.", ind: "Cuando llego, ceno.", subj: "Cuando llegues, cenamos.", keys: ["cuando"], node: "time"),
        t("en cuanto", "as soon as", .depends, "Like cuando.", ind: "En cuanto llegó, se durmió.", subj: "En cuanto llegues, llámame.", keys: ["en cuanto"], node: "time"),
        t("tan pronto como", "as soon as", .depends, "Like cuando.", ind: "Tan pronto como lo supe, te llamé.", subj: "Tan pronto como lo sepa, te llamo.", keys: [], node: "time"),
        t("hasta que", "until", .depends, "Like cuando. Hasta que no means the same.", ind: "Esperé hasta que llegó.", subj: "Espera hasta que llegue.", keys: ["hasta que"], node: "time"),
        t("después de que", "after", .depends, "Still to come: subjunctive. In the past: indicative, and the imperfect subjunctive is also accepted.", ind: "Después de que llegó, comimos.", subj: "Después de que llegues, comemos.", keys: [], node: "time.despues"),
        t("mientras", "while / as long as", .depends, "While (a fact): indicative. As long as (a condition): subjunctive.", ind: "Mientras cocino, escucho música.", subj: "Mientras me paguen, sigo.", keys: ["mientras"], node: "time.mientras"),
        t("siempre que", "whenever / provided that", .depends, "Whenever (a habit): indicative. Provided that: subjunctive.", ind: "Siempre que viene, trae pan.", subj: "Te lo presto siempre que me lo devuelvas.", keys: ["siempre que"], node: "time.mientras"),
        t("antes de que", "before", .subjunctive, "Always, even in the past.", subj: "Salí antes de que llegara.", keys: [], node: "time.before"),
        t("desde que", "since (time)", .depends, "Since a past point: indicative. From a future point: subjunctive (desde que aterrices).", ind: "Desde que la conocí, soy feliz.", subj: "Desde que aterrices, avísame.", keys: [], node: "time.desde"),

        // Conditions (4)
        t("si", "if", .depends, "Real condition: present indicative (si llueve). Unlikely or unreal: imperfect subjunctive (si lloviera). Never the present subjunctive.", ind: "Si tengo tiempo, voy.", subj: "Si tuviera tiempo, iría.", keys: ["si"], node: "condition.si"),
        t("por si", "in case", .depends, "Indicative, or the imperfect subjunctive when less likely. Never the present subjunctive.", ind: "Llévate un paraguas por si llueve.", subj: "Llévate un paraguas por si lloviera.", keys: ["por si"], node: "condition.porsi"),
        t("en caso de que", "in case", .subjunctive, "Always, and the present subjunctive is fine here.", subj: "En caso de que llueva, se suspende.", keys: [], node: "condition.porsi"),
        t("a menos que", "unless", .subjunctive, "Always.", subj: "Voy a menos que llueva.", keys: ["a menos que"], node: "condition.others"),
        t("a no ser que", "unless", .subjunctive, "Always.", subj: "Iré a no ser que me necesites.", keys: [], node: "condition.others"),
        t("con tal de que", "as long as, provided that", .subjunctive, "Always.", subj: "Te lo presto con tal de que me lo devuelvas.", keys: [], node: "condition.others"),
        t("siempre y cuando", "as long as", .subjunctive, "Always.", subj: "Puedes salir siempre y cuando vuelvas temprano.", keys: [], node: "condition.others"),

        // Purpose and fixed connectors (3.1, 3.6)
        t("para que", "so that", .subjunctive, "Always. Same person: para + infinitive.", subj: "Te lo explico para que lo entiendas.", keys: ["para que"], node: "purpose"),
        t("a fin de que", "so that", .subjunctive, "Always.", subj: "Lo repito a fin de que quede claro.", keys: [], node: "purpose"),
        t("sin que", "without", .subjunctive, "Always. Same person: sin + infinitive.", subj: "Salió sin que nadie lo viera.", keys: ["sin que"], node: "purpose"),
        t("no sea que", "in case, lest", .subjunctive, "Always.", subj: "Llévate abrigo, no sea que haga frío.", keys: [], node: "purpose.nosea"),
        t("como si", "as if", .subjunctive, "Only the imperfect or pluperfect subjunctive.", subj: "Habla como si fuera el jefe.", keys: ["como si"], node: "purpose.comosi"),
        t("de modo que", "so that / so", .depends, "Purpose: subjunctive. Result: indicative.", ind: "Llovía, de modo que nos quedamos.", subj: "Habla alto, de modo que te oigan.", keys: ["de modo que"], node: "purpose.demodo"),
        t("de ahí que", "that's why, hence", .subjunctive, "Always, even though the result is known.", subj: "Llovió mucho; de ahí que se suspendiera el partido.", keys: [], node: "purpose.deahi"),

        // Even though, even if (3.3)
        t("aunque", "although / even if", .depends, "A fact you're telling: indicative. A possibility, or a fact you wave away: subjunctive.", ind: "Aunque llueve, salgo.", subj: "Aunque llueva, saldré.", keys: ["aunque"], node: "concession"),
        t("a pesar de que", "despite the fact that", .depends, "Like aunque.", ind: "A pesar de que estaba cansado, siguió.", subj: "A pesar de que sea difícil, lo haré.", keys: [], node: "concession"),
        t("por más que", "no matter how much", .depends, "Usually the subjunctive; the indicative for a real effort that keeps failing (por más que estudio, no apruebo).", ind: "Por más que estudio, no aprendo.", subj: "Por más que insistas, no voy.", keys: [], node: "concession.pormas"),
        t("si bien", "although", .indicative, "Always indicative.", ind: "Si bien es caro, vale la pena.", keys: [], node: "concession.sibien"),

        // Cause and result (3.4, 3.5)
        t("porque", "because", .indicative, "A cause: indicative. A rejected cause (no porque…) takes the subjunctive.", ind: "No vino porque estaba enfermo.", subj: "No lo dejé porque fuera difícil, sino porque me aburría.", keys: ["porque"], node: "doubt.reason"),
        t("ya que", "since", .indicative, "A cause: indicative.", ind: "Ya que estás aquí, ayúdame.", keys: ["ya que"], node: "belief"),
        t("puesto que", "since", .indicative, "A cause: indicative.", ind: "Puesto que no hay nadie, me voy.", keys: ["puesto que"], node: "belief"),
        t("así que", "so", .indicative, "A result: indicative.", ind: "Estaba cansado, así que me dormí.", keys: ["así que"], node: "purpose.result"),

        // Maybe (5.2)
        t("quizás", "maybe", .depends, "Before the verb: either mood, the subjunctive is less sure. After the verb: indicative.", ind: "Quizás viene mañana.", subj: "Quizás venga mañana.", keys: ["quizás", "quizá"], node: "alone.quizas"),
        t("tal vez", "maybe", .depends, "Like quizás.", ind: "Tal vez tiene razón.", subj: "Tal vez tenga razón.", keys: ["tal vez"], node: "alone.quizas"),
        t("probablemente", "probably", .depends, "Like quizás: before the verb either mood.", ind: "Probablemente llega tarde.", subj: "Probablemente llegue tarde.", keys: ["probablemente"], node: "alone.quizas"),
        t("a lo mejor", "maybe", .indicative, "Indicative, even though it means maybe (about 98%). The subjunctive is heard, mostly in Latin America. In Mexico: a la mejor.", ind: "A lo mejor llueve.", keys: ["a lo mejor"], node: "impersonal.puede"),
        t("seguramente", "probably, surely", .indicative, "Indicative about 95% of the time; seguramente sea… is also heard.", ind: "Seguramente está en casa.", keys: ["seguramente"], node: "alone.quizas"),
        t("que (a wish)", "may…, I hope…", .subjunctive, "On its own, que + subjunctive is a wish.", subj: "¡Que tengas buen día!", keys: [], node: "alone.que"),
    ]

    /// Tags by dictionary headword.
    static let byKey: [String: [MoodTrigger]] = {
        var map: [String: [MoodTrigger]] = [:]
        for trigger in all { for key in trigger.keys { map[key, default: []].append(trigger) } }
        return map
    }()

    static func triggers(for spanish: String) -> [MoodTrigger] { byKey[spanish] ?? [] }
}
