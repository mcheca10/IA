;;; =========================================================
;;; SISTEMA EXPERTO (VERSION UNIMODULAR - CORREGIDA FINAL)
;;; =========================================================

;;; 1. TEMPLATES (Todo en MAIN)
;;; ---------------------------------------------------------

(defmodule MAIN (export ?ALL))

(deftemplate MAIN::Recomendacion
    (slot solicitante (type INSTANCE-NAME)) 
    (slot vivienda (type INSTANCE-NAME))
    (slot estado (type SYMBOL) (allowed-values INDETERMINADO DESCARTADO PARCIALMENTE_ADECUADO ADECUADO MUY_RECOMENDABLE) (default INDETERMINADO))
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

;;; 2. REGLA DE INICIO
;;; ---------------------------------------------------------

(defrule MAIN::inicio-batch
    (declare (salience 100))
    =>
    (printout t ">>> INICIANDO SISTEMA..." crlf)
    (assert (ControlFase (fase ABSTRACCION)))
)

;;; =========================================================
;;; FASE 1: ABSTRACCION
;;; =========================================================

(defrule MAIN::abs-precio-impagable
    (ControlFase (fase ABSTRACCION))
    (object (is-a Solicitante) (presupuesto_maximo ?max))
    (object (is-a Vivienda) (name ?v) (precio_mensual ?p))
    (test (> ?p ?max))
    =>
    (assert (Rasgo (objeto ?v) (caracteristica COSTE) (valor IMPAGABLE)))
)

(defrule MAIN::abs-precio-chollo
    (ControlFase (fase ABSTRACCION))
    (object (is-a Solicitante) (presupuesto_maximo ?max))
    (object (is-a Vivienda) (name ?v) (precio_mensual ?p))
    (test (<= ?p (- ?max 200)))
    =>
    (assert (Rasgo (objeto ?v) (caracteristica COSTE) (valor CHOLLO)))
)

(defrule MAIN::abs-espacio-hacinado
    (ControlFase (fase ABSTRACCION))
    (object (is-a Solicitante) (num_personas ?np))
    (object (is-a Vivienda) (name ?v) (num_habs_dobles ?hd) (num_habs_individual ?hi))
    (test (> ?np (+ (* ?hd 2) ?hi)))
    =>
    (assert (Rasgo (objeto ?v) (caracteristica ESPACIO) (valor INSUFICIENTE)))
)

(defrule MAIN::abs-accesibilidad-mala
    (ControlFase (fase ABSTRACCION))
    (object (is-a Vivienda) (name ?v) (tiene_ascensor FALSE) (altura_piso ?h))
    (test (> ?h 0))
    =>
    (assert (Rasgo (objeto ?v) (caracteristica ACCESIBILIDAD) (valor MALA)))
)

(defrule MAIN::abs-servicios-educacion
    (ControlFase (fase ABSTRACCION))
    (object (is-a Vivienda) (name ?v) (tiene_servicio_cercano $?s))
    (exists (object (is-a Educacion) (name ?e)) (test (member$ ?e ?s)))
    =>
    (assert (Rasgo (objeto ?v) (caracteristica ENTORNO) (valor EDUCATIVO)))
)

(defrule MAIN::abs-servicios-ocio
    (ControlFase (fase ABSTRACCION))
    (object (is-a Vivienda) (name ?v) (tiene_servicio_cercano $?s))
    (exists (object (is-a Zona_Nocturna) (name ?zn)) (test (member$ ?zn ?s)))
    =>
    (assert (Rasgo (objeto ?v) (caracteristica ENTORNO) (valor RUIDOSO)))
)

(defrule MAIN::abs-servicios-relax
    (ControlFase (fase ABSTRACCION))
    (object (is-a Vivienda) (name ?v) (tiene_servicio_cercano $?s))
    (exists (object (is-a Zona_Verde) (name ?zv)) (test (member$ ?zv ?s)))
    =>
    (assert (Rasgo (objeto ?v) (caracteristica ENTORNO) (valor RELAX)))
)

(defrule MAIN::abs-mascotas
    (ControlFase (fase ABSTRACCION))
    (object (is-a Vivienda) (name ?v) (permite_mascotas FALSE))
    =>
    (assert (Rasgo (objeto ?v) (caracteristica POLITICA) (valor NO_MASCOTAS)))
)

(defrule MAIN::abs-luz-pobre
    (ControlFase (fase ABSTRACCION))
    (object (is-a Vivienda) (name ?v) (es_soleado "Nada"))
    =>
    (assert (Rasgo (objeto ?v) (caracteristica LUMINOSIDAD) (valor OSCURO)))
)

(defrule MAIN::abs-transporte-metro
    (ControlFase (fase ABSTRACCION))
    (object (is-a Vivienda) (name ?v) (tiene_servicio_cercano $?s))
    (exists (object (is-a Parada_Metro) (name ?m)) (test (member$ ?m ?s)))
    =>
    (assert (Rasgo (objeto ?v) (caracteristica CONECTIVIDAD) (valor RAPIDA)))
)

(defrule MAIN::abs-transporte-lento
    (ControlFase (fase ABSTRACCION))
    (object (is-a Vivienda) (name ?v) (tiene_servicio_cercano $?s))
    (exists (object (is-a Parada_Autobús) (name ?b)) (test (member$ ?b ?s)))
    (not (exists (object (is-a Parada_Metro) (name ?m)) (test (member$ ?m ?s))))
    =>
    (assert (Rasgo (objeto ?v) (caracteristica CONECTIVIDAD) (valor LENTA)))
)

(defrule MAIN::abs-zona-comercial
    (ControlFase (fase ABSTRACCION))
    (object (is-a Vivienda) (name ?v) (tiene_servicio_cercano $?s))
    (exists (object (is-a Supermercado) (name ?sup)) (test (member$ ?sup ?s)))
    =>
    (assert (Rasgo (objeto ?v) (caracteristica ZONA) (valor COMERCIAL)))
)

(defrule MAIN::abs-confort-bajo
    (ControlFase (fase ABSTRACCION))
    (object (is-a Vivienda) (name ?v) (tiene_calefaccion FALSE) (tiene_aire_acondicionado FALSE))
    =>
    (assert (Rasgo (objeto ?v) (caracteristica CONFORT) (valor BAJO)))
)

(defrule MAIN::abs-tipo-bajos
    (ControlFase (fase ABSTRACCION))
    (object (is-a Vivienda) (name ?v) (altura_piso 0))
    =>
    (assert (Rasgo (objeto ?v) (caracteristica TIPOLOGIA) (valor BAJOS)))
)

(defrule MAIN::abs-tipo-atico
    (ControlFase (fase ABSTRACCION))
    (object (is-a Vivienda) (name ?v) (tiene_terraza TRUE) (altura_piso ?h&:(> ?h 5)))
    =>
    (assert (Rasgo (objeto ?v) (caracteristica TIPOLOGIA) (valor ATICO)))
)

(defrule MAIN::abs-abastecimiento
    (ControlFase (fase ABSTRACCION))
    (object (is-a Vivienda) (name ?v) (tiene_servicio_cercano $?s))
    (exists (object (is-a Supermercado) (name ?sup)) (test (member$ ?sup ?s)))
    =>
    (assert (Rasgo (objeto ?v) (caracteristica SERVICIOS) (valor ABASTECIMIENTO)))
)

;;; CAMBIO DE FASE: ABSTRACCION -> ASOCIACION
(defrule MAIN::siguiente-fase-1
    (declare (salience -10))
    ?f <- (ControlFase (fase ABSTRACCION))
    =>
    (modify ?f (fase ASOCIACION))
)

;;; =========================================================
;;; FASE 2: ASOCIACION
;;; =========================================================

(defrule MAIN::init-recom
    (ControlFase (fase ASOCIACION))
    (object (is-a Solicitante) (name ?s))
    (object (is-a Vivienda) (name ?v))
    =>
    (assert (Recomendacion (solicitante ?s) (vivienda ?v) (estado INDETERMINADO)))
)

;;; RESTRICCIONES (DESCARTADO)

(defrule MAIN::filtrar-precio
    (ControlFase (fase ASOCIACION))
    ?r <- (Recomendacion (vivienda ?v) (estado INDETERMINADO))
    (Rasgo (objeto ?v) (caracteristica COSTE) (valor IMPAGABLE))
    =>
    (modify ?r (estado DESCARTADO) (motivos "Presupuesto insuficiente"))
)

(defrule MAIN::filtrar-espacio
    (ControlFase (fase ASOCIACION))
    ?r <- (Recomendacion (vivienda ?v) (estado INDETERMINADO))
    (Rasgo (objeto ?v) (caracteristica ESPACIO) (valor INSUFICIENTE))
    =>
    (modify ?r (estado DESCARTADO) (motivos "Faltan habitaciones"))
)

(defrule MAIN::filtrar-mascota
    (ControlFase (fase ASOCIACION))
    ?r <- (Recomendacion (vivienda ?v) (estado INDETERMINADO))
    (object (is-a Solicitante) (tiene_mascota TRUE))
    (Rasgo (objeto ?v) (caracteristica POLITICA) (valor NO_MASCOTAS))
    =>
    (modify ?r (estado DESCARTADO) (motivos "No admiten mascotas"))
)

(defrule MAIN::filtrar-accesibilidad
    (ControlFase (fase ASOCIACION))
    ?r <- (Recomendacion (vivienda ?v) (estado INDETERMINADO))
    (object (is-a Solicitante) (edad_mas_anciano ?e&:(> ?e 70)))
    (Rasgo (objeto ?v) (caracteristica ACCESIBILIDAD) (valor MALA))
    =>
    (modify ?r (estado DESCARTADO) (motivos "Inaccesible (Sin ascensor)"))
)

(defrule MAIN::filtrar-duplex
    (ControlFase (fase ASOCIACION))
    ?r <- (Recomendacion (vivienda ?v) (estado INDETERMINADO))
    (object (is-a Solicitante) (edad_mas_anciano ?e&:(> ?e 75)))
    (object (is-a Dúplex) (name ?v))
    =>
    (modify ?r (estado DESCARTADO) (motivos "Duplex peligroso"))
)

(defrule MAIN::filtrar-estudio-familia
    (ControlFase (fase ASOCIACION))
    ?r <- (Recomendacion (vivienda ?v) (estado INDETERMINADO))
    (object (is-a Familia) (num_personas ?np&:(> ?np 3)))
    (object (is-a Vivienda) (name ?v) (num_habs_dobles 0))
    =>
    (modify ?r (estado DESCARTADO) (motivos "Estudio inviable para familia"))
)

;;; AVISOS (PARCIALMENTE_ADECUADO)

(defrule MAIN::aviso-oscuridad
    (ControlFase (fase ASOCIACION))
    ?r <- (Recomendacion (vivienda ?v) (estado ?st) (motivos $?m))
    (test (neq ?st DESCARTADO))
    (object (is-a Solicitante) (trabaja_en_casa TRUE))
    (Rasgo (objeto ?v) (caracteristica LUMINOSIDAD) (valor OSCURO))
    (test (not (member$ "Poca luz" $?m)))
    =>
    (modify ?r (estado PARCIALMENTE_ADECUADO) (motivos $?m "Poca luz"))
)

(defrule MAIN::aviso-ruido
    (ControlFase (fase ASOCIACION))
    ?r <- (Recomendacion (vivienda ?v) (estado ?st) (motivos $?m))
    (test (neq ?st DESCARTADO))
    (object (is-a Solicitante) (edad_mas_anciano ?e&:(> ?e 60)))
    (Rasgo (objeto ?v) (caracteristica ENTORNO) (valor RUIDOSO))
    (test (not (member$ "Ruidoso" $?m)))
    =>
    (modify ?r (estado PARCIALMENTE_ADECUADO) (motivos $?m "Ruidoso"))
)

(defrule MAIN::aviso-bajos
    (ControlFase (fase ASOCIACION))
    ?r <- (Recomendacion (vivienda ?v) (estado ?st) (motivos $?m))
    (test (neq ?st DESCARTADO))
    (object (is-a Familia))
    (Rasgo (objeto ?v) (caracteristica TIPOLOGIA) (valor BAJOS))
    (test (not (member$ "Bajos sin intimidad" $?m)))
    =>
    (modify ?r (estado PARCIALMENTE_ADECUADO) (motivos $?m "Bajos sin intimidad"))
)

(defrule MAIN::aviso-parking
    (ControlFase (fase ASOCIACION))
    ?r <- (Recomendacion (vivienda ?v) (estado ?st) (motivos $?m))
    (test (neq ?st DESCARTADO))
    (object (is-a Solicitante) (tiene_coche TRUE))
    (test (neq (class ?v) Unifamiliar))
    (not (Rasgo (objeto ?v) (caracteristica ZONA) (valor COMERCIAL)))
    (test (not (member$ "Dificil aparcar" $?m)))
    =>
    (modify ?r (estado PARCIALMENTE_ADECUADO) (motivos $?m "Dificil aparcar"))
)

(defrule MAIN::aviso-supermercado
    (ControlFase (fase ASOCIACION))
    ?r <- (Recomendacion (solicitante ?s) (vivienda ?v) (estado ?st) (motivos $?m))
    (test (neq ?st DESCARTADO))
    (object (is-a Familia))
    (not (Rasgo (objeto ?v) (caracteristica SERVICIOS) (valor ABASTECIMIENTO)))
    (test (not (member$ "Falta super" $?m)))
    =>
    (modify ?r (estado PARCIALMENTE_ADECUADO) (motivos $?m "Falta super"))
)

;;; BONUS (MUY_RECOMENDABLE)

(defrule MAIN::rec-cole
    (ControlFase (fase ASOCIACION))
    ?r <- (Recomendacion (vivienda ?v) (estado ?st) (motivos $?m))
    (test (neq ?st DESCARTADO))
    (object (is-a Familia))
    (Rasgo (objeto ?v) (caracteristica ENTORNO) (valor EDUCATIVO))
    (test (not (member$ "Colegios cerca" $?m)))
    =>
    (modify ?r (estado MUY_RECOMENDABLE) (motivos $?m "Colegios cerca"))
)

(defrule MAIN::rec-fiesta
    (ControlFase (fase ASOCIACION))
    ?r <- (Recomendacion (vivienda ?v) (estado ?st) (motivos $?m))
    (test (neq ?st DESCARTADO))
    (object (is-a Estudiantes))
    (Rasgo (objeto ?v) (caracteristica ENTORNO) (valor RUIDOSO))
    (test (not (member$ "Ambiente" $?m)))
    =>
    (modify ?r (estado MUY_RECOMENDABLE) (motivos $?m "Ambiente"))
)

(defrule MAIN::rec-metro
    (ControlFase (fase ASOCIACION))
    ?r <- (Recomendacion (vivienda ?v) (estado ?st) (motivos $?m))
    (test (neq ?st DESCARTADO))
    (object (is-a Estudiantes))
    (Rasgo (objeto ?v) (caracteristica CONECTIVIDAD) (valor RAPIDA))
    (test (not (member$ "Metro cerca" $?m)))
    =>
    (modify ?r (estado MUY_RECOMENDABLE) (motivos $?m "Metro cerca"))
)

(defrule MAIN::rec-relax
    (ControlFase (fase ASOCIACION))
    ?r <- (Recomendacion (vivienda ?v) (estado ?st) (motivos $?m))
    (test (neq ?st DESCARTADO))
    (object (is-a Solicitante) (edad_mas_anciano ?e&:(> ?e 65)))
    (Rasgo (objeto ?v) (caracteristica ENTORNO) (valor RELAX))
    (test (not (member$ "Zona tranquila" $?m)))
    =>
    (modify ?r (estado MUY_RECOMENDABLE) (motivos $?m "Zona tranquila"))
)

(defrule MAIN::rec-chollo
    (ControlFase (fase ASOCIACION))
    ?r <- (Recomendacion (vivienda ?v) (estado ?st) (motivos $?m))
    (test (neq ?st DESCARTADO))
    (Rasgo (objeto ?v) (caracteristica COSTE) (valor CHOLLO))
    (test (not (member$ "Gran precio" $?m)))
    =>
    (modify ?r (estado MUY_RECOMENDABLE) (motivos $?m "Gran precio"))
)

(defrule MAIN::rec-atico
    (ControlFase (fase ASOCIACION))
    ?r <- (Recomendacion (vivienda ?v) (estado ?st) (motivos $?m))
    (test (neq ?st DESCARTADO))
    (object (is-a Pareja))
    (Rasgo (objeto ?v) (caracteristica TIPOLOGIA) (valor ATICO))
    (test (not (member$ "Atico" $?m)))
    =>
    (modify ?r (estado MUY_RECOMENDABLE) (motivos $?m "Atico"))
)

(defrule MAIN::rec-ocio
    (ControlFase (fase ASOCIACION))
    ?r <- (Recomendacion (solicitante ?s) (vivienda ?v) (estado ?st) (motivos $?m))
    (test (neq ?st DESCARTADO))
    (object (is-a Pareja))
    (object (is-a Vivienda) (name ?v) (tiene_servicio_cercano $?servs))
    (exists (object (is-a Cine) (name ?c)) (test (member$ ?c ?servs)))
    (test (not (member$ "Cine cerca" $?m)))
    =>
    (modify ?r (estado MUY_RECOMENDABLE) (motivos $?m "Cine cerca"))
)

(defrule MAIN::rec-servicios-anciano
    (ControlFase (fase ASOCIACION))
    ?r <- (Recomendacion (solicitante ?s) (vivienda ?v) (estado ?st) (motivos $?m))
    (test (neq ?st DESCARTADO))
    (object (is-a Solicitante) (edad_mas_anciano ?e&:(> ?e 70)))
    (Rasgo (objeto ?v) (caracteristica SERVICIOS) (valor ABASTECIMIENTO))
    (test (not (member$ "Servicios a pie" $?m)))
    =>
    (modify ?r (estado MUY_RECOMENDABLE) (motivos $?m "Servicios a pie"))
)

;;; LIMPIEZA
(defrule MAIN::limpieza-default
    (declare (salience -5))
    (ControlFase (fase ASOCIACION))
    ?r <- (Recomendacion (estado INDETERMINADO))
    =>
    (modify ?r (estado ADECUADO))
)

;;; CAMBIO DE FASE: ASOCIACION -> REFINAMIENTO
(defrule MAIN::siguiente-fase-2
    (declare (salience -10))
    ?f <- (ControlFase (fase ASOCIACION))
    =>
    (modify ?f (fase REFINAMIENTO))
)

;;; =========================================================
;;; FASE 3: REFINAMIENTO
;;; =========================================================

(defrule MAIN::base-puntos-rec
    (ControlFase (fase REFINAMIENTO))
    ?r <- (Recomendacion (estado MUY_RECOMENDABLE) (puntuacion ?p))
    => (modify ?r (puntuacion (+ ?p 100)))
)

(defrule MAIN::base-puntos-adecuado
    (ControlFase (fase REFINAMIENTO))
    ?r <- (Recomendacion (estado ADECUADO) (puntuacion ?p))
    => (modify ?r (puntuacion (+ ?p 50)))
)

(defrule MAIN::base-puntos-parcial
    (ControlFase (fase REFINAMIENTO))
    ?r <- (Recomendacion (estado PARCIALMENTE_ADECUADO) (puntuacion ?p))
    => (modify ?r (puntuacion (+ ?p 10)))
)

(defrule MAIN::ref-ahorro
    (ControlFase (fase REFINAMIENTO))
    ?r <- (Recomendacion (vivienda ?v) (estado ?st) (puntuacion ?p))
    (test (neq ?st DESCARTADO))
    (object (is-a Solicitante) (presupuesto_maximo ?max))
    (object (is-a Vivienda) (name ?v) (precio_mensual ?pr))
    (test (< ?pr ?max))
    =>
    (bind ?ahorro (- ?max ?pr))
    (bind ?extra (div ?ahorro 10))
    (modify ?r (puntuacion (+ ?p ?extra)))
)

(defrule MAIN::ref-distancia
    (ControlFase (fase REFINAMIENTO))
    ?r <- (Recomendacion (vivienda ?v) (estado ?st) (puntuacion ?p) (motivos $?m))
    (test (neq ?st DESCARTADO))
    (object (is-a Solicitante) (trabaja_en_x ?tx) (trabaja_en_y ?ty))
    (object (is-a Vivienda) (name ?v) (coordx ?vx) (coordy ?vy))
    (test (neq ?tx nil))
    =>
    (bind ?dist (distancia ?tx ?ty ?vx ?vy))
    (if (< ?dist 1000) then
        (modify ?r (puntuacion (+ ?p 30)) (motivos $?m "Muy cerca trabajo"))
    else (if (< ?dist 3000) then
        (modify ?r (puntuacion (+ ?p 10)) (motivos $?m "Cerca trabajo")))
    )
)

(defrule MAIN::ref-aire
    (ControlFase (fase REFINAMIENTO))
    ?r <- (Recomendacion (vivienda ?v) (estado ?st) (puntuacion ?p))
    (test (neq ?st DESCARTADO))
    (object (is-a Vivienda) (name ?v) (tiene_aire_acondicionado TRUE))
    =>
    (modify ?r (puntuacion (+ ?p 10)))
)

(defrule MAIN::ref-amueblado
    (ControlFase (fase REFINAMIENTO))
    ?r <- (Recomendacion (vivienda ?v) (estado ?st) (puntuacion ?p) (motivos $?m))
    (test (neq ?st DESCARTADO))
    (object (is-a Vivienda) (name ?v) (amueblado SI))
    =>
    (modify ?r (puntuacion (+ ?p 15)) (motivos $?m "Amueblado"))
)

(defrule MAIN::ref-terraza
    (ControlFase (fase REFINAMIENTO))
    ?r <- (Recomendacion (vivienda ?v) (estado ?st) (puntuacion ?p))
    (test (neq ?st DESCARTADO))
    (object (is-a Vivienda) (name ?v) (tiene_terraza TRUE))
    =>
    (modify ?r (puntuacion (+ ?p 10)))
)

(defrule MAIN::ref-sin-ascensor
    (ControlFase (fase REFINAMIENTO))
    ?r <- (Recomendacion (vivienda ?v) (estado ?st) (puntuacion ?p))
    (test (neq ?st DESCARTADO))
    (object (is-a Vivienda) (name ?v) (tiene_ascensor FALSE) (altura_piso ?h&:(> ?h 1)))
    =>
    (modify ?r (puntuacion (- ?p 15)))
)

(defrule MAIN::ref-conectividad-mala
    (ControlFase (fase REFINAMIENTO))
    ?r <- (Recomendacion (vivienda ?v) (estado ?st) (puntuacion ?p))
    (test (neq ?st DESCARTADO))
    (Rasgo (objeto ?v) (caracteristica CONECTIVIDAD) (valor LENTA))
    =>
    (modify ?r (puntuacion (- ?p 10)))
)

(defrule MAIN::ref-oscuro
    (ControlFase (fase REFINAMIENTO))
    ?r <- (Recomendacion (vivienda ?v) (estado ?st) (puntuacion ?p))
    (test (neq ?st DESCARTADO))
    (Rasgo (objeto ?v) (caracteristica LUMINOSIDAD) (valor OSCURO))
    =>
    (modify ?r (puntuacion (- ?p 15)))
)

(defrule MAIN::ref-calefaccion
    (ControlFase (fase REFINAMIENTO))
    ?r <- (Recomendacion (vivienda ?v) (estado ?st) (puntuacion ?p))
    (test (neq ?st DESCARTADO))
    (object (is-a Vivienda) (name ?v) (tiene_calefaccion SI))
    =>
    (modify ?r (puntuacion (+ ?p 5)))
)

;;; CAMBIO DE FASE: REFINAMIENTO -> INFORME
(defrule MAIN::siguiente-fase-3
    (declare (salience -10))
    ?f <- (ControlFase (fase REFINAMIENTO))
    =>
    (modify ?f (fase INFORME))
)

;;; =========================================================
;;; FASE 4: INFORME
;;; =========================================================

(defrule MAIN::informe-cabecera
    (declare (salience 100))
    (ControlFase (fase INFORME))
    =>
    (printout t crlf "--- INFORME FINAL ---" crlf)
)

(defrule MAIN::informe-print
    (ControlFase (fase INFORME))
    ?r <- (Recomendacion (solicitante ?s) (vivienda ?v) (estado ?e) (puntuacion ?p) (motivos $?m))
    (test (neq ?e DESCARTADO))
    =>
    (printout t "SOLICITANTE: " ?s " -> VIVIENDA: " ?v crlf)
    (printout t " Estado: " ?e " (" ?p " pts)" crlf)
    (if (> (length$ $?m) 0) then (printout t " Motivos: " (implode$ $?m) crlf))
    (printout t "--------------------------" crlf)
)

(defrule MAIN::informe-fin
    (declare (salience -10))
    (ControlFase (fase INFORME))
    =>
    (printout t ">>> FIN EJECUCION." crlf)
)