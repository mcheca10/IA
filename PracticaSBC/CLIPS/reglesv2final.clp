;;; =========================================================
;;; SISTEMA EXPERTO INMOBILIARIO - BATCH
;;; =========================================================

;;; ---------------------------------------------------------
;;; 1. DEFINICIÓN DE MÓDULOS
;;; ---------------------------------------------------------
(defmodule MAIN (export ?ALL))
(defmodule ABSTRACCION (import MAIN ?ALL) (export ?ALL))
(defmodule ASOCIACION (import MAIN ?ALL) (export ?ALL))
(defmodule REFINAMIENTO (import MAIN ?ALL) (export ?ALL))
(defmodule INFORME (import MAIN ?ALL) (export ?ALL))

;;; ---------------------------------------------------------
;;; 2. TEMPLATES
;;; ---------------------------------------------------------

(deftemplate MAIN::Recomendacion
    (slot solicitante (type INSTANCE-NAME)) 
    (slot vivienda (type INSTANCE-NAME))
    (slot estado (type SYMBOL) (allowed-values INDETERMINADO DESCARTADO PARCIALMENTE_ADECUADO VALID MUY_RECOMENDABLE) (default INDETERMINADO))
    (multislot motivos (type STRING))
    (slot puntuacion (type INTEGER) (default 0))
)

(deftemplate MAIN::Rasgo
    (slot objeto (type INSTANCE-NAME))
    (slot caracteristica (type SYMBOL)) 
    (slot valor (type SYMBOL))
)

(deftemplate MAIN::ControlFase
    (slot fase (type SYMBOL))
)

(deffunction MAIN::distancia (?x1 ?y1 ?x2 ?y2)
   (sqrt (+ (* (- ?x2 ?x1) (- ?x2 ?x1)) (* (- ?y2 ?y1) (- ?y2 ?y1))))
)

;;; --- REGLA DE INICIO ---
(defrule MAIN::inicio-batch
    =>
    (printout t "=================================================" crlf)
    (printout t "   EJECUTANDO SISTEMA (JUEGOS DE PRUEBA)         " crlf)
    (printout t "=================================================" crlf)
    (assert (ControlFase (fase ABSTRACCION)))
    (focus ABSTRACCION)
)

;;; =========================================================
;;; MÓDULO ABSTRACCION
;;; =========================================================

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

(defrule ABSTRACCION::abs-espacio-hacinado
    (object (is-a Solicitante) (num_personas ?np))
    (object (is-a Vivienda) (name ?v) (num_habs_dobles ?hd) (num_habs_individual ?hi))
    (test (> ?np (+ (* ?hd 2) ?hi)))
    =>
    (assert (Rasgo (objeto ?v) (caracteristica ESPACIO) (valor INSUFICIENTE)))
)

(defrule ABSTRACCION::abs-accesibilidad-mala
    (object (is-a Vivienda) (name ?v) (tiene_ascensor FALSE) (altura_piso ?h))
    (test (> ?h 0))
    =>
    (assert (Rasgo (objeto ?v) (caracteristica ACCESIBILIDAD) (valor MALA)))
)

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

(defrule ABSTRACCION::abs-mascotas
    (object (is-a Vivienda) (name ?v) (permite_mascotas FALSE))
    =>
    (assert (Rasgo (objeto ?v) (caracteristica POLITICA) (valor NO_MASCOTAS)))
)

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

(defrule ABSTRACCION::abs-sin-climatizacion
    (object (is-a Vivienda) (name ?v) (tiene_calefaccion FALSE) (tiene_aire_acondicionado FALSE))
    =>
    (assert (Rasgo (objeto ?v) (caracteristica CONFORT) (valor BAJO)))
)

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

(defrule ABSTRACCION::abs-comercio-basico
    (object (is-a Vivienda) (name ?v) (tiene_servicio_cercano $?s))
    (exists (object (is-a Supermercado) (name ?sup)) (test (member$ ?sup ?s)))
    =>
    (assert (Rasgo (objeto ?v) (caracteristica SERVICIOS) (valor ABASTECIMIENTO)))
)

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
;;; MÓDULO ASOCIACION
;;; =========================================================

;;; Regla CLAVE para crear todas las combinaciones posibles
(defrule ASOCIACION::init-recom
    (object (is-a Solicitante) (name ?s))
    (object (is-a Vivienda) (name ?v))
    =>
    (assert (Recomendacion (solicitante ?s) (vivienda ?v) (estado INDETERMINADO)))
)

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

(defrule ASOCIACION::filtrar-duplex-ancianos
    ?r <- (Recomendacion (vivienda ?v) (estado INDETERMINADO))
    (object (is-a Solicitante) (edad_mas_anciano ?e&:(> ?e 75)))
    (object (is-a Dúplex) (name ?v))
    =>
    (modify ?r (estado DESCARTADO) (motivos "Duplex descartado (escaleras internas peligrosas)."))
)

(defrule ASOCIACION::filtrar-familia-estudio
    ?r <- (Recomendacion (vivienda ?v) (estado INDETERMINADO))
    (object (is-a Familia) (num_personas ?np&:(> ?np 3)))
    (object (is-a Vivienda) (name ?v) (num_habs_dobles 0))
    =>
    (modify ?r (estado DESCARTADO) (motivos "Distribucion inviable para familia."))
)

;;; AVISOS (PARCIAL)

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

(defrule ASOCIACION::aviso-mascota-sin-exterior
    ?r <- (Recomendacion (vivienda ?v) (estado ?st) (motivos $?m))
    (test (neq ?st DESCARTADO))
    (object (is-a Solicitante) (tiene_mascota TRUE))
    (object (is-a Vivienda) (name ?v) (tiene_terraza FALSE))
    (Rasgo (objeto ?v) (caracteristica TIPOLOGIA) (valor BAJOS))
    (test (not (member$ "Mascota sin espacio exterior" $?m)))
    =>
    (modify ?r (estado PARCIALMENTE_ADECUADO) (motivos $?m "Mascota sin espacio exterior"))
)

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

(defrule ASOCIACION::aviso-coche-parking
    ?r <- (Recomendacion (vivienda ?v) (estado ?st) (motivos $?m))
    (test (neq ?st DESCARTADO))
    (object (is-a Solicitante) (tiene_coche TRUE))
    (test (neq (class ?v) Unifamiliar)) 
    (not (Rasgo (objeto ?v) (caracteristica ZONA) (valor COMERCIAL)))
    (test (not (member$ "Dificil aparcamiento en la calle" $?m)))
    =>
    (modify ?r (estado PARCIALMENTE_ADECUADO) (motivos $?m "Dificil aparcamiento en la calle"))
)

(defrule ASOCIACION::aviso-pareja-aislada
    ?r <- (Recomendacion (solicitante ?s) (vivienda ?v) (estado ?st) (motivos $?m))
    (test (neq ?st DESCARTADO))
    (object (is-a Pareja) (edad_mas_anciano ?e&:(< ?e 40)))
    (not (Rasgo (objeto ?v) (caracteristica ZONA) (valor COMERCIAL)))
    (not (Rasgo (objeto ?v) (caracteristica ENTORNO) (valor RUIDOSO)))
    (test (not (member$ "Zona muy apagada para gente joven" $?m)))
    =>
    (modify ?r (estado PARCIALMENTE_ADECUADO) (motivos $?m "Zona muy apagada para gente joven"))
)

(defrule ASOCIACION::aviso-individuo-bajos
    ?r <- (Recomendacion (solicitante ?s) (vivienda ?v) (estado ?st) (motivos $?m))
    (test (neq ?st DESCARTADO))
    (object (is-a Individuo))
    (Rasgo (objeto ?v) (caracteristica TIPOLOGIA) (valor BAJOS))
    (test (not (member$ "Seguridad: Planta baja para vivir solo" $?m)))
    =>
    (modify ?r (estado PARCIALMENTE_ADECUADO) (motivos $?m "Seguridad: Planta baja para vivir solo"))
)

(defrule ASOCIACION::aviso-familia-abastecimiento
    ?r <- (Recomendacion (solicitante ?s) (vivienda ?v) (estado ?st) (motivos $?m))
    (test (neq ?st DESCARTADO))
    (object (is-a Familia))
    (not (Rasgo (objeto ?v) (caracteristica SERVICIOS) (valor ABASTECIMIENTO)))
    (test (not (member$ "Falta supermercado para compra familiar" $?m)))
    =>
    (modify ?r (estado PARCIALMENTE_ADECUADO) (motivos $?m "Falta supermercado para compra familiar"))
)

;;; RECOMENDACIONES (MUY RECOMENDABLE)

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
    (test (not (member$ "Conexion rapida Universidad" $?m)))
    =>
    (modify ?r (estado MUY_RECOMENDABLE) (motivos $?m "Conexion rapida Universidad"))
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

(defrule ASOCIACION::recomendar-pareja-atico
    ?r <- (Recomendacion (vivienda ?v) (estado ?st) (motivos $?m))
    (test (neq ?st DESCARTADO))
    (object (is-a Pareja))
    (Rasgo (objeto ?v) (caracteristica TIPOLOGIA) (valor ATICO))
    (test (not (member$ "Atico con terraza" $?m)))
    =>
    (modify ?r (estado MUY_RECOMENDABLE) (motivos $?m "Atico con terraza"))
)

(defrule ASOCIACION::recomendar-pareja-ocio
    ?r <- (Recomendacion (solicitante ?s) (vivienda ?v) (estado ?st) (motivos $?m))
    (test (neq ?st DESCARTADO))
    (object (is-a Pareja))
    (object (is-a Vivienda) (name ?v) (tiene_servicio_cercano $?servicios))
    (exists (object (is-a Cine) (name ?c)) (test (member$ ?c ?servicios)))
    (test (not (member$ "Ocio cultural cerca" $?m)))
    =>
    (modify ?r (estado MUY_RECOMENDABLE) (motivos $?m "Ocio cultural cerca"))
)

(defrule ASOCIACION::recomendar-anciano-servicios
    ?r <- (Recomendacion (solicitante ?s) (vivienda ?v) (estado ?st) (motivos $?m))
    (test (neq ?st DESCARTADO))
    (object (is-a Solicitante) (edad_mas_anciano ?e&:(> ?e 70)))
    (Rasgo (objeto ?v) (caracteristica SERVICIOS) (valor ABASTECIMIENTO))
    (test (not (member$ "Servicios basicos a pie" $?m)))
    =>
    (modify ?r (estado MUY_RECOMENDABLE) (motivos $?m "Servicios basicos a pie"))
)

(defrule ASOCIACION::validar-por-defecto
    (declare (salience -5))
    ?r <- (Recomendacion (estado INDETERMINADO))
    =>
    (modify ?r (estado VALID))
)

(defrule ASOCIACION::siguiente
    (declare (salience -10))
    ?f <- (ControlFase (fase ASOCIACION))
    =>
    (modify ?f (fase REFINAMIENTO))
    (focus REFINAMIENTO)
)

;;; =========================================================
;;; MÓDULO REFINAMIENTO
;;; =========================================================

(defrule REFINAMIENTO::base-muy-rec
    ?r <- (Recomendacion (estado MUY_RECOMENDABLE) (puntuacion ?p))
    => (modify ?r (puntuacion (+ ?p 100))))

(defrule REFINAMIENTO::base-valid
    ?r <- (Recomendacion (estado VALID) (puntuacion ?p))
    => (modify ?r (puntuacion (+ ?p 50))))

(defrule REFINAMIENTO::base-parcial
    ?r <- (Recomendacion (estado PARCIALMENTE_ADECUADO) (puntuacion ?p))
    => (modify ?r (puntuacion (+ ?p 10))))

(defrule REFINAMIENTO::bonus-ahorro-progresivo
    ?r <- (Recomendacion (vivienda ?v) (estado ?st) (puntuacion ?p) (motivos $?m))
    (test (neq ?st DESCARTADO))
    (object (is-a Solicitante) (presupuesto_maximo ?max))
    (object (is-a Vivienda) (name ?v) (precio_mensual ?pr))
    (test (< ?pr ?max))
    =>
    (bind ?ahorro (- ?max ?pr))
    (bind ?extra (div ?ahorro 10))
    (modify ?r (puntuacion (+ ?p ?extra)))
)

(defrule REFINAMIENTO::bonus-distancia-trabajo
    ?r <- (Recomendacion (vivienda ?v) (estado ?st) (puntuacion ?p) (motivos $?m))
    (test (neq ?st DESCARTADO))
    (object (is-a Solicitante) (trabaja_en_x ?tx) (trabaja_en_y ?ty))
    (object (is-a Vivienda) (name ?v) (coordx ?vx) (coordy ?vy))
    (test (neq ?tx nil))
    =>
    (bind ?dist (distancia ?tx ?ty ?vx ?vy))
    (if (< ?dist 1000) then
        (modify ?r (puntuacion (+ ?p 30)) (motivos $?m "Muy cerca del trabajo (<1km)"))
    else (if (< ?dist 3000) then
        (modify ?r (puntuacion (+ ?p 10)) (motivos $?m "Distancia razonable trabajo")))
    )
)

(defrule REFINAMIENTO::bonus-aire-acondicionado
    ?r <- (Recomendacion (vivienda ?v) (estado ?st) (puntuacion ?p))
    (test (neq ?st DESCARTADO))
    (object (is-a Vivienda) (name ?v) (tiene_aire_acondicionado TRUE))
    =>
    (modify ?r (puntuacion (+ ?p 10)))
)

(defrule REFINAMIENTO::bonus-amueblado
    ?r <- (Recomendacion (vivienda ?v) (estado ?st) (puntuacion ?p) (motivos $?m))
    (test (neq ?st DESCARTADO))
    (object (is-a Vivienda) (name ?v) (amueblado SI))
    =>
    (modify ?r (puntuacion (+ ?p 15)) (motivos $?m "Amueblado (listo para entrar)"))
)

(defrule REFINAMIENTO::bonus-terraza
    ?r <- (Recomendacion (vivienda ?v) (estado ?st) (puntuacion ?p))
    (test (neq ?st DESCARTADO))
    (object (is-a Vivienda) (name ?v) (tiene_terraza TRUE))
    =>
    (modify ?r (puntuacion (+ ?p 10)))
)

(defrule REFINAMIENTO::penalizacion-sin-ascensor
    ?r <- (Recomendacion (vivienda ?v) (estado ?st) (puntuacion ?p))
    (test (neq ?st DESCARTADO))
    (object (is-a Vivienda) (name ?v) (tiene_ascensor FALSE) (altura_piso ?h&:(> ?h 1)))
    =>
    (modify ?r (puntuacion (- ?p 15)))
)

(defrule REFINAMIENTO::penalizacion-conectividad-mala
    ?r <- (Recomendacion (vivienda ?v) (estado ?st) (puntuacion ?p))
    (test (neq ?st DESCARTADO))
    (Rasgo (objeto ?v) (caracteristica CONECTIVIDAD) (valor LENTA))
    =>
    (modify ?r (puntuacion (- ?p 10)))
)

(defrule REFINAMIENTO::penalizacion-general-oscuro
    ?r <- (Recomendacion (vivienda ?v) (estado ?st) (puntuacion ?p))
    (test (neq ?st DESCARTADO))
    (Rasgo (objeto ?v) (caracteristica LUMINOSIDAD) (valor OSCURO))
    =>
    (modify ?r (puntuacion (- ?p 15)))
)

(defrule REFINAMIENTO::bonus-ratio-banos
    ?r <- (Recomendacion (solicitante ?s) (vivienda ?v) (estado ?st) (puntuacion ?p) (motivos $?m))
    (test (neq ?st DESCARTADO))
    (object (is-a Solicitante) (num_personas ?np))
    (object (is-a Vivienda) (name ?v) (num_banos ?nb))
    (test (<= ?np (* ?nb 2))) 
    =>
    (modify ?r (puntuacion (+ ?p 10)) (motivos $?m "Buen ratio banos/personas"))
)

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
;;; MÓDULO INFORME
;;; =========================================================

(defrule INFORME::cabecera
    (declare (salience 100))
    =>
    (printout t crlf "========================================" crlf)
    (printout t "      INFORME DE RECOMENDACIONES        " crlf)
    (printout t "========================================" crlf crlf)
)

(defrule INFORME::imprimir-recomendacion
    ?r <- (Recomendacion (solicitante ?s) (vivienda ?v) (estado ?e) (puntuacion ?p) (motivos $?m))
    (test (neq ?e DESCARTADO))
    =>
    (printout t "SOLICITANTE: " ?s " >>> VIVIENDA: " ?v crlf)
    (printout t "   Estado: " ?e " (" ?p " pts)" crlf)
    (if (> (length$ $?m) 0) then (printout t "   Motivos: " (implode$ $?m) crlf))
    (printout t "----------------------------------------" crlf)
)

(defrule INFORME::fin
    (declare (salience -10))
    =>
    (printout t ">>> Proceso finalizado." crlf)
)