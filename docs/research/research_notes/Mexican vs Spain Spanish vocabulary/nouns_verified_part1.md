# DEM verification of Spain/Mexico noun pairs, part 1 (rows 1–180 of nouns.md)

## Which pairs are confirmed, which are wrong or overstated, and which could not be checked?

### Takeaway
I checked about 165 of the rows in rows 1–180 that were not already DEM✓ against the Diccionario del Español de México (DEM). The Mexican word is in DEM with the claimed meaning in about 135 of them (approximate hand count). The most common problem is the "Spain word in MX?" column. In about 20 rows DEM lists the Spain word with the same meaning, often as a plain synonym that points to the Mexican word (nevera = refrigerador, acera = banqueta, pendiente = arete, cola = fila, sujetador = brassier, ordenador = computadora). In those rows "rare" or "no" overstates the difference. A smaller set of Spain words means something different or risky in DEM: grifo is *(Popular)* a marijuana user, cerilla is earwax, bombilla is a lamp chimney or mate straw, rotonda is a circular monument, bizcocho is pan dulce, and polo has no ice-pop sense.

### Cited Findings

**Method.** Each word was fetched from `https://dem.colmex.mx/ver/<word>` with curl on 2026-11-07, and the page body was parsed.
- An entry counts as present only if the page opens with that headword and a part-of-speech tag.
- Pages showing "Su búsqueda no tuvo resultados", or pages that only list other entries containing the word, count as **not in DEM**.
- Pages that returned empty were re-fetched one at a time.
- The pages list homographs together (for example papa 1 s f "potato" and papa 2 s m "pope"), so all senses were read.
- Evidence below is my paraphrase. Labels in *(italics)* are DEM's own.

Verdict key:
- **confirmed**: the Mexican word has the claimed sense in DEM.
- **corrected**: the claim needs a change, which is stated.
- **not in DEM**: no headword.
- **not checked**: not fetched, or the sense is not visible.
- "ES:" gives the DEM finding for the Spain word.

Rows already DEM✓ in nouns.md were not re-checked: 2, 10, 26, 43, 57, 97, 99, 127. Row 55 is a cross-reference.

#### Food and drink
| # | Spain | Mexico | Verdict | DEM evidence (paraphrase) | URL |
|---|---|---|---|---|---|
| 1 | patata | papa | confirmed | papa s f: potato tuber; *(Popular)* "puras papas" = lies. ES: patata entry just refers to papa | [papa](https://dem.colmex.mx/ver/papa), [patata](https://dem.colmex.mx/ver/patata) |
| 3 | melocotón | durazno | confirmed | durazno s m: sweet, fleshy stone fruit. ES: melocotón = durazno type not grown in Mexico | [durazno](https://dem.colmex.mx/ver/durazno), [melocotón](https://dem.colmex.mx/ver/melocotón) |
| 4 | albaricoque | chabacano | confirmed | chabacano s m: apricot tree and fruit. ES: albaricoque listed, refers to chabacano | [chabacano](https://dem.colmex.mx/ver/chabacano), [albaricoque](https://dem.colmex.mx/ver/albaricoque) |
| 5 | cacahuete | cacahuate | confirmed | cacahuate s m: peanut plant and fruit. ES: cacahuete has no headword | [cacahuate](https://dem.colmex.mx/ver/cacahuate) |
| 6 | mazorca | elote | confirmed; ES-in-MX corrected | elote s m: tender maize ear, or its kernels as food. ES: mazorca s f is in DEM (maize ear in general) | [elote](https://dem.colmex.mx/ver/elote), [mazorca](https://dem.colmex.mx/ver/mazorca) |
| 7 | guisante | chícharo | confirmed | chícharo s m: pea; *(Popular)* apprentice or helper. ES: guisante refers to chícharo | [chícharo](https://dem.colmex.mx/ver/chícharo), [guisante](https://dem.colmex.mx/ver/guisante) |
| 8 | judía verde | ejote | confirmed | ejote s m: edible green, tender bean pod. ES: judía has no headword (only judío) | [ejote](https://dem.colmex.mx/ver/ejote) |
| 9 | judía / alubia | frijol | confirmed; ES-in-MX corrected | frijol s m: bean plant and seed. ES: alubia s f is in DEM (Phaseolus plant) | [frijol](https://dem.colmex.mx/ver/frijol), [alubia](https://dem.colmex.mx/ver/alubia) |
| 11 | (tomatillo) | tomate | confirmed | tomate s m sense 1: green husked fruit for salsa verde; sense 3: = jitomate | [tomate](https://dem.colmex.mx/ver/tomate) |
| 12 | pimiento | pimiento morrón | confirmed | pimiento s m: non-hot chile variety; pimiento morrón. ES word in DEM too | [pimiento](https://dem.colmex.mx/ver/pimiento), [morrón](https://dem.colmex.mx/ver/morrón) |
| 13 | guindilla | chile | confirmed; register note | chile s m: Capsicum plant and fruit; *(Popular)* penis; *(Groser)* idioms. ES: guindilla not in DEM | [chile](https://dem.colmex.mx/ver/chile) |
| 14 | calabacín | calabacita | confirmed | calabacita s f: Cucurbita pepo. ES: calabacín not in DEM | [calabacita](https://dem.colmex.mx/ver/calabacita) |
| 15 | remolacha | betabel | confirmed | betabel s m: Beta vulgaris red root. ES: remolacha refers to betabel | [betabel](https://dem.colmex.mx/ver/betabel), [remolacha](https://dem.colmex.mx/ver/remolacha) |
| 16 | boniato / batata | camote | confirmed | camote s m: sweet potato tuber; several *(Popular)* idioms (meterse en un camote). ES: neither boniato nor batata is a headword | [camote](https://dem.colmex.mx/ver/camote) |
| 17 | seta / champiñón | hongo / champiñón | confirmed | hongo s m and champiñón s m (Agaricus) both present. seta not fetched | [hongo](https://dem.colmex.mx/ver/hongo), [champiñón](https://dem.colmex.mx/ver/champiñón) |
| 18 | pomelo | toronja | confirmed | toronja s f: grapefruit. ES: pomelo not in DEM | [toronja](https://dem.colmex.mx/ver/toronja) |
| 19 | lima | limón | confirmed | limón s m: citrus, yellow **or green**. ES: lima s f = a distinct larger, sweet-sour fruit | [limón](https://dem.colmex.mx/ver/limón), [lima](https://dem.colmex.mx/ver/lima) |
| 20 | limón | limón amarillo | not checked (locution) | limón covers yellow and green; "limón amarillo" not seen as a locution | [limón](https://dem.colmex.mx/ver/limón) |
| 21 | mora | zarzamora | confirmed | zarzamora s f: blackberry. ES: mora s f also present (various berries) | [zarzamora](https://dem.colmex.mx/ver/zarzamora), [mora](https://dem.colmex.mx/ver/mora) |
| 22 | anacardo | nuez de la India | confirmed | nuez sense 4: "nuez de la India" is a locution under nuez. ES: anacardo not in DEM | [nuez](https://dem.colmex.mx/ver/nuez) |
| 23 | cebolleta | cebolla cambray / cebollín | confirmed | cebollín s m (Allium); "cebollita de cambray" under cebolla. ES: cebolleta not in DEM | [cebollín](https://dem.colmex.mx/ver/cebollín), [cebolla](https://dem.colmex.mx/ver/cebolla) |
| 24 | patatas fritas (bolsa) | papas / papitas | partly | papa examples include "papas fritas"; "papitas" not a headword | [papa](https://dem.colmex.mx/ver/papa) |
| 25 | patatas fritas (side) | papas a la francesa | not checked | "a la francesa" not found in papa entry | [papa](https://dem.colmex.mx/ver/papa) |
| 27 | tortilla | tortilla | confirmed; register note | tortilla s f: corn flatbread. *(Ofensivo)* idioms "echar tortillas" refer to sex between women | [tortilla](https://dem.colmex.mx/ver/tortilla) |
| 28 | tarta | pastel | confirmed | pastel s m: baked cake (pastel de cumpleaños). ES: tarta = puff-pastry tart or pie | [pastel](https://dem.colmex.mx/ver/pastel), [tarta](https://dem.colmex.mx/ver/tarta) |
| 29 | pastel / pasta | pan dulce | confirmed | pan entry sense 7: "pan dulce" = sweet bread (concha, cuerno, oreja) | [pan](https://dem.colmex.mx/ver/pan) |
| 30 | magdalena | mantecada / panqué | confirmed | mantecada s f: spongy cake in paper mould; panqué s m: loaf or cone cake. ES: magdalena no headword | [mantecada](https://dem.colmex.mx/ver/mantecada), [panqué](https://dem.colmex.mx/ver/panqué) |
| 31 | bizcocho | panqué / pastel | **corrected** | ES: bizcocho in DEM = pan dulce (conchas…), *(Popular)* attractive person. Not sponge cake, so "yes" is wrong; it is "else" | [bizcocho](https://dem.colmex.mx/ver/bizcocho) |
| 32 | nata | crema | confirmed | crema s f: fatty part of milk. ES: nata = skin on boiled milk; *(Popular)* "crema y nata" = the elite | [crema](https://dem.colmex.mx/ver/crema), [nata](https://dem.colmex.mx/ver/nata) |
| 33 | filete | bistec | confirmed | bistec s m: thin flat cut of beef or pork. ES: filete = tenderloin or fish fillet (narrower) | [bistec](https://dem.colmex.mx/ver/bistec), [filete](https://dem.colmex.mx/ver/filete) |
| 34 | carne picada | carne molida | confirmed | molido adj: example "carne molida" | [molido](https://dem.colmex.mx/ver/molido) |
| 35 | beicon | tocino | confirmed | tocino s m: smoked, salted streaky pork in thin slices (i.e. bacon) | [tocino](https://dem.colmex.mx/ver/tocino) |
| 36 | gamba | camarón | confirmed; ES-in-MX corrected | camarón s m: shrimp. ES: gamba in DEM = deep-water decapod, defined as camarón. Not "no" | [camarón](https://dem.colmex.mx/ver/camarón), [gamba](https://dem.colmex.mx/ver/gamba) |
| 37 | panecillo | bolillo | confirmed; register note | bolillo s m: salted wheat roll; *(N) (Popular)* gringo. ES: panecillo no headword | [bolillo](https://dem.colmex.mx/ver/bolillo) |
| 38 | pan de molde | pan de caja | confirmed | pan sense 5: "pan de caja" = industrial sliced rectangular bread | [pan](https://dem.colmex.mx/ver/pan) |
| 39 | cerdo | puerco | confirmed | puerco s: = cerdo (carne de puerco); also insult for a dirty person | [puerco](https://dem.colmex.mx/ver/puerco) |
| 40 | perrito caliente | hot dog / jocho | not in DEM | jocho: no results. "hot dog" not found as a headword | [jocho](https://dem.colmex.mx/ver/jocho) |
| 41 | batido | malteada / licuado | confirmed; ES-in-MX corrected | malteada s f; licuado s m (blender drink). ES: batido s m = foamy egg, milk and fruit drink | [malteada](https://dem.colmex.mx/ver/malteada), [licuado](https://dem.colmex.mx/ver/licuado), [batido](https://dem.colmex.mx/ver/batido) |
| 42 | cubito | hielo | confirmed (hielo only) | hielo s m: frozen water. cubito not fetched | [hielo](https://dem.colmex.mx/ver/hielo) |
| 44 | golosina | dulce | confirmed; ES-in-MX corrected | dulce s m: candy (comprar dulces). ES: golosina s f in DEM, a sweet bought in the street | [dulce](https://dem.colmex.mx/ver/dulce), [golosina](https://dem.colmex.mx/ver/golosina) |
| 45 | piruleta | paleta | confirmed | paleta s f: sweet or ice cream on a stick. piruleta not fetched | [paleta](https://dem.colmex.mx/ver/paleta) |
| 46 | polo | paleta helada | confirmed; ES note corrected | paleta covers ice cream on a stick. ES: polo in DEM shows geographic and other senses; no polo-shirt or ice-pop sense found | [polo](https://dem.colmex.mx/ver/polo) |
| 47 | aperitivo / tapa | botana | confirmed | botana s f: light snack with drinks; *(Popular)* butt of jokes. ES: aperitivo = pre-meal drink; tapa sense 5 = "Spanish-style" bar snack | [botana](https://dem.colmex.mx/ver/botana), [aperitivo](https://dem.colmex.mx/ver/aperitivo), [tapa](https://dem.colmex.mx/ver/tapa) |
| 48 | merienda | lonche / refrigerio | confirmed; register | lonche s m *(Popular)*: lunch; *(N y OCC)* torta/sandwich. refrigerio s m neutral. ES: merienda = light evening meal | [lonche](https://dem.colmex.mx/ver/lonche), [refrigerio](https://dem.colmex.mx/ver/refrigerio), [merienda](https://dem.colmex.mx/ver/merienda) |
| 49 | chupito | caballito | confirmed; **register corrected** | caballito s m *(Popular)*: small tequila glass. Register is Popular, not neutral. ES: chupito not in DEM | [caballito](https://dem.colmex.mx/ver/caballito) |
| 50 | caña | cerveza de barril | confirmed; ES note corrected | "cerveza de barril" is under cerveza. ES: caña sense 7 = tall beer glass and its contents | [cerveza](https://dem.colmex.mx/ver/cerveza), [caña](https://dem.colmex.mx/ver/caña) |
| 51 | birra | chela | confirmed; ES **corrected** | chela s f *(Popular)*: beer. ES: birra not in DEM, so "birra yes" is unsupported | [chela](https://dem.colmex.mx/ver/chela), [birra](https://dem.colmex.mx/ver/birra) |
| 52 | refresco | refresco / chesco | confirmed; register note | refresco s m: soft drink. chesco s m *(Popular)*; the idiom "bajarse por los chescos" is sexual | [refresco](https://dem.colmex.mx/ver/refresco), [chesco](https://dem.colmex.mx/ver/chesco) |
| 53 | café solo | café americano / negro | confirmed; ES-in-MX corrected | café: "café negro" = no milk, "café americano" = weak; "un café solo" also an example | [café](https://dem.colmex.mx/ver/café) |
| 54 | pavo | guajolote / pavo | confirmed | guajolote s m: domestic turkey. ES: pavo sense 1 = guajolote | [guajolote](https://dem.colmex.mx/ver/guajolote), [pavo](https://dem.colmex.mx/ver/pavo) |
| 56 | mantequilla de cacahuete | crema de cacahuate | not checked | phrase not in the cacahuate entry | [cacahuate](https://dem.colmex.mx/ver/cacahuate) |

#### Home and kitchen
| # | Spain | Mexico | Verdict | DEM evidence (paraphrase) | URL |
|---|---|---|---|---|---|
| 58 | piso | departamento / depa | confirmed (depa not in DEM) | departamento s m: dwelling unit in a building. ES: piso = floor or storey only | [departamento](https://dem.colmex.mx/ver/departamento), [piso](https://dem.colmex.mx/ver/piso) |
| 59 | frigorífico / nevera | refrigerador / refri | confirmed; ES-in-MX corrected | refrigerador s m. refri not in DEM. ES: nevera sense 1 = refrigerador; frigorífico = industrial cold store | [refrigerador](https://dem.colmex.mx/ver/refrigerador), [nevera](https://dem.colmex.mx/ver/nevera), [frigorífico](https://dem.colmex.mx/ver/frigorífico) |
| 60 | nevera portátil | hielera | confirmed | hielera s f: insulated box with ice for food and drinks | [hielera](https://dem.colmex.mx/ver/hielera) |
| 61 | grifo | llave | confirmed; ES **flag** | llave sense 6: valve for water or gas. ES: grifo = curly hair; *(Popular)* marijuana user; griffin. No tap sense | [llave](https://dem.colmex.mx/ver/llave), [grifo](https://dem.colmex.mx/ver/grifo) |
| 62 | bombilla | foco | confirmed; ES "else" | foco s m: electric light bulb. ES: bombilla = lamp's glass chimney, or mate drinking tube | [foco](https://dem.colmex.mx/ver/foco), [bombilla](https://dem.colmex.mx/ver/bombilla) |
| 63 | dormitorio | recámara / cuarto | confirmed | recámara s f: bedroom; cuarto s m: room. ES: dormitorio mainly shared sleeping quarters | [recámara](https://dem.colmex.mx/ver/recámara), [dormitorio](https://dem.colmex.mx/ver/dormitorio) |
| 64 | armario | clóset | confirmed | clóset s m: built-in wardrobe; *(Popular)* salir del clóset. ES: armario s m present | [clóset](https://dem.colmex.mx/ver/clóset), [armario](https://dem.colmex.mx/ver/armario) |
| 65 | salón | sala | confirmed | sala s f: room where visitors are received. ES: salón = bigger hall, salón de clases | [sala](https://dem.colmex.mx/ver/sala), [salón](https://dem.colmex.mx/ver/salón) |
| 66 | moqueta | alfombra | confirmed | alfombra s f: carpet covering a floor. ES: moqueta not in DEM | [alfombra](https://dem.colmex.mx/ver/alfombra) |
| 67 | felpudo | tapete | partly | tapete s m: woven piece covering a floor (rug); no explicit doormat sense. ES: felpudo only an adjective (plush) | [tapete](https://dem.colmex.mx/ver/tapete) |
| 68 | cocina / vitrocerámica | estufa | confirmed | estufa s f sense 1: kitchen stove with burners; sense 2: room heater | [estufa](https://dem.colmex.mx/ver/estufa) |
| 69 | estufa / radiador | calentador | confirmed | calentador sense 3: household fixed or portable room heater | [calentador](https://dem.colmex.mx/ver/calentador) |
| 70 | termo | boiler | confirmed; spelling | headword **bóiler** s m (also boiler): water heater; calentador sense 2 the same | [boiler](https://dem.colmex.mx/ver/boiler) |
| 71 | encimera | barra / cubierta | not confirmed | No countertop sense seen in barra or cubierta. ES: encimera not in DEM | [barra](https://dem.colmex.mx/ver/barra), [cubierta](https://dem.colmex.mx/ver/cubierta) |
| 72 | fregadero | tarja | confirmed | tarja s f: deep basin set into the fregadero. ES: fregadero s m also in DEM | [tarja](https://dem.colmex.mx/ver/tarja), [fregadero](https://dem.colmex.mx/ver/fregadero) |
| 73 | lavavajillas | lavatrastes / lavaplatos | partly | lavaplatos sense 2: dish machine. lavatrastes not in DEM. ES: lavavajillas refers to lavaplatos | [lavaplatos](https://dem.colmex.mx/ver/lavaplatos), [lavavajillas](https://dem.colmex.mx/ver/lavavajillas) |
| 74 | cubo de la basura | bote de basura | confirmed | bote s m: rigid container, example "bote de basura"; *(Popular)* jail | [bote](https://dem.colmex.mx/ver/bote) |
| 75 | cubo | cubeta | confirmed; regional note | cubeta s f: bucket. ES: cubo 2 = cubeta in Chiapas, Guerrero, Veracruz, Coahuila and elsewhere | [cubeta](https://dem.colmex.mx/ver/cubeta), [cubo](https://dem.colmex.mx/ver/cubo) |
| 76 | manta | cobija | confirmed; ES **corrected** | cobija s f: blanket. ES: manta sense 1 coarse cotton cloth, **sense 2 blanket** | [cobija](https://dem.colmex.mx/ver/cobija), [manta](https://dem.colmex.mx/ver/manta) |
| 77 | percha | gancho | confirmed | gancho sense 2: triangular hook for hanging clothes. ES: percha = bird perch or wall hook | [gancho](https://dem.colmex.mx/ver/gancho), [percha](https://dem.colmex.mx/ver/percha) |
| 78 | pinza | pinza | confirmed | pinza s f: example "pinzas para colgar la ropa" | [pinza](https://dem.colmex.mx/ver/pinza) |
| 79 | garaje | cochera / garage | confirmed | cochera s f. ES: headword **garage** (also garaje), pronounced garásh | [cochera](https://dem.colmex.mx/ver/cochera), [garaje](https://dem.colmex.mx/ver/garaje) |
| 80 | telefonillo | interfón | confirmed; spelling | headword **interfono** s m (also interfón) | [interfón](https://dem.colmex.mx/ver/interfón) |
| 81 | ascensor | elevador | confirmed | elevador s m. ES: ascensor refers to elevador | [elevador](https://dem.colmex.mx/ver/elevador), [ascensor](https://dem.colmex.mx/ver/ascensor) |
| 82 | fregona | trapeador | confirmed | trapeador s m: cloth on a pole for mopping. ES: fregona no headword; fregón *(Popular)* = pest or very capable | [trapeador](https://dem.colmex.mx/ver/trapeador), [fregona](https://dem.colmex.mx/ver/fregona) |
| 83 | bayeta | trapo / jerga | confirmed; ES-in-MX corrected | jerga 1 s f: coarse cloth for wiping water. ES: bayeta s f in DEM, used as kitchen cloth | [jerga](https://dem.colmex.mx/ver/jerga), [bayeta](https://dem.colmex.mx/ver/bayeta) |
| 84 | estropajo | fibra | confirmed | fibra sense 3: ball of metal threads for scouring. ES: estropajo = loofah fibre | [fibra](https://dem.colmex.mx/ver/fibra), [estropajo](https://dem.colmex.mx/ver/estropajo) |
| 85 | film transparente | plástico adherente | not checked | no matching sense found in plástico | [plástico](https://dem.colmex.mx/ver/plástico) |
| 86 | interruptor | apagador | confirmed | apagador s m: light switch; interruptor (circuit device) refers to apagador | [apagador](https://dem.colmex.mx/ver/apagador), [interruptor](https://dem.colmex.mx/ver/interruptor) |
| 87 | fontanero | plomero | confirmed; ES **corrected** | plomero s. ES: fontanero = plomero "in several regions of the country", so regional, not rare | [plomero](https://dem.colmex.mx/ver/plomero), [fontanero](https://dem.colmex.mx/ver/fontanero) |
| 88 | cerilla | cerillo | confirmed; ES **flag** | cerillo s m: match. ES: cerilla s f = **earwax** | [cerillo](https://dem.colmex.mx/ver/cerillo), [cerilla](https://dem.colmex.mx/ver/cerilla) |
| 89 | mechero | encendedor | confirmed | encendedor s m: lighter. ES: mechero = lamp burner or Bunsen burner | [encendedor](https://dem.colmex.mx/ver/encendedor), [mechero](https://dem.colmex.mx/ver/mechero) |
| 90 | mando | control (remoto) | confirmed | control sense 6: control (remoto). ES: mando = command, control mechanism | [control](https://dem.colmex.mx/ver/control), [mando](https://dem.colmex.mx/ver/mando) |
| 91 | sofá | sillón / sofá | confirmed | sillón sense 3 = sofá; sofá s m also present | [sillón](https://dem.colmex.mx/ver/sillón), [sofá](https://dem.colmex.mx/ver/sofá) |
| 92 | trastero | cuarto de triques / bodega | confirmed | trique 2 s m: junk, example "el cuarto de los triques"; bodega sense 2: storage area. ES: trastero = dish cupboard | [trique](https://dem.colmex.mx/ver/trique), [bodega](https://dem.colmex.mx/ver/bodega), [trastero](https://dem.colmex.mx/ver/trastero) |
| 93 | sartén | sartén | confirmed gender; **register flag** | sartén **s m o f**; examples "al sartén", "un sartén". *(Caló)* female genitals | [sartén](https://dem.colmex.mx/ver/sartén) |
| 94 | cazo | olla / cacerola | confirmed; ES-in-MX corrected | olla s f, cacerola s f. ES: cazo s m in DEM, a deep cooking pot | [olla](https://dem.colmex.mx/ver/olla), [cazo](https://dem.colmex.mx/ver/cazo) |
| 95 | chalé | casa (sola) | not checked | chalé not in DEM; casa not fetched | [chalé](https://dem.colmex.mx/ver/chalé) |

#### Transport and cars
| # | Spain | Mexico | Verdict | DEM evidence (paraphrase) | URL |
|---|---|---|---|---|---|
| 96 | coche | carro / coche / auto | confirmed | coche 1 s m: car (example "my car doesn't run Tuesdays"); *(Rural)* coche 2 = pig. carro s m, auto s m | [coche](https://dem.colmex.mx/ver/coche), [carro](https://dem.colmex.mx/ver/carro), [auto](https://dem.colmex.mx/ver/auto) |
| 98 | autocar | autobús | confirmed | autobús s m: collective passenger vehicle, = camión. ES: autocar not in DEM | [autobús](https://dem.colmex.mx/ver/autobús) |
| 100 | billete | boleto | confirmed | boleto s m: ticket (camión, avión); *(Popular)* "otro boleto". ES: billete = banknote, *(Popular)* money, lottery ticket | [boleto](https://dem.colmex.mx/ver/boleto), [billete](https://dem.colmex.mx/ver/billete) |
| 101 | maletero | cajuela | confirmed | cajuela s f: car luggage compartment. ES: maletero not in DEM | [cajuela](https://dem.colmex.mx/ver/cajuela) |
| 102 | capó | cofre | confirmed | cofre sense 2: front car panel covering the engine. ES: capó not in DEM | [cofre](https://dem.colmex.mx/ver/cofre) |
| 103 | parachoques | defensa | confirmed | defensa sense 3: bumper. ES: parachoques refers to defensa | [defensa](https://dem.colmex.mx/ver/defensa), [parachoques](https://dem.colmex.mx/ver/parachoques) |
| 104 | neumático | llanta | confirmed | llanta s f: tire. ES: neumático sense 2 = llanta | [llanta](https://dem.colmex.mx/ver/llanta), [neumático](https://dem.colmex.mx/ver/neumático) |
| 105 | llanta | rin | confirmed | rin s m: metal rim for a tire | [rin](https://dem.colmex.mx/ver/rin) |
| 106 | pinchazo | ponchadura | confirmed | ponchadura s f: puncture of a tire. ES: pinchazo = needle prick, bullfighting thrust | [ponchadura](https://dem.colmex.mx/ver/ponchadura), [pinchazo](https://dem.colmex.mx/ver/pinchazo) |
| 107 | aparcamiento | estacionamiento | confirmed | estacionamiento s m: parking place. ES: aparcamiento not in DEM | [estacionamiento](https://dem.colmex.mx/ver/estacionamiento) |
| 108 | plaza (de aparcamiento) | cajón / lugar | confirmed (cajón) | cajón sense 7: marked space for parking a car | [cajón](https://dem.colmex.mx/ver/cajón) |
| 109 | carné de conducir | licencia de manejo | partly | licencia s f: example "licencia para manejar"; "de manejo" not seen. carné not in DEM | [licencia](https://dem.colmex.mx/ver/licencia) |
| 110 | matrícula | placa | confirmed | placa sense 2: example "placa de automóvil". ES: matrícula = register list or number | [placa](https://dem.colmex.mx/ver/placa), [matrícula](https://dem.colmex.mx/ver/matrícula) |
| 111 | atasco | tráfico / embotellamiento | confirmed | embotellamiento s m: traffic jam; tráfico s m. ES: atasco no headword (atascar *(Popular)*) | [embotellamiento](https://dem.colmex.mx/ver/embotellamiento), [tráfico](https://dem.colmex.mx/ver/tráfico) |
| 112 | furgoneta | camioneta / van | confirmed (camioneta) | camioneta s f: smaller cargo vehicle, or a larger passenger car. furgoneta not in DEM | [camioneta](https://dem.colmex.mx/ver/camioneta) |
| 113 | todoterreno | camioneta / troca | confirmed; meaning note | troca s f *(N)*: cargo truck (not SUV specifically). todoterreno not in DEM | [troca](https://dem.colmex.mx/ver/troca) |
| 114 | rotonda | glorieta | confirmed; ES **corrected** | glorieta s f: circular traffic plaza. ES: rotonda = circular monument or building, not "yes" | [glorieta](https://dem.colmex.mx/ver/glorieta), [rotonda](https://dem.colmex.mx/ver/rotonda) |
| 115 | acera | banqueta | confirmed; ES-in-MX corrected | banqueta s f; *(Popular)* "soldado de banqueta". ES: acera s f = banqueta, with Mexican examples | [banqueta](https://dem.colmex.mx/ver/banqueta), [acera](https://dem.colmex.mx/ver/acera) |
| 116 | intermitente | direccional | confirmed | direccional s f: turn-signal light. ES: intermitente adj, "luces intermitentes" | [direccional](https://dem.colmex.mx/ver/direccional), [intermitente](https://dem.colmex.mx/ver/intermitente) |
| 117 | salpicadero | tablero | confirmed | tablero sense 3: panel of indicators or controls (tablero de instrumentos). salpicadero not in DEM | [tablero](https://dem.colmex.mx/ver/tablero) |
| 118 | peaje | caseta (de cobro) | confirmed | caseta sense 3: "caseta de cobro". ES: peaje s m = toll payment | [caseta](https://dem.colmex.mx/ver/caseta), [peaje](https://dem.colmex.mx/ver/peaje) |
| 119 | embrague | clutch | confirmed | clutch s m, pronounced clóch. ES: embrague *(Mec)*, defined as clutch | [clutch](https://dem.colmex.mx/ver/clutch), [embrague](https://dem.colmex.mx/ver/embrague) |
| 120 | gasóleo | diésel | confirmed; **spelling** | headword **diesel** (no accent; pronounced dísel), s m. gasóleo not in DEM | [diesel](https://dem.colmex.mx/ver/diesel) |
| 121 | depósito | tanque | confirmed | tanque s m: example "tanque de gasolina" | [tanque](https://dem.colmex.mx/ver/tanque) |
| 122 | alquiler | renta | confirmed | renta s f: payment for temporary use, esp. housing. ES: alquiler s m also present | [renta](https://dem.colmex.mx/ver/renta), [alquiler](https://dem.colmex.mx/ver/alquiler) |
| 123 | paso de cebra | paso peatonal / cebra | partly | paso: example "paso de peatones". cebra only the animal | [paso](https://dem.colmex.mx/ver/paso), [cebra](https://dem.colmex.mx/ver/cebra) |
| 124 | carril bici | ciclovía | confirmed | ciclovía s f: lane for bicycles; ciclopista | [ciclovía](https://dem.colmex.mx/ver/ciclovía) |
| 125 | autoescuela | escuela de manejo | not checked | autoescuela not in DEM; "escuela de manejo" not found under manejo | [manejo](https://dem.colmex.mx/ver/manejo) |

#### Clothing and accessories
| # | Spain | Mexico | Verdict | DEM evidence (paraphrase) | URL |
|---|---|---|---|---|---|
| 126 | camiseta | playera | confirmed; ES note refined | playera s f: cotton T-shirt, short sleeves. ES: camiseta = undershirt **or** sports jersey | [playera](https://dem.colmex.mx/ver/playera), [camiseta](https://dem.colmex.mx/ver/camiseta) |
| 128 | americana | saco | confirmed | saco 1 s m: jacket with lapels. ES: americana no noun headword | [saco](https://dem.colmex.mx/ver/saco) |
| 129 | jersey | suéter | confirmed; ES **corrected** | suéter s m. ES: jersey = knit fabric or stitch, not a sports shirt | [suéter](https://dem.colmex.mx/ver/suéter), [jersey](https://dem.colmex.mx/ver/jersey) |
| 130 | chándal | pants | confirmed | pants s m pl: loose sweatpants; sense 2 tracksuit. chándal not in DEM | [pants](https://dem.colmex.mx/ver/pants) |
| 131 | vaqueros | jeans / mezclilla | confirmed | jeans s m sing y pl; defined with "pantalón vaquero"; mezclilla s f denim | [jeans](https://dem.colmex.mx/ver/jeans), [mezclilla](https://dem.colmex.mx/ver/mezclilla) |
| 132 | bragas | calzones / pantaletas | confirmed | pantaleta s f: woman's calzón. calzón s m, plural ambiguous; several *(Popular)* idioms | [pantaleta](https://dem.colmex.mx/ver/pantaleta), [calzón](https://dem.colmex.mx/ver/calzón) |
| 133 | calzoncillos | calzones / trusa / bóxer | confirmed (bóxer / boxer not in DEM) | trusa s f: short tight underpants for men or boys; calzoncillos s m pl present | [trusa](https://dem.colmex.mx/ver/trusa), [calzoncillos](https://dem.colmex.mx/ver/calzoncillos) |
| 134 | sujetador | brasier | confirmed; ES-in-MX corrected; spelling | headword **brassier** s m (also brasier). ES: sujetador sense 2 = brassier | [brasier](https://dem.colmex.mx/ver/brasier), [sujetador](https://dem.colmex.mx/ver/sujetador) |
| 135 | bañador | traje de baño | not checked | bañador not in DEM; "traje de baño" not seen; calzón has "calzón de baño" | [calzón](https://dem.colmex.mx/ver/calzón) |
| 136 | gafas | lentes | confirmed | lente: "lentes s m pl" = glasses. ES: gafas s f pl = anteojos, esp. sunglasses | [lente](https://dem.colmex.mx/ver/lente), [gafas](https://dem.colmex.mx/ver/gafas) |
| 137 | gafas de sol | lentes oscuros | confirmed (gafas) | gafas defined chiefly as sun-protection glasses | [gafas](https://dem.colmex.mx/ver/gafas) |
| 138 | zapatillas | tenis | confirmed | tenis 2 s m sing y pl: sports shoe. ES: zapatilla = women's high-heeled shoe, ballet or torero shoe | [tenis](https://dem.colmex.mx/ver/tenis), [zapatilla](https://dem.colmex.mx/ver/zapatilla) |
| 139 | zapatillas de casa | pantuflas | confirmed | pantufla s f: soft shoe for wearing at home | [pantufla](https://dem.colmex.mx/ver/pantufla) |
| 140 | cremallera | cierre | confirmed | cierre sense 2: zipper (zíper, cremallera); *(Huast)* fly. ES: cremallera sense 1 = rack gear | [cierre](https://dem.colmex.mx/ver/cierre), [cremallera](https://dem.colmex.mx/ver/cremallera) |
| 141 | bolso | bolsa | confirmed | bolsa sense 2: bolsa (de mano). ES: bolso = bolsa de mano, also present | [bolsa](https://dem.colmex.mx/ver/bolsa), [bolso](https://dem.colmex.mx/ver/bolso) |
| 142 | bolsillo | bolsa | confirmed | bolsa sense 3: cloth pocket sewn into clothes. ES: bolsillo also present | [bolsa](https://dem.colmex.mx/ver/bolsa), [bolsillo](https://dem.colmex.mx/ver/bolsillo) |
| 143 | pijama | pijama / piyama | confirmed gender (f) | pijama **s f** (pronounced piyáma); piyama s f | [pijama](https://dem.colmex.mx/ver/pijama), [piyama](https://dem.colmex.mx/ver/piyama) |
| 144 | pendiente | arete | confirmed; ES **corrected** | arete s m: ear ornament. ES: pendiente sense 2 s m = **arete** | [arete](https://dem.colmex.mx/ver/arete), [pendiente](https://dem.colmex.mx/ver/pendiente) |
| 145 | chubasquero | impermeable | confirmed | impermeable sense 2 s m: waterproof garment. chubasquero not in DEM | [impermeable](https://dem.colmex.mx/ver/impermeable) |
| 146 | pintalabios | labial / lápiz labial | **corrected** | labial only an adjective, in example "lápiz labial"; bare "labial" noun not in DEM. pintalabios not in DEM | [labial](https://dem.colmex.mx/ver/labial) |
| 147 | peto | overol | confirmed | overol s m: one-piece work suit, or pants with large bib. ES: peto = chest protector | [overol](https://dem.colmex.mx/ver/overol), [peto](https://dem.colmex.mx/ver/peto) |
| 148 | gorra | gorra / cachucha | confirmed; **register corrected** | cachucha s f: visor cap, **no register mark** (not colloquial). gorra: *(Popular)* "de gorra" = free | [cachucha](https://dem.colmex.mx/ver/cachucha), [gorra](https://dem.colmex.mx/ver/gorra) |

#### Technology and office
| # | Spain | Mexico | Verdict | DEM evidence (paraphrase) | URL |
|---|---|---|---|---|---|
| 150 | ordenador | computadora | confirmed; ES-in-MX corrected | computadora s f. compu not in DEM. ES: ordenador sense 2 s m = computadora | [computadora](https://dem.colmex.mx/ver/computadora), [ordenador](https://dem.colmex.mx/ver/ordenador) |
| 151 | portátil | laptop | confirmed; gender | laptop **s f**: folding portable computer. portátil adj ("computadoras portátiles") | [laptop](https://dem.colmex.mx/ver/laptop), [portátil](https://dem.colmex.mx/ver/portátil) |
| 152 | móvil | celular | confirmed | celular sense 3 s m: teléfono celular. ES: móvil has no phone sense (moving; mobile sculpture) | [celular](https://dem.colmex.mx/ver/celular), [móvil](https://dem.colmex.mx/ver/móvil) |
| 153 | ratón | mouse | confirmed; ES-in-MX corrected | mouse s m, pronounced máus. ES: ratón sense IV = computer mouse | [mouse](https://dem.colmex.mx/ver/mouse), [ratón](https://dem.colmex.mx/ver/ratón) |
| 154 | bolígrafo | pluma | confirmed | pluma I sense 3: writing cylinder with metal tip. ES: bolígrafo present ("pluma atómica") | [pluma](https://dem.colmex.mx/ver/pluma), [bolígrafo](https://dem.colmex.mx/ver/bolígrafo) |
| 155 | rotulador | plumón | confirmed; ES **corrected** | plumón s m: felt-tip marker. ES: rotulador s m in DEM (thick porous-tip pen), not "no" | [plumón](https://dem.colmex.mx/ver/plumón), [rotulador](https://dem.colmex.mx/ver/rotulador) |
| 156 | típex | corrector | confirmed | corrector sense 4: white liquid or film to hide writing errors | [corrector](https://dem.colmex.mx/ver/corrector) |
| 157 | grapadora | engrapadora | confirmed | engrapadora s f. ES: grapadora not a headword (lookup shows engrapadora) | [engrapadora](https://dem.colmex.mx/ver/engrapadora) |
| 158 | celo | diurex | confirmed; spelling | headword **durex®** s m (also diurex, pronounced diúrecs). ES: celo = zeal or animal heat | [diurex](https://dem.colmex.mx/ver/diurex), [celo](https://dem.colmex.mx/ver/celo) |
| 159 | folio | hoja | confirmed | hoja II 1: sheet of paper. ES: folio = numbered leaf of a book, or legal folio | [hoja](https://dem.colmex.mx/ver/hoja), [folio](https://dem.colmex.mx/ver/folio) |
| 160 | archivador | archivero | confirmed; ES-in-MX corrected | archivero s m: filing cabinet. ES: archivador not in DEM, so "yes" is unsupported | [archivero](https://dem.colmex.mx/ver/archivero) |
| 161 | cascos / auriculares | audífonos | confirmed | audífono s m: earphone device. ES: auricular = phone earpiece; casco = helmet | [audífono](https://dem.colmex.mx/ver/audífono), [auricular](https://dem.colmex.mx/ver/auricular) |
| 162 | altavoz | bocina | confirmed | bocina s f sense 4: loudspeaker (radio, record player). ES: altavoz = cone megaphone | [bocina](https://dem.colmex.mx/ver/bocina), [altavoz](https://dem.colmex.mx/ver/altavoz) |
| 163 | batería | pila / batería | confirmed | pila II: battery cell. ES: batería sense 1: device of one or more cells | [pila](https://dem.colmex.mx/ver/pila), [batería](https://dem.colmex.mx/ver/batería) |
| 164 | enlace | link / liga | confirmed; register | link s m = "liga electrónica"; liga sense 7: electronic or Internet link (native term, not an anglicism) | [link](https://dem.colmex.mx/ver/link), [liga](https://dem.colmex.mx/ver/liga) |
| 165 | vídeo | video | confirmed | video s m (no accent); vídeo no headword | [video](https://dem.colmex.mx/ver/video) |
| 166 | mando | control | confirmed | control sense 5: device for operating a machine | [control](https://dem.colmex.mx/ver/control) |

#### Money and shopping
| # | Spain | Mexico | Verdict | DEM evidence (paraphrase) | URL |
|---|---|---|---|---|---|
| 167 | pasta | lana / feria | confirmed; register | lana II *(Popular)*: money; feria 2 *(Popular)*: loose change, money. ES: pasta has no money sense (*(Popular)* = drug pill) | [lana](https://dem.colmex.mx/ver/lana), [feria](https://dem.colmex.mx/ver/feria), [pasta](https://dem.colmex.mx/ver/pasta) |
| 168 | calderilla | morralla / cambio | confirmed | morralla s f *(Popular)*: loose coins; cambio II 2: small-denomination money | [morralla](https://dem.colmex.mx/ver/morralla), [cambio](https://dem.colmex.mx/ver/cambio) |
| 169 | escaparate | aparador | confirmed; ES-in-MX corrected | aparador sense 1: shop window. ES: escaparate s m present, glossed as aparador | [aparador](https://dem.colmex.mx/ver/aparador), [escaparate](https://dem.colmex.mx/ver/escaparate) |
| 170 | mercadillo | tianguis | confirmed | tianguis s m: weekly street market of temporary stalls. mercadillo not in DEM | [tianguis](https://dem.colmex.mx/ver/tianguis) |
| 171 | ultramarinos | abarrotes | confirmed; ES-in-MX corrected | abarrotes s m pl: groceries, and the shop. ES: ultramarinos s m pl = imported foods and their shop | [abarrotes](https://dem.colmex.mx/ver/abarrotes), [ultramarinos](https://dem.colmex.mx/ver/ultramarinos) |
| 172 | ticket | ticket / nota | confirmed | ticket s m: cash-register slip; nota I 2: paper proving a payment | [ticket](https://dem.colmex.mx/ver/ticket), [nota](https://dem.colmex.mx/ver/nota) |
| 173 | cola | fila | confirmed; ES note refined | fila s f. ES: cola III 1 = people queuing ("hacer cola"); also *(Popular)* buttocks, *(Ofensivo y Popular)* young woman | [fila](https://dem.colmex.mx/ver/fila), [cola](https://dem.colmex.mx/ver/cola) |
| 174 | chollo | ganga | confirmed | ganga s f: thing bought below normal price. chollo not in DEM | [ganga](https://dem.colmex.mx/ver/ganga) |
| 175 | hucha | alcancía | confirmed | alcancía s f: piggy bank. hucha not in DEM | [alcancía](https://dem.colmex.mx/ver/alcancía) |
| 176 | talonario | chequera | ES-in-MX corrected; chequera not in DEM | ES: talonario s m present (example "talonario de cheques"). chequera returned no result | [talonario](https://dem.colmex.mx/ver/talonario) |
| 177 | carro de la compra | carrito | not checked | carrito no headword; carro example "carrito de paletas" only | [carro](https://dem.colmex.mx/ver/carro) |
| 178 | centro comercial | plaza comercial | partly | centro sense: "centro comercial" listed; plaza has no shopping-mall sense in DEM | [centro](https://dem.colmex.mx/ver/centro), [plaza](https://dem.colmex.mx/ver/plaza) |
| 179 | rebajas | ofertas / rebajas | confirmed | oferta sense 3: goods at reduced price; rebaja s f ("Aproveche las rebajas") | [oferta](https://dem.colmex.mx/ver/oferta), [rebaja](https://dem.colmex.mx/ver/rebaja) |
| 180 | estanco | (none) | ES note | estanco s m in DEM: shop selling diverse goods; colonial state monopoly | [estanco](https://dem.colmex.mx/ver/estanco) |

### Inferences
- The Mexican side of the table is reliable. Every row checked has its Mexican word in DEM with the claimed meaning, except a few slang or brand forms (jocho, depa, refri, compu, lavatrastes, chequera) and a few locutions DEM does not list.
- The "ES in MX?" column is the weakest part of nouns.md. DEM is a dictionary of usage in Mexico. When it lists a Spain word with the same sense (nevera, acera, pendiente, sujetador, ordenador, rotulador, escaparate, talonario, gamba, batido, golosina, manta, cola), that word is known in Mexico, even if the Mexican word is more common. In these rows "no" or "rare" should become "known (DEM synonym)". DEM does not give frequency, so it cannot prove a word is rare.
- Some Spain words do not carry over and should be "else". In DEM they have another meaning: grifo, cerilla, bombilla, rotonda, bizcocho, jersey, trastero, frigorífico, mechero, estropajo, percha, dormitorio (dormitory), aperitivo (a drink).

### Gaps
- **Not in DEM or not checked:** lavatrastes, chequera, jocho, depa, refri, compu, carrito, bóxer and calderilla (all returned "no results"). Several locutions were not found: limón amarillo, papas a la francesa, crema de cacahuate, plástico adherente, escuela de manejo, licencia de manejo (DEM has "licencia para manejar"), plaza comercial and paso peatonal. The countertop sense of barra/cubierta (row 71) was not confirmed. Row 42 (cubito), 95 (casa), 45 (piruleta) and 17 (seta) were only partly checked.
- **No second source used:** I did not consult Wiktionary or the Academia Mexicana de la Lengua for the words DEM lacks (chequera, lavatrastes, jocho, depa, refri, compu). For these words, a missing DEM entry is not evidence that the word is unused. DEM itself marks searches with no results as "registered for possible inclusion".
- **Partial reads:** some long entries were read only through keyword search, so a minor sense could have been missed. For example, I did not find a polo-shirt sense of polo or a countertop sense of barra, but a full read might.

## Any corrections to gender or register?

### Takeaway
Most claimed genders match DEM. Four corrections or confirmations matter. **sartén** is "s m o f" in DEM, used with both articles. **pijama/piyama** is feminine. **laptop** is feminine. **lentes** is masculine plural. On register, DEM marks **caballito**, **lonche**, **chela**, **chesco**, **lana**, **feria** and **morralla** as *(Popular)*. **cachucha** has no mark. Several neutral food and household words have vulgar senses or idioms worth flagging: chile, sartén, tortilla, chesco, cola.

### Cited Findings
- **sartén**: DEM gives "s m o f". Its examples use "al sartén" and "un sartén", and it lists both "tener el sartén / la sartén por el mango". The nouns.md row 93 claim (masculine common in Mexico) is confirmed, with feminine also accepted. A separate *(Caló)* sense means female genitals. — [DEM sartén](https://dem.colmex.mx/ver/sartén)
- **pijama** s f (pronounced piyáma) and **piyama** s f: feminine is confirmed (row 143, m→f). — [DEM pijama](https://dem.colmex.mx/ver/pijama); [DEM piyama](https://dem.colmex.mx/ver/piyama)
- **laptop** s f: feminine (row 151 lists "la laptop", correct). — [DEM laptop](https://dem.colmex.mx/ver/laptop)
- **lentes** s m pl (under lente, which is "s m o f" for the optical lens). The f→m flip in rows 136–137 is correct. — [DEM lente](https://dem.colmex.mx/ver/lente)
- **puerco** is tagged "s" (common gender, m/f). **plomero** and **fontanero** are also "s". — [DEM puerco](https://dem.colmex.mx/ver/puerco); [DEM plomero](https://dem.colmex.mx/ver/plomero)
- **tianguis** s m sing y pl; **pants** s m pl; **jeans** s m sing y pl; **abarrotes** s m pl. The number marking matters for flashcard articles. — [tianguis](https://dem.colmex.mx/ver/tianguis); [pants](https://dem.colmex.mx/ver/pants); [jeans](https://dem.colmex.mx/ver/jeans); [abarrotes](https://dem.colmex.mx/ver/abarrotes)
- **calzón** s m: DEM notes that the plural "calzones" can mean one garment or several. **pantaleta** likewise. — [calzón](https://dem.colmex.mx/ver/calzón); [pantaleta](https://dem.colmex.mx/ver/pantaleta)
- **Register to change from neutral to Popular**: caballito (row 49) and lonche (row 48, already marked colloquial). Also confirmed *(Popular)*: chela, chesco, lana and feria (money), morralla. Row 168 already says colloquial. — [caballito](https://dem.colmex.mx/ver/caballito); [lonche](https://dem.colmex.mx/ver/lonche); [chela](https://dem.colmex.mx/ver/chela); [chesco](https://dem.colmex.mx/ver/chesco); [lana](https://dem.colmex.mx/ver/lana); [feria](https://dem.colmex.mx/ver/feria); [morralla](https://dem.colmex.mx/ver/morralla)
- **cachucha**: no register label in DEM, so "colloquial" in row 148 is not supported. — [cachucha](https://dem.colmex.mx/ver/cachucha)
- **troca** is marked *(N)* (north) with the sense "cargo truck", which supports "north" in row 113. **lonche** = torta is marked *(N y OCC)*. **cubo** = cubeta is regional (Chiapas, Guerrero, Veracruz, Coahuila). **fontanero** is "in several regions". — [troca](https://dem.colmex.mx/ver/troca); [lonche](https://dem.colmex.mx/ver/lonche); [cubo](https://dem.colmex.mx/ver/cubo); [fontanero](https://dem.colmex.mx/ver/fontanero)
- **Vulgar or offensive senses on neutral words**:
  - chile IV *(Popular)* = penis, and *(Groser)* idioms
  - tortilla II *(Ofensivo)* idioms about lesbian sex
  - chesco: the "bajarse por los chescos" idiom (oral sex)
  - cola: *(Popular)* buttocks, and *(Ofensivo y Popular)* young woman
  - sartén *(Caló)*
  - grifo *(Popular)* = marijuana user, relevant for the Spain word for tap
  — [chile](https://dem.colmex.mx/ver/chile); [tortilla](https://dem.colmex.mx/ver/tortilla); [chesco](https://dem.colmex.mx/ver/chesco); [cola](https://dem.colmex.mx/ver/cola); [grifo](https://dem.colmex.mx/ver/grifo)
- **Spelling and headword forms DEM uses**: bóiler (also boiler), brassier (also brasier), durex® (also diurex), interfono (also interfón), garage (also garaje), diesel (no accent), video (no accent). — URLs in the tables above

### Inferences
- For the app, the sartén entry can show "el/la sartén". pijama, laptop and computadora should take "la", and lentes "los".
- The *(Popular)* tag in DEM lines up with "colloquial" in nouns.md. Where nouns.md says "neutral" but DEM says *(Popular)* (caballito), the DEM label should win.

### Gaps
- DEM does not mark frequency, so it cannot settle "rare" against "formal" in the ES-in-MX column.
- I did not check the gender of the Colombian words. They were out of scope.
