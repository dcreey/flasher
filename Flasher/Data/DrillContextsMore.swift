import Foundation

/// More context sentences, added so every kind of verb has about twenty that fit it closely in every pool
/// (see `DrillContexts.pick`). They follow the same tense rules as the first fifty in each pool.
extension DrillContexts {
    static let moreImperfectScenes = """
    Olía a café por toda la casa.|Se preparaba la cena en la cocina.|Había olor a pan recién hecho.|El mercado estaba lleno de frutas.|La comida se enfriaba en la mesa.|\
    Era la hora de la cena.|El café estaba recién hecho.|Había olor a comida por todas partes.|Ya servían la comida en el comedor.|En el mercado olía a especias.|\
    La cena estaba casi lista.|Había una fila larga en el mercado.|La comida olía muy bien.|El café humeaba en las tazas.|Se sentía el olor del pan tostado.|\
    Era la hora del café.|El mercado abría muy temprano.|En esa casa se cenaba tarde.|Había mucho trabajo en la oficina.|Era lunes y todos tenían prisa.|\
    La reunión estaba por empezar.|Todo el mundo estaba ocupado.|Había muchas cosas por hacer.|Era martes por la mañana.|El horario era muy apretado.|\
    Había muchos pendientes.|Era un viernes lleno de trabajo.|Eran días de examen.|El trabajo se acumulaba.|Había prisa por terminar.|\
    La oficina estaba llena de trabajo.|Era un lunes muy ocupado.|Había una reunión importante ese día.|El día estaba lleno de pendientes.|Había mucho que hacer en la oficina.|\
    Era un martes de mucho trabajo.|El horario de trabajo era largo.|Había mucho tráfico en el centro.|Había poca gente en la plaza.|El parque estaba lleno de niños.|\
    Afuera hacía mucho viento.|La ciudad se movía despacio.|Las calles estaban mojadas.|El centro estaba lleno de tráfico.|Había mucha gente en la fiesta.|\
    El ambiente era alegre.|Se oía música por todas partes.|Había mucho ruido en la plaza.|Todos esperaban en el café.|El ambiente estaba animado.|\
    La fiesta estaba en su mejor momento.|Había gente conversando en la plaza.|La música sonaba a todo volumen.|El café estaba lleno de gente.|El ambiente en la sala era tenso.|\
    Había mucha gente esperando afuera.|Había ruido de conversaciones por todos lados.|Era un día normal.|Reinaba el silencio en la casa.|La casa estaba muy tranquila.|\
    Había calma en toda la ciudad.|La oficina estaba vacía.|Era una noche cualquiera.|Todo estaba normal y tranquilo.|Había un silencio total.|\
    La calle estaba tranquila.|Era una mañana tranquila y normal.|El pueblo estaba en calma.|La puerta estaba cerrada.|Las luces estaban encendidas.|\
    El teléfono estaba apagado.|La casa estaba limpia.|La tienda estaba cerrada.|El lugar estaba muy ordenado.|Las luces de la calle estaban apagadas.|\
    La puerta de la casa estaba abierta.|El teléfono sonaba sin parar.|La ciudad estaba iluminada.|Las calles estaban limpias.|El lugar estaba a oscuras.
    """

    static let morePresentStates = """
    Es la hora de la cena.|El café está listo.|Hay mucha comida en la mesa.|La comida está caliente.|Huele a café.|\
    El mercado está abierto.|Hoy hay comida para todos.|La cena es a las nueve.|Ya es hora de la comida.|Hay olor a pan en la cocina.|\
    El mercado está lleno hoy.|La comida está casi lista.|Es temporada de mangos en el mercado.|El café está muy caliente.|Hay una cena esta noche.|\
    Es hora de ir al mercado.|Hoy toca cena en casa.|La comida es muy buena aquí.|Hay café en la cocina.|Hay una reunión a las diez.|\
    Hoy hay mucho que hacer.|Estamos en época de trabajo duro.|Hay muchos pendientes en la oficina.|Es lunes y hay mucho trabajo.|El horario de hoy es largo.|\
    Hay examen el martes.|Es viernes y hay prisa.|Hay mucho trabajo acumulado.|Los pendientes se acumulan.|Hay mucho tráfico en el centro.|\
    Afuera hace viento.|La calle está llena de coches.|El parque está abierto hoy.|La plaza está llena.|Hay obras en el centro.|\
    Es una mañana soleada.|La ciudad está tranquila hoy.|El centro está cerrado al tráfico.|Las calles están mojadas.|El parque está vacío.|\
    La ciudad está llena de turistas.|Hay desfile en el centro.|El tráfico está terrible hoy.|Afuera hay mucho ruido.|La plaza está en obras.|\
    Hoy el centro está lleno.|La calle principal está cerrada.|Hay un mercado en la plaza.|Hay mucha gente en la fiesta.|El ambiente es muy bueno.|\
    Hay música en la plaza.|Hay mucho ruido en el café.|El ambiente está tenso.|La fiesta es esta noche.|Hay música en vivo hoy.|\
    El café está lleno de gente.|La gente está contenta.|Hay ruido en toda la casa.|El ambiente es alegre.|Hay fiesta en el barrio.|\
    La plaza está llena de gente.|La música suena fuerte.|Hay gente esperando afuera.|El ambiente en la oficina es tenso.|Hay mucho ruido afuera.|\
    La fiesta empieza a las nueve.|Es un día normal.|Hay calma en la ciudad.|Todo está normal.|Es un día cualquiera.|\
    La calle está tranquila.|Hay silencio en la casa.|La oficina está vacía.|Hoy el barrio está en calma.|Es una tarde tranquila.|\
    Todo está en silencio.|La plaza está vacía.|Es una noche tranquila.|El día está normal.|Hay mucha calma hoy.|\
    La sala está vacía.|Es una mañana cualquiera.|Todo parece normal.|El barrio está muy tranquilo.|La puerta está abierta.|\
    Las luces están apagadas.|El teléfono está cargado.|La casa está lista.|La tienda está cerrada.|El lugar está limpio.|\
    La ciudad está iluminada.|El mercado está cerrado.|La puerta está cerrada con llave.|Las luces están encendidas.|El teléfono está en la mesa.|\
    La casa está en orden.|La tienda está abierta hoy.|El lugar es muy bonito.|La calle está limpia.|El teléfono no tiene batería.|\
    La casa es grande.|La ciudad es muy grande.|La puerta de la tienda está rota.
    """

    static let morePastCloses = """
    Luego sirvieron la cena.|Después tomaron un café.|La comida terminó temprano.|Todos probaron la comida.|Al final no hubo cena.|\
    Después compraron comida en el mercado.|La cena fue muy buena.|El café se enfrió.|Luego llegó la comida.|Todos cenaron juntos.|\
    Nadie quiso más café.|Después fueron al mercado.|La comida se acabó pronto.|Hubo café para todos.|Esa noche la cena fue tarde.|\
    Al rato llegó el café.|Al final el mercado cerró.|La cena salió bien.|El olor a café llenó la casa.|Después hubo una reunión.|\
    El trabajo terminó tarde.|Fue un lunes de mucho trabajo.|Todo el trabajo quedó listo.|Luego tuvieron que hacer otra cosa.|Los pendientes quedaron para el martes.|\
    Hubo prisa al final.|El examen fue el viernes.|Terminó el horario de trabajo.|Después siguió el trabajo.|Fue un día de mucho trabajo.|\
    La reunión duró dos horas.|Todo quedó listo para el viernes.|Después hubo mucho que hacer.|El martes empezó el trabajo nuevo.|Fue un lunes muy ocupado.|\
    Se acabó el trabajo del día.|Luego empezó la reunión.|Los pendientes se resolvieron.|Luego salieron a la calle.|Después fueron al parque.|\
    Llegaron al centro.|Cruzaron la plaza.|Hubo mucho tráfico.|Salieron de la ciudad.|Después caminaron por la calle.|\
    Volvieron al centro.|Luego cruzaron el parque.|El tráfico se detuvo.|Al rato entraron en la ciudad.|Pasaron por la plaza.|\
    Después salieron afuera.|Luego recorrieron el centro.|Hubo mucho tráfico en la calle.|La calle quedó cerrada.|Después cruzaron la ciudad.|\
    Fue un paseo por el parque.|Todos salieron a la plaza.|Se fueron por la calle.|Llegó mucha gente.|El ambiente se puso tenso.|\
    La fiesta terminó tarde.|Empezó la música.|Hubo mucho ruido.|La gente aplaudió.|Luego sonó la música.|\
    La fiesta fue un éxito.|Todo el café se llenó de gente.|La gente se fue de la plaza.|Se armó un ambiente alegre.|Hubo música toda la noche.|\
    Se oyó ruido afuera.|Toda la gente se divirtió.|Fue una fiesta muy animada.|El ambiente mejoró después.|La gente salió del café.|\
    Llegó más gente a la plaza.|Hubo ruido en toda la casa.|La música duró hasta tarde.|Después volvió la calma.|Todo quedó tranquilo.|\
    Hubo un silencio largo.|Pronto todo volvió a ser normal.|La sala quedó vacía.|Fue un día cualquiera.|Luego todo quedó en calma.|\
    La calle quedó vacía.|Se hizo un silencio total.|Después la noche fue tranquila.|Todo volvió a la normalidad.|Al final reinó la calma.|\
    La casa quedó en silencio.|Fue una noche tranquila.|Después todo siguió normal.|La plaza quedó vacía.|Después todo fue distinto.|\
    Todo cambió desde entonces.|Nada volvió a ser igual.|Fue una etapa diferente.|Después ya no fue lo mismo.|Todo cambió de golpe.|\
    Fue otra época.|Después las cosas fueron diferentes.|Antes de eso nada cambió.|Desde entonces ya no fue igual.|Todo cambió esa semana.|\
    Fue una historia diferente.|Ese día cambió todo.|Todo fue diferente después.|Después fue otra cosa.|Esa noche todo cambió.|\
    La puerta se cerró.|Las luces se apagaron.|El teléfono sonó.|La tienda cerró temprano.|El lugar se llenó.|\
    Se fue la luz en toda la ciudad.|La puerta se abrió sola.|Las luces parpadearon.|El teléfono dejó de sonar.|La casa se quedó a oscuras.|\
    La tienda abrió tarde.|El mercado cerró pronto.|La puerta chirrió.|Las luces se encendieron.|El lugar quedó limpio.|\
    El teléfono se cayó al suelo.|La ciudad se quedó sin luz.
    """

    static let moreFutureCloses = """
    Después cenaremos juntos.|Mañana habrá comida para todos.|Luego tomaremos un café.|La cena será a las nueve.|Sería una buena comida.|\
    Pronto servirán la cena.|Mañana iremos al mercado.|El café estará listo pronto.|La comida estará lista en un rato.|Habrá café para todos.|\
    En el mercado habrá más.|Después habrá una cena.|Sería una cena perfecta.|Mañana compraremos comida.|La comida llegará pronto.|\
    Esta noche cenaremos tarde.|Habrá comida de sobra.|Luego iremos por un café.|El mercado abrirá mañana.|Más tarde habrá cena.|\
    Mañana habrá mucho trabajo.|La reunión será el lunes.|Habrá mucho que hacer.|El trabajo quedará listo pronto.|Los pendientes se resolverán el martes.|\
    Sería bueno terminar el trabajo.|El viernes habrá examen.|Pronto habrá una reunión.|El horario cambiará pronto.|Estaremos muy ocupados.|\
    Tendremos mucho trabajo el lunes.|El trabajo terminará el viernes.|Habrá prisa al final.|Sería un buen horario.|El martes habrá reunión.|\
    Mañana tendremos más trabajo.|Los pendientes quedarán listos.|Habrá tiempo para hacer todo.|Sería un trabajo largo.|Dentro de poco estaremos ocupados.|\
    Pronto saldremos a la calle.|Mañana iremos al parque.|Habrá tráfico en el centro.|Cruzaremos la ciudad.|Llegaremos al centro pronto.|\
    La plaza estará llena.|Sería un buen paseo por el parque.|Saldremos de la ciudad mañana.|Habrá mucho tráfico mañana.|Pasaremos por la plaza.|\
    Después caminaremos por la calle.|El parque estará abierto.|La calle estará cerrada.|El centro estará lleno.|Pronto volveremos a la ciudad.|\
    Mañana habrá viento afuera.|Iremos al centro más tarde.|Habrá menos tráfico después.|Saldremos afuera en un rato.|Mañana la ciudad estará tranquila.|\
    Habrá mucha gente en la fiesta.|El ambiente será alegre.|Habrá música toda la noche.|Habrá mucho ruido.|Todos nos esperarán en el café.|\
    La fiesta será muy animada.|Pronto llegará más gente.|La plaza se llenará de gente.|El ambiente mejorará.|Habrá música en la plaza.|\
    La fiesta empezará a las nueve.|Sería una fiesta increíble.|El café se llenará de gente.|Habrá ruido hasta tarde.|Toda la gente estará contenta.|\
    Sería bueno tener música.|El ambiente estará tenso.|La fiesta terminará tarde.|Habrá gente de todas partes.|Más tarde habrá música en vivo.|\
    Pronto volverá la calma.|Todo estará tranquilo.|Habrá silencio después.|Todo será normal otra vez.|Mañana será un día normal.|\
    La casa estará vacía.|Sería un día cualquiera.|Pronto reinará la calma.|La noche será tranquila.|Después habrá silencio.|\
    Todo quedará en calma.|La calle estará tranquila.|Será una semana normal.|Habrá calma en unos días.|La oficina estará vacía.|\
    Después todo será tranquilo.|Sería un día tranquilo.|Todo volverá a la normalidad.|Habrá un silencio largo.|Todo será distinto.|\
    Nada será igual.|Las cosas cambiarán pronto.|Ya no será lo mismo.|Sería otra historia.|Todo cambiaría.|\
    Será una etapa diferente.|Todo será mejor que antes.|Ya no habrá problema.|Pronto será otra época.|Cambiará todo el plan.|\
    Eso sería diferente.|Será igual que antes.|Todo cambiará mañana.|Sería muy distinto.|Será otra cosa.|\
    Ya no será necesario.|La puerta estará abierta.|Las luces estarán encendidas.|El teléfono sonará pronto.|La casa estará lista.|\
    La tienda abrirá mañana.|El lugar estará limpio.|La ciudad estará iluminada.|El mercado abrirá temprano.|La puerta se abrirá pronto.|\
    Las luces se encenderán.|El teléfono estará cargado.|La casa quedaría perfecta.|La tienda estaría cerrada.|El lugar sería ideal.|\
    La calle estará limpia.|El teléfono funcionará.|La casa será nuestra.|La ciudad crecerá.|Las luces estarían listas.|\
    La puerta estará lista mañana.
    """

    static let moreNowContrasts = """
    Hoy la comida es distinta.|Ahora el café es más caro.|Hoy ya no hay cena en casa.|Ahora la comida es más cara.|Hoy el mercado está vacío.|\
    Ahora solo hay café.|Hoy se cena más temprano.|Ahora el mercado es más grande.|Hoy la comida llega a casa.|Ahora ya nadie cena junto.|\
    Hoy el café es otra cosa.|Ahora hay más comida.|Hoy el mercado está en otro lugar.|Ahora la cena es rápida.|Hoy ya no hay mercado.|\
    Ahora el café es mejor.|Hoy hay comida de todo el mundo.|Ahora cada quien cena por su lado.|Hoy el mercado cierra temprano.|Ahora la comida cuesta más.|\
    Hoy hay más trabajo.|Ahora el horario es otro.|Hoy el trabajo es más pesado.|Ahora hay muchos pendientes.|Hoy la reunión es por internet.|\
    Ahora hay que hacer más.|Hoy el lunes es más pesado.|Ahora el trabajo es distinto.|Hoy tienen mucha prisa.|Ahora hay más pendientes.|\
    Hoy todos están ocupados.|Ahora el horario es más largo.|Hoy hay menos trabajo.|Ahora el viernes es diferente.|Hoy el trabajo es por teléfono.|\
    Ahora hay una reunión cada martes.|Hoy es más difícil hacer las cosas.|Ahora los pendientes son otros.|Hoy hay más tráfico.|Ahora la ciudad es más grande.|\
    Hoy el centro está lleno de coches.|Ahora la calle es peatonal.|Hoy el parque está cerrado.|Ahora la plaza es otra.|Hoy el tráfico es terrible.|\
    Ahora la ciudad es más ruidosa.|Hoy el centro es distinto.|Ahora el parque es más bonito.|Hoy hay menos tráfico en la calle.|Ahora la plaza está llena de puestos.|\
    Hoy la ciudad ya no es la misma.|Ahora hay un parque nuevo.|Hoy el centro está lleno de gente.|Ahora el viento es más fuerte.|Hoy todo el tráfico pasa por otra calle.|\
    Ahora la calle está cerrada.|Hoy el centro está lejos.|Ahora hay más ciudad.|Ahora la gente habla más.|Hoy el ambiente es distinto.|\
    Ahora ya no hay fiesta.|Hoy la música es otra.|Ahora el café está lleno de gente.|Hoy el ambiente es más tenso.|Ahora hay más gente.|\
    Hoy la plaza es otra cosa.|Ahora la fiesta es en otro lugar.|Hoy la gente ya no habla igual.|Ahora el ruido es constante.|Hoy la música suena distinta.|\
    Ahora el ambiente es mejor.|Hoy hay más fiestas.|Ahora la gente es otra.|Hoy el ruido no para.|Ahora el café es un lugar de reunión.|\
    Hoy el ambiente ya no es igual.|Hoy todo está tranquilo.|Ahora hay calma.|Hoy ya no hay silencio.|Ahora todo es normal.|\
    Hoy la casa está vacía.|Ahora es un día cualquiera.|Hoy el barrio está tranquilo.|Ahora la calle está vacía.|Hoy hay más calma.|\
    Ahora todo es tranquilo.|Hoy ya es un día normal.|Ahora reina la calma.|Hoy el silencio es total.|Ahora la sala está vacía.|\
    Hoy todo parece normal.|Ahora el lugar es tranquilo.|Hoy es una tarde cualquiera.|Ahora la oficina está vacía.|Hoy la noche es tranquila.|\
    Ahora todo está en calma.|Hoy la casa es otra.|Ahora la tienda está cerrada.|Hoy el teléfono es distinto.|Ahora la puerta es nueva.|\
    Hoy las luces son más modernas.|Ahora el lugar es otro.|Hoy la ciudad es más grande.|Ahora el mercado ya no existe.|Hoy la calle es peatonal.|\
    Ahora la casa está vacía.|Hoy el teléfono lo hace todo.|Ahora la tienda es un banco.|Hoy la puerta está cerrada.|Ahora las luces son de colores.|\
    Hoy el lugar está abandonado.|Ahora la ciudad es distinta.|Hoy el mercado es un museo.|Ahora el teléfono es más pequeño.|Hoy la casa es más grande.|\
    Ahora la puerta está rota.
    """

    static let moreImperfectCloses = """
    Olía a café.|Se preparaba la cena.|La comida estaba en la mesa.|El mercado estaba lleno.|Había olor a pan.|\
    El café estaba caliente.|La cena estaba servida.|Todo olía a comida.|Ya servían la cena.|El café humeaba.|\
    La comida se enfriaba.|Era la hora de la cena.|Había café en la mesa.|El mercado estaba abierto.|Se sentía el olor a comida.|\
    La cena estaba casi lista.|El café estaba recién hecho.|Todo el mercado olía a fruta.|Nadie probaba la comida.|Había mucho trabajo.|\
    Era lunes por la mañana.|La reunión estaba por empezar.|Todos estaban ocupados.|Había muchos pendientes.|Era martes por la tarde.|\
    El horario era largo.|Había prisa en la oficina.|Era viernes por la tarde.|Había mucho que hacer.|El trabajo no terminaba.|\
    La oficina estaba muy ocupada.|Era un lunes muy ocupado.|Había una reunión en la sala.|El examen estaba por empezar.|Los pendientes se acumulaban.|\
    Había prisa por terminar el trabajo.|Era un martes de trabajo.|El horario de trabajo seguía igual.|Había tráfico en la calle.|La calle estaba llena de coches.|\
    El centro estaba lleno.|El parque estaba abierto.|La plaza estaba llena.|Hacía viento afuera.|La ciudad estaba en movimiento.|\
    Había mucho tráfico en el centro.|Las calles estaban mojadas.|La plaza estaba vacía.|El parque estaba tranquilo.|La ciudad dormía.|\
    Afuera se oía el tráfico.|La calle estaba cerrada.|El centro estaba iluminado.|En el parque había niños.|Había mucho viento en la plaza.|\
    Era una mañana soleada en la ciudad.|Había mucha gente.|El ambiente era alegre.|Había música en la plaza.|La fiesta estaba animada.|\
    Todos esperaban en el café.|El ambiente estaba tenso.|La música sonaba fuerte.|Había gente en todas partes.|El café estaba lleno de gente.|\
    La fiesta seguía.|Todos esperaban afuera.|Había ruido en la plaza.|El ambiente era muy bueno.|Había gente bailando.|\
    Había un silencio total.|Era un día normal.|La sala estaba vacía.|Era una tarde cualquiera.|La casa estaba tranquila.|\
    Todo estaba en calma.|Había silencio en la calle.|La oficina estaba vacía.|Era una noche tranquila.|Nada cambiaba.|\
    Todo era distinto.|Ya no era lo mismo.|Era otra época.|Las cosas eran diferentes.|Todo seguía como antes.|\
    Era un lugar distinto.|Nada parecía igual.|Ya no había nadie.|Todo cambiaba rápido.|Era otra ciudad.|\
    Ya nada era igual.|Todo era diferente.|Se veía todo distinto.|Ya no se veía igual.|Todo estaba cambiando.|\
    Era una historia diferente.|Las cosas ya no eran igual.|Las luces estaban encendidas.|El teléfono estaba apagado.|La tienda estaba cerrada.|\
    El lugar estaba oscuro.|La ciudad estaba iluminada.|El mercado estaba cerrado.|La puerta chirriaba.|Las luces parpadeaban.|\
    El teléfono sonaba.|La casa estaba en silencio.|La tienda estaba vacía.|La calle estaba oscura.
    """

    static let moreTimeContrasts = """
    Antes la comida era más barata.|Ayer hubo cena en casa.|Antes el café era mejor.|Ayer la comida estuvo buena.|Mañana habrá comida de sobra.|\
    Antes la cena era más temprana.|Ayer el mercado estaba lleno.|Antes había más café.|Ayer cenamos tarde.|Mañana habrá cena.|\
    Antes el mercado era más grande.|Ayer el café salió frío.|La semana pasada la comida fue mejor.|Antes la comida se servía en la mesa.|Mañana iremos al mercado.|\
    Antes la cena era a las ocho.|Ayer la comida se acabó.|Mañana habrá café.|Hace años el mercado era más chico.|\
    Ayer hubo más trabajo.|Antes el horario era más corto.|La semana pasada hubo más pendientes.|Mañana habrá reunión.|Antes había menos trabajo.|\
    Ayer fue lunes de mucho trabajo.|El viernes pasado hubo examen.|Antes había menos trabajo en casa.|Mañana hay más por hacer.|El martes pasado fue distinto.|\
    Antes teníamos menos pendientes.|Ayer estuvimos muy ocupados.|El lunes pasado fue igual.|Antes el trabajo era más lento.|Mañana tendremos más prisa.|\
    Hace un año el horario era otro.|Ayer la reunión fue larga.|Antes había menos pendientes.|El viernes será igual.|Ayer hubo más tráfico.|\
    Antes la calle era más tranquila.|Mañana habrá tráfico en el centro.|Antes el parque estaba más limpio.|Ayer la ciudad estaba vacía.|Antes la plaza era más chica.|\
    Ayer el centro estaba cerrado.|Mañana la calle estará cerrada.|Antes no había tanto tráfico.|Ayer hizo viento afuera.|El año pasado la ciudad era distinta.|\
    Antes el centro era más pequeño.|Ayer el parque estaba lleno.|Mañana iremos al centro.|Antes la calle estaba vacía.|Hace años la plaza era otra.|\
    Ayer la calle estuvo cerrada.|Antes el parque era más grande.|La semana pasada hubo más tráfico.|Mañana la plaza estará llena.|Ayer hubo más ruido.|\
    Ayer la fiesta fue mejor.|Antes el ambiente era distinto.|Mañana habrá música.|Antes había más música.|Ayer el café estaba lleno.|\
    Antes la gente hablaba más.|Mañana habrá fiesta.|Ayer el ambiente estuvo tenso.|Hace años el ruido era menor.|Antes la plaza era más alegre.|\
    Ayer la música estuvo muy fuerte.|Antes había más fiestas.|La semana pasada hubo mucha gente.|Mañana habrá más ruido.|Hace un año el ambiente era mejor.|\
    Antes el café era más tranquilo.|Ayer todo estuvo tranquilo.|Antes había más calma.|Mañana habrá silencio.|Antes todo era normal.|\
    Ayer la casa estaba vacía.|Mañana será un día cualquiera.|Antes había más silencio.|Ayer la calle estaba tranquila.|Hace tiempo todo estaba en calma.|\
    Mañana la oficina estará vacía.|Ayer fue un día cualquiera.|Antes todo era más tranquilo.|La semana pasada fue normal.|Ayer hubo mucha calma.|\
    Antes la noche era más silenciosa.|Ayer la puerta estaba abierta.|Antes la casa era más pequeña.|Mañana la tienda abrirá.|Antes el teléfono era más grande.|\
    Ayer las luces estaban apagadas.|Antes el lugar era distinto.|Mañana la ciudad estará lista.|Hace años la tienda era otra.|Ayer el mercado estaba cerrado.|\
    Antes la calle era de tierra.|Ayer el teléfono no funcionó.|Antes las luces eran más débiles.|Mañana la puerta estará lista.|Hace un año la casa era distinta.|\
    Ayer la ciudad estaba iluminada.|Antes la tienda abría más tarde.|Mañana el teléfono funcionará.|Antes el mercado era más chico.|Ayer la puerta no cerraba.|\
    Antes la casa era más ruidosa.
    """
}
