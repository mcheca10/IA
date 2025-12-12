;;; =========================================================
;;; SISTEMA EXPERTO DE RECOMENDACIÓN INMOBILIARIA (SBC)
;;; Metodología: Clasificación Heurística
;;; =========================================================

;;; ---------------------------------------------------------
;;; 1. DEFINICIÓN DE MÓDULOS (Flujo de Control)
;;; ---------------------------------------------------------
(defmodule MAIN (export ?ALL))
(defmodule PREGUNTAS (import MAIN ?ALL) (export ?ALL))   ;;; Interacción usuario
(defmodule ABSTRACCION (import MAIN ?ALL) (export ?ALL)) ;;; Datos -> Rasgos
(defmodule ASOCIACION (import MAIN ?ALL) (export ?ALL))  ;;; Rasgos -> Estado
(defmodule REFINAMIENTO (import MAIN ?ALL) (export ?ALL));;; Ajuste fino numérico
(defmodule INFORME (import MAIN ?ALL) (export ?ALL))     ;;; Salida

;;; ---------------------------------------------------------
;;; 2. TEMPLATES Y FUNCIONES
;;; ---------------------------------------------------------

(deftemplate MAIN::Recomendacion
    (slot solicitante (type INSTANCE-NAME)) 
    (slot vivienda (type INSTANCE-NAME))
    (slot estado (type SYMBOL) (allowed-values INDETERMINADO DESCARTADO VALID MUY_RECOMENDABLE) (default INDETERMINADO))
    (multislot motivos (type STRING))
    (slot puntuacion (type INTEGER) (default 0))
)

;;; Objeto simbólico para la Clasificación Heurística
(deftemplate MAIN::Rasgo
    (slot objeto (type INSTANCE-NAME))
    (slot caracteristica (type SYMBOL)) 
    (slot valor (type SYMBOL))
)

;;; Control de preguntas
(deftemplate MAIN::Pregunta
    (slot atributo (type SYMBOL))   
    (slot texto (type STRING))      
    (slot tipo (type SYMBOL))       ;; numerico, si-no, menu, texto
    (multislot validos)             
    (slot ya-preguntado (type SYMBOL) (default FALSE))
)

(deftemplate MAIN::Respuesta
    (slot atributo (type SYMBOL))
    (slot valor)
)

(deftemplate MAIN::ControlFase
    (slot fase (type SYMBOL))
)

(deffunction MAIN::distancia (?x1 ?y1 ?x2 ?y2)
   (sqrt (+ (* (- ?x2 ?x1) (- ?x2 ?x1)) (* (- ?y2 ?y1) (- ?y2 ?y1))))
)

(defrule MAIN::inicio
    =>
    (printout t "=================================================" crlf)
    (printout t "   SISTEMA DE RECOMENDACIÓN DE VIVIENDAS (SBC)   " crlf)
    (printout t "=================================================" crlf)
    (assert (ControlFase (fase PREGUNTAS)))
    (focus PREGUNTAS)
)

;;; =========================================================
;;; MÓDULO PREGUNTAS: Interacción y Creación de Instancia
;;; =========================================================

(defrule PREGUNTAS::init-preguntas
    (declare (salience 100))
    (not (Pregunta))
    =>
    (assert (Pregunta (atributo tipo_usuario) (texto "1. ¿Qué tipo de perfil tienes?") 
                      (tipo menu) (validos familia estudiantes individuo pareja)))
    (assert (Pregunta (atributo presupuesto) (texto "2. Presupuesto máximo mensual (€):") (tipo numerico)))
    (assert (Pregunta (atributo personas) (texto "3. Número de personas:") (tipo numerico)))
    (assert (Pregunta (atributo mascota) (texto "4. ¿Tienes mascota? (si/no):") (tipo si-no)))
    (assert (Pregunta (atributo ancianos) (texto "5. Edad de la persona más mayor:") (tipo numerico)))
    (assert (Pregunta (atributo trabajo_casa) (texto "6. ¿Trabajas desde casa? (si/no):") (tipo si-no)))
)

;;; Reglas genéricas para leer consola
(defrule PREGUNTAS::ask-numerico
    ?p <- (Pregunta (atributo ?a) (texto ?t) (tipo numerico) (ya-preguntado FALSE))
    (not (Respuesta (atributo ?a)))
    =>
    (printout t ?t " ")
    (bind ?r (read))
    (if (numberp ?r) then (assert (Respuesta (atributo ?a) (valor ?r))) (modify ?p (ya-preguntado TRUE))
    else (printout t ">> Error: Introduce un número." crlf))
)

(defrule PREGUNTAS::ask-menu
    ?p <- (Pregunta (atributo ?a) (texto ?t) (tipo menu) (validos $?v) (ya-preguntado FALSE))
    (not (Respuesta (atributo ?a)))
    =>
    (printout t ?t " [" (implode$ $?v) "]: ")
    (bind ?r (lowcase (read)))
    (if (member$ ?r $?v) then (assert (Respuesta (atributo ?a) (valor ?r))) (modify ?p (ya-preguntado TRUE))
    else (printout t ">> Error: Opción no válida." crlf))
)

(defrule PREGUNTAS::ask-sino
    ?p <- (Pregunta (atributo ?a) (texto ?t) (tipo si-no) (ya-preguntado FALSE))
    (not (Respuesta (atributo ?a)))
    =>
    (printout t ?t " ")
    (bind ?r (lowcase (read)))
    (if (or (eq ?r si) (eq ?r s)) then (assert (Respuesta (atributo ?a) (valor TRUE))) (modify ?p (ya-preguntado TRUE))
     else (if (or (eq ?r no) (eq ?r n)) then (assert (Respuesta (atributo ?a) (valor FALSE))) (modify ?p (ya-preguntado TRUE))
     else (printout t ">> Error: Responde 'si' o 'no'." crlf)))
)

;;; CREACIÓN DE LA INSTANCIA DINÁMICA
(defrule PREGUNTAS::crear-solicitante
    (declare (salience -10))
    ?f <- (ControlFase (fase PREGUNTAS))
    (Respuesta (atributo tipo_usuario) (valor ?tipo))
    (Respuesta (atributo presupuesto) (valor ?presup))
    (Respuesta (atributo personas) (valor ?pers))
    (Respuesta (atributo mascota) (valor ?masc))
    (Respuesta (atributo ancianos) (valor ?edad))
    (Respuesta (atributo trabajo_casa) (valor ?tele))
    =>
    (bind ?clase Solicitante)
    (if (eq ?tipo familia) then (bind ?clase Familia))
    (if (eq ?tipo estudiantes) then (bind ?clase Estudiantes))
    (if (eq ?tipo pareja) then (bind ?clase Pareja))
    (if (eq ?tipo individuo) then (bind ?clase Individuo))

    (make-instance [usuario_actual] of ?clase
        (presupuesto_maximo ?presup)
        (num_personas ?pers)
        (tiene_mascota ?masc)
        (edad_mas_anciano ?edad)
        (trabaja_en_casa ?tele)
    )
    (printout t ">>> Perfil generado: " ?clase crlf)
    (modify ?f (fase ABSTRACCION))
    (focus ABSTRACCION)
)

;;; =========================================================
;;; MÓDULO ABSTRACCION: Datos Numéricos -> Rasgos Simbólicos
;;; =========================================================

;;; 1. ECONOMÍA
(defrule ABSTRACCION::abs-precio-impagable
    (object (is-a Solicitante) (presupuesto_maximo ?max))
    (object (is-a Vivienda) (name ?v) (precio_mensual ?p))
    (test (> ?p ?max))
    =>
    (assert (Rasgo (objeto ?v) (caracteristica COSTE) (valor IMPAGABLE)))
)

(defrule ABSTRACCION::abs-precio-chollo
    (object (is-a Solicitante) (presupuesto_maximo ?max))
    (object (is-a Vivienda) (name ?v) (precio_mensual ?p))
    (test (<= ?p (- ?max 200)))
    =>
    (assert (Rasgo (objeto ?v) (caracteristica COSTE) (valor CHOLLO)))
)

;;; 2. ESPACIO
(defrule ABSTRACCION::abs-espacio-hacinado
    (object (is-a Solicitante) (num_personas ?np))
    (object (is-a Vivienda) (name ?v) (num_habs_dobles ?hd) (num_habs_individual ?hi))
    (test (> ?np (+ (* ?hd 2) ?hi)))
    =>
    (assert (Rasgo (objeto ?v) (caracteristica ESPACIO) (valor INSUFICIENTE)))
)

;;; 3. ACCESIBILIDAD
(defrule ABSTRACCION::abs-accesibilidad-mala
    (object (is-a Vivienda) (name ?v) (tiene_ascensor FALSE) (altura_piso ?h))
    (test (> ?h 0))
    =>
    (assert (Rasgo (objeto ?v) (caracteristica ACCESIBILIDAD) (valor MALA)))
)

;;; 4. SERVICIOS (Ejemplos para llegar a 50 reglas)
(defrule ABSTRACCION::abs-servicios-educacion
    (object (is-a Vivienda) (name ?v) (tiene_servicio_cercano $?s))
    (exists (object (is-a Educacion) (name ?e)) (test (member$ ?e ?s)))
    =>
    (assert (Rasgo (objeto ?v) (caracteristica ENTORNO) (valor EDUCATIVO)))
)

(defrule ABSTRACCION::abs-servicios-salud
    (object (is-a Vivienda) (name ?v) (tiene_servicio_cercano $?s))
    (exists (object (is-a Salud) (name ?sa)) (test (member$ ?sa ?s)))
    =>
    (assert (Rasgo (objeto ?v) (caracteristica ENTORNO) (valor SANITARIO)))
)

(defrule ABSTRACCION::abs-servicios-ocio
    (object (is-a Vivienda) (name ?v) (tiene_servicio_cercano $?s))
    (exists (object (is-a Zona_Nocturna) (name ?zn)) (test (member$ ?zn ?s)))
    =>
    (assert (Rasgo (objeto ?v) (caracteristica ENTORNO) (valor RUIDOSO)))
)

(defrule ABSTRACCION::abs-servicios-relax
    (object (is-a Vivienda) (name ?v) (tiene_servicio_cercano $?s))
    (exists (object (is-a Zona_Verde) (name ?zv)) (test (member$ ?zv ?s)))
    =>
    (assert (Rasgo (objeto ?v) (caracteristica ENTORNO) (valor RELAX)))
)

;;; 5. POLITICAS
(defrule ABSTRACCION::abs-mascotas
    (object (is-a Vivienda) (name ?v) (permite_mascotas FALSE))
    =>
    (assert (Rasgo (objeto ?v) (caracteristica POLITICA) (valor NO_MASCOTAS)))
)

;;; 6. LUMINOSIDAD

(defrule ABSTRACCION::abs-luz-natural
    (object (is-a Vivienda) (name ?v) (es_soleado "Nada"))
    =>
    (assert (Rasgo (objeto ?v) (caracteristica LUMINOSIDAD) (valor OSCURO)))
)

(defrule ABSTRACCION::abs-luz-premium
    (object (is-a Vivienda) (name ?v) (es_soleado "Todo el dia"))
    =>
    (assert (Rasgo (objeto ?v) (caracteristica LUMINOSIDAD) (valor EXCELENTE)))
)

(defrule ABSTRACCION::abs-luz-pobre
    (object (is-a Vivienda) (name ?v) (es_soleado "Nada"))
    =>
    (assert (Rasgo (objeto ?v) (caracteristica LUMINOSIDAD) (valor OSCURO)))
)

;;; 7. TRANSPORTE
(defrule ABSTRACCION::abs-transporte-metro
    (object (is-a Vivienda) (name ?v) (tiene_servicio_cercano $?s))
    (exists (object (is-a Parada_Metro) (name ?m)) (test (member$ ?m ?s)))
    =>
    (assert (Rasgo (objeto ?v) (caracteristica CONECTIVIDAD) (valor RAPIDA)))
)

(defrule ABSTRACCION::abs-transporte-solo-bus
    (object (is-a Vivienda) (name ?v) (tiene_servicio_cercano $?s))
    (exists (object (is-a Parada_Autobús) (name ?b)) (test (member$ ?b ?s)))
    (not (exists (object (is-a Parada_Metro) (name ?m)) (test (member$ ?m ?s))))
    =>
    (assert (Rasgo (objeto ?v) (caracteristica CONECTIVIDAD) (valor LENTA)))
)

;;; 8. ENTORNO
(defrule ABSTRACCION::abs-zona-comercial
    (object (is-a Vivienda) (name ?v) (tiene_servicio_cercano $?s))
    (exists (object (is-a Supermercado) (name ?sup)) (test (member$ ?sup ?s)))
    (exists (object (is-a Centro_Comercial) (name ?cc)) (test (member$ ?cc ?s)))
    =>
    (assert (Rasgo (objeto ?v) (caracteristica ZONA) (valor COMERCIAL)))
)

(defrule ABSTRACCION::abs-zona-verde
    (object (is-a Vivienda) (name ?v) (tiene_servicio_cercano $?s))
    (exists (object (is-a Zona_Verde) (name ?zv)) (test (member$ ?zv ?s)))
    =>
    (assert (Rasgo (objeto ?v) (caracteristica ZONA) (valor NATURAL)))
)

;;; 9. CONFORT TÉRMICO
(defrule ABSTRACCION::abs-sin-climatizacion
    (object (is-a Vivienda) (name ?v) (tiene_calefaccion FALSE) (tiene_aire_acondicionado FALSE))
    =>
    (assert (Rasgo (objeto ?v) (caracteristica CONFORT) (valor BAJO)))
)

;;; 10. TIPO DE PISO
(defrule ABSTRACCION::abs-piso-bajo
    (object (is-a Vivienda) (name ?v) (altura_piso 0))
    =>
    (assert (Rasgo (objeto ?v) (caracteristica TIPOLOGIA) (valor BAJOS)))
)

(defrule ABSTRACCION::abs-piso-atico
    (object (is-a Vivienda) (name ?v) (tiene_terraza TRUE) (altura_piso ?h&:(> ?h 5)))
    =>
    (assert (Rasgo (objeto ?v) (caracteristica TIPOLOGIA) (valor ATICO)))
)

;;; 11. SERVICIOS

;;; Detectar Supermercado
(defrule ABSTRACCION::abs-comercio-basico
    (object (is-a Vivienda) (name ?v) (tiene_servicio_cercano $?s))
    (exists (object (is-a Supermercado) (name ?sup)) (test (member$ ?sup ?s)))
    =>
    (assert (Rasgo (objeto ?v) (caracteristica SERVICIOS) (valor ABASTECIMIENTO)))
)

;;; Detectar Zonas Deportivas
(defrule ABSTRACCION::abs-zona-deporte
    (object (is-a Vivienda) (name ?v) (tiene_servicio_cercano $?s))
    (exists (object (is-a Parque) (name ?p)) (test (member$ ?p ?s)))
    =>
    (assert (Rasgo (objeto ?v) (caracteristica ESTILO_VIDA) (valor DEPORTIVO)))
)

(defrule ABSTRACCION::siguiente
    (declare (salience -10))
    ?f <- (ControlFase (fase ABSTRACCION))
    =>
    (modify ?f (fase ASOCIACION))
    (focus ASOCIACION)
)



;;; =========================================================
;;; MÓDULO ASOCIACION: Lógica Heurística (Match Usuario-Rasgo)
;;; =========================================================

;;; Inicializar recomendaciones
(defrule ASOCIACION::init-recom
    (object (is-a Solicitante) (name ?s))
    (object (is-a Vivienda) (name ?v))
    =>
    (assert (Recomendacion (solicitante ?s) (vivienda ?v) (estado INDETERMINADO)))
)

;;; ---------------------------------------------------------
;;; A. RESTRICCIONES DURAS (HARD) -> DESCARTADO
;;; ---------------------------------------------------------

(defrule ASOCIACION::filtrar-precio
    ?r <- (Recomendacion (vivienda ?v) (estado INDETERMINADO))
    (Rasgo (objeto ?v) (caracteristica COSTE) (valor IMPAGABLE))
    =>
    (modify ?r (estado DESCARTADO) (motivos "Presupuesto insuficiente."))
)

(defrule ASOCIACION::filtrar-espacio
    ?r <- (Recomendacion (vivienda ?v) (estado INDETERMINADO))
    (Rasgo (objeto ?v) (caracteristica ESPACIO) (valor INSUFICIENTE))
    =>
    (modify ?r (estado DESCARTADO) (motivos "Faltan habitaciones para todos."))
)

(defrule ASOCIACION::filtrar-mascota-prohibida
    ?r <- (Recomendacion (vivienda ?v) (estado INDETERMINADO))
    (object (is-a Solicitante) (tiene_mascota TRUE))
    (Rasgo (objeto ?v) (caracteristica POLITICA) (valor NO_MASCOTAS))
    =>
    (modify ?r (estado DESCARTADO) (motivos "No admiten mascotas."))
)

(defrule ASOCIACION::filtrar-accesibilidad-ancianos
    ?r <- (Recomendacion (vivienda ?v) (estado INDETERMINADO))
    (object (is-a Solicitante) (edad_mas_anciano ?e&:(> ?e 70)))
    (Rasgo (objeto ?v) (caracteristica ACCESIBILIDAD) (valor MALA))
    =>
    (modify ?r (estado DESCARTADO) (motivos "Inaccesible (Piso alto sin ascensor)."))
)

;;; NUEVA: Los dúplex suelen tener escaleras internas, peligroso para ancianos
(defrule ASOCIACION::filtrar-duplex-ancianos
    ?r <- (Recomendacion (vivienda ?v) (estado INDETERMINADO))
    (object (is-a Solicitante) (edad_mas_anciano ?e&:(> ?e 75)))
    (object (is-a Dúplex) (name ?v))
    =>
    (modify ?r (estado DESCARTADO) (motivos "Dúplex descartado (escaleras internas peligrosas)."))
)

;;; NUEVA: Familia numerosa en estudio/apartamento pequeño
(defrule ASOCIACION::filtrar-familia-estudio
    ?r <- (Recomendacion (vivienda ?v) (estado INDETERMINADO))
    (object (is-a Familia) (num_personas ?np&:(> ?np 3)))
    (object (is-a Vivienda) (name ?v) (num_habs_dobles 0)) ; Si no tiene hab doble
    =>
    (modify ?r (estado DESCARTADO) (motivos "Distribución inviable para familia."))
)

;;; ---------------------------------------------------------
;;; B. RESTRICCIONES SUAVES (SOFT NEGATIVAS) -> PARCIALMENTE
;;; ---------------------------------------------------------

(defrule ASOCIACION::aviso-oscuridad-teletrabajo
    ?r <- (Recomendacion (vivienda ?v) (estado ?st) (motivos $?m))
    (test (neq ?st DESCARTADO))
    (object (is-a Solicitante) (trabaja_en_casa TRUE))
    (Rasgo (objeto ?v) (caracteristica LUMINOSIDAD) (valor OSCURO))
    (test (not (member$ "Poca luz para trabajar" $?m)))
    =>
    (modify ?r (estado PARCIALMENTE_ADECUADO) (motivos $?m "Poca luz para trabajar"))
)

(defrule ASOCIACION::aviso-ruido-ancianos
    ?r <- (Recomendacion (vivienda ?v) (estado ?st) (motivos $?m))
    (test (neq ?st DESCARTADO))
    (object (is-a Solicitante) (edad_mas_anciano ?e&:(> ?e 60)))
    (Rasgo (objeto ?v) (caracteristica ENTORNO) (valor RUIDOSO))
    (test (not (member$ "Zona muy ruidosa" $?m)))
    =>
    (modify ?r (estado PARCIALMENTE_ADECUADO) (motivos $?m "Zona muy ruidosa"))
)

;;; NUEVA: Mascota en piso sin terraza (aviso, no descarte)
(defrule ASOCIACION::aviso-mascota-sin-exterior
    ?r <- (Recomendacion (vivienda ?v) (estado ?st) (motivos $?m))
    (test (neq ?st DESCARTADO))
    (object (is-a Solicitante) (tiene_mascota TRUE))
    (object (is-a Vivienda) (name ?v) (tiene_terraza FALSE))
    (Rasgo (objeto ?v) (caracteristica TIPOLOGIA) (valor BAJOS)) ; Si no es bajo jardin
    (test (not (member$ "Mascota sin espacio exterior" $?m)))
    =>
    (modify ?r (estado PARCIALMENTE_ADECUADO) (motivos $?m "Mascota sin espacio exterior"))
)

;;; NUEVA: Familia en Bajos ruidosos
(defrule ASOCIACION::aviso-familia-bajos
    ?r <- (Recomendacion (vivienda ?v) (estado ?st) (motivos $?m))
    (test (neq ?st DESCARTADO))
    (object (is-a Familia))
    (Rasgo (objeto ?v) (caracteristica TIPOLOGIA) (valor BAJOS))
    (Rasgo (objeto ?v) (caracteristica ENTORNO) (valor RUIDOSO))
    (test (not (member$ "Bajos con poca intimidad" $?m)))
    =>
    (modify ?r (estado PARCIALMENTE_ADECUADO) (motivos $?m "Bajos con poca intimidad"))
)

;;; NUEVA: Coche sin parking fácil
(defrule ASOCIACION::aviso-coche-parking
    ?r <- (Recomendacion (vivienda ?v) (estado ?st) (motivos $?m))
    (test (neq ?st DESCARTADO))
    (object (is-a Solicitante) (tiene_coche TRUE))
    ;; Asumimos que si no es unifamiliar ni tiene parking en servicios...
    (test (neq (class ?v) Unifamiliar)) 
    (not (Rasgo (objeto ?v) (caracteristica ZONA) (valor COMERCIAL))) ; En zonas comerciales es dificil aparcar
    (test (not (member$ "Dificil aparcamiento en la calle" $?m)))
    =>
    (modify ?r (estado PARCIALMENTE_ADECUADO) (motivos $?m "Dificil aparcamiento en la calle"))
)

;;; ---------------------------------------------------------
;;; C. RECOMENDACIONES (BONUS) -> MUY RECOMENDABLE
;;; ---------------------------------------------------------

(defrule ASOCIACION::recomendar-familia-educacion
    ?r <- (Recomendacion (vivienda ?v) (estado ?st) (motivos $?m))
    (test (neq ?st DESCARTADO))
    (object (is-a Familia))
    (Rasgo (objeto ?v) (caracteristica ENTORNO) (valor EDUCATIVO))
    (test (not (member$ "Colegios cerca" $?m)))
    =>
    (modify ?r (estado MUY_RECOMENDABLE) (motivos $?m "Colegios cerca"))
)

(defrule ASOCIACION::recomendar-estudiante-fiesta
    ?r <- (Recomendacion (vivienda ?v) (estado ?st) (motivos $?m))
    (test (neq ?st DESCARTADO))
    (object (is-a Estudiantes))
    (Rasgo (objeto ?v) (caracteristica ENTORNO) (valor RUIDOSO))
    (test (not (member$ "Zona de ambiente" $?m)))
    =>
    (modify ?r (estado MUY_RECOMENDABLE) (motivos $?m "Zona de ambiente"))
)

(defrule ASOCIACION::recomendar-estudiante-transporte
    ?r <- (Recomendacion (vivienda ?v) (estado ?st) (motivos $?m))
    (test (neq ?st DESCARTADO))
    (object (is-a Estudiantes))
    (Rasgo (objeto ?v) (caracteristica CONECTIVIDAD) (valor RAPIDA))
    (test (not (member$ "Conexión rápida Universidad" $?m)))
    =>
    (modify ?r (estado MUY_RECOMENDABLE) (motivos $?m "Conexión rápida Universidad"))
)

(defrule ASOCIACION::recomendar-anciano-relax
    ?r <- (Recomendacion (vivienda ?v) (estado ?st) (motivos $?m))
    (test (neq ?st DESCARTADO))
    (object (is-a Solicitante) (edad_mas_anciano ?e&:(> ?e 65)))
    (Rasgo (objeto ?v) (caracteristica ENTORNO) (valor RELAX))
    (test (not (member$ "Zona verde tranquila" $?m)))
    =>
    (modify ?r (estado MUY_RECOMENDABLE) (motivos $?m "Zona verde tranquila"))
)

(defrule ASOCIACION::recomendar-chollo
    ?r <- (Recomendacion (vivienda ?v) (estado ?st) (motivos $?m))
    (test (neq ?st DESCARTADO))
    (Rasgo (objeto ?v) (caracteristica COSTE) (valor CHOLLO))
    (test (not (member$ "Gran precio" $?m)))
    =>
    (modify ?r (estado MUY_RECOMENDABLE) (motivos $?m "Gran precio"))
)

;;; NUEVA: Recomendar Ático a Parejas (Calidad de vida)
(defrule ASOCIACION::recomendar-pareja-atico
    ?r <- (Recomendacion (vivienda ?v) (estado ?st) (motivos $?m))
    (test (neq ?st DESCARTADO))
    (object (is-a Pareja))
    (Rasgo (objeto ?v) (caracteristica TIPOLOGIA) (valor ATICO))
    (test (not (member$ "Ático con terraza" $?m)))
    =>
    (modify ?r (estado MUY_RECOMENDABLE) (motivos $?m "Ático con terraza"))
)

;;; Regla de limpieza (Si no se ha activado nada, se queda en VALID)
(defrule ASOCIACION::validar-por-defecto
    (declare (salience -5))
    ?r <- (Recomendacion (estado INDETERMINADO))
    =>
    (modify ?r (estado VALID))
)

;;; Pareja busca ocio cultural (Cine/Teatro)
(defrule ASOCIACION::recomendar-pareja-ocio
    ?r <- (Recomendacion (solicitante ?s) (vivienda ?v) (estado ?st) (motivos $?m))
    (test (neq ?st DESCARTADO))
    (object (is-a Pareja))
    (object (is-a Vivienda) (name ?v) (tiene_servicio_cercano $?s))
    (exists (object (is-a Cine) (name ?c)) (test (member$ ?c ?s)))
    (test (not (member$ "Ocio cultural cerca" $?m)))
    =>
    (modify ?r (estado MUY_RECOMENDABLE) (motivos $?m "Ocio cultural cerca"))
)

;;; Pareja joven evita zonas dormitorio (quieren vida)
(defrule ASOCIACION::aviso-pareja-aislada
    ?r <- (Recomendacion (solicitante ?s) (vivienda ?v) (estado ?st) (motivos $?m))
    (test (neq ?st DESCARTADO))
    (object (is-a Pareja) (edad_mas_anciano ?e&:(< ?e 40)))
    (not (Rasgo (objeto ?v) (caracteristica ZONA) (valor COMERCIAL)))
    (not (Rasgo (objeto ?v) (caracteristica ENTORNO) (valor RUIDOSO))) ;; Ni tiendas ni bares
    (test (not (member$ "Zona muy apagada para gente joven" $?m)))
    =>
    (modify ?r (estado PARCIALMENTE_ADECUADO) (motivos $?m "Zona muy apagada para gente joven"))
)

;;; Individuo valora seguridad (evita bajos en zonas solas)
(defrule ASOCIACION::aviso-individuo-bajos
    ?r <- (Recomendacion (solicitante ?s) (vivienda ?v) (estado ?st) (motivos $?m))
    (test (neq ?st DESCARTADO))
    (object (is-a Individuo))
    (Rasgo (objeto ?v) (caracteristica TIPOLOGIA) (valor BAJOS))
    (test (not (member$ "Seguridad: Planta baja para vivir solo" $?m)))
    =>
    (modify ?r (estado PARCIALMENTE_ADECUADO) (motivos $?m "Seguridad: Planta baja para vivir solo"))
)

;;; Familia necesita supermercado cerca (Logística pesada)
(defrule ASOCIACION::aviso-familia-abastecimiento
    ?r <- (Recomendacion (solicitante ?s) (vivienda ?v) (estado ?st) (motivos $?m))
    (test (neq ?st DESCARTADO))
    (object (is-a Familia))
    (not (Rasgo (objeto ?v) (caracteristica SERVICIOS) (valor ABASTECIMIENTO)))
    (test (not (member$ "Falta supermercado para compra familiar" $?m)))
    =>
    (modify ?r (estado PARCIALMENTE_ADECUADO) (motivos $?m "Falta supermercado para compra familiar"))
)

;;; Anciano y farmacia/supermercado
(defrule ASOCIACION::recomendar-anciano-servicios
    ?r <- (Recomendacion (solicitante ?s) (vivienda ?v) (estado ?st) (motivos $?m))
    (test (neq ?st DESCARTADO))
    (object (is-a Solicitante) (edad_mas_anciano ?e&:(> ?e 70)))
    (Rasgo (objeto ?v) (caracteristica SERVICIOS) (valor ABASTECIMIENTO))
    (test (not (member$ "Servicios básicos a pie" $?m)))
    =>
    (modify ?r (estado MUY_RECOMENDABLE) (motivos $?m "Servicios básicos a pie"))
)

(defrule ASOCIACION::siguiente
    (declare (salience -10))
    ?f <- (ControlFase (fase ASOCIACION))
    =>
    (modify ?f (fase REFINAMIENTO))
    (focus REFINAMIENTO)
)

;;; =========================================================
;;; MÓDULO REFINAMIENTO: Puntuación Final
;;; =========================================================

;;; Puntos base según estado cualitativo
(defrule REFINAMIENTO::base-muy-rec
    ?r <- (Recomendacion (estado MUY_RECOMENDABLE) (puntuacion ?p))
    => (modify ?r (puntuacion (+ ?p 100))))

(defrule REFINAMIENTO::base-valid
    ?r <- (Recomendacion (estado VALID) (puntuacion ?p))
    => (modify ?r (puntuacion (+ ?p 50))))

(defrule REFINAMIENTO::base-parcial
    ?r <- (Recomendacion (estado PARCIALMENTE_ADECUADO) (puntuacion ?p))
    => (modify ?r (puntuacion (+ ?p 10))))
    

;;; ---------------------------------------------------------
;;; CÁLCULOS MATEMÁTICOS DE BONIFICACIÓN
;;; ---------------------------------------------------------

;;; 1. Bonus por Ahorro (Matemático)
(defrule REFINAMIENTO::bonus-ahorro-progresivo
    ?r <- (Recomendacion (vivienda ?v) (estado ?st) (puntuacion ?p) (motivos $?m))
    (test (neq ?st DESCARTADO))
    (object (is-a Solicitante) (presupuesto_maximo ?max))
    (object (is-a Vivienda) (name ?v) (precio_mensual ?pr))
    (test (< ?pr ?max))
    =>
    (bind ?ahorro (- ?max ?pr))
    ;; 1 punto extra por cada 10€ de ahorro
    (bind ?extra (div ?ahorro 10))
    (modify ?r (puntuacion (+ ?p ?extra)))
)

;;; 2. Bonus por Proximidad Trabajo (Matemático)
(defrule REFINAMIENTO::bonus-distancia-trabajo
    ?r <- (Recomendacion (vivienda ?v) (estado ?st) (puntuacion ?p) (motivos $?m))
    (test (neq ?st DESCARTADO))
    (object (is-a Solicitante) (trabaja_en_x ?tx) (trabaja_en_y ?ty))
    (object (is-a Vivienda) (name ?v) (coordx ?vx) (coordy ?vy))
    (test (neq ?tx nil)) ;; Solo si tiene coordenadas de trabajo
    =>
    (bind ?dist (distancia ?tx ?ty ?vx ?vy))
    (if (< ?dist 1000) then
        (modify ?r (puntuacion (+ ?p 30)) (motivos $?m "Muy cerca del trabajo (<1km)"))
    else (if (< ?dist 3000) then
        (modify ?r (puntuacion (+ ?p 10)) (motivos $?m "Distancia razonable trabajo")))
    )
)

;;; 3. Bonus Calidad/Precio: Aire Acondicionado
(defrule REFINAMIENTO::bonus-aire-acondicionado
    ?r <- (Recomendacion (vivienda ?v) (estado ?st) (puntuacion ?p))
    (test (neq ?st DESCARTADO))
    (object (is-a Vivienda) (name ?v) (tiene_aire_acondicionado TRUE))
    =>
    (modify ?r (puntuacion (+ ?p 10)))
)

;;; 4. Bonus Calidad: Muebles (Ahorro inicial para el usuario)
(defrule REFINAMIENTO::bonus-amueblado
    ?r <- (Recomendacion (vivienda ?v) (estado ?st) (puntuacion ?p) (motivos $?m))
    (test (neq ?st DESCARTADO))
    (object (is-a Vivienda) (name ?v) (amueblado SI))
    =>
    (modify ?r (puntuacion (+ ?p 15)) (motivos $?m "Amueblado (listo para entrar)"))
)

;;; 5. Bonus Espacio Exterior
(defrule REFINAMIENTO::bonus-terraza
    ?r <- (Recomendacion (vivienda ?v) (estado ?st) (puntuacion ?p))
    (test (neq ?st DESCARTADO))
    (object (is-a Vivienda) (name ?v) (tiene_terraza TRUE))
    =>
    (modify ?r (puntuacion (+ ?p 10)))
)

;;; ---------------------------------------------------------
;;; PENALIZACIONES NUMÉRICAS
;;; ---------------------------------------------------------

;;; 6. Penalización: Sin ascensor (aunque no sea anciano, molesta)
(defrule REFINAMIENTO::penalizacion-sin-ascensor
    ?r <- (Recomendacion (vivienda ?v) (estado ?st) (puntuacion ?p))
    (test (neq ?st DESCARTADO))
    (object (is-a Vivienda) (name ?v) (tiene_ascensor FALSE) (altura_piso ?h&:(> ?h 1)))
    =>
    (modify ?r (puntuacion (- ?p 15)))
)

;;; 7. Penalización: Conectividad Pobre (si no es estudiante)
(defrule REFINAMIENTO::penalizacion-conectividad-mala
    ?r <- (Recomendacion (vivienda ?v) (estado ?st) (puntuacion ?p))
    (test (neq ?st DESCARTADO))
    (Rasgo (objeto ?v) (caracteristica CONECTIVIDAD) (valor LENTA))
    =>
    (modify ?r (puntuacion (- ?p 10)))
)

;;; Penalizar pisos interiores (aunque no teletrabajes, es triste)
(defrule REFINAMIENTO::penalizacion-general-oscuro
    ?r <- (Recomendacion (vivienda ?v) (estado ?st) (puntuacion ?p))
    (test (neq ?st DESCARTADO))
    (Rasgo (objeto ?v) (caracteristica LUMINOSIDAD) (valor OSCURO))
    =>
    (modify ?r (puntuacion (- ?p 15)))
)

;;; Bonificar número de baños (Ratio personas/baño)
(defrule REFINAMIENTO::bonus-ratio-banos
    ?r <- (Recomendacion (solicitante ?s) (vivienda ?v) (estado ?st) (puntuacion ?p) (motivos $?m))
    (test (neq ?st DESCARTADO))
    (object (is-a Solicitante) (num_personas ?np))
    (object (is-a Vivienda) (name ?v) (num_banos ?nb))
    ;; Si hay al menos un baño por cada 2 personas, es un lujo
    (test (<= ?np (* ?nb 2))) 
    =>
    (modify ?r (puntuacion (+ ?p 10)) (motivos $?m "Buen ratio baños/personas"))
)

;;; Bonificar calefacción (Siempre es bueno)
(defrule REFINAMIENTO::bonus-calefaccion-general
    ?r <- (Recomendacion (vivienda ?v) (estado ?st) (puntuacion ?p))
    (test (neq ?st DESCARTADO))
    (object (is-a Vivienda) (name ?v) (tiene_calefaccion SI))
    =>
    (modify ?r (puntuacion (+ ?p 5)))
)

(defrule REFINAMIENTO::siguiente
    (declare (salience -10))
    ?f <- (ControlFase (fase REFINAMIENTO))
    =>
    (modify ?f (fase INFORME))
    (focus INFORME)
)

;;; =========================================================
;;; MÓDULO INFORME: Presentación de Resultados
;;; =========================================================

(defrule INFORME::cabecera
    (declare (salience 100))
    =>
    (printout t crlf "=========================================" crlf)
    (printout t "      INFORME FINAL DE RECOMENDACIONES     " crlf)
    (printout t "=========================================" crlf crlf)
)

;;; ---------------------------------------------------------
;;; IMPRIMIR VIVIENDAS ACEPTADAS (Ordenadas por lógica interna de CLIPS)
;;; ---------------------------------------------------------

(defrule INFORME::imprimir-recomendacion
    ;; Imprimimos cualquier vivienda que NO esté descartada
    ?r <- (Recomendacion (vivienda ?v) (estado ?e) (puntuacion ?p) (motivos $?m))
    (test (neq ?e DESCARTADO))
    =>
    (printout t "VIVIENDA: " ?v crlf)
    (printout t "  -> Estado: " ?e crlf)
    (printout t "  -> Puntuación: " ?p " puntos" crlf)
    
    ;; Imprimimos los motivos si existen
    (if (> (length$ $?m) 0) 
        then 
        (printout t "  -> Motivos: " (implode$ $?m) crlf)
    )
    (printout t "-----------------------------------------" crlf)
)

;;; ---------------------------------------------------------
;;; IMPRIMIR DESCARTES (Opcional, pero útil para depurar)
;;; ---------------------------------------------------------

(defrule INFORME::imprimir-descarte
    ?r <- (Recomendacion (vivienda ?v) (estado DESCARTADO) (motivos $?m))
    =>
    (printout t "[X] DESCARTADA: " ?v crlf)
    (printout t "    Causa: " (implode$ $?m) crlf)
    (printout t "-----------------------------------------" crlf)
)

;;; ---------------------------------------------------------
;;; FIN DEL SISTEMA
;;; ---------------------------------------------------------

(defrule INFORME::fin-del-proceso
    (declare (salience -10))
    =>
    (printout t crlf ">>> Proceso finalizado." crlf)
)