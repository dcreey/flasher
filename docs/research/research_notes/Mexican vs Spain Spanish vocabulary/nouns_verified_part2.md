# DEM check of Mexican-vs-Spain noun pairs, part 2 (nouns.md rows 181-260 and the anglicisms section)

Method: on 2026-11-07, each word's page at `https://dem.colmex.mx/ver/<word>` was fetched with curl and the entry text extracted. DEM sometimes returns a fuzzy match when it has no headword (for example INE returned *acinesia*, van returned *acta*, carné returned unrelated entries). Those cases are recorded as **not in DEM**. A page saying "Su búsqueda no tuvo resultados" is also **not in DEM**.

Verdicts:
- **confirmed**: DEM has the Mexican word with the claimed meaning.
- **corrected**: DEM shows something that changes the row, such as the Spain word also being used in Mexico, a different gender, a different register, or a different meaning.
- **not in DEM**: no headword.
- **not checked**: no fetch was made.
- **prev. DEM✓**: nouns.md had already verified the row.

Register labels are DEM's own: (Popular), (Groser), (Ofensivo), (Caló), and regional marks (N = north, NO = northwest, OCC = west, Yuc = Yucatán).

nouns.md was not modified.

## Which pairs are confirmed, which are wrong or overstated, and which could not be checked?

### Takeaway
Nearly every Mexican word in rows 181-260 has a DEM entry with the claimed meaning, so the Mexican side is largely confirmed. The common error is on the Spain side. Many Spain words the table marks "rare", "no" or "else" also have plain, unmarked DEM entries with the same meaning. Examples: ducha, piscina, pizarra, asignatura, camarero, ayuntamiento, chupete, cometa, chisme (thing), papel higiénico, despacho, trasto, cachivache. These pairs are overstated. A few rows are wrong in substance:
- tiza and cisterna mean other things in Mexico.
- colega means professional colleague only.
- tira (police) is feminine *la tira*.
- laptop is feminine *la laptop*.

### Cited Findings

#### School and work (rows 181-196)
| # | Spain | Mexico | Verdict | DEM evidence (paraphrase) | URL |
|---|---|---|---|---|---|
| 181 | el instituto | la prepa(ratoria) / la secundaria | confirmed (MX); ES word = else | preparatoria: studies after secundaria, before university. *Prepa* marked Popular. Instituto = an organization or institute, no school sense | [prepa](https://dem.colmex.mx/ver/prepa), [preparatoria](https://dem.colmex.mx/ver/preparatoria), [instituto](https://dem.colmex.mx/ver/instituto) |
| 182 | el colegio | la escuela | confirmed | escuela: establishment where something is taught. Colegio: teaching establishment, also professional association | [escuela](https://dem.colmex.mx/ver/escuela), [colegio](https://dem.colmex.mx/ver/colegio) |
| 183 | la nota | la calificación | confirmed; ES word partly corrected | calificación sense 2: assessment of a student in a subject. *Nota* has no school-grade sense in DEM | [calificación](https://dem.colmex.mx/ver/calificación), [nota](https://dem.colmex.mx/ver/nota) |
| 184 | la asignatura | la materia | confirmed; ES "formal" fits | materia sense 3: subject taught in a school. Asignatura also an unmarked entry | [materia](https://dem.colmex.mx/ver/materia), [asignatura](https://dem.colmex.mx/ver/asignatura) |
| 185 | la pizarra | el pizarrón (m) | confirmed; ES "rare" overstated | pizarrón: board written on with gis. Pizarra sense 2 simply = pizarrón | [pizarrón](https://dem.colmex.mx/ver/pizarrón), [pizarra](https://dem.colmex.mx/ver/pizarra) |
| 186 | la tiza | el gis (m) | confirmed; ES word = **else** | gis: chalk stick for pizarrón. *Andar gis* (Popular) = drunk. Tiza = tailor's or billiard chalk | [gis](https://dem.colmex.mx/ver/gis), [tiza](https://dem.colmex.mx/ver/tiza) |
| 187 | el curro | la chamba (f) | confirmed (Popular); ES word = else | chamba (Popular): work or job. Curro is an adjective here: elegant, or tight-fitting | [chamba](https://dem.colmex.mx/ver/chamba), [curro](https://dem.colmex.mx/ver/curro) |
| 188 | el despacho | la oficina | **corrected** | oficina confirmed. Despacho is ordinary MX: a professional's office (despacho de abogados) | [oficina](https://dem.colmex.mx/ver/oficina), [despacho](https://dem.colmex.mx/ver/despacho) |
| 189 | el becario | el practicante | confirmed; ES word = else | practicante: person practising a profession under a teacher. Becario = scholarship holder only | [practicante](https://dem.colmex.mx/ver/practicante), [becario](https://dem.colmex.mx/ver/becario) |
| 190 | el paro | el desempleo | confirmed | desempleo: lack of jobs. Paro = stoppage or strike; *hacer el paro* (Popular) = to help | [desempleo](https://dem.colmex.mx/ver/desempleo), [paro](https://dem.colmex.mx/ver/paro) |
| 191 | el parado | el desempleado | confirmed (MX) | desempleado: person without a steady job. Parado not checked | [desempleado](https://dem.colmex.mx/ver/desempleado) |
| 192 | el autónomo | el freelance / el independiente | confirmed (freelance); corrected (independiente) | freelance s m y f: works independently. Independiente is an adjective only. Autónomo is an adjective only | [freelance](https://dem.colmex.mx/ver/freelance), [independiente](https://dem.colmex.mx/ver/independiente), [autónomo](https://dem.colmex.mx/ver/autónomo) |
| 193 | la baja (médica) | la incapacidad | confirmed; ES = else | incapacidad sense 3: sick leave, or the social-security document for it. Baja has no sick-leave sense | [incapacidad](https://dem.colmex.mx/ver/incapacidad), [baja](https://dem.colmex.mx/ver/baja) |
| 194 | el carné | la credencial | confirmed; carné not in DEM | credencial: membership or ID document (de estudiante, de elector). Carné returned unrelated hits | [credencial](https://dem.colmex.mx/ver/credencial), [carné](https://dem.colmex.mx/ver/carné) |
| 195 | el DNI | la INE / la credencial de elector | partly confirmed | *credencial de elector* is cited under credencial. INE has no headword (returned acinesia) | [credencial](https://dem.colmex.mx/ver/credencial), [INE](https://dem.colmex.mx/ver/INE) |
| 196 | el aula / la clase | el salón (de clases) | confirmed; ES "yes" correct | salón: large room, e.g. salón de clases. Aula: room where teaching is given | [salón](https://dem.colmex.mx/ver/salón), [aula](https://dem.colmex.mx/ver/aula) |

#### People, family and kinship (rows 197-213)
| # | Spain | Mexico | Verdict | DEM evidence (paraphrase) | URL |
|---|---|---|---|---|---|
| 197 | el crío / el chaval | el chamaco / el chavo | confirmed (Popular); ES corrected | chamaco (Popular): child, teen or son. Crío has an unmarked entry: a baby being raised. Chaval has no entry; nearest is *chavalo* (Popular) | [chamaco](https://dem.colmex.mx/ver/chamaco), [crío](https://dem.colmex.mx/ver/crío), [chaval](https://dem.colmex.mx/ver/chaval) |
| 198 | el chaval / el chico | el morro / la morra | confirmed, gender noted | morra redirects to morro III (NO, Popular): child or young person. Female examples are *morrita* | [morro](https://dem.colmex.mx/ver/morro), [morra](https://dem.colmex.mx/ver/morra) |
| 199 | el chico / la chica | el chavo / la chava | prev. DEM✓ | chavo (Popular): child or young person | [chavo](https://dem.colmex.mx/ver/chavo) |
| 200 | el novio / la novia | mi chavo / mi chava | prev. DEM✓ | chavo sense 2: boyfriend or girlfriend | [chavo](https://dem.colmex.mx/ver/chavo) |
| 201 | el tío / la tía (guy/girl) | el güey / el cuate / la morra | confirmed, **register corrected** | güey: Popular as an address term among young people. **Ofensivo** for "despised stranger" and "fool". Cuate II (Popular): individual, guy | [güey](https://dem.colmex.mx/ver/güey), [cuate](https://dem.colmex.mx/ver/cuate) |
| 202 | el colega | el cuate / el compa / el carnal | confirmed (all Popular); ES word = else | cuate II (Popular): friend; also twin (unmarked). Compa (Popular): short for compadre/compañero. Carnal (Popular): friend. Colega = professional colleague only | [cuate](https://dem.colmex.mx/ver/cuate), [compa](https://dem.colmex.mx/ver/compa), [carnal](https://dem.colmex.mx/ver/carnal), [colega](https://dem.colmex.mx/ver/colega) |
| 203 | el hermano | el carnal | confirmed (Popular) | carnal sense 3 (Popular): brother; *carnala* = sister | [carnal](https://dem.colmex.mx/ver/carnal) |
| 204 | los padres | los papás / los jefes | confirmed (Popular) | papás = father and mother. Jefe sense 2 (Popular): father or mother; *mis jefes* | [papá](https://dem.colmex.mx/ver/papá), [jefe](https://dem.colmex.mx/ver/jefe) |
| 205 | la madre | la mamá / la jefa | confirmed (Popular) | jefa = mother (Popular), as in *jefecita*. Also (Popular) señor/señora as an address term | [jefa](https://dem.colmex.mx/ver/jefa) |
| 206 | la novia | la torta | prev. DEM✓ | torta (Popular): young woman, girlfriend | [torta](https://dem.colmex.mx/ver/torta) |
| 207 | el pijo | el fresa / el chavo fresa | confirmed (Popular), gender corrected | fresa adj m y f (Popular): privileged class; also conservative, rule-abiding. Pijo has no entry | [fresa](https://dem.colmex.mx/ver/fresa), [pijo](https://dem.colmex.mx/ver/pijo) |
| 208 | el guiri | el gringo | confirmed (Popular) | gringo (Popular): from the USA; also a blond foreign speaker. Guiri has no entry | [gringo](https://dem.colmex.mx/ver/gringo), [guiri](https://dem.colmex.mx/ver/guiri) |
| 209 | el gilipollas | el pendejo | prev. DEM✓ (Groser) | — | [pendejo](https://dem.colmex.mx/ver/pendejo) |
| 210 | el camarero | el mesero | confirmed; **ES "rare" overstated** | mesero: restaurant server. Camarero sense 1 = mesero, unmarked; also hotel/ship steward | [mesero](https://dem.colmex.mx/ver/mesero), [camarero](https://dem.colmex.mx/ver/camarero) |
| 211 | el dependiente | el empleado / el vendedor | confirmed (empleado) | empleado: person working for a wage. Vendedor and dependiente not checked | [empleado](https://dem.colmex.mx/ver/empleado) |
| 212 | la asistenta | la muchacha | confirmed, note | muchacha sense 1 = sirvienta, unmarked; *muchacha de entrada por salida* | [muchacha](https://dem.colmex.mx/ver/muchacha) |
| 213 | el madero | el tira / el azul / el poli | **gender corrected** | tira (**Caló**): *la tira* s f = police force; *un/una tira* = an officer. Azul (Popular). Poli s m y f (Popular) | [tira](https://dem.colmex.mx/ver/tira), [azul](https://dem.colmex.mx/ver/azul), [poli](https://dem.colmex.mx/ver/poli) |

#### Body (rows 214-218)
| # | Spain | Mexico | Verdict | DEM evidence (paraphrase) | URL |
|---|---|---|---|---|---|
| 214 | el culo | las pompas / las nalgas / el trasero | confirmed; register of ES word confirmed | pompa II.2 (Popular) = nalga. Nalga unmarked. Trasero (Popular). **Culo is Groser y Ofensivo** in DEM | [pompas](https://dem.colmex.mx/ver/pompas), [nalga](https://dem.colmex.mx/ver/nalga), [trasero](https://dem.colmex.mx/ver/trasero), [culo](https://dem.colmex.mx/ver/culo) |
| 215 | la tripa / la barriga | la panza | confirmed; ES partly corrected | panza sense 4 (Popular): human belly. Barriga (Popular) = abdomen, so it is used in MX. Tripa (Popular) = intestine | [panza](https://dem.colmex.mx/ver/panza), [barriga](https://dem.colmex.mx/ver/barriga), [tripa](https://dem.colmex.mx/ver/tripa) |
| 216 | los mofletes | los cachetes | confirmed | cachete: fleshy part of the face; mejilla. Moflete has no entry | [cachete](https://dem.colmex.mx/ver/cachete), [moflete](https://dem.colmex.mx/ver/moflete) |
| 217 | el grano | el barro / el grano | confirmed (barro) | barro 2: pimple from skin grease. Grano's first senses are seed/grain (pimple sense not seen in the excerpt) | [barro](https://dem.colmex.mx/ver/barro), [grano](https://dem.colmex.mx/ver/grano) |
| 218 | las tetas | las chichis | confirmed, **register corrected** | chichi (Popular): woman's breast. Only Popular, not Groser, so "vulgar" is not DEM-backed. Yuc: bread crumb | [chichi](https://dem.colmex.mx/ver/chichi) |

#### Animals (rows 219-226)
| # | Spain | Mexico | Verdict | DEM evidence (paraphrase) | URL |
|---|---|---|---|---|---|
| 219 | la mariquita | la catarina | confirmed | catarina sense 1 refers to *catarinita*: small spotted beetle | [catarina](https://dem.colmex.mx/ver/catarina), [catarinita](https://dem.colmex.mx/ver/catarinita) |
| 220 | el búho | el tecolote | confirmed; ES "yes" correct | tecolote: Bubo virginianus, the most widespread owl in Mexico. Búho also an entry | [tecolote](https://dem.colmex.mx/ver/tecolote), [búho](https://dem.colmex.mx/ver/búho) |
| 221 | el buitre | el zopilote | confirmed | zopilote: black carrion bird. Buitre also an entry (also figurative) | [zopilote](https://dem.colmex.mx/ver/zopilote), [buitre](https://dem.colmex.mx/ver/buitre) |
| 222 | el mosquito | el mosco / el zancudo | confirmed | mosco: blood-sucking culicid. Zancudo: long-legged mosquito | [mosco](https://dem.colmex.mx/ver/mosco), [zancudo](https://dem.colmex.mx/ver/zancudo) |
| 223 | el cerdo | el puerco / el cochino / el marrano | confirmed | each defined as cerdo, all unmarked. Cerdo is the main entry | [puerco](https://dem.colmex.mx/ver/puerco), [cochino](https://dem.colmex.mx/ver/cochino), [marrano](https://dem.colmex.mx/ver/marrano), [cerdo](https://dem.colmex.mx/ver/cerdo) |
| 224 | el chucho | el perro / el firulais | **corrected** | chucho (Popular) = perro, so it is used in MX. Firuláis appears only as a proper-name example | [chucho](https://dem.colmex.mx/ver/chucho), [firulais](https://dem.colmex.mx/ver/firulais) |
| 225 | el colibrí | el colibrí / el chupamirto | confirmed, region added | chupamirto: colibrí in southern Mexico | [chupamirto](https://dem.colmex.mx/ver/chupamirto), [colibrí](https://dem.colmex.mx/ver/colibrí) |
| 226 | el bicho | el bicho | prev. DEM✓ | — | [bicho](https://dem.colmex.mx/ver/bicho) |

#### Places in a city (rows 227-235)
| # | Spain | Mexico | Verdict | DEM evidence (paraphrase) | URL |
|---|---|---|---|---|---|
| 227 | el barrio | la colonia | confirmed | colonia: urban zone around the city centre (colonia Juárez). Barrio: zone, also poor area | [colonia](https://dem.colmex.mx/ver/colonia), [barrio](https://dem.colmex.mx/ver/barrio) |
| 228 | la piscina | la alberca | confirmed; ES "formal" overstated | alberca: artificial pool for swimming. Piscina is defined simply as "alberca", unmarked | [alberca](https://dem.colmex.mx/ver/alberca), [piscina](https://dem.colmex.mx/ver/piscina) |
| 229 | el ayuntamiento | la presidencia municipal / alcaldía | confirmed; **ES "rare" wrong** | presidencia: its offices (presidencia municipal). Alcaldía = presidencia municipal. Ayuntamiento = municipal government or its seat | [presidencia](https://dem.colmex.mx/ver/presidencia), [alcaldía](https://dem.colmex.mx/ver/alcaldía), [ayuntamiento](https://dem.colmex.mx/ver/ayuntamiento) |
| 230 | el polideportivo | el deportivo | confirmed | deportivo sense 2 (s m): complex where sports are practised | [deportivo](https://dem.colmex.mx/ver/deportivo) |
| 231 | la peluquería | la estética / la peluquería | confirmed, nuance | estética sense 2: salon for hair or skin care. Peluquería: mainly men's haircuts | [estética](https://dem.colmex.mx/ver/estética), [peluquería](https://dem.colmex.mx/ver/peluquería) |
| 232 | el bloque de pisos | el edificio de departamentos / la unidad habitacional | confirmed (unidad) | unidad sense 3: housing complex of several buildings | [unidad](https://dem.colmex.mx/ver/unidad) |
| 233 | el bar / la tasca | la cantina / el bar | confirmed | cantina: drinking place with snacks, dominoes, music | [cantina](https://dem.colmex.mx/ver/cantina) |
| 234 | el quiosco | el puesto | confirmed; ES "yes" correct | puesto: stall to show or sell goods (puestos del mercado). Quiosco/kiosco: bandstand; newspaper stand | [puesto](https://dem.colmex.mx/ver/puesto), [quiosco](https://dem.colmex.mx/ver/quiosco) |
| 235 | el césped | el pasto | confirmed; ES "rare" overstated | pasto: grass plants; a garden with pasto. Césped: smooth well-kept garden grass, unmarked | [pasto](https://dem.colmex.mx/ver/pasto), [césped](https://dem.colmex.mx/ver/césped) |

#### Bathroom (rows 236-249)
| # | Spain | Mexico | Verdict | DEM evidence (paraphrase) | URL |
|---|---|---|---|---|---|
| 236 | el váter | el excusado / el escusado / el inodoro / el baño | confirmed (excusado, inodoro); escusado and váter not in DEM | excusado: bathroom fixture for urinating and defecating. Inodoro sense 2 = baño, excusado. Sanitario sense 3 also = toilet | [excusado](https://dem.colmex.mx/ver/excusado), [inodoro](https://dem.colmex.mx/ver/inodoro), [sanitario](https://dem.colmex.mx/ver/sanitario), [váter](https://dem.colmex.mx/ver/váter) |
| 237 | los aseos | los baños / los sanitarios | confirmed | baño II: room with lavabo and excusado. Sanitario sense 2: bathroom (sanitario de hombres) | [baño](https://dem.colmex.mx/ver/baño), [sanitario](https://dem.colmex.mx/ver/sanitario) |
| 238 | la ducha | la regadera | confirmed; ES "yes" correct | regadera: shower head; baño de regadera. Ducha is defined as "regadera", unmarked | [regadera](https://dem.colmex.mx/ver/regadera), [ducha](https://dem.colmex.mx/ver/ducha) |
| 239 | la bañera | la tina | confirmed; ES corrected | tina: large tub for bathing (baño de tina). Bañera = tina, especially a baby bathtub | [tina](https://dem.colmex.mx/ver/tina), [bañera](https://dem.colmex.mx/ver/bañera) |
| 240 | el lavabo | el lavabo / el lavamanos | confirmed | both entries, both unmarked | [lavabo](https://dem.colmex.mx/ver/lavabo), [lavamanos](https://dem.colmex.mx/ver/lavamanos) |
| 241 | el albornoz | la bata (de baño) | confirmed | bata: loose house garment; bata de baño. Albornoz has no entry | [bata](https://dem.colmex.mx/ver/bata), [albornoz](https://dem.colmex.mx/ver/albornoz) |
| 242 | el papel higiénico | el papel de baño | **corrected** | DEM's sub-entry is *papel higiénico*, unmarked; no "papel de baño" sub-entry seen | [papel](https://dem.colmex.mx/ver/papel) |
| 243 | la cisterna | el tanque | **corrected** | tanque = tank for liquids, war tank, (sense 3) jail; no toilet sense. Cisterna = building's underground water tank | [tanque](https://dem.colmex.mx/ver/tanque), [cisterna](https://dem.colmex.mx/ver/cisterna) |
| 244 | la maquinilla | el rastrillo | confirmed | rastrillo: rake, plus a sense for a blade used for shaving (rasurarse) | [rastrillo](https://dem.colmex.mx/ver/rastrillo) |
| 245 | el bastoncillo | el cotonete | not in DEM | DEM has no cotonete. Hisopo sense 2 = cotton-tipped stick. Wiktionary (es) tags cotonete Argentina/Bolivia/Paraguay/Uruguay, not Mexico | [cotonete](https://dem.colmex.mx/ver/cotonete), [hisopo](https://dem.colmex.mx/ver/hisopo), [Wiktionary](https://es.wiktionary.org/wiki/cotonete) |
| 246 | la compresa | la toalla femenina | **corrected (form)** | DEM gives *toalla sanitaria* / *toalla higiénica*. Compresa = medical compress | [toalla](https://dem.colmex.mx/ver/toalla), [compresa](https://dem.colmex.mx/ver/compresa) |
| 247 | la tirita | la curita | confirmed, **gender corrected** | curita **s m o f**: small antiseptic adhesive bandage. Tirita has no entry | [curita](https://dem.colmex.mx/ver/curita), [tirita](https://dem.colmex.mx/ver/tirita) |
| 248 | el chupete | el chupón | confirmed; **ES "rare" wrong** | chupón: rubber teat for babies. Chupete is defined as "chupón", unmarked | [chupón](https://dem.colmex.mx/ver/chupón), [chupete](https://dem.colmex.mx/ver/chupete) |
| 249 | el biberón | la mamila | confirmed | mamila: baby bottle; also its teat. Biberón also an entry, defined via mamila | [mamila](https://dem.colmex.mx/ver/mamila), [biberón](https://dem.colmex.mx/ver/biberón) |

#### Everyday objects (rows 250-260)
| # | Spain | Mexico | Verdict | DEM evidence (paraphrase) | URL |
|---|---|---|---|---|---|
| 250 | el pañuelo (de papel) | el kleenex / el pañuelo desechable | confirmed | kleenex ® s m: disposable paper tissue. Pañuelo sense 2: pañuelo desechable | [kleenex](https://dem.colmex.mx/ver/kleenex), [pañuelo](https://dem.colmex.mx/ver/pañuelo) |
| 251 | la papelera | el cesto / el bote de basura | confirmed; ES "rare" partly overstated | cesto 2: office waste container (cesto de basura). Bote: can, *bote de basura*. Papelera sense 2: used-paper bin | [cesto](https://dem.colmex.mx/ver/cesto), [bote](https://dem.colmex.mx/ver/bote), [papelera](https://dem.colmex.mx/ver/papelera) |
| 252 | el sello | el timbre / la estampilla | confirmed | timbre 2: proof of paid postage stuck on envelopes. Estampilla: postage stamp. Sello: rubber stamp, no postal sense seen | [timbre](https://dem.colmex.mx/ver/timbre), [estampilla](https://dem.colmex.mx/ver/estampilla), [sello](https://dem.colmex.mx/ver/sello) |
| 253 | la cometa | el papalote | confirmed; **ES "else" wrong** | papalote: kite toy. *Cometa* sense 2 (s f) = papalote; masculine is the comet | [papalote](https://dem.colmex.mx/ver/papalote), [cometa](https://dem.colmex.mx/ver/cometa) |
| 254 | el tobogán | la resbaladilla | confirmed | resbaladilla: playground slide. Tobogán also an unmarked entry | [resbaladilla](https://dem.colmex.mx/ver/resbaladilla), [tobogán](https://dem.colmex.mx/ver/tobogán) |
| 255 | la goma (elástica) | la liga | confirmed | liga sense 6: elastic band for holding things. Goma sense 2: eraser | [liga](https://dem.colmex.mx/ver/liga), [goma](https://dem.colmex.mx/ver/goma) |
| 256 | la cuerda | el mecate / la cuerda | confirmed, register corrected | mecate: ixtle-fiber rope, with no rural or colloquial mark. *A todo mecate* (Popular) | [mecate](https://dem.colmex.mx/ver/mecate), [cuerda](https://dem.colmex.mx/ver/cuerda) |
| 257 | el pegamento | el pegamento / el resistol | confirmed | resistol ®: thick white liquid glue. Pegamento unmarked | [resistol](https://dem.colmex.mx/ver/resistol), [pegamento](https://dem.colmex.mx/ver/pegamento) |
| 258 | el trasto / el cachivache | el tiliche / el triques | tiliche confirmed (Popular); triques not in DEM in this sense; ES corrected | tiliche (Popular): worn, low-value belonging. Trique = Oaxaca ethnic group. Trasto and cachivache (Popular) both used | [tiliche](https://dem.colmex.mx/ver/tiliche), [triques](https://dem.colmex.mx/ver/triques), [cachivache](https://dem.colmex.mx/ver/cachivache), [trasto](https://dem.colmex.mx/ver/trasto) |
| 259 | el chisme (gadget) | el chisme (gossip only) | **corrected** | chisme 1 = gossip; chisme 2 = small unimportant thing. Both senses exist in MX | [chisme](https://dem.colmex.mx/ver/chisme) |
| 260 | el bote (jar, boat) | el bote (can, bin; jail) | confirmed | bote: rigid container, usually a can (bote de basura). (Popular) jail | [bote](https://dem.colmex.mx/ver/bote) |

#### Anglicisms section: Mexico-side words
| Spain | Mexico | Verdict | DEM evidence (paraphrase) | URL |
|---|---|---|---|---|
| armario | clóset | confirmed | built-in wardrobe; *salir del clóset* (Popular) | [clóset](https://dem.colmex.mx/ver/clóset) |
| calentador/termo | boiler | confirmed | bóiler (also boiler) s m: water heater | [boiler](https://dem.colmex.mx/ver/boiler) |
| ratón | mouse | confirmed | s m, pronounced máus: computer mouse | [mouse](https://dem.colmex.mx/ver/mouse) |
| portátil | laptop | confirmed, **gender: feminine** | *laptop s f*: portable computer with a folding screen | [laptop](https://dem.colmex.mx/ver/laptop) |
| chándal | pants | confirmed | s m pl: loose exercise trousers; also tracksuit. Chándal not in DEM | [pants](https://dem.colmex.mx/ver/pants), [chándal](https://dem.colmex.mx/ver/chándal) |
| vaqueros | jeans | confirmed | s m: trousers, usually blue denim | [jeans](https://dem.colmex.mx/ver/jeans) |
| calzoncillos | bóxer | not in DEM | no result | [bóxer](https://dem.colmex.mx/ver/bóxer) |
| sujetador | brasier/bra | confirmed (brasier) | *brassier* (also brasier) s m: bra | [brasier](https://dem.colmex.mx/ver/brasier) |
| peto | overol | confirmed | one-piece work suit, or trousers with a bib | [overol](https://dem.colmex.mx/ver/overol) |
| jersey | suéter | confirmed | knitted garment covering arms and trunk | [suéter](https://dem.colmex.mx/ver/suéter) |
| embrague | clutch | confirmed | s m, pronounced clóch: engaging/disengaging device | [clutch](https://dem.colmex.mx/ver/clutch) |
| camioneta | troca | confirmed, **meaning narrowed** | troca s f (N): cargo truck | [troca](https://dem.colmex.mx/ver/troca) |
| merienda/bocadillo | lonche | confirmed, regional | (Popular) lunch; (N y OCC) torta or sandwich | [lonche](https://dem.colmex.mx/ver/lonche) |
| enlace | link | confirmed | s m: electronic link (liga electrónica) | [link](https://dem.colmex.mx/ver/link) |
| perrito caliente | hot dog | confirmed | sausage in a long bun | [hot dog](https://dem.colmex.mx/ver/hot%20dog) |
| furgoneta | van | not in DEM | returned unrelated *acta* | [van](https://dem.colmex.mx/ver/van) |
| pantalón corto | short | confirmed | s m: shorts; also baseball shortstop | [short](https://dem.colmex.mx/ver/short) |
| nevera portátil | cooler / hielera | hielera confirmed; cooler not in DEM | hielera: insulated box with ice for food and drink | [hielera](https://dem.colmex.mx/ver/hielera), [cooler](https://dem.colmex.mx/ver/cooler) |
| comprobar | checar (verb) | confirmed | to check validity or condition against a norm | [checar](https://dem.colmex.mx/ver/checar) |
| camión articulado | tráiler | confirmed | large articulated truck; also camper; film trailer | [tráiler](https://dem.colmex.mx/ver/tráiler) |
| (parquear) | estacionar | not checked | — | — |

#### Anglicisms section: Spain-side words (does DEM have them?)
| Spain | Mexico | Verdict | DEM evidence (paraphrase) | URL |
|---|---|---|---|---|
| el parking | estacionamiento | confirmed (MX); parking not in DEM | estacionamiento: public or private place to park vehicles | [estacionamiento](https://dem.colmex.mx/ver/estacionamiento), [parking](https://dem.colmex.mx/ver/parking) |
| el bacon | tocino | confirmed; bacon not in DEM | tocino: cured, smoked pork belly in thin slices | [tocino](https://dem.colmex.mx/ver/tocino) |
| el footing | — | not in DEM | no result | [footing](https://dem.colmex.mx/ver/footing) |
| el tupper | topper | **corrected** | DEM headword is *tupper* (pronounced tóper, also spelled so). "topper" not found | [tupper](https://dem.colmex.mx/ver/tupper) |
| el camping | campamento | **corrected** | *camping* is in DEM too (the pastime). Campamento: camp facilities | [camping](https://dem.colmex.mx/ver/camping), [campamento](https://dem.colmex.mx/ver/campamento) |
| el pádel | — | not in DEM | no result | [pádel](https://dem.colmex.mx/ver/pádel) |
| el friki | ñoño / nerd | partly confirmed | nerd s m y f (Popular): studious, obsessive. Ñoño adj: cursi, childish, over-dutiful. Friki not in DEM | [nerd](https://dem.colmex.mx/ver/nerd), [ñoño](https://dem.colmex.mx/ver/ñoño), [friki](https://dem.colmex.mx/ver/friki) |
| el puenting | bungee | not in DEM | no result | [puenting](https://dem.colmex.mx/ver/puenting) |
| el smoking | esmoquin | **corrected** | DEM headword is *smoking* (pronounced esmóquin); esmoquin redirects to it | [smoking](https://dem.colmex.mx/ver/smoking) |
| el spot | comercial | **corrected** | *spot* is in DEM: short TV, radio or internet ad. Comercial noun sense not seen in excerpt | [spot](https://dem.colmex.mx/ver/spot) |
| el ticket | ticket | confirmed (both) | ticket: boleto, or cash-register receipt | [ticket](https://dem.colmex.mx/ver/ticket) |

### Inferences
- The Mexican words are almost all real and DEM-documented. The weak spot is the "ES in MX?" column. DEM defines many Spain words by simple cross-reference (ducha = regadera, piscina = alberca, chupete = chupón, pizarra = pizarrón, camarero = mesero, cometa = papalote), with no regional or register mark. That suggests they are known and used in Mexico, though less common. In those rows, "rare/no" should be read as "less common", not "unknown". DEM does not give frequencies, so this is an inference.
- Spain-side anglicisms (camping, smoking, spot, tupper, ticket) mostly also exist in Mexico per DEM. So the "Spain uses an anglicism, Mexico uses a native word" list is largely overstated.

### Gaps
- Not in DEM, and not corroborated: INE (as a noun for the ID card), firulais (as a common noun for "mutt"), triques ("junk"), escusado (spelling), bóxer, van, cooler. Wiktionary raw fetches for INE, firulais and triques returned Wikimedia errors.
- Cotonete: not in DEM. Spanish Wiktionary labels it for Argentina, Bolivia, Paraguay and Uruguay, not Mexico. Its Mexican use stays unverified, and that Wiktionary page does not support it.
- Not checked: parado, vendedor, dependiente, edificio de departamentos, papel de baño as a phrase (the *papel* entry showed only *papel higiénico* in the part searched), grano's pimple sense, comercial as a noun, parquear/estacionar.
- DEM gives no frequency data. "Rare" vs "less common" for Spain words cannot be settled from DEM.

## Any corrections to gender or register, especially for people words and anything potentially offensive?

### Takeaway
Most people words are DEM **(Popular)**, not neutral or "colloquial": chavo, chamaco, morro, cuate, compa, carnal, jefe/jefa, fresa, gringo, poli, azul. Words that need an explicit **offensive** flag in the app:
- **naco**: Popular y Ofensivo; its first sense is a slur for Indigenous people.
- **güey**: Ofensivo in the "despised person" and "fool" senses.
- **buey**: Groser.
- **culo**: Groser y Ofensivo.
- **pendejo**: Groser.

Gender fixes:
- *la tira* (police force); *un/una tira* for an officer.
- *la laptop*.
- *el/la curita*.
- fresa and poli are both m and f.
- morro's female form in DEM examples is *morrita*.

### Cited Findings
- **chavo**: (Popular) child or young person; also boyfriend or girlfriend. *Chavo fresa* = a well-off young man. Previously verified. — [DEM chavo](https://dem.colmex.mx/ver/chavo)
- **morro / morra**: "morra" redirects to *morro*. Sense III is marked (NO) (Popular), s y adj: child or young person. The female examples use *morrita*. "Morra" for "girl" is not shown as a separate form, but follows from the s y adj marking. — [DEM morro](https://dem.colmex.mx/ver/morra)
- **cuate**: sense I is unmarked: twin, or paired (torres cuatas). Sense II is (Popular): friend, and also "individual, guy". — [DEM cuate](https://dem.colmex.mx/ver/cuate)
- **jefe / jefa**: sense 2 (Popular) = father or mother (*mis jefes*, *jefecita*). Sense 3 (Popular) = polite address "señor/señora" used by vendors and attendants. — [DEM jefe](https://dem.colmex.mx/ver/jefa)
- **güero**: no register mark. Means blond, and is also a vendor's courteous address ("¡Pásele güero!"). (Rural) = rotten or hollow egg or fruit. — [DEM güero](https://dem.colmex.mx/ver/güero)
- **naco**: marked **(Popular y Ofensivo)**. Senses: (1) Indigenous person, (2) ignorant, uneducated, (3) tacky. This is an ethnic slur, not merely "tacky". — [DEM naco](https://dem.colmex.mx/ver/naco)
- **fresa**: adj m y f (Popular). Means privileged class, or conservative and rule-abiding. — [DEM fresa](https://dem.colmex.mx/ver/fresa)
- **güey**: (Popular) as a variant of buey, and as a young people's attention-keeping address term. Marked **(Ofensivo)** for "despised unknown person" and "fool". — [DEM güey](https://dem.colmex.mx/ver/güey)
- **buey**: (Groser) = stupid ("No te hagas buey"), and (Groser) = cuckold. — [DEM buey](https://dem.colmex.mx/ver/buey)
- **culo**: (Groser y Ofensivo). Any table that calls it only "more vulgar in MX" understates this. — [DEM culo](https://dem.colmex.mx/ver/culo)
- **chichi**: (Popular) only, so "colloquial / vulgar" overstates it per DEM. — [DEM chichi](https://dem.colmex.mx/ver/chichi)
- **tira**: tira 2 is marked (Caló). As s f it means the police force (*la tira*). As s m y f it means a police officer (*los tiras*). The table's "el tira" alone is incomplete. — [DEM tira](https://dem.colmex.mx/ver/tira)
- **gringo**: (Popular) = from the USA; also a blond foreign-language speaker; *a la gringa* = splitting the bill. — [DEM gringo](https://dem.colmex.mx/ver/gringo)
- **muchacha**: sense 1 = maid (sirvienta), unmarked. The ordinary "girl" sense is under *muchacho*. — [DEM muchacha](https://dem.colmex.mx/ver/muchacha)
- **carnal**: (Popular) brother, *carnala* = sister; also (Popular) friend. — [DEM carnal](https://dem.colmex.mx/ver/carnal)
- **chamaco**: (Popular) child, adolescent or son; *chamaca* for a girl. — [DEM chamaco](https://dem.colmex.mx/ver/chamaco)
- **chucho**: (Popular) = dog, so the Spain word does exist in Mexico. — [DEM chucho](https://dem.colmex.mx/ver/chucho)
- **chupamirto**: marked "in the south of Mexico", which is more specific than the table's "regional". — [DEM chupamirto](https://dem.colmex.mx/ver/chupamirto)
- **troca**: (N), and means cargo truck rather than SUV. — [DEM troca](https://dem.colmex.mx/ver/troca)
- **lonche**: (Popular) lunch; (N y OCC) torta. — [DEM lonche](https://dem.colmex.mx/ver/lonche)
- **mecate**: no rural or colloquial mark. — [DEM mecate](https://dem.colmex.mx/ver/mecate)
- **laptop**: s f. — [DEM laptop](https://dem.colmex.mx/ver/laptop)
- **curita**: s m o f. — [DEM curita](https://dem.colmex.mx/ver/curita)

### Inferences
- In the Register column, "colloquial" maps to DEM's (Popular) for nearly all of the people words. The app could adopt DEM's label directly.
- naco and güey (Ofensivo senses) deserve a "careful" warning alongside pendejo, coger and chaqueta. Güey's friendly address-term use is DEM-documented, but its insult senses are explicitly Ofensivo.

### Gaps
- DEM does not rank how offensive a word is, and does not mark how common each sense is (for example, how often güey is friendly versus insulting).
- No separate DEM headword for "morra" or "chava". Their forms are inferred from the s y adj marking and the examples.
