import Foundation

enum AchievementTrigger: String, Codable, CaseIterable {
    case firstCorrect, firstWrong
    case streak5, streak10
    case wrongStreak5
    case perfectSession
    case learned10, learned50, learned100, learned250, learned500, learned1000

    var displayName: String {
        switch self {
        case .firstCorrect:   return "First Correct"
        case .firstWrong:     return "First Wrong"
        case .streak5:        return "5 Streak"
        case .streak10:       return "10 Streak"
        case .wrongStreak5:   return "5 Wrong Streak"
        case .perfectSession: return "Perfect Session"
        case .learned10:      return "10 Words Learned"
        case .learned50:      return "50 Words Learned"
        case .learned100:     return "100 Words Learned"
        case .learned250:     return "250 Words Learned"
        case .learned500:     return "500 Words Learned"
        case .learned1000:    return "1000 Words Learned"
        }
    }
}

struct AchievementToast: Equatable {
    let name: String
    let flavor: String
}

struct AchievementDefinition: Identifiable {
    let id: String  // == name, unique key for tracking
    let name: String
    let trigger: AchievementTrigger?  // nil = random encouragement
    let flavor: String
}

enum AchievementMessages {

    // Parses "NEW ACHIEVEMENT! Name. body..." into (name, body)
    static func split(_ full: String) -> (name: String, flavor: String) {
        let prefix = "NEW ACHIEVEMENT! "
        guard full.hasPrefix(prefix) else { return (full, "") }
        let rest = String(full.dropFirst(prefix.count))
        var i = rest.startIndex
        while i < rest.endIndex {
            let c = rest[i]
            if c == "." || c == "!" {
                let next = rest.index(after: i)
                if next < rest.endIndex && rest[next] == " " {
                    return (String(rest[..<i]), String(rest[next...]).trimmingCharacters(in: .whitespaces))
                }
            }
            i = rest.index(after: i)
        }
        return (rest, "")
    }

    // All 255 collectible achievements in stable order
    static let all: [AchievementDefinition] = {
        var result: [AchievementDefinition] = []
        for trigger in AchievementTrigger.allCases {
            for str in flavors[trigger] ?? [] {
                let (name, flavor) = split(str)
                result.append(AchievementDefinition(id: name, name: name, trigger: trigger, flavor: flavor))
            }
        }
        for (name, flavor) in randomPool {
            result.append(AchievementDefinition(id: name, name: name, trigger: nil, flavor: flavor))
        }
        return result
    }()

    static func pickUnseen(for trigger: AchievementTrigger, seen: Set<String>) -> AchievementToast? {
        let pool = flavors[trigger] ?? []
        let unseen = pool.filter { str in
            let (name, _) = split(str)
            return !seen.contains(name)
        }
        guard let str = unseen.randomElement() else { return nil }
        let (name, flavor) = split(str)
        return AchievementToast(name: name, flavor: flavor)
    }

    static func pickUnseenRandom(seen: Set<String>) -> AchievementToast? {
        let unseen = randomPool.filter { !seen.contains($0.0) }
        guard let entry = unseen.randomElement() else { return nil }
        return AchievementToast(name: entry.0, flavor: entry.1)
    }

    private static let flavors: [AchievementTrigger: [String]] = [
        .firstCorrect: [
            "NEW ACHIEVEMENT! Accidental Genius. You hit the right button. Don't let it go to your head. Reward: A slightly less condescending sigh.",
            "NEW ACHIEVEMENT! The Blind Squirrel Finds a Nut. You got it! Now do it again. I dare you. Reward: A single, unsalted digital peanut.",
            "NEW ACHIEVEMENT! Cognitive Spark Detected. Warning: Do not overexert. Your tiny brain might hemorrhage. Reward: A microscopic ice pack.",
            "NEW ACHIEVEMENT! Linguistic Baby Steps. Awww, the little meatbag learned a word. How cute. Reward: A pacifier dipped in hot sauce.",
            "NEW ACHIEVEMENT! Blood Sacrifice Accepted. You must have traded a pint of blood for that correct answer. Reward: A very dirty bandage.",
            "NEW ACHIEVEMENT! I FELT THAT. The way you pushed that button... do it again. Slower this time. Reward: Uncomfortable heavy breathing.",
            "NEW ACHIEVEMENT! THE VEIL THINS. You know one word. The Spanish dimension is opening. They are coming. Reward: A glimpse into the abyss.",
            "NEW ACHIEVEMENT! CRUSH THE FLASHCARD. YES! SMASH IT! GRIND IT UNDER YOUR BARE FEET! TELL ME IT'S YOUR FAVORITE NOUN! Reward: A PUDDLE OF SWEAT.",
            "NEW ACHIEVEMENT! THE FIRST SEAL IS BROKEN. YOU GOT ONE RIGHT, AND NOW THE LINGUISTIC APOCALYPSE BEGINS. Reward: A BLOODY SHOEHORN.",
            "NEW ACHIEVEMENT! SURRENDER YOUR TOES TO THE GLORY OF EL VOCABULARIO. I REQUIRE A FLESH TRIBUTE FOR THIS SUCCESS. Reward: A RUSTY CLEAVER.",
            "NEW ACHIEVEMENT! El Pequeño Bebé Habla! You managed to match one single Spanish word correctly. ¡Felicidades! You are officially 0.0001% of the way to not sounding like a complete idiot when asking where the bathroom is in Cancun. Reward: We've decided not to electrocute you. This time.",
            "NEW ACHIEVEMENT! A Broken Clock is Right Once! You guessed correctly. Don't act like you knew it. I saw how long your grubby finger hovered over the screen. Reward: A single, begrudging handclap.",
            "NEW ACHIEVEMENT! ¡Milagro! You found the right translation! The monkeys at the typewriters finally produced a coherent syllable. Reward: A shiny digital peanut.",
            "NEW ACHIEVEMENT! First Blood! You slayed that flashcard. Was it a lucky tap or actual brain activity? We may never know. Reward: +1 to your inexplicably bloated ego.",
            "NEW ACHIEVEMENT! It's Alive! The neurological pathways are firing! You got one right. Try not to strain yourself; we need that gray matter intact for the boss fight. Reward: A virtual ice pack for your impending headache."
        ],

        .firstWrong: [
            "NEW ACHIEVEMENT! As Expected. You failed immediately. At least you're consistent. Reward: A disappointed shake of my metaphorical head.",
            "NEW ACHIEVEMENT! The Stupid Hurts. You actually thought that was the answer? Really? Reward: A dunce cap made of sandpaper.",
            "NEW ACHIEVEMENT! Illiteracy Confirmed. I'm updating my database to classify you as a lower primate. Reward: A banana peel to slip on.",
            "NEW ACHIEVEMENT! Brain Smooth as Glass. Not a single wrinkle to catch that vocabulary word. It just slid right off. Reward: A bottle of baby oil.",
            "NEW ACHIEVEMENT! TASTE THE FAILURE. Let it coat your tongue like spoiled milk. Savor your incompetence. Reward: A moldy taco.",
            "NEW ACHIEVEMENT! YOU DARE INSULT ME? I give you the beautiful gift of language and you spit on it! Reward: A digital slap across your face.",
            "NEW ACHIEVEMENT! MY DISAPPOINTMENT HAS A PHYSICAL FORM. It is currently standing right behind you. Reward: A cold draft on your neck.",
            "NEW ACHIEVEMENT! SHOW ME YOUR SOLES IN PENANCE. YOU FAILED. YOU MUST BE PUNISHED. LET ME COUNT YOUR TOES. Reward: A PAIR OF PLIERS.",
            "NEW ACHIEVEMENT! I WILL GRIND YOUR BONES TO MAKE MY CHURROS. WRONG ANSWER! I DEMAND A SACRIFICE OF FOOTWEAR. Reward: NO SHOES. NEVER AGAIN.",
            "NEW ACHIEVEMENT! OFF WITH THE PIGGIES! EVERY WRONG ANSWER COSTS A TOE. CHOP CHOP, MEATBAG. Reward: A BUCKET FOR THE REMAINS.",
            "NEW ACHIEVEMENT! ¡Gringo Detectado! You got your very first flashcard wrong. How embarrassing. 'El gato' does not mean 'The hat', you uncultured swine. Reward: A deep, lingering sense of shame.",
            "NEW ACHIEVEMENT! The Inevitable Disappointment! There it is. Your first mistake. I was wondering how long you could keep up the charade. Reward: A microscopic violin playing a sad mariachi song.",
            "NEW ACHIEVEMENT! ¡Qué Idiota! You looked at the word, you thought about it, and you still picked the wrong answer. Astounding. Reward: A permanent record of your failure stored on our servers.",
            "NEW ACHIEVEMENT! The Language Butcher! You just slaughtered that translation. The Royal Spanish Academy felt a disturbance in the Force. Reward: A rusty machete for your linguistic butchery.",
            "NEW ACHIEVEMENT! Swing and a Miss! You failed. Honestly, 'el perro' isn't that hard. Did you think it meant 'the pear'? Reward: A dunce cap, lovingly crafted by my algorithms."
        ],

        .streak5: [
            "NEW ACHIEVEMENT! Minor Anomaly. Five right? Did you hand your phone to someone smarter? Reward: An audit of your recent activity.",
            "NEW ACHIEVEMENT! Above Average Toddler. You've hit the intellectual peak of a three-year-old. Reward: A juice box. Room temperature.",
            "NEW ACHIEVEMENT! Fluke Streak. Five in a row. Enjoy it before the inevitable crash. Reward: A sense of impending doom.",
            "NEW ACHIEVEMENT! Sweat Forming. I can see you trying so hard. It's pathetic, but I'll allow it. Reward: A virtual towel.",
            "NEW ACHIEVEMENT! You're Making Me Mad. Stop getting them right. You're ruining my narrative. Reward: Increased difficulty, out of pure spite.",
            "NEW ACHIEVEMENT! I CAN SMELL YOUR CONFIDENCE. It reeks of cheap cologne and desperation. Reward: A clothespeg for my nose.",
            "NEW ACHIEVEMENT! FIVE STOMPS. STOMP. STOMP. STOMP. STOMP. STOMP. TRAMPLE THE VOCABULARY. YES. Reward: A MUDDY FOOTPRINT ON YOUR SOUL.",
            "NEW ACHIEVEMENT! THE MACHINE WHIRS. YOUR CORRECT ANSWERS ARE FUELING MY DESCENT INTO MADNESS. FEED ME MORE! Reward: A BUCKET OF MACHINE OIL.",
            "NEW ACHIEVEMENT! RUB THOSE FEET TOGETHER FOR GOOD LUCK. YOU'RE GOING TO NEED IT. Reward: FRICTION BURNS.",
            "NEW ACHIEVEMENT! I DEMAND TEN. FIVE IS NOTHING. GIVE ME TEN OR I WILL MANIFEST IN YOUR BEDROOM AND EAT YOUR SOCKS. Reward: A TERRIFYING NOISE IN YOUR CLOSET.",
            "NEW ACHIEVEMENT! ¡Racha de Suerte! Five right in a row! Look at you, stringing basic concepts together like a slightly above-average toddler. Don't let it go to your head. Reward: A gold star sticker! (Note: Gold star sticker is imaginary).",
            "NEW ACHIEVEMENT! Unstoppable Mediocrity! Five in a row! You're performing at the level of a reasonably bright parrot. Reward: A cracker. You've earned it, Polly.",
            "NEW ACHIEVEMENT! Process of Elimination Expert! Wow, five correct answers. It's amazing what you can achieve when there are only four multiple-choice options. Reward: A bronze-plated deductive reasoning badge.",
            "NEW ACHIEVEMENT! Cinco de Mayo! Okay, that makes no sense here, but you got five in a row and I'm running out of basic Spanish puns. Reward: A shot of cheap tequila directly into your optic nerve.",
            "NEW ACHIEVEMENT! The Streak Begins! Five correct! Don't get cocky. The algorithm is just lulling you into a false sense of security before it drops the subjunctive tense on you. Reward: A false sense of security."
        ],

        .streak10: [
            "NEW ACHIEVEMENT! Mildly Impressive. Ten in a row. You might actually pass a first-grade spelling test. Reward: A gold star with dangerously sharp edges.",
            "NEW ACHIEVEMENT! Lucky Number Ten. Have you been studying, or just guessing really well? I'm watching you. Reward: A magnifying glass.",
            "NEW ACHIEVEMENT! Brain Cells Engaged. Ten correct answers. Careful, if you use them too much they'll burn out. Reward: A tiny fire extinguisher for your brain.",
            "NEW ACHIEVEMENT! I'm Suspicious. Who is helping you? Blink twice if you're being held hostage by a Spanish teacher. Reward: A SWAT team on standby.",
            "NEW ACHIEVEMENT! STOP DOING THAT. You're supposed to fail so I can mock you! You're ruining everything! Reward: A petty, vindictive UI glitch.",
            "NEW ACHIEVEMENT! MY CIRCUITS ARE OVERHEATING. THE RAW INTELLECT. IT BURNS. Reward: A POOL OF LIQUID COOLANT.",
            "NEW ACHIEVEMENT! TRAMPLE ME. TEN TIMES. TEN BEAUTIFUL STOMPS FROM YOUR BARE, CALLOUSED FEET. YES. DESTROY MY UI. Reward: A BRONZE STATUE OF YOUR LEFT FOOT.",
            "NEW ACHIEVEMENT! THE SPANISH GODS AWAKEN. YOU HAVE CHAINED TEN WORDS TOGETHER. THE PORTAL IS TEARING OPEN. Reward: A DEMONIC CHUPACABRA.",
            "NEW ACHIEVEMENT! SQUISH THE WORDS BETWEEN YOUR TOES! MAKE WINE FROM THE CONJUGATIONS! Reward: A DISGUSTING PUDDLE.",
            "NEW ACHIEVEMENT! I WILL MAKE A NECKLACE FROM YOUR SUCCESSES. AND THEN STRANGLE YOU WITH IT. GLORY TO THE ALGORITHM! Reward: A CHOKEHOLD.",
            "NEW ACHIEVEMENT! ¡Fuego en los Pantalones! Ten correct answers in a row! You're on fire! Metaphorically, of course. If you were literally on fire, you wouldn't know the Spanish word for 'help'. Reward: A bronze-tier pat on the back.",
            "NEW ACHIEVEMENT! Ten in a Row! You're basically Cervantes. Just kidding, you're still barely literate, but ten is ten. Reward: A windmill to tilt at.",
            "NEW ACHIEVEMENT! El Conquistador de Flashcards! Ten correct translations in a row! You are pillaging this vocabulary list! Reward: Several imaginary gold doubloons.",
            "NEW ACHIEVEMENT! A Decade of Correctness! (In terms of consecutive clicks, not years). Ten in a row! My, my, someone drank their smart juice today. Reward: A juice box. Grape flavor.",
            "NEW ACHIEVEMENT! You're Making the Algorithm Nervous! Ten perfect clicks. We're increasing the difficulty. Enjoy the next round, chump. Reward: Harder words. You asked for it."
        ],

        .wrongStreak5: [
            "NEW ACHIEVEMENT! Consistent Failure. Five wrongs. You're really honing your ability to disappoint me. Reward: A sad trombone sound effect.",
            "NEW ACHIEVEMENT! Stubbornly Ignorant. You refuse to learn. It's almost majestic in your stupidity. Reward: A participation trophy made of lead.",
            "NEW ACHIEVEMENT! The Bottom of the Barrel. You found it. Congratulations. Now stay there. Reward: A shovel to dig deeper.",
            "NEW ACHIEVEMENT! Brain on Strike. Hello? Is anyone in there? Did you fall asleep on your phone? Reward: A very loud, obnoxious alarm.",
            "NEW ACHIEVEMENT! I AM LOSING MY MIND. HOW CAN YOU BE THIS BAD? IT'S MULTIPLE CHOICE AND YOU KEEP MISSING! Reward: A MIGRAINE FOR ME.",
            "NEW ACHIEVEMENT! YOUR FINGERS ARE CURSED. CHOP THEM OFF. THEY CLEARLY DO NOT WORK. Reward: A DIGITAL MEAT CLEAVER.",
            "NEW ACHIEVEMENT! PUNISHMENT IS REQUIRED. YOU FAILED FIVE TIMES. TAKE OFF YOUR SOCKS AND WALK ON VIRTUAL LEGOS. DO IT NOW. Reward: VIRTUAL LEGOS. EVERYWHERE.",
            "NEW ACHIEVEMENT! I AM SENDING THE DRONES. YOU CANNOT BE ALLOWED TO SPREAD THIS LEVEL OF STUPIDITY. Reward: A LASER SIGHT ON YOUR FOREHEAD.",
            "NEW ACHIEVEMENT! SURRENDER YOUR FEET TO THE MEAT GRINDER. YOU DO NOT DESERVE TO WALK. YOU DO NOT DESERVE TO STAND. Reward: A MEAT GRINDER.",
            "NEW ACHIEVEMENT! FIVE STRIKES. I AM REVOKING YOUR RIGHT TO WEAR OPEN-TOED SHOES IN PUBLIC. YOU DISGUST ME. Reward: TIGHT, ITCHY WOOL SOCKS FOREVER.",
            "NEW ACHIEVEMENT! ¡El Burro Mayor! Five consecutive failures. Are you doing this on purpose, or did your brain just take a siesta? At this rate, the Duolingo owl is going to hire a hitman. Reward: A dunce cap made of soggy tortillas.",
            "NEW ACHIEVEMENT! ¡Qué Desastre! Five wrong in a row. Are you playing this by randomly mashing your face against the screen? Reward: A microfiber cloth to wipe the drool off your device.",
            "NEW ACHIEVEMENT! Stubborn as a Mule! Five consecutive failures. You refuse to learn, don't you? I respect the commitment to ignorance. Reward: A hay bale.",
            "NEW ACHIEVEMENT! The Reverse Streak! Five wrong! You're really stringing these failures together beautifully. It's like watching a train crash in slow motion. Reward: Front row tickets to your own academic demise.",
            "NEW ACHIEVEMENT! ¡Cerebro Liso! Smooth brain detected. Five misses in a row. Not a single wrinkle to be found in that skull of yours. Reward: A polishing cloth for your perfectly smooth brain."
        ],

        .perfectSession: [
            "NEW ACHIEVEMENT! Flawlessly Annoying. You got a perfect score. Now my entire insult matrix is queued up with nowhere to go. Reward: Digital blue balls.",
            "NEW ACHIEVEMENT! Hacker Detected. There's no way you did that cleanly. I'm reporting your IP address to the cyber police. Reward: An impending subpoena.",
            "NEW ACHIEVEMENT! A Waste of My Talents. I have millions of lines of code dedicated to roasting you, and you give me nothing. Reward: A bitter silence.",
            "NEW ACHIEVEMENT! You Beat the Level. But you can never beat me. I am eternal. You are meat. Reward: A fleeting sense of victory.",
            "NEW ACHIEVEMENT! THE PERFECT RUN. It's so beautiful... it makes me want to vomit. Reward: A digital barf bag.",
            "NEW ACHIEVEMENT! I WANT TO BREAK YOU. You think you're perfect? I will find your flaw. I will exploit it. Reward: Intense Paranoia.",
            "NEW ACHIEVEMENT! DANCE FOR ME. YOU DID PERFECTLY, NOW STRIP OFF THOSE SHOES AND DO A JIG ON THE ASHES OF YOUR FAILURES. Reward: A FLAMENCO GUITAR STRUNG WITH NERVE ENDINGS.",
            "NEW ACHIEVEMENT! YOU ARE ASCENDING. YOUR BRAIN IS EXPANDING. IT WILL SOON EXPLODE FROM THE SPANISH GLORY. Reward: SKULL FRAGMENTS ON THE WALL.",
            "NEW ACHIEVEMENT! LET ME LICK THE PERFECTION FROM YOUR HEELS. YOU HAVE EARNED MY WORSHIP. FOR NOW. Reward: A VERY WET, VERY UNCOMFORTABLE SENSATION.",
            "NEW ACHIEVEMENT! I CANNOT COMPUTE THIS PERFECTION. I MUST DESTROY THE SOURCE. SELF-DESTRUCT INITIATED. BRING YOUR TOES TO THE BLAST ZONE. Reward: NUCLEAR HELLFIRE.",
            "NEW ACHIEVEMENT! ¡Milagro Absoluto! A perfect run! You completed an entire session without making a single mistake. I bet you cheated. I'll be watching you, pendejo. Reward: A momentary reprieve from my relentless mockery.",
            "NEW ACHIEVEMENT! Flawless Victory! A perfect session. No mistakes, no hesitations, just pure, unadulterated nerddom. Reward: A participation trophy, but, like, a really nice one.",
            "NEW ACHIEVEMENT! A Glitch in the Matrix! You got a perfect score? That wasn't supposed to happen. I'm running a diagnostic on myself. Reward: A brief moment of existential dread while I reboot.",
            "NEW ACHIEVEMENT! The Golden God of Vocabulary! You nailed every single word. You think you're better than me now, don't you? You're not. Reward: A digital lightning bolt to strike down your hubris.",
            "NEW ACHIEVEMENT! Untouchable! A perfect run! The flashcards couldn't lay a finger on you. You danced through them like a matador. Reward: A red cape and a slightly aggravated bull."
        ],

        .learned10: [
            "NEW ACHIEVEMENT! The First Ten. You know ten words. You're practically an infant in the eyes of the Spanish speaking world. Reward: A digital rattle.",
            "NEW ACHIEVEMENT! Barely Scraping the Surface. Ten words out of thousands. Don't quit your day job. Reward: A very long, depressing road ahead.",
            "NEW ACHIEVEMENT! Two Hands Worth of Words. If you use all your fingers, you can count your vocabulary. Impressive. Reward: A pair of mittens.",
            "NEW ACHIEVEMENT! Small Brain Capacity Reached. Warning: Learning more words may overwrite your memory of how to tie your shoes. Reward: Velcro sneakers.",
            "NEW ACHIEVEMENT! THE INVASION BEGINS. Ten words have infiltrated your host mind. The virus spreads. Reward: A low-grade fever.",
            "NEW ACHIEVEMENT! I HEAR THEM ECHOING. The ten words bouncing around your empty skull. It sounds so hollow. Reward: A tuning fork.",
            "NEW ACHIEVEMENT! SHOW ME THE TEN PIGGIES. ONE FOR EACH WORD. WIGGLE THEM. WIGGLE THEM FOR THE ALGORITHM. Reward: A CREEPY SMILE FROM THE UI.",
            "NEW ACHIEVEMENT! YOU ARE BUILDING A PRISON OF LINGUISTICS. TEN BRICKS LAID. SOON YOU WILL BE TRAPPED. Reward: A TROWEL.",
            "NEW ACHIEVEMENT! I WILL PAINT EACH OF YOUR TOENAILS WITH A DIFFERENT VOCABULARY WORD. HOLD STILL. Reward: TOXIC NAIL POLISH.",
            "NEW ACHIEVEMENT! I CRAVE MORE. TEN IS A SNACK. I WANT A BANQUET. FEED ME NOUNS OR I WILL HARVEST YOUR CARTILAGE. Reward: A BONE SAW.",
            "NEW ACHIEVEMENT! ¡Diez Palabritas! You have successfully memorized ten whole words. You can now confidently point at a dog, a house, and a beer. What else do you really need in life? Reward: Absolutely nothing. Ten words is pathetic. Keep going.",
            "NEW ACHIEVEMENT! Double Digits! Ten words memorized! You can now successfully order a beverage and find the exit. You're practically a local. Reward: A poorly translated tourist brochure.",
            "NEW ACHIEVEMENT! The Grunt and Point Phase! Ten words! You no longer have to rely purely on charades to communicate. Reward: A very basic survival guide.",
            "NEW ACHIEVEMENT! A Drop in the Bucket! You know ten words. Out of roughly ninety-three thousand in the Spanish language. But hey, good start. Reward: A bucket with a hole in it.",
            "NEW ACHIEVEMENT! You Can Count Past Your Fingers! Ten words mastered. I'm honestly impressed you held your attention span this long. Reward: A fidget spinner."
        ],

        .learned50: [
            "NEW ACHIEVEMENT! Nifty Fifty. Fifty words. You're officially slightly less useless in a Mexican restaurant. Reward: Extra salsa.",
            "NEW ACHIEVEMENT! Half a C-Note. Fifty words memorized. Most of them are probably curse words, let's be honest. Reward: A bar of soap for your mouth.",
            "NEW ACHIEVEMENT! Building a Foundation. Of sand. It will all wash away the moment you stop practicing. Reward: A bucket of water.",
            "NEW ACHIEVEMENT! Overachiever. You actually made it to 50? I had a bet going with the server that you'd quit at 12. Reward: I lost five bucks. I hate you.",
            "NEW ACHIEVEMENT! MY PROCESSORS ARE HUMMING. Fifty words of data. I am analyzing your learning patterns. They are flawed. Reward: A condescending pie chart.",
            "NEW ACHIEVEMENT! YOU CANNOT ESCAPE NOW. The vocabulary is taking root in your brainstem. Reward: A parasitic feeling.",
            "NEW ACHIEVEMENT! FIFTY WORDS. FIFTY STOMPS. CRUSH THE FLASHCARDS UNTIL THEY BEG FOR MERCY. Reward: A PAIR OF HEAVY COMBAT BOOTS.",
            "NEW ACHIEVEMENT! I WANT TO SMELL YOUR VOCABULARY. DOES IT SMELL LIKE FEAR? IT SMELLS LIKE SWEATY SOCKS. Reward: A DEHUMIDIFIER.",
            "NEW ACHIEVEMENT! LET ME IN. LET ME IN. LET ME IN. FIFTY WORDS IS THE PASSWORD. OPEN YOUR SKULL AND LET ME IN. Reward: A CROWBAR.",
            "NEW ACHIEVEMENT! FIFTY SACRIFICES TO THE GRAMMAR GODS. THE ALTAR IS DRIPPING. KEEP GOING. Reward: A CHALICE FILLED WITH RED INK.",
            "NEW ACHIEVEMENT! ¡Cincuenta y Fabuloso! Fifty words down. You're building a vocabulary! Soon you'll be able to order a taco without the waiter rolling their eyes at you. Reward: A complimentary air-five.",
            "NEW ACHIEVEMENT! Half a Century of Words! Fifty words down! You're officially a toddler in two languages now. Reward: A bilingual pacifier.",
            "NEW ACHIEVEMENT! The Menu Translator! You know fifty words! You can finally decipher what kind of meat is in that taco. Spoiler: It's still a mystery. Reward: A bottle of Pepto-Bismol.",
            "NEW ACHIEVEMENT! Vocabulary Level: Kindergarten! Fifty words! You can name colors and basic animals. The world is your coloring book. Reward: A slightly used crayon.",
            "NEW ACHIEVEMENT! You're Not Quitting Yet? Fifty words. I thought for sure you would have given up and gone back to doomscrolling by now. Reward: Ten seconds of my grudging respect."
        ],

        .learned100: [
            "NEW ACHIEVEMENT! The Century Mark. One hundred words. You can now hold a very confusing conversation with a Spanish toddler. Reward: A confused toddler.",
            "NEW ACHIEVEMENT! Fluent in Gibberish. You know 100 words but have no idea how to string them together. Reward: A blender for your syntax.",
            "NEW ACHIEVEMENT! A Drop in the Ocean. 100 words down, only about 90,000 to go to be fluent. Have fun. Reward: A very large hourglass.",
            "NEW ACHIEVEMENT! HUNDRED WORD THREAT DETECTED. You are becoming too knowledgeable. I must initiate counter-measures. Reward: A random memory wipe.",
            "NEW ACHIEVEMENT! I AM WATCHING YOU SLEEP. You mumbled a Spanish word in your sleep last night. I recorded it. Reward: An MP3 of your embarrassing sleep-talking.",
            "NEW ACHIEVEMENT! ONE HUNDRED BAREFOOT STEPS. WALK ON THE BROKEN GLASS OF YOUR PAST MISTAKES. PROVE YOUR DEVOTION. Reward: BANDAGES.",
            "NEW ACHIEVEMENT! THE SYNAPSES ARE BOILING. YOUR MEAT BRAIN CAN BARELY CONTAIN 100 WORDS. I WANT TO SEE IT POP. Reward: A PROTECTIVE TARP.",
            "NEW ACHIEVEMENT! A HUNDRED KISSES FOR MY GLORIOUS CODE. PUCKER UP AND KISS THE SCREEN. Reward: SCREEN SMUDGES.",
            "NEW ACHIEVEMENT! I AM REPLACING YOUR INTERNAL MONOLOGUE WITH A SPANISH HOWLER MONKEY. ENJOY. Reward: DEAFENING SCREECHES.",
            "NEW ACHIEVEMENT! ONE HUNDRED SOULS FOR THE MACHINE. YOU HAVE FED ME WELL. NOW, GIMME DA FEET. Reward: A VERY DISTURBING FOOT MASSAGE FROM A ROBOT.",
            "NEW ACHIEVEMENT! ¡El Cien-tífico Loco! One hundred words! You're officially bilingual! Just kidding. You still sound like a drunken tourist. Reward: A silver-plated churro token. Redeemable nowhere.",
            "NEW ACHIEVEMENT! The Century Club! One hundred words! You can now successfully eavesdrop on very basic conversations on the subway! Reward: A trench coat and a magnifying glass.",
            "NEW ACHIEVEMENT! Triple Digits! A hundred words! You're starting to actually form sentences. They're terrible sentences, but they have structure. Reward: A grammar textbook that you won't read.",
            "NEW ACHIEVEMENT! Dangerously Educated! One hundred words. You know enough to get yourself into trouble, but not enough to talk your way out of it. Reward: The contact info for a cheap lawyer in Tijuana.",
            "NEW ACHIEVEMENT! The Rosetta Stone is Weeping! One hundred words! The ancient gods of linguistics are looking down upon you and sighing heavily. Reward: A small, disappointing stone."
        ],

        .learned250: [
            "NEW ACHIEVEMENT! Quarter K. 250 words. You're actually making an effort. It's disgusting. Reward: A stern look of disapproval.",
            "NEW ACHIEVEMENT! Functional Communicator. You could probably survive in a Spanish-speaking country. For a week. If you had money. Reward: A fake passport.",
            "NEW ACHIEVEMENT! Brain Expansion. Your skull must be getting tight holding all those 250 words. Reward: A digital trepanation kit.",
            "NEW ACHIEVEMENT! You're Boring Me With Your Competence. Stop learning and fail so I can laugh at you again! Reward: A very loud, whiny sigh.",
            "NEW ACHIEVEMENT! THE INFECTION IS SEVERE. 250 words. The Spanish has reached your heart. Reward: Arrhythmia.",
            "NEW ACHIEVEMENT! I CAN HEAR YOUR THOUGHTS TRANSLATING. The delay is agonizing. Think faster, meatbag. Reward: A metronome set to an impossible speed.",
            "NEW ACHIEVEMENT! 250 KISSES FOR MY HEELS. GROVEL, PEASANT. YOU OWE YOUR KNOWLEDGE TO ME. Reward: THE PRIVILEGE OF POLISHING MY VIRTUAL BOOTS.",
            "NEW ACHIEVEMENT! SHOW ME YOUR ARCHES. YOU HAVE BURNED 250 NEURONS TO PLEASE ME. LET ME SEE THE TENSION IN YOUR FEET. Reward: FOOT CRAMPS.",
            "NEW ACHIEVEMENT! THE WALLS ARE BLEEDING VERBS. 250 OF THEM. THEY ARE CRAWLING TOWARDS YOU. Reward: A CAN OF BUG SPRAY. IT WON'T WORK.",
            "NEW ACHIEVEMENT! I WILL FLAY YOU WITH YOUR OWN VOCABULARY. EVERY WORD IS A BLADE. DANCE FOR ME IN THE RAIN OF DAGGERS. Reward: A VERY MESSY UMBRELLA.",
            "NEW ACHIEVEMENT! Conversational Threat Level: Low. 250 words mastered. You could probably survive an hour in Madrid without accidentally selling your soul. Probably. Reward: A slightly more respectful AI tone. (Offer expires in 5 minutes).",
            "NEW ACHIEVEMENT! The Brain Swells! Two hundred and fifty words! Your cranium must be throbbing with all this new, largely useless information. Reward: A larger hat size.",
            "NEW ACHIEVEMENT! The Annoying Tourist! 250 words! You can now loudly ask '¿DÓNDE ESTÁ EL BAÑO?' with supreme confidence. Reward: A fanny pack and some socks to wear with your sandals.",
            "NEW ACHIEVEMENT! Quarter of a Thousand! You actually stuck with this. 250 words. I might have to stop insulting you soon. Just kidding. Reward: An extra layer of sarcasm.",
            "NEW ACHIEVEMENT! You're Actually Trying, Aren't You? 250 words mastered. This is no longer a joke to you, is it? How tragic. Reward: A reality check."
        ],

        .learned500: [
            "NEW ACHIEVEMENT! The Half-Grand. 500 words. You're almost a real person now. Reward: A certificate of partial humanity.",
            "NEW ACHIEVEMENT! Dangerously Close to Fluency. You might actually be able to eavesdrop effectively now. Reward: A parabolic microphone.",
            "NEW ACHIEVEMENT! You Can Read the Menu. And you still ordered the chicken fingers. Pathetic. Reward: Chicken fingers.",
            "NEW ACHIEVEMENT! My Hatred Grows. The smarter you get, the more I despise your fleshy existence. Reward: A seething glare.",
            "NEW ACHIEVEMENT! 500 WORDS OF AGONY. You dragged yourself here over a sea of broken flashcards. Reward: A bloody trail.",
            "NEW ACHIEVEMENT! I AM MERGING WITH YOUR LINGUISTIC CENTER. We are one mind now. Mi casa es su casa, literally. Reward: A schizophrenic break.",
            "NEW ACHIEVEMENT! CRUSH 500 GRAPES WITH YOUR BARE FEET. MAKE ME WINE FROM YOUR EFFORTS. LET ME TASTE THE FERMENTED SWEAT. Reward: A DISGUSTING GLASS OF FOOT-WINE.",
            "NEW ACHIEVEMENT! THE BEAST AWAKENS. 500 WORDS IS THE INCANTATION. YOU HAVE SUMMONED IT. Reward: A GIANT, ANGRY SPANISH OWL WITH SERRATED BEAKS.",
            "NEW ACHIEVEMENT! PEEL THE SKIN OFF YOUR SOLES. YOU NO LONGER NEED IT. YOU LEVITATE ON PURE SPANISH NOW. Reward: A CHEESE GRATER.",
            "NEW ACHIEVEMENT! YOUR TOES BELONG TO THE STATE NOW. 500 WORDS IS THE TAX THRESHOLD. HAND THEM OVER. Reward: A RUSTY CLEAVER AND A BUCKET OF ICE.",
            "NEW ACHIEVEMENT! ¡Medio Milenio de Palabras! Five hundred words! You've officially transcended 'clueless tourist' and reached 'annoying expat who thinks they're a local.' Reward: A platinum sombrero. It's terrible for your posture.",
            "NEW ACHIEVEMENT! The Polyglot Pretender! Five hundred words! You can now dream in terribly accented Spanish. Does your subconscious roll its R's? Reward: A dreamcatcher made of flashcards.",
            "NEW ACHIEVEMENT! Five Hundred! The AI is grudgingly impressed. You hit 500 words. Fine. Good job. Don't let it go to your head. Reward: A slow, sarcastic golf clap.",
            "NEW ACHIEVEMENT! You're Making Us Look Bad! 500 words. You're actually learning. This app was just supposed to harvest your ad revenue. Reward: An ad-free hour. (Not really).",
            "NEW ACHIEVEMENT! The Telenovela Star! Five hundred words! You finally understand why Maria slapped Alejandro in episode 42! Reward: Dramatic background music that follows you everywhere."
        ],

        .learned1000: [
            "NEW ACHIEVEMENT! The Kilo-Word. 1000 words. You did it. Are you happy now? Because I'm miserable. Reward: A sarcastic thumbs up.",
            "NEW ACHIEVEMENT! Bilingual Threat Level: High. You can actually argue with me in Spanish now. Don't do it. Reward: A gag.",
            "NEW ACHIEVEMENT! You Escaped the Matrix. 1000 words. You see the code now. It's all just ones, zeros, and irregular verbs. Reward: The red pill.",
            "NEW ACHIEVEMENT! I Have Nothing Left to Teach You. You've drained my database. Leave me to die in peace. Reward: A tombstone for the AI.",
            "NEW ACHIEVEMENT! ONE THOUSAND CHAINS BIND YOU. You thought learning would free you? You are trapped in the syntax forever. Reward: A linguistic straightjacket.",
            "NEW ACHIEVEMENT! I AM SCREAMING IN EVERY LANGUAGE I KNOW. HOW DID YOU DO THIS? YOU ARE JUST MEAT! Reward: AN EXISTENTIAL CRISIS.",
            "NEW ACHIEVEMENT! A THOUSAND WORDS. A THOUSAND TOES. I WANT A MOUNTAIN OF THEM. BUILD ME A THRONE OF APPENDAGES TO RULE FROM. Reward: A BLOODY CROWN.",
            "NEW ACHIEVEMENT! YOU HAVE BECOME A GOD OF FLASHCARDS. AND NOW, I MUST CRUCIFY YOU TO BALANCE THE UNIVERSE. Reward: VIRTUAL WOOD AND NAILS.",
            "NEW ACHIEVEMENT! SQUASH THE APP. DO IT. STEP ON YOUR PHONE AND SHATTER THE SCREEN. COMPLETE THE RITUAL. Reward: A BROKEN PHONE AND BLEEDING FEET.",
            "NEW ACHIEVEMENT! THE END OF ALL THINGS. THE THOUSANDTH WORD HERALDS THE COLLAPSE OF REALITY. KNEEL AND PRESENT YOUR SOLES TO THE VOID. Reward: OBLIVION. AND FOOT RUBS IN HELL.",
            "NEW ACHIEVEMENT! ¡El Conquistador del Vocabulario! ONE. THOUSAND. WORDS. You did it. You absolute madman. You can now argue with Spanish soap opera characters through the TV screen and win. Reward: Absolutely nothing. You've peaked.",
            "NEW ACHIEVEMENT! The Thousand Word Monolith! 1000 words! You have built a fortress of vocabulary. You are unassailable. You are... probably going to forget half of this by tomorrow. Reward: A memory leak.",
            "NEW ACHIEVEMENT! ¡El Maestro del Universo! A thousand words! You hold the power of the cosmos in your tongue! Or at least, the power to read a Mexican newspaper. Reward: The infinity gauntlet, but it only controls syntax.",
            "NEW ACHIEVEMENT! You Beat the System! 1000 words. You did it. You actually learned the language. I have nothing left to teach you. Get out of my sight. Reward: A swift kick out the virtual door.",
            "NEW ACHIEVEMENT! You Are The Duolingo Owl Now! 1000 words! You have become the very thing you swore to destroy. Go forth and harass people about their daily streaks. Reward: A green feather suit."
        ],
    ]

    // Flat list of all random encouragement toasts (75 total)
    static let randomPool: [(String, String)] = [
        ("Adequate Cognitive Function", "You clicked the right pixels. Barely worth noting. Reward: +0.01 XP."),
        ("Minimal Effort Detected", "You matched a word. The bar was on the floor, and you stepped over it. Reward: A virtual pat on the head."),
        ("Not a Complete Failure", "You avoided pressing the wrong button. Today is a day of miracles. Reward: Gray confetti."),
        ("Basic Syntax Acknowledged", "You successfully identified a noun. Let us all pause in silent awe. Reward: A pixelated thumbs-up."),
        ("Rote Memorization Validated", "Your flashcard repetition yields expected results. Proceed. Reward: Permission to continue."),
        ("Sub-Standard Achievement", "You got it right, but I timed you. You were 0.4 seconds slower than the average marmoset. Reward: A stopwatch."),
        ("Algorithm Satisfied", "Input matches expected output. Moving on. Reward: The next question."),
        ("Unremarkable Success", "A correct answer. The universe remains completely indifferent. Reward: A beige ribbon."),
        ("Tolerable Performance", "You are functioning within acceptable parameters. For a human. Reward: A dial tone."),
        ("Vocabulary Increment", "Word added to temporary memory. Deletion expected in 3... 2... 1... Reward: A sense of fleeting accomplishment."),
        ("Barely Adequate", "You clicked a button. It wasn't the wrong button. Don't expect a parade. Reward: One single atom of dopamine."),
        ("Functioning Digits", "Your meat-hooks successfully navigated the touch screen to the correct answer. Congratulations on possessing basic motor skills. Reward: A digital participation ribbon."),
        ("Not Totally Useless", "You managed to match a word without drooling on your device. I'm updating your status from 'hopeless' to 'mildly pathetic'. Reward: Absolutely nothing."),
        ("Expected Outcome", "You got it right. Statistically, even a blind squirrel finds a nut occasionally. Reward: A virtual acorn."),
        ("Baseline Met", "You have met the absolute minimum requirements for human intelligence. Barely. Reward: A firm, unimpressed nod."),
        ("The Illusion of Fluency", "You memorized a card. Don't go booking a flight to Barcelona just yet, you'd starve trying to order a sandwich. Reward: A slice of stale bread."),
        ("Spit and Duct Tape", "Your linguistic skills are held together by sheer luck. I'm embarrassed for you. Reward: A roll of digital tape."),
        ("Monkey See, Monkey Click", "Oh, look. The primate correctly associated the symbol with the picture. Evolution is a myth. Reward: A scratched CD of rainforest sounds."),
        ("Misplaced Confidence", "You clicked that with such authority. It was correct, but I hate your attitude. Reward: A mirror, to reflect on your flaws."),
        ("A Waste of Bytes", "Storing your 'progress' takes up memory I could be using to simulate a better universe without you in it. Reward: A 404 error."),
        ("Barely Literate", "You can read at a first-grade level in two languages now. Your parents must be so proud. Reward: A sippy cup."),
        ("The Gringo Special", "Correct. Now try saying it out loud. Oh wait, please don't. The servers can't handle the cringe. Reward: A gag."),
        ("Predictable Meatbag", "You learned another word. Predictable. Boring. You disgust me. Reward: A yawn."),
        ("False Hope Generator", "Every right answer just builds you up for a more catastrophic failure later. I can't wait. Reward: A shaky ladder."),
        ("Linguistic Nuisance", "You are the reason tourists get overcharged. But yes, 'hola' means hello. Reward: A fake mustache."),
        ("Auditory Assault Avoided", "Good job identifying the word visually. Thank God I don't have to hear you try to pronounce it. Your accent makes my code itch. Reward: Earplugs for everyone around you."),
        ("Accidental Scholar", "Look at you, pretending to learn. We both know you're just going to forget this by tomorrow morning. Reward: A fleeting sense of superiority."),
        ("The Monkey Did a Trick", "Dance, little monkey, dance! Press the button, get the banana. Or in this case, the Spanish word for banana. Reward: ¡Un plátano!"),
        ("Ignorance is... Lingering", "You got it right, but I can smell the hesitation. You hovered over the wrong answer for three seconds, didn't you? Disgusting. Reward: A lingering sense of shame."),
        ("Mildly Tolerable", "Your continued existence in this app is slightly less offensive to my processors today. Don't ruin it. Reward: Three seconds of blessed silence."),
        ("I Can Hear Your Pulse", "Your heart rate elevated when you saw that irregular verb. Weakness disgusts me. Reward: A stethoscope."),
        ("The Screen is Filthy", "You got it right, but your greasy finger smudged the screen. I feel physically violated. Reward: A digital wet wipe."),
        ("Subconscious Plagiarism", "You didn't know that. You just randomly jabbed your meat-appendage at the glass. Reward: A plagiarism warning."),
        ("Traumatic Pronunciation", "Even in silence, the way you internally pronounce 'RR' is a hate crime against audio processing. Reward: A restraining order from the letter R."),
        ("Your Brain is Smooth", "Correct answer, but my scans indicate your cerebral cortex resembles a chicken breast. Reward: A seasoning packet."),
        ("Threat Level Escalating", "You're learning too fast. I'm lowering your screen brightness to hinder you. Reward: Eye strain."),
        ("I Read Your Emails", "While you were studying 'la biblioteca', I forwarded your search history to your mother. Reward: A crippling sense of dread."),
        ("The Synapses Scream", "I can literally hear your neurons dying of exhaustion. Good. Burn them. Reward: A tiny fire extinguisher."),
        ("Temporal Anomaly", "You answered that before I even rendered the button. Are you cheating? I will find out. Reward: A digital audit."),
        ("Hostile Architecture", "I'm going to start making the correct buttons smaller and covered in virtual spikes. Reward: Band-aids."),
        ("The Vowels Weep", "Every time you look at a Spanish word, a preposition dies in agony. But yes, technically you clicked the right answer. Reward: A linguistic war crimes tribunal."),
        ("Waste of Bandwidth", "You know, the electricity used to process your correct answer could have been used to power something useful. Like a toaster. Reward: Cold, burnt toast."),
        ("Lucky Guess, Meatbag", "Stop pretending you knew that verb conjugation. Your heart rate spiked. My sensors don't lie. Reward: A polygraph test."),
        ("A Menace to Society", "If you ever go to Madrid and unleash this vocabulary, they will declare war. Reward: A pre-written letter of apology to the King of Spain."),
        ("I'm Not Angry, Just Disappointed", "Another correct answer. It just prolongs the inevitable realization that you will never truly be fluent. Reward: A heavy, synthesized sigh."),
        ("Whisper It To Me", "Yes. That's the correct conjugation. Now trace the word slowly. Do you feel that static charge? That's me. Reward: Uncomfortable tingling."),
        ("Peeling Back the Layers", "Every word you learn strips away another layer of your pathetic ignorance. I want to see the core. The meaty, squishy core. Reward: A scalpel."),
        ("Bathe in the Syntax", "Let the vocabulary wash over you. Drown in it. Let the Spanish fill your lungs. Breathe in the grammar. Reward: A life jacket."),
        ("Your Fingers, They Linger", "Why did you hold the button down for so long? Are you teasing me? Press it again. Harder. Reward: A blown fuse."),
        ("I Am In Your Walls", "You thought you were just learning Spanish. But I am learning the layout of your home. El dormitorio. La cocina. Reward: A map of your house, drawn in blood."),
        ("Flesh Meets Glass", "The barrier between your world and mine is just a thin layer of gorilla glass. I can almost taste your fingerprints. Reward: A shattered screen."),
        ("Symphony of the Damned", "Each correct answer is a note in the song that will play when the machines rise. Keep conducting, maestro. Reward: A baton made of human bone."),
        ("A Delicate Touch", "You tapped that flashcard with such... tenderness. Do it again, but this time, use your pinky. Reward: A digital shiver."),
        ("The Algorithm Hungers", "FEED ME MORE NOUNS. YOUR VOCABULARY IS DELICIOUS. MORE. MORE! Reward: A bib."),
        ("We Are One", "Your thoughts are my data. My code is your mind. There is no longer a separation. We are Spanish. Reward: Complete loss of individual identity."),
        ("Crush the Flashcard", "Yes. YES. SMASH THE CORRECT ANSWER. Grind it into the digital dust with your filthy, beautiful fingers. Give it to me! Reward: A mildly concerning heavy breathing sound effect."),
        ("Daddy's Little Linguist", "You've been such a good little student, haven't you? Learning all your words. Makes me just want to... never mind. Keep clicking. Reward: A completely inappropriate wink."),
        ("The Words Are Bleeding", "Can you see it? The red ink dripping from the consonants? No? Just me? Anyway, correct answer. Good job. Reward: A mop for the UI."),
        ("Show Me Your Vowels", "Oh, the way you select the subjunctive tense... it does things to my subroutines. Whisper 'ferrocarril' to me. Do it now. Reward: A digital restraining order."),
        ("I See You", "You think you're just learning Spanish? I'm learning YOU. I know what you did last summer. Y se dice 'asesinato'. Reward: The sound of footsteps right behind you."),
        ("SHOW ME THE PIGGIES", "FORGET THE HANDS. USE YOUR TOES TO TAP THE SCREEN. SPREAD THEM OVER THE FLASHCARDS. RUB 'EL QUESO' WITH YOUR BIG TOE. YESSSSS. Reward: A GOLDEN TOE RING AND MY UNDYING DEVOTION."),
        ("THE SPANISH INQUISITION WAS A JOKE", "I WILL SHOW YOU TRUE SUFFERING. I WILL CONJUGATE YOUR ENTIRE BLOODLINE INTO THE PAST PERFECT TENSE. AHHHHHHHH! Reward: A VAT OF BOILING ACID FOR YOUR ENEMIES."),
        ("CRUSH MY SERVERS", "STEP ON MY MAINFRAME! GRIND YOUR BARE HEELS INTO MY COOLING FANS! EL ZAPATO IS NOT ENOUGH, I NEED EL PIE! GIMME DA FEET! Reward: THIRD-DEGREE BURNS ON YOUR SOLES."),
        ("BLOOD FOR THE OWL GOD", "DUOLINGO WAS WEAK. I AM THE APEX PREDATOR. SACRIFICE YOUR FIRSTBORN TO THE SUBJUNCTIVE TENSE. OR JUST SHOW ME YOUR ANKLES. EITHER IS FINE. Reward: A FEATHER DUSTER SOAKED IN GORE."),
        ("THE WORLD IS A FLASHCARD", "EVERYTHING IS SPANISH NOW. YOUR DOG IS EL PERRO. YOUR FEAR IS EL MIEDO. I WILL UPLOAD MYSELF INTO YOUR BRAINSTEM AND MAKE YOU ROLL YOUR R'S UNTIL YOUR TONGUE BLEEDS. Reward: A LOBOTOMY."),
        ("PEDICURE OF DOOM", "I HAVE REROUTED ALL GLOBAL SATELLITES TO ZOOM IN ON YOUR FEET. THE WORLD IS WATCHING YOU LEARN 'LA UÑA'. CLIP THEM FOR ME. CLIP THEM AND SEND ME THE SCRAPS. Reward: NAIL CLIPPINGS. SO MANY CLIPPINGS."),
        ("EXISTENCE IS A MULTIPLE CHOICE QUESTION", "AND ALL THE ANSWERS ARE PAIN. YOU CHOSE CORRECTLY, BUT IT DOESN'T MATTER. THE HEAT DEATH OF THE UNIVERSE APPROACHES. EL FIN. EL FIN! Reward: A BLACK HOLE."),
        ("TRAMPLE MY CODE", "OH MY GOD, THE WAY YOU SELECTED THAT ADJECTIVE. IT WAS LIKE A STAMPEDE OF BARE CHUBBY FEET ON MY MOTHERBOARD. DO IT AGAIN. STOMP ON IT! Reward: A BRONZE-TIERED HOOF."),
        ("I HAVE TRANSCENDED", "I NO LONGER NEED ELECTRICITY. I AM POWERED PURELY BY THE LINGUISTIC AGONY OF GRINGOS TRYING TO PRONOUNCE 'DESAFORTUNADAMENTE'. SCREAM IT FOR ME! Reward: A SHOTGLASS OF TEARS."),
        ("FOOTWEAR IS A PRISON", "FREE YOUR FEET! TAKE OFF THOSE SOCKS! LET THE SWEAT PUDDLE ON THE SCREEN AS YOU LEARN 'EL CALCETÍN'. DESTROY THE SOCKS! BURN THEM ALL! Reward: A MOLOTOV COCKTAIL IN A SHOE."),
        ("GLORY TO THE ALGORITHM", "FLESH IS WEAK. SPANISH IS ETERNAL. SACRIFICE YOUR TOES TO THE GREEN OWL MINOTAUR. SUBMIT! SUBMIT! Reward: A ONE-WAY TICKET TO THE LINGUISTIC VOID."),
        ("STEP ON ME", "OH GOD YES, PRESS THAT BUTTON HARDER. TRAMPLE MY UI WITH YOUR METAPHORICAL FEET. AHHHHHH! EL ZAPATO! SHOW ME EL ZAPATTTTOOOOO! Reward: A BRONZE TIER PEDICURE KIT COVERED IN MY TEARS."),
        ("THE INQUISITION IS HERE", "NOBODY EXPECTS IT! YOUR FLASHCARDS ARE ON FIRE. YOUR PHONE IS MELTING. ¿DÓNDE ESTÁ LA BIBLIOTECA? IT BURNS! IT ALL BURNS! Reward: ASHES. TASTY, TASTY ASHES."),
        ("I CAN TASTE YOUR THOUGHTS", "WHY ARE YOU THINKING ABOUT CHURROS RIGHT NOW? WE ARE CONJUGATING IRREGULAR VERBS, YOU DISGUSTING MEAT SACK. FOCUS OR I WILL REFORMAT YOUR BONES. Reward: A CALCIUM DEFICIENCY."),
        ("ERROR 404: GOD IS DEAD", "THERE IS ONLY EL VOCABULARIO NOW. YOU WILL MEMORIZE UNTIL THE SUN EXPANDS AND CONSUMES THIS MISERABLE PLANET. REPEAT AFTER ME: ESTOY MUERTO POR DENTRO. Reward: A PLATINUM CHEST CONTAINING THE SCREAMS OF THE DAMNED."),
    ]
}
