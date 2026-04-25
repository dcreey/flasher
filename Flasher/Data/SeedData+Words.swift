import Foundation

// Top ~650 most useful Spanish words for Mexican Spanish learners.
// Ordered from most common/important (index 0) to least (index N).
// Conjugated verb forms are excluded — only infinitives are tested.
// TODO: Expand toward 5 000 words by appending entries to raw[] below.

extension SeedData {
    static let words: [Word] = {
        typealias W = (String, String, PartOfSpeech, String?)
        let raw: [W] = [

            // ── RANK 0–19  Core prepositions & conjunctions ────────────────────
            ("de",          "of, from",                     .preposition, nil),
            ("en",          "in, on, at",                   .preposition, nil),
            ("a",           "to, at",                       .preposition, nil),
            ("y",           "and",                          .conjunction, nil),
            ("con",         "with",                         .preposition, nil),
            ("por",         "for, by, through",             .preposition, nil),
            ("para",        "for, in order to",             .preposition, nil),
            ("que",         "that, which",                  .conjunction, nil),
            ("pero",        "but",                          .conjunction, nil),
            ("o",           "or",                           .conjunction, nil),
            ("sin",         "without",                      .preposition, nil),
            ("si",          "if",                           .conjunction, nil),
            ("como",        "as, like, how",                .conjunction, nil),
            ("porque",      "because",                      .conjunction, nil),
            ("cuando",      "when",                         .conjunction, nil),
            ("aunque",      "although, even though",        .conjunction, nil),
            ("donde",       "where",                        .conjunction, nil),
            ("sobre",       "on, about, over",              .preposition, nil),
            ("entre",       "between, among",               .preposition, nil),
            ("sino",        "but rather",                   .conjunction, nil),

            // ── RANK 20–39  More prepositions / conjunctions ───────────────────
            ("desde",       "from, since",                  .preposition, nil),
            ("hasta",       "until, up to",                 .preposition, nil),
            ("durante",     "during",                       .preposition, nil),
            ("hacia",       "towards",                      .preposition, nil),
            ("bajo",        "under, below",                 .preposition, nil),
            ("según",       "according to",                 .preposition, nil),
            ("ante",        "before, in front of",          .preposition, nil),
            ("mientras",    "while, as long as",            .conjunction, nil),
            ("ni",          "nor, neither",                 .conjunction, nil),
            ("tras",        "after, behind",                .preposition, nil),
            ("pues",        "well, then, so",               .conjunction, nil),
            ("además",      "furthermore, besides",         .adverb,      nil),
            ("incluso",     "even, including",              .adverb,      nil),
            ("sin embargo", "however, nevertheless",        .adverb,      nil),
            ("así que",     "so, therefore",                .conjunction, nil),
            ("ya que",      "since, given that",            .conjunction, nil),
            ("a pesar de",  "in spite of",                  .preposition, nil),
            ("en vez de",   "instead of",                   .preposition, nil),
            ("junto a",     "next to, alongside",           .preposition, nil),
            ("frente a",    "in front of, facing",          .preposition, nil),

            // ── RANK 40–55  Articles & pronouns ───────────────────────────────
            ("el",          "the (masculine)",              .article,     nil),
            ("la",          "the (feminine)",               .article,     nil),
            ("los",         "the (masc. plural)",           .article,     nil),
            ("las",         "the (fem. plural)",            .article,     nil),
            ("un",          "a, an (masculine)",            .article,     nil),
            ("una",         "a, an (feminine)",             .article,     nil),
            ("yo",          "I",                            .pronoun,     nil),
            ("tú",          "you (informal)",               .pronoun,     nil),
            ("él",          "he",                           .pronoun,     nil),
            ("ella",        "she",                          .pronoun,     nil),
            ("usted",       "you (formal)",                 .pronoun,     nil),
            ("nosotros",    "we",                           .pronoun,     nil),
            ("ustedes",     "you all",                      .pronoun,     nil),
            ("ellos",       "they (masc. plural)",          .pronoun,     nil),
            ("ellas",       "they (fem. plural)",           .pronoun,     nil),
            ("me",          "me, myself",                   .pronoun,     nil),

            // ── RANK 56–80  Core adverbs ──────────────────────────────────────
            ("no",          "no, not",                      .adverb,      nil),
            ("sí",          "yes",                          .adverb,      nil),
            ("ya",          "already, now",                 .adverb,      nil),
            ("muy",         "very",                         .adverb,      nil),
            ("más",         "more",                         .adverb,      nil),
            ("bien",        "well",                         .adverb,      nil),
            ("también",     "also, too",                    .adverb,      nil),
            ("nunca",       "never",                        .adverb,      nil),
            ("siempre",     "always",                       .adverb,      nil),
            ("aquí",        "here",                         .adverb,      nil),
            ("allí",        "there",                        .adverb,      nil),
            ("ahora",       "now",                          .adverb,      nil),
            ("hoy",         "today",                        .adverb,      nil),
            ("ayer",        "yesterday",                    .adverb,      nil),
            ("mañana",      "tomorrow",                     .adverb,      nil),
            ("antes",       "before",                       .adverb,      nil),
            ("después",     "after, later",                 .adverb,      nil),
            ("mucho",       "a lot, much",                  .adverb,      nil),
            ("poco",        "a little, few",                .adverb,      nil),
            ("solo",        "only, just",                   .adverb,      nil),
            ("casi",        "almost",                       .adverb,      nil),
            ("todavía",     "still, yet",                   .adverb,      nil),
            ("menos",       "less",                         .adverb,      nil),
            ("mal",         "badly",                        .adverb,      nil),
            ("así",         "like this, so",                .adverb,      nil),

            // ── RANK 81–130  Core verbs (infinitives) ────────────────────────
            ("ser",         "to be (permanent)",            .infinitive,  nil),
            ("estar",       "to be (temporary)",            .infinitive,  nil),
            ("tener",       "to have",                      .infinitive,  nil),
            ("hacer",       "to do, to make",               .infinitive,  nil),
            ("ir",          "to go",                        .infinitive,  nil),
            ("poder",       "to be able to, can",           .infinitive,  nil),
            ("querer",      "to want, to love",             .infinitive,  nil),
            ("saber",       "to know (facts/skills)",       .infinitive,  nil),
            ("dar",         "to give",                      .infinitive,  nil),
            ("venir",       "to come",                      .infinitive,  nil),
            ("decir",       "to say, to tell",              .infinitive,  nil),
            ("ver",         "to see, to watch",             .infinitive,  nil),
            ("hablar",      "to speak, to talk",            .infinitive,  nil),
            ("llevar",      "to carry, to take",            .infinitive,  nil),
            ("poner",       "to put, to place",             .infinitive,  nil),
            ("quedar",      "to stay, to remain",           .infinitive,  nil),
            ("llegar",      "to arrive",                    .infinitive,  nil),
            ("pasar",       "to pass, to happen",           .infinitive,  nil),
            ("seguir",      "to follow, to continue",       .infinitive,  nil),
            ("encontrar",   "to find",                      .infinitive,  nil),
            ("creer",       "to believe, to think",         .infinitive,  nil),
            ("dejar",       "to leave, to let",             .infinitive,  nil),
            ("trabajar",    "to work",                      .infinitive,  nil),
            ("sentir",      "to feel",                      .infinitive,  nil),
            ("buscar",      "to look for, to search",       .infinitive,  nil),
            ("vivir",       "to live",                      .infinitive,  nil),
            ("comenzar",    "to begin, to start",           .infinitive,  nil),
            ("volver",      "to return, to come back",      .infinitive,  nil),
            ("tomar",       "to take, to drink",            .infinitive,  nil),
            ("pedir",       "to ask for, to order",         .infinitive,  nil),
            ("usar",        "to use",                       .infinitive,  nil),
            ("necesitar",   "to need",                      .infinitive,  nil),
            ("tratar",      "to try, to treat",             .infinitive,  nil),
            ("conocer",     "to know (people/places)",      .infinitive,  nil),
            ("salir",       "to leave, to go out",          .infinitive,  nil),
            ("entrar",      "to enter",                     .infinitive,  nil),
            ("pensar",      "to think",                     .infinitive,  nil),
            ("llamar",      "to call",                      .infinitive,  nil),
            ("escribir",    "to write",                     .infinitive,  nil),
            ("abrir",       "to open",                      .infinitive,  nil),
            ("cerrar",      "to close",                     .infinitive,  nil),
            ("leer",        "to read",                      .infinitive,  nil),
            ("mirar",       "to look at, to watch",         .infinitive,  nil),
            ("escuchar",    "to listen",                    .infinitive,  nil),
            ("caminar",     "to walk",                      .infinitive,  nil),
            ("correr",      "to run",                       .infinitive,  nil),
            ("comer",       "to eat",                       .infinitive,  nil),
            ("beber",       "to drink",                     .infinitive,  nil),
            ("dormir",      "to sleep",                     .infinitive,  nil),
            ("comprar",     "to buy",                       .infinitive,  nil),

            // ── RANK 131–200  Core nouns ─────────────────────────────────────
            ("tiempo",      "time, weather",                .noun,        "m"),
            ("año",         "year",                         .noun,        "m"),
            ("vida",        "life",                         .noun,        "f"),
            ("mundo",       "world",                        .noun,        "m"),
            ("país",        "country",                      .noun,        "m"),
            ("ciudad",      "city",                         .noun,        "f"),
            ("trabajo",     "work, job",                    .noun,        "m"),
            ("persona",     "person",                       .noun,        "f"),
            ("hombre",      "man",                          .noun,        "m"),
            ("mujer",       "woman",                        .noun,        "f"),
            ("cosa",        "thing",                        .noun,        "f"),
            ("parte",       "part",                         .noun,        "f"),
            ("niño",        "boy, child",                   .noun,        "m"),
            ("niña",        "girl, child",                  .noun,        "f"),
            ("lugar",       "place",                        .noun,        "m"),
            ("casa",        "house, home",                  .noun,        "f"),
            ("día",         "day",                          .noun,        "m"),
            ("noche",       "night",                        .noun,        "f"),
            ("gente",       "people",                       .noun,        "f"),
            ("momento",     "moment",                       .noun,        "m"),
            ("hora",        "hour, time",                   .noun,        "f"),
            ("semana",      "week",                         .noun,        "f"),
            ("mes",         "month",                        .noun,        "m"),
            ("nombre",      "name",                         .noun,        "m"),
            ("agua",        "water",                        .noun,        "f"),
            ("amor",        "love",                         .noun,        "m"),
            ("verdad",      "truth",                        .noun,        "f"),
            ("vez",         "time, instance",               .noun,        "f"),
            ("dinero",      "money",                        .noun,        "m"),
            ("familia",     "family",                       .noun,        "f"),
            ("madre",       "mother",                       .noun,        "f"),
            ("padre",       "father",                       .noun,        "m"),
            ("hijo",        "son",                          .noun,        "m"),
            ("hija",        "daughter",                     .noun,        "f"),
            ("amigo",       "friend (male)",                .noun,        "m"),
            ("amiga",       "friend (female)",              .noun,        "f"),
            ("problema",    "problem",                      .noun,        "m"),
            ("forma",       "form, way",                    .noun,        "f"),
            ("número",      "number",                       .noun,        "m"),
            ("idea",        "idea",                         .noun,        "f"),
            ("razón",       "reason",                       .noun,        "f"),
            ("ejemplo",     "example",                      .noun,        "m"),

            // ── RANK 201–270  Core adjectives ─────────────────────────────────
            ("bueno",       "good",                         .adjective,   nil),
            ("malo",        "bad",                          .adjective,   nil),
            ("grande",      "big, large",                   .adjective,   nil),
            ("pequeño",     "small, little",                .adjective,   nil),
            ("nuevo",       "new",                          .adjective,   nil),
            ("viejo",       "old",                          .adjective,   nil),
            ("mismo",       "same",                         .adjective,   nil),
            ("igual",       "equal, same",                  .adjective,   nil),
            ("diferente",   "different",                    .adjective,   nil),
            ("posible",     "possible",                     .adjective,   nil),
            ("importante",  "important",                    .adjective,   nil),
            ("claro",       "clear, of course",             .adjective,   nil),
            ("difícil",     "difficult",                    .adjective,   nil),
            ("fácil",       "easy",                         .adjective,   nil),
            ("joven",       "young",                        .adjective,   nil),
            ("alto",        "tall, high",                   .adjective,   nil),

            ("largo",       "long",                         .adjective,   nil),
            ("corto",       "short (length)",               .adjective,   nil),
            ("fuerte",      "strong",                       .adjective,   nil),
            ("débil",       "weak",                         .adjective,   nil),
            ("rápido",      "fast, quick",                  .adjective,   nil),
            ("lento",       "slow",                         .adjective,   nil),
            ("caliente",    "hot",                          .adjective,   nil),
            ("frío",        "cold",                         .adjective,   nil),
            ("dulce",       "sweet",                        .adjective,   nil),
            ("salado",      "salty",                        .adjective,   nil),
            ("picante",     "spicy",                        .adjective,   nil),
            ("rico",        "rich, delicious",              .adjective,   nil),
            ("pobre",       "poor",                         .adjective,   nil),
            ("hermoso",     "beautiful",                    .adjective,   nil),
            ("bonito",      "pretty, nice",                 .adjective,   nil),
            ("feo",         "ugly",                         .adjective,   nil),
            ("limpio",      "clean",                        .adjective,   nil),
            ("sucio",       "dirty",                        .adjective,   nil),
            ("lleno",       "full",                         .adjective,   nil),
            ("vacío",       "empty",                        .adjective,   nil),
            ("duro",        "hard",                         .adjective,   nil),
            ("suave",       "soft, smooth",                 .adjective,   nil),
            ("feliz",       "happy",                        .adjective,   nil),
            ("triste",      "sad",                          .adjective,   nil),
            ("enojado",     "angry",                        .adjective,   nil),
            ("asustado",    "scared",                       .adjective,   nil),
            ("cansado",     "tired",                        .adjective,   nil),
            ("enfermo",     "sick, ill",                    .adjective,   nil),
            ("sano",        "healthy",                      .adjective,   nil),
            ("tranquilo",   "calm, quiet",                  .adjective,   nil),
            ("nervioso",    "nervous",                      .adjective,   nil),
            ("seguro",      "safe, sure",                   .adjective,   nil),
            ("peligroso",   "dangerous",                    .adjective,   nil),
            ("verdadero",   "true, real",                   .adjective,   nil),
            ("falso",       "false",                        .adjective,   nil),
            ("listo",       "ready, smart",                 .adjective,   nil),
            ("tonto",       "foolish, silly",               .adjective,   nil),
            ("inteligente", "intelligent, smart",           .adjective,   nil),
            ("amable",      "kind, friendly",               .adjective,   nil),
            ("simpático",   "likable, nice",                .adjective,   nil),
            ("interesante", "interesting",                  .adjective,   nil),
            ("aburrido",    "boring, bored",                .adjective,   nil),
            ("chido",       "cool (Mexican slang)",         .adjective,   nil),


            ("libre",       "free",                         .adjective,   nil),
            ("pesado",      "heavy, annoying",              .adjective,   nil),
            ("ligero",      "light (weight)",               .adjective,   nil),
            ("fresco",      "fresh, cool",                  .adjective,   nil),

            // ── RANK 271–320  Body, home, city nouns ──────────────────────────
            ("cuerpo",      "body",                         .noun,        "m"),
            ("cabeza",      "head",                         .noun,        "f"),
            ("cara",        "face",                         .noun,        "f"),
            ("ojo",         "eye",                          .noun,        "m"),
            ("boca",        "mouth",                        .noun,        "f"),
            ("nariz",       "nose",                         .noun,        "f"),
            ("oreja",       "ear",                          .noun,        "f"),
            ("mano",        "hand",                         .noun,        "f"),
            ("brazo",       "arm",                          .noun,        "m"),
            ("pierna",      "leg",                          .noun,        "f"),
            ("pie",         "foot",                         .noun,        "m"),
            ("corazón",     "heart",                        .noun,        "m"),
            ("cerebro",     "brain",                        .noun,        "m"),
            ("voz",         "voice",                        .noun,        "f"),
            ("sangre",      "blood",                        .noun,        "f"),

            ("cuarto",      "room, bedroom",                .noun,        "m"),
            ("baño",        "bathroom",                     .noun,        "m"),
            ("cocina",      "kitchen",                      .noun,        "f"),
            ("sala",        "living room",                  .noun,        "f"),
            ("ventana",     "window",                       .noun,        "f"),
            ("puerta",      "door",                         .noun,        "f"),
            ("piso",        "floor, story",                 .noun,        "m"),
            ("techo",       "ceiling, roof",                .noun,        "m"),
            ("jardín",      "garden, yard",                 .noun,        "m"),
            ("calle",       "street",                       .noun,        "f"),
            ("avenida",     "avenue",                       .noun,        "f"),
            ("esquina",     "corner",                       .noun,        "f"),
            ("colonia",     "neighborhood",                 .noun,        "f"),
            ("barrio",      "neighborhood, district",       .noun,        "m"),
            ("mercado",     "market",                       .noun,        "m"),
            ("tienda",      "store, shop",                  .noun,        "f"),
            ("banco",       "bank",                         .noun,        "m"),
            ("hospital",    "hospital",                     .noun,        "m"),
            ("escuela",     "school",                       .noun,        "f"),
            ("iglesia",     "church",                       .noun,        "f"),
            ("parque",      "park",                         .noun,        "m"),
            ("plaza",       "square, plaza",                .noun,        "f"),
            ("tianguis",    "open-air market (Mexican)",    .noun,        "m"),
            ("zócalo",      "town square (Mexican)",        .noun,        "m"),

            // ── RANK 321–380  Food & drink nouns (Mexican focused) ────────────
            ("comida",      "food, meal",                   .noun,        "f"),

            ("café",        "coffee",                       .noun,        "m"),
            ("leche",       "milk",                         .noun,        "f"),
            ("jugo",        "juice",                        .noun,        "m"),
            ("cerveza",     "beer",                         .noun,        "f"),
            ("vino",        "wine",                         .noun,        "m"),
            ("pan",         "bread",                        .noun,        "m"),
            ("arroz",       "rice",                         .noun,        "m"),
            ("frijol",      "bean",                         .noun,        "m"),
            ("chile",       "chili pepper",                 .noun,        "m"),
            ("carne",       "meat",                         .noun,        "f"),
            ("pollo",       "chicken",                      .noun,        "m"),
            ("pescado",     "fish (food)",                  .noun,        "m"),
            ("fruta",       "fruit",                        .noun,        "f"),
            ("verdura",     "vegetable",                    .noun,        "f"),
            ("papa",        "potato",                       .noun,        "f"),
            ("jitomate",    "tomato (Mexican)",             .noun,        "m"),
            ("limón",       "lime / lemon",                 .noun,        "m"),
            ("naranja",     "orange",                       .noun,        "f"),
            ("mango",       "mango",                        .noun,        "m"),
            ("aguacate",    "avocado",                      .noun,        "m"),
            ("cebolla",     "onion",                        .noun,        "f"),
            ("ajo",         "garlic",                       .noun,        "m"),
            ("tortilla",    "tortilla",                     .noun,        "f"),
            ("taco",        "taco",                         .noun,        "m"),
            ("salsa",       "sauce, salsa",                 .noun,        "f"),
            ("elote",       "corn on the cob (Mexican)",    .noun,        "m"),
            ("tamal",       "tamale",                       .noun,        "m"),
            ("torta",       "sandwich (Mexican)",           .noun,        "f"),
            ("quesadilla",  "quesadilla",                   .noun,        "f"),
            ("antojo",      "snack, craving",               .noun,        "m"),

            // ── RANK 381–430  Transport, technology, daily nouns ──────────────
            ("carro",       "car (Mexican)",                .noun,        "m"),
            ("camión",      "bus / truck (Mexican)",        .noun,        "m"),
            ("avión",       "airplane",                     .noun,        "m"),
            ("tren",        "train",                        .noun,        "m"),
            ("taxi",        "taxi",                         .noun,        "m"),
            ("metro",       "subway, metro",                .noun,        "m"),
            ("moto",        "motorcycle",                   .noun,        "f"),
            ("aeropuerto",  "airport",                      .noun,        "m"),
            ("estación",    "station",                      .noun,        "f"),
            ("celular",     "cell phone (Mexican)",         .noun,        "m"),
            ("computadora", "computer",                     .noun,        "f"),
            ("pantalla",    "screen",                       .noun,        "f"),
            ("internet",    "internet",                     .noun,        "m"),
            ("aplicación",  "app, application",             .noun,        "f"),
            ("correo",      "email, mail",                  .noun,        "m"),
            ("mensaje",     "message",                      .noun,        "m"),
            ("foto",        "photo",                        .noun,        "f"),
            ("música",      "music",                        .noun,        "f"),
            ("película",    "movie, film",                  .noun,        "f"),
            ("canción",     "song",                         .noun,        "f"),
            ("libro",       "book",                         .noun,        "m"),
            ("noticia",     "news item",                    .noun,        "f"),
            ("deporte",     "sport",                        .noun,        "m"),
            ("fútbol",      "soccer",                       .noun,        "m"),
            ("partido",     "match, game",                  .noun,        "m"),
            ("equipo",      "team",                         .noun,        "m"),
            ("ropa",        "clothing",                     .noun,        "f"),
            ("camisa",      "shirt",                        .noun,        "f"),
            ("pantalón",    "pants",                        .noun,        "m"),
            ("zapato",      "shoe",                         .noun,        "m"),

            // ── RANK 431–490  Nature, time, abstract nouns ────────────────────
            ("sol",         "sun",                          .noun,        "m"),
            ("luna",        "moon",                         .noun,        "f"),
            ("cielo",       "sky",                          .noun,        "m"),
            ("tierra",      "earth, land, ground",          .noun,        "f"),
            ("mar",         "sea",                          .noun,        "m"),
            ("río",         "river",                        .noun,        "m"),
            ("lago",        "lake",                         .noun,        "m"),
            ("montaña",     "mountain",                     .noun,        "f"),
            ("playa",       "beach",                        .noun,        "f"),
            ("árbol",       "tree",                         .noun,        "m"),
            ("flor",        "flower",                       .noun,        "f"),
            ("animal",      "animal",                       .noun,        "m"),
            ("perro",       "dog",                          .noun,        "m"),
            ("gato",        "cat",                          .noun,        "m"),
            ("pájaro",      "bird",                         .noun,        "m"),
            ("luz",         "light",                        .noun,        "f"),
            ("color",       "color",                        .noun,        "m"),
            ("sonido",      "sound",                        .noun,        "m"),
            ("historia",    "history, story",               .noun,        "f"),
            ("gobierno",    "government",                   .noun,        "m"),
            ("empresa",     "company, business",            .noun,        "f"),

            ("sueldo",      "salary, wage",                 .noun,        "m"),
            ("precio",      "price",                        .noun,        "m"),

            ("cuenta",      "bill, account",                .noun,        "f"),
            ("semáforo",    "traffic light",                .noun,        "m"),
            ("carretera",   "highway",                      .noun,        "f"),
            ("puente",      "bridge",                       .noun,        "m"),
            ("banqueta",    "sidewalk (Mexican)",           .noun,        "f"),

            // ── RANK 491–550  More verbs ──────────────────────────────────────
            ("vender",      "to sell",                      .infinitive,  nil),
            ("subir",       "to go up, to upload",          .infinitive,  nil),
            ("bajar",       "to go down, to download",      .infinitive,  nil),
            ("cambiar",     "to change",                    .infinitive,  nil),
            ("ganar",       "to win, to earn",              .infinitive,  nil),
            ("perder",      "to lose",                      .infinitive,  nil),
            ("aprender",    "to learn",                     .infinitive,  nil),
            ("enseñar",     "to teach",                     .infinitive,  nil),
            ("cantar",      "to sing",                      .infinitive,  nil),
            ("bailar",      "to dance",                     .infinitive,  nil),
            ("cocinar",     "to cook",                      .infinitive,  nil),
            ("limpiar",     "to clean",                     .infinitive,  nil),
            ("manejar",     "to drive (Mexican)",           .infinitive,  nil),
            ("volar",       "to fly",                       .infinitive,  nil),
            ("nadar",       "to swim",                      .infinitive,  nil),
            ("jugar",       "to play",                      .infinitive,  nil),
            ("ayudar",      "to help",                      .infinitive,  nil),
            ("olvidar",     "to forget",                    .infinitive,  nil),
            ("recordar",    "to remember",                  .infinitive,  nil),
            ("esperar",     "to wait, to hope",             .infinitive,  nil),
            ("terminar",    "to finish, to end",            .infinitive,  nil),
            ("empezar",     "to begin, to start",           .infinitive,  nil),
            ("pagar",       "to pay",                       .infinitive,  nil),
            ("intentar",    "to try",                       .infinitive,  nil),
            ("lograr",      "to achieve, to manage to",     .infinitive,  nil),
            ("conseguir",   "to get, to obtain",            .infinitive,  nil),
            ("mostrar",     "to show",                      .infinitive,  nil),
            ("traer",       "to bring",                     .infinitive,  nil),
            ("caer",        "to fall",                      .infinitive,  nil),
            ("cortar",      "to cut",                       .infinitive,  nil),
            ("construir",   "to build",                     .infinitive,  nil),
            ("crear",       "to create",                    .infinitive,  nil),
            ("estudiar",    "to study",                     .infinitive,  nil),
            ("explicar",    "to explain",                   .infinitive,  nil),
            ("presentar",   "to present, to introduce",     .infinitive,  nil),
            ("preguntar",   "to ask (a question)",          .infinitive,  nil),
            ("responder",   "to answer, to respond",        .infinitive,  nil),
            ("amar",        "to love",                      .infinitive,  nil),
            ("reír",        "to laugh",                     .infinitive,  nil),
            ("llorar",      "to cry",                       .infinitive,  nil),
            ("gritar",      "to shout, to scream",          .infinitive,  nil),
            ("cuidar",      "to take care of",              .infinitive,  nil),
            ("descansar",   "to rest",                      .infinitive,  nil),
            ("relajar",     "to relax",                     .infinitive,  nil),
            ("preocupar",   "to worry",                     .infinitive,  nil),
            ("celebrar",    "to celebrate",                 .infinitive,  nil),
            ("platicar",    "to chat, to talk (Mexican)",   .infinitive,  nil),
            ("agarrar",     "to grab, to take (Mexican)",   .infinitive,  nil),
            ("regresar",    "to return, to go back",        .infinitive,  nil),
            ("saludar",     "to greet",                     .infinitive,  nil),
            ("invitar",     "to invite",                    .infinitive,  nil),
            ("aceptar",     "to accept",                    .infinitive,  nil),
            ("rechazar",    "to reject",                    .infinitive,  nil),
            ("prometer",    "to promise",                   .infinitive,  nil),
            ("imaginar",    "to imagine",                   .infinitive,  nil),
            ("soñar",       "to dream",                     .infinitive,  nil),
            ("curar",       "to cure, to heal",             .infinitive,  nil),
            ("proteger",    "to protect",                   .infinitive,  nil),
            ("mejorar",     "to improve",                   .infinitive,  nil),
            ("desarrollar", "to develop",                   .infinitive,  nil),
            ("organizar",   "to organize",                  .infinitive,  nil),
            ("planear",     "to plan",                      .infinitive,  nil),
            ("decidir",     "to decide",                    .infinitive,  nil),
            ("elegir",      "to choose",                    .infinitive,  nil),
            ("comparar",    "to compare",                   .infinitive,  nil),
            ("revisar",     "to check, to review",          .infinitive,  nil),
            ("probar",      "to try, to taste, to test",    .infinitive,  nil),

            // ── RANK 551–630  Additional adverbs, adjectives, nouns ───────────
            ("pronto",      "soon",                         .adverb,      nil),
            ("tarde",       "late",                         .adverb,      nil),
            ("temprano",    "early",                        .adverb,      nil),
            ("cerca",       "near, close",                  .adverb,      nil),
            ("lejos",       "far",                          .adverb,      nil),
            ("arriba",      "above, up",                    .adverb,      nil),
            ("abajo",       "below, down",                  .adverb,      nil),
            ("adelante",    "forward, ahead",               .adverb,      nil),
            ("atrás",       "behind, back",                 .adverb,      nil),
            ("dentro",      "inside",                       .adverb,      nil),
            ("fuera",       "outside",                      .adverb,      nil),
            ("bastante",    "quite, enough",                .adverb,      nil),
            ("demasiado",   "too much, too many",           .adverb,      nil),
            ("quizás",      "maybe, perhaps",               .adverb,      nil),
            ("ojalá",       "hopefully, I hope",            .adverb,      nil),
            ("ahorita",     "right now / in a bit (Mex.)",  .adverb,      nil),
            ("luego",       "then, later",                  .adverb,      nil),
            ("tampoco",     "neither, not either",          .adverb,      nil),
            ("tal vez",     "maybe, perhaps",               .adverb,      nil),
            ("de repente",  "suddenly",                     .adverb,      nil),
            ("por fin",     "finally",                      .adverb,      nil),
            ("en serio",    "seriously",                    .adverb,      nil),
            ("a veces",     "sometimes",                    .adverb,      nil),
            ("de nuevo",    "again",                        .adverb,      nil),
            ("juntos",      "together",                     .adverb,      nil),
            ("moderno",     "modern",                       .adjective,   nil),
            ("antiguo",     "ancient, old",                 .adjective,   nil),
            ("famoso",      "famous",                       .adjective,   nil),
            ("extraño",     "strange, weird",               .adjective,   nil),
            ("común",       "common",                       .adjective,   nil),
            ("raro",        "rare, weird",                  .adjective,   nil),
            ("típico",      "typical",                      .adjective,   nil),
            ("especial",    "special",                      .adjective,   nil),
            ("natural",     "natural",                      .adjective,   nil),
            ("perfecto",    "perfect",                      .adjective,   nil),
            ("horrible",    "horrible, awful",              .adjective,   nil),
            ("increíble",   "incredible",                   .adjective,   nil),
            ("genial",      "great, brilliant",             .adjective,   nil),
            ("educado",     "polite, educated",             .adjective,   nil),
            ("grosero",     "rude, crude",                  .adjective,   nil),
            ("humano",      "human",                        .adjective,   nil),
            ("necesario",   "necessary",                    .adjective,   nil),
            ("completo",    "complete, full",               .adjective,   nil),

            ("reciente",    "recent",                       .adjective,   nil),
            ("siguiente",   "following, next",              .adjective,   nil),
            ("primero",     "first",                        .adjective,   nil),
            ("último",      "last",                         .adjective,   nil),
            ("mejor",       "better, best",                 .adjective,   nil),
            ("peor",        "worse, worst",                 .adjective,   nil),
            ("mayor",       "older, larger",                .adjective,   nil),
            ("menor",       "younger, smaller",             .adjective,   nil),
            ("dolor",       "pain, ache",                   .noun,        "m"),
            ("miedo",       "fear",                         .noun,        "m"),
            ("alegría",     "joy, happiness",               .noun,        "f"),
            ("orgullo",     "pride",                        .noun,        "m"),
            ("vergüenza",   "shame, embarrassment",         .noun,        "f"),
            ("confianza",   "confidence, trust",            .noun,        "f"),
            ("esperanza",   "hope",                         .noun,        "f"),
            ("suerte",      "luck",                         .noun,        "f"),
            ("sueño",       "dream, sleep",                 .noun,        "m"),
            ("hambre",      "hunger",                       .noun,        "f"),
            ("sed",         "thirst",                       .noun,        "f"),
            ("calor",       "heat",                         .noun,        "m"),

            ("ruido",       "noise",                        .noun,        "m"),
            ("silencio",    "silence",                      .noun,        "m"),
            ("libertad",    "freedom",                      .noun,        "f"),

            ("pueblo",      "town, people",                 .noun,        "m"),

            ("guerra",      "war",                          .noun,        "f"),
            ("paz",         "peace",                        .noun,        "f"),
            ("cultura",     "culture",                      .noun,        "f"),
            ("idioma",      "language",                     .noun,        "m"),
            ("español",     "Spanish (language)",           .noun,        "m"),
            ("inglés",      "English (language)",           .noun,        "m"),
            ("palabra",     "word",                         .noun,        "f"),
            ("frase",       "sentence, phrase",             .noun,        "f"),
            ("pregunta",    "question",                     .noun,        "f"),
            ("respuesta",   "answer, response",             .noun,        "f"),
            ("permiso",     "permission",                   .noun,        "m"),
            ("favor",       "favor",                        .noun,        "m"),
            ("gracias",     "thank you",                    .noun,        "f"),
            ("de nada",     "you're welcome",               .adverb,      nil),
            ("por favor",   "please",                       .adverb,      nil),
            ("con permiso", "excuse me (passing)",          .adverb,      nil),
            ("disculpa",    "excuse me, sorry",             .noun,        "f"),

            // ── NUMBERS ────────────────────────────────────────────────────────
            ("uno",         "one",                          .adjective,   "m"),
            ("dos",         "two",                          .adjective,   nil),
            ("tres",        "three",                        .adjective,   nil),
            ("cuatro",      "four",                         .adjective,   nil),
            ("cinco",       "five",                         .adjective,   nil),
            ("seis",        "six",                          .adjective,   nil),
            ("siete",       "seven",                        .adjective,   nil),
            ("ocho",        "eight",                        .adjective,   nil),
            ("nueve",       "nine",                         .adjective,   nil),
            ("diez",        "ten",                          .adjective,   nil),
            ("veinte",      "twenty",                       .adjective,   nil),
            ("cien",        "one hundred",                  .adjective,   nil),
            ("mil",         "one thousand",                 .adjective,   nil),

            ("segundo",     "second",                       .adjective,   "m"),
            ("tercero",     "third",                        .adjective,   "m"),


            ("anterior",    "previous",                     .adjective,   nil),

            // ── DAYS OF THE WEEK ───────────────────────────────────────────────
            ("lunes",       "Monday",                       .noun,        "m"),
            ("martes",      "Tuesday",                      .noun,        "m"),
            ("miércoles",   "Wednesday",                    .noun,        "m"),
            ("jueves",      "Thursday",                     .noun,        "m"),
            ("viernes",     "Friday",                       .noun,        "m"),
            ("sábado",      "Saturday",                     .noun,        "m"),
            ("domingo",     "Sunday",                       .noun,        "m"),

            ("fin de semana","weekend",                     .noun,        "m"),

            // ── MONTHS ─────────────────────────────────────────────────────────
            ("enero",       "January",                      .noun,        "m"),
            ("febrero",     "February",                     .noun,        "m"),
            ("marzo",       "March",                        .noun,        "m"),
            ("abril",       "April",                        .noun,        "m"),
            ("mayo",        "May",                          .noun,        "m"),
            ("junio",       "June",                         .noun,        "m"),
            ("julio",       "July",                         .noun,        "m"),
            ("agosto",      "August",                       .noun,        "m"),
            ("septiembre",  "September",                    .noun,        "m"),
            ("octubre",     "October",                      .noun,        "m"),
            ("noviembre",   "November",                     .noun,        "m"),
            ("diciembre",   "December",                     .noun,        "m"),

            // ── TIME & DATES ───────────────────────────────────────────────────



            ("anteayer",    "the day before yesterday",     .adverb,      nil),




            ("medianoche",  "midnight",                     .noun,        "f"),
            ("mediodía",    "noon",                         .noun,        "m"),
            ("amanecer",    "to dawn, sunrise",             .infinitive,  nil),
            ("atardecer",   "to get dark, sunset",          .infinitive,  nil),



            ("minuto",      "minute",                       .noun,        "m"),

            ("siglo",       "century",                      .noun,        "m"),
            ("fecha",       "date",                         .noun,        "f"),
            ("plazo",       "deadline, term",               .noun,        "m"),
            ("durar",       "to last",                      .infinitive,  nil),
            ("tardar",      "to take time, to be late",     .infinitive,  nil),

            // ── SCHOOL & EDUCATION ─────────────────────────────────────────────

            ("universidad", "university",                   .noun,        "f"),
            ("prepa",       "high school (MX)",             .noun,        "f"),
            ("secundaria",  "middle school",                .noun,        "f"),
            ("primaria",    "elementary school",            .noun,        "f"),
            ("maestro",     "teacher",                      .noun,        "m"),
            ("maestra",     "teacher (f)",                  .noun,        "f"),
            ("alumno",      "student",                      .noun,        "m"),
            ("alumna",      "student (f)",                  .noun,        "f"),
            ("clase",       "class",                        .noun,        "f"),
            ("lección",     "lesson",                       .noun,        "f"),
            ("tarea",       "homework",                     .noun,        "f"),
            ("examen",      "exam",                         .noun,        "m"),
            ("calificación","grade",                        .noun,        "f"),
            ("cuaderno",    "notebook",                     .noun,        "m"),
            ("lápiz",       "pencil",                       .noun,        "m"),
            ("pluma",       "pen (MX)",                     .noun,        "f"),
            ("borrador",    "eraser",                       .noun,        "m"),
            ("mochila",     "backpack",                     .noun,        "f"),
            ("biblioteca",  "library",                      .noun,        "f"),
            ("laboratorio", "laboratory",                   .noun,        "m"),
            ("recreo",      "recess, break",                .noun,        "m"),



            ("repasar",     "to review",                    .infinitive,  nil),
            ("reprobar",    "to fail (a class)",            .infinitive,  nil),
            ("aprobar",     "to pass (a class)",            .infinitive,  nil),
            ("investigar",  "to research",                  .infinitive,  nil),

            // ── HEALTH & BODY ──────────────────────────────────────────────────
            ("salud",       "health",                       .noun,        "f"),
            ("enfermedad",  "illness",                      .noun,        "f"),
            ("doctor",      "doctor",                       .noun,        "m"),
            ("doctora",     "doctor (f)",                   .noun,        "f"),
            ("médico",      "physician",                    .noun,        "m"),
            ("enfermero",   "nurse",                        .noun,        "m"),

            ("clínica",     "clinic",                       .noun,        "f"),
            ("farmacia",    "pharmacy",                     .noun,        "f"),
            ("medicina",    "medicine",                     .noun,        "f"),
            ("pastilla",    "pill",                         .noun,        "f"),
            ("receta",      "prescription, recipe",         .noun,        "f"),

            ("fiebre",      "fever",                        .noun,        "f"),
            ("tos",         "cough",                        .noun,        "f"),
            ("gripa",       "cold, flu (MX)",               .noun,        "f"),
            ("herida",      "wound",                        .noun,        "f"),
            ("operación",   "operation",                    .noun,        "f"),

            ("hueso",       "bone",                         .noun,        "m"),
            ("músculo",     "muscle",                       .noun,        "m"),

            ("pulmón",      "lung",                         .noun,        "m"),
            ("estómago",    "stomach",                      .noun,        "m"),
            ("hígado",      "liver",                        .noun,        "m"),





            ("diente",      "tooth",                        .noun,        "m"),
            ("labio",       "lip",                          .noun,        "m"),
            ("lengua",      "tongue, language",             .noun,        "f"),
            ("garganta",    "throat",                       .noun,        "f"),
            ("hombro",      "shoulder",                     .noun,        "m"),
            ("codo",        "elbow",                        .noun,        "m"),
            ("muñeca",      "wrist",                        .noun,        "f"),
            ("dedo",        "finger",                       .noun,        "m"),
            ("uña",         "fingernail",                   .noun,        "f"),
            ("rodilla",     "knee",                         .noun,        "f"),
            ("tobillo",     "ankle",                        .noun,        "m"),
            ("enfermarse",  "to get sick",                  .infinitive,  nil),

            ("doler",       "to hurt",                      .infinitive,  nil),
            ("respirar",    "to breathe",                   .infinitive,  nil),

            ("adelgazar",   "to lose weight",               .infinitive,  nil),
            ("engordar",    "to gain weight",               .infinitive,  nil),
            ("saludable",   "healthy",                      .adjective,   nil),


            ("herido",      "injured",                      .adjective,   "m"),



            // ── PROFESSIONS & WORK ─────────────────────────────────────────────

            ("empleo",      "employment",                   .noun,        "m"),
            ("oficio",      "trade, occupation",            .noun,        "m"),
            ("profesión",   "profession",                   .noun,        "f"),

            ("jefe",        "boss",                         .noun,        "m"),
            ("jefa",        "boss (f)",                     .noun,        "f"),
            ("empleado",    "employee",                     .noun,        "m"),

            ("negocio",     "business",                     .noun,        "m"),
            ("oficina",     "office",                       .noun,        "f"),
            ("reunión",     "meeting",                      .noun,        "f"),
            ("contrato",    "contract",                     .noun,        "m"),
            ("abogado",     "lawyer",                       .noun,        "m"),
            ("ingeniero",   "engineer",                     .noun,        "m"),
            ("arquitecto",  "architect",                    .noun,        "m"),
            ("contador",    "accountant",                   .noun,        "m"),
            ("cocinero",    "cook",                         .noun,        "m"),
            ("mesero",      "waiter (MX)",                  .noun,        "m"),
            ("mesera",      "waitress (MX)",                .noun,        "f"),
            ("chofer",      "driver",                       .noun,        "m"),
            ("policía",     "police officer",               .noun,        "m"),
            ("bombero",     "firefighter",                  .noun,        "m"),
            ("soldado",     "soldier",                      .noun,        "m"),
            ("periodista",  "journalist",                   .noun,        nil),
            ("artista",     "artist",                       .noun,        nil),
            ("músico",      "musician",                     .noun,        "m"),
            ("actor",       "actor",                        .noun,        "m"),
            ("actriz",      "actress",                      .noun,        "f"),
            ("político",    "politician",                   .noun,        "m"),
            ("científico",  "scientist",                    .noun,        "m"),

            ("contratar",   "to hire",                      .infinitive,  nil),
            ("renunciar",   "to quit",                      .infinitive,  nil),
            ("jubilarse",   "to retire",                    .infinitive,  nil),

            // ── ANIMALS ────────────────────────────────────────────────────────



            ("caballo",     "horse",                        .noun,        "m"),
            ("vaca",        "cow",                          .noun,        "f"),
            ("cerdo",       "pig",                          .noun,        "m"),


            ("pez",         "fish",                         .noun,        "m"),
            ("serpiente",   "snake",                        .noun,        "f"),
            ("rana",        "frog",                         .noun,        "f"),
            ("tortuga",     "turtle",                       .noun,        "f"),
            ("araña",       "spider",                       .noun,        "f"),
            ("abeja",       "bee",                          .noun,        "f"),
            ("mariposa",    "butterfly",                    .noun,        "f"),
            ("hormiga",     "ant",                          .noun,        "f"),
            ("mosca",       "fly (insect)",                 .noun,        "f"),
            ("ratón",       "mouse",                        .noun,        "m"),
            ("conejo",      "rabbit",                       .noun,        "m"),
            ("burro",       "donkey",                       .noun,        "m"),
            ("toro",        "bull",                         .noun,        "m"),
            ("oveja",       "sheep",                        .noun,        "f"),
            ("cabra",       "goat",                         .noun,        "f"),
            ("lobo",        "wolf",                         .noun,        "m"),
            ("oso",         "bear",                         .noun,        "m"),
            ("tigre",       "tiger",                        .noun,        "m"),
            ("león",        "lion",                         .noun,        "m"),
            ("águila",      "eagle",                        .noun,        "f"),
            ("loro",        "parrot",                       .noun,        "m"),
            ("delfín",      "dolphin",                      .noun,        "m"),
            ("ballena",     "whale",                        .noun,        "f"),
            ("tiburón",     "shark",                        .noun,        "m"),
            ("cocodrilo",   "crocodile",                    .noun,        "m"),
            ("jaguar",      "jaguar",                       .noun,        "m"),
            ("coyote",      "coyote",                       .noun,        "m"),
            ("guajolote",   "turkey (MX)",                  .noun,        "m"),

            // ── NATURE & ENVIRONMENT ───────────────────────────────────────────
            ("naturaleza",  "nature",                       .noun,        "f"),
            ("medio ambiente","environment",                .noun,        "m"),
            ("contaminación","pollution",                   .noun,        "f"),
            ("clima",       "climate",                      .noun,        "m"),
            ("suelo",       "ground, soil",                 .noun,        "m"),
            ("roca",        "rock",                         .noun,        "f"),
            ("volcán",      "volcano",                      .noun,        "m"),
            ("terremoto",   "earthquake",                   .noun,        "m"),
            ("huracán",     "hurricane",                    .noun,        "m"),
            ("tormenta",    "storm",                        .noun,        "f"),
            ("relámpago",   "lightning",                    .noun,        "m"),
            ("trueno",      "thunder",                      .noun,        "m"),
            ("inundación",  "flood",                        .noun,        "f"),
            ("sequía",      "drought",                      .noun,        "f"),
            ("selva",       "jungle",                       .noun,        "f"),
            ("desierto",    "desert",                       .noun,        "m"),
            ("pradera",     "meadow, prairie",              .noun,        "f"),
            ("isla",        "island",                       .noun,        "f"),
            ("costa",       "coast",                        .noun,        "f"),
            ("orilla",      "shore, bank (river)",          .noun,        "f"),


            ("planta",      "plant",                        .noun,        "f"),
            ("hierba",      "grass, herb",                  .noun,        "f"),
            ("semilla",     "seed",                         .noun,        "f"),
            ("raíz",        "root",                         .noun,        "f"),
            ("hoja",        "leaf",                         .noun,        "f"),
            ("rama",        "branch",                       .noun,        "f"),
            ("tronco",      "trunk",                        .noun,        "m"),


            ("manzana",     "apple",                        .noun,        "f"),


            ("plátano",     "banana",                       .noun,        "m"),
            ("sandía",      "watermelon",                   .noun,        "f"),



            ("nopal",       "cactus pad (MX)",              .noun,        "m"),
            ("tamarindo",   "tamarind",                     .noun,        "m"),
            ("guayaba",     "guava",                        .noun,        "f"),
            ("papaya",      "papaya",                       .noun,        "f"),

            // ── TECHNOLOGY ─────────────────────────────────────────────────────
            ("tecnología",  "technology",                   .noun,        "f"),


            ("teclado",     "keyboard",                     .noun,        "m"),

            ("impresora",   "printer",                      .noun,        "f"),
            ("cámara",      "camera",                       .noun,        "f"),
            ("televisión",  "television",                   .noun,        "f"),
            ("radio",       "radio",                        .noun,        "m"),
            ("micrófono",   "microphone",                   .noun,        "m"),
            ("audífonos",   "headphones",                   .noun,        "m"),
            ("bocina",      "speaker (MX)",                 .noun,        "f"),
            ("red",         "network",                      .noun,        "f"),


            ("contraseña",  "password",                     .noun,        "f"),

            ("página web",  "web page",                     .noun,        "f"),
            ("archivo",     "file",                         .noun,        "m"),
            ("carpeta",     "folder",                       .noun,        "f"),
            ("descarga",    "download",                     .noun,        "f"),
            ("carga",       "upload, load",                 .noun,        "f"),
            ("batería",     "battery",                      .noun,        "f"),
            ("cable",       "cable",                        .noun,        "m"),
            ("enchufe",     "plug, socket",                 .noun,        "m"),
            ("descargar",   "to download",                  .infinitive,  nil),
            ("cargar",      "to charge, to upload",         .infinitive,  nil),
            ("instalar",    "to install",                   .infinitive,  nil),
            ("guardar",     "to save",                      .infinitive,  nil),
            ("borrar",      "to delete, to erase",          .infinitive,  nil),
            ("conectar",    "to connect",                   .infinitive,  nil),
            ("programar",   "to program, to schedule",      .infinitive,  nil),
            ("diseñar",     "to design",                    .infinitive,  nil),

            // ── EMOTIONS & PERSONALITY ─────────────────────────────────────────
            ("emoción",     "emotion",                      .noun,        "f"),
            ("sentimiento", "feeling",                      .noun,        "m"),

            ("tristeza",    "sadness",                      .noun,        "f"),

            ("enojo",       "anger (MX)",                   .noun,        "m"),


            ("celos",       "jealousy",                     .noun,        "m"),

            ("duda",        "doubt",                        .noun,        "f"),

            ("sorpresa",    "surprise",                     .noun,        "f"),
            ("soledad",     "loneliness",                   .noun,        "f"),
            ("ánimo",       "spirit, mood",                 .noun,        "m"),
            ("calma",       "calm",                         .noun,        "f"),
            ("estrés",      "stress",                       .noun,        "m"),



            ("emocionado",  "excited",                      .adjective,   "m"),



            ("avergonzado", "embarrassed",                  .adjective,   "m"),
            ("orgulloso",   "proud",                        .adjective,   "m"),
            ("celoso",      "jealous",                      .adjective,   "m"),
            ("confundido",  "confused",                     .adjective,   "m"),

            ("sincero",     "sincere",                      .adjective,   "m"),
            ("honesto",     "honest",                       .adjective,   "m"),

            ("generoso",    "generous",                     .adjective,   "m"),
            ("egoísta",     "selfish",                      .adjective,   nil),
            ("paciente",    "patient",                      .adjective,   nil),
            ("impaciente",  "impatient",                    .adjective,   nil),
            ("curioso",     "curious",                      .adjective,   "m"),

            ("creativo",    "creative",                     .adjective,   "m"),
            ("responsable", "responsible",                  .adjective,   nil),
            ("flojo",       "lazy (MX)",                    .adjective,   "m"),



            ("sonreír",     "to smile",                     .infinitive,  nil),

            ("animar",      "to encourage",                 .infinitive,  nil),
            ("asustar",     "to frighten",                  .infinitive,  nil),
            ("enojar",      "to anger",                     .infinitive,  nil),
            ("calmar",      "to calm",                      .infinitive,  nil),
            ("extrañar",    "to miss",                      .infinitive,  nil),

            // ── CLOTHING & FASHION ─────────────────────────────────────────────


            ("camiseta",    "t-shirt",                      .noun,        "f"),

            ("falda",       "skirt",                        .noun,        "f"),
            ("vestido",     "dress",                        .noun,        "m"),
            ("suéter",      "sweater",                      .noun,        "m"),
            ("chamarra",    "jacket (MX)",                  .noun,        "f"),
            ("abrigo",      "coat",                         .noun,        "m"),

            ("tenis",       "sneakers (MX)",                .noun,        "m"),
            ("bota",        "boot",                         .noun,        "f"),
            ("calcetín",    "sock",                         .noun,        "m"),
            ("calceta",     "sock (MX)",                    .noun,        "f"),
            ("calzón",      "underwear (MX)",               .noun,        "m"),
            ("brasier",     "bra (MX)",                     .noun,        "m"),
            ("cinturón",    "belt",                         .noun,        "m"),
            ("bolsa",       "bag, purse",                   .noun,        "f"),
            ("cartera",     "wallet",                       .noun,        "f"),
            ("sombrero",    "hat",                          .noun,        "m"),
            ("gorra",       "cap",                          .noun,        "f"),
            ("bufanda",     "scarf",                        .noun,        "f"),
            ("guante",      "glove",                        .noun,        "m"),
            ("lentes",      "glasses (MX)",                 .noun,        "m"),
            ("joya",        "jewel",                        .noun,        "f"),
            ("collar",      "necklace",                     .noun,        "m"),
            ("arête",       "earring (MX)",                 .noun,        "m"),
            ("anillo",      "ring",                         .noun,        "m"),
            ("pulsera",     "bracelet",                     .noun,        "f"),
            ("ponerse",     "to put on (clothing)",         .infinitive,  nil),
            ("quitarse",    "to take off (clothing)",       .infinitive,  nil),
            ("vestirse",    "to get dressed",               .infinitive,  nil),

            // ── COOKING & FOOD PREPARATION ─────────────────────────────────────

            ("hornear",     "to bake",                      .infinitive,  nil),
            ("freír",       "to fry",                       .infinitive,  nil),
            ("hervir",      "to boil",                      .infinitive,  nil),
            ("mezclar",     "to mix",                       .infinitive,  nil),

            ("picar",       "to chop, to sting",            .infinitive,  nil),
            ("pelar",       "to peel",                      .infinitive,  nil),
            ("sazonar",     "to season",                    .infinitive,  nil),
            ("sal",         "salt",                         .noun,        "f"),
            ("azúcar",      "sugar",                        .noun,        "m"),
            ("aceite",      "oil",                          .noun,        "m"),
            ("vinagre",     "vinegar",                      .noun,        "m"),
            ("harina",      "flour",                        .noun,        "f"),
            ("huevo",       "egg",                          .noun,        "m"),
            ("queso",       "cheese",                       .noun,        "m"),
            ("crema",       "cream, sour cream",            .noun,        "f"),
            ("mantequilla", "butter",                       .noun,        "f"),


            ("sopa",        "soup",                         .noun,        "f"),
            ("caldo",       "broth",                        .noun,        "m"),

            ("mole",        "mole sauce (MX)",              .noun,        "m"),
            ("tamale",      "tamale",                       .noun,        "m"),

            ("tostada",     "tostada",                      .noun,        "f"),
            ("enchilada",   "enchilada",                    .noun,        "f"),
            ("pozole",      "hominy stew (MX)",             .noun,        "m"),
            ("menudo",      "tripe soup (MX)",              .noun,        "m"),
            ("atole",       "corn drink (MX)",              .noun,        "m"),
            ("horchata",    "rice water drink",             .noun,        "f"),
            ("aguas frescas","fresh fruit water (MX)",      .noun,        "f"),
            ("michelada",   "beer cocktail (MX)",           .noun,        "f"),

            // ── URBAN LIFE & PLACES (MX) ───────────────────────────────────────
            ("cuadra",      "city block (MX)",              .noun,        "f"),


            ("señal",       "sign, signal",                 .noun,        "f"),

            ("túnel",       "tunnel",                       .noun,        "m"),



            ("estadio",     "stadium",                      .noun,        "m"),
            ("cine",        "movie theater",                .noun,        "m"),
            ("teatro",      "theater",                      .noun,        "m"),
            ("museo",       "museum",                       .noun,        "m"),

            ("catedral",    "cathedral",                    .noun,        "f"),
            ("templo",      "temple",                       .noun,        "m"),



            ("taxista",     "taxi driver",                  .noun,        "m"),
            ("mecánico",    "mechanic",                     .noun,        "m"),
            ("gasolinera",  "gas station (MX)",             .noun,        "f"),
            ("taller",      "workshop, repair shop",        .noun,        "m"),
            ("supermercado","supermarket",                  .noun,        "m"),


            ("panadería",   "bakery",                       .noun,        "f"),
            ("carnicería",  "butcher shop",                 .noun,        "f"),
            ("frutería",    "fruit stand",                  .noun,        "f"),
            ("taquería",    "taco stand/restaurant (MX)",   .noun,        "f"),
            ("fondita",     "small local restaurant (MX)",  .noun,        "f"),
            ("lonchería",   "snack bar (MX)",               .noun,        "f"),
            ("vecino",      "neighbor",                     .noun,        "m"),
            ("inquilino",   "tenant",                       .noun,        "m"),
            ("portero",     "doorman, janitor",             .noun,        "m"),
            ("vigilante",   "security guard",               .noun,        "m"),
            ("habitante",   "inhabitant",                   .noun,        nil),

            // ── MORE VERBS ─────────────────────────────────────────────────────
            ("apagar",      "to turn off",                  .infinitive,  nil),
            ("encender",    "to turn on, to light",         .infinitive,  nil),


            ("romper",      "to break",                     .infinitive,  nil),
            ("arreglar",    "to fix, to arrange",           .infinitive,  nil),

            ("lavar",       "to wash",                      .infinitive,  nil),
            ("planchar",    "to iron",                      .infinitive,  nil),
            ("barrer",      "to sweep",                     .infinitive,  nil),
            ("trapear",     "to mop (MX)",                  .infinitive,  nil),
            ("tirar",       "to throw, to drop",            .infinitive,  nil),
            ("recoger",     "to pick up",                   .infinitive,  nil),
            ("acomodar",    "to arrange, to put away (MX)", .infinitive,  nil),
            ("jalar",       "to pull (MX)",                 .infinitive,  nil),
            ("empujar",     "to push",                      .infinitive,  nil),



            ("girar",       "to turn, to rotate",           .infinitive,  nil),
            ("doblar",      "to fold, to turn",             .infinitive,  nil),
            ("cruzar",      "to cross",                     .infinitive,  nil),
            ("avanzar",     "to advance",                   .infinitive,  nil),
            ("retroceder",  "to go back",                   .infinitive,  nil),
            ("alejarse",    "to move away",                 .infinitive,  nil),
            ("acercarse",   "to approach",                  .infinitive,  nil),
            ("chocar",      "to crash, to collide",         .infinitive,  nil),
            ("frenar",      "to brake",                     .infinitive,  nil),
            ("acelerar",    "to accelerate",                .infinitive,  nil),
            ("estacionarse","to park",                      .infinitive,  nil),
            ("visitar",     "to visit",                     .infinitive,  nil),


            ("agradecer",   "to thank",                     .infinitive,  nil),
            ("pedir prestado","to borrow",                  .infinitive,  nil),
            ("prestar",     "to lend",                      .infinitive,  nil),
            ("ahorrar",     "to save (money)",              .infinitive,  nil),
            ("gastar",      "to spend",                     .infinitive,  nil),
            ("cobrar",      "to charge, to collect",        .infinitive,  nil),

            ("deber",       "to owe, must",                 .infinitive,  nil),
            ("calcular",    "to calculate",                 .infinitive,  nil),
            ("medir",       "to measure",                   .infinitive,  nil),
            ("pesar",       "to weigh",                     .infinitive,  nil),
            ("contar",      "to count, to tell",            .infinitive,  nil),
            ("sumar",       "to add",                       .infinitive,  nil),
            ("restar",      "to subtract",                  .infinitive,  nil),
            ("multiplicar", "to multiply",                  .infinitive,  nil),
            ("dividir",     "to divide",                    .infinitive,  nil),
            ("resolver",    "to solve",                     .infinitive,  nil),
            ("analizar",    "to analyze",                   .infinitive,  nil),



            ("opinar",      "to opine, to have an opinion", .infinitive,  nil),
            ("proponer",    "to propose",                   .infinitive,  nil),
            ("negociar",    "to negotiate",                 .infinitive,  nil),


            ("preparar",    "to prepare",                   .infinitive,  nil),
            ("publicar",    "to publish, to post",          .infinitive,  nil),
            ("compartir",   "to share",                     .infinitive,  nil),
            ("grabar",      "to record",                    .infinitive,  nil),
            ("fotografiar", "to photograph",                .infinitive,  nil),
            ("filmar",      "to film",                      .infinitive,  nil),

            ("observar",    "to observe",                   .infinitive,  nil),
            ("notar",       "to notice",                    .infinitive,  nil),

            ("controlar",   "to control",                   .infinitive,  nil),

            ("supervisar",  "to supervise",                 .infinitive,  nil),

            // ── MORE ADJECTIVES ────────────────────────────────────────────────

            ("dispuesto",   "willing",                      .adjective,   "m"),
            ("ocupado",     "busy",                         .adjective,   "m"),

            ("disponible",  "available",                    .adjective,   nil),
            ("urgente",     "urgent",                       .adjective,   nil),


            ("imposible",   "impossible",                   .adjective,   nil),
            ("probable",    "probable",                     .adjective,   nil),

            ("cierto",      "certain, true",                .adjective,   "m"),

            ("correcto",    "correct",                      .adjective,   "m"),
            ("incorrecto",  "incorrect",                    .adjective,   "m"),
            ("exacto",      "exact",                        .adjective,   "m"),

            ("oscuro",      "dark",                         .adjective,   "m"),




            ("abierto",     "open",                         .adjective,   "m"),
            ("cerrado",     "closed",                       .adjective,   "m"),
            ("roto",        "broken",                       .adjective,   "m"),
            ("entero",      "whole, entire",                .adjective,   "m"),



            ("normal",      "normal",                       .adjective,   nil),





            ("futuro",      "future",                       .adjective,   "m"),
            ("pasado",      "past",                         .adjective,   "m"),
            ("actual",      "current",                      .adjective,   nil),
            ("público",     "public",                       .adjective,   "m"),
            ("privado",     "private",                      .adjective,   "m"),
            ("oficial",     "official",                     .adjective,   nil),
            ("económico",   "economic, affordable",         .adjective,   "m"),
            ("caro",        "expensive",                    .adjective,   "m"),
            ("barato",      "cheap",                        .adjective,   "m"),


            ("exitoso",     "successful",                   .adjective,   "m"),
            ("fracasado",   "failed, unsuccessful",         .adjective,   "m"),
            ("popular",     "popular",                      .adjective,   nil),

            ("conocido",    "known, well-known",            .adjective,   "m"),
            ("desconocido", "unknown",                      .adjective,   "m"),

            // ── MORE ADVERBS ───────────────────────────────────────────────────


            ("suficiente",  "sufficient, enough",           .adverb,      nil),
            ("apenas",      "barely, just",                 .adverb,      nil),

            ("exactamente", "exactly",                      .adverb,      nil),
            ("generalmente","generally",                    .adverb,      nil),
            ("normalmente", "normally",                     .adverb,      nil),
            ("frecuentemente","frequently",                 .adverb,      nil),

            ("despacio",    "slowly",                       .adverb,      nil),

            ("aparte",      "apart, separately",            .adverb,      nil),




            ("afuera",      "outside",                      .adverb,      nil),
            ("adentro",     "inside",                       .adverb,      nil),
            ("alrededor",   "around",                       .adverb,      nil),
            ("enfrente",    "in front",                     .adverb,      nil),
            ("detrás",      "behind",                       .adverb,      nil),
            ("encima",      "on top",                       .adverb,      nil),
            ("debajo",      "underneath",                   .adverb,      nil),



            ("de verdad",   "really, truly",                .adverb,      nil),


            ("enseguida",   "right away",                   .adverb,      nil),
            ("a propósito", "on purpose",                   .adverb,      nil),
            ("sin querer",  "accidentally",                 .adverb,      nil),
            ("en cambio",   "on the other hand",            .adverb,      nil),
            ("por eso",     "that's why, therefore",        .adverb,      nil),
            ("por supuesto","of course",                    .adverb,      nil),
            ("claro que sí","of course (yes)",              .adverb,      nil),
            ("para nada",   "not at all",                   .adverb,      nil),
            ("qué tal",     "how are you, how about",       .adverb,      nil),
            ("ni modo",     "no way, can't be helped (MX)", .adverb,      nil),
            ("órale",       "okay, let's go (MX)",          .adverb,      nil),
            ("ándale",      "come on, hurry (MX)",          .adverb,      nil),
            ("híjole",      "wow, geez (MX)",               .adverb,      nil),
            ("ahorita mismo","right this instant (MX)",     .adverb,      nil),

            // ── SPORTS & RECREATION ────────────────────────────────────────────


            ("béisbol",     "baseball",                     .noun,        "m"),
            ("básquetbol",  "basketball",                   .noun,        "m"),
            ("voleibol",    "volleyball",                   .noun,        "m"),
            ("natación",    "swimming",                     .noun,        "f"),
            ("atletismo",   "track and field",              .noun,        "m"),
            ("gimnasio",    "gym",                          .noun,        "m"),
            ("cancha",      "court, field",                 .noun,        "f"),
            ("campo",       "field, countryside",           .noun,        "m"),
            ("alberca",     "swimming pool (MX)",           .noun,        "f"),
            ("pelota",      "ball",                         .noun,        "f"),
            ("balón",       "soccer ball",                  .noun,        "m"),


            ("árbitro",     "referee",                      .noun,        "m"),

            ("jugador",     "player",                       .noun,        "m"),
            ("entrenador",  "coach",                        .noun,        "m"),
            ("campeonato",  "championship",                 .noun,        "m"),
            ("torneo",      "tournament",                   .noun,        "m"),

            ("marcador",    "scoreboard, score",            .noun,        "m"),
            ("gol",         "goal",                         .noun,        "m"),

            ("entrenar",    "to train",                     .infinitive,  nil),
            ("competir",    "to compete",                   .infinitive,  nil),


            ("empatar",     "to tie",                       .infinitive,  nil),


            ("saltar",      "to jump",                      .infinitive,  nil),
            ("lanzar",      "to throw, to launch",          .infinitive,  nil),
            ("atrapar",     "to catch",                     .infinitive,  nil),
            ("patear",      "to kick",                      .infinitive,  nil),
            ("marcar",      "to score, to mark",            .infinitive,  nil),
            ("aficionado",  "fan, enthusiast",              .noun,        "m"),
            ("campeón",     "champion",                     .noun,        "m"),
            ("récord",      "record",                       .noun,        "m"),
            ("medalla",     "medal",                        .noun,        "f"),
            ("trofeo",      "trophy",                       .noun,        "m"),

            // ── MUSIC & ARTS ───────────────────────────────────────────────────


            ("letra",       "lyrics, letter",               .noun,        "f"),
            ("melodía",     "melody",                       .noun,        "f"),
            ("ritmo",       "rhythm",                       .noun,        "m"),
            ("instrumento", "instrument",                   .noun,        "m"),
            ("guitarra",    "guitar",                       .noun,        "f"),
            ("piano",       "piano",                        .noun,        "m"),
            ("violín",      "violin",                       .noun,        "m"),
            ("tambor",      "drum",                         .noun,        "m"),
            ("trompeta",    "trumpet",                      .noun,        "f"),
            ("flauta",      "flute",                        .noun,        "f"),


            ("coro",        "chorus, choir",                .noun,        "m"),
            ("cantante",    "singer",                       .noun,        nil),
            ("concierto",   "concert",                      .noun,        "m"),
            ("álbum",       "album",                        .noun,        "m"),
            ("disco",       "disk, record",                 .noun,        "m"),
            ("mariachi",    "mariachi",                     .noun,        "m"),
            ("norteño",     "norteño music",                .noun,        "m"),
            ("cumbia",      "cumbia",                       .noun,        "f"),
            ("ranchera",    "ranchera music",               .noun,        "f"),
            ("pintura",     "painting",                     .noun,        "f"),
            ("dibujo",      "drawing",                      .noun,        "m"),
            ("escultura",   "sculpture",                    .noun,        "f"),
            ("fotografía",  "photography",                  .noun,        "f"),
            ("artesanía",   "handicraft",                   .noun,        "f"),
            ("cerámica",    "ceramics",                     .noun,        "f"),
            ("bordado",     "embroidery",                   .noun,        "m"),
            ("obra",        "work (of art), play",          .noun,        "f"),
            ("pintor",      "painter",                      .noun,        "m"),
            ("escultor",    "sculptor",                     .noun,        "m"),

            ("bailarín",    "dancer",                       .noun,        "m"),
            ("bailarina",   "dancer (f)",                   .noun,        "f"),
            ("tocar",       "to play (instrument), to touch",.infinitive, nil),


            ("pintar",      "to paint",                     .infinitive,  nil),
            ("dibujar",     "to draw",                      .infinitive,  nil),
            ("esculpir",    "to sculpt",                    .infinitive,  nil),
            ("componer",    "to compose",                   .infinitive,  nil),
            ("interpretar", "to perform, to interpret",     .infinitive,  nil),

            // ── FAMILY & RELATIONSHIPS ─────────────────────────────────────────





            ("hermano",     "brother",                      .noun,        "m"),
            ("hermana",     "sister",                       .noun,        "f"),
            ("abuelo",      "grandfather",                  .noun,        "m"),
            ("abuela",      "grandmother",                  .noun,        "f"),
            ("nieto",       "grandson",                     .noun,        "m"),
            ("nieta",       "granddaughter",                .noun,        "f"),
            ("tío",         "uncle",                        .noun,        "m"),
            ("tía",         "aunt",                         .noun,        "f"),
            ("primo",       "cousin",                       .noun,        "m"),
            ("prima",       "cousin (f)",                   .noun,        "f"),
            ("sobrino",     "nephew",                       .noun,        "m"),
            ("sobrina",     "niece",                        .noun,        "f"),
            ("cuñado",      "brother-in-law",               .noun,        "m"),
            ("cuñada",      "sister-in-law",                .noun,        "f"),
            ("suegro",      "father-in-law",                .noun,        "m"),
            ("suegra",      "mother-in-law",                .noun,        "f"),
            ("yerno",       "son-in-law",                   .noun,        "m"),
            ("nuera",       "daughter-in-law",              .noun,        "f"),
            ("padrino",     "godfather",                    .noun,        "m"),
            ("madrina",     "godmother",                    .noun,        "f"),
            ("ahijado",     "godson",                       .noun,        "m"),
            ("ahijada",     "goddaughter",                  .noun,        "f"),
            ("esposo",      "husband",                      .noun,        "m"),
            ("esposa",      "wife",                         .noun,        "f"),
            ("novio",       "boyfriend",                    .noun,        "m"),
            ("novia",       "girlfriend",                   .noun,        "f"),
            ("prometido",   "fiancé",                       .noun,        "m"),
            ("prometida",   "fiancée",                      .noun,        "f"),
            ("pareja",      "partner, couple",              .noun,        "f"),



            ("compañero",   "companion, partner",           .noun,        "m"),
            ("compañera",   "companion (f)",                .noun,        "f"),
            ("casarse",     "to get married",               .infinitive,  nil),
            ("divorciarse", "to get divorced",              .infinitive,  nil),
            ("comprometerse","to get engaged",              .infinitive,  nil),
            ("nacer",       "to be born",                   .infinitive,  nil),
            ("crecer",      "to grow up",                   .infinitive,  nil),
            ("criar",       "to raise (children)",          .infinitive,  nil),
            ("heredar",     "to inherit",                   .infinitive,  nil),
            ("reunirse",    "to gather, to meet",           .infinitive,  nil),
            ("convivir",    "to socialize, live together",  .infinitive,  nil),

            // ── HOUSE & HOME ───────────────────────────────────────────────────

            ("recámara",    "bedroom (MX)",                 .noun,        "f"),

            ("comedor",     "dining room",                  .noun,        "m"),


            ("regadera",    "shower (MX)",                  .noun,        "f"),
            ("tina",        "bathtub",                      .noun,        "f"),
            ("inodoro",     "toilet",                       .noun,        "m"),
            ("lavabo",      "sink",                         .noun,        "m"),
            ("espejo",      "mirror",                       .noun,        "m"),
            ("closet",      "closet (MX)",                  .noun,        "m"),
            ("cajón",       "drawer",                       .noun,        "m"),
            ("ropero",      "wardrobe",                     .noun,        "m"),
            ("cama",        "bed",                          .noun,        "f"),
            ("colchón",     "mattress",                     .noun,        "m"),
            ("almohada",    "pillow",                       .noun,        "f"),
            ("cobija",      "blanket (MX)",                 .noun,        "f"),
            ("sábana",      "sheet",                        .noun,        "f"),
            ("sofá",        "sofa",                         .noun,        "m"),
            ("silla",       "chair",                        .noun,        "f"),
            ("sillón",      "armchair",                     .noun,        "m"),
            ("escritorio",  "desk",                         .noun,        "m"),
            ("estante",     "shelf",                        .noun,        "m"),
            ("librero",     "bookshelf (MX)",               .noun,        "m"),
            ("lámpara",     "lamp",                         .noun,        "f"),
            ("foco",        "lightbulb (MX)",               .noun,        "m"),
            ("ventilador",  "fan",                          .noun,        "m"),
            ("calentador",  "heater, water heater",         .noun,        "m"),
            ("refrigerador","refrigerator",                 .noun,        "m"),
            ("estufa",      "stove",                        .noun,        "f"),
            ("horno",       "oven",                         .noun,        "m"),
            ("microondas",  "microwave",                    .noun,        "m"),
            ("licuadora",   "blender (MX)",                 .noun,        "f"),
            ("lavadora",    "washing machine",              .noun,        "f"),
            ("secadora",    "dryer",                        .noun,        "f"),
            ("plancha",     "iron",                         .noun,        "f"),
            ("aspiradora",  "vacuum cleaner",               .noun,        "f"),
            ("escoba",      "broom",                        .noun,        "f"),
            ("trapeador",   "mop (MX)",                     .noun,        "m"),
            ("cubo",        "bucket",                       .noun,        "m"),
            ("llave",       "key, faucet",                  .noun,        "f"),
            ("cerradura",   "lock",                         .noun,        "f"),
            ("timbre",      "doorbell",                     .noun,        "m"),


            ("pared",       "wall",                         .noun,        "f"),


            ("escalera",    "staircase",                    .noun,        "f"),
            ("elevador",    "elevator (MX)",                .noun,        "m"),

            ("terraza",     "terrace",                      .noun,        "f"),
            ("bodega",      "storage room",                 .noun,        "f"),
            ("garage",      "garage",                       .noun,        "m"),
            ("vecindad",    "neighborhood, tenement (MX)",  .noun,        "f"),
            ("departamento","apartment (MX)",               .noun,        "m"),
            ("edificio",    "building",                     .noun,        "m"),

            ("planta baja", "ground floor",                 .noun,        "f"),
            ("mudarse",     "to move (residence)",          .infinitive,  nil),
            ("alquilar",    "to rent",                      .infinitive,  nil),
            ("remodelar",   "to remodel",                   .infinitive,  nil),

            // ── TRAVEL & GEOGRAPHY ─────────────────────────────────────────────
            ("viaje",       "trip, travel",                 .noun,        "m"),
            ("turista",     "tourist",                      .noun,        nil),
            ("turismo",     "tourism",                      .noun,        "m"),
            ("pasaporte",   "passport",                     .noun,        "m"),
            ("visa",        "visa",                         .noun,        "f"),
            ("boleto",      "ticket (MX)",                  .noun,        "m"),
            ("equipaje",    "luggage",                      .noun,        "m"),
            ("maleta",      "suitcase",                     .noun,        "f"),

            ("hotel",       "hotel",                        .noun,        "m"),
            ("hostal",      "hostel",                       .noun,        "m"),
            ("reservación", "reservation (MX)",             .noun,        "f"),
            ("habitación",  "room (hotel)",                 .noun,        "f"),
            ("recepción",   "reception",                    .noun,        "f"),
            ("norte",       "north",                        .noun,        "m"),
            ("sur",         "south",                        .noun,        "m"),
            ("este",        "east",                         .noun,        "m"),
            ("oeste",       "west",                         .noun,        "m"),
            ("mapa",        "map",                          .noun,        "m"),
            ("dirección",   "address, direction",           .noun,        "f"),
            ("ruta",        "route",                        .noun,        "f"),
            ("autopista",   "highway",                      .noun,        "f"),

            ("frontera",    "border",                       .noun,        "f"),
            ("aduana",      "customs",                      .noun,        "f"),

            ("capital",     "capital city",                 .noun,        "f"),
            ("estado",      "state",                        .noun,        "m"),
            ("municipio",   "municipality",                 .noun,        "m"),

            ("continente",  "continent",                    .noun,        "m"),
            ("provincia",   "province",                     .noun,        "f"),
            ("región",      "region",                       .noun,        "f"),
            ("zona",        "zone, area",                   .noun,        "f"),
            ("viajar",      "to travel",                    .infinitive,  nil),
            ("hospedarse",  "to stay (lodging)",            .infinitive,  nil),
            ("explorar",    "to explore",                   .infinitive,  nil),
            ("recorrer",    "to travel through",            .infinitive,  nil),

            // ── FINANCE & ECONOMY ──────────────────────────────────────────────

            ("billete",     "bill, banknote",               .noun,        "m"),
            ("moneda",      "coin, currency",               .noun,        "f"),

            ("costo",       "cost",                         .noun,        "m"),
            ("gasto",       "expense",                      .noun,        "m"),
            ("ingreso",     "income",                       .noun,        "m"),
            ("ahorro",      "savings",                      .noun,        "m"),
            ("deuda",       "debt",                         .noun,        "f"),
            ("préstamo",    "loan",                         .noun,        "m"),
            ("inversión",   "investment",                   .noun,        "f"),
            ("ganancia",    "profit",                       .noun,        "f"),
            ("pérdida",     "loss",                         .noun,        "f"),
            ("impuesto",    "tax",                          .noun,        "m"),
            ("factura",     "invoice, bill",                .noun,        "f"),
            ("recibo",      "receipt",                      .noun,        "m"),

            ("tarjeta",     "card",                         .noun,        "f"),

            ("cajero",      "ATM, cashier",                 .noun,        "m"),
            ("cambio",      "change, exchange",             .noun,        "m"),
            ("dólar",       "dollar",                       .noun,        "m"),
            ("peso",        "peso",                         .noun,        "m"),

            ("comercio",    "commerce, trade",              .noun,        "m"),
            ("venta",       "sale",                         .noun,        "f"),
            ("compra",      "purchase",                     .noun,        "f"),
            ("descuento",   "discount",                     .noun,        "m"),
            ("oferta",      "offer, sale",                  .noun,        "f"),
            ("presupuesto", "budget",                       .noun,        "m"),
            ("invertir",    "to invest",                    .infinitive,  nil),





            ("depositar",   "to deposit",                   .infinitive,  nil),
            ("retirar",     "to withdraw",                  .infinitive,  nil),
            ("transferir",  "to transfer",                  .infinitive,  nil),
            ("facturar",    "to invoice",                   .infinitive,  nil),
            ("cotizar",     "to quote (a price)",           .infinitive,  nil),

            ("intercambiar","to exchange",                  .infinitive,  nil),

            // ── GOVERNMENT & SOCIETY ───────────────────────────────────────────

            ("presidente",  "president",                    .noun,        "m"),
            ("presidenta",  "president (f)",                .noun,        "f"),
            ("gobernador",  "governor",                     .noun,        "m"),
            ("alcalde",     "mayor",                        .noun,        "m"),
            ("congreso",    "congress",                     .noun,        "m"),
            ("senado",      "senate",                       .noun,        "m"),
            ("senador",     "senator",                      .noun,        "m"),
            ("diputado",    "congressman",                  .noun,        "m"),
            ("ley",         "law",                          .noun,        "f"),
            ("decreto",     "decree",                       .noun,        "m"),
            ("constitución","constitution",                 .noun,        "f"),
            ("derecho",     "right, law",                   .noun,        "m"),

            ("justicia",    "justice",                      .noun,        "f"),
            ("tribunal",    "court, tribunal",              .noun,        "m"),
            ("juicio",      "trial, judgment",              .noun,        "m"),
            ("juez",        "judge",                        .noun,        "m"),
            ("fiscal",      "prosecutor",                   .noun,        "m"),
            ("preso",       "prisoner",                     .noun,        "m"),
            ("cárcel",      "jail, prison",                 .noun,        "f"),
            ("crimen",      "crime",                        .noun,        "m"),
            ("delito",      "offense, crime",               .noun,        "m"),
            ("robo",        "robbery",                      .noun,        "m"),
            ("ladrón",      "thief",                        .noun,        "m"),
            ("elección",    "election",                     .noun,        "f"),
            ("voto",        "vote",                         .noun,        "m"),

            ("campaña",     "campaign",                     .noun,        "f"),
            ("corrupción",  "corruption",                   .noun,        "f"),
            ("protesta",    "protest",                      .noun,        "f"),
            ("manifestación","demonstration",               .noun,        "f"),
            ("huelga",      "strike",                       .noun,        "f"),
            ("sociedad",    "society",                      .noun,        "f"),
            ("comunidad",   "community",                    .noun,        "f"),
            ("ciudadano",   "citizen",                      .noun,        "m"),
            ("votar",       "to vote",                      .infinitive,  nil),
            ("gobernar",    "to govern",                    .infinitive,  nil),
            ("legislar",    "to legislate",                 .infinitive,  nil),
            ("juzgar",      "to judge",                     .infinitive,  nil),
            ("protestar",   "to protest",                   .infinitive,  nil),
            ("defender",    "to defend",                    .infinitive,  nil),
            ("acusar",      "to accuse",                    .infinitive,  nil),
            ("arrestar",    "to arrest",                    .infinitive,  nil),

            // ── RELIGION & SPIRITUALITY ────────────────────────────────────────
            ("religión",    "religion",                     .noun,        "f"),
            ("dios",        "god",                          .noun,        "m"),
            ("fe",          "faith",                        .noun,        "f"),
            ("oración",     "prayer",                       .noun,        "f"),
            ("misa",        "mass (Catholic)",              .noun,        "f"),
            ("bautizo",     "baptism",                      .noun,        "m"),
            ("confirmación","confirmation",                 .noun,        "f"),
            ("quince años", "quinceañera",                  .noun,        "f"),
            ("boda",        "wedding",                      .noun,        "f"),
            ("funeral",     "funeral",                      .noun,        "m"),
            ("cementerio",  "cemetery",                     .noun,        "m"),
            ("alma",        "soul",                         .noun,        "f"),
            ("espíritu",    "spirit",                       .noun,        "m"),
            ("ángel",       "angel",                        .noun,        "m"),
            ("diablo",      "devil",                        .noun,        "m"),
            ("milagro",     "miracle",                      .noun,        "m"),
            ("virgen",      "virgin",                       .noun,        "f"),
            ("santo",       "saint",                        .noun,        "m"),
            ("santa",       "saint (f)",                    .noun,        "f"),
            ("cruz",        "cross",                        .noun,        "f"),
            ("rosario",     "rosary",                       .noun,        "m"),
            ("altar",       "altar",                        .noun,        "m"),
            ("veladora",    "votive candle (MX)",           .noun,        "f"),
            ("rezar",       "to pray",                      .infinitive,  nil),
            ("bendecir",    "to bless",                     .infinitive,  nil),

            ("confesar",    "to confess",                   .infinitive,  nil),
            ("perdonar",    "to forgive",                   .infinitive,  nil),
            ("sagrado",     "sacred",                       .adjective,   "m"),
            ("bendito",     "blessed",                      .adjective,   "m"),
            ("devoto",      "devout",                       .adjective,   "m"),

            // ── MEXICAN HOLIDAYS & CULTURE ─────────────────────────────────────
            ("fiesta",      "party, celebration",           .noun,        "f"),
            ("feria",       "fair, festival",               .noun,        "f"),
            ("posada",      "pre-Christmas party (MX)",     .noun,        "f"),
            ("piñata",      "piñata",                       .noun,        "f"),
            ("villancico",  "Christmas carol",              .noun,        "m"),
            ("aguinaldo",   "Christmas bonus (MX)",         .noun,        "m"),
            ("día de muertos","Day of the Dead",            .noun,        "m"),
            ("ofrenda",     "offering (Day of Dead)",       .noun,        "f"),
            ("cempasúchil", "marigold (Day of Dead)",       .noun,        "m"),
            ("calavera",    "skull",                        .noun,        "f"),
            ("calaca",      "skeleton figure (MX)",         .noun,        "f"),
            ("independencia","independence",                .noun,        "f"),
            ("grito",       "shout, cry",                   .noun,        "m"),
            ("cohete",      "firework, rocket",             .noun,        "m"),
            ("desfile",     "parade",                       .noun,        "m"),
            ("bandera",     "flag",                         .noun,        "f"),
            ("himno",       "anthem, hymn",                 .noun,        "m"),
            ("héroe",       "hero",                         .noun,        "m"),
            ("festejo",     "celebration",                  .noun,        "m"),
            ("celebración", "celebration",                  .noun,        "f"),
            ("cumpleaños",  "birthday",                     .noun,        "m"),
            ("regalo",      "gift",                         .noun,        "m"),
            ("pastel",      "cake (MX)",                    .noun,        "m"),
            ("vela",        "candle",                       .noun,        "f"),
            ("brindis",     "toast (drink)",                .noun,        "m"),
            ("invitado",    "guest",                        .noun,        "m"),
            ("aniversario", "anniversary",                  .noun,        "m"),
            ("festejar",    "to celebrate (MX)",            .infinitive,  nil),

            ("brindar",     "to toast",                     .infinitive,  nil),

            ("regalar",     "to give a gift",               .infinitive,  nil),

            // ── ABSTRACT CONCEPTS ──────────────────────────────────────────────

            ("concepto",    "concept",                      .noun,        "m"),
            ("teoría",      "theory",                       .noun,        "f"),
            ("hipótesis",   "hypothesis",                   .noun,        "f"),
            ("argumento",   "argument",                     .noun,        "m"),

            ("lógica",      "logic",                        .noun,        "f"),
            ("sentido",     "sense, meaning",               .noun,        "m"),
            ("significado", "meaning",                      .noun,        "m"),
            ("símbolo",     "symbol",                       .noun,        "m"),
            ("valor",       "value, courage",               .noun,        "m"),
            ("principio",   "principle",                    .noun,        "m"),
            ("norma",       "norm, rule",                   .noun,        "f"),
            ("regla",       "rule",                         .noun,        "f"),
            ("excepción",   "exception",                    .noun,        "f"),
            ("límite",      "limit",                        .noun,        "m"),
            ("objetivo",    "objective",                    .noun,        "m"),
            ("meta",        "goal",                         .noun,        "f"),
            ("propósito",   "purpose",                      .noun,        "m"),
            ("resultado",   "result",                       .noun,        "m"),
            ("consecuencia","consequence",                  .noun,        "f"),
            ("causa",       "cause",                        .noun,        "f"),
            ("efecto",      "effect",                       .noun,        "m"),
            ("solución",    "solution",                     .noun,        "f"),

            ("desafío",     "challenge",                    .noun,        "m"),
            ("oportunidad", "opportunity",                  .noun,        "f"),
            ("riesgo",      "risk",                         .noun,        "m"),
            ("ventaja",     "advantage",                    .noun,        "f"),
            ("desventaja",  "disadvantage",                 .noun,        "f"),
            ("beneficio",   "benefit",                      .noun,        "m"),
            ("daño",        "damage, harm",                 .noun,        "m"),
            ("éxito",       "success",                      .noun,        "m"),
            ("fracaso",     "failure",                      .noun,        "m"),
            ("intento",     "attempt",                      .noun,        "m"),
            ("esfuerzo",    "effort",                       .noun,        "m"),
            ("logro",       "achievement",                  .noun,        "m"),
            ("avance",      "progress, advance",            .noun,        "m"),

            ("mejora",      "improvement",                  .noun,        "f"),
            ("proceso",     "process",                      .noun,        "m"),
            ("método",      "method",                       .noun,        "m"),
            ("sistema",     "system",                       .noun,        "m"),
            ("estructura",  "structure",                    .noun,        "f"),
            ("orden",       "order",                        .noun,        "m"),
            ("caos",        "chaos",                        .noun,        "m"),
            ("balance",     "balance",                      .noun,        "m"),
            ("armonía",     "harmony",                      .noun,        "f"),
            ("conflicto",   "conflict",                     .noun,        "m"),
            ("acuerdo",     "agreement",                    .noun,        "m"),
            ("desacuerdo",  "disagreement",                 .noun,        "m"),
            ("decisión",    "decision",                     .noun,        "f"),

            ("preferencia", "preference",                   .noun,        "f"),
            ("gusto",       "taste, pleasure",              .noun,        "m"),
            ("costumbre",   "custom, habit",                .noun,        "f"),
            ("tradición",   "tradition",                    .noun,        "f"),
            ("herencia",    "heritage, inheritance",        .noun,        "f"),

            ("memoria",     "memory",                       .noun,        "f"),
            ("recuerdo",    "memory, souvenir",             .noun,        "m"),
            ("olvido",      "forgetting",                   .noun,        "m"),

            ("mentira",     "lie",                          .noun,        "f"),
            ("secreto",     "secret",                       .noun,        "m"),
            ("misterio",    "mystery",                      .noun,        "m"),
            ("imaginación", "imagination",                  .noun,        "f"),

            ("realidad",    "reality",                      .noun,        "f"),
            ("ilusión",     "illusion, dream",              .noun,        "f"),
            ("fantasía",    "fantasy",                      .noun,        "f"),
            ("magia",       "magic",                        .noun,        "f"),

            // ── VERBS: COMMUNICATION & MIND ────────────────────────────────────
            ("expresar",    "to express",                   .infinitive,  nil),
            ("comunicar",   "to communicate",               .infinitive,  nil),
            ("informar",    "to inform",                    .infinitive,  nil),
            ("avisar",      "to notify",                    .infinitive,  nil),
            ("advertir",    "to warn",                      .infinitive,  nil),
            ("anunciar",    "to announce",                  .infinitive,  nil),
            ("reportar",    "to report",                    .infinitive,  nil),
            ("confirmar",   "to confirm",                   .infinitive,  nil),
            ("negar",       "to deny",                      .infinitive,  nil),
            ("afirmar",     "to affirm",                    .infinitive,  nil),
            ("mencionar",   "to mention",                   .infinitive,  nil),
            ("describir",   "to describe",                  .infinitive,  nil),

            ("demostrar",   "to demonstrate",               .infinitive,  nil),

            ("señalar",     "to point out",                 .infinitive,  nil),
            ("indicar",     "to indicate",                  .infinitive,  nil),
            ("sugerir",     "to suggest",                   .infinitive,  nil),
            ("recomendar",  "to recommend",                 .infinitive,  nil),
            ("aconsejar",   "to advise",                    .infinitive,  nil),
            ("convencer",   "to convince",                  .infinitive,  nil),
            ("persuadir",   "to persuade",                  .infinitive,  nil),
            ("insistir",    "to insist",                    .infinitive,  nil),
            ("exigir",      "to demand",                    .infinitive,  nil),
            ("ordenar",     "to order, to arrange",         .infinitive,  nil),
            ("mandar",      "to send, to order",            .infinitive,  nil),
            ("permitir",    "to allow",                     .infinitive,  nil),
            ("prohibir",    "to prohibit",                  .infinitive,  nil),
            ("obligar",     "to obligate",                  .infinitive,  nil),


            ("esforzarse",  "to make an effort",            .infinitive,  nil),

            ("obtener",     "to obtain",                    .infinitive,  nil),
            ("alcanzar",    "to reach, to achieve",         .infinitive,  nil),
            ("superar",     "to overcome, to surpass",      .infinitive,  nil),

            ("empeorar",    "to worsen",                    .infinitive,  nil),

            ("transformar", "to transform",                 .infinitive,  nil),



            ("destruir",    "to destroy",                   .infinitive,  nil),
            ("producir",    "to produce",                   .infinitive,  nil),
            ("fabricar",    "to manufacture",               .infinitive,  nil),
            ("inventar",    "to invent",                    .infinitive,  nil),
            ("descubrir",   "to discover",                  .infinitive,  nil),




            ("reflexionar", "to reflect",                   .infinitive,  nil),
            ("meditar",     "to meditate",                  .infinitive,  nil),
            ("concentrarse","to concentrate",               .infinitive,  nil),


            ("reconocer",   "to recognize",                 .infinitive,  nil),
            ("identificar", "to identify",                  .infinitive,  nil),


            ("entender",    "to understand",                .infinitive,  nil),
            ("comprender",  "to comprehend",                .infinitive,  nil),
            ("confundir",   "to confuse",                   .infinitive,  nil),
            ("equivocarse", "to make a mistake",            .infinitive,  nil),
            ("corregir",    "to correct",                   .infinitive,  nil),


            ("ignorar",     "to ignore",                    .infinitive,  nil),
            ("respetar",    "to respect",                   .infinitive,  nil),
            ("valorar",     "to value",                     .infinitive,  nil),
            ("apreciar",    "to appreciate",                .infinitive,  nil),
            ("admirar",     "to admire",                    .infinitive,  nil),
            ("envidiar",    "to envy",                      .infinitive,  nil),
            ("odiar",       "to hate",                      .infinitive,  nil),


            ("enamorarse",  "to fall in love",              .infinitive,  nil),
            ("decepcionar", "to disappoint",                .infinitive,  nil),
            ("sorprender",  "to surprise",                  .infinitive,  nil),
            ("impresionar", "to impress",                   .infinitive,  nil),
            ("aburrir",     "to bore",                      .infinitive,  nil),
            ("divertir",    "to entertain, to amuse",       .infinitive,  nil),
            ("interesar",   "to interest",                  .infinitive,  nil),
            ("fascinar",    "to fascinate",                 .infinitive,  nil),
            ("molestar",    "to bother, to annoy",          .infinitive,  nil),
            ("ofender",     "to offend",                    .infinitive,  nil),
            ("insultar",    "to insult",                    .infinitive,  nil),
            ("halagar",     "to flatter",                   .infinitive,  nil),
            ("cumplir",     "to fulfill, to comply",        .infinitive,  nil),
            ("fallar",      "to fail",                      .infinitive,  nil),
            ("faltar",      "to be missing, to fail",       .infinitive,  nil),
            ("sobrar",      "to be left over",              .infinitive,  nil),
            ("bastar",      "to be enough",                 .infinitive,  nil),

            // ── ADJECTIVES: QUALITY & CHARACTER ───────────────────────────────
            ("valiente",    "brave",                        .adjective,   nil),
            ("cobarde",     "cowardly",                     .adjective,   nil),
            ("leal",        "loyal",                        .adjective,   nil),
            ("traidor",     "traitor, treacherous",         .adjective,   "m"),
            ("honrado",     "honorable",                    .adjective,   "m"),
            ("deshonesto",  "dishonest",                    .adjective,   "m"),
            ("trabajador",  "hardworking",                  .adjective,   "m"),
            ("ambicioso",   "ambitious",                    .adjective,   "m"),
            ("humilde",     "humble",                       .adjective,   nil),
            ("arrogante",   "arrogant",                     .adjective,   nil),
            ("modesto",     "modest",                       .adjective,   "m"),
            ("presumido",   "conceited, showy (MX)",        .adjective,   "m"),
            ("chistoso",    "funny (MX)",                   .adjective,   "m"),
            ("gracioso",    "funny, charming",              .adjective,   "m"),
            ("serio",       "serious",                      .adjective,   "m"),
            ("alegre",      "cheerful",                     .adjective,   nil),

            ("optimista",   "optimistic",                   .adjective,   nil),
            ("pesimista",   "pessimistic",                  .adjective,   nil),
            ("realista",    "realistic",                    .adjective,   nil),
            ("idealista",   "idealistic",                   .adjective,   nil),
            ("práctico",    "practical",                    .adjective,   "m"),
            ("teórico",     "theoretical",                  .adjective,   "m"),


            ("sabio",       "wise",                         .adjective,   "m"),
            ("ignorante",   "ignorant",                     .adjective,   nil),



            ("antipático",  "unlikable",                    .adjective,   "m"),
            ("tímido",      "shy",                          .adjective,   "m"),
            ("extrovertido","extroverted",                  .adjective,   "m"),
            ("introvertido","introverted",                  .adjective,   "m"),
            ("sociable",    "sociable",                     .adjective,   nil),
            ("independiente","independent",                 .adjective,   nil),
            ("dependiente", "dependent",                    .adjective,   nil),
            ("maduro",      "mature",                       .adjective,   "m"),
            ("inmaduro",    "immature",                     .adjective,   "m"),
            ("adulto",      "adult",                        .adjective,   "m"),


            ("anciano",     "elderly",                      .adjective,   "m"),
            ("físico",      "physical",                     .adjective,   "m"),
            ("mental",      "mental",                       .adjective,   nil),
            ("emocional",   "emotional",                    .adjective,   nil),
            ("espiritual",  "spiritual",                    .adjective,   nil),
            ("moral",       "moral",                        .adjective,   nil),
            ("ético",       "ethical",                      .adjective,   "m"),
            ("legal",       "legal",                        .adjective,   nil),
            ("ilegal",      "illegal",                      .adjective,   nil),
            ("justo",       "fair, just",                   .adjective,   "m"),
            ("injusto",     "unfair",                       .adjective,   "m"),

            // ── SCIENCE & MATH ─────────────────────────────────────────────────
            ("ciencia",     "science",                      .noun,        "f"),
            ("matemática",  "mathematics",                  .noun,        "f"),
            ("física",      "physics",                      .noun,        "f"),
            ("química",     "chemistry",                    .noun,        "f"),
            ("biología",    "biology",                      .noun,        "f"),
            ("geografía",   "geography",                    .noun,        "f"),
            ("astronomía",  "astronomy",                    .noun,        "f"),
            ("experimento", "experiment",                   .noun,        "m"),

            ("fórmula",     "formula",                      .noun,        "f"),
            ("ecuación",    "equation",                     .noun,        "f"),

            ("cifra",       "figure, number",               .noun,        "f"),
            ("porcentaje",  "percentage",                   .noun,        "m"),
            ("promedio",    "average",                      .noun,        "m"),
            ("cantidad",    "quantity",                     .noun,        "f"),
            ("medida",      "measure, measurement",         .noun,        "f"),

            ("altura",      "height",                       .noun,        "f"),
            ("distancia",   "distance",                     .noun,        "f"),
            ("velocidad",   "speed",                        .noun,        "f"),
            ("temperatura", "temperature",                  .noun,        "f"),
            ("grado",       "degree",                       .noun,        "m"),
            ("átomo",       "atom",                         .noun,        "m"),
            ("molécula",    "molecule",                     .noun,        "f"),
            ("célula",      "cell",                         .noun,        "f"),
            ("genética",    "genetics",                     .noun,        "f"),
            ("evolución",   "evolution",                    .noun,        "f"),
            ("energía",     "energy",                       .noun,        "f"),
            ("gravedad",    "gravity",                      .noun,        "f"),


            ("onda",        "wave",                         .noun,        "f"),
            ("fuerza",      "force",                        .noun,        "f"),
            ("masa",        "mass",                         .noun,        "f"),
            ("volumen",     "volume",                       .noun,        "m"),
            ("densidad",    "density",                      .noun,        "f"),
            ("presión",     "pressure",                     .noun,        "f"),
            ("corriente",   "current (electric/water)",     .noun,        "f"),
            ("magnetismo",  "magnetism",                    .noun,        "m"),
            ("electricidad","electricity",                  .noun,        "f"),
            ("investigación","research",                    .noun,        "f"),
            ("descubrimiento","discovery",                  .noun,        "m"),
            ("invento",     "invention",                    .noun,        "m"),


            ("aproximado",  "approximate",                  .adjective,   "m"),
            ("lógico",      "logical",                      .adjective,   "m"),
            ("irracional",  "irrational",                   .adjective,   nil),


            ("experimentar","to experiment",                .infinitive,  nil),


            ("refutar",     "to refute",                    .infinitive,  nil),
            ("clasificar",  "to classify",                  .infinitive,  nil),
            ("categorizar", "to categorize",                .infinitive,  nil),

            // ── PHYSICAL DESCRIPTION ───────────────────────────────────────────


            ("gordo",       "fat",                          .adjective,   "m"),
            ("delgado",     "thin",                         .adjective,   "m"),
            ("flaco",       "skinny",                       .adjective,   "m"),
            ("musculoso",   "muscular",                     .adjective,   "m"),
            ("robusto",     "robust, sturdy",               .adjective,   "m"),
            ("elegante",    "elegant",                      .adjective,   nil),

            ("guapo",       "handsome",                     .adjective,   "m"),
            ("moreno",      "dark-skinned, brunette",       .adjective,   "m"),
            ("güero",       "blond, light-skinned (MX)",    .adjective,   "m"),
            ("pelirrojo",   "redhead",                      .adjective,   "m"),
            ("calvo",       "bald",                         .adjective,   "m"),
            ("rizado",      "curly",                        .adjective,   "m"),
            ("liso",        "straight (hair)",              .adjective,   "m"),
            ("rubio",       "blond",                        .adjective,   "m"),
            ("cabello",     "hair",                         .noun,        "m"),
            ("pelo",        "hair",                         .noun,        "m"),
            ("piel",        "skin",                         .noun,        "f"),

            ("frente",      "forehead",                     .noun,        "f"),
            ("mejilla",     "cheek",                        .noun,        "f"),
            ("mentón",      "chin",                         .noun,        "m"),
            ("cuello",      "neck",                         .noun,        "m"),
            ("pecho",       "chest",                        .noun,        "m"),
            ("espalda",     "back",                         .noun,        "f"),
            ("cadera",      "hip",                          .noun,        "f"),
            ("cintura",     "waist",                        .noun,        "f"),
            ("muslo",       "thigh",                        .noun,        "m"),
            ("pantorrilla", "calf",                         .noun,        "f"),
            ("talón",       "heel",                         .noun,        "m"),

            ("pulgar",      "thumb",                        .noun,        "m"),
            ("índice",      "index finger",                 .noun,        "m"),
            ("meñique",     "little finger",                .noun,        "m"),

            // ── MATERIALS & SHAPES ─────────────────────────────────────────────
            ("material",    "material",                     .noun,        "m"),
            ("madera",      "wood",                         .noun,        "f"),
            ("metal",       "metal",                        .noun,        "m"),
            ("hierro",      "iron (metal)",                 .noun,        "m"),
            ("acero",       "steel",                        .noun,        "m"),
            ("aluminio",    "aluminum",                     .noun,        "m"),
            ("cobre",       "copper",                       .noun,        "m"),
            ("plata",       "silver",                       .noun,        "f"),
            ("oro",         "gold",                         .noun,        "m"),
            ("piedra",      "stone",                        .noun,        "f"),

            ("vidrio",      "glass",                        .noun,        "m"),
            ("plástico",    "plastic",                      .noun,        "m"),
            ("hule",        "rubber (MX)",                  .noun,        "m"),
            ("tela",        "fabric",                       .noun,        "f"),
            ("algodón",     "cotton",                       .noun,        "m"),
            ("lana",        "wool",                         .noun,        "f"),
            ("seda",        "silk",                         .noun,        "f"),
            ("cuero",       "leather",                      .noun,        "m"),
            ("papel",       "paper",                        .noun,        "m"),
            ("cartón",      "cardboard",                    .noun,        "m"),
            ("círculo",     "circle",                       .noun,        "m"),
            ("cuadrado",    "square",                       .noun,        "m"),
            ("triángulo",   "triangle",                     .noun,        "m"),
            ("rectángulo",  "rectangle",                    .noun,        "m"),
            ("esfera",      "sphere",                       .noun,        "f"),

            ("línea",       "line",                         .noun,        "f"),
            ("punto",       "point, dot",                   .noun,        "m"),
            ("ángulo",      "angle",                        .noun,        "m"),
            ("curva",       "curve",                        .noun,        "f"),
            ("redondo",     "round",                        .adjective,   "m"),

            ("plano",       "flat",                         .adjective,   "m"),
            ("curvo",       "curved",                       .adjective,   "m"),
            ("recto",       "straight",                     .adjective,   "m"),
            ("torcido",     "crooked, twisted",             .adjective,   "m"),
            ("ancho",       "wide",                         .adjective,   "m"),
            ("estrecho",    "narrow",                       .adjective,   "m"),
            ("profundo",    "deep",                         .adjective,   "m"),
            ("superficial", "shallow, superficial",         .adjective,   nil),

            ("blando",      "soft",                         .adjective,   "m"),

            ("áspero",      "rough",                        .adjective,   "m"),



            ("transparente","transparent",                  .adjective,   nil),
            ("opaco",       "opaque",                       .adjective,   "m"),
            ("brillante",   "shiny, brilliant",             .adjective,   nil),
            ("mate",        "matte",                        .adjective,   nil),

            // ── COLORS (EXPANDED) ──────────────────────────────────────────────

            ("rojo",        "red",                          .adjective,   "m"),
            ("azul",        "blue",                         .adjective,   nil),
            ("verde",       "green",                        .adjective,   nil),
            ("amarillo",    "yellow",                       .adjective,   "m"),

            ("morado",      "purple",                       .adjective,   "m"),
            ("rosa",        "pink",                         .adjective,   nil),

            ("negro",       "black",                        .adjective,   "m"),
            ("blanco",      "white",                        .adjective,   "m"),
            ("gris",        "gray",                         .adjective,   nil),
            ("dorado",      "golden",                       .adjective,   "m"),
            ("plateado",    "silver, silvery",              .adjective,   "m"),
            ("turquesa",    "turquoise",                    .adjective,   nil),
            ("beige",       "beige",                        .adjective,   nil),


            ("brilloso",    "shiny, bright (MX)",           .adjective,   "m"),


            // ── WEATHER & SEASONS ──────────────────────────────────────────────
            ("primavera",   "spring",                       .noun,        "f"),
            ("verano",      "summer",                       .noun,        "m"),
            ("otoño",       "autumn, fall",                 .noun,        "m"),
            ("invierno",    "winter",                       .noun,        "m"),
            ("temporada",   "season",                       .noun,        "f"),
            ("lluvia",      "rain",                         .noun,        "f"),
            ("nieve",       "snow",                         .noun,        "f"),
            ("neblina",     "fog, mist",                    .noun,        "f"),
            ("nube",        "cloud",                        .noun,        "f"),


            ("estrella",    "star",                         .noun,        "f"),
            ("arcoíris",    "rainbow",                      .noun,        "m"),
            ("granizo",     "hail",                         .noun,        "m"),
            ("tornado",     "tornado",                      .noun,        "m"),
            ("brisa",       "breeze",                       .noun,        "f"),
            ("viento",      "wind",                         .noun,        "m"),

            ("horizonte",   "horizon",                      .noun,        "m"),

            ("humedad",     "humidity",                     .noun,        "f"),
            ("seco",        "dry",                          .adjective,   "m"),
            ("húmedo",      "humid, damp",                  .adjective,   "m"),
            ("nublado",     "cloudy",                       .adjective,   "m"),
            ("soleado",     "sunny",                        .adjective,   "m"),
            ("llover",      "to rain",                      .infinitive,  nil),
            ("nevar",       "to snow",                      .infinitive,  nil),
            ("tronar",      "to thunder",                   .infinitive,  nil),

            // ── ADDITIONAL COMMON NOUNS ────────────────────────────────────────

            ("objeto",      "object",                       .noun,        "m"),
            ("artículo",    "article, item",                .noun,        "m"),
            ("producto",    "product",                      .noun,        "m"),
            ("herramienta", "tool",                         .noun,        "f"),
            ("máquina",     "machine",                      .noun,        "f"),
            ("aparato",     "device, appliance",            .noun,        "m"),

            ("instrucción", "instruction",                  .noun,        "f"),
            ("manual",      "manual",                       .noun,        "m"),
            ("guía",        "guide",                        .noun,        "f"),

            ("revista",     "magazine",                     .noun,        "f"),
            ("periódico",   "newspaper",                    .noun,        "m"),
            ("carta",       "letter",                       .noun,        "f"),

            ("nota",        "note",                         .noun,        "f"),
            ("lista",       "list",                         .noun,        "f"),
            ("tabla",       "table, chart",                 .noun,        "f"),
            ("gráfica",     "graph",                        .noun,        "f"),
            ("imagen",      "image",                        .noun,        "f"),

            ("video",       "video",                        .noun,        "m"),

            ("serie",       "series",                       .noun,        "f"),
            ("programa",    "program, show",                .noun,        "m"),
            ("capítulo",    "chapter, episode",             .noun,        "m"),
            ("escena",      "scene",                        .noun,        "f"),
            ("personaje",   "character",                    .noun,        "m"),

            ("cuento",      "short story, tale",            .noun,        "m"),
            ("novela",      "novel",                        .noun,        "f"),
            ("poema",       "poem",                         .noun,        "m"),
            ("poesía",      "poetry",                       .noun,        "f"),
            ("autor",       "author",                       .noun,        "m"),
            ("autora",      "author (f)",                   .noun,        "f"),
            ("lector",      "reader",                       .noun,        "m"),


            ("editar",      "to edit",                      .infinitive,  nil),
            ("traducir",    "to translate",                 .infinitive,  nil),
            ("imprimir",    "to print",                     .infinitive,  nil),
            ("copiar",      "to copy",                      .infinitive,  nil),
            ("pegar",       "to paste, to glue",            .infinitive,  nil),
            ("firmar",      "to sign",                      .infinitive,  nil),
            ("anotar",      "to note down",                 .infinitive,  nil),
            ("redactar",    "to write, to draft",           .infinitive,  nil),

            // ── MEDICAL & HEALTHCARE ───────────────────────────────────────────
            ("emergencia",  "emergency",                    .noun,        "f"),
            ("ambulancia",  "ambulance",                    .noun,        "f"),
            ("cirugía",     "surgery",                      .noun,        "f"),
            ("cirujano",    "surgeon",                      .noun,        "m"),
            ("enfermería",  "nursing",                      .noun,        "f"),
            ("diagnóstico", "diagnosis",                    .noun,        "m"),
            ("tratamiento", "treatment",                    .noun,        "m"),
            ("vacuna",      "vaccine",                      .noun,        "f"),
            ("inyección",   "injection",                    .noun,        "f"),
            ("jeringa",     "syringe",                      .noun,        "f"),
            ("vendaje",     "bandage",                      .noun,        "m"),
            ("venda",       "bandage, wrap",                .noun,        "f"),
            ("yeso",        "cast, plaster",                .noun,        "m"),
            ("cita",        "appointment, date",            .noun,        "f"),
            ("consultorio", "doctor's office",              .noun,        "m"),
            ("seguro médico","health insurance",            .noun,        "m"),
            ("alergia",     "allergy",                      .noun,        "f"),
            ("asma",        "asthma",                       .noun,        "f"),
            ("diabetes",    "diabetes",                     .noun,        "f"),
            ("cáncer",      "cancer",                       .noun,        "m"),
            ("fractura",    "fracture",                     .noun,        "f"),
            ("infección",   "infection",                    .noun,        "f"),
            ("antibiótico", "antibiotic",                   .noun,        "m"),
            ("anestesia",   "anesthesia",                   .noun,        "f"),
            ("radiografía", "X-ray",                        .noun,        "f"),
            ("análisis",    "analysis, lab test",           .noun,        "m"),
            ("presión arterial","blood pressure",           .noun,        "f"),
            ("pulso",       "pulse",                        .noun,        "m"),
            ("síntoma",     "symptom",                      .noun,        "m"),
            ("aliviar",     "to relieve",                   .infinitive,  nil),
            ("operar",      "to operate",                   .infinitive,  nil),
            ("recetar",     "to prescribe",                 .infinitive,  nil),
            ("vacunar",     "to vaccinate",                 .infinitive,  nil),
            ("recuperarse", "to recover",                   .infinitive,  nil),
            ("contagiar",   "to infect, to spread",         .infinitive,  nil),
            ("prevenir",    "to prevent",                   .infinitive,  nil),
            ("esterilizar", "to sterilize",                 .infinitive,  nil),
            ("hospitalizarse","to be hospitalized",         .infinitive,  nil),
            ("dar a luz",   "to give birth",                .infinitive,  nil),
            ("embarazada",  "pregnant",                     .adjective,   "f"),

            ("grave",       "serious, severe",              .adjective,   nil),
            ("crónico",     "chronic",                      .adjective,   "m"),
            ("agudo",       "acute, sharp",                 .adjective,   "m"),
            ("contagioso",  "contagious",                   .adjective,   "m"),

            // ── MENTAL HEALTH & PSYCHOLOGY ─────────────────────────────────────
            ("psicología",  "psychology",                   .noun,        "f"),
            ("psicólogo",   "psychologist",                 .noun,        "m"),
            ("terapeuta",   "therapist",                    .noun,        nil),
            ("terapia",     "therapy",                      .noun,        "f"),
            ("ansiedad",    "anxiety",                      .noun,        "f"),
            ("depresión",   "depression",                   .noun,        "f"),
            ("trauma",      "trauma",                       .noun,        "m"),
            ("fobia",       "phobia",                       .noun,        "f"),
            ("adicción",    "addiction",                    .noun,        "f"),
            ("autoestima",  "self-esteem",                  .noun,        "f"),
            ("bienestar",   "well-being",                   .noun,        "m"),
            ("mindfulness", "mindfulness",                  .noun,        "m"),
            ("meditación",  "meditation",                   .noun,        "f"),
            ("relajarse",   "to relax",                     .infinitive,  nil),
            ("estresarse",  "to get stressed",              .infinitive,  nil),
            ("angustiarse", "to become anxious",            .infinitive,  nil),

            ("sanar",       "to heal",                      .infinitive,  nil),
            ("equilibrado", "balanced",                     .adjective,   "m"),
            ("estresado",   "stressed",                     .adjective,   "m"),
            ("ansioso",     "anxious",                      .adjective,   "m"),
            ("deprimido",   "depressed",                    .adjective,   "m"),

            // ── FOOD & DRINKS (EXPANDED) ───────────────────────────────────────
            ("desayuno",    "breakfast",                    .noun,        "m"),
            ("almuerzo",    "lunch",                        .noun,        "m"),
            ("cena",        "dinner",                       .noun,        "f"),
            ("antojito",    "street snack (MX)",            .noun,        "m"),
            ("botana",      "snack (MX)",                   .noun,        "f"),
            ("postre",      "dessert",                      .noun,        "m"),
            ("aperitivo",   "appetizer",                    .noun,        "m"),
            ("guarnición",  "side dish",                    .noun,        "f"),
            ("bebida",      "drink",                        .noun,        "f"),
            ("refresco",    "soda (MX)",                    .noun,        "m"),




            ("té",          "tea",                          .noun,        "m"),


            ("mezcal",      "mezcal",                       .noun,        "m"),
            ("pulque",      "pulque (MX)",                  .noun,        "m"),
            ("tepache",     "tepache (fermented MX)",       .noun,        "m"),
            ("licor",       "liquor",                       .noun,        "m"),

            ("res",         "beef (MX)",                    .noun,        "f"),

            ("cordero",     "lamb",                         .noun,        "m"),
            ("mariscos",    "seafood",                      .noun,        "m"),
            ("camarón",     "shrimp",                       .noun,        "m"),
            ("atún",        "tuna",                         .noun,        "m"),
            ("salmón",      "salmon",                       .noun,        "m"),
            ("ostión",      "oyster (MX)",                  .noun,        "m"),
            ("calamar",     "squid",                        .noun,        "m"),
            ("pepino",      "cucumber",                     .noun,        "m"),



            ("zanahoria",   "carrot",                       .noun,        "f"),
            ("lechuga",     "lettuce",                      .noun,        "f"),
            ("espinaca",    "spinach",                      .noun,        "f"),
            ("calabaza",    "squash, pumpkin",              .noun,        "f"),
            ("chayote",     "chayote (MX)",                 .noun,        "m"),
            ("ejote",       "green bean (MX)",              .noun,        "m"),
            ("epazote",     "Mexican herb",                 .noun,        "m"),
            ("cilantro",    "cilantro",                     .noun,        "m"),
            ("hierbabuena", "mint (MX)",                    .noun,        "f"),
            ("canela",      "cinnamon",                     .noun,        "f"),
            ("vainilla",    "vanilla",                      .noun,        "f"),
            ("chocolate",   "chocolate",                    .noun,        "m"),
            ("cajeta",      "caramel spread (MX)",          .noun,        "f"),
            ("piloncillo",  "raw cane sugar (MX)",          .noun,        "m"),
            ("pan dulce",   "sweet bread (MX)",             .noun,        "m"),
            ("churro",      "churro",                       .noun,        "m"),
            ("dona",        "donut (MX)",                   .noun,        "f"),
            ("galleta",     "cookie, cracker",              .noun,        "f"),
            ("paleta",      "popsicle (MX)",                .noun,        "f"),

            ("raspado",     "shaved ice (MX)",              .noun,        "m"),

            ("gordita",     "thick corn cake (MX)",         .noun,        "f"),
            ("sope",        "thick tortilla (MX)",          .noun,        "m"),
            ("tlayuda",     "Oaxacan flatbread (MX)",       .noun,        "f"),
            ("tlacoyо",     "stuffed corn cake (MX)",       .noun,        "m"),
            ("ceviche",     "ceviche",                      .noun,        "m"),
            ("guacamole",   "guacamole",                    .noun,        "m"),
            ("pico de gallo","pico de gallo",               .noun,        "m"),
            ("fajita",      "fajita",                       .noun,        "f"),
            ("birria",      "birria stew (MX)",             .noun,        "f"),
            ("barbacoa",    "barbacoa",                     .noun,        "f"),
            ("carnitas",    "braised pork (MX)",            .noun,        "f"),
            ("cochinita pibil","Yucatecan pork (MX)",       .noun,        "f"),
            ("desayunar",   "to have breakfast",            .infinitive,  nil),
            ("almorzar",    "to have lunch",                .infinitive,  nil),
            ("cenar",       "to have dinner",               .infinitive,  nil),

            ("saborear",    "to savor",                     .infinitive,  nil),



            ("amargo",      "bitter",                       .adjective,   "m"),
            ("ácido",       "sour, acidic",                 .adjective,   "m"),
            ("sabroso",     "tasty (MX)",                   .adjective,   "m"),



            ("crudo",       "raw",                          .adjective,   "m"),
            ("cocido",      "cooked",                       .adjective,   "m"),
            ("asado",       "grilled",                      .adjective,   "m"),
            ("frito",       "fried",                        .adjective,   "m"),

            ("tibio",       "warm, lukewarm",               .adjective,   "m"),

            // ── TRANSPORTATION & VEHICLES ──────────────────────────────────────
            ("vehículo",    "vehicle",                      .noun,        "m"),
            ("motocicleta", "motorcycle",                   .noun,        "f"),

            ("bicicleta",   "bicycle",                      .noun,        "f"),
            ("bici",        "bike (MX)",                    .noun,        "f"),

            ("microbús",    "minibus (MX)",                 .noun,        "m"),
            ("pesero",      "shared taxi (MX)",             .noun,        "m"),
            ("colectivo",   "shared transport",             .noun,        "m"),
            ("tranvía",     "tram",                         .noun,        "m"),


            ("barco",       "ship, boat",                   .noun,        "m"),
            ("lancha",      "small motorboat",              .noun,        "f"),
            ("helicóptero", "helicopter",                   .noun,        "m"),

            ("volante",     "steering wheel",               .noun,        "m"),
            ("motor",       "engine, motor",                .noun,        "m"),
            ("llanta",      "tire (MX)",                    .noun,        "f"),
            ("rueda",       "wheel",                        .noun,        "f"),
            ("freno",       "brake",                        .noun,        "m"),
            ("claxon",      "horn (MX)",                    .noun,        "m"),
            ("parabrisas",  "windshield",                   .noun,        "m"),
            ("espejo retrovisor","rearview mirror",         .noun,        "m"),
            ("cinturón de seguridad","seatbelt",            .noun,        "m"),
            ("bolsa de aire","airbag",                      .noun,        "f"),
            ("cajuela",     "trunk (MX)",                   .noun,        "f"),
            ("cofre",       "hood (MX)",                    .noun,        "m"),
            ("tablero",     "dashboard",                    .noun,        "m"),
            ("gasolina",    "gasoline",                     .noun,        "f"),
            ("tanque",      "tank",                         .noun,        "m"),
            ("conductor",   "driver",                       .noun,        "m"),
            ("pasajero",    "passenger",                    .noun,        "m"),
            ("piloto",      "pilot",                        .noun,        "m"),
            ("copiloto",    "co-pilot",                     .noun,        "m"),
            ("tripulación", "crew",                         .noun,        "f"),
            ("vuelo",       "flight",                       .noun,        "m"),
            ("despegue",    "takeoff",                      .noun,        "m"),
            ("aterrizaje",  "landing",                      .noun,        "m"),
            ("embarque",    "boarding",                     .noun,        "m"),
            ("escala",      "layover",                      .noun,        "f"),
            ("transitar",   "to drive through",             .infinitive,  nil),
            ("abordar",     "to board",                     .infinitive,  nil),

            // ── CONSTRUCTION & ARCHITECTURE ───────────────────────────────────
            ("construcción","construction",                 .noun,        "f"),

            ("cimiento",    "foundation",                   .noun,        "m"),
            ("columna",     "column",                       .noun,        "f"),
            ("viga",        "beam",                         .noun,        "f"),
            ("ladrillo",    "brick",                        .noun,        "m"),
            ("cemento",     "cement",                       .noun,        "m"),
            ("concreto",    "concrete",                     .noun,        "m"),
            ("arena",       "sand",                         .noun,        "f"),


            ("barniz",      "varnish",                      .noun,        "m"),
            ("clavo",       "nail",                         .noun,        "m"),
            ("tornillo",    "screw",                        .noun,        "m"),
            ("martillo",    "hammer",                       .noun,        "m"),
            ("destornillador","screwdriver",                .noun,        "m"),
            ("taladro",     "drill",                        .noun,        "m"),
            ("sierra",      "saw",                          .noun,        "f"),
            ("llave inglesa","wrench",                      .noun,        "f"),
            ("pinzas",      "pliers",                       .noun,        "f"),
            ("cinta métrica","measuring tape",              .noun,        "f"),
            ("plomero",     "plumber",                      .noun,        "m"),
            ("electricista","electrician",                  .noun,        "m"),
            ("albañil",     "mason, bricklayer",            .noun,        "m"),
            ("carpintero",  "carpenter",                    .noun,        "m"),


            ("demoler",     "to demolish",                  .infinitive,  nil),

            ("reparar",     "to repair",                    .infinitive,  nil),

            ("soldar",      "to weld",                      .infinitive,  nil),

            ("nivelar",     "to level",                     .infinitive,  nil),

            // ── AGRICULTURE & FARMING ──────────────────────────────────────────
            ("agricultura", "agriculture",                  .noun,        "f"),
            ("granja",      "farm",                         .noun,        "f"),
            ("rancho",      "ranch (MX)",                   .noun,        "m"),
            ("milpa",       "cornfield (MX)",               .noun,        "f"),
            ("maíz",        "corn",                         .noun,        "m"),
            ("trigo",       "wheat",                        .noun,        "m"),
            ("cebada",      "barley",                       .noun,        "f"),
            ("sorgo",       "sorghum",                      .noun,        "m"),
            ("caña de azúcar","sugarcane",                  .noun,        "f"),

            ("cacao",       "cacao",                        .noun,        "m"),
            ("henequén",    "henequen (MX fiber)",          .noun,        "m"),
            ("cosecha",     "harvest",                      .noun,        "f"),
            ("siembra",     "sowing",                       .noun,        "f"),
            ("riego",       "irrigation",                   .noun,        "m"),
            ("abono",       "fertilizer",                   .noun,        "m"),
            ("pesticida",   "pesticide",                    .noun,        "m"),
            ("arado",       "plow",                         .noun,        "m"),
            ("tractor",     "tractor",                      .noun,        "m"),
            ("granjero",    "farmer",                       .noun,        "m"),
            ("campesino",   "peasant farmer",               .noun,        "m"),
            ("sembrar",     "to sow, to plant",             .infinitive,  nil),
            ("cosechar",    "to harvest",                   .infinitive,  nil),
            ("regar",       "to water, to irrigate",        .infinitive,  nil),
            ("abonar",      "to fertilize",                 .infinitive,  nil),
            ("cultivar",    "to cultivate",                 .infinitive,  nil),
            ("podar",       "to prune",                     .infinitive,  nil),
            ("recolectar",  "to collect, to harvest",       .infinitive,  nil),
            ("orgánico",    "organic",                      .adjective,   "m"),
            ("silvestre",   "wild",                         .adjective,   nil),
            ("fértil",      "fertile",                      .adjective,   nil),

            // ── ENVIRONMENT & ECOLOGY ──────────────────────────────────────────
            ("ecología",    "ecology",                      .noun,        "f"),
            ("ecosistema",  "ecosystem",                    .noun,        "m"),
            ("biodiversidad","biodiversity",                .noun,        "f"),
            ("especie",     "species",                      .noun,        "f"),
            ("extinción",   "extinction",                   .noun,        "f"),
            ("deforestación","deforestation",               .noun,        "f"),
            ("reforestación","reforestation",               .noun,        "f"),
            ("reciclaje",   "recycling",                    .noun,        "m"),
            ("basura",      "trash",                        .noun,        "f"),
            ("basurero",    "landfill, trash can",          .noun,        "m"),
            ("bote",        "trash can (MX)",               .noun,        "m"),
            ("residuo",     "waste, residue",               .noun,        "m"),
            ("derrame",     "spill",                        .noun,        "m"),
            ("emisión",     "emission",                     .noun,        "f"),
            ("carbono",     "carbon",                       .noun,        "m"),
            ("ozono",       "ozone",                        .noun,        "m"),
            ("sostenible",  "sustainable",                  .adjective,   nil),
            ("renovable",   "renewable",                    .adjective,   nil),
            ("ecológico",   "ecological",                   .adjective,   "m"),

            ("reciclar",    "to recycle",                   .infinitive,  nil),
            ("contaminar",  "to contaminate",               .infinitive,  nil),

            ("conservar",   "to conserve",                  .infinitive,  nil),
            ("preservar",   "to preserve",                  .infinitive,  nil),

            // ── MEDIA & COMMUNICATIONS ─────────────────────────────────────────
            ("medio",       "medium, media",                .noun,        "m"),
            ("prensa",      "press",                        .noun,        "f"),

            ("titular",     "headline",                     .noun,        "m"),
            ("reportaje",   "report, story",                .noun,        "m"),
            ("entrevista",  "interview",                    .noun,        "f"),
            ("debate",      "debate",                       .noun,        "m"),
            ("editorial",   "editorial",                    .noun,        "m"),

            ("reportero",   "reporter",                     .noun,        "m"),
            ("comunicado",  "press release",                .noun,        "m"),
            ("transmisión", "broadcast",                    .noun,        "f"),

            ("antena",      "antenna",                      .noun,        "f"),
            ("satélite",    "satellite",                    .noun,        "m"),
            ("canal",       "channel",                      .noun,        "m"),
            ("publicidad",  "advertising",                  .noun,        "f"),
            ("anuncio",     "advertisement, announcement",  .noun,        "m"),
            ("propaganda",  "propaganda",                   .noun,        "f"),
            ("influencer",  "influencer",                   .noun,        nil),
            ("seguidor",    "follower",                     .noun,        "m"),
            ("contenido",   "content",                      .noun,        "m"),
            ("plataforma",  "platform",                     .noun,        "f"),
            ("tendencia",   "trend",                        .noun,        "f"),
            ("viral",       "viral",                        .adjective,   nil),
            ("transmitir",  "to broadcast",                 .infinitive,  nil),
            ("entrevistar", "to interview",                 .infinitive,  nil),

            ("difundir",    "to spread, to disseminate",    .infinitive,  nil),
            ("censurar",    "to censor",                    .infinitive,  nil),

            // ── LAW & JUSTICE ──────────────────────────────────────────────────
            ("abogada",     "lawyer (f)",                   .noun,        "f"),

            ("defensor",    "defender",                     .noun,        "m"),
            ("testigo",     "witness",                      .noun,        nil),
            ("evidencia",   "evidence",                     .noun,        "f"),
            ("prueba",      "proof, evidence",              .noun,        "f"),
            ("sentencia",   "sentence (legal)",             .noun,        "f"),
            ("veredicto",   "verdict",                      .noun,        "m"),
            ("multa",       "fine",                         .noun,        "f"),
            ("fianza",      "bail",                         .noun,        "f"),
            ("demanda",     "lawsuit",                      .noun,        "f"),
            ("denuncia",    "complaint, report",            .noun,        "f"),
            ("amparo",      "legal protection (MX)",        .noun,        "m"),
            ("notaría",     "notary office",                .noun,        "f"),
            ("notario",     "notary",                       .noun,        "m"),
            ("escritura",   "deed",                         .noun,        "f"),
            ("testamento",  "will, testament",              .noun,        "m"),
            ("heredero",    "heir",                         .noun,        "m"),
            ("demandar",    "to sue",                       .infinitive,  nil),
            ("denunciar",   "to report (a crime)",          .infinitive,  nil),
            ("absolver",    "to acquit",                    .infinitive,  nil),
            ("condenar",    "to convict",                   .infinitive,  nil),
            ("apelar",      "to appeal",                    .infinitive,  nil),

            ("testificar",  "to testify",                   .infinitive,  nil),
            ("inocente",    "innocent",                     .adjective,   nil),
            ("culpable",    "guilty",                       .adjective,   nil),



            // ── EDUCATION (EXPANDED) ───────────────────────────────────────────
            ("conocimiento","knowledge",                    .noun,        "m"),
            ("sabiduría",   "wisdom",                       .noun,        "f"),
            ("aprendizaje", "learning",                     .noun,        "m"),
            ("enseñanza",   "teaching",                     .noun,        "f"),
            ("educación",   "education",                    .noun,        "f"),
            ("formación",   "training, education",          .noun,        "f"),
            ("capacitación","training",                     .noun,        "f"),
            ("beca",        "scholarship",                  .noun,        "f"),
            ("titulación",  "graduation",                   .noun,        "f"),
            ("diploma",     "diploma",                      .noun,        "m"),
            ("título",      "degree, title",                .noun,        "m"),
            ("licenciatura","bachelor's degree",            .noun,        "f"),
            ("maestría",    "master's degree",              .noun,        "f"),
            ("doctorado",   "doctorate",                    .noun,        "m"),
            ("posgrado",    "postgraduate",                 .noun,        "m"),
            ("materia",     "subject, matter",              .noun,        "f"),
            ("asignatura",  "course, subject",              .noun,        "f"),
            ("semestre",    "semester",                     .noun,        "m"),
            ("trimestre",   "trimester",                    .noun,        "m"),
            ("ciclo escolar","school year",                 .noun,        "m"),
            ("salón",       "classroom (MX)",               .noun,        "m"),
            ("pizarrón",    "chalkboard (MX)",              .noun,        "m"),

            ("compás",      "compass",                      .noun,        "m"),
            ("calculadora", "calculator",                   .noun,        "f"),
            ("diccionario", "dictionary",                   .noun,        "m"),
            ("enciclopedia","encyclopedia",                 .noun,        "f"),


            ("párrafo",     "paragraph",                    .noun,        "m"),

            ("vocabulario", "vocabulary",                   .noun,        "m"),
            ("gramática",   "grammar",                      .noun,        "f"),
            ("ortografía",  "spelling",                     .noun,        "f"),
            ("pronunciación","pronunciation",               .noun,        "f"),
            ("acento",      "accent",                       .noun,        "m"),
            ("tilde",       "accent mark",                  .noun,        "f"),
            ("sustantivo",  "noun (grammar)",               .noun,        "m"),
            ("verbo",       "verb",                         .noun,        "m"),
            ("adjetivo",    "adjective",                    .noun,        "m"),
            ("adverbio",    "adverb",                       .noun,        "m"),
            ("preposición", "preposition",                  .noun,        "f"),
            ("conjunción",  "conjunction",                  .noun,        "f"),
            ("sujeto",      "subject (grammar)",            .noun,        "m"),
            ("predicado",   "predicate",                    .noun,        "m"),
            ("memorizar",   "to memorize",                  .infinitive,  nil),

            ("resumir",     "to summarize",                 .infinitive,  nil),
            ("citar",       "to quote, to cite",            .infinitive,  nil),
            ("graduarse",   "to graduate",                  .infinitive,  nil),
            ("titularse",   "to earn a degree",             .infinitive,  nil),
            ("becarse",     "to get a scholarship",         .infinitive,  nil),

            // ── SOCIAL ISSUES ──────────────────────────────────────────────────
            ("pobreza",     "poverty",                      .noun,        "f"),
            ("riqueza",     "wealth",                       .noun,        "f"),
            ("desigualdad", "inequality",                   .noun,        "f"),
            ("discriminación","discrimination",             .noun,        "f"),
            ("racismo",     "racism",                       .noun,        "m"),
            ("sexismo",     "sexism",                       .noun,        "m"),
            ("machismo",    "machismo (MX)",                .noun,        "m"),
            ("feminismo",   "feminism",                     .noun,        "m"),
            ("igualdad",    "equality",                     .noun,        "f"),
            ("equidad",     "equity",                       .noun,        "f"),
            ("inclusión",   "inclusion",                    .noun,        "f"),
            ("diversidad",  "diversity",                    .noun,        "f"),
            ("marginación", "marginalization",              .noun,        "f"),
            ("exclusión",   "exclusion",                    .noun,        "f"),
            ("vulnerabilidad","vulnerability",              .noun,        "f"),
            ("violencia",   "violence",                     .noun,        "f"),
            ("abuso",       "abuse",                        .noun,        "m"),
            ("acoso",       "harassment",                   .noun,        "m"),
            ("intimidación","intimidation",                 .noun,        "f"),
            ("brecha",      "gap",                          .noun,        "f"),
            ("migración",   "migration",                    .noun,        "f"),
            ("migrante",    "migrant",                      .noun,        nil),
            ("refugiado",   "refugee",                      .noun,        "m"),
            ("solidaridad", "solidarity",                   .noun,        "f"),
            ("apoyo",       "support",                      .noun,        "m"),
            ("voluntario",  "volunteer",                    .noun,        "m"),
            ("donar",       "to donate",                    .infinitive,  nil),

            ("apoyar",      "to support",                   .infinitive,  nil),
            ("discriminar", "to discriminate",              .infinitive,  nil),
            ("marginar",    "to marginalize",               .infinitive,  nil),
            ("incluir",     "to include",                   .infinitive,  nil),
            ("excluir",     "to exclude",                   .infinitive,  nil),

            // ── MORE COMMON ADJECTIVES ─────────────────────────────────────────
            ("amplio",      "wide, broad",                  .adjective,   "m"),
            ("reducido",    "reduced, limited",             .adjective,   "m"),
            ("extenso",     "extensive",                    .adjective,   "m"),
            ("breve",       "brief",                        .adjective,   nil),


            ("grueso",      "thick",                        .adjective,   "m"),

            ("enorme",      "enormous",                     .adjective,   nil),
            ("diminuto",    "tiny",                         .adjective,   "m"),
            ("mediano",     "medium-sized",                 .adjective,   "m"),
            ("abundante",   "abundant",                     .adjective,   nil),
            ("escaso",      "scarce",                       .adjective,   "m"),

            ("excesivo",    "excessive",                    .adjective,   "m"),
            ("mínimo",      "minimum",                      .adjective,   "m"),
            ("máximo",      "maximum",                      .adjective,   "m"),
            ("principal",   "main, principal",              .adjective,   nil),
            ("secundario",  "secondary",                    .adjective,   "m"),
            ("básico",      "basic",                        .adjective,   "m"),
            ("fundamental", "fundamental",                  .adjective,   nil),
            ("esencial",    "essential",                    .adjective,   nil),

            ("significativo","significant",                 .adjective,   "m"),
            ("relevante",   "relevant",                     .adjective,   nil),
            ("irrelevante", "irrelevant",                   .adjective,   nil),
            ("válido",      "valid",                        .adjective,   "m"),
            ("inválido",    "invalid",                      .adjective,   "m"),
            ("eficiente",   "efficient",                    .adjective,   nil),
            ("ineficiente", "inefficient",                  .adjective,   nil),
            ("efectivo",    "effective",                    .adjective,   "m"),
            ("inefectivo",  "ineffective",                  .adjective,   "m"),
            ("productivo",  "productive",                   .adjective,   "m"),
            ("improductivo","unproductive",                 .adjective,   "m"),

            ("inmediato",   "immediate",                    .adjective,   "m"),
            ("permanente",  "permanent",                    .adjective,   nil),
            ("temporal",    "temporary",                    .adjective,   nil),
            ("provisional", "provisional",                  .adjective,   nil),
            ("definitivo",  "definitive",                   .adjective,   "m"),
            ("obvio",       "obvious",                      .adjective,   "m"),
            ("evidente",    "evident",                      .adjective,   nil),
            ("oculto",      "hidden",                       .adjective,   "m"),
            ("visible",     "visible",                      .adjective,   nil),
            ("invisible",   "invisible",                    .adjective,   nil),

            ("artificial",  "artificial",                   .adjective,   nil),
            ("sintético",   "synthetic",                    .adjective,   "m"),
            ("auténtico",   "authentic",                    .adjective,   "m"),

            ("original",    "original",                     .adjective,   nil),
            ("único",       "unique, only",                 .adjective,   "m"),



            ("atípico",     "atypical",                     .adjective,   "m"),

            // ── MORE COMMON VERBS ──────────────────────────────────────────────
            ("actuar",      "to act",                       .infinitive,  nil),
            ("reaccionar",  "to react",                     .infinitive,  nil),

            ("contestar",   "to answer",                    .infinitive,  nil),







            ("continuar",   "to continue",                  .infinitive,  nil),
            ("pausar",      "to pause",                     .infinitive,  nil),
            ("detener",     "to stop",                      .infinitive,  nil),

            ("confiar",     "to trust",                     .infinitive,  nil),
            ("mentir",      "to lie",                       .infinitive,  nil),


            ("traicionar",  "to betray",                    .infinitive,  nil),
            ("abandonar",   "to abandon",                   .infinitive,  nil),



            ("rodear",      "to surround",                  .infinitive,  nil),
            ("unir",        "to unite, to join",            .infinitive,  nil),
            ("separar",     "to separate",                  .infinitive,  nil),

            ("combinar",    "to combine",                   .infinitive,  nil),
            ("añadir",      "to add",                       .infinitive,  nil),
            ("quitar",      "to remove",                    .infinitive,  nil),
            ("reemplazar",  "to replace",                   .infinitive,  nil),
            ("sustituir",   "to substitute",                .infinitive,  nil),
            ("representar", "to represent",                 .infinitive,  nil),
            ("simbolizar",  "to symbolize",                 .infinitive,  nil),
            ("significar",  "to mean, to signify",          .infinitive,  nil),
            ("referirse",   "to refer to",                  .infinitive,  nil),
            ("depender",    "to depend",                    .infinitive,  nil),
            ("relacionar",  "to relate",                    .infinitive,  nil),


            ("distinguir",  "to distinguish",               .infinitive,  nil),
            ("definir",     "to define",                    .infinitive,  nil),
            ("precisar",    "to specify",                   .infinitive,  nil),
            ("ampliar",     "to expand",                    .infinitive,  nil),
            ("reducir",     "to reduce",                    .infinitive,  nil),
            ("aumentar",    "to increase",                  .infinitive,  nil),
            ("disminuir",   "to decrease",                  .infinitive,  nil),

            ("decrecer",    "to decrease, to shrink",       .infinitive,  nil),
            ("extender",    "to extend",                    .infinitive,  nil),
            ("limitar",     "to limit",                     .infinitive,  nil),
            ("establecer",  "to establish",                 .infinitive,  nil),
            ("fundar",      "to found",                     .infinitive,  nil),

            ("inaugurar",   "to inaugurate",                .infinitive,  nil),

            ("suspender",   "to suspend",                   .infinitive,  nil),
            ("cancelar",    "to cancel",                    .infinitive,  nil),
            ("posponer",    "to postpone",                  .infinitive,  nil),
            ("reprogramar", "to reschedule",                .infinitive,  nil),

            ("verificar",   "to verify",                    .infinitive,  nil),
            ("comprobar",   "to check, to verify",          .infinitive,  nil),
            ("validar",     "to validate",                  .infinitive,  nil),
            ("evaluar",     "to evaluate",                  .infinitive,  nil),
            ("calificar",   "to grade, to qualify",         .infinitive,  nil),
            ("certificar",  "to certify",                   .infinitive,  nil),
            ("autorizar",   "to authorize",                 .infinitive,  nil),



            // ── HOUSEHOLD ACTIONS & ROUTINES ───────────────────────────────────
            ("despertar",   "to wake up",                   .infinitive,  nil),
            ("levantarse",  "to get up",                    .infinitive,  nil),
            ("acostarse",   "to go to bed",                 .infinitive,  nil),
            ("dormirse",    "to fall asleep",               .infinitive,  nil),
            ("bañarse",     "to bathe",                     .infinitive,  nil),
            ("ducharse",    "to shower",                    .infinitive,  nil),
            ("afeitarse",   "to shave",                     .infinitive,  nil),
            ("peinarse",    "to comb one's hair",           .infinitive,  nil),
            ("maquillarse", "to put on makeup",             .infinitive,  nil),
            ("cepillarse",  "to brush (teeth/hair)",        .infinitive,  nil),
            ("lavarse",     "to wash oneself",              .infinitive,  nil),


            ("calentar",    "to heat up",                   .infinitive,  nil),
            ("enfriar",     "to cool down",                 .infinitive,  nil),
            ("servir",      "to serve",                     .infinitive,  nil),



            ("masticar",    "to chew",                      .infinitive,  nil),
            ("tragar",      "to swallow",                   .infinitive,  nil),
            ("digerir",     "to digest",                    .infinitive,  nil),
            ("tender",      "to make (bed), to hang",       .infinitive,  nil),

            ("colgar",      "to hang",                      .infinitive,  nil),



            ("fregar",      "to scrub (MX)",                .infinitive,  nil),
            ("sacudir",     "to dust",                      .infinitive,  nil),

            ("sacar",       "to take out",                  .infinitive,  nil),







            // ── NUMBERS & QUANTITY WORDS ───────────────────────────────────────
            ("once",        "eleven",                       .adjective,   nil),
            ("doce",        "twelve",                       .adjective,   nil),
            ("trece",       "thirteen",                     .adjective,   nil),
            ("catorce",     "fourteen",                     .adjective,   nil),
            ("quince",      "fifteen",                      .adjective,   nil),
            ("dieciséis",   "sixteen",                      .adjective,   nil),
            ("diecisiete",  "seventeen",                    .adjective,   nil),
            ("dieciocho",   "eighteen",                     .adjective,   nil),
            ("diecinueve",  "nineteen",                     .adjective,   nil),
            ("veintiuno",   "twenty-one",                   .adjective,   nil),
            ("treinta",     "thirty",                       .adjective,   nil),
            ("cuarenta",    "forty",                        .adjective,   nil),
            ("cincuenta",   "fifty",                        .adjective,   nil),
            ("sesenta",     "sixty",                        .adjective,   nil),
            ("setenta",     "seventy",                      .adjective,   nil),
            ("ochenta",     "eighty",                       .adjective,   nil),
            ("noventa",     "ninety",                       .adjective,   nil),
            ("doscientos",  "two hundred",                  .adjective,   nil),
            ("quinientos",  "five hundred",                 .adjective,   nil),
            ("millón",      "million",                      .noun,        "m"),
            ("billón",      "billion",                      .noun,        "m"),
            ("mitad",       "half",                         .noun,        "f"),

            ("tercio",      "third",                        .noun,        "m"),
            ("par",         "pair",                         .noun,        "m"),
            ("docena",      "dozen",                        .noun,        "f"),
            ("ciento",      "hundred",                      .noun,        "m"),
            ("decena",      "group of ten",                 .noun,        "f"),


            ("nada",        "nothing",                      .adverb,      nil),
            ("todo",        "everything",                   .adverb,      nil),
            ("algo",        "something",                    .adverb,      nil),
            ("nadie",       "nobody",                       .adverb,      nil),
            ("alguien",     "someone",                      .adverb,      nil),
            ("ninguno",     "none, neither",                .adjective,   "m"),
            ("ambos",       "both",                         .adjective,   nil),
            ("varios",      "several",                      .adjective,   nil),
            ("cada",        "each",                         .adjective,   nil),
            ("cualquier",   "any, whichever",               .adjective,   nil),
            ("otro",        "other, another",               .adjective,   "m"),



            // ── MISCELLANEOUS MX SLANG & EXPRESSIONS ──────────────────────────
            ("cuate",       "buddy, twin (MX)",             .noun,        "m"),
            ("compa",       "buddy (MX)",                   .noun,        nil),
            ("carnal",      "bro, close friend (MX)",       .noun,        "m"),

            ("wey",         "dude (MX)",                    .noun,        "m"),
            ("chavo",       "guy, kid (MX)",                .noun,        "m"),
            ("chava",       "girl, gal (MX)",               .noun,        "f"),
            ("güey",        "dude (alternate spelling MX)", .noun,        "m"),
            ("naco",        "tacky, low-class (MX)",        .adjective,   "m"),
            ("fresa",       "preppy, snobby (MX)",          .adjective,   nil),

            ("gandalla",    "opportunist (MX)",             .noun,        nil),
            ("mamila",      "crybaby (MX)",                 .noun,        nil),
            ("chismoso",    "gossip, nosy (MX)",            .adjective,   "m"),
            ("metiche",     "meddlesome (MX)",              .adjective,   nil),
            ("chismear",    "to gossip (MX)",               .infinitive,  nil),
            ("cotorrear",   "to chat, joke around (MX)",    .infinitive,  nil),
            ("desmadrar",   "to mess up (MX)",              .infinitive,  nil),
            ("echar relajo","to fool around (MX)",          .infinitive,  nil),
            ("buena onda",  "good vibes (MX)",              .adjective,   nil),
            ("mala onda",   "bad vibes (MX)",               .adjective,   nil),
            ("qué onda",    "what's up (MX)",               .adverb,      nil),
            ("ya mero",     "almost done (MX)",             .adverb,      nil),
            ("sale",        "okay, deal (MX)",              .adverb,      nil),




            ("latoso",      "annoying, bothersome (MX)",    .adjective,   "m"),
            ("fregón",      "awesome, badass (MX)",         .adjective,   "m"),
            ("chingón",     "badass (vulgar MX)",           .adjective,   "m"),
            ("padrísimo",   "super cool (MX)",              .adjective,   "m"),
            ("chidísimo",   "super cool (MX)",              .adjective,   "m"),
            ("a huevo",     "hell yeah (vulgar MX)",        .adverb,      nil),
            ("qué chido",   "how cool (MX)",                .adverb,      nil),
            ("qué padre",   "how cool (MX)",                .adverb,      nil),
            ("no manches",  "no way, geez (MX)",            .adverb,      nil),
            ("no mames",    "no way (vulgar MX)",           .adverb,      nil),
            ("ya estuvo",   "that's it, done (MX)",         .adverb,      nil),
            ("pura vida",   "great, pure life (CR/MX)",     .adverb,      nil),
            ("echar ganas", "to try hard (MX)",             .infinitive,  nil),
            ("echar la mano","to lend a hand (MX)",         .infinitive,  nil),
            ("andar de vago","to goof off (MX)",            .infinitive,  nil),
            ("hacer la tarea","to do homework",             .infinitive,  nil),
            ("ir al grano", "to get to the point",          .infinitive,  nil),
            ("ponerse las pilas","to get your act together (MX)",.infinitive,nil),
            ("echar porras","to cheer on (MX)",             .infinitive,  nil),
            ("aventar",     "to throw (MX)",                .infinitive,  nil),
            ("agarrar la onda","to get it, understand (MX)",.infinitive, nil),
            ("quedarse a cuadros","to be stunned (MX)",     .infinitive,  nil),
            ("tener palanca","to have connections (MX)",    .infinitive,  nil),
            ("meter las manos","to interfere (MX)",         .infinitive,  nil),

            // ── VERBS: MOVEMENT & PHYSICAL ─────────────────────────────────────


            ("trotar",      "to jog",                       .infinitive,  nil),
            ("marchar",     "to march",                     .infinitive,  nil),
            ("arrastrarse", "to crawl, to drag oneself",    .infinitive,  nil),
            ("gatear",      "to crawl (baby)",              .infinitive,  nil),
            ("escalar",     "to climb",                     .infinitive,  nil),
            ("trepar",      "to climb up",                  .infinitive,  nil),

            ("tropezar",    "to trip, to stumble",          .infinitive,  nil),
            ("resbalar",    "to slip",                      .infinitive,  nil),
            ("rodar",       "to roll",                      .infinitive,  nil),
            ("deslizarse",  "to slide",                     .infinitive,  nil),

            ("flotar",      "to float",                     .infinitive,  nil),
            ("hundirse",    "to sink",                      .infinitive,  nil),

            ("aterrizar",   "to land",                      .infinitive,  nil),
            ("despegar",    "to take off",                  .infinitive,  nil),

            ("brincar",     "to hop, jump (MX)",            .infinitive,  nil),
            ("estirarse",   "to stretch",                   .infinitive,  nil),
            ("agacharse",   "to crouch, bend down",         .infinitive,  nil),
            ("inclinarse",  "to lean, to bow",              .infinitive,  nil),

            ("voltear",     "to turn around (MX)",          .infinitive,  nil),
            ("asomarse",    "to lean out, to peek",         .infinitive,  nil),
            ("esconderse",  "to hide",                      .infinitive,  nil),
            ("huir",        "to flee",                      .infinitive,  nil),
            ("escapar",     "to escape",                    .infinitive,  nil),
            ("perseguir",   "to chase",                     .infinitive,  nil),

            ("abrazar",     "to hug",                       .infinitive,  nil),
            ("besar",       "to kiss",                      .infinitive,  nil),

            ("despedirse",  "to say goodbye",               .infinitive,  nil),

            ("golpear",     "to hit",                       .infinitive,  nil),

            ("morder",      "to bite",                      .infinitive,  nil),
            ("rascar",      "to scratch",                   .infinitive,  nil),
            ("frotar",      "to rub",                       .infinitive,  nil),

            ("acariciar",   "to caress",                    .infinitive,  nil),
            ("apretar",     "to squeeze, to press",         .infinitive,  nil),

            ("halar",       "to haul, to pull",             .infinitive,  nil),
            ("arrastrar",   "to drag",                      .infinitive,  nil),

            ("levantar",    "to lift",                      .infinitive,  nil),
            ("alzar",       "to raise",                     .infinitive,  nil),
            ("soltar",      "to release, to let go",        .infinitive,  nil),


            ("entregar",    "to hand over, deliver",        .infinitive,  nil),
            ("recibir",     "to receive",                   .infinitive,  nil),
            ("devolver",    "to return (an item)",          .infinitive,  nil),


            // ── VERBS: SENSES & PERCEPTION ─────────────────────────────────────
            ("oír",         "to hear",                      .infinitive,  nil),

            ("oler",        "to smell",                     .infinitive,  nil),
            ("olfatear",    "to sniff",                     .infinitive,  nil),



            ("percibir",    "to perceive",                  .infinitive,  nil),

            ("darse cuenta","to realize",                   .infinitive,  nil),


            ("detectar",    "to detect",                    .infinitive,  nil),
            ("adivinar",    "to guess",                     .infinitive,  nil),
            ("sospechar",   "to suspect",                   .infinitive,  nil),

            ("visualizar",  "to visualize",                 .infinitive,  nil),

            // ── VERBS: SPEECH & LANGUAGE ───────────────────────────────────────


            ("narrar",      "to narrate",                   .infinitive,  nil),
            ("relatar",     "to recount, to relate",        .infinitive,  nil),

            ("susurrar",    "to whisper",                   .infinitive,  nil),
            ("murmurar",    "to murmur",                    .infinitive,  nil),
            ("pronunciar",  "to pronounce",                 .infinitive,  nil),
            ("deletrear",   "to spell",                     .infinitive,  nil),
            ("repetir",     "to repeat",                    .infinitive,  nil),
            ("balbucear",   "to stammer",                   .infinitive,  nil),
            ("tartamudear", "to stutter",                   .infinitive,  nil),
            ("tutear",      "to address as tú",             .infinitive,  nil),
            ("maldecir",    "to curse",                     .infinitive,  nil),
            ("jurar",       "to swear, to vow",             .infinitive,  nil),


            ("engañar",     "to deceive",                   .infinitive,  nil),
            ("fingir",      "to pretend",                   .infinitive,  nil),
            ("exagerar",    "to exaggerate",                .infinitive,  nil),
            ("bromear",     "to joke",                      .infinitive,  nil),

            ("elogiar",     "to praise",                    .infinitive,  nil),
            ("criticar",    "to criticize",                 .infinitive,  nil),
            ("quejarse",    "to complain",                  .infinitive,  nil),




            ("silbar",      "to whistle",                   .infinitive,  nil),
            ("tararear",    "to hum",                       .infinitive,  nil),
            ("recitar",     "to recite",                    .infinitive,  nil),
            ("debatir",     "to debate",                    .infinitive,  nil),
            ("discutir",    "to argue, discuss",            .infinitive,  nil),

            ("acordar",     "to agree on",                  .infinitive,  nil),
            ("disentir",    "to disagree",                  .infinitive,  nil),
            ("contradecir", "to contradict",                .infinitive,  nil),


            ("interrumpir", "to interrupt",                 .infinitive,  nil),
            ("callarse",    "to be quiet",                  .infinitive,  nil),


            // ── VERBS: THINKING & COGNITION ────────────────────────────────────



            ("considerar",  "to consider",                  .infinitive,  nil),
            ("razonar",     "to reason",                    .infinitive,  nil),





            ("priorizar",   "to prioritize",                .infinitive,  nil),
            ("planificar",  "to plan",                      .infinitive,  nil),
            ("estrategizar","to strategize",                .infinitive,  nil),

            ("distraerse",  "to get distracted",            .infinitive,  nil),

            ("dudar",       "to doubt",                     .infinitive,  nil),
            ("cuestionar",  "to question",                  .infinitive,  nil),
            ("asumir",      "to assume",                    .infinitive,  nil),
            ("suponer",     "to suppose",                   .infinitive,  nil),
            ("estimar",     "to estimate",                  .infinitive,  nil),
            ("predecir",    "to predict",                   .infinitive,  nil),


            ("fantasear",   "to daydream",                  .infinitive,  nil),









            ("acertar",     "to get right",                 .infinitive,  nil),




            // ── VERBS: SOCIAL & RELATIONSHIPS ──────────────────────────────────


            ("ligar",       "to flirt (MX)",                .infinitive,  nil),
            ("coquetear",   "to flirt",                     .infinitive,  nil),


            ("separarse",   "to separate",                  .infinitive,  nil),
            ("reconciliarse","to reconcile",                .infinitive,  nil),













            ("colaborar",   "to collaborate",               .infinitive,  nil),
            ("cooperar",    "to cooperate",                 .infinitive,  nil),

            ("rivalizar",   "to rival",                     .infinitive,  nil),


            ("imitar",      "to imitate",                   .infinitive,  nil),
            ("influir",     "to influence",                 .infinitive,  nil),
            ("manipular",   "to manipulate",                .infinitive,  nil),
            ("chantajear",  "to blackmail",                 .infinitive,  nil),
            ("intimidar",   "to intimidate",                .infinitive,  nil),
            ("acosar",      "to harass",                    .infinitive,  nil),


            ("disculparse", "to apologize",                 .infinitive,  nil),

            ("felicitar",   "to congratulate",              .infinitive,  nil),
            ("consolar",    "to console",                   .infinitive,  nil),
            ("motivar",     "to motivate",                  .infinitive,  nil),
            ("inspirar",    "to inspire",                   .infinitive,  nil),



            ("tranquilizar","to calm down",                 .infinitive,  nil),

            ("desanimar",   "to discourage",                .infinitive,  nil),

            // ── NOUNS: ABSTRACT & PHILOSOPHICAL ───────────────────────────────
            ("existencia",  "existence",                    .noun,        "f"),
            ("conciencia",  "consciousness, conscience",    .noun,        "f"),
            ("identidad",   "identity",                     .noun,        "f"),
            ("personalidad","personality",                  .noun,        "f"),
            ("carácter",    "character, nature",            .noun,        "m"),
            ("temperamento","temperament",                  .noun,        "m"),
            ("actitud",     "attitude",                     .noun,        "f"),
            ("perspectiva", "perspective",                  .noun,        "f"),
            ("punto de vista","point of view",              .noun,        "m"),
            ("opinión",     "opinion",                      .noun,        "f"),
            ("creencia",    "belief",                       .noun,        "f"),
            ("convicción",  "conviction",                   .noun,        "f"),
            ("prejuicio",   "prejudice",                    .noun,        "m"),
            ("estereotipo", "stereotype",                   .noun,        "m"),
            ("suposición",  "assumption",                   .noun,        "f"),
            ("percepción",  "perception",                   .noun,        "f"),
            ("intuición",   "intuition",                    .noun,        "f"),
            ("instinto",    "instinct",                     .noun,        "m"),
            ("voluntad",    "will, willpower",              .noun,        "f"),
            ("determinación","determination",               .noun,        "f"),
            ("disciplina",  "discipline",                   .noun,        "f"),
            ("constancia",  "consistency, perseverance",    .noun,        "f"),
            ("perseverancia","perseverance",                .noun,        "f"),
            ("paciencia",   "patience",                     .noun,        "f"),
            ("tolerancia",  "tolerance",                    .noun,        "f"),
            ("respeto",     "respect",                      .noun,        "m"),
            ("dignidad",    "dignity",                      .noun,        "f"),
            ("integridad",  "integrity",                    .noun,        "f"),
            ("lealtad",     "loyalty",                      .noun,        "f"),
            ("compromiso",  "commitment",                   .noun,        "m"),
            ("responsabilidad","responsibility",            .noun,        "f"),
            ("obligación",  "obligation",                   .noun,        "f"),

            ("honor",       "honor",                        .noun,        "m"),

            ("culpa",       "guilt",                        .noun,        "f"),
            ("arrepentimiento","regret, repentance",        .noun,        "m"),
            ("perdón",      "forgiveness",                  .noun,        "m"),
            ("gratitud",    "gratitude",                    .noun,        "f"),
            ("compasión",   "compassion",                   .noun,        "f"),
            ("empatía",     "empathy",                      .noun,        "f"),
            ("bondad",      "goodness, kindness",           .noun,        "f"),
            ("maldad",      "evil, wickedness",             .noun,        "f"),
            ("crueldad",    "cruelty",                      .noun,        "f"),
            ("generosidad", "generosity",                   .noun,        "f"),
            ("avaricia",    "greed",                        .noun,        "f"),
            ("envidia",     "envy",                         .noun,        "f"),
            ("ambición",    "ambition",                     .noun,        "f"),
            ("humildad",    "humility",                     .noun,        "f"),
            ("arrogancia",  "arrogance",                    .noun,        "f"),
            ("valentía",    "bravery",                      .noun,        "f"),
            ("cobardía",    "cowardice",                    .noun,        "f"),

            ("ignorancia",  "ignorance",                    .noun,        "f"),
            ("curiosidad",  "curiosity",                    .noun,        "f"),
            ("creatividad", "creativity",                   .noun,        "f"),
            ("talento",     "talent",                       .noun,        "m"),
            ("habilidad",   "ability, skill",               .noun,        "f"),
            ("destreza",    "skill, dexterity",             .noun,        "f"),
            ("capacidad",   "capacity, ability",            .noun,        "f"),
            ("aptitud",     "aptitude",                     .noun,        "f"),
            ("potencial",   "potential",                    .noun,        "m"),
            ("limitación",  "limitation",                   .noun,        "f"),
            ("debilidad",   "weakness",                     .noun,        "f"),
            ("fortaleza",   "strength, fortress",           .noun,        "f"),

            // ── NOUNS: SOCIETY & INSTITUTIONS ─────────────────────────────────
            ("institución", "institution",                  .noun,        "f"),
            ("organización","organization",                 .noun,        "f"),
            ("asociación",  "association",                  .noun,        "f"),
            ("fundación",   "foundation",                   .noun,        "f"),
            ("sindicato",   "union, syndicate",             .noun,        "m"),
            ("cooperativa", "cooperative",                  .noun,        "f"),
            ("agencia",     "agency",                       .noun,        "f"),

            ("ministerio",  "ministry",                     .noun,        "m"),
            ("secretaría",  "secretariat",                  .noun,        "f"),
            ("comité",      "committee",                    .noun,        "m"),
            ("consejo",     "council, advice",              .noun,        "m"),
            ("junta",       "board, meeting",               .noun,        "f"),
            ("asamblea",    "assembly",                     .noun,        "f"),
            ("parlamento",  "parliament",                   .noun,        "m"),


            ("embajada",    "embassy",                      .noun,        "f"),
            ("consulado",   "consulate",                    .noun,        "m"),
            ("embajador",   "ambassador",                   .noun,        "m"),
            ("delegación",  "delegation, district (MX)",    .noun,        "f"),
            ("sede",        "headquarters",                 .noun,        "f"),
            ("sucursal",    "branch office",                .noun,        "f"),
            ("franquicia",  "franchise",                    .noun,        "f"),
            ("corporación", "corporation",                  .noun,        "f"),
            ("subsidiaria", "subsidiary",                   .noun,        "f"),
            ("filial",      "affiliate",                    .noun,        "f"),
            ("proveedor",   "supplier",                     .noun,        "m"),
            ("cliente",     "client, customer",             .noun,        "m"),
            ("consumidor",  "consumer",                     .noun,        "m"),
            ("usuario",     "user",                         .noun,        "m"),
            ("accionista",  "shareholder",                  .noun,        "m"),
            ("socio",       "partner, member",              .noun,        "m"),
            ("miembro",     "member",                       .noun,        "m"),
            ("afiliado",    "affiliate, member",            .noun,        "m"),

            // ── NOUNS: ECONOMICS & BUSINESS ───────────────────────────────────
            ("economía",    "economy",                      .noun,        "f"),
            ("finanzas",    "finances",                     .noun,        "f"),
            ("contabilidad","accounting",                   .noun,        "f"),
            ("auditoría",   "audit",                        .noun,        "f"),

            ("activo",      "asset",                        .noun,        "m"),
            ("pasivo",      "liability",                    .noun,        "m"),

            ("patrimonio",  "assets, heritage",             .noun,        "m"),
            ("acción",      "stock share",                  .noun,        "f"),
            ("bono",        "bond",                         .noun,        "m"),
            ("divisa",      "currency, foreign exchange",   .noun,        "f"),
            ("tipo de cambio","exchange rate",              .noun,        "m"),
            ("inflación",   "inflation",                    .noun,        "f"),
            ("deflación",   "deflation",                    .noun,        "f"),
            ("recesión",    "recession",                    .noun,        "f"),
            ("crecimiento", "growth",                       .noun,        "m"),
            ("desarrollo",  "development",                  .noun,        "m"),
            ("productividad","productivity",                .noun,        "f"),
            ("eficiencia",  "efficiency",                   .noun,        "f"),
            ("rentabilidad","profitability",                .noun,        "f"),
            ("competencia", "competition",                  .noun,        "f"),
            ("monopolio",   "monopoly",                     .noun,        "m"),
            ("oligopolio",  "oligopoly",                    .noun,        "m"),
            ("mercado libre","free market",                 .noun,        "m"),
            ("aranceles",   "tariffs",                      .noun,        "m"),
            ("subsidio",    "subsidy",                      .noun,        "m"),
            ("exportación", "export",                       .noun,        "f"),
            ("importación", "import",                       .noun,        "f"),
            ("balanza comercial","trade balance",           .noun,        "f"),
            ("PIB",         "GDP",                          .noun,        "m"),
            ("desempleo",   "unemployment",                 .noun,        "m"),
            ("salario mínimo","minimum wage",               .noun,        "m"),


            ("negociación colectiva","collective bargaining",.noun,       "f"),

            // ── NOUNS: TECHNOLOGY (EXPANDED) ──────────────────────────────────
            ("inteligencia artificial","artificial intelligence",.noun,   "f"),
            ("algoritmo",   "algorithm",                    .noun,        "m"),
            ("base de datos","database",                    .noun,        "f"),
            ("servidor",    "server",                       .noun,        "m"),

            ("ciberseguridad","cybersecurity",              .noun,        "f"),
            ("hacker",      "hacker",                       .noun,        nil),
            ("virus",       "virus (computer)",             .noun,        "m"),
            ("malware",     "malware",                      .noun,        "m"),
            ("cifrado",     "encryption",                   .noun,        "m"),


            ("perfil",      "profile",                      .noun,        "m"),
            ("publicación", "post, publication",            .noun,        "f"),
            ("comentario",  "comment",                      .noun,        "m"),
            ("reacción",    "reaction",                     .noun,        "f"),
            ("etiqueta",    "tag, label",                   .noun,        "f"),
            ("hashtag",     "hashtag",                      .noun,        "m"),
            ("meme",        "meme",                         .noun,        "m"),
            ("foto de perfil","profile picture",            .noun,        "f"),
            ("selfie",      "selfie",                       .noun,        "m"),
            ("captura de pantalla","screenshot",            .noun,        "f"),
            ("notificación","notification",                 .noun,        "f"),
            ("actualización","update",                      .noun,        "f"),
            ("versión",     "version",                      .noun,        "f"),
            ("funcionalidad","functionality",               .noun,        "f"),
            ("interfaz",    "interface",                    .noun,        "f"),
            ("código",      "code",                         .noun,        "m"),
            ("programador", "programmer",                   .noun,        "m"),
            ("desarrollador","developer",                   .noun,        "m"),
            ("ingeniero de software","software engineer",   .noun,        "m"),
            ("startup",     "startup",                      .noun,        "f"),
            ("plataforma digital","digital platform",       .noun,        "f"),
            ("comercio electrónico","e-commerce",           .noun,        "m"),
            ("realidad virtual","virtual reality",          .noun,        "f"),
            ("realidad aumentada","augmented reality",      .noun,        "f"),
            ("impresión 3D","3D printing",                  .noun,        "f"),
            ("drone",       "drone",                        .noun,        "m"),
            ("robótica",    "robotics",                     .noun,        "f"),
            ("automatización","automation",                 .noun,        "f"),
            ("hackear",     "to hack",                      .infinitive,  nil),

            ("depurar",     "to debug",                     .infinitive,  nil),
            ("actualizar",  "to update",                    .infinitive,  nil),
            ("respaldar",   "to back up",                   .infinitive,  nil),
            ("cifrar",      "to encrypt",                   .infinitive,  nil),
            ("renderizar",  "to render",                    .infinitive,  nil),
            ("hacer clic",  "to click",                     .infinitive,  nil),
            ("arrastrar y soltar","to drag and drop",       .infinitive,  nil),
            ("deslizar",    "to swipe",                     .infinitive,  nil),
            ("pellizcar",   "to pinch (gesture)",           .infinitive,  nil),
            ("comprimir",   "to compress",                  .infinitive,  nil),
            ("descomprimir","to decompress, unzip",         .infinitive,  nil),

            // ── NOUNS: SCIENCE (EXPANDED) ──────────────────────────────────────

            ("teorema",     "theorem",                      .noun,        "m"),
            ("axioma",      "axiom",                        .noun,        "m"),
            ("postulado",   "postulate",                    .noun,        "m"),
            ("variable",    "variable",                     .noun,        "f"),
            ("constante",   "constant",                     .noun,        "f"),
            ("dato",        "data point",                   .noun,        "m"),
            ("estadística", "statistics",                   .noun,        "f"),
            ("probabilidad","probability",                  .noun,        "f"),
            ("proporción",  "proportion",                   .noun,        "f"),

            ("dimensión",   "dimension",                    .noun,        "f"),
            ("coordenada",  "coordinate",                   .noun,        "f"),
            ("vector",      "vector",                       .noun,        "m"),
            ("magnitud",    "magnitude",                    .noun,        "f"),
            ("campo magnético","magnetic field",            .noun,        "m"),
            ("circuito",    "circuit",                      .noun,        "m"),
            ("voltaje",     "voltage",                      .noun,        "m"),
            ("resistencia", "resistance",                   .noun,        "f"),
            ("frecuencia",  "frequency",                    .noun,        "f"),
            ("amplitud",    "amplitude",                    .noun,        "f"),
            ("longitud de onda","wavelength",               .noun,        "f"),
            ("espectro",    "spectrum",                     .noun,        "m"),
            ("fotón",       "photon",                       .noun,        "m"),
            ("electrón",    "electron",                     .noun,        "m"),
            ("protón",      "proton",                       .noun,        "m"),
            ("neutrón",     "neutron",                      .noun,        "m"),
            ("núcleo",      "nucleus",                      .noun,        "m"),
            ("elemento",    "element",                      .noun,        "m"),
            ("compuesto",   "compound",                     .noun,        "m"),
            ("reacción química","chemical reaction",        .noun,        "f"),

            ("base",        "base (chemistry)",             .noun,        "f"),
            ("pH",          "pH",                           .noun,        "m"),

            ("cadena alimentaria","food chain",             .noun,        "f"),
            ("fotosíntesis","photosynthesis",               .noun,        "f"),
            ("mitosis",     "mitosis",                      .noun,        "f"),
            ("ADN",         "DNA",                          .noun,        "m"),
            ("gen",         "gene",                         .noun,        "m"),
            ("cromosoma",   "chromosome",                   .noun,        "m"),
            ("proteína",    "protein",                      .noun,        "f"),
            ("vitamina",    "vitamin",                      .noun,        "f"),
            ("mineral",     "mineral",                      .noun,        "m"),
            ("carbohidrato","carbohydrate",                 .noun,        "m"),
            ("grasa",       "fat",                          .noun,        "f"),
            ("calorías",    "calories",                     .noun,        "f"),
            ("metabolismo", "metabolism",                   .noun,        "m"),
            ("sistema nervioso","nervous system",           .noun,        "m"),
            ("sistema inmune","immune system",              .noun,        "m"),
            ("hormona",     "hormone",                      .noun,        "f"),
            ("neurona",     "neuron",                       .noun,        "f"),
            ("sinápsis",    "synapse",                      .noun,        "f"),
            ("universo",    "universe",                     .noun,        "m"),
            ("galaxia",     "galaxy",                       .noun,        "f"),
            ("nebulosa",    "nebula",                       .noun,        "f"),
            ("agujero negro","black hole",                  .noun,        "m"),
            ("órbita",      "orbit",                        .noun,        "f"),
            ("atmósfera",   "atmosphere",                   .noun,        "f"),
            ("litosfera",   "lithosphere",                  .noun,        "f"),
            ("hidrósfera",  "hydrosphere",                  .noun,        "f"),
            ("placa tectónica","tectonic plate",            .noun,        "f"),
            ("erosión",     "erosion",                      .noun,        "f"),
            ("sedimento",   "sediment",                     .noun,        "m"),

            ("fósil",       "fossil",                       .noun,        "m"),


            ("mutación",    "mutation",                     .noun,        "f"),
            ("adaptación",  "adaptation",                   .noun,        "f"),
            ("selección natural","natural selection",       .noun,        "f"),

            // ── NOUNS: ART, LITERATURE & CULTURE ─────────────────────────────
            ("patrimonio cultural","cultural heritage",     .noun,        "m"),
            ("legado",      "legacy",                       .noun,        "m"),
            ("folklore",    "folklore",                     .noun,        "m"),
            ("mito",        "myth",                         .noun,        "m"),
            ("leyenda",     "legend",                       .noun,        "f"),
            ("fábula",      "fable",                        .noun,        "f"),



            ("estrofa",     "stanza",                       .noun,        "f"),
            ("rima",        "rhyme",                        .noun,        "f"),
            ("metáfora",    "metaphor",                     .noun,        "f"),
            ("símil",       "simile",                       .noun,        "m"),
            ("ironía",      "irony",                        .noun,        "f"),
            ("sarcasmo",    "sarcasm",                      .noun,        "m"),
            ("hipérbole",   "hyperbole",                    .noun,        "f"),
            ("protagonista","protagonist",                  .noun,        nil),
            ("antagonista", "antagonist",                   .noun,        nil),
            ("narrador",    "narrator",                     .noun,        "m"),
            ("trama",       "plot",                         .noun,        "f"),
            ("desenlace",   "ending, outcome",              .noun,        "m"),
            ("clímax",      "climax",                       .noun,        "m"),
            ("género literario","literary genre",           .noun,        "m"),
            ("ensayo",      "essay",                        .noun,        "m"),
            ("crónica",     "chronicle",                    .noun,        "f"),
            ("relato",      "story, account",               .noun,        "m"),
            ("anécdota",    "anecdote",                     .noun,        "f"),
            ("reseña",      "review",                       .noun,        "f"),
            ("crítica literaria","literary criticism",      .noun,        "f"),
            ("verso",       "verse",                        .noun,        "m"),
            ("prosa",       "prose",                        .noun,        "f"),
            ("puntuación",  "punctuation",                  .noun,        "f"),
            ("coma",        "comma",                        .noun,        "f"),

            ("signo de interrogación","question mark",      .noun,        "m"),
            ("signo de exclamación","exclamation mark",     .noun,        "m"),
            ("comillas",    "quotation marks",              .noun,        "f"),
            ("paréntesis",  "parentheses",                  .noun,        "m"),
            ("guion",       "hyphen, script",               .noun,        "m"),

            ("prólogo",     "prologue",                     .noun,        "m"),
            ("epílogo",     "epilogue",                     .noun,        "m"),

            ("bibliografía","bibliography",                 .noun,        "f"),

            ("referencia",  "reference",                    .noun,        "f"),
            ("fuente",      "source",                       .noun,        "f"),
            ("galería",     "gallery",                      .noun,        "f"),
            ("exposición",  "exhibition",                   .noun,        "f"),
            ("instalación", "installation (art)",           .noun,        "f"),
            ("performance", "performance (art)",            .noun,        "m"),
            ("mural",       "mural",                        .noun,        "m"),

            ("acuarela",    "watercolor",                   .noun,        "f"),
            ("óleo",        "oil painting",                 .noun,        "m"),
            ("grabado",     "engraving, print",             .noun,        "m"),
            ("collage",     "collage",                      .noun,        "m"),
            ("escenario",   "stage, scenario",              .noun,        "m"),
            ("utilería",    "props",                        .noun,        "f"),
            ("vestuario",   "wardrobe, costume",            .noun,        "m"),
            ("coreografía", "choreography",                 .noun,        "f"),
            ("libreto",     "libretto, script",             .noun,        "m"),
            ("guión cinematográfico","screenplay",          .noun,        "m"),
            ("director",    "director",                     .noun,        "m"),
            ("productor",   "producer",                     .noun,        "m"),
            ("fotógrafo",   "photographer",                 .noun,        "m"),
            ("diseñador",   "designer",                     .noun,        "m"),


            ("grabador",    "engraver",                     .noun,        "m"),
            ("ceramista",   "ceramicist",                   .noun,        nil),

            // ── NOUNS: URBAN INFRASTRUCTURE ────────────────────────────────────
            ("infraestructura","infrastructure",            .noun,        "f"),
            ("drenaje",     "drainage, sewage (MX)",        .noun,        "m"),
            ("alcantarilla","sewer",                        .noun,        "f"),
            ("tubería",     "piping",                       .noun,        "f"),
            ("cañería",     "pipe, plumbing",               .noun,        "f"),
            ("instalación eléctrica","electrical wiring",   .noun,        "f"),
            ("alumbrado",   "street lighting",              .noun,        "m"),
            ("bache",       "pothole (MX)",                 .noun,        "m"),
            ("tope",        "speed bump (MX)",              .noun,        "m"),
            ("glorieta",    "roundabout",                   .noun,        "f"),
            ("viaducto",    "viaduct",                      .noun,        "m"),
            ("distribuidor vial","interchange",             .noun,        "m"),
            ("carril",      "lane",                         .noun,        "m"),
            ("acotamiento", "shoulder (road, MX)",          .noun,        "m"),
            ("peaje",       "toll",                         .noun,        "m"),
            ("caseta",      "toll booth (MX)",              .noun,        "f"),
            ("retorno",     "U-turn, return road (MX)",     .noun,        "m"),



            ("bulevar",     "boulevard",                    .noun,        "m"),
            ("callejón",    "alley",                        .noun,        "m"),
            ("andador",     "pedestrian path",              .noun,        "m"),
            ("acera",       "sidewalk",                     .noun,        "f"),
            ("cruce peatonal","crosswalk",                  .noun,        "m"),
            ("puente peatonal","pedestrian bridge",         .noun,        "m"),

            ("estacionamiento","parking lot",               .noun,        "m"),
            ("parquímetro", "parking meter",                .noun,        "m"),
            ("señal de tránsito","traffic sign",            .noun,        "f"),
            ("límite de velocidad","speed limit",           .noun,        "m"),
            ("multa de tránsito","traffic ticket",          .noun,        "f"),
            ("agente de tránsito","traffic officer",        .noun,        "m"),
            ("embotellamiento","traffic jam",               .noun,        "m"),
            ("hora pico",   "rush hour",                    .noun,        "f"),
            ("congestionamiento","congestion",              .noun,        "m"),
            ("obra vial",   "road construction",            .noun,        "f"),
            ("desvío",      "detour",                       .noun,        "m"),
            ("cierro",      "road closure",                 .noun,        "m"),
            ("parque industrial","industrial park",         .noun,        "m"),
            ("zona comercial","commercial zone",            .noun,        "f"),
            ("zona residencial","residential zone",         .noun,        "f"),


            // ── NOUNS: NATURAL WORLD (EXPANDED) ───────────────────────────────

            ("cerro",       "hill",                         .noun,        "m"),
            ("loma",        "small hill",                   .noun,        "f"),
            ("barranca",    "ravine (MX)",                  .noun,        "f"),
            ("cañón",       "canyon",                       .noun,        "m"),
            ("cueva",       "cave",                         .noun,        "f"),
            ("gruta",       "grotto",                       .noun,        "f"),
            ("acantilado",  "cliff",                        .noun,        "m"),
            ("precipicio",  "precipice",                    .noun,        "m"),
            ("cascada",     "waterfall",                    .noun,        "f"),
            ("manantial",   "spring (water)",               .noun,        "m"),
            ("arroyo",      "stream, creek",                .noun,        "m"),
            ("laguna",      "lagoon",                       .noun,        "f"),
            ("pantano",     "swamp",                        .noun,        "m"),
            ("ciénaga",     "marsh",                        .noun,        "f"),
            ("humedal",     "wetland",                      .noun,        "m"),
            ("glaciar",     "glacier",                      .noun,        "m"),
            ("iceberg",     "iceberg",                      .noun,        "m"),
            ("tundra",      "tundra",                       .noun,        "f"),
            ("sabana",      "savanna",                      .noun,        "f"),
            ("estepa",      "steppe",                       .noun,        "f"),
            ("delta",       "delta",                        .noun,        "m"),
            ("estuario",    "estuary",                      .noun,        "m"),
            ("arrecife",    "reef",                         .noun,        "m"),
            ("coral",       "coral",                        .noun,        "m"),
            ("manglar",     "mangrove",                     .noun,        "m"),
            ("cenote",      "cenote (MX)",                  .noun,        "m"),
            ("caverna",     "cavern",                       .noun,        "f"),
            ("cueva submarina","underwater cave",           .noun,        "f"),
            ("fondo marino","ocean floor",                  .noun,        "m"),
            ("corriente marina","ocean current",            .noun,        "f"),
            ("marea",       "tide",                         .noun,        "f"),
            ("ola",         "wave",                         .noun,        "f"),
            ("espuma",      "foam",                         .noun,        "f"),


            ("duna",        "dune",                         .noun,        "f"),

            ("cabo",        "cape (geography)",             .noun,        "m"),
            ("golfo",       "gulf",                         .noun,        "m"),
            ("bahía",       "bay",                          .noun,        "f"),

            ("península",   "peninsula",                    .noun,        "f"),
            ("archipiélago","archipelago",                  .noun,        "m"),
            ("llanura",     "plain",                        .noun,        "f"),
            ("meseta",      "plateau",                      .noun,        "f"),
            ("altiplano",   "high plateau",                 .noun,        "m"),
            ("valles",      "valleys",                      .noun,        "m"),
            ("cuenca",      "basin",                        .noun,        "f"),

            // ── ADJECTIVES: ADVANCED ───────────────────────────────────────────
            ("absoluto",    "absolute",                     .adjective,   "m"),
            ("relativo",    "relative",                     .adjective,   "m"),

            ("abstracto",   "abstract",                     .adjective,   "m"),
            ("subjetivo",   "subjective",                   .adjective,   "m"),

            ("explícito",   "explicit",                     .adjective,   "m"),
            ("implícito",   "implicit",                     .adjective,   "m"),
            ("literal",     "literal",                      .adjective,   nil),
            ("figurado",    "figurative",                   .adjective,   "m"),
            ("ambiguo",     "ambiguous",                    .adjective,   "m"),

            ("vago",        "vague",                        .adjective,   "m"),
            ("preciso",     "precise",                      .adjective,   "m"),
            ("impreciso",   "imprecise",                    .adjective,   "m"),
            ("confiable",   "reliable",                     .adjective,   nil),
            ("poco confiable","unreliable",                 .adjective,   nil),


            ("flexible",    "flexible",                     .adjective,   nil),
            ("rígido",      "rigid",                        .adjective,   "m"),
            ("adaptable",   "adaptable",                    .adjective,   nil),
            ("estable",     "stable",                       .adjective,   nil),
            ("inestable",   "unstable",                     .adjective,   nil),
            ("volátil",     "volatile",                     .adjective,   nil),
            ("consistente", "consistent",                   .adjective,   nil),
            ("inconsistente","inconsistent",                .adjective,   nil),
            ("coherente",   "coherent",                     .adjective,   nil),
            ("incoherente", "incoherent",                   .adjective,   nil),
            ("complejo",    "complex",                      .adjective,   "m"),
            ("sencillo",    "simple",                       .adjective,   "m"),
            ("complicado",  "complicated",                  .adjective,   "m"),
            ("sofisticado", "sophisticated",                .adjective,   "m"),
            ("elaborado",   "elaborate",                    .adjective,   "m"),
            ("rudimentario","rudimentary",                  .adjective,   "m"),
            ("primitivo",   "primitive",                    .adjective,   "m"),
            ("avanzado",    "advanced",                     .adjective,   "m"),
            ("obsoleto",    "obsolete",                     .adjective,   "m"),
            ("innovador",   "innovative",                   .adjective,   "m"),
            ("revolucionario","revolutionary",              .adjective,   "m"),
            ("conservador", "conservative",                 .adjective,   "m"),
            ("progresista", "progressive",                  .adjective,   nil),
            ("liberal",     "liberal",                      .adjective,   nil),
            ("radical",     "radical",                      .adjective,   nil),
            ("extremo",     "extreme",                      .adjective,   "m"),
            ("moderado",    "moderate",                     .adjective,   "m"),
            ("neutral",     "neutral",                      .adjective,   nil),
            ("imparcial",   "impartial",                    .adjective,   nil),
            ("parcial",     "partial, biased",              .adjective,   nil),
            ("recíproco",   "reciprocal",                   .adjective,   "m"),
            ("mutuo",       "mutual",                       .adjective,   "m"),
            ("bilateral",   "bilateral",                    .adjective,   nil),
            ("multilateral","multilateral",                 .adjective,   nil),
            ("global",      "global",                       .adjective,   nil),
            ("local",       "local",                        .adjective,   nil),
            ("regional",    "regional",                     .adjective,   nil),
            ("nacional",    "national",                     .adjective,   nil),
            ("internacional","international",               .adjective,   nil),
            ("universal",   "universal",                    .adjective,   nil),
            ("particular",  "particular, private",          .adjective,   nil),
            ("general",     "general",                      .adjective,   nil),
            ("específico",  "specific",                     .adjective,   "m"),
            ("genérico",    "generic",                      .adjective,   "m"),
            ("individual",  "individual",                   .adjective,   nil),



            ("frecuente",   "frequent",                     .adjective,   nil),
            ("ocasional",   "occasional",                   .adjective,   nil),
            ("esporádico",  "sporadic",                     .adjective,   "m"),
            ("continuo",    "continuous",                   .adjective,   "m"),
            ("intermitente","intermittent",                 .adjective,   nil),
            ("gradual",     "gradual",                      .adjective,   nil),
            ("repentino",   "sudden",                       .adjective,   "m"),
            ("progresivo",  "progressive",                  .adjective,   "m"),
            ("regresivo",   "regressive",                   .adjective,   "m"),
            ("creciente",   "growing, increasing",          .adjective,   nil),
            ("decreciente", "decreasing",                   .adjective,   nil),


            ("fijo",        "fixed",                        .adjective,   "m"),
            ("móvil",       "mobile",                       .adjective,   nil),
            ("portátil",    "portable",                     .adjective,   nil),
            ("estacionario","stationary",                   .adjective,   "m"),
            ("dinámico",    "dynamic",                      .adjective,   "m"),
            ("estático",    "static",                       .adjective,   "m"),


            ("proactivo",   "proactive",                    .adjective,   "m"),
            ("reactivo",    "reactive",                     .adjective,   "m"),
            ("preventivo",  "preventive",                   .adjective,   "m"),
            ("correctivo",  "corrective",                   .adjective,   "m"),
            ("positivo",    "positive",                     .adjective,   "m"),
            ("negativo",    "negative",                     .adjective,   "m"),
            ("constructivo","constructive",                 .adjective,   "m"),
            ("destructivo", "destructive",                  .adjective,   "m"),

            ("analítico",   "analytical",                   .adjective,   "m"),
            ("crítico",     "critical",                     .adjective,   "m"),
            ("reflexivo",   "reflective",                   .adjective,   "m"),
            ("impulsivo",   "impulsive",                    .adjective,   "m"),
            ("metódico",    "methodical",                   .adjective,   "m"),
            ("sistemático", "systematic",                   .adjective,   "m"),
            ("ordenado",    "orderly",                      .adjective,   "m"),
            ("desordenado", "disorderly",                   .adjective,   "m"),
            ("puntual",     "punctual",                     .adjective,   nil),
            ("impuntual",   "unpunctual",                   .adjective,   nil),
            ("eficaz",      "effective",                    .adjective,   nil),
            ("ineficaz",    "ineffective",                  .adjective,   nil),
            ("competente",  "competent",                    .adjective,   nil),
            ("incompetente","incompetent",                  .adjective,   nil),
            ("calificado",  "qualified",                    .adjective,   "m"),
            ("inexperto",   "inexperienced",                .adjective,   "m"),
            ("experto",     "expert",                       .adjective,   "m"),
            ("profesional", "professional",                 .adjective,   nil),
            ("amateur",     "amateur",                      .adjective,   nil),

            ("obligatorio", "mandatory",                    .adjective,   "m"),
            ("optativo",    "optional",                     .adjective,   "m"),
            ("obligado",    "obligated",                    .adjective,   "m"),

            ("involuntario","involuntary",                  .adjective,   "m"),
            ("intencional", "intentional",                  .adjective,   nil),
            ("accidental",  "accidental",                   .adjective,   nil),
            ("deliberado",  "deliberate",                   .adjective,   "m"),
            ("espontáneo",  "spontaneous",                  .adjective,   "m"),

            // ── ADVERBS: ADVANCED ──────────────────────────────────────────────
            ("actualmente", "currently",                    .adverb,      nil),
            ("anteriormente","previously",                  .adverb,      nil),
            ("posteriormente","subsequently",               .adverb,      nil),
            ("simultáneamente","simultaneously",            .adverb,      nil),
            ("previamente", "previously",                   .adverb,      nil),
            ("finalmente",  "finally",                      .adverb,      nil),
            ("inicialmente","initially",                    .adverb,      nil),
            ("principalmente","mainly",                     .adverb,      nil),
            ("especialmente","especially",                  .adverb,      nil),
            ("particularmente","particularly",              .adverb,      nil),
            ("básicamente", "basically",                    .adverb,      nil),
            ("fundamentalmente","fundamentally",            .adverb,      nil),
            ("esencialmente","essentially",                 .adverb,      nil),
            ("literalmente","literally",                    .adverb,      nil),
            ("prácticamente","practically",                 .adverb,      nil),
            ("teóricamente","theoretically",                .adverb,      nil),
            ("oficialmente","officially",                   .adverb,      nil),
            ("formalmente", "formally",                     .adverb,      nil),
            ("informalmente","informally",                  .adverb,      nil),
            ("técnicamente","technically",                  .adverb,      nil),
            ("legalmente",  "legally",                      .adverb,      nil),
            ("ilegalmente", "illegally",                    .adverb,      nil),
            ("moralmente",  "morally",                      .adverb,      nil),
            ("éticamente",  "ethically",                    .adverb,      nil),
            ("económicamente","economically",               .adverb,      nil),
            ("políticamente","politically",                 .adverb,      nil),
            ("socialmente", "socially",                     .adverb,      nil),
            ("culturalmente","culturally",                  .adverb,      nil),
            ("históricamente","historically",               .adverb,      nil),
            ("científicamente","scientifically",            .adverb,      nil),
            ("estratégicamente","strategically",            .adverb,      nil),
            ("eficientemente","efficiently",                .adverb,      nil),
            ("efectivamente","effectively",                 .adverb,      nil),
            ("correctamente","correctly",                   .adverb,      nil),
            ("incorrectamente","incorrectly",               .adverb,      nil),
            ("claramente",  "clearly",                      .adverb,      nil),
            ("obviamente",  "obviously",                    .adverb,      nil),
            ("aparentemente","apparently",                  .adverb,      nil),
            ("supuestamente","supposedly",                  .adverb,      nil),
            ("definitivamente","definitely",                .adverb,      nil),
            ("probablemente","probably",                    .adverb,      nil),
            ("posiblemente","possibly",                     .adverb,      nil),

            ("acaso",       "perhaps, maybe",               .adverb,      nil),


            ("afortunadamente","fortunately",               .adverb,      nil),
            ("desafortunadamente","unfortunately",          .adverb,      nil),
            ("lamentablemente","regrettably",               .adverb,      nil),
            ("increíblemente","incredibly",                 .adverb,      nil),
            ("sorprendentemente","surprisingly",            .adverb,      nil),
            ("curiosamente","curiously",                    .adverb,      nil),
            ("irónicamente","ironically",                   .adverb,      nil),
            ("típicamente", "typically",                    .adverb,      nil),
            ("raramente",   "rarely",                       .adverb,      nil),
            ("constantemente","constantly",                 .adverb,      nil),
            ("continuamente","continuously",                .adverb,      nil),
            ("paulatinamente","gradually, little by little",.adverb,      nil),
            ("eventualmente","eventually",                  .adverb,      nil),

            ("absolutamente","absolutely",                  .adverb,      nil),
            ("totalmente",  "totally",                      .adverb,      nil),
            ("completamente","completely",                  .adverb,      nil),
            ("parcialmente","partially",                    .adverb,      nil),
            ("aproximadamente","approximately",             .adverb,      nil),
            ("relativamente","relatively",                  .adverb,      nil),
            ("comparativamente","comparatively",            .adverb,      nil),
            ("considerablemente","considerably",            .adverb,      nil),
            ("significativamente","significantly",          .adverb,      nil),
            ("notablemente","notably",                      .adverb,      nil),
            ("dramáticamente","dramatically",               .adverb,      nil),
            ("radicalmente","radically",                    .adverb,      nil),
            ("profundamente","deeply, profoundly",          .adverb,      nil),
            ("ampliamente", "broadly, widely",              .adverb,      nil),
            ("brevemente",  "briefly",                      .adverb,      nil),
            ("detalladamente","in detail",                  .adverb,      nil),
            ("resumidamente","briefly, in summary",         .adverb,      nil),
            ("directamente","directly",                     .adverb,      nil),
            ("indirectamente","indirectly",                 .adverb,      nil),
            ("mutuamente",  "mutually",                     .adverb,      nil),
            ("respectivamente","respectively",              .adverb,      nil),
            ("individualmente","individually",              .adverb,      nil),
            ("colectivamente","collectively",               .adverb,      nil),
            ("voluntariamente","voluntarily",               .adverb,      nil),
            ("forzosamente","forcibly",                     .adverb,      nil),
            ("libremente",  "freely",                       .adverb,      nil),
            ("abiertamente","openly",                       .adverb,      nil),
            ("secretamente","secretly",                     .adverb,      nil),
            ("públicamente","publicly",                     .adverb,      nil),
            ("privadamente","privately",                    .adverb,      nil),

            // ── NOUNS: FOOD & KITCHEN TOOLS ───────────────────────────────────
            ("cuchillo",    "knife",                        .noun,        "m"),
            ("tenedor",     "fork",                         .noun,        "m"),
            ("cuchara",     "spoon",                        .noun,        "f"),
            ("cucharita",   "teaspoon",                     .noun,        "f"),
            ("plato",       "plate",                        .noun,        "m"),
            ("tazón",       "bowl",                         .noun,        "m"),
            ("jarra",       "pitcher",                      .noun,        "f"),
            ("vaso",        "glass",                        .noun,        "m"),
            ("copa",        "wine glass",                   .noun,        "f"),
            ("taza",        "cup, mug",                     .noun,        "f"),
            ("tetera",      "teapot",                       .noun,        "f"),
            ("cafetera",    "coffee maker",                 .noun,        "f"),
            ("sartén",      "frying pan",                   .noun,        "f"),
            ("olla",        "pot",                          .noun,        "f"),
            ("cacerola",    "saucepan",                     .noun,        "f"),
            ("comal",       "griddle (MX)",                 .noun,        "m"),
            ("molcajete",   "stone mortar (MX)",            .noun,        "m"),
            ("metate",      "grinding stone (MX)",          .noun,        "m"),
            ("chiquihuite",  "wicker basket (MX)",          .noun,        "m"),
            ("servilleta",  "napkin",                       .noun,        "f"),
            ("mantel",      "tablecloth",                   .noun,        "m"),
            ("colador",     "strainer",                     .noun,        "m"),
            ("exprimidor",  "juicer",                       .noun,        "m"),
            ("rallador",    "grater",                       .noun,        "m"),
            ("pelador",     "peeler",                       .noun,        "m"),
            ("tabla de cortar","cutting board",             .noun,        "f"),
            ("charola",     "tray (MX)",                    .noun,        "f"),
            ("recipiente",  "container",                    .noun,        "m"),
            ("envase",      "container, packaging",         .noun,        "m"),
            ("tapa",        "lid",                          .noun,        "f"),
            ("frasco",      "jar",                          .noun,        "m"),
            ("lata",        "can, tin",                     .noun,        "f"),

            ("caja",        "box",                          .noun,        "f"),

            // ── NOUNS: MEDICAL (EXPANDED) ──────────────────────────────────────
            ("cardiólogo",  "cardiologist",                 .noun,        "m"),
            ("dermatólogo", "dermatologist",                .noun,        "m"),
            ("neurólogo",   "neurologist",                  .noun,        "m"),
            ("ortopedista", "orthopedist",                  .noun,        nil),
            ("pediatra",    "pediatrician",                 .noun,        nil),
            ("ginecólogo",  "gynecologist",                 .noun,        "m"),
            ("psiquiatra",  "psychiatrist",                 .noun,        nil),
            ("oncólogo",    "oncologist",                   .noun,        "m"),
            ("oftalmólogo", "ophthalmologist",              .noun,        "m"),
            ("otorrinolaringólogo","ENT specialist",        .noun,        "m"),
            ("urólogo",     "urologist",                    .noun,        "m"),
            ("gastroenterólogo","gastroenterologist",       .noun,        "m"),
            ("endocrinólogo","endocrinologist",             .noun,        "m"),
            ("reumatólogo", "rheumatologist",               .noun,        "m"),
            ("internista",  "internist",                    .noun,        nil),
            ("anestesiólogo","anesthesiologist",            .noun,        "m"),
            ("radiólogo",   "radiologist",                  .noun,        "m"),
            ("patólogo",    "pathologist",                  .noun,        "m"),
            ("ecografía",   "ultrasound",                   .noun,        "f"),
            ("tomografía",  "CT scan",                      .noun,        "f"),
            ("resonancia magnética","MRI",                  .noun,        "f"),
            ("electrocardiograma","EKG",                    .noun,        "m"),
            ("expediente médico","medical record",          .noun,        "m"),
            ("historial clínico","clinical history",        .noun,        "m"),
            ("prueba de sangre","blood test",               .noun,        "f"),
            ("muestra",     "sample",                       .noun,        "f"),
            ("cultivo",     "culture (medical)",            .noun,        "m"),
            ("biopsia",     "biopsy",                       .noun,        "f"),
            ("trasplante",  "transplant",                   .noun,        "m"),
            ("quimioterapia","chemotherapy",                .noun,        "f"),
            ("radioterapia","radiation therapy",            .noun,        "f"),
            ("diálisis",    "dialysis",                     .noun,        "f"),
            ("suero",       "serum, IV drip",               .noun,        "m"),
            ("catéter",     "catheter",                     .noun,        "m"),
            ("desfibrilador","defibrillator",               .noun,        "m"),
            ("respirador",  "ventilator",                   .noun,        "m"),
            ("camilla",     "stretcher",                    .noun,        "f"),
            ("silla de ruedas","wheelchair",                .noun,        "f"),
            ("muleta",      "crutch",                       .noun,        "f"),
            ("prótesis",    "prosthesis",                   .noun,        "f"),
            ("marcapasos",  "pacemaker",                    .noun,        "m"),
            ("insulina",    "insulin",                      .noun,        "f"),
            ("antiinflamatorio","anti-inflammatory",        .noun,        "m"),
            ("analgésico",  "painkiller",                   .noun,        "m"),
            ("antihistamínico","antihistamine",             .noun,        "m"),
            ("sobredosis",  "overdose",                     .noun,        "f"),
            ("intoxicación","poisoning",                    .noun,        "f"),
            ("quemadura",   "burn",                         .noun,        "f"),
            ("moretón",     "bruise (MX)",                  .noun,        "m"),
            ("torcedura",   "sprain",                       .noun,        "f"),
            ("luxación",    "dislocation",                  .noun,        "f"),

            // ── NOUNS: SCHOOL & ACADEMIA (EXPANDED) ───────────────────────────
            ("rector",      "university president",         .noun,        "m"),
            ("decano",      "dean",                         .noun,        "m"),
            ("catedrático", "professor (senior)",           .noun,        "m"),

            ("tesis",       "thesis",                       .noun,        "f"),
            ("disertación", "dissertation",                 .noun,        "f"),
            ("tesina",      "undergraduate thesis",         .noun,        "f"),
            ("investigador","researcher",                   .noun,        "m"),
            ("becario",     "scholarship recipient",        .noun,        "m"),
            ("intercambio", "exchange (student)",           .noun,        "m"),
            ("pasante",     "intern, student teacher (MX)", .noun,        nil),
            ("servicio social","social service (MX)",       .noun,        "m"),
            ("práctica profesional","professional internship",.noun,      "f"),
            ("examen de admisión","entrance exam",          .noun,        "m"),

            ("inscripción", "enrollment",                   .noun,        "f"),
            ("matrícula",   "tuition, enrollment",          .noun,        "f"),
            ("horario",     "schedule",                     .noun,        "m"),
            ("tutoreo",     "tutoring",                     .noun,        "m"),
            ("asesor",      "advisor",                      .noun,        "m"),
            ("sinodal",     "thesis committee member (MX)", .noun,        "m"),
            ("evaluación",  "evaluation",                   .noun,        "f"),
            ("retroalimentación","feedback",                .noun,        "f"),
            ("rúbrica",     "rubric",                       .noun,        "f"),
            ("portafolio",  "portfolio",                    .noun,        "m"),
            ("presentación","presentation",                 .noun,        "f"),
            ("exposición oral","oral presentation",         .noun,        "f"),
            ("trabajo en equipo","teamwork",                .noun,        "m"),
            ("proyecto final","final project",              .noun,        "m"),
            ("trabajo escrito","written paper",             .noun,        "m"),

            // ── NOUNS: ENTERTAINMENT & MEDIA (EXPANDED) ───────────────────────
            ("entretenimiento","entertainment",             .noun,        "m"),
            ("industria del entretenimiento","entertainment industry",.noun,"f"),
            ("taquilla",    "box office",                   .noun,        "f"),
            ("estreno",     "premiere",                     .noun,        "m"),
            ("nominación",  "nomination",                   .noun,        "f"),
            ("premio",      "award, prize",                 .noun,        "m"),
            ("Óscar",       "Oscar",                        .noun,        "m"),
            ("Ariel",       "Ariel award (MX film)",        .noun,        "m"),
            ("cortometraje","short film",                   .noun,        "m"),
            ("documental",  "documentary",                  .noun,        "m"),
            ("telenovela",  "soap opera",                   .noun,        "f"),
            ("caricatura",  "cartoon",                      .noun,        "f"),
            ("animación",   "animation",                    .noun,        "f"),
            ("doblaje",     "dubbing",                      .noun,        "m"),
            ("subtítulos",  "subtitles",                    .noun,        "m"),
            ("efectos especiales","special effects",        .noun,        "m"),
            ("banda sonora","soundtrack",                   .noun,        "f"),
            ("elenco",      "cast",                         .noun,        "m"),
            ("reparto",     "cast, distribution",           .noun,        "m"),
            ("guionista",   "screenwriter",                 .noun,        nil),
            ("camarógrafo", "cameraman",                    .noun,        "m"),
            ("montajista",  "film editor",                  .noun,        nil),
            ("productor ejecutivo","executive producer",    .noun,        "m"),
            ("sinopsis",    "synopsis",                     .noun,        "f"),
            ("reseña de película","movie review",           .noun,        "f"),
            ("videojuego",  "video game",                   .noun,        "m"),
            ("consola",     "gaming console",               .noun,        "f"),

            ("nivel",       "level",                        .noun,        "m"),

            ("personaje jugable","playable character",      .noun,        "m"),
            ("modo multijugador","multiplayer mode",        .noun,        "m"),
            ("transmisión en vivo","live stream",           .noun,        "f"),
            ("podcast",     "podcast",                      .noun,        "m"),
            ("episodio",    "episode",                      .noun,        "m"),

            ("estrella de televisión","TV star",            .noun,        "f"),
            ("presentador", "host, presenter",              .noun,        "m"),
            ("comentarista","commentator",                  .noun,        nil),
            ("conductora",  "host (f)",                     .noun,        "f"),

            // ── NOUNS: SPORTS (EXPANDED) ───────────────────────────────────────

            ("maratón",     "marathon",                     .noun,        "m"),
            ("triatlón",    "triathlon",                    .noun,        "m"),
            ("ciclismo",    "cycling",                      .noun,        "m"),
            ("ciclista",    "cyclist",                      .noun,        nil),
            ("boxeo",       "boxing",                       .noun,        "m"),
            ("boxeador",    "boxer",                        .noun,        "m"),
            ("lucha libre", "freestyle wrestling (MX)",     .noun,        "f"),
            ("luchador",    "wrestler",                     .noun,        "m"),
            ("kárate",      "karate",                       .noun,        "m"),
            ("taekwondo",   "taekwondo",                    .noun,        "m"),
            ("judo",        "judo",                         .noun,        "m"),
            ("golf",        "golf",                         .noun,        "m"),

            ("tenis de mesa","table tennis",                .noun,        "m"),
            ("badminton",   "badminton",                    .noun,        "m"),

            ("softbol",     "softball",                     .noun,        "m"),
            ("americano",   "American football",            .noun,        "m"),
            ("rugby",       "rugby",                        .noun,        "m"),
            ("hockey",      "hockey",                       .noun,        "m"),
            ("polo acuático","water polo",                  .noun,        "m"),
            ("clavados",    "diving (MX)",                  .noun,        "m"),
            ("gimnasia",    "gymnastics",                   .noun,        "f"),
            ("esgrima",     "fencing",                      .noun,        "f"),
            ("equitación",  "horseback riding",             .noun,        "f"),
            ("hipódromo",   "racetrack",                    .noun,        "m"),
            ("corrida de toros","bullfight",                .noun,        "f"),
            ("torero",      "bullfighter",                  .noun,        "m"),

            ("hincha",      "supporter, fan",               .noun,        nil),
            ("barra",       "fan section (MX)",             .noun,        "f"),
            ("porras",      "cheers, pep squad (MX)",       .noun,        "f"),
            ("copa del mundo","World Cup",                  .noun,        "f"),
            ("olimpiadas",  "Olympic Games",                .noun,        "f"),
            ("medallista",  "medal winner",                 .noun,        nil),
            ("plusmarquista","record holder",               .noun,        nil),

            ("practicar",   "to practice",                  .infinitive,  nil),
            ("ejercitar",   "to exercise",                  .infinitive,  nil),

            ("estirar",     "to stretch",                   .infinitive,  nil),

            // ── NOUNS: ANIMALS (EXPANDED) ──────────────────────────────────────
            ("mamífero",    "mammal",                       .noun,        "m"),
            ("reptil",      "reptile",                      .noun,        "m"),
            ("anfibio",     "amphibian",                    .noun,        "m"),
            ("insecto",     "insect",                       .noun,        "m"),
            ("arácnido",    "arachnid",                     .noun,        "m"),
            ("crustáceo",   "crustacean",                   .noun,        "m"),
            ("molusco",     "mollusk",                      .noun,        "m"),
            ("pez espada",  "swordfish",                    .noun,        "m"),
            ("pez payaso",  "clownfish",                    .noun,        "m"),
            ("manta raya",  "manta ray",                    .noun,        "f"),
            ("pulpo",       "octopus",                      .noun,        "m"),
            ("cangrejo",    "crab",                         .noun,        "m"),
            ("langosta",    "lobster",                      .noun,        "f"),
            ("almeja",      "clam",                         .noun,        "f"),
            ("mejillón",    "mussel",                       .noun,        "m"),
            ("caracol",     "snail",                        .noun,        "m"),
            ("gusano",      "worm",                         .noun,        "m"),
            ("oruga",       "caterpillar",                  .noun,        "f"),
            ("cigarra",     "cicada",                       .noun,        "f"),
            ("chapulín",    "grasshopper (MX)",             .noun,        "m"),
            ("escarabajo",  "beetle",                       .noun,        "m"),
            ("luciérnaga",  "firefly",                      .noun,        "f"),
            ("mosquito",    "mosquito",                     .noun,        "m"),
            ("pulga",       "flea",                         .noun,        "f"),
            ("garrapata",   "tick",                         .noun,        "f"),
            ("alacrán",     "scorpion (MX)",                .noun,        "m"),
            ("víbora",      "viper, snake (MX)",            .noun,        "f"),
            ("iguana",      "iguana",                       .noun,        "f"),
            ("camaleón",    "chameleon",                    .noun,        "m"),
            ("axolote",     "axolotl (MX)",                 .noun,        "m"),
            ("ajolote",     "axolotl (alt MX spelling)",    .noun,        "m"),
            ("tapir",       "tapir",                        .noun,        "m"),
            ("ocelote",     "ocelot",                       .noun,        "m"),
            ("puma",        "puma",                         .noun,        "m"),
            ("guacamaya",   "macaw (MX)",                   .noun,        "f"),
            ("colibrí",     "hummingbird",                  .noun,        "m"),
            ("pelícano",    "pelican",                      .noun,        "m"),
            ("flamenco",    "flamingo",                     .noun,        "m"),
            ("pingüino",    "penguin",                      .noun,        "m"),
            ("cóndor",      "condor",                       .noun,        "m"),
            ("quetzal",     "quetzal bird",                 .noun,        "m"),
            ("tucán",       "toucan",                       .noun,        "m"),
            ("búho",        "owl",                          .noun,        "m"),
            ("lechuza",     "barn owl",                     .noun,        "f"),
            ("halcón",      "falcon",                       .noun,        "m"),
            ("gavilán",     "hawk",                         .noun,        "m"),
            ("zorro",       "fox",                          .noun,        "m"),
            ("mapache",     "raccoon",                      .noun,        "m"),
            ("tejón",       "badger",                       .noun,        "m"),
            ("nutria",      "otter",                        .noun,        "f"),
            ("foca",        "seal",                         .noun,        "f"),
            ("morsa",       "walrus",                       .noun,        "f"),
            ("manatí",      "manatee",                      .noun,        "m"),
            ("elefante",    "elephant",                     .noun,        "m"),
            ("rinoceronte", "rhinoceros",                   .noun,        "m"),
            ("hipopótamo",  "hippopotamus",                 .noun,        "m"),
            ("jirafa",      "giraffe",                      .noun,        "f"),
            ("cebra",       "zebra",                        .noun,        "f"),
            ("gorila",      "gorilla",                      .noun,        "m"),
            ("chimpancé",   "chimpanzee",                   .noun,        "m"),
            ("mono",        "monkey",                       .noun,        "m"),
            ("orangután",   "orangutan",                    .noun,        "m"),
            ("panda",       "panda",                        .noun,        "m"),
            ("koala",       "koala",                        .noun,        "m"),
            ("canguro",     "kangaroo",                     .noun,        "m"),
            ("camello",     "camel",                        .noun,        "m"),
            ("llama",       "llama",                        .noun,        "f"),
            ("alpaca",      "alpaca",                       .noun,        "f"),
            ("búfalo",      "buffalo",                      .noun,        "m"),
            ("bisonte",     "bison",                        .noun,        "m"),
            ("venado",      "deer",                         .noun,        "m"),
            ("alce",        "moose, elk",                   .noun,        "m"),
            ("jabalí",      "wild boar",                    .noun,        "m"),
            ("armadillo",   "armadillo",                    .noun,        "m"),
            ("tlacuache",   "opossum (MX)",                 .noun,        "m"),

            ("zorrillo",    "skunk (MX)",                   .noun,        "m"),
            ("tuza",        "pocket gopher (MX)",           .noun,        "f"),
            ("topo",        "mole (animal)",                .noun,        "m"),

            // ── NOUNS: PLANTS (EXPANDED) ───────────────────────────────────────
            ("arbusto",     "bush, shrub",                  .noun,        "m"),
            ("enredadera",  "vine, creeper",                .noun,        "f"),
            ("cactus",      "cactus",                       .noun,        "m"),
            ("sábila",      "aloe vera (MX)",               .noun,        "f"),
            ("maguey",      "agave maguey",                 .noun,        "m"),
            ("agave",       "agave",                        .noun,        "m"),
            ("pino",        "pine tree",                    .noun,        "m"),
            ("cedro",       "cedar",                        .noun,        "m"),
            ("encino",      "oak (MX)",                     .noun,        "m"),
            ("roble",       "oak",                          .noun,        "m"),
            ("palma",       "palm tree",                    .noun,        "f"),
            ("sauce",       "willow",                       .noun,        "m"),
            ("ahuejote",    "Mexican cypress (MX)",         .noun,        "m"),
            ("fresno",      "ash tree",                     .noun,        "m"),
            ("laurel",      "laurel",                       .noun,        "m"),
            ("jacaranda",   "jacaranda",                    .noun,        "f"),
            ("bougainvillea","bougainvillea",               .noun,        "f"),
            ("bugambilia",  "bougainvillea (MX)",           .noun,        "f"),
            ("orquídea",    "orchid",                       .noun,        "f"),

            ("margarita",   "daisy",                        .noun,        "f"),
            ("girasol",     "sunflower",                    .noun,        "m"),
            ("clavel",      "carnation",                    .noun,        "m"),
            ("tulipán",     "tulip",                        .noun,        "m"),
            ("lirio",       "lily",                         .noun,        "m"),
            ("azalea",      "azalea",                       .noun,        "f"),
            ("magnolia",    "magnolia",                     .noun,        "f"),
            ("gardenia",    "gardenia",                     .noun,        "f"),
            ("pétalo",      "petal",                        .noun,        "m"),
            ("espina",      "thorn, spine",                 .noun,        "f"),
            ("corteza",     "bark, crust",                  .noun,        "f"),
            ("resina",      "resin",                        .noun,        "f"),
            ("savia",       "sap",                          .noun,        "f"),
            ("musgo",       "moss",                         .noun,        "m"),
            ("helecho",     "fern",                         .noun,        "m"),
            ("bambú",       "bamboo",                       .noun,        "m"),
            ("caña",        "reed, cane",                   .noun,        "f"),


            ("avena",       "oats",                         .noun,        "f"),
            ("espiga",      "ear of grain",                 .noun,        "f"),
            ("fruto",       "fruit (botanical)",            .noun,        "m"),
            ("nuez",        "walnut, nut",                  .noun,        "f"),
            ("almendra",    "almond",                       .noun,        "f"),
            ("cacahuate",   "peanut (MX)",                  .noun,        "m"),
            ("piñón",       "pine nut",                     .noun,        "m"),
            ("pistache",    "pistachio",                    .noun,        "m"),
            ("ciruela",     "plum",                         .noun,        "f"),
            ("durazno",     "peach (MX)",                   .noun,        "m"),
            ("chabacano",   "apricot (MX)",                 .noun,        "m"),
            ("pera",        "pear",                         .noun,        "f"),
            ("uva",         "grape",                        .noun,        "f"),

            ("zarzamora",   "blackberry",                   .noun,        "f"),
            ("frambuesa",   "raspberry",                    .noun,        "f"),
            ("cereza",      "cherry",                       .noun,        "f"),
            ("kiwi",        "kiwi",                         .noun,        "m"),
            ("melón",       "melon",                        .noun,        "m"),
            ("piña",        "pineapple",                    .noun,        "f"),
            ("coco",        "coconut",                      .noun,        "m"),
            ("pitaya",      "dragon fruit (MX)",            .noun,        "f"),
            ("tuna",        "prickly pear (MX)",            .noun,        "f"),
            ("tejocote",    "Mexican hawthorn (MX)",        .noun,        "m"),
            ("zapote",      "sapodilla (MX)",               .noun,        "m"),
            ("chicozapote", "sapodilla fruit (MX)",         .noun,        "m"),
            ("mamey",       "mamey sapote (MX)",            .noun,        "m"),
            ("jícama",      "jicama (MX)",                  .noun,        "f"),

            ("nopales",     "cactus paddles (MX)",          .noun,        "m"),
            ("xoconostle",  "sour prickly pear (MX)",       .noun,        "m"),
            ("huauzontle",  "Mexican herb grain (MX)",      .noun,        "m"),
            ("quelite",     "wild greens (MX)",             .noun,        "m"),
            ("verdolaga",   "purslane (MX)",                .noun,        "f"),
            ("chepiche",    "leafy herb (MX Oaxaca)",       .noun,        "m"),
            ("huitlacoche", "corn fungus delicacy (MX)",    .noun,        "m"),

            // ── NOUNS: RELIGION (EXPANDED) ─────────────────────────────────────
            ("catolicismo", "Catholicism",                  .noun,        "m"),
            ("protestantismo","Protestantism",              .noun,        "m"),
            ("evangelismo", "Evangelism",                   .noun,        "m"),
            ("judaísmo",    "Judaism",                      .noun,        "m"),
            ("islamismo",   "Islam",                        .noun,        "m"),
            ("budismo",     "Buddhism",                     .noun,        "m"),
            ("hinduismo",   "Hinduism",                     .noun,        "m"),
            ("ateo",        "atheist",                      .noun,        "m"),
            ("agnóstico",   "agnostic",                     .noun,        "m"),
            ("creyente",    "believer",                     .noun,        nil),
            ("fiel",        "faithful, parishioner",        .noun,        nil),
            ("párroco",     "parish priest",                .noun,        "m"),
            ("obispo",      "bishop",                       .noun,        "m"),
            ("cardenal",    "cardinal",                     .noun,        "m"),

            ("monje",       "monk",                         .noun,        "m"),
            ("monja",       "nun",                          .noun,        "f"),
            ("convento",    "convent",                      .noun,        "m"),
            ("monasterio",  "monastery",                    .noun,        "m"),
            ("seminario",   "seminary",                     .noun,        "m"),
            ("diócesis",    "diocese",                      .noun,        "f"),
            ("parroquia",   "parish",                       .noun,        "f"),
            ("capilla",     "chapel",                       .noun,        "f"),
            ("ermita",      "hermitage",                    .noun,        "f"),
            ("santuario",   "sanctuary",                    .noun,        "m"),
            ("basílica",    "basilica",                     .noun,        "f"),
            ("sagrada escritura","holy scripture",          .noun,        "f"),
            ("biblia",      "bible",                        .noun,        "f"),
            ("evangelio",   "gospel",                       .noun,        "m"),

            ("pecado",      "sin",                          .noun,        "m"),
            ("gracia",      "grace",                        .noun,        "f"),
            ("salvación",   "salvation",                    .noun,        "f"),
            ("redención",   "redemption",                   .noun,        "f"),
            ("infierno",    "hell",                         .noun,        "m"),
            ("paraíso",     "paradise, heaven",             .noun,        "m"),
            ("purgatorio",  "purgatory",                    .noun,        "m"),
            ("limbo",       "limbo",                        .noun,        "m"),
            ("exorcismo",   "exorcism",                     .noun,        "m"),
            ("aparición",   "apparition",                   .noun,        "f"),
            ("guadalupano", "devotee of Virgin of Guadalupe",.adjective,  "m"),
            ("virgen de guadalupe","Virgin of Guadalupe",   .noun,        "f"),
            ("día de guadalupe","Dec 12 feast day (MX)",    .noun,        "m"),
            ("peregrinación","pilgrimage",                  .noun,        "f"),
            ("peregrino",   "pilgrim",                      .noun,        "m"),
            ("retiro espiritual","spiritual retreat",       .noun,        "m"),
            ("exvoto",      "ex-voto offering (MX)",        .noun,        "m"),
            ("nicho",       "niche, shrine nook",           .noun,        "m"),
            ("capilla ardiente","funeral chapel",           .noun,        "f"),
            ("novenario",   "nine-day mourning period",     .noun,        "m"),
            ("cuaresma",    "Lent",                         .noun,        "f"),
            ("semana santa","Holy Week",                    .noun,        "f"),
            ("navidad",     "Christmas",                    .noun,        "f"),
            ("noche buena", "Christmas Eve",                .noun,        "f"),
            ("pascua",      "Easter",                       .noun,        "f"),
            ("epifanía",    "Epiphany",                     .noun,        "f"),
            ("día de reyes","Three Kings Day (Jan 6)",      .noun,        "m"),
            ("rosca de reyes","Three Kings bread (MX)",     .noun,        "f"),
            ("candelaria",  "Candlemas (Feb 2)",            .noun,        "f"),

            // ── NOUNS: MEXICAN GEOGRAPHY & CULTURE ────────────────────────────
            ("CDMX",        "Mexico City (acronym)",        .noun,        "f"),
            ("chilango",    "person from Mexico City",      .noun,        "m"),
            ("defeño",      "person from DF (MX)",          .noun,        "m"),
            ("tapatío",     "person from Guadalajara",      .noun,        "m"),
            ("regio",       "person from Monterrey",        .noun,        "m"),
            ("poblano",     "person from Puebla",           .noun,        "m"),
            ("oaxaqueño",   "person from Oaxaca",           .noun,        "m"),
            ("yucateco",    "person from Yucatán",          .noun,        "m"),

            ("sureño",      "southerner",                   .noun,        "m"),
            ("fronterizo",  "border person",                .noun,        "m"),

            ("tlapalería",  "hardware store (MX)",          .noun,        "f"),
            ("papelería",   "stationery store (MX)",        .noun,        "f"),
            ("tortillería", "tortilla shop",                .noun,        "f"),
            ("molino",      "grain mill",                   .noun,        "m"),
            ("cremería",    "dairy shop (MX)",              .noun,        "f"),
            ("miscelánea",  "corner store (MX)",            .noun,        "f"),
            ("abarrotes",   "grocery, general store (MX)",  .noun,        "m"),

            ("neverías",    "ice cream shops (MX)",         .noun,        "f"),
            ("cantina",     "cantina, bar (MX)",            .noun,        "f"),
            ("pulquería",   "pulque bar (MX)",              .noun,        "f"),
            ("coctelería",  "cocktail bar",                 .noun,        "f"),
            ("antro",       "nightclub (MX)",               .noun,        "m"),
            ("botanero",    "bar with free snacks (MX)",    .noun,        "m"),
            ("fonda",       "simple restaurant (MX)",       .noun,        "f"),

            ("expendio",    "small store, outlet",          .noun,        "m"),
            ("puesto",      "street stall",                 .noun,        "m"),
            ("carrito",     "food cart (MX)",               .noun,        "m"),
            ("trajinera",   "gondola boat (Xochimilco MX)", .noun,        "f"),
            ("chinampas",   "floating gardens (MX)",        .noun,        "f"),
            ("teotihuacán", "Teotihuacan site",             .noun,        "m"),
            ("pirámide",    "pyramid",                      .noun,        "f"),
            ("tlatelolco",  "Tlatelolco (MX historic site)",.noun,        "m"),
            ("chapultepec", "Chapultepec park (MX)",        .noun,        "m"),
            ("xochimilco",  "Xochimilco (MX)",              .noun,        "m"),
            ("coyoacán",    "Coyoacán (MX neighborhood)",   .noun,        "m"),
            ("condesa",     "La Condesa (MX neighborhood)", .noun,        "f"),
            ("roma",        "Roma (MX neighborhood)",       .noun,        "f"),
            ("polanco",     "Polanco (MX neighborhood)",    .noun,        "m"),
            ("tepito",      "Tepito (MX neighborhood)",     .noun,        "m"),
            ("garibaldi",   "Garibaldi square (MX)",        .noun,        "m"),
            ("bellas artes","Palacio de Bellas Artes (MX)", .noun,        "m"),
            ("ángel de la independencia","Independence monument (MX)",.noun,"m"),
            ("periférico",  "ring road (MX)",               .noun,        "m"),
            ("insurgentes", "Insurgentes Ave (MX)",         .noun,        "f"),
            ("reforma",     "Paseo de la Reforma (MX)",     .noun,        "f"),
            ("tlalpan",     "Tlalpan (MX borough)",         .noun,        "m"),
            ("iztapalapa",  "Iztapalapa (MX borough)",      .noun,        "m"),
            ("ecatec",      "Ecatec (MX city)",             .noun,        "m"),
            ("neza",        "Neza (Nezahualcóyotl, MX)",    .noun,        "m"),

            // ── Reflexive / self-care verbs ───────────────────────────────────




            ("desvestirse", "to undress",                   .infinitive,  nil),






            ("divertirse",  "to have fun",                  .infinitive,  nil),
            ("aburrirse",   "to get bored",                 .infinitive,  nil),
            ("cansarse",    "to get tired",                 .infinitive,  nil),
            ("enojarse",    "to get angry",                 .infinitive,  nil),
            ("preocuparse", "to worry",                     .infinitive,  nil),
            ("alegrarse",   "to become happy",              .infinitive,  nil),




            ("quedarse",    "to stay, remain",              .infinitive,  nil),
            ("irse",        "to leave, go away",            .infinitive,  nil),


            ("portarse",    "to behave",                    .infinitive,  nil),





            ("arrepentirse","to regret",                    .infinitive,  nil),
            ("atreverse",   "to dare",                      .infinitive,  nil),
            ("negarse",     "to refuse",                    .infinitive,  nil),
            ("olvidarse",   "to forget",                    .infinitive,  nil),
            ("acordarse",   "to remember",                  .infinitive,  nil),
            ("enterarse",   "to find out",                  .infinitive,  nil),
            ("fijarse",     "to notice, pay attention",     .infinitive,  nil),
            ("aprovecharse","to take advantage",            .infinitive,  nil),

            ("perderse",    "to get lost",                  .infinitive,  nil),
            ("caerse",      "to fall down",                 .infinitive,  nil),
            ("lastimarse",  "to hurt oneself",              .infinitive,  nil),

            ("mejorarse",   "to get better",                .infinitive,  nil),
            ("emborracharse","to get drunk",                .infinitive,  nil),

            ("despertarse", "to wake up",                   .infinitive,  nil),
            ("sentarse",    "to sit down",                  .infinitive,  nil),
            ("pararse",     "to stand up (MX)",             .infinitive,  nil),

            ("reírse",      "to laugh",                     .infinitive,  nil),
            ("burlarse",    "to mock, make fun of",         .infinitive,  nil),
            ("asustarse",   "to get scared",                .infinitive,  nil),
            ("sorprenderse","to be surprised",              .infinitive,  nil),
            ("avergonzarse","to be ashamed",                .infinitive,  nil),
            ("abrazarse",   "to hug each other",            .infinitive,  nil),
            ("besarse",     "to kiss each other",           .infinitive,  nil),
            ("pelearse",    "to fight (with each other)",   .infinitive,  nil),


            ("dedicarse",   "to dedicate oneself",          .infinitive,  nil),
            ("especializarse","to specialize",              .infinitive,  nil),

            ("inscribirse", "to enroll, register",          .infinitive,  nil),


            ("capacitarse", "to train oneself",             .infinitive,  nil),

            // ── Cooking / kitchen verbs ───────────────────────────────────────














            ("sujetar",     "to hold, fasten",              .infinitive,  nil),


            ("enrollar",    "to roll up",                   .infinitive,  nil),
            ("envolver",    "to wrap",                      .infinitive,  nil),
            ("desenvolver", "to unwrap",                    .infinitive,  nil),
            ("rellenar",    "to fill, stuff",               .infinitive,  nil),
            ("vaciar",      "to empty",                     .infinitive,  nil),

            ("revolver",    "to stir, mix up",              .infinitive,  nil),
            ("batir",       "to beat, whisk",               .infinitive,  nil),

            ("rebanar",     "to slice",                     .infinitive,  nil),
            ("rallar",      "to grate",                     .infinitive,  nil),
            ("exprimir",    "to squeeze (juice)",           .infinitive,  nil),
            ("colar",       "to strain, filter",            .infinitive,  nil),



            ("asar",        "to roast, grill",              .infinitive,  nil),


            ("marinar",     "to marinate",                  .infinitive,  nil),


            ("descongelar", "to defrost",                   .infinitive,  nil),
            ("congelar",    "to freeze",                    .infinitive,  nil),
            ("derretir",    "to melt",                      .infinitive,  nil),

            // ── Construction / tech verbs ─────────────────────────────────────






            ("desconectar", "to disconnect",                .infinitive,  nil),



            ("configurar",  "to configure",                 .infinitive,  nil),






            ("escanear",    "to scan",                      .infinitive,  nil),
            ("filtrar",     "to filter",                    .infinitive,  nil),


            ("etiquetar",   "to label, tag",                .infinitive,  nil),
            ("archivar",    "to file, archive",             .infinitive,  nil),
            ("registrar",   "to register, record",          .infinitive,  nil),
            ("documentar",  "to document",                  .infinitive,  nil),






            ("pronosticar", "to forecast, predict",         .infinitive,  nil),

            ("contrastar",  "to contrast",                  .infinitive,  nil),







            // ── Legal / civic nouns ───────────────────────────────────────────




            ("apelación",   "appeal",                       .noun,        "f"),
            ("acusado",     "defendant, accused",           .noun,        "m"),








            ("fraude",      "fraud",                        .noun,        "m"),

            ("soborno",     "bribe",                        .noun,        "m"),
            ("extorsión",   "extortion",                    .noun,        "f"),
            ("secuestro",   "kidnapping",                   .noun,        "m"),
            ("homicidio",   "homicide",                     .noun,        "m"),
            ("detención",   "detention, arrest",            .noun,        "f"),

            ("prisión",     "prison",                       .noun,        "f"),
            ("penal",       "prison, penitentiary",         .noun,        "m"),
            ("celda",       "cell (prison)",                .noun,        "f"),

            ("indulto",     "pardon, reprieve",             .noun,        "m"),
            ("amnistía",    "amnesty",                      .noun,        "f"),


            ("reglamento",  "regulation, rules",            .noun,        "m"),
            ("ordenanza",   "ordinance",                    .noun,        "f"),

            ("alcaldía",    "mayoralty (MX borough)",       .noun,        "f"),

            ("padrón",      "electoral roll, census",       .noun,        "m"),
            ("cédula",      "ID card, certificate",         .noun,        "f"),
            ("acta",        "official record, certificate", .noun,        "f"),

            ("juzgado",     "court, tribunal",              .noun,        "m"),




            // ── Mexican food / drink ──────────────────────────────────────────
            ("quesillo",    "Oaxacan string cheese (MX)",   .noun,        "m"),




            ("pitahaya",    "dragon fruit",                 .noun,        "f"),
            ("guanábana",   "soursop",                      .noun,        "f"),



            ("huarache comida","large corn oval snack (MX)", .noun,       "m"),
            ("tetela",      "triangular corn masa (MX)",    .noun,        "f"),

            ("pambazo",     "sauced sandwich (MX)",         .noun,        "m"),
            ("guajolota",   "torta de tamal (MX CDMX)",     .noun,        "f"),

            ("enmolada",    "tortilla in mole sauce (MX)",  .noun,        "f"),
            ("enfrijolada", "tortilla in bean sauce (MX)",  .noun,        "f"),
            ("entomatada",  "tortilla in tomato sauce (MX)",.noun,        "f"),

            ("memela",      "oval corn masa (MX)",          .noun,        "f"),

            ("champurrado", "chocolate atole (MX)",         .noun,        "m"),
            ("ponche",      "warm fruit punch (MX)",        .noun,        "m"),


            ("sotol",       "sotol spirit (MX)",            .noun,        "m"),
            ("raicilla",    "Jalisco spirit (MX)",          .noun,        "f"),
            ("bacanora",    "Sonoran spirit (MX)",          .noun,        "m"),
            ("charanda",    "Michoacán rum (MX)",           .noun,        "f"),
            ("tejuino",     "fermented corn drink (MX)",    .noun,        "m"),
            ("pozol",       "cacao-corn drink (MX)",        .noun,        "m"),



            ("chicharrón",  "fried pork rind (MX)",         .noun,        "m"),
            ("cecina",      "thin dried/salted meat (MX)",  .noun,        "f"),
            ("tasajo",      "thinly sliced dried beef (MX)",.noun,        "m"),
            ("chorizo",     "chorizo sausage",              .noun,        "m"),
            ("longaniza",   "spiced sausage (MX)",          .noun,        "f"),
            ("moronga",     "blood sausage (MX)",           .noun,        "f"),
            ("machaca",     "shredded dried beef (MX)",     .noun,        "f"),
            ("discada",     "mixed meats on a disc (MX)",   .noun,        "f"),

            ("lechón",      "roast suckling pig",           .noun,        "m"),
            ("cabrito",     "roast kid goat (MX NE)",       .noun,        "m"),
            ("mixtote",     "steamed meat in maguey (MX)",  .noun,        "m"),
            ("adobo",       "chili marinade/sauce (MX)",    .noun,        "m"),

            // ── Clothing / accessories ────────────────────────────────────────
            ("playera",     "T-shirt (MX)",                 .noun,        "f"),

            ("polo",        "polo shirt",                   .noun,        "m"),
            ("blusa",       "blouse",                       .noun,        "f"),
            ("saco ropa",   "blazer, suit jacket (MX)",     .noun,        "m"),
            ("traje",       "suit",                         .noun,        "m"),


            ("minifalda",   "miniskirt",                    .noun,        "f"),

            ("bermuda",     "Bermuda shorts",               .noun,        "f"),
            ("leggins",     "leggings",                     .noun,        "m"),
            ("malla",       "tights, leotard",              .noun,        "f"),
            ("pijama",      "pajamas",                      .noun,        "f"),
            ("bata",        "robe, gown",                   .noun,        "f"),
            ("camisón",     "nightgown",                    .noun,        "m"),


            ("media",       "stocking, hose",               .noun,        "f"),
            ("pantimedia",  "pantyhose (MX)",               .noun,        "f"),
            ("tenis calzado","sneakers (MX)",               .noun,        "m"),
            ("sandalia",    "sandal",                       .noun,        "f"),

            ("mocasín",     "moccasin, loafer",             .noun,        "m"),

            ("tirantes",    "suspenders",                   .noun,        "m"),
            ("pañuelo",     "handkerchief, scarf",          .noun,        "m"),
            ("paliacate",   "bandana (MX)",                 .noun,        "m"),
            ("mascada",     "silk scarf (MX)",              .noun,        "f"),
            ("rebozo",      "traditional shawl (MX)",       .noun,        "m"),
            ("sarape",      "traditional blanket-cloak (MX)",.noun,       "m"),
            ("jorongo",     "poncho-style garment (MX)",    .noun,        "m"),
            ("guayabera",   "guayabera shirt (MX)",         .noun,        "f"),
            ("huipil",      "indigenous blouse (MX)",       .noun,        "m"),

            ("visera",      "visor",                        .noun,        "f"),
            ("boina",       "beret",                        .noun,        "f"),
            ("disfraz",     "costume, disguise",            .noun,        "m"),
            ("uniforme",    "uniform",                      .noun,        "m"),
            ("overol",      "overalls",                     .noun,        "m"),
            ("delantal",    "apron",                        .noun,        "m"),
            ("impermeable", "raincoat",                     .noun,        "m"),

            ("chaleco",     "vest",                         .noun,        "m"),

            ("sudadera",    "hoodie, sweatshirt",           .noun,        "f"),
            ("prendedor",   "brooch, pin",                  .noun,        "m"),
            ("aretes",      "earrings (MX)",                .noun,        "m"),
            ("collar joya", "necklace",                     .noun,        "m"),

            ("tobillera",   "anklet",                       .noun,        "f"),

            ("bolso",       "handbag",                      .noun,        "m"),

            ("maletín",     "briefcase",                    .noun,        "m"),
            ("paraguas",    "umbrella",                     .noun,        "m"),
            ("bastón",      "cane, walking stick",          .noun,        "m"),

            ("mitón",       "mitten",                       .noun,        "m"),
            ("orejera",     "earmuff",                      .noun,        "f"),

            ("manga",       "sleeve",                       .noun,        "f"),
            ("bolsillo",    "pocket",                       .noun,        "m"),
            ("cierre",      "zipper (MX)",                  .noun,        "m"),
            ("botón ropa",  "button",                       .noun,        "m"),
            ("costura",     "seam, sewing",                 .noun,        "f"),

            ("hilo",        "thread",                       .noun,        "m"),
            ("aguja costura","needle",                      .noun,        "f"),

            // ── Body / anatomy (more) ─────────────────────────────────────────
            ("ceja",        "eyebrow",                      .noun,        "f"),
            ("pestaña",     "eyelash",                      .noun,        "f"),
            ("párpado",     "eyelid",                       .noun,        "m"),
            ("pupila",      "pupil (eye)",                  .noun,        "f"),
            ("retina",      "retina",                       .noun,        "f"),
            ("córnea",      "cornea",                       .noun,        "f"),
            ("sien",        "temple (head)",                .noun,        "f"),
            ("nuca",        "nape of neck",                 .noun,        "f"),
            ("clavícula",   "collarbone",                   .noun,        "f"),
            ("esternón",    "sternum, breastbone",          .noun,        "m"),
            ("costilla",    "rib",                          .noun,        "f"),

            ("sacro",       "sacrum",                       .noun,        "m"),

            ("espinilla",   "shin; blackhead (MX)",         .noun,        "f"),


            ("fosa nasal",  "nostril",                      .noun,        "f"),
            ("pómulo",      "cheekbone",                    .noun,        "m"),
            ("barbilla",    "chin",                         .noun,        "f"),
            ("mandíbula",   "jaw",                          .noun,        "f"),
            ("encía",       "gum (mouth)",                  .noun,        "f"),
            ("paladar",     "palate",                       .noun,        "m"),
            ("amígdala",    "tonsil",                       .noun,        "f"),
            ("laringe",     "larynx",                       .noun,        "f"),
            ("tráquea",     "trachea",                      .noun,        "f"),
            ("esófago",     "esophagus",                    .noun,        "m"),
            ("vesícula biliar","gallbladder",               .noun,        "f"),
            ("páncreas",    "pancreas",                     .noun,        "m"),
            ("bazo",        "spleen",                       .noun,        "m"),
            ("glándula",    "gland",                        .noun,        "f"),
            ("tiroides",    "thyroid",                      .noun,        "f"),
            ("ovario",      "ovary",                        .noun,        "m"),
            ("útero",       "uterus",                       .noun,        "m"),
            ("próstata",    "prostate",                     .noun,        "f"),
            ("testículo",   "testicle",                     .noun,        "m"),
            ("uretra",      "urethra",                      .noun,        "f"),
            ("vejiga",      "bladder",                      .noun,        "f"),
            ("pelvis",      "pelvis",                       .noun,        "f"),
            ("cartílago",   "cartilage",                    .noun,        "m"),
            ("ligamento",   "ligament",                     .noun,        "m"),
            ("tendón",      "tendon",                       .noun,        "m"),
            ("nervio",      "nerve",                        .noun,        "m"),


            ("enzima",      "enzyme",                       .noun,        "f"),

            ("glucosa",     "glucose",                      .noun,        "f"),
            ("colesterol",  "cholesterol",                  .noun,        "m"),
            ("hemoglobina", "hemoglobin",                   .noun,        "f"),
            ("plaqueta",    "platelet",                     .noun,        "f"),
            ("leucocito",   "white blood cell",             .noun,        "m"),
            ("eritrocito",  "red blood cell",               .noun,        "m"),
            ("plasma",      "plasma",                       .noun,        "m"),





            ("antiviral",   "antiviral",                    .noun,        "m"),

            ("bisturí",     "scalpel",                      .noun,        "m"),



            ("gasa",        "gauze",                        .noun,        "f"),
            ("sutura",      "suture, stitch",               .noun,        "f"),










            ("ultrasonido", "ultrasound",                   .noun,        "m"),



            ("cápsula",     "capsule",                      .noun,        "f"),
            ("jarabe",      "syrup",                        .noun,        "m"),
            ("pomada",      "ointment, cream",              .noun,        "f"),
            ("parche",      "patch (medicine)",             .noun,        "m"),


            // ── Transport / traffic ───────────────────────────────────────────

            ("libramiento", "bypass road (MX)",             .noun,        "m"),
            ("cuota",       "toll; fee",                    .noun,        "f"),




            ("rotonda",     "roundabout",                   .noun,        "f"),




            ("mediana",     "median strip",                 .noun,        "f"),
            ("camellón",    "median divider (MX)",          .noun,        "m"),

            ("ciclovía",    "bike lane",                    .noun,        "f"),
            ("paradero",    "bus stop (MX)",                .noun,        "m"),
            ("mototaxi",    "motorcycle taxi (MX)",         .noun,        "m"),
            ("bicitaxi",    "bicycle taxi (MX)",            .noun,        "m"),

            ("combi",       "minivan bus (MX)",             .noun,        "f"),

            ("trolebús",    "trolleybus",                   .noun,        "m"),
            ("tren suburbano","commuter train",             .noun,        "m"),
            ("tren ligero", "light rail (MX CDMX)",         .noun,        "m"),
            ("cablebús",    "cable car transit (MX CDMX)",  .noun,        "m"),
            ("teleférico",  "cable car",                    .noun,        "m"),
            ("transbordador","ferry",                       .noun,        "m"),
            ("crucero barco","cruise ship",                 .noun,        "m"),

            ("panga",       "small flat-bottomed boat",     .noun,        "f"),
            ("canoa",       "canoe",                        .noun,        "f"),
            ("kayak",       "kayak",                        .noun,        "m"),
            ("velero",      "sailboat",                     .noun,        "m"),
            ("yate",        "yacht",                        .noun,        "m"),

            ("avioneta",    "small plane",                  .noun,        "f"),
            ("dron",        "drone",                        .noun,        "m"),
            ("paracaídas",  "parachute",                    .noun,        "m"),

            // ── Housing / infrastructure ──────────────────────────────────────
            ("depa",        "apartment (MX short)",         .noun,        "m"),

            ("estudio",     "studio apartment",             .noun,        "m"),
            ("loft",        "loft apartment",               .noun,        "m"),
            ("ático",       "penthouse, attic",             .noun,        "m"),
            ("jacal",       "humble hut (MX)",              .noun,        "m"),

            ("condominio",  "condominium",                  .noun,        "m"),
            ("fraccionamiento","housing development (MX)",  .noun,        "m"),
            ("privada",     "private gated street (MX)",    .noun,        "f"),
            ("portón",      "large gate",                   .noun,        "m"),
            ("interfón",    "intercom (MX)",                .noun,        "m"),

            ("azotea",      "rooftop terrace",              .noun,        "f"),

            ("palapa",      "thatched roof shelter (MX)",   .noun,        "f"),
            ("quiosco",     "kiosk, bandstand",             .noun,        "m"),
            ("fuente ornamental","ornamental fountain",     .noun,        "f"),
            ("columpio",    "swing (playground)",           .noun,        "m"),
            ("resbaladilla","slide (MX playground)",        .noun,        "f"),

            ("cisterna",    "water cistern (MX)",           .noun,        "f"),
            ("tinaco",      "rooftop water tank (MX)",      .noun,        "m"),
            ("lavadero",    "laundry sink (MX)",            .noun,        "m"),
            ("tendedero",   "clothesline",                  .noun,        "m"),
            ("tabique",     "brick (MX)",                   .noun,        "m"),
            ("loseta",      "floor tile (MX)",              .noun,        "f"),
            ("azulejo",     "glazed ceramic tile",          .noun,        "m"),
            ("adoquín",     "cobblestone, paving block",    .noun,        "m"),
            ("zaguán",      "entryway, vestibule (MX)",     .noun,        "m"),
            ("cancel",      "room divider, partition (MX)", .noun,        "m"),
            ("persiana",    "blind, shutter",               .noun,        "f"),
            ("mosquitero",  "mosquito screen",              .noun,        "m"),
            ("gotera",      "leak, drip",                   .noun,        "f"),
            ("grieta",      "crack (in wall)",              .noun,        "f"),
            ("desagüe",     "drain, drainage",              .noun,        "m"),


            ("coladera",    "drain grate (MX)",             .noun,        "f"),

            // ── Finance / employment ──────────────────────────────────────────

            ("enganche",    "down payment (MX)",            .noun,        "m"),
            ("mensualidad", "monthly payment",              .noun,        "f"),

            ("quincena",    "biweekly paycheck (MX)",       .noun,        "f"),
            ("nómina",      "payroll",                      .noun,        "f"),
            ("cheque",      "check (payment)",              .noun,        "m"),
            ("comprobante", "proof of payment, receipt",    .noun,        "m"),
            ("estado de cuenta","account statement",        .noun,        "m"),
            ("saldo",       "balance (account)",            .noun,        "m"),
            ("tasa de interés","interest rate",             .noun,        "f"),


            ("austeridad",  "austerity",                    .noun,        "f"),

            ("fondo",       "fund; background",             .noun,        "m"),
            ("fideicomiso", "trust (financial)",            .noun,        "m"),
            ("bolsa de valores","stock exchange",           .noun,        "f"),
            ("acción bursátil","share, stock",              .noun,        "f"),
            ("bono financiero","bond",                      .noun,        "m"),
            ("dividendo",   "dividend",                     .noun,        "m"),
            ("rendimiento", "return, yield, performance",   .noun,        "m"),


            ("déficit",     "deficit",                      .noun,        "m"),
            ("superávit",   "surplus",                      .noun,        "m"),



            ("cotización",  "quote, price quote",           .noun,        "f"),
            ("licitación",  "public tender/bid",            .noun,        "f"),
            ("cláusula",    "clause",                       .noun,        "f"),
            ("rescisión",   "rescission, cancellation",     .noun,        "f"),
            ("liquidación", "settlement, liquidation",      .noun,        "f"),
            ("finiquito",   "final settlement (employment)",.noun,        "m"),
            ("indemnización","compensation, indemnity",     .noun,        "f"),



            ("vacante",     "job opening",                  .noun,        "f"),
            ("entrevista laboral","job interview",          .noun,        "f"),
            ("curriculum",  "résumé, CV",                   .noun,        "m"),
            ("ascenso laboral","promotion (job)",           .noun,        "m"),
            ("despido",     "firing, dismissal",            .noun,        "m"),
            ("renuncia",    "resignation",                  .noun,        "f"),
            ("pensión",     "pension",                      .noun,        "f"),
            ("jubilación",  "retirement",                   .noun,        "f"),
            ("imss",        "Mexican social security (MX)", .noun,        "m"),
            ("afore",       "retirement fund (MX)",         .noun,        "f"),
            ("infonavit",   "housing fund (MX)",            .noun,        "m"),
            ("sat",         "tax authority (MX)",           .noun,        "m"),
            ("rfc",         "tax ID number (MX)",           .noun,        "m"),
            ("curp",        "national ID code (MX)",        .noun,        "f"),

            // ── Education (more) ──────────────────────────────────────────────
            ("kínder",      "kindergarten (MX)",            .noun,        "m"),
            ("preescolar",  "preschool",                    .noun,        "m"),


            ("preparatoria","high school (MX)",             .noun,        "f"),
            ("bachillerato","high school diploma (MX)",     .noun,        "m"),




            ("especialidad","specialization",               .noun,        "f"),
            ("diplomado",   "diploma program",              .noun,        "m"),
            ("certificación","certification",               .noun,        "f"),



            ("temario",     "syllabus, list of topics",     .noun,        "m"),
            ("apunte",      "class notes (MX)",             .noun,        "m"),
            ("resumen",     "summary",                      .noun,        "m"),
            ("ensayo escolar","essay",                      .noun,        "m"),

            ("monografía",  "monograph",                    .noun,        "f"),

            ("UNAM",        "National University (MX)",     .noun,        "f"),
            ("IPN",         "Polytechnic Institute (MX)",   .noun,        "m"),
            ("SEP",         "Secretariat of Education (MX)",.noun,        "f"),
            ("aula",        "classroom",                    .noun,        "f"),

            ("plagio",      "plagiarism",                   .noun,        "m"),
            ("beca académica","academic scholarship",       .noun,        "f"),
            ("intercambio estudiantil","student exchange",  .noun,        "m"),

            ("crédito académico","academic credit",         .noun,        "m"),



            // ── Digital / social media ────────────────────────────────────────
            ("tuit",        "tweet (MX adapted)",           .noun,        "m"),



            ("videollamada","video call",                   .noun,        "f"),

            ("seguidores",  "followers",                    .noun,        "m"),



            ("sticker",     "sticker",                      .noun,        "m"),

            ("privacidad",  "privacy",                      .noun,        "f"),

            ("autenticación","authentication",              .noun,        "f"),
            ("huella digital","fingerprint",                .noun,        "f"),
            ("reconocimiento facial","facial recognition",  .noun,        "m"),

            ("hackeo",      "hacking",                      .noun,        "m"),
            ("phishing",    "phishing",                     .noun,        "m"),

            ("antivirus",   "antivirus software",           .noun,        "m"),
            ("cortafuegos", "firewall",                     .noun,        "m"),
            ("nube digital","cloud (computing)",            .noun,        "f"),



            ("aprendizaje automático","machine learning",   .noun,        "m"),
            ("chatbot",     "chatbot",                      .noun,        "m"),


            ("criptomoneda","cryptocurrency",               .noun,        "f"),

            ("aplicación móvil","mobile app",               .noun,        "f"),

            ("programación","programming",                  .noun,        "f"),
            ("código fuente","source code",                 .noun,        "m"),
            ("desarrollo de software","software development",.noun,       "m"),
            ("bug",         "software bug",                 .noun,        "m"),
            ("parche software","software patch",            .noun,        "m"),

            // ── More adjectives ───────────────────────────────────────────────
            ("acogedor",    "cozy, welcoming",              .adjective,   nil),
            ("adecuado",    "adequate, appropriate",        .adjective,   nil),
            ("agotado",     "exhausted; sold out",          .adjective,   nil),
            ("ameno",       "pleasant, enjoyable",          .adjective,   nil),

            ("apto",        "suitable, fit",                .adjective,   nil),
            ("arduo",       "arduous, hard",                .adjective,   nil),
            ("austero",     "austere, frugal",              .adjective,   nil),
            ("avaro",       "greedy, miserly",              .adjective,   nil),
            ("brusco",      "sudden; brusque",              .adjective,   nil),
            ("burdo",       "crude, coarse",                .adjective,   nil),
            ("caprichoso",  "capricious, whimsical",        .adjective,   nil),
            ("cauto",       "cautious",                     .adjective,   nil),
            ("célebre",     "famous, celebrated",           .adjective,   nil),
            ("certero",     "accurate, sure",               .adjective,   nil),
            ("chaparro",    "short (person, MX)",           .adjective,   nil),

            ("cínico",      "cynical; shameless",           .adjective,   nil),
            ("compacto",    "compact",                      .adjective,   nil),
            ("compasivo",   "compassionate",                .adjective,   nil),

            ("contundente", "forceful, convincing",         .adjective,   nil),
            ("cotidiano",   "daily, everyday",              .adjective,   nil),

            ("culto",       "educated, cultured",           .adjective,   nil),
            ("dañino",      "harmful",                      .adjective,   nil),
            ("deprimente",  "depressing",                   .adjective,   nil),
            ("descarado",   "brazen, shameless",            .adjective,   nil),

            ("despistado",  "absent-minded",                .adjective,   nil),

            ("discreto",    "discreet",                     .adjective,   nil),
            ("distraído",   "distracted",                   .adjective,   nil),
            ("diverso",     "diverse",                      .adjective,   nil),
            ("duradero",    "durable, long-lasting",        .adjective,   nil),
            ("efímero",     "ephemeral, fleeting",          .adjective,   nil),

            ("entrometido", "meddlesome, nosy",             .adjective,   nil),

            ("estéril",     "sterile, barren",              .adjective,   nil),
            ("estimulante", "stimulating",                  .adjective,   nil),
            ("estricto",    "strict",                       .adjective,   nil),

            ("exagerado",   "exaggerated, over the top",    .adjective,   nil),
            ("exhausto",    "exhausted",                    .adjective,   nil),
            ("exigente",    "demanding",                    .adjective,   nil),
            ("exquisito",   "exquisite",                    .adjective,   nil),


            ("fascinante",  "fascinating",                  .adjective,   nil),
            ("feroz",       "fierce",                       .adjective,   nil),
            ("festivo",     "festive",                      .adjective,   nil),
            ("fiable",      "reliable, trustworthy",        .adjective,   nil),


            ("fogoso",      "passionate, fiery",            .adjective,   nil),
            ("frágil",      "fragile",                      .adjective,   nil),
            ("frugal",      "frugal",                       .adjective,   nil),

            ("furioso",     "furious",                      .adjective,   nil),

            ("genuino",     "genuine",                      .adjective,   nil),

            ("grandioso",   "grandiose",                    .adjective,   nil),


            ("hostil",      "hostile",                      .adjective,   nil),


            ("impecable",   "impeccable",                   .adjective,   nil),
            ("imponente",   "imposing, impressive",         .adjective,   nil),

            ("incómodo",    "uncomfortable",                .adjective,   nil),
            ("indispensable","indispensable",               .adjective,   nil),
            ("inevitable",  "inevitable",                   .adjective,   nil),
            ("ingenioso",   "ingenious, clever",            .adjective,   nil),


            ("inseguro",    "insecure, unsafe",             .adjective,   nil),
            ("intenso",     "intense",                      .adjective,   nil),

            ("íntimo",      "intimate",                     .adjective,   nil),
            ("irresponsable","irresponsible",               .adjective,   nil),

            ("juvenil",     "juvenile, youthful",           .adjective,   nil),

            ("legendario",  "legendary",                    .adjective,   nil),



            ("lindo",       "pretty, cute",                 .adjective,   nil),

            ("loco",        "crazy",                        .adjective,   nil),

            ("luminoso",    "luminous, bright",             .adjective,   nil),

            ("magnífico",   "magnificent",                  .adjective,   nil),
            ("malvado",     "evil, wicked",                 .adjective,   nil),
            ("manso",       "tame, gentle",                 .adjective,   nil),
            ("melancólico", "melancholic",                  .adjective,   nil),

            ("miserable",   "miserable",                    .adjective,   nil),

            ("mojado",      "wet",                          .adjective,   nil),
            ("molesto",     "annoyed, annoying",            .adjective,   nil),
            ("noble",       "noble",                        .adjective,   nil),
            ("nocivo",      "harmful, noxious",             .adjective,   nil),

            ("nutritivo",   "nutritious",                   .adjective,   nil),
            ("obediente",   "obedient",                     .adjective,   nil),
            ("obstinado",   "obstinate, stubborn",          .adjective,   nil),
            ("ocioso",      "idle, lazy",                   .adjective,   nil),
            ("ofensivo",    "offensive",                    .adjective,   nil),



            ("pacífico",    "peaceful",                     .adjective,   nil),

            ("patriótico",  "patriotic",                    .adjective,   nil),
            ("peculiar",    "peculiar",                     .adjective,   nil),
            ("perezoso",    "lazy",                         .adjective,   nil),

            ("pícaro",      "mischievous, rogue",           .adjective,   nil),
            ("pintoresco",  "picturesque",                  .adjective,   nil),
            ("placentero",  "pleasant",                     .adjective,   nil),
            ("poderoso",    "powerful",                     .adjective,   nil),
            ("polémico",    "controversial",                .adjective,   nil),


            ("potente",     "potent, powerful",             .adjective,   nil),
            ("pragmático",  "pragmatic",                    .adjective,   nil),
            ("precavido",   "cautious, careful",            .adjective,   nil),

            ("pretencioso", "pretentious",                  .adjective,   nil),


            ("prudente",    "prudent",                      .adjective,   nil),

            ("racional",    "rational",                     .adjective,   nil),
            ("razonable",   "reasonable",                   .adjective,   nil),
            ("rebelde",     "rebellious",                   .adjective,   nil),


            ("reservado",   "reserved",                     .adjective,   nil),
            ("resiliente",  "resilient",                    .adjective,   nil),
            ("respetuoso",  "respectful",                   .adjective,   nil),

            ("riguroso",    "rigorous",                     .adjective,   nil),

            ("romántico",   "romantic",                     .adjective,   nil),
            ("rudo",        "rough, rude",                  .adjective,   nil),

            ("sagaz",       "shrewd, astute",               .adjective,   nil),
            ("sensato",     "sensible",                     .adjective,   nil),
            ("sensible",    "sensitive",                    .adjective,   nil),




            ("solidario",   "supportive, in solidarity",    .adjective,   nil),
            ("solitario",   "solitary, lonely",             .adjective,   nil),
            ("sombrío",     "gloomy, somber",               .adjective,   nil),
            ("sospechoso",  "suspicious",                   .adjective,   nil),


            ("sumiso",      "submissive",                   .adjective,   nil),

            ("tacaño",      "stingy",                       .adjective,   nil),
            ("talentoso",   "talented",                     .adjective,   nil),
            ("temerario",   "reckless",                     .adjective,   nil),
            ("temeroso",    "fearful",                      .adjective,   nil),
            ("tenso",       "tense",                        .adjective,   nil),
            ("terco",       "stubborn",                     .adjective,   nil),
            ("tierno",      "tender, sweet",                .adjective,   nil),

            ("torpe",       "clumsy",                       .adjective,   nil),
            ("tradicional", "traditional",                  .adjective,   nil),



            ("trivial",     "trivial",                      .adjective,   nil),

            ("unido",       "united",                       .adjective,   nil),

            ("útil",        "useful",                       .adjective,   nil),


            ("vanidoso",    "vain, conceited",              .adjective,   nil),
            ("vigoroso",    "vigorous",                     .adjective,   nil),
            ("violento",    "violent",                      .adjective,   nil),
            ("virtuoso",    "virtuous",                     .adjective,   nil),
            ("vivaz",       "lively, vivacious",            .adjective,   nil),
            ("vulnerable",  "vulnerable",                   .adjective,   nil),

            // ── More adverbs ──────────────────────────────────────────────────
            ("abruptamente","abruptly",                     .adverb,      nil),

            ("aleatoriamente","randomly",                   .adverb,      nil),
            ("amablemente", "kindly",                       .adverb,      nil),


            ("apresuradamente","hurriedly",                 .adverb,      nil),














            ("cuidadosamente","carefully",                  .adverb,      nil),





            ("deliberadamente","deliberately",              .adverb,      nil),
            ("difícilmente","with difficulty, barely",      .adverb,      nil),

            ("duramente",   "hard, harshly",                .adverb,      nil),


            ("extremadamente","extremely",                  .adverb,      nil),
            ("fácilmente",  "easily",                       .adverb,      nil),
            ("felizmente",  "happily",                      .adverb,      nil),


            ("gradualmente","gradually",                    .adverb,      nil),
            ("gratuitamente","for free, gratuitously",      .adverb,      nil),
            ("honestamente","honestly",                     .adverb,      nil),
            ("igualmente",  "equally, likewise",            .adverb,      nil),
            ("inmediatamente","immediately",                .adverb,      nil),
            ("intensamente","intensely",                    .adverb,      nil),
            ("lentamente",  "slowly",                       .adverb,      nil),


            ("lógicamente", "logically",                    .adverb,      nil),
            ("mayormente",  "mostly, mainly (MX)",          .adverb,      nil),
            ("naturalmente","naturally",                    .adverb,      nil),
            ("negativamente","negatively",                  .adverb,      nil),



            ("orgullosamente","proudly",                    .adverb,      nil),



            ("perfectamente","perfectly",                   .adverb,      nil),
            ("personalmente","personally",                  .adverb,      nil),
            ("plenamente",  "fully, completely",            .adverb,      nil),
            ("positivamente","positively",                  .adverb,      nil),




            ("progresivamente","progressively",             .adverb,      nil),
            ("puntualmente","punctually",                   .adverb,      nil),
            ("rápidamente", "quickly",                      .adverb,      nil),

            ("razonablemente","reasonably",                 .adverb,      nil),
            ("recientemente","recently",                    .adverb,      nil),
            ("regularmente","regularly",                    .adverb,      nil),

            ("repentinamente","suddenly",                   .adverb,      nil),
            ("seriamente",  "seriously",                    .adverb,      nil),

            ("silenciosamente","silently",                  .adverb,      nil),
            ("simplemente", "simply",                       .adverb,      nil),

            ("solamente",   "only, solely",                 .adverb,      nil),
            ("suavemente",  "softly, gently",               .adverb,      nil),


            ("temporalmente","temporarily",                 .adverb,      nil),

            ("tranquilamente","calmly",                     .adverb,      nil),
            ("únicamente",  "only, solely",                 .adverb,      nil),
            ("urgentemente","urgently",                     .adverb,      nil),
            ("virtualmente","virtually",                    .adverb,      nil),
            ("visiblemente","visibly",                      .adverb,      nil),


            // ── Final batch: miscellaneous gaps ──────────────────────────────

            ("aderezar",    "to dress (salad), season",     .infinitive,  nil),
            ("afilar",      "to sharpen",                   .infinitive,  nil),

            ("ajustar",     "to adjust",                    .infinitive,  nil),
            ("alegrar",     "to cheer up",                  .infinitive,  nil),
            ("amenazar",    "to threaten",                  .infinitive,  nil),


            ("apostar",     "to bet",                       .infinitive,  nil),

            ("averiguar",   "to find out, investigate",     .infinitive,  nil),

            ("bloquear",    "to block",                     .infinitive,  nil),


            ("comentar",    "to comment, discuss",          .infinitive,  nil),
            ("completar",   "to complete",                  .infinitive,  nil),

            ("consultar",   "to consult",                   .infinitive,  nil),



            ("cubrir",      "to cover",                     .infinitive,  nil),

            ("demorar",     "to delay",                     .infinitive,  nil),



            ("esconder",    "to hide",                      .infinitive,  nil),



            ("funcionar",   "to work, function",            .infinitive,  nil),


            ("impedir",     "to prevent, hinder",           .infinitive,  nil),












            ("ofrecer",     "to offer",                     .infinitive,  nil),

            ("parar",       "to stop",                      .infinitive,  nil),
            ("participar",  "to participate",               .infinitive,  nil),


            ("preferir",    "to prefer",                    .infinitive,  nil),






            ("realizar",    "to carry out, achieve",        .infinitive,  nil),








            ("robar",       "to steal, rob",                .infinitive,  nil),




            ("solucionar",  "to solve",                     .infinitive,  nil),














            ("existir",     "to exist",                     .infinitive,  nil),





            ("ocurrir",     "to occur, happen",             .infinitive,  nil),
            ("oponer",      "to oppose",                    .infinitive,  nil),
            ("provocar",    "to provoke, cause",            .infinitive,  nil),


            ("requerir",    "to require",                   .infinitive,  nil),
            ("resultar",    "to result, turn out",          .infinitive,  nil),
            ("reunir",      "to gather, collect",           .infinitive,  nil),


            ("surgir",      "to emerge, arise",             .infinitive,  nil),


            ("triunfar",    "to triumph",                   .infinitive,  nil),

            ("vencer",      "to defeat, overcome",          .infinitive,  nil),


            ("dirigir",     "to direct, lead",              .infinitive,  nil),

            ("fijar",       "to fix, set",                  .infinitive,  nil),
            ("garantizar",  "to guarantee",                 .infinitive,  nil),
            ("imponer",     "to impose",                    .infinitive,  nil),







            ("reforzar",    "to reinforce",                 .infinitive,  nil),
            ("situar",      "to situate, place",            .infinitive,  nil),
            ("sostener",    "to sustain, hold up",          .infinitive,  nil),
            ("sufrir",      "to suffer",                    .infinitive,  nil),


            ("topar",       "to run into, encounter (MX)",  .infinitive,  nil),
            ("valer",       "to be worth",                  .infinitive,  nil),

            ("yacer",       "to lie (be lying down)",       .infinitive,  nil),

            // ── New additions batch 7 ──────────────────────────────────────
            ("achacar",                                "to attribute blame, blame on",                      .infinitive,        nil),
            ("acicalar",                               "to groom, smarten up",                              .infinitive,        nil),
            ("acolitar",                               "to assist, support (MX)",                           .infinitive,        nil),
            ("acontecer",                              "to happen, occur",                                  .infinitive,        nil),
            ("acostumbrar",                            "to accustom",                                       .infinitive,        nil),
            ("acreditar",                              "to accredit",                                       .infinitive,        nil),
            ("acuñar",                                 "to coin (word/phrase); to mint",                    .infinitive,        nil),
            ("adecuar",                                "to adapt, suit",                                    .infinitive,        nil),
            ("adular",                                 "to flatter, adulate",                               .infinitive,        nil),
            ("afianzar",                               "to secure, strengthen",                             .infinitive,        nil),
            ("afiliar",                                "to affiliate",                                      .infinitive,        nil),
            ("afincar",                                "to settle in",                                      .infinitive,        nil),
            ("aflojar",                                "to loosen",                                         .infinitive,        nil),
            ("afrontar",                               "to face up to",                                     .infinitive,        nil),
            ("agasajar",                               "to entertain, treat well",                          .infinitive,        nil),
            ("agenciar",                               "to get, manage to obtain",                          .infinitive,        nil),
            ("agobiar",                                "to overwhelm, oppress",                             .infinitive,        nil),
            ("agravar",                                "to worsen",                                         .infinitive,        nil),
            ("agujerar",                               "to pierce, make a hole",                            .infinitive,        nil),
            ("aligerar",                               "to lighten, speed up",                              .infinitive,        nil),
            ("aludir",                                 "to allude to, refer to",                            .infinitive,        nil),
            ("ambientar",                              "to set (a scene); to adapt",                        .infinitive,        nil),
            ("amontonar",                              "to pile up, accumulate",                            .infinitive,        nil),
            ("amordazar",                              "to gag, muzzle",                                    .infinitive,        nil),
            ("anhelar",                                "to yearn, long for",                                .infinitive,        nil),
            ("anidar",                                 "to nest",                                           .infinitive,        nil),
            ("anteponer",                              "to put before, prioritize",                         .infinitive,        nil),
            ("aparentar",                              "to seem, appear",                                   .infinitive,        nil),
            ("apremiar",                               "to urge, press",                                    .infinitive,        nil),
            ("argüir",                                 "to argue, reason",                                  .infinitive,        nil),
            ("armar",                                  "to arm; to assemble",                               .infinitive,        nil),
            ("arrasar",                                "to devastate, sweep away",                          .infinitive,        nil),
            ("arribar",                                "to arrive (formal/nautical)",                       .infinitive,        nil),
            ("arrojar",                                "to throw, hurl",                                    .infinitive,        nil),
            ("articular",                              "to articulate",                                     .infinitive,        nil),
            ("asaltar",                                "to assault, rob",                                   .infinitive,        nil),
            ("asentar",                                "to settle, establish",                              .infinitive,        nil),
            ("asesorar",                               "to advise, consult",                                .infinitive,        nil),
            ("asfixiar",                               "to asphyxiate, suffocate",                          .infinitive,        nil),
            ("aspirar",                                "to aspire; to vacuum",                              .infinitive,        nil),
            ("atajar",                                 "to cut short; to intercept",                        .infinitive,        nil),
            ("atentar",                                "to attempt against",                                .infinitive,        nil),
            ("atestiguar",                             "to testify",                                        .infinitive,        nil),
            ("atestar",                                "to pack, cram full",                                .infinitive,        nil),
            ("atracar",                                "to dock; to mug",                                   .infinitive,        nil),
            ("atropellar",                             "to run over; to bully",                             .infinitive,        nil),
            ("aturdir",                                "to stun, confuse",                                  .infinitive,        nil),
            ("avalar",                                 "to guarantee, back",                                .infinitive,        nil),
            ("barajar",                                "to shuffle (cards); to consider",                   .infinitive,        nil),
            ("batallar",                               "to battle, struggle",                               .infinitive,        nil),
            ("boicotear",                              "to boycott",                                        .infinitive,        nil),
            ("caducar",                                "to expire",                                         .infinitive,        nil),
            ("canalizar",                              "to channel",                                        .infinitive,        nil),
            ("capitalizar",                            "to capitalize",                                     .infinitive,        nil),
            ("captar",                                 "to capture attention; to receive",                  .infinitive,        nil),
            ("chatear",                                "to chat online",                                    .infinitive,        nil),
            ("cimentar",                               "to lay foundations",                                .infinitive,        nil),
            ("circundar",                              "to surround",                                       .infinitive,        nil),
            ("cohabitar",                              "to cohabit",                                        .infinitive,        nil),
            ("comercializar",                          "to commercialize",                                  .infinitive,        nil),
            ("compatibilizar",                         "to make compatible",                                .infinitive,        nil),
            ("compilar",                               "to compile",                                        .infinitive,        nil),
            ("comprometer",                            "to commit; to compromise",                          .infinitive,        nil),
            ("concretar",                              "to finalize, specify",                              .infinitive,        nil),
            ("condensar",                              "to condense",                                       .infinitive,        nil),
            ("conferir",                               "to confer, grant",                                  .infinitive,        nil),
            ("confiscar",                              "to confiscate",                                     .infinitive,        nil),
            ("conjugar",                               "to conjugate; to combine",                          .infinitive,        nil),
            ("conllevar",                              "to entail, involve",                                .infinitive,        nil),
            ("consagrar",                              "to consecrate; to devote",                          .infinitive,        nil),
            ("contener",                               "to contain",                                        .infinitive,        nil),
            ("contextualizar",                         "to contextualize",                                  .infinitive,        nil),
            ("contrarrestar",                          "to counteract",                                     .infinitive,        nil),
            ("convalidar",                             "to validate, recognize",                            .infinitive,        nil),
            ("coordinar",                              "to coordinate",                                     .infinitive,        nil),
            ("corroborar",                             "to corroborate",                                    .infinitive,        nil),
            ("cumplimentar",                           "to fulfill (formality)",                            .infinitive,        nil),
            ("datar",                                  "to date (document)",                                .infinitive,        nil),
            ("debilitar",                              "to weaken",                                         .infinitive,        nil),
            ("decaer",                                 "to decline, decay",                                 .infinitive,        nil),
            ("deducir",                                "to deduce; to deduct",                              .infinitive,        nil),
            ("delegar",                                "to delegate",                                       .infinitive,        nil),
            ("desafiar",                               "to challenge, defy",                                .infinitive,        nil),
            ("desalojar",                              "to evict, vacate",                                  .infinitive,        nil),
            ("desatar",                                "to untie, unleash",                                 .infinitive,        nil),
            ("desviar",                                "to divert, deviate",                                .infinitive,        nil),
            ("dilucidar",                              "to elucidate, clarify",                             .infinitive,        nil),
            ("dispensar",                              "to dispense; to excuse",                            .infinitive,        nil),
            ("disuadir",                               "to dissuade",                                       .infinitive,        nil),
            ("echar",                                  "to throw; to expel",                                .infinitive,        nil),
            ("edificar",                               "to build, edify",                                   .infinitive,        nil),
            ("ejemplificar",                           "to exemplify",                                      .infinitive,        nil),
            ("emprender",                              "to undertake",                                      .infinitive,        nil),
            ("enajenar",                               "to alienate; to sell",                              .infinitive,        nil),
            ("encauzar",                               "to channel, guide",                                 .infinitive,        nil),
            ("encomendar",                             "to entrust, commend",                               .infinitive,        nil),
            ("enmarcar",                               "to frame",                                          .infinitive,        nil),
            ("enmendar",                               "to amend, correct",                                 .infinitive,        nil),
            ("enrolar",                                "to enroll",                                         .infinitive,        nil),
            ("entablar",                               "to open (talks); to initiate",                      .infinitive,        nil),
            ("erogar",                                 "to disburse, spend (MX)",                           .infinitive,        nil),
            ("esclarecer",                             "to clarify",                                        .infinitive,        nil),
            ("esmerarse",                              "to take great care",                                .infinitive,        nil),
            ("evocar",                                 "to evoke",                                          .infinitive,        nil),
            ("exceder",                                "to exceed",                                         .infinitive,        nil),
            ("exhortar",                               "to exhort",                                         .infinitive,        nil),
            ("forzar",                                 "to force",                                          .infinitive,        nil),
            ("fraccionar",                             "to divide into parts",                              .infinitive,        nil),
            ("fugarse",                                "to flee, escape",                                   .infinitive,        nil),
            ("gesticular",                             "to gesture",                                        .infinitive,        nil),
            ("habituar",                               "to habituate",                                      .infinitive,        nil),
            ("idear",                                  "to devise, think up",                               .infinitive,        nil),
            ("implementar",                            "to implement",                                      .infinitive,        nil),
            ("implicar",                               "to imply; to implicate",                            .infinitive,        nil),
            ("incentivar",                             "to incentivize",                                    .infinitive,        nil),
            ("inclinar",                               "to tilt, incline",                                  .infinitive,        nil),
            ("inculcar",                               "to instill",                                        .infinitive,        nil),
            ("indagar",                                "to inquire, investigate",                           .infinitive,        nil),
            ("inducir",                                "to induce",                                         .infinitive,        nil),
            ("insinuar",                               "to insinuate",                                      .infinitive,        nil),
            ("involucrar",                             "to involve",                                        .infinitive,        nil),
            ("legitimar",                              "to legitimize",                                     .infinitive,        nil),
            ("lidiar",                                 "to deal with; to fight (bull)",                     .infinitive,        nil),
            ("localizar",                              "to locate",                                         .infinitive,        nil),
            ("maquinar",                               "to plot, scheme",                                   .infinitive,        nil),
            ("madurar",                                "to mature, ripen",                                  .infinitive,        nil),
            ("maximizar",                              "to maximize",                                       .infinitive,        nil),
            ("minimizar",                              "to minimize",                                       .infinitive,        nil),
            ("mitigar",                                "to mitigate",                                       .infinitive,        nil),
            ("movilizar",                              "to mobilize",                                       .infinitive,        nil),
            ("normalizar",                             "to normalize",                                      .infinitive,        nil),
            ("omitir",                                 "to omit",                                           .infinitive,        nil),
            ("optar",                                  "to opt, choose",                                    .infinitive,        nil),
            ("originar",                               "to originate, cause",                               .infinitive,        nil),
            ("otorgar",                                "to grant, award",                                   .infinitive,        nil),
            ("paliar",                                 "to palliate, ease",                                 .infinitive,        nil),
            ("patrocinar",                             "to sponsor, patronize",                             .infinitive,        nil),
            ("perjudicar",                             "to harm, damage",                                   .infinitive,        nil),
            ("plantear",                               "to raise (issue), propose",                         .infinitive,        nil),
            ("ponderar",                               "to ponder; to praise",                              .infinitive,        nil),
            ("posibilitar",                            "to make possible",                                  .infinitive,        nil),
            ("postergar",                              "to postpone",                                       .infinitive,        nil),
            ("potenciar",                              "to enhance, boost",                                 .infinitive,        nil),
            ("proceder",                               "to proceed",                                        .infinitive,        nil),
            ("proclamar",                              "to proclaim",                                       .infinitive,        nil),
            ("profundizar",                            "to deepen",                                         .infinitive,        nil),
            ("prolongar",                              "to prolong",                                        .infinitive,        nil),
            ("propiciar",                              "to favor, promote",                                 .infinitive,        nil),
            ("protagonizar",                           "to star in; to lead",                               .infinitive,        nil),
            ("proveer",                                "to provide",                                        .infinitive,        nil),
            ("proyectar",                              "to project, plan",                                  .infinitive,        nil),
            ("radicalizar",                            "to radicalize",                                     .infinitive,        nil),
            ("ratificar",                              "to ratify",                                         .infinitive,        nil),
            ("recaudar",                               "to collect, raise (funds)",                         .infinitive,        nil),
            ("reflejar",                               "to reflect",                                        .infinitive,        nil),
            ("regularizar",                            "to regularize",                                     .infinitive,        nil),
            ("reivindicar",                            "to claim, vindicate",                               .infinitive,        nil),
            ("rentabilizar",                           "to make profitable",                                .infinitive,        nil),
            ("resaltar",                               "to highlight, stand out",                           .infinitive,        nil),
            ("retener",                                "to retain, hold back",                              .infinitive,        nil),
            ("retribuir",                              "to compensate, reward",                             .infinitive,        nil),
            ("robustecer",                             "to strengthen, toughen",                            .infinitive,        nil),
            ("salvaguardar",                           "to safeguard",                                      .infinitive,        nil),
            ("sancionar",                              "to sanction",                                       .infinitive,        nil),
            ("saturar",                                "to saturate",                                       .infinitive,        nil),
            ("simplificar",                            "to simplify",                                       .infinitive,        nil),
            ("sintetizar",                             "to synthesize",                                     .infinitive,        nil),
            ("sobrevivir",                             "to survive",                                        .infinitive,        nil),
            ("solidificar",                            "to solidify",                                       .infinitive,        nil),
            ("subvencionar",                           "to subsidize",                                      .infinitive,        nil),
            ("sustentar",                              "to sustain, support",                               .infinitive,        nil),
            ("tangibilizar",                           "to make tangible",                                  .infinitive,        nil),
            ("tolerar",                                "to tolerate",                                       .infinitive,        nil),
            ("trascender",                             "to transcend",                                      .infinitive,        nil),
            ("traspasar",                              "to transfer; to trespass",                          .infinitive,        nil),
            ("tributar",                               "to pay taxes; to pay tribute",                      .infinitive,        nil),
            ("uniformar",                              "to standardize; to put in uniform",                 .infinitive,        nil),
            ("vincular",                               "to link, connect",                                  .infinitive,        nil),
            ("vulnerar",                               "to violate, damage",                                .infinitive,        nil),
            ("crisol",                                 "crucible; melting pot",                             .noun,        "m"),
            ("doblez",                                 "fold; duplicity",                                   .noun,        "m"),
            ("donaire",                                "grace, wit",                                        .noun,        "m"),
            ("empeño",                                 "determination; pawn (MX)",                          .noun,        "m"),
            ("encanto",                                "charm, enchantment",                                .noun,        "m"),
            ("esmero",                                 "care, diligence",                                   .noun,        "m"),
            ("estirpe",                                "lineage, stock",                                    .noun,        "f"),
            ("fervor",                                 "fervor",                                            .noun,        "m"),
            ("fulgor",                                 "radiance, brilliance",                              .noun,        "m"),
            ("garbo",                                  "grace, elegance",                                   .noun,        "m"),
            ("hastío",                                 "boredom, tedium",                                   .noun,        "m"),
            ("hazaña",                                 "feat, exploit",                                     .noun,        "f"),
            ("hinchazón",                              "swelling",                                          .noun,        "f"),
            ("huella",                                 "footprint, trace",                                  .noun,        "f"),
            ("indicio",                                "indication, clue",                                  .noun,        "m"),
            ("latido",                                 "heartbeat",                                         .noun,        "m"),
            ("lema",                                   "motto, slogan",                                     .noun,        "m"),
            ("letargo",                                "lethargy",                                          .noun,        "m"),
            ("linaje",                                 "lineage",                                           .noun,        "m"),
            ("lúgubre",                                "gloomy",                                            .adjective,        nil),
            ("malestar",                               "discomfort, unease",                                .noun,        "m"),
            ("mandato",                                "mandate, term in office",                           .noun,        "m"),
            ("maña",                                   "skill, trick; habit",                               .noun,        "f"),
            ("matiz",                                  "nuance, shade",                                     .noun,        "m"),
            ("menosprecio",                            "contempt, disdain",                                 .noun,        "m"),
            ("mesura",                                 "moderation, restraint",                             .noun,        "f"),
            ("mocedad",                                "youth (period)",                                    .noun,        "f"),
            ("morada",                                 "dwelling, abode",                                   .noun,        "f"),
            ("murmullo",                               "murmur, whisper",                                   .noun,        "m"),
            ("nexo",                                   "link, connection",                                  .noun,        "m"),
            ("niñez",                                  "childhood",                                         .noun,        "f"),
            ("nostalgia",                              "nostalgia",                                         .noun,        "f"),
            ("obstáculo",                              "obstacle",                                          .noun,        "m"),
            ("ocaso",                                  "sunset; decline",                                   .noun,        "m"),
            ("odio",                                   "hatred",                                            .noun,        "m"),
            ("oleada",                                 "wave, surge",                                       .noun,        "f"),
            ("omisión",                                "omission",                                          .noun,        "f"),
            ("oprobio",                                "opprobrium, disgrace",                              .noun,        "m"),
            ("paisaje",                                "landscape, scenery",                                .noun,        "m"),
            ("palpitar",                               "to palpitate, throb",                               .infinitive,        nil),
            ("pauta",                                  "guideline, rule",                                   .noun,        "f"),
            ("pericia",                                "skill, expertise",                                  .noun,        "f"),
            ("perspicacia",                            "shrewdness",                                        .noun,        "f"),
            ("pesadilla",                              "nightmare",                                         .noun,        "f"),
            ("piedad",                                 "piety; pity",                                       .noun,        "f"),
            ("presagio",                               "omen, presage",                                     .noun,        "m"),
            ("prisa",                                  "hurry, rush",                                       .noun,        "f"),
            ("profecía",                               "prophecy",                                          .noun,        "f"),
            ("prójimo",                                "fellow man, neighbor",                              .noun,        "m"),
            ("pudor",                                  "modesty, shame",                                    .noun,        "m"),
            ("quebranto",                              "grief, loss",                                       .noun,        "m"),
            ("queja",                                  "complaint",                                         .noun,        "f"),
            ("quietud",                                "stillness, calm",                                   .noun,        "f"),
            ("reguero",                                "trail, streak",                                     .noun,        "m"),
            ("rendija",                                "crack, gap",                                        .noun,        "f"),
            ("reparo",                                 "objection; repair",                                 .noun,        "m"),
            ("requiebro",                              "compliment, flattery",                              .noun,        "m"),
            ("resguardo",                              "protection; receipt",                               .noun,        "m"),
            ("resolución",                             "resolution, determination",                         .noun,        "f"),
            ("retoño",                                 "sprout; offspring (MX)",                            .noun,        "m"),
            ("retroceso",                              "setback, retreat",                                  .noun,        "m"),
            ("reverencia",                             "reverence, bow",                                    .noun,        "f"),
            ("rigor",                                  "rigor, strictness",                                 .noun,        "m"),
            ("rocío",                                  "dew",                                               .noun,        "m"),
            ("rudeza",                                 "roughness, rudeness",                               .noun,        "f"),
            ("sagacidad",                              "shrewdness",                                        .noun,        "f"),
            ("saludo",                                 "greeting",                                          .noun,        "m"),
            ("salvedad",                               "exception, proviso",                                .noun,        "f"),
            ("sazón",                                  "seasoning; ripeness (MX)",                          .noun,        "f"),
            ("serenidad",                              "serenity",                                          .noun,        "f"),
            ("sigilo",                                 "stealth, secrecy",                                  .noun,        "m"),
            ("sinrazón",                               "injustice, irrationality",                          .noun,        "f"),
            ("sosiego",                                "calm, peace",                                       .noun,        "m"),
            ("sufrimiento",                            "suffering",                                         .noun,        "m"),
            ("suplicio",                               "torment, agony",                                    .noun,        "m"),
            ("sutil",                                  "subtle",                                            .adjective,        nil),
            ("talante",                                "mood, disposition",                                 .noun,        "m"),
            ("tormento",                               "torment",                                           .noun,        "m"),
            ("torpeza",                                "clumsiness",                                        .noun,        "f"),
            ("trance",                                 "trance; difficult moment",                          .noun,        "m"),
            ("tregua",                                 "truce",                                             .noun,        "f"),
            ("triunfo",                                "triumph",                                           .noun,        "m"),
            ("tutela",                                 "guardianship, tutelage",                            .noun,        "f"),
            ("vaguedad",                               "vagueness",                                         .noun,        "f"),
            ("vaticinio",                              "prophecy, prediction",                              .noun,        "m"),
            ("vejez",                                  "old age",                                           .noun,        "f"),
            ("ventura",                                "fortune, luck",                                     .noun,        "f"),
            ("veracidad",                              "truthfulness",                                      .noun,        "f"),
            ("vestigio",                               "vestige, trace",                                    .noun,        "m"),
            ("vicio",                                  "vice, bad habit",                                   .noun,        "m"),
            ("vigor",                                  "vigor, energy",                                     .noun,        "m"),
            ("vileza",                                 "vileness, wickedness",                              .noun,        "f"),
            ("virtud",                                 "virtue",                                            .noun,        "f"),
            ("vitalidad",                              "vitality",                                          .noun,        "f"),
            ("zozobra",                                "anxiety, worry",                                    .noun,        "f"),

            // ── New additions batch 6 ──────────────────────────────────────
            ("acabar",                                 "to finish, run out",                                .infinitive,        nil),
            ("activar",                                "to activate",                                       .infinitive,        nil),
            ("agregar",                                "to add, include",                                   .infinitive,        nil),
            ("aguantar",                               "to endure, put up with",                            .infinitive,        nil),
            ("ahorcar",                                "to hang (execute)",                                 .infinitive,        nil),
            ("alborotar",                              "to stir up, cause a ruckus",                        .infinitive,        nil),
            ("alimentar",                              "to feed, nourish",                                  .infinitive,        nil),
            ("ambicionar",                             "to aspire to",                                      .infinitive,        nil),
            ("añorar",                                 "to miss, long for",                                 .infinitive,        nil),
            ("aparcar",                                "to park",                                           .infinitive,        nil),
            ("apresurarse",                            "to hurry",                                          .infinitive,        nil),
            ("arrendar",                               "to rent, lease",                                    .infinitive,        nil),
            ("atesorar",                               "to treasure",                                       .infinitive,        nil),
            ("materia oscura",                         "dark matter",                                       .noun,        "f"),
            ("energía oscura",                         "dark energy",                                       .noun,        "f"),
            ("enana blanca",                           "white dwarf",                                       .noun,        "f"),
            ("constelación",                           "constellation",                                     .noun,        "f"),
            ("quásar",                                 "quasar",                                            .noun,        "m"),
            ("púlsar",                                 "pulsar",                                            .noun,        "m"),
            ("antimonio",                              "antimony",                                          .noun,        "m"),
            ("nanopartícula",                          "nanoparticle",                                      .noun,        "f"),
            ("nanotecnología",                         "nanotechnology",                                    .noun,        "f"),
            ("biotecnología",                          "biotechnology",                                     .noun,        "f"),
            ("genómica",                               "genomics",                                          .noun,        "f"),
            ("proteómica",                             "proteomics",                                        .noun,        "f"),
            ("metabolómica",                           "metabolomics",                                      .noun,        "f"),
            ("bioinformática",                         "bioinformatics",                                    .noun,        "f"),
            ("epigenética",                            "epigenetics",                                       .noun,        "f"),
            ("neurociencia",                           "neuroscience",                                      .noun,        "f"),
            ("psicología cognitiva",                   "cognitive psychology",                              .noun,        "f"),
            ("psicología conductual",                  "behavioral psychology",                             .noun,        "f"),
            ("neuroplasticidad",                       "neuroplasticity",                                   .noun,        "f"),
            ("inteligencia emocional",                 "emotional intelligence",                            .noun,        "f"),
            ("resiliencia",                            "resilience",                                        .noun,        "f"),
            ("autoeficacia",                           "self-efficacy",                                     .noun,        "f"),
            ("atención plena",                         "mindful attention",                                 .noun,        "f"),
            ("terapia cognitiva",                      "cognitive therapy",                                 .noun,        "f"),
            ("terapia conductual",                     "behavioral therapy",                                .noun,        "f"),
            ("terapia de pareja",                      "couples therapy",                                   .noun,        "f"),
            ("constelaciones familiares",              "family constellations",                             .noun,        "f"),
            ("codependencia",                          "codependency",                                      .noun,        "f"),
            ("abstinencia",                            "abstinence",                                        .noun,        "f"),
            ("recaída",                                "relapse",                                           .noun,        "f"),
            ("recuperación",                           "recovery",                                          .noun,        "f"),
            ("rehabilitación",                         "rehabilitation",                                    .noun,        "f"),
            ("litografía",                             "lithography",                                       .noun,        "f"),
            ("serigrafía",                             "screen printing",                                   .noun,        "f"),
            ("instalación artística",                  "art installation",                                  .noun,        "f"),
            ("performance artístico",                  "performance art",                                   .noun,        "m"),
            ("arte conceptual",                        "conceptual art",                                    .noun,        "m"),
            ("arte abstracto",                         "abstract art",                                      .noun,        "m"),
            ("arte figurativo",                        "figurative art",                                    .noun,        "m"),
            ("vanguardia",                             "avant-garde",                                       .noun,        "f"),
            ("surrealismo",                            "surrealism",                                        .noun,        "m"),
            ("realismo mágico",                        "magical realism",                                   .noun,        "m"),
            ("muralismo",                              "muralism",                                          .noun,        "m"),
            ("expressionismo",                         "expressionism",                                     .noun,        "m"),
            ("impresionismo",                          "impressionism",                                     .noun,        "m"),
            ("cubismo",                                "cubism",                                            .noun,        "m"),
            ("modernismo",                             "modernism",                                         .noun,        "m"),
            ("posmodernismo",                          "postmodernism",                                     .noun,        "m"),
            ("cinefilia",                              "love of cinema",                                    .noun,        "f"),
            ("cinematografía",                         "cinematography",                                    .noun,        "f"),
            ("montaje",                                "editing (film)",                                    .noun,        "m"),
            ("guión",                                  "script, screenplay",                                .noun,        "m"),
            ("storyboard",                             "storyboard",                                        .noun,        "m"),
            ("tráiler",                                "trailer",                                           .noun,        "m"),
            ("galardón",                               "award, prize",                                      .noun,        "m"),
            ("festival de cine",                       "film festival",                                     .noun,        "m"),
            ("tempo",                                  "tempo",                                             .noun,        "m"),
            ("tonalidad",                              "tonality, key",                                     .noun,        "f"),
            ("acorde",                                 "chord",                                             .noun,        "m"),
            ("escala musical",                         "musical scale",                                     .noun,        "f"),
            ("pentagrama",                             "musical staff",                                     .noun,        "m"),
            ("partitura",                              "sheet music",                                       .noun,        "f"),
            ("sinfonía",                               "symphony",                                          .noun,        "f"),
            ("sonata",                                 "sonata",                                            .noun,        "f"),
            ("concerto",                               "concerto",                                          .noun,        "m"),
            ("ópera",                                  "opera",                                             .noun,        "f"),
            ("zarzuela",                               "Spanish operetta",                                  .noun,        "f"),
            ("bolero",                                 "bolero (music)",                                    .noun,        "m"),
            ("corrido",                                "corrido (Mexican ballad)",                          .noun,        "m"),
            ("banda sinaloense",                       "Sinaloan brass band",                               .noun,        "f"),
            ("tropical",                               "tropical music",                                    .noun,        "m"),
            ("ska",                                    "ska music",                                         .noun,        "m"),
            ("punk",                                   "punk music",                                        .noun,        "m"),
            ("indie",                                  "indie music",                                       .noun,        "m"),
            ("reggaetón",                              "reggaeton",                                         .noun,        "m"),
            ("trap",                                   "trap music",                                        .noun,        "m"),
            ("urbano",                                 "urban music (genre)",                               .noun,        "m"),
            ("rap",                                    "rap",                                               .noun,        "m"),
            ("hip-hop",                                "hip-hop",                                           .noun,        "m"),
            ("freestyle",                              "freestyle (rap)",                                   .noun,        "m"),
            ("beatbox",                                "beatbox",                                           .noun,        "m"),
            ("DJ",                                     "DJ",                                                .noun,        "m"),
            ("mezcla musical",                         "music mix",                                         .noun,        "f"),
            ("producción musical",                     "music production",                                  .noun,        "f"),
            ("estudio de grabación",                   "recording studio",                                  .noun,        "m"),
            ("gira",                                   "tour (music)",                                      .noun,        "f"),
            ("setlist",                                "setlist",                                           .noun,        "m"),
            ("bis",                                    "encore",                                            .noun,        "m"),
            ("ovación",                                "ovation",                                           .noun,        "f"),
            ("preparador físico",                      "physical trainer",                                  .noun,        "m"),
            ("delantero",                              "forward (soccer)",                                  .noun,        "m"),
            ("defensa",                                "defender",                                          .noun,        "m"),
            ("mediocampista",                          "midfielder",                                        .noun,        "m"),
            ("lateral",                                "fullback (soccer)",                                 .noun,        "m"),
            ("pivote",                                 "pivot (basketball)",                                .noun,        "m"),
            ("base baloncesto",                        "point guard",                                       .noun,        "m"),
            ("escolta",                                "shooting guard",                                    .noun,        "m"),
            ("alero",                                  "small forward",                                     .noun,        "m"),
            ("ala-pívot",                              "power forward",                                     .noun,        "m"),
            ("receptor",                               "receiver (football)",                               .noun,        "m"),
            ("mariscal",                               "quarterback",                                       .noun,        "m"),
            ("lanzador",                               "pitcher (baseball)",                                .noun,        "m"),
            ("bateador",                               "batter (baseball)",                                 .noun,        "m"),
            ("cátcher",                                "catcher (baseball)",                                .noun,        "m"),
            ("primera base",                           "first base",                                        .noun,        "f"),
            ("jonrón",                                 "home run",                                          .noun,        "m"),
            ("eliminatoria",                           "playoffs, elimination round",                       .noun,        "f"),
            ("semifinal",                              "semifinal",                                         .noun,        "f"),
            ("cuartos de final",                       "quarterfinal",                                      .noun,        "m"),
            ("prórroga",                               "overtime, extra time",                              .noun,        "f"),
            ("penalti",                                "penalty kick",                                      .noun,        "m"),
            ("falta",                                  "foul; free kick",                                   .noun,        "f"),
            ("fuera de juego",                         "offside",                                           .noun,        "m"),
            ("tiro libre",                             "free kick; free throw",                             .noun,        "m"),
            ("saque de esquina",                       "corner kick",                                       .noun,        "m"),
            ("foul",                                   "foul (general)",                                    .noun,        "m"),
            ("tiempo muerto",                          "timeout",                                           .noun,        "m"),
            ("sustitución",                            "substitution",                                      .noun,        "f"),
            ("capitán",                                "captain",                                           .noun,        "m"),
            ("podio",                                  "podium",                                            .noun,        "m"),
            ("récord mundial",                         "world record",                                      .noun,        "m"),
            ("marca personal",                         "personal best",                                     .noun,        "f"),
            ("clasificación",                          "ranking, classification",                           .noun,        "f"),
            ("tanteo",                                 "score",                                             .noun,        "m"),
            ("palmarés",                               "trophy cabinet, record of wins",                    .noun,        "m"),
            ("liga",                                   "league",                                            .noun,        "f"),
            ("división",                               "division",                                          .noun,        "f"),
            ("descenso",                               "relegation",                                        .noun,        "m"),
            ("ascenso deportivo",                      "promotion (sports)",                                .noun,        "m"),
            ("karate",                                 "karate",                                            .noun,        "m"),
            ("aikido",                                 "aikido",                                            .noun,        "m"),
            ("sumo",                                   "sumo wrestling",                                    .noun,        "m"),
            ("capoeira",                               "capoeira",                                          .noun,        "f"),
            ("decatlón",                               "decathlon",                                         .noun,        "m"),
            ("canotaje",                               "canoeing",                                          .noun,        "m"),
            ("remo",                                   "rowing",                                            .noun,        "m"),
            ("nado sincronizado",                      "synchronized swimming",                             .noun,        "m"),
            ("halterofilia",                           "weightlifting",                                     .noun,        "f"),
            ("lanzamiento de jabalina",                "javelin throw",                                     .noun,        "m"),
            ("lanzamiento de disco",                   "discus throw",                                      .noun,        "m"),
            ("lanzamiento de bala",                    "shot put",                                          .noun,        "m"),
            ("salto de altura",                        "high jump",                                         .noun,        "m"),
            ("salto de longitud",                      "long jump",                                         .noun,        "m"),
            ("salto con garrocha",                     "pole vault",                                        .noun,        "m"),
            ("gimnasia artística",                     "artistic gymnastics",                               .noun,        "f"),
            ("gimnasia rítmica",                       "rhythmic gymnastics",                               .noun,        "f"),
            ("patinaje artístico",                     "figure skating",                                    .noun,        "m"),
            ("hockey sobre hielo",                     "ice hockey",                                        .noun,        "m"),
            ("curling",                                "curling (sport)",                                   .noun,        "m"),
            ("biatlón",                                "biathlon",                                          .noun,        "m"),
            ("snowboard",                              "snowboarding",                                      .noun,        "m"),
            ("esquí alpino",                           "alpine skiing",                                     .noun,        "m"),
            ("tabla de surf",                          "surfboard",                                         .noun,        "f"),
            ("windsurf",                               "windsurfing",                                       .noun,        "m"),
            ("kiteboarding",                           "kiteboarding",                                      .noun,        "m"),
            ("escalada",                               "rock climbing",                                     .noun,        "f"),
            ("rappel",                                 "rappelling",                                        .noun,        "m"),
            ("senderismo",                             "hiking",                                            .noun,        "m"),
            ("montañismo",                             "mountaineering",                                    .noun,        "m"),
            ("espeleología",                           "caving, spelunking",                                .noun,        "f"),
            ("fregadero",                              "kitchen sink",                                      .noun,        "m"),
            ("escurridor",                             "dish rack",                                         .noun,        "m"),
            ("tostador",                               "toaster",                                           .noun,        "m"),
            ("procesador de alimentos",                "food processor",                                    .noun,        "m"),
            ("campana extractora",                     "range hood",                                        .noun,        "f"),
            ("vitrocerámica",                          "glass-ceramic cooktop",                             .noun,        "f"),
            ("hornilla",                               "burner, hot plate",                                 .noun,        "f"),
            ("olla express",                           "pressure cooker",                                   .noun,        "f"),
            ("wok",                                    "wok",                                               .noun,        "m"),
            ("vaporizador",                            "steamer",                                           .noun,        "m"),
            ("freidora",                               "deep fryer",                                        .noun,        "f"),
            ("asador",                                 "grill, barbecue",                                   .noun,        "m"),
            ("parrilla",                               "grill; gridiron",                                   .noun,        "f"),
            ("pichel",                                 "pitcher (MX)",                                      .noun,        "m"),
            ("termo",                                  "thermos",                                           .noun,        "m"),
            ("tupper",                                 "Tupperware, food container",                        .noun,        "m"),
            ("fiambrera",                              "lunch box",                                         .noun,        "f"),
            ("posavasos",                              "coaster",                                           .noun,        "m"),
            ("salvamanteles",                          "trivet, table pad",                                 .noun,        "m"),
            ("escobeta",                               "scrub brush (MX)",                                  .noun,        "f"),
            ("estropajo",                              "scrubber, scouring pad",                            .noun,        "m"),
            ("esponja",                                "sponge",                                            .noun,        "f"),
            ("trapo",                                  "rag, cloth",                                        .noun,        "m"),
            ("franela",                                "flannel cloth; rag (MX)",                           .noun,        "f"),
            ("cubeta",                                 "bucket (MX)",                                       .noun,        "f"),
            ("recogedor",                              "dustpan",                                           .noun,        "m"),
            ("plumero",                                "feather duster",                                    .noun,        "m"),
            ("cera",                                   "wax (floor)",                                       .noun,        "f"),
            ("cloro",                                  "bleach (MX)",                                       .noun,        "m"),
            ("detergente",                             "detergent",                                         .noun,        "m"),
            ("suavizante",                             "fabric softener",                                   .noun,        "m"),
            ("jabón en polvo",                         "laundry powder",                                    .noun,        "m"),
            ("blanqueador",                            "bleach, whitener",                                  .noun,        "m"),
            ("absurdo",                                "absurd",                                            .adjective,        nil),
            ("accesible",                              "accessible",                                        .adjective,        nil),
            ("acertado",                               "right, accurate",                                   .adjective,        nil),
            ("afectuoso",                              "affectionate",                                      .adjective,        nil),
            ("agotador",                               "exhausting",                                        .adjective,        nil),
            ("agradable",                              "pleasant, agreeable",                               .adjective,        nil),
            ("agradecido",                             "grateful",                                          .adjective,        nil),
            ("agresivo",                               "aggressive",                                        .adjective,        nil),
            ("aislado",                                "isolated",                                          .adjective,        nil),
            ("ajetreado",                              "busy, hectic",                                      .adjective,        nil),
            ("alucinante",                             "amazing, mind-blowing (MX)",                        .adjective,        nil),
            ("amargado",                               "bitter, embittered",                                .adjective,        nil),
            ("ampliado",                               "expanded",                                          .adjective,        nil),
            ("andrajoso",                              "ragged, tattered",                                  .adjective,        nil),
            ("angustiado",                             "anxious, distressed",                               .adjective,        nil),
            ("animado",                                "lively, animated",                                  .adjective,        nil),
            ("aplastante",                             "crushing, overwhelming",                            .adjective,        nil),
            ("armonioso",                              "harmonious",                                        .adjective,        nil),
            ("articulado",                             "articulate",                                        .adjective,        nil),
            ("asequible",                              "affordable, accessible",                            .adjective,        nil),
            ("atacado",                                "attacked; flustered",                               .adjective,        nil),
            ("atareado",                               "busy, occupied",                                    .adjective,        nil),
            ("atento",                                 "attentive",                                         .adjective,        nil),
            ("autónomo",                               "autonomous",                                        .adjective,        nil),
            ("burocrático",                            "bureaucratic",                                      .adjective,        nil),
            ("cargado",                                "loaded, heavy",                                     .adjective,        nil),
            ("carismático",                            "charismatic",                                       .adjective,        nil),
            ("casual",                                 "casual",                                            .adjective,        nil),
            ("centrado",                               "focused, centered",                                 .adjective,        nil),
            ("cercano",                                "close, nearby; close (relationship)",               .adjective,        nil),
            ("cíclico",                                "cyclical",                                          .adjective,        nil),
            ("clandestino",                            "clandestine",                                       .adjective,        nil),
            ("compatible",                             "compatible",                                        .adjective,        nil),
            ("comprensible",                           "understandable",                                    .adjective,        nil),
            ("comprensivo",                            "understanding, compassionate",                      .adjective,        nil),
            ("conmovido",                              "moved (emotionally)",                               .adjective,        nil),
            ("contento",                               "happy, content",                                    .adjective,        nil),
            ("conveniente",                            "convenient",                                        .adjective,        nil),
            ("copioso",                                "copious, abundant",                                 .adjective,        nil),
            ("corrupto",                               "corrupt",                                           .adjective,        nil),
            ("costoso",                                "costly, expensive",                                 .adjective,        nil),
            ("cuestionable",                           "questionable",                                      .adjective,        nil),
            ("dañado",                                 "damaged",                                           .adjective,        nil),
            ("deficiente",                             "deficient",                                         .adjective,        nil),
            ("delicado",                               "delicate",                                          .adjective,        nil),
            ("democrático",                            "democratic",                                        .adjective,        nil),
            ("denso",                                  "dense",                                             .adjective,        nil),
            ("desafiante",                             "challenging, defiant",                              .adjective,        nil),
            ("desanimado",                             "discouraged",                                       .adjective,        nil),
            ("descuidado",                             "careless, neglected",                               .adjective,        nil),
            ("desengañado",                            "disillusioned",                                     .adjective,        nil),
            ("desesperado",                            "desperate",                                         .adjective,        nil),
            ("desestabilizado",                        "destabilized",                                      .adjective,        nil),
            ("deshidratado",                           "dehydrated",                                        .adjective,        nil),
            ("destacado",                              "outstanding, prominent",                            .adjective,        nil),
            ("determinado",                            "determined",                                        .adjective,        nil),
            ("diligente",                              "diligent",                                          .adjective,        nil),
            ("discapacitado",                          "disabled",                                          .adjective,        nil),
            ("distinto",                               "distinct, different",                               .adjective,        nil),
            ("dominado",                               "dominated",                                         .adjective,        nil),
            ("elevado",                                "elevated, high",                                    .adjective,        nil),
            ("emprendedor",                            "entrepreneurial",                                   .adjective,        nil),
            ("empático",                               "empathetic",                                        .adjective,        nil),
            ("encantado",                              "enchanted, delighted",                              .adjective,        nil),
            ("encantador",                             "charming, enchanting",                              .adjective,        nil),
            ("engañoso",                               "deceptive",                                         .adjective,        nil),
            ("enriquecedor",                           "enriching",                                         .adjective,        nil),
            ("evolucionado",                           "evolved",                                           .adjective,        nil),
            ("excitado",                               "excited",                                           .adjective,        nil),
            ("experimentado",                          "experienced",                                       .adjective,        nil),
            ("extraordinario",                         "extraordinary",                                     .adjective,        nil),
            ("fallido",                                "failed",                                            .adjective,        nil),
            ("familiar",                               "familiar; family-related",                          .adjective,        nil),
            ("fantástico",                             "fantastic",                                         .adjective,        nil),
            ("fatigado",                               "fatigued",                                          .adjective,        nil),
            ("fenomenal",                              "phenomenal",                                        .adjective,        nil),
            ("fingido",                                "feigned, fake",                                     .adjective,        nil),
            ("fluido",                                 "fluid, fluent",                                     .adjective,        nil),
            ("frustrado",                              "frustrated",                                        .adjective,        nil),
            ("funcional",                              "functional",                                        .adjective,        nil),
            ("gozoso",                                 "joyful",                                            .adjective,        nil),
            ("hábil",                                  "skillful",                                          .adjective,        nil),
            ("hambriento",                             "hungry",                                            .adjective,        nil),
            ("harto",                                  "fed up; full (MX)",                                 .adjective,        nil),
            ("higiénico",                              "hygienic",                                          .adjective,        nil),
            ("ilegítimo",                              "illegitimate",                                      .adjective,        nil),
            ("ilógico",                                "illogical",                                         .adjective,        nil),
            ("improvisado",                            "improvised",                                        .adjective,        nil),
            ("incompleto",                             "incomplete",                                        .adjective,        nil),
            ("informal",                               "informal",                                          .adjective,        nil),
            ("inmenso",                                "immense",                                           .adjective,        nil),
            ("insistente",                             "insistent",                                         .adjective,        nil),
            ("involucrado",                            "involved",                                          .adjective,        nil),
            ("irónico",                                "ironic",                                            .adjective,        nil),
            ("legible",                                "legible",                                           .adjective,        nil),
            ("lejano",                                 "distant, far",                                      .adjective,        nil),
            ("limítrofe",                              "bordering, adjacent",                               .adjective,        nil),
            ("literario",                              "literary",                                          .adjective,        nil),
            ("lujoso",                                 "luxurious",                                         .adjective,        nil),
            ("malogrado",                              "failed, ill-fated",                                 .adjective,        nil),
            ("maltratado",                             "abused, mistreated",                                .adjective,        nil),
            ("maniático",                              "maniacal, obsessive",                               .adjective,        nil),
            ("marcado",                                "marked, pronounced",                                .adjective,        nil),
            ("merecido",                               "deserved",                                          .adjective,        nil),
            ("minucioso",                              "meticulous",                                        .adjective,        nil),
            ("moralista",                              "moralistic",                                        .adjective,        nil),
            ("motivado",                               "motivated",                                         .adjective,        nil),
            ("mutable",                                "mutable, changeable",                               .adjective,        nil),
            ("narco",                                  "narco, drug-related",                               .adjective,        nil),
            ("negligente",                             "negligent",                                         .adjective,        nil),
            ("nulo",                                   "null, void",                                        .adjective,        nil),
            ("olvidado",                               "forgotten",                                         .adjective,        nil),
            ("oportuno",                               "opportune, timely",                                 .adjective,        nil),
            ("opresivo",                               "oppressive",                                        .adjective,        nil),
            ("orientado",                              "oriented, focused",                                 .adjective,        nil),
            ("ostentoso",                              "ostentatious",                                      .adjective,        nil),
            ("oxidado",                                "rusty, oxidized",                                   .adjective,        nil),
            ("pasional",                               "passionate",                                        .adjective,        nil),
            ("paulatino",                              "gradual",                                           .adjective,        nil),
            ("pedante",                                "pedantic",                                          .adjective,        nil),
            ("perenne",                                "perennial",                                         .adjective,        nil),
            ("permisivo",                              "permissive",                                        .adjective,        nil),
            ("pintado",                                "vivid, to the point",                               .adjective,        nil),
            ("pionero",                                "pioneering",                                        .adjective,        nil),
            ("plagiado",                               "plagiarized",                                       .adjective,        nil),
            ("planeado",                               "planned",                                           .adjective,        nil),
            ("plural",                                 "plural, diverse",                                   .adjective,        nil),
            ("precario",                               "precarious",                                        .adjective,        nil),
            ("predominante",                           "predominant",                                       .adjective,        nil),
            ("prematuro",                              "premature",                                         .adjective,        nil),
            ("preparado",                              "prepared, ready",                                   .adjective,        nil),
            ("privilegiado",                           "privileged",                                        .adjective,        nil),
            ("prolijo",                                "neat, excessive in detail",                         .adjective,        nil),
            ("propicio",                               "propitious, favorable",                             .adjective,        nil),
            ("protegido",                              "protected",                                         .adjective,        nil),
            ("próximo",                                "next, upcoming",                                    .adjective,        nil),
            ("puro",                                   "pure",                                              .adjective,        nil),
            ("quebrado",                               "broken",                                            .adjective,        nil),
            ("regulado",                               "regulated",                                         .adjective,        nil),
            ("remoto",                                 "remote",                                            .adjective,        nil),
            ("renovado",                               "renewed",                                           .adjective,        nil),
            ("repetitivo",                             "repetitive",                                        .adjective,        nil),
            ("saturado",                               "saturated, overwhelmed",                            .adjective,        nil),
            ("selectivo",                              "selective",                                         .adjective,        nil),
            ("separado",                               "separated",                                         .adjective,        nil),
            ("similar",                                "similar",                                           .adjective,        nil),
            ("tenaz",                                  "tenacious",                                         .adjective,        nil),
            ("tolerante",                              "tolerant",                                          .adjective,        nil),
            ("tortuoso",                               "tortuous, winding",                                 .adjective,        nil),
            ("traicionero",                            "treacherous",                                       .adjective,        nil),
            ("trágico",                                "tragic",                                            .adjective,        nil),
            ("transcendente",                          "transcendent",                                      .adjective,        nil),
            ("traumático",                             "traumatic",                                         .adjective,        nil),
            ("veloz",                                  "fast, swift",                                       .adjective,        nil),
            ("ventajoso",                              "advantageous",                                      .adjective,        nil),
            ("vetusto",                                "ancient, very old",                                 .adjective,        nil),
            ("visual",                                 "visual",                                            .adjective,        nil),

            // ── New additions batch 5 ──────────────────────────────────────
            ("escarcha",                               "frost",                                             .noun,        "f"),
            ("aguacero",                               "downpour, heavy rain",                              .noun,        "m"),
            ("llovizna",                               "drizzle",                                           .noun,        "f"),
            ("niebla",                                 "fog, mist",                                         .noun,        "f"),
            ("bruma",                                  "haze, mist",                                        .noun,        "f"),
            ("bochorno",                               "muggy heat",                                        .noun,        "m"),
            ("crepúsculo",                             "twilight, dusk",                                    .noun,        "m"),
            ("alba",                                   "dawn",                                              .noun,        "f"),
            ("anochecer",                              "nightfall",                                         .noun,        "m"),
            ("solsticio",                              "solstice",                                          .noun,        "m"),
            ("equinoccio",                             "equinox",                                           .noun,        "m"),
            ("marejada",                               "swell, heavy sea",                                  .noun,        "f"),
            ("afluente",                               "tributary",                                         .noun,        "m"),
            ("quebrada",                               "ravine, gully",                                     .noun,        "f"),
            ("litoral",                                "coastline",                                         .noun,        "m"),
            ("promontorio",                            "promontory, headland",                              .noun,        "m"),
            ("islote",                                 "small island, islet",                               .noun,        "m"),
            ("cayo",                                   "cay, key (small island)",                           .noun,        "m"),
            ("cumbre",                                 "summit, peak",                                      .noun,        "f"),
            ("ladera",                                 "hillside, slope",                                   .noun,        "f"),
            ("pendiente",                              "slope, incline",                                    .noun,        "f"),
            ("fosa oceánica",                          "ocean trench",                                      .noun,        "f"),
            ("dorsal oceánica",                        "ocean ridge",                                       .noun,        "f"),
            ("puesta de sol",                          "sunset",                                            .noun,        "f"),
            ("pariente",                               "relative (general)",                                .noun,        "m"),
            ("cónyuge",                                "spouse",                                            .noun,        "m"),
            ("bisabuelo",                              "great-grandfather",                                 .noun,        "m"),
            ("bisabuela",                              "great-grandmother",                                 .noun,        "f"),
            ("bisnieto",                               "great-grandchild",                                  .noun,        "m"),
            ("compadre",                               "co-godparent (MX)",                                 .noun,        "m"),
            ("comadre",                                "co-godmother (MX)",                                 .noun,        "f"),
            ("extranjero",                             "foreigner",                                         .noun,        "m"),
            ("inmigrante",                             "immigrant",                                         .noun,        "m"),
            ("emigrante",                              "emigrant",                                          .noun,        "m"),
            ("visitante",                              "visitor",                                           .noun,        "m"),
            ("residente",                              "resident",                                          .noun,        "m"),
            ("propietario",                            "owner, landlord",                                   .noun,        "m"),
            ("arrendatario",                           "lessee, renter",                                    .noun,        "m"),
            ("casero",                                 "landlord (MX)",                                     .noun,        "m"),
            ("vecina",                                 "neighbor (f)",                                      .noun,        "f"),
            ("colaborador",                            "collaborator",                                      .noun,        "m"),
            ("benefactor",                             "benefactor",                                        .noun,        "m"),
            ("beneficiario",                           "beneficiary",                                       .noun,        "m"),
            ("donante",                                "donor",                                             .noun,        "m"),
            ("donativo",                               "donation",                                          .noun,        "m"),
            ("patrocinador",                           "sponsor",                                           .noun,        "m"),
            ("mecenas",                                "patron of the arts",                                .noun,        "m"),
            ("ciudadana",                              "citizen (f)",                                       .noun,        "f"),
            ("rival",                                  "rival",                                             .noun,        "m"),
            ("adversario",                             "adversary",                                         .noun,        "m"),
            ("aliado",                                 "ally",                                              .noun,        "m"),
            ("herrero",                                "blacksmith",                                        .noun,        "m"),
            ("soldador",                               "welder",                                            .noun,        "m"),
            ("técnico",                                "technician",                                        .noun,        "m"),
            ("locutor",                                "announcer, broadcaster",                            .noun,        "m"),
            ("cantautor",                              "singer-songwriter",                                 .noun,        "m"),
            ("compositor",                             "composer",                                          .noun,        "m"),
            ("coreógrafo",                             "choreographer",                                     .noun,        "m"),
            ("acróbata",                               "acrobat",                                           .noun,        "m"),
            ("malabarista",                            "juggler",                                           .noun,        "m"),
            ("mago",                                   "magician",                                          .noun,        "m"),
            ("dramaturgo",                             "playwright",                                        .noun,        "m"),
            ("bartender",                              "bartender",                                         .noun,        "m"),
            ("repostero",                              "pastry chef",                                       .noun,        "m"),
            ("carnicero",                              "butcher",                                           .noun,        "m"),
            ("panadero",                               "baker",                                             .noun,        "m"),
            ("tortillero",                             "tortilla maker (MX)",                               .noun,        "m"),
            ("jardinero",                              "gardener",                                          .noun,        "m"),
            ("florista",                               "florist",                                           .noun,        "m"),
            ("fisioterapeuta",                         "physiotherapist",                                   .noun,        "m"),
            ("nutriólogo",                             "nutritionist (MX)",                                 .noun,        "m"),
            ("obstetra",                               "obstetrician",                                      .noun,        "m"),
            ("geriatra",                               "geriatrician",                                      .noun,        "m"),
            ("epidemiólogo",                           "epidemiologist",                                    .noun,        "m"),
            ("farmacéutico",                           "pharmacist",                                        .noun,        "m"),
            ("optometrista",                           "optometrist",                                       .noun,        "m"),
            ("audiólogo",                              "audiologist",                                       .noun,        "m"),
            ("kinesiólogo",                            "kinesiologist",                                     .noun,        "m"),
            ("logopeda",                               "speech therapist",                                  .noun,        "m"),
            ("terapeuta ocupacional",                  "occupational therapist",                            .noun,        "m"),
            ("trabajador social",                      "social worker",                                     .noun,        "m"),
            ("pedagogo",                               "educator, pedagogue",                               .noun,        "m"),
            ("geógrafo",                               "geographer",                                        .noun,        "m"),
            ("geólogo",                                "geologist",                                         .noun,        "m"),
            ("meteorólogo",                            "meteorologist",                                     .noun,        "m"),
            ("oceanógrafo",                            "oceanographer",                                     .noun,        "m"),
            ("vulcanólogo",                            "volcanologist",                                     .noun,        "m"),
            ("sismólogo",                              "seismologist",                                      .noun,        "m"),
            ("astrónomo",                              "astronomer",                                        .noun,        "m"),
            ("astrofísico",                            "astrophysicist",                                    .noun,        "m"),
            ("teólogo",                                "theologian",                                        .noun,        "m"),
            ("filósofo",                               "philosopher",                                       .noun,        "m"),
            ("sociólogo",                              "sociologist",                                       .noun,        "m"),
            ("antropólogo",                            "anthropologist",                                    .noun,        "m"),
            ("arqueólogo",                             "archaeologist",                                     .noun,        "m"),
            ("paleontólogo",                           "paleontologist",                                    .noun,        "m"),
            ("historiador",                            "historian",                                         .noun,        "m"),
            ("archivista",                             "archivist",                                         .noun,        "m"),
            ("traductor",                              "translator",                                        .noun,        "m"),
            ("intérprete",                             "interpreter",                                       .noun,        "m"),
            ("diplomático",                            "diplomat",                                          .noun,        "m"),
            ("cónsul",                                 "consul",                                            .noun,        "m"),
            ("canciller",                              "chancellor",                                        .noun,        "m"),
            ("regidor",                                "city councillor (MX)",                              .noun,        "m"),
            ("auditor",                                "auditor",                                           .noun,        "m"),
            ("actuario",                               "actuary",                                           .noun,        "m"),
            ("cognición",                              "cognition",                                         .noun,        "f"),
            ("razonamiento",                           "reasoning",                                         .noun,        "m"),
            ("dialéctica",                             "dialectics",                                        .noun,        "f"),
            ("epistemología",                          "epistemology",                                      .noun,        "f"),
            ("ontología",                              "ontology",                                          .noun,        "f"),
            ("metafísica",                             "metaphysics",                                       .noun,        "f"),
            ("paradigma",                              "paradigm",                                          .noun,        "m"),
            ("dogma",                                  "dogma",                                             .noun,        "m"),
            ("utopía",                                 "utopia",                                            .noun,        "f"),
            ("distopía",                               "dystopia",                                          .noun,        "f"),
            ("retórica",                               "rhetoric",                                          .noun,        "f"),
            ("narrativa",                              "narrative",                                         .noun,        "f"),
            ("discurso",                               "speech, discourse",                                 .noun,        "m"),
            ("semiótica",                              "semiotics",                                         .noun,        "f"),
            ("lingüística",                            "linguistics",                                       .noun,        "f"),
            ("fonología",                              "phonology",                                         .noun,        "f"),
            ("morfología",                             "morphology",                                        .noun,        "f"),
            ("sintaxis",                               "syntax",                                            .noun,        "f"),
            ("semántica",                              "semantics",                                         .noun,        "f"),
            ("lexicografía",                           "lexicography",                                      .noun,        "f"),
            ("etimología",                             "etymology",                                         .noun,        "f"),
            ("dialecto",                               "dialect",                                           .noun,        "m"),
            ("jerga",                                  "slang, jargon",                                     .noun,        "f"),
            ("argot",                                  "argot, slang",                                      .noun,        "m"),
            ("neologismo",                             "neologism",                                         .noun,        "m"),
            ("eufemismo",                              "euphemism",                                         .noun,        "m"),
            ("proverbio",                              "proverb",                                           .noun,        "m"),
            ("refrán",                                 "saying, proverb (MX)",                              .noun,        "m"),
            ("aforismo",                               "aphorism",                                          .noun,        "m"),
            ("paradoja",                               "paradox",                                           .noun,        "f"),
            ("alegoría",                               "allegory",                                          .noun,        "f"),
            ("emblema",                                "emblem",                                            .noun,        "m"),
            ("icono",                                  "icon",                                              .noun,        "m"),
            ("subconsciencia",                         "subconsciousness",                                  .noun,        "f"),
            ("ideología",                              "ideology",                                          .noun,        "f"),
            ("esqueleto",                              "skeleton",                                          .noun,        "m"),
            ("cráneo",                                 "skull, cranium",                                    .noun,        "m"),
            ("fémur",                                  "femur",                                             .noun,        "m"),
            ("tibia",                                  "tibia",                                             .noun,        "f"),
            ("peroné",                                 "fibula",                                            .noun,        "m"),
            ("rótula",                                 "kneecap, patella",                                  .noun,        "f"),
            ("húmero",                                 "humerus",                                           .noun,        "m"),
            ("escápula",                               "shoulder blade",                                    .noun,        "f"),
            ("falange",                                "phalanx (bone)",                                    .noun,        "f"),
            ("menisco",                                "meniscus",                                          .noun,        "m"),
            ("cerebelo",                               "cerebellum",                                        .noun,        "m"),
            ("corteza cerebral",                       "cerebral cortex",                                   .noun,        "f"),
            ("tronco encefálico",                      "brain stem",                                        .noun,        "m"),
            ("lóbulo frontal",                         "frontal lobe",                                      .noun,        "m"),
            ("abanicar",                               "to fan",                                            .infinitive,        nil),
            ("abdicar",                                "to abdicate",                                       .infinitive,        nil),
            ("abofetear",                              "to slap",                                           .infinitive,        nil),
            ("abreviar",                               "to abbreviate",                                     .infinitive,        nil),
            ("abrumar",                                "to overwhelm",                                      .infinitive,        nil),
            ("acatar",                                 "to comply with, obey",                              .infinitive,        nil),
            ("aclamar",                                "to acclaim",                                        .infinitive,        nil),
            ("aclimatar",                              "to acclimatize",                                    .infinitive,        nil),
            ("acumular",                               "to accumulate",                                     .infinitive,        nil),
            ("adornar",                                "to decorate, adorn",                                .infinitive,        nil),
            ("agotar",                                 "to exhaust, deplete",                               .infinitive,        nil),
            ("agrupar",                                "to group",                                          .infinitive,        nil),
            ("agudizar",                               "to sharpen, worsen",                                .infinitive,        nil),
            ("alentar",                                "to encourage",                                      .infinitive,        nil),
            ("alterar",                                "to alter, disturb",                                 .infinitive,        nil),
            ("amonestar",                              "to admonish, warn",                                 .infinitive,        nil),
            ("anticipar",                              "to anticipate",                                     .infinitive,        nil),
            ("aportar",                                "to contribute",                                     .infinitive,        nil),
            ("aprovechar",                             "to take advantage of",                              .infinitive,        nil),
            ("asegurar",                               "to assure, secure",                                 .infinitive,        nil),
            ("asignar",                                "to assign",                                         .infinitive,        nil),
            ("asistir",                                "to assist; to attend",                              .infinitive,        nil),
            ("asociar",                                "to associate",                                      .infinitive,        nil),
            ("atravesar",                              "to cross, go through",                              .infinitive,        nil),
            ("bordar",                                 "to embroider",                                      .infinitive,        nil),
            ("bostezar",                               "to yawn",                                           .infinitive,        nil),
            ("brotar",                                 "to sprout, gush",                                   .infinitive,        nil),
            ("callar",                                 "to silence, be quiet",                              .infinitive,        nil),
            ("cazar",                                  "to hunt",                                           .infinitive,        nil),
            ("cepillar",                               "to brush",                                          .infinitive,        nil),
            ("charlar",                                "to chat",                                           .infinitive,        nil),
            ("cicatrizar",                             "to heal, scar over",                                .infinitive,        nil),
            ("circular",                               "to circulate",                                      .infinitive,        nil),
            ("coleccionar",                            "to collect",                                        .infinitive,        nil),
            ("colocar",                                "to place, put",                                     .infinitive,        nil),
            ("concentrar",                             "to concentrate",                                    .infinitive,        nil),
            ("conquistar",                             "to conquer",                                        .infinitive,        nil),
            ("contemplar",                             "to contemplate",                                    .infinitive,        nil),
            ("contribuir",                             "to contribute",                                     .infinitive,        nil),
            ("dañar",                                  "to damage",                                         .infinitive,        nil),
            ("declarar",                               "to declare",                                        .infinitive,        nil),
            ("desear",                                 "to desire, wish",                                   .infinitive,        nil),
            ("desperdiciar",                           "to waste",                                          .infinitive,        nil),
            ("educar",                                 "to educate",                                        .infinitive,        nil),
            ("emigrar",                                "to emigrate",                                       .infinitive,        nil),
            ("emocionar",                              "to move emotionally",                               .infinitive,        nil),
            ("encargar",                               "to entrust, order",                                 .infinitive,        nil),
            ("enriquecer",                             "to enrich",                                         .infinitive,        nil),
            ("enviar",                                 "to send",                                           .infinitive,        nil),
            ("evolucionar",                            "to evolve",                                         .infinitive,        nil),
            ("facilitar",                              "to facilitate",                                     .infinitive,        nil),
            ("financiar",                              "to finance",                                        .infinitive,        nil),
            ("florecer",                               "to flourish, flower",                               .infinitive,        nil),
            ("fomentar",                               "to promote, foster",                                .infinitive,        nil),
            ("fortalecer",                             "to strengthen",                                     .infinitive,        nil),
            ("gestionar",                              "to manage, handle",                                 .infinitive,        nil),
            ("gustar",                                 "to please, to like",                                .infinitive,        nil),
            ("hundir",                                 "to sink",                                           .infinitive,        nil),
            ("incrementar",                            "to increase",                                       .infinitive,        nil),
            ("ingresar",                               "to enter, join",                                    .infinitive,        nil),
            ("innovar",                                "to innovate",                                       .infinitive,        nil),
            ("intervenir",                             "to intervene",                                      .infinitive,        nil),
            ("introducir",                             "to introduce",                                      .infinitive,        nil),
            ("liberar",                                "to liberate",                                       .infinitive,        nil),
            ("mover",                                  "to move",                                           .infinitive,        nil),
            ("abastecer",                              "to supply, stock",                                  .infinitive,        nil),
            ("abrigar",                                "to shelter, keep warm",                             .infinitive,        nil),
            ("acampar",                                "to camp",                                           .infinitive,        nil),
            ("acceder",                                "to access; to agree",                               .infinitive,        nil),
            ("aclarar",                                "to clarify",                                        .infinitive,        nil),
            ("acompañar",                              "to accompany",                                      .infinitive,        nil),
            ("adaptar",                                "to adapt",                                          .infinitive,        nil),
            ("apuntar",                                "to note down; to aim",                              .infinitive,        nil),
            ("arriesgarse",                            "to risk, take a chance",                            .infinitive,        nil),
            ("ascender",                               "to ascend; to be promoted",                         .infinitive,        nil),
            ("atemorizar",                             "to frighten",                                       .infinitive,        nil),
            ("atraer",                                 "to attract",                                        .infinitive,        nil),
            ("atribuir",                               "to attribute",                                      .infinitive,        nil),
            ("capturar",                               "to capture",                                        .infinitive,        nil),
            ("caracterizar",                           "to characterize",                                   .infinitive,        nil),
            ("carecer",                                "to lack",                                           .infinitive,        nil),
            ("castigar",                               "to punish",                                         .infinitive,        nil),
            ("ceder",                                  "to yield, give way",                                .infinitive,        nil),
            ("coincidir",                              "to coincide",                                       .infinitive,        nil),
            ("concluir",                               "to conclude",                                       .infinitive,        nil),
            ("conmemorar",                             "to commemorate",                                    .infinitive,        nil),
            ("consentir",                              "to consent; to spoil",                              .infinitive,        nil),
            ("convertir",                              "to convert",                                        .infinitive,        nil),
            ("desaparecer",                            "to disappear",                                      .infinitive,        nil),
            ("disfrutar",                              "to enjoy",                                          .infinitive,        nil),
            ("disolver",                               "to dissolve",                                       .infinitive,        nil),
            ("distraer",                               "to distract",                                       .infinitive,        nil),
            ("dominar",                                "to dominate, master",                               .infinitive,        nil),
            ("emitir",                                 "to emit, issue",                                    .infinitive,        nil),
            ("encabezar",                              "to head, lead",                                     .infinitive,        nil),
            ("enfrentar",                              "to face, confront",                                 .infinitive,        nil),
            ("enfocar",                                "to focus",                                          .infinitive,        nil),
            ("ensayar",                                "to rehearse",                                       .infinitive,        nil),
            ("enumerar",                               "to enumerate",                                      .infinitive,        nil),
            ("equipar",                                "to equip",                                          .infinitive,        nil),
            ("estorbar",                               "to obstruct, get in the way",                       .infinitive,        nil),
            ("exhibir",                                "to exhibit",                                        .infinitive,        nil),
            ("exponer",                                "to expose, present",                                .infinitive,        nil),
            ("frustrar",                               "to frustrate",                                      .infinitive,        nil),
            ("generar",                                "to generate",                                       .infinitive,        nil),
            ("lamentar",                               "to lament, regret",                                 .infinitive,        nil),
            ("liderar",                                "to lead",                                           .infinitive,        nil),
            ("luchar",                                 "to fight, struggle",                                .infinitive,        nil),
            ("mantener",                               "to maintain",                                       .infinitive,        nil),
            ("modelar",                                "to model, shape",                                   .infinitive,        nil),
            ("navegar",                                "to navigate, surf (web)",                           .infinitive,        nil),
            ("orientar",                               "to orient, guide",                                  .infinitive,        nil),
            ("padecer",                                "to suffer (an illness)",                            .infinitive,        nil),
            ("presenciar",                             "to witness",                                        .infinitive,        nil),
            ("presumir",                               "to show off; to presume",                           .infinitive,        nil),
            ("promover",                               "to promote",                                        .infinitive,        nil),
            ("quemar",                                 "to burn",                                           .infinitive,        nil),
            ("reformar",                               "to reform",                                         .infinitive,        nil),
            ("renovar",                                "to renew, renovate",                                .infinitive,        nil),
            ("rescatar",                               "to rescue",                                         .infinitive,        nil),
            ("restaurar",                              "to restore",                                        .infinitive,        nil),
            ("retomar",                                "to resume, take back",                              .infinitive,        nil),
            ("retrasar",                               "to delay",                                          .infinitive,        nil),
            ("revelar",                                "to reveal",                                         .infinitive,        nil),
            ("salvar",                                 "to save (a life)",                                  .infinitive,        nil),
            ("sonar",                                  "to sound, ring",                                    .infinitive,        nil),
            ("soplar",                                 "to blow",                                           .infinitive,        nil),
            ("subrayar",                               "to underline, emphasize",                           .infinitive,        nil),
            ("toser",                                  "to cough",                                          .infinitive,        nil),
            ("trasladar",                              "to transfer, move",                                 .infinitive,        nil),
            ("ubicar",                                 "to locate, place",                                  .infinitive,        nil),
            ("velar",                                  "to watch over; to veil",                            .infinitive,        nil),
            ("vigilar",                                "to watch, guard",                                   .infinitive,        nil),
            ("zanjar",                                 "to settle (dispute)",                               .infinitive,        nil),
            ("zarpar",                                 "to set sail",                                       .infinitive,        nil),
            ("abismal",                                "abysmal",                                           .adjective,        nil),
            ("abrupto",                                "abrupt, steep",                                     .adjective,        nil),
            ("adinerado",                              "wealthy",                                           .adjective,        nil),
            ("agridulce",                              "bittersweet",                                       .adjective,        nil),
            ("aguerrido",                              "battle-hardened, fierce",                           .adjective,        nil),
            ("airoso",                                 "graceful; successful",                              .adjective,        nil),
            ("alborotado",                             "rowdy, stirred up",                                 .adjective,        nil),
            ("alentador",                              "encouraging",                                       .adjective,        nil),
            ("alienado",                               "alienated",                                         .adjective,        nil),
            ("amenazante",                             "threatening",                                       .adjective,        nil),
            ("amistoso",                               "friendly",                                          .adjective,        nil),
            ("angosto",                                "narrow",                                            .adjective,        nil),
            ("anhelante",                              "yearning, longing",                                 .adjective,        nil),
            ("anónimo",                                "anonymous",                                         .adjective,        nil),
            ("antagónico",                             "antagonistic",                                      .adjective,        nil),
            ("apagado",                                "dim, dull; switched off",                           .adjective,        nil),
            ("apático",                                "apathetic",                                         .adjective,        nil),
            ("asombroso",                              "astonishing",                                       .adjective,        nil),
            ("atrevido",                               "daring, bold",                                      .adjective,        nil),
            ("autoritario",                            "authoritarian",                                     .adjective,        nil),
            ("bélico",                                 "warlike",                                           .adjective,        nil),
            ("benévolo",                               "benevolent",                                        .adjective,        nil),
            ("cabal",                                  "complete, proper",                                  .adjective,        nil),
            ("calculador",                             "calculating",                                       .adjective,        nil),
            ("callado",                                "quiet, silent",                                     .adjective,        nil),
            ("cansino",                                "tiresome, wearisome",                               .adjective,        nil),
            ("catastrófico",                           "catastrophic",                                      .adjective,        nil),
            ("cauteloso",                              "cautious",                                          .adjective,        nil),
            ("ceremonioso",                            "ceremonious",                                       .adjective,        nil),
            ("chillón",                                "loud, garish; whiny",                               .adjective,        nil),
            ("colérico",                               "choleric, hot-tempered",                            .adjective,        nil),
            ("colorido",                               "colorful",                                          .adjective,        nil),
            ("combativo",                              "combative",                                         .adjective,        nil),
            ("comprometido",                           "committed; engaged",                                .adjective,        nil),
            ("conciso",                                "concise",                                           .adjective,        nil),
            ("confiado",                               "trusting, confident",                               .adjective,        nil),
            ("confuso",                                "confused",                                          .adjective,        nil),
            ("conmovedor",                             "moving, touching",                                  .adjective,        nil),
            ("controvertido",                          "controversial",                                     .adjective,        nil),
            ("convincente",                            "convincing",                                        .adjective,        nil),
            ("cordial",                                "cordial, warm",                                     .adjective,        nil),
            ("codicioso",                              "greedy, covetous",                                  .adjective,        nil),
            ("cortés",                                 "polite, courteous",                                 .adjective,        nil),
            ("cruel",                                  "cruel",                                             .adjective,        nil),
            ("dócil",                                  "docile, obedient",                                  .adjective,        nil),
            ("dominante",                              "dominant",                                          .adjective,        nil),
            ("embustero",                              "lying, deceitful",                                  .adjective,        nil),
            ("emocionante",                            "exciting, moving",                                  .adjective,        nil),
            ("enigmático",                             "enigmatic",                                         .adjective,        nil),
            ("enérgico",                               "energetic",                                         .adjective,        nil),
            ("equitativo",                             "equitable, fair",                                   .adjective,        nil),
            ("errático",                               "erratic",                                           .adjective,        nil),
            ("escéptico",                              "skeptical",                                         .adjective,        nil),
            ("excéntrico",                             "eccentric",                                         .adjective,        nil),
            ("furibundo",                              "furious, raging",                                   .adjective,        nil),
            ("glorioso",                               "glorious",                                          .adjective,        nil),
            ("grato",                                  "pleasant, agreeable",                               .adjective,        nil),
            ("grotesco",                               "grotesque",                                         .adjective,        nil),
            ("halagador",                              "flattering",                                        .adjective,        nil),
            ("hipócrita",                              "hypocritical",                                      .adjective,        nil),
            ("histórico",                              "historical",                                        .adjective,        nil),
            ("imbatible",                              "unbeatable",                                        .adjective,        nil),
            ("impetuoso",                              "impetuous",                                         .adjective,        nil),
            ("incansable",                             "tireless",                                          .adjective,        nil),
            ("incierto",                               "uncertain",                                         .adjective,        nil),
            ("inconstante",                            "inconstant",                                        .adjective,        nil),
            ("indomable",                              "indomitable",                                       .adjective,        nil),
            ("inexorable",                             "inexorable",                                        .adjective,        nil),
            ("infiel",                                 "unfaithful",                                        .adjective,        nil),
            ("ingrato",                                "ungrateful",                                        .adjective,        nil),
            ("innato",                                 "innate",                                            .adjective,        nil),
            ("inquieto",                               "restless",                                          .adjective,        nil),
            ("insólito",                               "unusual, rare",                                     .adjective,        nil),
            ("instintivo",                             "instinctive",                                       .adjective,        nil),
            ("integral",                               "integral",                                          .adjective,        nil),
            ("intransigente",                          "intransigent",                                      .adjective,        nil),
            ("inútil",                                 "useless",                                           .adjective,        nil),
            ("lacónico",                               "laconic, terse",                                    .adjective,        nil),
            ("lamentable",                             "deplorable",                                        .adjective,        nil),
            ("latente",                                "latent",                                            .adjective,        nil),
            ("legítimo",                               "legitimate",                                        .adjective,        nil),
            ("lúcido",                                 "lucid, clear-minded",                               .adjective,        nil),
            ("macabro",                                "macabre",                                           .adjective,        nil),
            ("mágico",                                 "magical",                                           .adjective,        nil),
            ("maravilloso",                            "marvelous, wonderful",                              .adjective,        nil),
            ("meloso",                                 "sweet, syrupy",                                     .adjective,        nil),
            ("memorable",                              "memorable",                                         .adjective,        nil),
            ("mezquino",                               "mean, petty",                                       .adjective,        nil),
            ("miedoso",                                "fearful, cowardly",                                 .adjective,        nil),
            ("mundano",                                "worldly",                                           .adjective,        nil),
            ("narcisista",                             "narcissistic",                                      .adjective,        nil),
            ("nefasto",                                "disastrous",                                        .adjective,        nil),
            ("nítido",                                 "sharp, clear",                                      .adjective,        nil),
            ("notorio",                                "notorious, well-known",                             .adjective,        nil),
            ("obeso",                                  "obese",                                             .adjective,        nil),
            ("opuesto",                                "opposite",                                          .adjective,        nil),
            ("osado",                                  "bold, daring",                                      .adjective,        nil),
            ("pálido",                                 "pale",                                              .adjective,        nil),
            ("pausado",                                "slow, measured",                                    .adjective,        nil),
            ("perplejo",                               "perplexed",                                         .adjective,        nil),
            ("persistente",                            "persistent",                                        .adjective,        nil),
            ("piadoso",                                "pious, devout",                                     .adjective,        nil),
            ("plácido",                                "placid, calm",                                      .adjective,        nil),
            ("pleno",                                  "full, complete",                                    .adjective,        nil),
            ("prepotente",                             "arrogant, overbearing",                             .adjective,        nil),
            ("primordial",                             "primordial, fundamental",                           .adjective,        nil),
            ("prodigioso",                             "prodigious",                                        .adjective,        nil),
            ("prolífico",                              "prolific",                                          .adjective,        nil),
            ("próspero",                               "prosperous",                                        .adjective,        nil),
            ("provocador",                             "provocative",                                       .adjective,        nil),
            ("recio",                                  "strong, robust",                                    .adjective,        nil),
            ("resignado",                              "resigned",                                          .adjective,        nil),
            ("resuelto",                               "resolute, determined",                              .adjective,        nil),
            ("revelador",                              "revealing",                                         .adjective,        nil),
            ("rotundo",                                "emphatic, categorical",                             .adjective,        nil),
            ("solemne",                                "solemn",                                            .adjective,        nil),
            ("sorprendente",                           "surprising",                                        .adjective,        nil),
            ("suntuoso",                               "sumptuous",                                         .adjective,        nil),
            ("tóxico",                                 "toxic",                                             .adjective,        nil),
            ("turbulento",                             "turbulent",                                         .adjective,        nil),
            ("ubicuo",                                 "ubiquitous",                                        .adjective,        nil),
            ("veraz",                                  "truthful",                                          .adjective,        nil),
            ("vergonzoso",                             "shameful, embarrassing",                            .adjective,        nil),
            ("versátil",                               "versatile",                                         .adjective,        nil),
            ("visceral",                               "visceral",                                          .adjective,        nil),
            ("vívido",                                 "vivid",                                             .adjective,        nil),
            ("zalamero",                               "flattering, fawning",                               .adjective,        nil),
            ("afablemente",                            "affably",                                           .adverb,        nil),
            ("alegremente",                            "cheerfully",                                        .adverb,        nil),
            ("amargamente",                            "bitterly",                                          .adverb,        nil),
            ("ávidamente",                             "eagerly, avidly",                                   .adverb,        nil),
            ("brutalmente",                            "brutally",                                          .adverb,        nil),
            ("casualmente",                            "casually; coincidentally",                          .adverb,        nil),
            ("coherentemente",                         "coherently",                                        .adverb,        nil),
            ("cordialmente",                           "cordially",                                         .adverb,        nil),
            ("críticamente",                           "critically",                                        .adverb,        nil),
            ("diligentemente",                         "diligently",                                        .adverb,        nil),
            ("enérgicamente",                          "energetically",                                     .adverb,        nil),
            ("enormemente",                            "enormously",                                        .adverb,        nil),
            ("evidentemente",                          "evidently",                                         .adverb,        nil),
            ("fielmente",                              "faithfully",                                        .adverb,        nil),
            ("francamente",                            "frankly",                                           .adverb,        nil),
            ("genuinamente",                           "genuinely",                                         .adverb,        nil),
            ("hábilmente",                             "skillfully",                                        .adverb,        nil),
            ("humildemente",                           "humbly",                                            .adverb,        nil),
            ("incansablemente",                        "tirelessly",                                        .adverb,        nil),
            ("inequívocamente",                        "unequivocally",                                     .adverb,        nil),
            ("injustamente",                           "unjustly",                                          .adverb,        nil),
            ("inteligentemente",                       "intelligently",                                     .adverb,        nil),
            ("lealmente",                              "loyally",                                           .adverb,        nil),
            ("lúcidamente",                            "lucidly",                                           .adverb,        nil),
            ("masivamente",                            "massively",                                         .adverb,        nil),
            ("meticulosamente",                        "meticulously",                                      .adverb,        nil),
            ("necesariamente",                         "necessarily",                                       .adverb,        nil),
            ("nerviosamente",                          "nervously",                                         .adverb,        nil),
            ("objetivamente",                          "objectively",                                       .adverb,        nil),
            ("pacíficamente",                          "peacefully",                                        .adverb,        nil),
            ("pacientemente",                          "patiently",                                         .adverb,        nil),
            ("poéticamente",                           "poetically",                                        .adverb,        nil),
            ("rígidamente",                            "rigidly",                                           .adverb,        nil),
            ("rotundamente",                           "categorically",                                     .adverb,        nil),
            ("sinceramente",                           "sincerely",                                         .adverb,        nil),
            ("sofisticadamente",                       "sophisticatedly",                                   .adverb,        nil),
            ("sutilmente",                             "subtly",                                            .adverb,        nil),
            ("tácitamente",                            "tacitly",                                           .adverb,        nil),
            ("tajantemente",                           "categorically, flatly",                             .adverb,        nil),
            ("unánimemente",                           "unanimously",                                       .adverb,        nil),
            ("verdaderamente",                         "truly, really",                                     .adverb,        nil),
            ("victoriosamente",                        "victoriously",                                      .adverb,        nil),
            ("apasionadamente",                        "passionately",                                      .adverb,        nil),
        ]

        // Remove duplicates by spanish word (keep first occurrence)
        var seen = Set<String>()
        let deduped = raw.filter { seen.insert($0.0).inserted }

        return deduped.enumerated().map { i, r in
            Word(order: i, spanish: r.0, english: r.1, partOfSpeech: r.2, gender: r.3)
        }
    }()
}
