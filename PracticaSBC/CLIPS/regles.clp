;;; =========================================================
;;; SISTEMA DE RECOMENDACIÓN DE VIVIENDA
;;; Esta version es un prototipo de la version final, en la que se le pide al usuario el perfil del solicitante
;;; y se le muestra una lista de viviendas que cumplen con sus requisitos
;;; =========================================================

(defmodule MAIN (export ?ALL))

(deftemplate MAIN::Recomendacion
    (slot solicitante (type INSTANCE-NAME)) 
    (slot vivienda (type INSTANCE-NAME))
    (slot estado (type SYMBOL) (allowed-values VALID DESCARTADO PARCIALMENTE_ADECUADO MUY_RECOMENDABLE))
    (multislot motivos (type STRING))
)

(deftemplate MAIN::ControlFase
    (slot fase (type SYMBOL))
)

(deffunction MAIN::distancia (?x1 ?y1 ?x2 ?y2)
   (sqrt (+ (* (- ?x2 ?x1) (- ?x2 ?x1)) (* (- ?y2 ?y1) (- ?y2 ?y1))))
)

;;; MÓDULOS
(defmodule DEDUCCION (import MAIN ?ALL) (export ?ALL))
(defmodule GENERACION (import MAIN ?ALL) (export ?ALL))
(defmodule FILTRADO (import MAIN ?ALL) (export ?ALL))    
(defmodule REQUISITOS (import MAIN ?ALL) (export ?ALL))  
(defmodule EXTRAS (import MAIN ?ALL) (export ?ALL))      
(defmodule INFORME (import MAIN ?ALL) (export ?ALL))     

(defrule MAIN::inicio
    =>
    (printout t "--- Iniciando Sistema Inmobiliario ---" crlf)
    (assert (ControlFase (fase DEDUCCION)))
    (focus DEDUCCION)
)

;;; =========================================================
;;; MÓDULO DEDUCCION
;;; =========================================================

(defrule DEDUCCION::detectar-servicios-cercanos
    ?v <- (object (is-a Vivienda) (coordx ?vx) (coordy ?vy) (tiene_servicio_cercano $?lista))
    (object (is-a Servicio) (name ?s) (servicio_en_x ?sx) (servicio_en_y ?sy))
    
    (test (< (distancia ?vx ?vy ?sx ?sy) 500))
    (test (not (member$ ?s ?lista)))
    =>
    (slot-insert$ ?v tiene_servicio_cercano 1 ?s)
)

(defrule DEDUCCION::paso-a-generacion
    (declare (salience -10))
    ?c <- (ControlFase (fase DEDUCCION))
    =>
    (modify ?c (fase GENERACION))
    (focus GENERACION)
)

;;; =========================================================
;;; MÓDULO GENERACIÓN
;;; =========================================================

(defrule GENERACION::generar-candidatos-inteligente
    (object (is-a Solicitante) (name ?s) (busca_vivienda $?tipos_buscados))
    (object (is-a Vivienda) (name ?v))
    
    (test (or (eq (length$ $?tipos_buscados) 0)
              (member$ (class ?v) $?tipos_buscados)))
    =>
    (assert (Recomendacion (solicitante ?s) (vivienda ?v) (estado VALID) (motivos)))
)

(defrule GENERACION::generar-candidatos-tipo-incorrecto
    (object (is-a Solicitante) (name ?s) (busca_vivienda $?tipos_buscados))
    (object (is-a Vivienda) (name ?v))
    
    (test (and (> (length$ $?tipos_buscados) 0)
               (not (member$ (class ?v) $?tipos_buscados))))
    =>
    (assert (Recomendacion (solicitante ?s) (vivienda ?v) 
                           (estado DESCARTADO) 
                           (motivos "Tipo de vivienda no coincide con lo buscado")))
)

(defrule GENERACION::paso-a-filtrado
    (declare (salience -10))
    ?c <- (ControlFase (fase GENERACION))
    =>
    (modify ?c (fase FILTRADO))
    (focus FILTRADO)
)

;;; =========================================================
;;; MÓDULO FILTRADO (Restricciones Duras -> DESCARTADO)
;;; =========================================================


;;; redundante ya que la generacion inteligente ya filtra por tipo
(defrule FILTRADO::tipo-incorrecto
    ?r <- (Recomendacion (solicitante ?s) (vivienda ?v) (estado VALID))
    (object (is-a Solicitante) (name ?s) (busca_vivienda $?tipos))
    (object (is-a Vivienda) (name ?v))
    ;; Si la lista de buscados no está vacía Y la clase de la casa no está en la lista
    (test (and (> (length$ $?tipos) 0) 
               (not (member$ (class ?v) $?tipos))))
    =>
    (modify ?r (estado DESCARTADO) (motivos "Tipo de vivienda no coincide con lo buscado"))
)

(defrule FILTRADO::superficie-insuficiente
    ?r <- (Recomendacion (solicitante ?s) (vivienda ?v) (estado VALID))
    (object (is-a Solicitante) (name ?s) (superficie_minima ?min))
    (object (is-a Vivienda) (name ?v) (superficie ?sup))
    (test (< ?sup ?min))
    =>
    (modify ?r (estado DESCARTADO) (motivos (str-cat "Superficie insuficiente (<" ?min "m2)")))
)

(defrule FILTRADO::mascotas-prohibidas
    ?r <- (Recomendacion (solicitante ?s) (vivienda ?v) (estado VALID))
    (object (is-a Solicitante) (name ?s) (tiene_mascota TRUE))
    (object (is-a Vivienda) (name ?v) (permite_mascotas FALSE))
    =>
    (modify ?r (estado DESCARTADO) (motivos "Tiene mascota y la vivienda no las admite"))
)

(defrule FILTRADO::accesibilidad-ascensor
    ?r <- (Recomendacion (solicitante ?s) (vivienda ?v) (estado VALID))
    (object (is-a Solicitante) (name ?s) (movilidad_reducida ?mov) (edad_mas_anciano ?edad))
    (test (or (eq ?mov TRUE) (> ?edad 60)))
    (object (is-a Vivienda) (name ?v) (tiene_ascensor FALSE) (altura_piso ?altura))
    (test (> ?altura 0))
    =>
    (modify ?r (estado DESCARTADO) (motivos "Inaccesible: Sin ascensor para perfil vulnerable"))
)

(defrule FILTRADO::duplex-inviable-movilidad
    ?r <- (Recomendacion (solicitante ?s) (vivienda ?v) (estado VALID))
    (object (is-a Solicitante) (name ?s) (movilidad_reducida TRUE))
    (object (is-a Dúplex) (name ?v)) ;; Dúplex implica escaleras internas
    =>
    (modify ?r (estado DESCARTADO) (motivos "Inviable: Dúplex tiene escaleras internas (movilidad reducida)"))
)

(defrule FILTRADO::presupuesto-estricto
    ?r <- (Recomendacion (solicitante ?s) (vivienda ?v) (estado VALID))
    (object (is-a Solicitante) (name ?s) (presupuesto_flexible FALSE) (presupuesto_maximo ?max))
    (object (is-a Vivienda) (name ?v) (precio_mensual ?precio))
    (test (> ?precio ?max))
    =>
    (modify ?r (estado DESCARTADO) (motivos "Precio supera presupuesto estricto"))
)

(defrule FILTRADO::presupuesto-flexible-limite-absoluto
    ?r <- (Recomendacion (solicitante ?s) (vivienda ?v) (estado VALID))
    (object (is-a Solicitante) (name ?s) (presupuesto_flexible TRUE) (presupuesto_maximo ?max))
    (object (is-a Vivienda) (name ?v) (precio_mensual ?precio))
    (test (> ?precio (+ ?max 100)))
    =>
    (modify ?r (estado DESCARTADO) (motivos "Precio excesivo (supera margen de +100)"))
)

(defrule FILTRADO::capacidad-fisica
    ?r <- (Recomendacion (solicitante ?s) (vivienda ?v) (estado VALID))
    (object (is-a Solicitante) (name ?s) (num_personas ?np))
    (object (is-a Vivienda) (name ?v) (num_habs_dobles ?hd) (num_habs_individual ?hi))
    (test (> ?np (+ (* ?hd 2) ?hi)))
    =>
    (modify ?r (estado DESCARTADO) (motivos "Faltan camas para las personas"))
)

(defrule FILTRADO::teletrabajo-oscuridad-total
    ?r <- (Recomendacion (solicitante ?s) (vivienda ?v) (estado VALID))
    (object (is-a Solicitante) (name ?s) (trabaja_en_casa TRUE))
    (object (is-a Vivienda) (name ?v) (es_soleado "Nada"))
    =>
    (modify ?r (estado DESCARTADO) (motivos "Salud laboral: Piso interior sin luz natural para teletrabajo"))
)

(defrule FILTRADO::paso-a-requisitos
    (declare (salience -10))
    ?c <- (ControlFase (fase FILTRADO))
    =>
    (modify ?c (fase REQUISITOS))
    (focus REQUISITOS)
)

;;; =========================================================
;;; MÓDULO REQUISITOS (Restricciones Suaves -> PARCIALMENTE)
;;; =========================================================

(defrule REQUISITOS::preferencia-cercania-no-cumplida
    ?r <- (Recomendacion (solicitante ?s) (vivienda ?v) (estado ?st) (motivos $?m))
    (object (is-a Solicitante) (name ?s) (prefiere_cerca $? ?clase_servicio $?))
    (object (is-a Vivienda) (name ?v) (tiene_servicio_cercano $?servicios_casa))
    (not (exists (object (name ?s_cerca) (is-a ?clase_servicio))
                 (test (member$ ?s_cerca ?servicios_casa))))
    (test (neq ?st DESCARTADO))
    (test (not (member$ (str-cat "Falta servicio preferido: " ?clase_servicio) ?m)))
    =>
    (modify ?r (estado PARCIALMENTE_ADECUADO) 
               (motivos $?m (str-cat "Falta servicio preferido: " ?clase_servicio)))
)

(defrule REQUISITOS::vulnerable-sin-calefaccion
    ?r <- (Recomendacion (solicitante ?s) (vivienda ?v) (estado ?st) (motivos $?m))
    (object (is-a Vivienda) (name ?v) (tiene_calefaccion NO))
    (or (object (is-a Solicitante) (name ?s) (edad_mas_anciano ?e&:(> ?e 65)))
        (object (is-a Familia) (name ?s) (edad_hijo_menor ?h&:(< ?h 5))))
    (test (neq ?st DESCARTADO))
    (test (not (member$ "Riesgo salud: Sin calefaccion para vulnerables" ?m)))
    =>
    (modify ?r (estado PARCIALMENTE_ADECUADO) 
               (motivos $?m "Riesgo salud: Sin calefaccion para vulnerables"))
)

(defrule REQUISITOS::cola-en-el-bano
    ?r <- (Recomendacion (solicitante ?s) (vivienda ?v) (estado ?st) (motivos $?m))
    (object (is-a Solicitante) (name ?s) (num_personas ?np))
    (object (is-a Vivienda) (name ?v) (num_banos ?nb))
    (test (> (/ ?np ?nb) 3))
    (test (neq ?st DESCARTADO))
    (test (not (member$ "Problema convivencia: Pocos banos para tanta gente" ?m)))
    =>
    (modify ?r (estado PARCIALMENTE_ADECUADO) 
               (motivos $?m "Problema convivencia: Pocos banos para tanta gente"))
)

(defrule REQUISITOS::precio-inferior-al-minimo
    ?r <- (Recomendacion (solicitante ?s) (vivienda ?v) (estado ?st) (motivos $?m))
    (object (is-a Solicitante) (name ?s) (precio_minimo ?min))
    (object (is-a Vivienda) (name ?v) (precio_mensual ?precio))
    (test (< ?precio ?min))
    (test (neq ?st DESCARTADO))
    (test (not (member$ "Precio sospechosamente barato (< minimo usuario)" ?m)))
    =>
    (modify ?r (estado PARCIALMENTE_ADECUADO) 
               (motivos $?m "Precio sospechosamente barato (< minimo usuario)"))
)

(defrule REQUISITOS::precio-sospechoso
    ?r <- (Recomendacion (solicitante ?s) (vivienda ?v) (estado ?st) (motivos $?m))
    (object (is-a Solicitante) (name ?s))
    (object (is-a Vivienda) (name ?v) (precio_mensual ?precio))
    (test (< ?precio 400)) 
    (test (neq ?st DESCARTADO))
    (test (not (member$ "Precio sospechosamente bajo (<400)" ?m)))
    =>
    (modify ?r (estado PARCIALMENTE_ADECUADO) 
               (motivos $?m "Precio sospechosamente bajo (<400)"))
)

(defrule REQUISITOS::evitar-ruido-nocturno
    ?r <- (Recomendacion (solicitante ?s) (vivienda ?v) (estado ?st) (motivos $?m))
    (object (is-a Solicitante) (name ?s) (edad_mas_anciano ?edad))
    (test (or (> ?edad 50) (eq (class ?s) Familia)))
    (object (is-a Vivienda) (name ?v) (tiene_servicio_cercano $?servicios))
    (exists (object (is-a Zona_Nocturna) (name ?zn))
            (test (member$ ?zn ?servicios)))
    (test (neq ?st DESCARTADO))
    (test (not (member$ "Demasiado cerca de zona de ocio (ruido)" ?m)))
    =>
    (modify ?r (estado PARCIALMENTE_ADECUADO) 
               (motivos $?m "Demasiado cerca de zona de ocio (ruido)"))
)

(defrule REQUISITOS::anciano-sin-super
    ?r <- (Recomendacion (solicitante ?s) (vivienda ?v) (estado ?st) (motivos $?m))
    (object (is-a Solicitante) (name ?s) (edad_mas_anciano ?edad))
    (test (> ?edad 65))
    (object (is-a Vivienda) (name ?v) (tiene_servicio_cercano $?servicios))
    (not (exists (object (is-a Supermercado) (name ?super))
                 (test (member$ ?super ?servicios))))
    (test (neq ?st DESCARTADO))
    (test (not (member$ "Falta supermercado cerca (importante ancianos)" ?m)))
    =>
    (modify ?r (estado PARCIALMENTE_ADECUADO) 
               (motivos $?m "Falta supermercado cerca (importante ancianos)"))
)

(defrule REQUISITOS::coche-sin-parking
    ?r <- (Recomendacion (solicitante ?s) (vivienda ?v) (estado ?st) (motivos $?m))
    (object (is-a Solicitante) (name ?s) (tiene_coche TRUE))
    (object (is-a Vivienda) (name ?v) (altura_piso ?h))
    (test (> ?h 0)) 
    (test (neq (class ?v) Unifamiliar))
    (test (neq ?st DESCARTADO))
    (test (not (member$ "Dificil aparcar (Piso sin garaje explicito)" ?m)))
    =>
    (modify ?r (estado PARCIALMENTE_ADECUADO) 
               (motivos $?m "Dificil aparcar (Piso sin garaje explicito)"))
)

(defrule REQUISITOS::presupuesto-flexible-margen
    ?r <- (Recomendacion (solicitante ?s) (vivienda ?v) (estado ?st) (motivos $?m))
    (object (is-a Solicitante) (name ?s) (presupuesto_flexible TRUE) (presupuesto_maximo ?max))
    (object (is-a Vivienda) (name ?v) (precio_mensual ?precio))
    (test (> ?precio ?max))
    (test (<= ?precio (+ ?max 100))) 
    (test (neq ?st DESCARTADO))
    (test (not (member$ "Precio ajustado: Supera presupuesto flexible" ?m)))
    =>
    (modify ?r (estado PARCIALMENTE_ADECUADO) 
               (motivos $?m "Precio ajustado: Supera presupuesto flexible"))
)

(defrule REQUISITOS::trabajo-lejos
    ?r <- (Recomendacion (solicitante ?s) (vivienda ?v) (estado ?st) (motivos $?m))
    (object (is-a Solicitante) (name ?s) (trabaja_en_x ?tx) (trabaja_en_y ?ty) (trabaja_en_casa FALSE))
    (object (is-a Vivienda) (name ?v) (coordx ?vx) (coordy ?vy))
    (test (neq ?st DESCARTADO))
    (test (> (distancia ?tx ?ty ?vx ?vy) 2000))
    (test (not (member$ "Lejos del trabajo (>2km)" ?m)))
    =>
    (modify ?r (estado PARCIALMENTE_ADECUADO) 
               (motivos $?m "Lejos del trabajo (>2km)"))
)

(defrule REQUISITOS::estudiante-sin-metro
    ?r <- (Recomendacion (solicitante ?s) (vivienda ?v) (estado ?st) (motivos $?m))
    (object (is-a Estudiantes) (name ?s))
    (object (is-a Vivienda) (name ?v) (tiene_servicio_cercano $?servicios))
    (not (exists (object (is-a Parada_Metro) (name ?metro))
                 (test (member$ ?metro ?servicios))))
    (test (neq ?st DESCARTADO))
    (test (not (member$ "Falta transporte publico cercano" ?m)))
    =>
    (modify ?r (estado PARCIALMENTE_ADECUADO) 
               (motivos $?m "Falta transporte publico cercano"))
)

(defrule REQUISITOS::familia-sin-parque
    ?r <- (Recomendacion (solicitante ?s) (vivienda ?v) (estado ?st) (motivos $?m))
    (object (is-a Familia) (name ?s))
    (object (is-a Vivienda) (name ?v) (tiene_servicio_cercano $?servicios))
    (not (exists (object (is-a Zona_Verde) (name ?parque))
                 (test (member$ ?parque ?servicios))))
    (test (neq ?st DESCARTADO))
    (test (not (member$ "No hay zonas verdes cerca" ?m)))
    =>
    (modify ?r (estado PARCIALMENTE_ADECUADO) 
               (motivos $?m "No hay zonas verdes cerca"))
)

(defrule REQUISITOS::mascota-sin-espacio-exterior
   ?r <- (Recomendacion (solicitante ?s) (vivienda ?v) (estado ?st) (motivos $?m))
   (object (is-a Solicitante) (name ?s) (tiene_mascota TRUE))
   (object (is-a Vivienda) (name ?v) (tiene_terraza FALSE))
   ;; COMPROBACIÓN CORRECTA: Miramos si la clase NO es Unifamiliar
   (test (neq (class ?v) Unifamiliar))
   (test (neq ?st DESCARTADO))
   (test (not (member$ "Mascota: Falta terraza o jardín" ?m)))
   =>
   (modify ?r (estado PARCIALMENTE_ADECUADO) 
              (motivos $?m "Mascota: Falta terraza o jardín"))
)

(defrule REQUISITOS::estudiantes-zona-aburrida
    ?r <- (Recomendacion (solicitante ?s) (vivienda ?v) (estado ?st) (motivos $?m))
    (object (is-a Estudiantes) (name ?s))
    (object (is-a Vivienda) (name ?v) (tiene_servicio_cercano $?servicios))
    (not (exists (object (is-a Zona_Nocturna) (name ?zn)) (test (member$ ?zn ?servicios))))
    (not (exists (object (is-a Cine) (name ?ci)) (test (member$ ?ci ?servicios))))
    (test (neq ?st DESCARTADO))
    (test (not (member$ "Zona poco animada para estudiantes (sin ocio cerca)" ?m)))
    =>
    (modify ?r (estado PARCIALMENTE_ADECUADO) 
               (motivos $?m "Zona poco animada para estudiantes (sin ocio cerca)"))
)

(defrule REQUISITOS::pareja-teletrabajo-espacio
    ?r <- (Recomendacion (solicitante ?s) (vivienda ?v) (estado ?st) (motivos $?m))
    (object (is-a Pareja) (name ?s) (trabaja_en_casa TRUE))
    (object (is-a Vivienda) (name ?v) (num_habs_individual 0) (num_habs_dobles 1)) 
    ;; Solo tienen el dormitorio, no hay despacho extra
    (test (neq ?st DESCARTADO))
    (test (not (member$ "Espacio: Falta habitación extra para despacho" ?m)))
    =>
    (modify ?r (estado PARCIALMENTE_ADECUADO) 
               (motivos $?m "Espacio: Falta habitación extra para despacho"))
)

(defrule REQUISITOS::lejos-pediatra
    ?r <- (Recomendacion (solicitante ?s) (vivienda ?v) (estado ?st) (motivos $?m))
    (object (is-a Familia) (name ?s) (edad_hijo_menor ?e&:(< ?e 10)))
    (object (is-a Vivienda) (name ?v) (tiene_servicio_cercano $?servicios))
    (not (exists (object (is-a Centro_Salud) (name ?cs)) (test (member$ ?cs ?servicios))))
    (test (neq ?st DESCARTADO))
    (test (not (member$ "Salud: Pediatra/CAP lejos para los niños" ?m)))
    =>
    (modify ?r (estado PARCIALMENTE_ADECUADO) 
               (motivos $?m "Salud: Pediatra/CAP lejos para los niños"))
)

;;; ===============================================================
;;; REGLA NUEVA: CONTROL DE CALIDAD - 5 FALLOS = DESCARTADO
;;; ===============================================================

(defrule REQUISITOS::exceso-de-incumplimientos
    (declare (salience -5)) ;; Ejecutar DESPUÉS de detectar los fallos, ANTES de cambiar de módulo
    ?r <- (Recomendacion (estado PARCIALMENTE_ADECUADO) (motivos $?lista-motivos))
    
    ;; Contamos si hay 3 o más elementos en la lista de motivos
    (test (>= (length$ $?lista-motivos) 5))
    =>
    ;; Cambiamos el estado a DESCARTADO y añadimos el motivo final
    (modify ?r (estado DESCARTADO) 
               (motivos $?lista-motivos "DESCARTADO AUTOMATICO: 3 o mas requisitos incumplidos"))
)

(defrule REQUISITOS::paso-a-extras
    (declare (salience -10))
    ?c <- (ControlFase (fase REQUISITOS))
    =>
    (modify ?c (fase EXTRAS))
    (focus EXTRAS)
)

;;; =========================================================
;;; MÓDULO EXTRAS (Bonificaciones)
;;; =========================================================

(defrule EXTRAS::confort-termico
    ?r <- (Recomendacion (vivienda ?v) (estado ?st) (motivos $?m))
    (object (is-a Vivienda) (name ?v) (tiene_aire_acondicionado SI) (tiene_calefaccion SI))
    (test (or (eq ?st VALID) (eq ?st MUY_RECOMENDABLE)))
    (test (not (member$ "EXTRA: Climatizacion completa (Frio/Calor)" ?m)))
    =>
    (modify ?r (estado MUY_RECOMENDABLE) 
               (motivos $?m "EXTRA: Climatizacion completa (Frio/Calor)"))
)

(defrule EXTRAS::cerca-zona-ocio
    ?r <- (Recomendacion (solicitante ?s) (vivienda ?v) (estado ?st) (motivos $?m))
    (object (is-a Estudiantes) (name ?s))
    (object (is-a Vivienda) (name ?v) (tiene_servicio_cercano $?servicios))
    (exists (object (is-a Zona_Nocturna) (name ?zn))
            (test (member$ ?zn ?servicios)))
    (test (or (eq ?st VALID) (eq ?st MUY_RECOMENDABLE)))
    (test (not (member$ "EXTRA: Zona de ocio cercana" ?m)))
    =>
    (modify ?r (estado MUY_RECOMENDABLE) 
               (motivos $?m "EXTRA: Zona de ocio cercana"))
)

(defrule EXTRAS::precio-ganga
    ?r <- (Recomendacion (solicitante ?s) (vivienda ?v) (estado ?st) (motivos $?m))
    (object (is-a Solicitante) (name ?s) (presupuesto_maximo ?max))
    (object (is-a Vivienda) (name ?v) (precio_mensual ?precio))
    (test (or (eq ?st VALID) (eq ?st MUY_RECOMENDABLE)))
    (test (<= ?precio (- ?max 150)))
    (test (not (member$ "EXTRA: Precio ganga (ahorro >150)" ?m)))
    =>
    (modify ?r (estado MUY_RECOMENDABLE) 
               (motivos $?m "EXTRA: Precio ganga (ahorro >150)"))
)

(defrule EXTRAS::trabajo-muy-cerca
    ?r <- (Recomendacion (solicitante ?s) (vivienda ?v) (estado ?st) (motivos $?m))
    (object (is-a Solicitante) (name ?s) (trabaja_en_x ?tx) (trabaja_en_y ?ty))
    (object (is-a Vivienda) (name ?v) (coordx ?vx) (coordy ?vy))
    (test (or (eq ?st VALID) (eq ?st MUY_RECOMENDABLE)))
    (test (< (distancia ?tx ?ty ?vx ?vy) 500))
    (test (not (member$ "EXTRA: Al lado del trabajo (<500m)" ?m)))
    =>
    (modify ?r (estado MUY_RECOMENDABLE) 
               (motivos $?m "EXTRA: Al lado del trabajo (<500m)"))
)

(defrule EXTRAS::calidad-vida
    ?r <- (Recomendacion (vivienda ?v) (estado ?st) (motivos $?m))
    (object (is-a Vivienda) (name ?v) (es_soleado "Todo el dia") (tiene_terraza TRUE))
    (test (or (eq ?st VALID) (eq ?st MUY_RECOMENDABLE)))
    (test (not (member$ "EXTRA: Gran calidad (Sol+Terraza)" ?m)))
    =>
    (modify ?r (estado MUY_RECOMENDABLE) 
               (motivos $?m "EXTRA: Gran calidad (Sol+Terraza)"))
)

(defrule EXTRAS::familia-colegio-top
    ?r <- (Recomendacion (solicitante ?s) (vivienda ?v) (estado ?st) (motivos $?m))
    (object (is-a Familia) (name ?s))
    (object (is-a Vivienda) (name ?v) (tiene_servicio_cercano $?servicios))
    (exists (object (is-a Colegio) (name ?cole))
            (test (member$ ?cole ?servicios)))
    (test (or (eq ?st VALID) (eq ?st MUY_RECOMENDABLE)))
    (test (not (member$ "EXTRA: Colegio muy cerca" ?m)))
    =>
    (modify ?r (estado MUY_RECOMENDABLE) 
               (motivos $?m "EXTRA: Colegio muy cerca"))
)

(defrule EXTRAS::luz-premium
    ?r <- (Recomendacion (vivienda ?v) (estado ?st) (motivos $?m))
    (object (is-a Vivienda) (name ?v) (es_soleado "Todo el dia"))
    (test (or (eq ?st VALID) (eq ?st MUY_RECOMENDABLE)))
    (test (not (member$ "EXTRA: Iluminación excelente (sol todo el día)" ?m)))
    =>
    (modify ?r (estado MUY_RECOMENDABLE) 
               (motivos $?m "EXTRA: Iluminación excelente (sol todo el día)"))
)

(defrule EXTRAS::transporte-total
    ?r <- (Recomendacion (vivienda ?v) (estado ?st) (motivos $?m))
    (object (is-a Vivienda) (name ?v) (tiene_servicio_cercano $?s))
    (exists (object (is-a Parada_Metro) (name ?m1)) (test (member$ ?m1 ?s)))
    (exists (object (is-a Parada_Autobús) (name ?b1)) (test (member$ ?b1 ?s)))
    (test (or (eq ?st VALID) (eq ?st MUY_RECOMENDABLE)))
    (test (not (member$ "EXTRA: Conexión total (Metro y Bus)" ?m)))
    =>
    (modify ?r (estado MUY_RECOMENDABLE) 
               (motivos $?m "EXTRA: Conexión total (Metro y Bus)"))
)

(defrule EXTRAS::supermercado-puerta
    ?r <- (Recomendacion (vivienda ?v) (estado ?st) (motivos $?m))
    (object (is-a Vivienda) (name ?v) (tiene_servicio_cercano $?s))
    (exists (object (is-a Supermercado) (name ?sup)) (test (member$ ?sup ?s)))
    (test (or (eq ?st VALID) (eq ?st MUY_RECOMENDABLE)))
    (test (not (member$ "EXTRA: Supermercado al lado de casa" ?m)))
    =>
    (modify ?r (estado MUY_RECOMENDABLE) 
               (motivos $?m "EXTRA: Supermercado al lado de casa"))
)

(defrule EXTRAS::espacio-ideal-familia
    ?r <- (Recomendacion (solicitante ?s) (vivienda ?v) (estado ?st) (motivos $?m))
    (object (is-a Familia) (name ?s) (num_personas ?np&:(>= ?np 4)))
    (object (is-a Unifamiliar) (name ?v))
    (test (or (eq ?st VALID) (eq ?st MUY_RECOMENDABLE)))
    (test (not (member$ "EXTRA: Tipología ideal (Casa) para familia grande" ?m)))
    =>
    (modify ?r (estado MUY_RECOMENDABLE) 
               (motivos $?m "EXTRA: Tipología ideal (Casa) para familia grande"))
)

(defrule EXTRAS::ahorro-alto
    ?r <- (Recomendacion (solicitante ?s) (vivienda ?v) (estado ?st) (motivos $?m))
    (object (is-a Solicitante) (name ?s) (presupuesto_maximo ?max))
    (object (is-a Vivienda) (name ?v) (precio_mensual ?p))
    (test (<= ?p (- ?max 250)))
    (test (or (eq ?st VALID) (eq ?st MUY_RECOMENDABLE)))
    (test (not (member$ "EXTRA: Gran Ahorro (>250 eur)" ?m)))
    =>
    (modify ?r (estado MUY_RECOMENDABLE) 
               (motivos $?m "EXTRA: Gran Ahorro (>250 eur)"))
)

(defrule EXTRAS::jubilacion-dorada
    ?r <- (Recomendacion (solicitante ?s) (vivienda ?v) (estado ?st) (motivos $?m))
    (object (is-a Solicitante) (name ?s) (edad_mas_anciano ?e&:(> ?e 65)))
    (object (is-a Vivienda) (name ?v) (tiene_ascensor TRUE) (tiene_terraza TRUE) (tiene_servicio_cercano $?ser))
    (exists (object (is-a Zona_Verde) (name ?zv)) (test (member$ ?zv ?ser)))
    (exists (object (is-a Centro_Salud) (name ?cs)) (test (member$ ?cs ?ser)))
    (test (or (eq ?st VALID) (eq ?st MUY_RECOMENDABLE)))
    (test (not (member$ "EXTRA: Jubilación Ideal (Salud + Relax + Accesible)" ?m)))
    =>
    (modify ?r (estado MUY_RECOMENDABLE) 
               (motivos $?m "EXTRA: Jubilación Ideal (Salud + Relax + Accesible)"))
)

(defrule EXTRAS::paso-a-informe
    (declare (salience -10))
    ?c <- (ControlFase (fase EXTRAS))
    =>
    (modify ?c (fase INFORME))
    (focus INFORME)
)

;;; =========================================================
;;; MÓDULO INFORME
;;; =========================================================

(defrule INFORME::cabecera
    (declare (salience 100))
    =>
    (printout t crlf "#################################################" crlf)
    (printout t "      RESULTADOS DE LA BUSQUEDA      " crlf)
    (printout t "#################################################" crlf crlf)
)

(defrule INFORME::imprimir-top
    ?r <- (Recomendacion (solicitante ?s) (vivienda ?v) (estado MUY_RECOMENDABLE) (motivos $?m))
    =>
    (printout t ">>> [MUY RECOMENDABLE] " ?v " para " ?s crlf)
    (printout t "    DESTACA POR: " $?m crlf)
    (printout t "-------------------------------------------------" crlf)
)

(defrule INFORME::imprimir-adecuado
    ?r <- (Recomendacion (solicitante ?s) (vivienda ?v) (estado VALID))
    =>
    (printout t ">>> [ADECUADO] " ?v " para " ?s crlf)
    (printout t "    Cumple todos los requisitos." crlf)
    (printout t "-------------------------------------------------" crlf)
)

(defrule INFORME::imprimir-parcial
    ?r <- (Recomendacion (solicitante ?s) (vivienda ?v) (estado PARCIALMENTE_ADECUADO) (motivos $?m))
    =>
    (printout t ">>> [PARCIALMENTE ADECUADO] " ?v " para " ?s crlf)
    (printout t "    AVISOS: " $?m crlf)
    (printout t "-------------------------------------------------" crlf)
)

(defrule INFORME::imprimir-descartado
    ?r <- (Recomendacion (solicitante ?s) (vivienda ?v) (estado DESCARTADO) (motivos $?m))
    =>
    (printout t ">>> [X] DESCARTADO " ?v " para " ?s crlf)
    (printout t "    MOTIVO: " $?m crlf)
    (printout t "-------------------------------------------------" crlf)
)