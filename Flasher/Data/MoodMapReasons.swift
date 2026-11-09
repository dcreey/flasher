import Foundation

/// The "Why?" options after an answer. Each step's reason is a full sentence that says what happens and why, so the three options read
/// as three explanations rather than three titles. Imperfect forms in a reason hide it until the imperfect lesson, like everything else.
extension MoodMap {
    static let reasonTexts: [String: String] = [
        "root": "Because the clause is either something you claim is true (indicative) or something you don't claim: wanted, doubted, not real yet, or just reacted to (subjunctive).",
        "want": "Because you want, ask or tell someone else to do something. It isn't a fact yet, only what you wish, so the clause is subjunctive.",
        "feel": "Because it's a feeling or a judgement about something (glad, annoyed, sorry, it's strange that…). You react to it instead of announcing it, so it's subjunctive, even when it's true.",
        "doubt": "Because you doubt or deny the clause: you refuse to claim it's true, so it's subjunctive.",
        "belief": "Because you state what you believe, know, see or say. That claims it's true, so the clause is indicative; only a negated belief (no creo que) takes it back.",
        "impersonal": "Because es + adjective + que works in three cases: truth or evidence (es cierto) is indicative, need or possibility (es necesario, es posible) is subjunctive, and a judgement (es raro) is subjunctive.",
        "unknown": "Because the clause describes a thing: if it's known and real (el piso que tiene balcón) it's indicative; if it's only wanted, unknown or doesn't exist (un piso que tenga balcón) it's subjunctive.",
        "time": "Because of the time word (cuando, hasta que, en cuanto): has it happened, or does it happen as a habit (indicative), or is it still to come (subjunctive)?",
        "condition": "Because of the condition word: si never takes the present subjunctive, and the other condition words (en caso de que, a menos que, con tal de que) take the subjunctive.",
        "purpose": "Because this connector (para que, sin que, antes de que) never introduces a fact, only a purpose, an absence or something that hasn't happened yet, so it always takes the subjunctive.",
        "concession": "Because of aunque: a fact you state is indicative (aunque llueve), a possibility is subjunctive (aunque llueva), and a fact you wave away can be either.",
        "alone": "Because there's no main verb, so a word at the start sets the mood: ojalá always takes the subjunctive, quizás depends on where it goes, and que + subjunctive on its own is a wish.",
        "sequence": "Because the event happened before the main verb, so it needs haber + participle (haya or hubiera), and the main verb decides whether that's present or past.",
        "imperfect": "Because the subjunctive has two simple tenses, present (venga) and imperfect (viniera). The reason for the subjunctive is the same; the imperfect only moves it back in time or into what isn't real.",
        "want.same": "Because the same person wants and does it, so Spanish uses the infinitive (quiero ir) and drops que.",
        "want.decir": "Because decir changes with the mood: decir que + indicative passes on information (me dice que viene), decir que + subjunctive gives an order (me dice que venga).",
        "want.meaning": "Because these verbs have two meanings and the mood picks one: the indicative states or perceives something, the subjunctive reacts, asks or judges.",
        "feel.true": "Because a feeling about a true fact is still a reaction, not news, so the clause is subjunctive even though the fact is real.",
        "feel.temerse": "Because me temo que (I suspect) and menos mal que (thank goodness) pass on a fact instead of reacting to one, so they take the indicative.",
        "doubt.nodudo": "Because not doubting is almost certainty, so the indicative is normal here; the subjunctive is also correct.",
        "doubt.certain": "Because phrases like no cabe duda de que and estoy seguro de que state certainty. You claim it, so it's indicative.",
        "belief.no": "Because a negated belief (no creo que) takes your claim back: you don't vouch for the clause, so it's subjunctive.",
        "belief.claim": "Because the mood follows who stands behind the clause, not the word no: if the speaker vouches for it (creo que no viene) it's indicative; if nobody does, it's subjunctive.",
        "belief.question": "Because a question asking you to agree (¿no crees que…?) or a warning (no creas que…) points at something you consider true, so it stays indicative.",
        "impersonal.truth": "Because es verdad, es cierto and es obvio state truth, so the clause is indicative; only the negated form (no es verdad que) rejects it and takes the subjunctive.",
        "impersonal.puede": "Because puede que always takes the subjunctive (it's a possibility), while a lo mejor (maybe) normally takes the indicative.",
        "unknown.none": "Because something that doesn't exist (no hay nadie que…) can't be described as a fact, so the description is subjunctive.",
        "unknown.superlative": "Because after a superlative (el mejor… que) the thing is known, so the indicative is plain and the subjunctive adds emphasis; for something not yet known (el primero que llegue) the subjunctive is needed.",
        "time.before": "Because antes de que points at something that hasn't happened yet at that moment, even in a story about the past, so it always takes the subjunctive.",
        "time.question": "Because ¿cuándo…? with an accent is a question, not a time clause, so it takes the indicative or the future like any question.",
        "time.despues": "Because después de que about the past tells what happened, so it takes the indicative (the imperfect subjunctive is also accepted in news writing).",
        "condition.si": "Because si never takes the present subjunctive: a real condition uses the present indicative, and an unlikely or unreal one uses the imperfect subjunctive.",
        "condition.como": "Because como + subjunctive is a warning (if you don't…), while como + indicative gives a reason (since…).",
        "condition.porsi": "Because por si (in case) takes the indicative, or the imperfect subjunctive if it's unlikely, but never the present subjunctive.",
        "purpose.comosi": "Because como si (as if) compares with something that isn't so, so it only takes a past subjunctive, never the present.",
        "purpose.demodo": "Because de modo que gives either a purpose (subjunctive) or a result (indicative): is it what you want to happen, or what did happen?",
        "purpose.deahi": "Because de ahí que (that's why) takes the subjunctive even though the result is known: it links back to the cause instead of announcing news.",
        "concession.waved": "Because a known fact after aunque can take the subjunctive when the speaker waves it away (it may be so, but it doesn't matter), and both moods are right.",
        "concession.pormas": "Because por más que and por difícil que (no matter how…) usually take the subjunctive; for a real effort that keeps failing, the indicative is also correct.",
        "alone.ojala": "Because ojalá always takes the subjunctive, and the tense says how likely the wish is: present (it can happen), imperfect (unlikely), pluperfect (it didn't happen).",
        "alone.quizas": "Because quizás and tal vez take either mood before the verb (the indicative is surer), but only the indicative after the verb.",
        "alone.que": "Because que + subjunctive on its own is a wish or an order passed on, while que + indicative on its own is a warning or an emphatic repeat.",
        "alone.mexico": "Because this is how people in Mexico and Colombia say it (ojalá y, a la mejor, capaz que): a regional form you'll hear, even though the standard form differs.",
        "sequence.conditional": "Because the conditional (me gustaría, sería mejor) counts like a past main verb, so the subjunctive after it moves back too.",
        "sequence.pending": "Because after a past verb the present subjunctive is heard, mostly in Latin America, for something still to come; the past form is the safe standard.",
        "subject": "Because when the same person does both things Spanish uses the infinitive; a second person needs que + subjunctive.",
        "subject.feel": "Because the one who feels is also the one who does it (me alegro de estar aquí), so it's an infinitive; someone else would need que + subjunctive.",
        "subject.prep": "Because para, sin and antes de take the infinitive when the same person does both things, and que + subjunctive when someone else does.",
        "subject.impersonal": "Because es importante and es necesario have no person of their own: the infinitive talks about people in general, que + subjunctive about a particular person. Both are correct.",
        "subject.doer": "Because with gustar, encantar and importar the one who feels is me, te or le: if that person also does the action it's an infinitive, and if someone else does it, que + subjunctive.",
        "subject.overlap": "Because yo and nosotros aren't the same person, so quiero que vayamos is right, but queremos ir stays an infinitive because we want and we go.",
        "subject.object": "Because dejar, permitir, prohibir and mandar name the person who acts as an object (te, le), so both the infinitive and que + subjunctive are correct.",
        "subject.allowed": "Because some structures allow que even with one person: esperar (espero que pueda ir), time words (hasta que me canse) and impersonal phrases.",
        "subject.belief": "Because the infinitive rule belongs to wanting and feeling; with believing and saying, the same person keeps que (creo que tengo razón).",
        "subject.perfect": "Because for something you already did yourself, use haber + participle (me alegro de haber venido); for someone else, que + haya.",
        "want.esperaA": "Because esperar a que (wait until) always takes the subjunctive: what you're waiting for hasn't happened yet.",
        "want.convencer": "Because convencer de que + subjunctive means persuade someone to do it, while estar convencido de que means be sure and takes the indicative.",
        "feel.hecho": "Because a fact put first as the topic (el hecho de que…, que… at the start of the sentence) is background, so it usually takes the subjunctive.",
        "feel.lo": "Because lo + adjective + es que follows the adjective: lo cierto es que states a fact (indicative), lo mejor es que says what should happen (subjunctive).",
        "doubt.mentira": "Because es mentira que rejects the clause (subjunctive), while no es mentira que claims it (indicative).",
        "doubt.reason": "Because giving a reason (es que) is a claim (indicative), while rejecting a reason (no es que, no porque) is not (subjunctive).",
        "belief.askdoubt": "Because a plain question with creer normally takes the indicative; the subjunctive is also correct and shows you doubt it.",
        "belief.whether": "Because si meaning whether, and qué or cuándo inside a sentence, aren't triggers: use the tense that fits, and the infinitive for what to do.",
        "belief.parece": "Because parece que (it seems) is indicative, no parece que is subjunctive, and parece mentira que (it's hard to believe) is a judgement: subjunctive.",
        "belief.nouns": "Because nouns work like the verbs they come from: nouns of information (la noticia de que) take the indicative, nouns of wish, need or possibility (la posibilidad de que) take the subjunctive.",
        "impersonal.agree": "Because no es verdad que rejects the clause (subjunctive), but ¿no es verdad que…? asks you to agree, so it's indicative.",
        "unknown.ask": "Because asking whether something exists is open: the subjunctive asks without assuming, the indicative assumes it does, and pocos que takes the subjunctive when it means almost none.",
        "unknown.free": "Because lo que, donde and como are indicative when known or past (hice lo que me dijo) and subjunctive when open (haz lo que quieras).",
        "unknown.quiera": "Because quienquiera, cualquiera and todo el que point at anyone at all, an open set, so they take the subjunctive.",
        "time.never": "Because the future or the conditional never goes after cuando, en cuanto or hasta que: for something still to come, use the subjunctive.",
        "time.mientras": "Because mientras means while (indicative) or as long as (subjunctive), and siempre que means whenever (indicative) or provided that (subjunctive).",
        "time.desde": "Because desde que points at something that happened (indicative), unless the starting point is in the future (subjunctive); hasta que no adds nothing.",
        "condition.unreal": "Because something that didn't happen takes si + pluperfect subjunctive, with habría or hubiera + participle in the result.",
        "condition.others": "Because every condition word except si and por si takes the subjunctive, and the present subjunctive is fine with them.",
        "condition.de": "Because these are conditions without si (de haberlo sabido, insiste y lo conseguirás, yo que tú), so there's no clause to put in a mood.",
        "purpose.nosea": "Because no sea que, vengo a que and que after a command mean in case or so that: a purpose, so it's subjunctive.",
        "purpose.result": "Because a result is a fact (así que, tan… que), so it's indicative; only a denied result takes the subjunctive.",
        "concession.unreal": "Because aunque about something unreal takes the imperfect subjunctive, and about something that didn't happen the pluperfect subjunctive.",
        "concession.sibien": "Because si bien (although) and y eso que (even though) state a fact, so they always take the indicative.",
        "alone.commands": "Because every negative command and every usted or ustedes command uses the present subjunctive form.",
        "alone.polite": "Because quisiera, pudiera and debiera are polite -ra forms that soften a request.",
        "imperfect.make": "Because the imperfect subjunctive is built from the ellos form of the preterite: drop -ron and add -ra, -ras, -ra, -ramos, -rais, -ran.",
        "sequence.past": "Because the main verb is in the past (quería, pidió, me alegré), so the subjunctive moves back too: quería que vinieras, not vengas.",
        "imperfect.unreal": "Because the imperfect subjunctive also says something isn't real or is unlikely, with no past in it (si tuviera, ojalá fuera, como si fuera).",
        "imperfect.english": "Because English has no matching form, so the imperfect subjunctive shows up as “wanted you to come”, “if I had” or “I wish she were”.",
        "sequence.earlier": "Because the event happened before the main verb, so it needs haber + participle: haya after a present verb, hubiera after a past one.",
        "sequence.presentpast": "Because the main verb sets the time unless the event itself is past: a present verb about a past event takes the imperfect subjunctive or haya + participle.",
        "sequence.feelpast": "Because after a feeling about something earlier the subjunctive is hubiera, never the conditional habría.",
        "sequence.forms": "Because the -ra and -se forms are the same subjunctive (tuviera = tuviese), and the old future subjunctive (fuere) survives in legal text and set phrases.",
        "fixed": "Because these are set phrases that are subjunctive with no trigger: doubled verbs meaning no matter what, and hedges like que yo sepa.",
        "fixed.double": "Because the same verb twice in the subjunctive means no matter: diga lo que diga, cueste lo que cueste.",
        "fixed.hedge": "Because que yo sepa and que yo recuerde (as far as I know) are always subjunctive, and que digamos adds “not exactly”.",
        "fixed.frozen": "Because these are frozen wishes in the subjunctive: ¡viva México!, que en paz descanse, así sea.",
    ]

    /// Steps whose reason describes how a form is built or what it means in English: it explains their own cards only, and is never
    /// offered next to a card about another step, where a "how it's made" reason is no reason for choosing the mood.
    static let ownCardsOnly: Set<String> = ["imperfect.make", "imperfect.english"]

    /// Reasons written for one card, where the step's own reason wouldn't explain that card's answer: the right one and two plausible wrong ones.
    static let cardReasons: [String: (right: String, wrong: [String])] = [
        "imperfect.make.1": ("Because ojalá takes the subjunctive, and the imperfect subjunctive of tener is built from tuvieron: tuviera.",
                             ["Because ojalá takes the imperfect indicative (tenía) to say what you wish for.", "Because ojalá needs the conditional (tendría), as in a polite wish."]),
        "imperfect.make.2": ("Because si about something unreal takes the imperfect subjunctive, and fueron (ser) gives its form: fuera.",
                             ["Because si takes the imperfect indicative (era) to say how things were.", "Because si takes the present subjunctive (sea) for something possible."]),
        "imperfect.make.3": ("Because pidió is in the past, so the subjunctive moves back to the imperfect, built from dijeron: dijera.",
                             ["Because pedir que takes the imperfect indicative (decía) to report what he used to say.", "Because pidió is in the past, so the verb stays in the preterite (dijo)."]),
        "imperfect.make.4": ("Because querían is in the past, so the subjunctive moves back to the imperfect; the nosotros form is llegaron → llegáramos, with an accent.",
                             ["Because querer que takes the imperfect indicative (llegábamos) after a past verb.", "Because the nosotros form of the subjunctive is just llegamos, with no change."]),
        "imperfect.make.5": ("Because si about something unreal takes the imperfect subjunctive, and tuvieron gives tuviéramos (with an accent for nosotros).",
                             ["Because si takes the imperfect indicative (teníamos) for a possible condition.", "Because the conditional (iríamos) goes in both halves of the sentence."]),
        "imperfect.make.6": ("Because pidieron is in the past, so the subjunctive moves back to the imperfect: vinieron → viniera.",
                             ["Because pedir que takes the imperfect indicative (venía) when you report it.", "Because pidieron is in the past, so the verb stays in the preterite (vino)."]),
        "imperfect.make.7": ("Because quería is in the past, so the subjunctive moves back to the imperfect, built from dijeron: dijeras.",
                             ["Because querer que takes the imperfect indicative (decías).", "Because querer que always takes the present subjunctive (digas)."]),
        "imperfect.english.1": ("Because que + someone else's action after a past want means “wanted you to…”, and the imperfect subjunctive puts it in the past.",
                                ["Because quería que always means “I wanted to…”, with the same person.", "Because the imperfect always means “used to”, so it says I used to come."]),
        "imperfect.english.2": ("Because si + imperfect subjunctive is English “if I had…”: an unreal or unlikely condition.",
                                ["Because si + the imperfect means “if I have”, a real possibility.", "Because the imperfect after si means “when I had”, about the past."]),
        "imperfect.english.3": ("Because ojalá + imperfect subjunctive is English “I wish… were”: it isn't true right now.",
                                ["Because ojalá + the imperfect means “I hope”, something that can still happen.", "Because ojalá + the imperfect means “I wished” back then."]),
        "imperfect.english.4": ("Because pedir que + subjunctive means asking someone to do something, and the imperfect puts the asking in the past.",
                                ["Because pedir que + the imperfect means asking whether something already happened.", "Because que + the imperfect reports what someone did."]),
        "imperfect.english.5": ("Because que + someone else's action after a past want means “wanted you to…”, and the imperfect subjunctive puts it in the past.",
                                ["Because quería que always means “I wanted to…”, with the same person.", "Because the imperfect always means “used to”, so it says I used to help."]),
        "imperfect.english.6": ("Because ojalá + imperfect subjunctive is English “I wish I had…”: it isn't true right now.",
                                ["Because ojalá + the imperfect means “I hope I have”, something that can still happen.", "Because ojalá + the imperfect means “I wished” back then."]),
    ]

    /// The card with its own reasons, if it has them: the right one sits in a different place on each card.
    static func withCardReason(_ item: MoodItem) -> MoodItem {
        guard let reasons = cardReasons[item.id] else { return item }
        var item = item
        let at = item.id.unicodeScalars.reduce(0) { ($0 &+ Int($1.value)) } % 3
        var options = reasons.wrong
        options.insert(reasons.right, at: at)
        item.why = options
        item.whyRight = at
        return item
    }

    /// What a step says as a reason: the full sentence, or its title if none is written.
    static func reasonText(of node: MoodNode) -> String { reasonTexts[node.id] ?? node.title }
}
