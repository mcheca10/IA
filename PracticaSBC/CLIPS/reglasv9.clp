;;; 1. MÓDULOS
(defmodule MAIN (export ?ALL))
(defmodule PREGUNTAS (import MAIN ?ALL) (export ?ALL))   
(defmodule ABSTRACCION (import MAIN ?ALL) (export ?ALL)) 
(defmodule ASOCIACION (import MAIN ?ALL) (export ?ALL))  
(defmodule REFINAMIENTO (import MAIN ?ALL) (export ?ALL))
(defmodule INFORME (import MAIN ?ALL) (export ?ALL))     

;;; 2. TEMPLATES
(deftemplate MAIN::Recomendacion
    (slot solicitante (type INSTANCE-NAME)) 
    (slot vivienda (type INSTANCE-NAME))
    (slot estado (type SYMBOL) (default INDETERMINADO))
    (multislot motivos (type STRING))
    (slot puntuacion (type INTEGER) (default 0))
    (slot base_aplicada (type SYMBOL) (default FALSE))
)
(deftemplate MAIN::Rasgo
    (slot objeto (type INSTANCE-NAME))
    (slot caracteristica (type SYMBOL)) 
    (slot valor (type SYMBOL))
)
(deftemplate MAIN::FaseEntrevista (slot estado))
(deftemplate MAIN::PasarFaseEspecifica)

;;; 3. FUNCIONES UTILIDAD

(deffunction MAIN::ask-float (?q) 
   (printout t ?q " ") (bind ?a (read)) 
   (while (lexemep ?a) do (printout t "Error. Numero: ") (bind ?a (read))) 
   (float ?a))

(deffunction MAIN::ask-int (?q) 
   (printout t ?q " ") (bind ?a (read)) 
   (while (lexemep ?a) do (printout t "Error. Entero: ") (bind ?a (read))) 
   (integer ?a))

(deffunction MAIN::ask-choice (?q $?v) 
   (printout t ?q " [" (implode$ $?v) "]: ") 
   (bind ?a (read)) 
   (if (lexemep ?a) then (bind ?a (lowcase ?a))) 
   (while (not (member$ ?a $?v)) do (printout t "Opcion no valida. " ?q " ") (bind ?a (read))) 
   ?a)

(deffunction MAIN::yes-or-no-p (?q) 
   (bind ?a (ask-choice ?q yes no y n si s)) 
   (if (or (eq ?a yes) (eq ?a y) (eq ?a si) (eq ?a s)) then TRUE else FALSE))

(deffunction MAIN::ask-list-int (?p) 
   (printout t ?p " (separados por espacios): ") 
   (bind ?l (readline)) (bind ?c (explode$ ?l)) (bind ?r (create$)) 
   (progn$ (?e ?c) (if (integerp ?e) then (bind ?r (create$ ?r ?e)))) 
   ?r)

(deffunction MAIN::distancia (?x1 ?y1 ?x2 ?y2) 
   (sqrt (+ (* (- ?x2 ?x1) (- ?x2 ?x1)) (* (- ?y2 ?y1) (- ?y2 ?y1)))))

(defrule MAIN::inicio
    (declare (salience 100))
    =>
    (printout t "===========================================" crlf)
    (printout t "       SISTEMA EXPERTO INMOBILIARIO        " crlf)
    (printout t "===========================================" crlf)
    (assert (FaseEntrevista (estado router)))
    (focus PREGUNTAS)
)

;;; =========================================================
;;; MÓDULO PREGUNTAS
;;; =========================================================

(defrule PREGUNTAS::Router-Principal
    ?f <- (FaseEntrevista (estado router))
    =>
    (printout t "--- FASE 1: PERFILADO ---" crlf)
    (bind ?act (ask-choice "1. Actividad principal:" (create$ estudiante trabajador jubilado desempleado)))
    
    (if (eq ?act estudiante) then
        (printout t ">> Perfil: ESTUDIANTE" crlf)
        (bind ?ed (create$)) (while (neq (length$ ?ed) 1) do (bind ?ed (ask-list-int "   > Tu edad")))
        (make-instance [usuario_actual] of Estudiantes (situacion_laboral ESTUDIANTE) (num_personas 1) (edades_inquilinos ?ed))
    else
        (bind ?adultos (ask-int "2. Num Adultos:"))
        (bind ?menores (ask-int "3. Num Niños:"))
        (bind ?total (+ ?adultos ?menores))
        (bind ?ed (create$)) (while (neq (length$ ?ed) ?total) do (bind ?ed (ask-list-int "   > Edades de todos (separadas por espacio)")))

        (if (> ?menores 0) then
            (printout t ">> Perfil: FAMILIA" crlf)
            (make-instance [usuario_actual] of Familia (situacion_laboral ?act) (num_personas ?total) (edades_inquilinos ?ed) (num_hijos ?menores))
        else (if (and (> ?adultos 1) (eq (ask-choice "4. ¿Relacion?" (create$ pareja amigos)) amigos)) then
            (printout t ">> Perfil: COLIVING" crlf)
            (make-instance [usuario_actual] of CoLiving (situacion_laboral ?act) (num_personas ?adultos) (edades_inquilinos ?ed))
        else (if (> ?adultos 1) then
            (printout t ">> Perfil: PAREJA" crlf)
            (make-instance [usuario_actual] of Pareja (situacion_laboral ?act) (num_personas ?adultos) (edades_inquilinos ?ed))
        else
            (printout t ">> Perfil: INDIVIDUO" crlf)
            (make-instance [usuario_actual] of Individuo (situacion_laboral ?act) (num_personas 1) (edades_inquilinos ?ed))
        )))
    )
    (modify ?f (estado comunes))
)

(defrule PREGUNTAS::Datos-Comunes-Detallados
    (FaseEntrevista (estado comunes))
    ?s <- (object (is-a Solicitante))
    =>
    (printout t "--- FASE 2: DATOS GENERALES ---" crlf)
    
    (send ?s put-presupuesto_esperado (ask-float "5. Alquiler deseado (€):"))
    
    (send ?s put-superficie_deseada (ask-float "6. Superficie deseada (m2):"))

    (bind ?m (yes-or-no-p "7. ¿Teneis mascota?"))
    (send ?s put-tiene_mascota (if ?m then SI else NO))
    
    (bind ?t (yes-or-no-p "8. ¿Teletrabajo habitual?"))
    (send ?s put-teletrabajo (if ?t then SI else NO))
    (send ?s put-trabaja_en_casa (if ?t then TRUE else FALSE))

    (if (eq (class ?s) Estudiantes) then 
        (send ?s put-necesita_muebles SI)
    else 
        (send ?s put-necesita_muebles (ask-choice "9. ¿Necesitas muebles?" (create$ si no indiferente))))

    (bind ?sit (send ?s get-situacion_laboral))
    
    (if (and (or (eq ?sit estudiante) (eq ?sit trabajador)) 
             (eq ?t FALSE)) then
        (printout t "10. Ubicacion Trabajo/Universidad (X Y):" crlf)
        (send ?s put-trabaja_en_x (ask-float "    X: "))
        (send ?s put-trabaja_en_y (ask-float "    Y: "))
    )
    
    (bind ?tr (ask-choice "11. Transporte principal:" (create$ publico coche)))
    (send ?s put-medio_transporte_principal ?tr)
    (if (or (eq ?tr coche) (yes-or-no-p "    ¿Tienes coche?")) then 
        (send ?s put-tiene_coche TRUE)
    else 
        (send ?s put-tiene_coche FALSE))
     
    (bind ?mr (yes-or-no-p "12. ¿Movilidad reducida (o silla bebe)?"))
    (send ?s put-movilidad_reducida (if ?mr then SI else NO))

    (bind ?eds (send ?s get-edades_inquilinos))
    (bind ?mx 0) 
    (progn$ (?e ?eds) (if (> ?e ?mx) then (bind ?mx ?e)))
    (send ?s put-edad_mas_anciano ?mx)

    (assert (PasarFaseEspecifica))
)

(defrule PREGUNTAS::Transicion 
    ?f <- (FaseEntrevista (estado comunes)) 
    ?t <- (PasarFaseEspecifica) 
    => 
    (retract ?t) 
    (modify ?f (estado especificas)))


(defrule PREGUNTAS::Esp-CoLiving 
    (FaseEntrevista (estado especificas)) 
    ?s <- (object (is-a CoLiving))
    (test (eq (instance-name ?s) [usuario_actual]))
    (test (eq (send ?s get-bano_privado) nil))
    =>
    (send ?s put-bano_privado (if (yes-or-no-p "C. ¿Baño privado imprescindible?") then SI else NO))
    (send ?s put-habitaciones_individuales (if (yes-or-no-p "C. ¿Necesitais habitaciones individuales todos?") then SI else NO)))

(defrule PREGUNTAS::Esp-Pareja 
    (FaseEntrevista (estado especificas)) 
    ?s <- (object (is-a Pareja))
    (test (eq (instance-name ?s) [usuario_actual]))
    (test (not (member$ "Eficiencia" (send ?s get-prefiere_cerca))))
    =>
    (bind ?resp (yes-or-no-p "P. ¿Valoráis mucho la eficiencia energética (ahorro en facturas)?"))
    (if ?resp then 
        (slot-insert$ ?s prefiere_cerca 1 "Eficiencia")))


(defrule PREGUNTAS::Finalizar 
    (declare (salience -10)) 
    ?f <- (FaseEntrevista (estado especificas)) 
    => 
    (printout t ">>> Entrevista completa. Analizando datos..." crlf) 
    (modify ?f (estado fin)) 
    (focus ABSTRACCION))


;;; =========================================================
;;; MÓDULO ABSTRACCIÓN
;;; =========================================================

(defrule ABSTRACCION::detectar-servicios-cercanos
    (declare (salience 30))
    ?v <- (object (is-a Vivienda) (coordx ?vx) (coordy ?vy) (tiene_servicio_cercano $?lista))
    (object (is-a Servicio) (name ?s) (servicio_en_x ?sx) (servicio_en_y ?sy))
    (test (< (distancia ?vx ?vy ?sx ?sy) 500))
    (test (not (member$ ?s $?lista)))
    =>
    (slot-insert$ ?v tiene_servicio_cercano 1 ?s)
)

(defrule ABSTRACCION::Calculo-Termico
    (declare (salience 20))
    ?s <- (object (is-a Solicitante) (edades_inquilinos $?e) (exigencia_termica ?x&:(eq ?x nil)))
    =>
    (bind ?critica FALSE) 
    (progn$ (?edad ?e) (if (or (< ?edad 4) (> ?edad 70)) then (bind ?critica TRUE)))
    (if ?critica then (send ?s put-exigencia_termica CRITICA) else (send ?s put-exigencia_termica NORMAL))
)


;;; --- GENERACIÓN DE RASGOS ---

(defrule ABSTRACCION::Gen-Rasgo-Coste
    (object (is-a Solicitante) (presupuesto_esperado ?p_deseado))
    (object (is-a Vivienda) (name ?v) (precio_mensual ?p_real)) 
    
    (test (if (numberp ?p_deseado) then (> ?p_deseado 0) else FALSE)) 
    (not (Rasgo (objeto ?v) (caracteristica COSTE))) 
    =>
    ;; --- LÓGICA REALISTA ---
    
    ;; 1. IMPAGABLE (> 20% extra)
    (if (> ?p_real (* ?p_deseado 1.20)) then 
        (assert (Rasgo (objeto ?v) (caracteristica COSTE) (valor IMPAGABLE)))
    else 
        ;; 2. CARO (Entre +10% y +20%)
        (if (> ?p_real (* ?p_deseado 1.10)) then 
            (assert (Rasgo (objeto ?v) (caracteristica COSTE) (valor CARO)))
        else 
            ;; 3. SOSPECHOSO (< 30% más barato) -> ¡Ojo aquí!
            (if (< ?p_real (* ?p_deseado 0.70)) then
                (assert (Rasgo (objeto ?v) (caracteristica COSTE) (valor DEMASIADO_BARATO)))
            else
                ;; 4. CHOLLO (Entre -10% y -30%)
                (if (< ?p_real (* ?p_deseado 0.90)) then 
                    (assert (Rasgo (objeto ?v) (caracteristica COSTE) (valor CHOLLO)))
                )
            )
        )
    )
)

(defrule ABSTRACCION::Gen-Rasgo-Superficie
    (object (is-a Solicitante) (superficie_deseada ?sd))
    (object (is-a Vivienda) (name ?v) (superficie ?sup))
    
    (test (> ?sd 0))
    (not (Rasgo (objeto ?v) (caracteristica SUPERFICIE_REQ))) 
    =>
    ;; 1. INSUFICIENTE (Si falta más del 20% del espacio)
    (if (< ?sup (* ?sd 0.80)) then 
        (assert (Rasgo (objeto ?v) (caracteristica SUPERFICIE_REQ) (valor INSUFICIENTE)))
    else 
        ;; 2. JUSTO (Si falta entre 10% y 20%)
        (if (< ?sup (* ?sd 0.90)) then 
            (assert (Rasgo (objeto ?v) (caracteristica SUPERFICIE_REQ) (valor JUSTO)))
        else 
            ;; 3. EXTRA (Si sobra más del 10%)
            (if (> ?sup (* ?sd 1.10)) then 
                (assert (Rasgo (objeto ?v) (caracteristica SUPERFICIE_REQ) (valor EXTRA)))
            )
        )
    )
)

(defrule ABSTRACCION::Gen-Rasgo-accesibilidad
    (object (is-a Vivienda) (name ?v) (tiene_ascensor ?asc) (acceso_portal ?portal) (altura_piso ?h))
    (not (Rasgo (objeto ?v) (caracteristica ACCESIBILIDAD)))
    =>
    (bind ?mala FALSE)
    (if (eq ?portal ESCALONES) then (bind ?mala TRUE))
    (if (and (> ?h 0) (or (eq ?asc NO) (eq ?asc FALSE))) then (bind ?mala TRUE))
    (if ?mala then (assert (Rasgo (objeto ?v) (caracteristica ACCESIBILIDAD) (valor MALA))))
)

(defrule ABSTRACCION::Gen-Rasgo-Confort-Termico
    (object (is-a Vivienda) (name ?v) (tiene_calefaccion ?cal) (certificado_energetico ?cert))
    (not (Rasgo (objeto ?v) (caracteristica CONFORT)))
    =>
    (if (or (eq ?cal NO) (eq ?cal FALSE) (eq ?cert F) (eq ?cert G)) then
        (assert (Rasgo (objeto ?v) (caracteristica CONFORT) (valor BAJO)))
    else (if (or (eq ?cert A) (eq ?cert B)) then
        (assert (Rasgo (objeto ?v) (caracteristica CONFORT) (valor ALTO)))))
)

(defrule ABSTRACCION::abs-espacio-dormitorios 
    (object (is-a Solicitante) (num_personas ?np)) 
    (object (is-a Vivienda) (name ?v) (num_habs_dobles ?d) (num_habs_individual ?i))
    (test (> ?np (+ (* ?d 2) ?i)))
    (not (Rasgo (objeto ?v) (caracteristica ESPACIO)))
    => (assert (Rasgo (objeto ?v) (caracteristica ESPACIO) (valor INSUFICIENTE))))

(defrule ABSTRACCION::abs-mascotas-check
    (object (is-a Vivienda) (name ?v) 
            (permite_mascotas ?m) 
            (tiene_terraza ?t) 
            (tiene_servicio_cercano $?servicios))
            
    (not (Rasgo (objeto ?v) (caracteristica MASCOTAS))) 
    =>
    (if (or (eq ?m NO) (eq ?m FALSE)) then
        (assert (Rasgo (objeto ?v) (caracteristica MASCOTAS) (valor PROHIBIDAS)))
    else
        
        (bind ?tiene_espacio FALSE)
        (if (or (eq ?t SI) (eq ?t TRUE)) then (bind ?tiene_espacio TRUE))
        (if (eq (class ?v) Unifamiliar) then
            (if (> (send ?v get-tamano_jardin) 10) then (bind ?tiene_espacio TRUE))
        )
        (bind ?tiene_parque FALSE)
        (progn$ (?s $?servicios)
            (if (or (eq (class ?s) Parque) (eq (class ?s) Zona_Verde)) then 
                (bind ?tiene_parque TRUE)
            )
        )
        
        (if (and (eq ?tiene_espacio FALSE) (eq ?tiene_parque FALSE)) then
            (assert (Rasgo (objeto ?v) (caracteristica MASCOTAS) (valor REGULAR)))
        )
    )
)

(defrule ABSTRACCION::Gen-Rasgo-Luminosidad
    (object (is-a Vivienda) (name ?v) (es_soleado ?sol))
    (not (Rasgo (objeto ?v) (caracteristica LUMINOSIDAD)))
    =>
    ;; 1. Si es "Nada" -> OSCURO
    (if (eq ?sol "Nada") then
        (assert (Rasgo (objeto ?v) (caracteristica LUMINOSIDAD) (valor OSCURO)))
    else 
        ;; 2. Si es "Todo el dia" o "Mucho" -> MUY_LUMINOSO
        (if (or (eq ?sol "Todo el dia") (eq ?sol "Mucho")) then
            (assert (Rasgo (objeto ?v) (caracteristica LUMINOSIDAD) (valor MUY_LUMINOSO)))
        else
            ;; 3. Resto de casos ("Algo", "Mañana", etc.) -> NORMAL
            (assert (Rasgo (objeto ?v) (caracteristica LUMINOSIDAD) (valor NORMAL)))
        )
    )
)

(defrule ABSTRACCION::abs-servicios-educacion (object (is-a Vivienda) (name ?v) (tiene_servicio_cercano $?s)) (exists (object (is-a Educacion) (name ?e)) (test (member$ ?e ?s))) (not (Rasgo (objeto ?v) (caracteristica ENTORNO) (valor EDUCATIVO))) => (assert (Rasgo (objeto ?v) (caracteristica ENTORNO) (valor EDUCATIVO))))
(defrule ABSTRACCION::abs-servicios-ocio (object (is-a Vivienda) (name ?v) (tiene_servicio_cercano $?s)) (exists (object (is-a Zona_Nocturna) (name ?zn)) (test (member$ ?zn ?s))) (not (Rasgo (objeto ?v) (caracteristica ENTORNO) (valor RUIDOSO))) => (assert (Rasgo (objeto ?v) (caracteristica ENTORNO) (valor RUIDOSO))))
(defrule ABSTRACCION::abs-servicios-relax (object (is-a Vivienda) (name ?v) (tiene_servicio_cercano $?s)) (exists (object (is-a Zona_Verde) (name ?zv)) (test (member$ ?zv ?s))) (not (Rasgo (objeto ?v) (caracteristica ENTORNO) (valor RELAX))) => (assert (Rasgo (objeto ?v) (caracteristica ENTORNO) (valor RELAX))))
(defrule ABSTRACCION::abs-zona-comercial (object (is-a Vivienda) (name ?v) (tiene_servicio_cercano $?s)) (exists (object (is-a Supermercado) (name ?sup)) (test (member$ ?sup ?s))) (not (Rasgo (objeto ?v) (caracteristica SERVICIOS) (valor ABASTECIMIENTO))) => (assert (Rasgo (objeto ?v) (caracteristica SERVICIOS) (valor ABASTECIMIENTO))))

(defrule ABSTRACCION::abs-transporte-rapido
    (object (is-a Vivienda) (name ?v) (tiene_servicio_cercano $?s)) 
    (exists (object (is-a Transporte) (name ?t)) 
        (test (member$ ?t ?s))
        ;; Comprobamos si es Metro, Tren o Autobús
        (test (or (eq (class ?t) Parada_Metro) 
                  (eq (class ?t) Estación_Tren)
                  (eq (class ?t) Parada_Autobús)))
    )
    (not (Rasgo (objeto ?v) (caracteristica CONECTIVIDAD) (valor RAPIDA))) 
    => (assert (Rasgo (objeto ?v) (caracteristica CONECTIVIDAD) (valor RAPIDA))))


(defrule ABSTRACCION::siguiente 
    (declare (salience -10)) 
    => 
    (focus ASOCIACION)
)


;;; =========================================================
;;; MÓDULO ASOCIACION (OPTIMIZADO V5)
;;; =========================================================

(defrule ASOCIACION::init-recom 
    (object (is-a Solicitante) (name ?s)) 
    (object (is-a Vivienda) (name ?v)) 
    => (assert (Recomendacion (solicitante ?s) (vivienda ?v) (estado INDETERMINADO) (puntuacion 0))))

;;; A. RESTRICCIONES DURAS -> RESTAN 150 PUNTOS

(defrule ASOCIACION::filtrar-precio 
    ?r<-(Recomendacion(vivienda ?v)(puntuacion ?p)(motivos $?m)) 
    (test (> ?p -150)) 
    (Rasgo(objeto ?v)(caracteristica COSTE)(valor IMPAGABLE)) 
    (test (not (member$ "Presupuesto insuficiente" $?m)))
    => (modify ?r (puntuacion (- ?p 150))(motivos $?m "Presupuesto insuficiente")))

(defrule ASOCIACION::filtrar-precio-sospechoso
    ?r <- (Recomendacion (vivienda ?v) (puntuacion ?p) (motivos $?m))
    (test (> ?p -150)) ;; Solo si sigue viva
    
    ;; Detectamos la etiqueta generada anteriormente
    (Rasgo (objeto ?v) (caracteristica COSTE) (valor DEMASIADO_BARATO))
    
    (test (not (member$ "Precio sospechosamente bajo" $?m)))
    =>
    ;; Descarte (-150 puntos)
    (modify ?r (puntuacion (- ?p 150)) (motivos $?m "Precio sospechosamente bajo"))
)

(defrule ASOCIACION::filtrar-superficie-insuficiente
    ?r <- (Recomendacion (vivienda ?v) (puntuacion ?p) (motivos $?m))
    (test (> ?p -150))
    
    ;; Detectamos el rasgo generado por el porcentaje (< 85%)
    (Rasgo (objeto ?v) (caracteristica SUPERFICIE_REQ) (valor INSUFICIENTE))
    
    (test (not (member$ "Superficie insuficiente (>15% dif)" $?m)))
    =>
    (modify ?r (puntuacion (- ?p 150)) (motivos $?m "Superficie insuficiente (>15% dif)"))
)

(defrule ASOCIACION::filtrar-sin-muebles
    ?r<-(Recomendacion(vivienda ?v)(puntuacion ?p)(motivos $?m))
    (test (> ?p -150)) 
    (object (is-a Solicitante) (necesita_muebles SI))
    (object (is-a Vivienda) (name ?v) (amueblado ?a))
    (test (or (eq ?a NO) (eq ?a FALSE)))
    (test (not (member$ "Requiere muebles" $?m)))
    =>
    (modify ?r (puntuacion (- ?p 150)) (motivos $?m "Requiere muebles")))

(defrule ASOCIACION::filtrar-espacio 
    ?r<-(Recomendacion(vivienda ?v)(puntuacion ?p)(motivos $?m)) 
    (test (> ?p -150))
    (Rasgo(objeto ?v)(caracteristica ESPACIO)(valor INSUFICIENTE)) 
    (test (not (member$ "Faltan dormitorios" $?m)))
    => (modify ?r (puntuacion (- ?p 150))(motivos $?m "Faltan dormitorios")))

(defrule ASOCIACION::filtrar-coliving-bano-privado
    ?r <- (Recomendacion (vivienda ?v) (puntuacion ?p) (motivos $?m))
    (test (> ?p -150)) ;; Solo evaluamos si sigue viva
    
    ;; 1. Es CoLiving y exige baño privado
    (object (is-a CoLiving) (num_personas ?np) (bano_privado SI))
    
    ;; 2. La vivienda no tiene suficientes baños (1 por persona)
    (object (is-a Vivienda) (name ?v) (num_banos ?nb))
    (test (< ?nb ?np))
    
    ;; 3. Evitar duplicados
    (test (not (member$ "Faltan baños privados (CoLiving)" $?m)))
    =>
    ;; Descarte (-150)
    (modify ?r (puntuacion (- ?p 150)) (motivos $?m "Faltan baños privados (CoLiving)"))
)

(defrule ASOCIACION::filtrar-mascota-prohibida 
    ?r<-(Recomendacion(vivienda ?v)(puntuacion ?p)(motivos $?m)) 
    (test (> ?p -150))
    (object (is-a Solicitante) (tiene_mascota SI)) 
    
    ;; Leemos el nuevo rasgo
    (Rasgo (objeto ?v) (caracteristica MASCOTAS) (valor PROHIBIDAS)) 
    
    (test (not (member$ "No admiten mascotas" $?m)))
    => 
    (modify ?r (puntuacion (- ?p 150))(motivos $?m "No admiten mascotas"))
)

(defrule ASOCIACION::filtrar-accesibilidad-ancianos-mobilidad-reducida 
    ?r<-(Recomendacion(vivienda ?v)(puntuacion ?p)(motivos $?m)) 
    (test (> ?p -150))
    (object (is-a Solicitante) (edad_mas_anciano ?e) (movilidad_reducida ?mr)) 
    (test (or (> ?e 70) (eq ?mr SI) (eq ?mr TRUE)))
    (Rasgo(objeto ?v)(caracteristica ACCESIBILIDAD)(valor MALA)) 
    (test (not (member$ "Barreras arquitectónicas (Ancianos/Movilidad)" $?m)))
    => 
    (modify ?r (puntuacion (- ?p 150))(motivos $?m "Barreras arquitectónicas (Ancianos/Movilidad)")))

(defrule ASOCIACION::filtrar-duplex-ancianos-mobilidad-reducida 
    ?r<-(Recomendacion(vivienda ?v)(puntuacion ?p)(motivos $?m)) 
    (test (> ?p -150))
    (object (is-a Solicitante) (edad_mas_anciano ?e) (movilidad_reducida ?mr))
    (test (or (> ?e 75) (eq ?mr SI) (eq ?mr TRUE)))
    (object (is-a Dúplex) (name ?v)) 
    (test (not (member$ "Dúplex peligroso/inaccesible" $?m)))
    => 
    (modify ?r (puntuacion (- ?p 150))(motivos $?m "Dúplex peligroso/inaccesible")))

(defrule ASOCIACION::filtrar-familia-estudio 
    ?r<-(Recomendacion(vivienda ?v)(puntuacion ?p)(motivos $?m)) 
    (test (> ?p -150))
    (object (is-a Familia) (num_personas ?np&:(> ?np 3))) 
    (object (is-a Vivienda) (name ?v) (num_habs_dobles 0)) 
    (test (not (member$ "Inviable para familia (Estudio)" $?m)))
    => (modify ?r (puntuacion (- ?p 150))(motivos $?m "Inviable para familia (Estudio)")))

(defrule ASOCIACION::filtrar-coliving-habitaciones
    ?r <- (Recomendacion (vivienda ?v) (puntuacion ?p)(motivos $?m))
    (test (> ?p -150))
    (object (is-a CoLiving) (num_personas ?np) (habitaciones_individuales SI))
    (object (is-a Vivienda) (name ?v) (num_habs_dobles ?hd) (num_habs_individual ?hi))
    (test (< (+ ?hd ?hi) ?np)) 
    (test (not (member$ "Faltan habitaciones separadas" $?m)))
    => (modify ?r (puntuacion (- ?p 150)) (motivos $?m "Faltan habitaciones separadas")))

(defrule ASOCIACION::filtrar-sin-transporte-publico
    ?r <- (Recomendacion (vivienda ?v) (puntuacion ?p) (motivos $?m))
    (test (> ?p -150))
    (object (is-a Solicitante) (medio_transporte_principal publico))
    (object (is-a Vivienda) (name ?v) (tiene_servicio_cercano $?servicios))
    (not (exists (object (is-a Transporte) (name ?t)) (test (member$ ?t $?servicios))))
    (test (not (member$ "Sin transporte público cercano" $?m)))
    =>
    (modify ?r (puntuacion (- ?p 150)) (motivos $?m "Sin transporte público cercano")))

;;; B. AVISOS -> RESTAN 50 PUNTOS


(defrule ASOCIACION::aviso-superficie-justa
    ?r <- (Recomendacion (vivienda ?v) (puntuacion ?p) (motivos $?m))
    (test (> ?p -150))
    
    (object (is-a Solicitante) (superficie_deseada ?sd))
    (object (is-a Vivienda) (name ?v) (superficie ?sup))
    
    (test (> ?sd 0))
    
    ;; LÓGICA: Es menor que lo deseado, PERO entra en el margen de 15m
    ;; Ejemplo: Pides 80m. La casa tiene 70m.
    (test (< ?sup ?sd))
    (test (>= ?sup (- ?sd 15)))
    
    (test (not (member$ "Superficie algo justa" $?m)))
    =>
    (modify ?r (puntuacion (- ?p 50)) (motivos $?m "Superficie algo justa"))
)

(defrule ASOCIACION::aviso-precio-caro
    ?r <- (Recomendacion (vivienda ?v) (puntuacion ?p) (motivos $?m))
    (test (> ?p -150))
    (Rasgo (objeto ?v) (caracteristica COSTE) (valor CARO))
    (test (not (member$ "Precio alto" $?m)))
    =>
    (modify ?r (puntuacion (- ?p 50)) (motivos $?m "Precio alto")))

(defrule ASOCIACION::aviso-oscuridad-teletrabajo 
    ?r<-(Recomendacion(vivienda ?v)(puntuacion ?p)(motivos $?m)) 
    (test (> ?p -150))
    (object (is-a Solicitante) (trabaja_en_casa TRUE)) 
    (Rasgo(objeto ?v)(caracteristica LUMINOSIDAD)(valor OSCURO)) 
    (test (not (member$ "Poca luz" $?m))) 
    => (modify ?r (puntuacion (- ?p 50))(motivos $?m "Poca luz")))

(defrule ASOCIACION::aviso-ruido-ancianos 
    ?r<-(Recomendacion(vivienda ?v)(puntuacion ?p)(motivos $?m)) 
    (test (> ?p -150))
    (object (is-a Solicitante) (edad_mas_anciano ?e&:(> ?e 60))) 
    (Rasgo(objeto ?v)(caracteristica ENTORNO)(valor RUIDOSO)) 
    (test (not (member$ "Zona muy ruidosa" $?m))) 
    => (modify ?r (puntuacion (- ?p 50))(motivos $?m "Zona muy ruidosa")))

(defrule ASOCIACION::aviso-mascota-sin-exterior 
    ?r<-(Recomendacion(vivienda ?v)(puntuacion ?p)(motivos $?m)) 
    (test (> ?p -150))
    (object (is-a Solicitante) (tiene_mascota SI)) 
    (Rasgo (objeto ?v) (caracteristica MASCOTAS) (valor REGULAR)) 
    (test (not (member$ "Mascota sin espacio exterior" $?m))) 
    => 
    (modify ?r (puntuacion (- ?p 50))(motivos $?m "Mascota sin espacio exterior"))
)

(defrule ASOCIACION::aviso-pareja-mala-eficiencia
    ?r <- (Recomendacion (vivienda ?v) (puntuacion ?p) (motivos $?m))
    (test (> ?p -150)) ;; Solo si la vivienda sigue viva
    
    ;; 1. Es Pareja y busca Eficiencia (lo guardamos antes en la entrevista)
    (object (is-a Pareja) (prefiere_cerca $?pc))
    (test (member$ "Eficiencia" $?pc))
    
    ;; 2. La vivienda tiene mala eficiencia (F o G)
    (object (is-a Vivienda) (name ?v) (certificado_energetico ?ce))
    (test (or (eq ?ce F) (eq ?ce G)))
    
    ;; 3. Evitar duplicados
    (test (not (member$ "Gasto energético alto (Mal certificado)" $?m)))
    =>
    ;; Penalización de 50 puntos
    (modify ?r (puntuacion (- ?p 50)) (motivos $?m "Gasto energético alto (Mal certificado)"))
)

(defrule ASOCIACION::aviso-familia-abastecimiento 
    ?r<-(Recomendacion(vivienda ?v)(puntuacion ?p)(motivos $?m)) 
    (test (> ?p -150))
    (object (is-a Familia)) (not (Rasgo(objeto ?v)(caracteristica SERVICIOS)(valor ABASTECIMIENTO))) 
    (test (not (member$ "Falta super" $?m))) 
    => (modify ?r (puntuacion (- ?p 50))(motivos $?m "Falta super")))

(defrule ASOCIACION::aviso-confort-frio 
    ?r<-(Recomendacion(vivienda ?v)(puntuacion ?p)(motivos $?m)) 
    (test (> ?p -150))
    (object (is-a Solicitante) (exigencia_termica CRITICA)) 
    (Rasgo(objeto ?v)(caracteristica CONFORT)(valor BAJO)) 
    (test (not (member$ "Riesgo Termico" $?m))) 
    => (modify ?r (puntuacion (- ?p 50))(motivos $?m "Riesgo Termico")))

(defrule ASOCIACION::aviso-coche-sin-parking
    ?r <- (Recomendacion (vivienda ?v) (puntuacion ?p) (motivos $?m))
    (test (> ?p -150)) ;; Solo si la vivienda sigue viva
    
    ;; 1. El solicitante tiene coche
    (object (is-a Solicitante) (tiene_coche ?tc))
    (test (or (eq ?tc TRUE) (eq ?tc SI)))
    
    ;; 2. La vivienda NO tiene parking
    (object (is-a Vivienda) (name ?v) (tiene_parking ?tp))
    (test (or (eq ?tp NO) (eq ?tp FALSE)))
    
    ;; 3. Evitar duplicados
    (test (not (member$ "Sin Parking con coche propio" $?m)))
    =>
    ;; Restamos 50 puntos
    (modify ?r (puntuacion (- ?p 50)) (motivos $?m "Sin Parking con coche propio"))
)


(defrule ASOCIACION::aviso-sin-ascensor
    ?r<-(Recomendacion(vivienda ?v)(puntuacion ?p)(motivos $?m))
    (test (> ?p -150))
    (object (is-a Vivienda) (name ?v) (tiene_ascensor ?a) (altura_piso ?h))
    (test (> ?h 2))
    (test (or (eq ?a NO) (eq ?a FALSE)))
    (test (not (member$ "Sin Ascensor y piso alto" $?m)))
    =>
    (modify ?r (puntuacion (- ?p 50)) (motivos $?m "Sin Ascensor y piso alto"))
)

(defrule ASOCIACION::aviso-anciano-sin-super
    ?r <- (Recomendacion (vivienda ?v) (puntuacion ?p) (motivos $?m))
    (test (> ?p -150)) 
    (object (is-a Solicitante) (edad_mas_anciano ?e&:(> ?e 70)))
    (not (Rasgo (objeto ?v) (caracteristica SERVICIOS) (valor ABASTECIMIENTO)))
    (test (not (member$ "Lejos de supermercados" $?m)))
    =>
    (modify ?r (puntuacion (- ?p 50)) (motivos $?m "Lejos de supermercados"))
)

(defrule ASOCIACION::siguiente (declare (salience -10)) => (focus REFINAMIENTO))


;;; =========================================================
;;; MÓDULO REFINAMIENTO (PUNTUACION FINA Y CLASIFICACION)
;;; =========================================================


(defrule REFINAMIENTO::bonus-distancia 
    ?r<-(Recomendacion(vivienda ?v)(puntuacion ?p)(motivos $?m))
    (test (> ?p -150))
    (object (is-a Solicitante) (trabaja_en_x ?tx) (trabaja_en_y ?ty)) 
    (object (is-a Vivienda) (name ?v) (coordx ?vx) (coordy ?vy)) 
    (test (or (neq ?tx 0.0) (neq ?ty 0.0))) 
    (test (not (or (member$ "Muy cerca" $?m) (member$ "Distancia media" $?m))))
    => 
    (bind ?d (distancia ?tx ?ty ?vx ?vy)) 
    (if (< ?d 1500) then 
        (modify ?r (puntuacion (+ ?p 10)) (motivos $?m "Muy cerca")) 
     else 
        (if (< ?d 3000) then 
            (modify ?r (puntuacion (+ ?p 5)) (motivos $?m "Distancia media")))))

(defrule REFINAMIENTO::recomendar-espacio-extra
    ?r <- (Recomendacion (vivienda ?v) (puntuacion ?p) (motivos $?m))
    (test (> ?p -150))
    
    ;; Detectamos el rasgo "Extra" (> 105%)
    (Rasgo (objeto ?v) (caracteristica SUPERFICIE_REQ) (valor EXTRA))
    
    (test (not (member$ "Espacio extra (>5%)" $?m)))
    =>
    (modify ?r (puntuacion (+ ?p 10)) (motivos $?m "Espacio extra (>5%)"))
)

(defrule REFINAMIENTO::bonus-aire 
    ?r<-(Recomendacion(vivienda ?v)(puntuacion ?p)(motivos $?m))
    (test (> ?p -150)) 
    (object (is-a Vivienda) (name ?v) (tiene_aire_acondicionado ?ac)) 
    (test (or (eq ?ac TRUE) (eq ?ac SI))) (test (not (member$ "Aire" $?m))) 
    => (modify ?r (puntuacion (+ ?p 10)) (motivos $?m "Aire")))

(defrule REFINAMIENTO::bonus-amueblado 
    ?r<-(Recomendacion(vivienda ?v)(puntuacion ?p)(motivos $?m))
    (test (> ?p -150))
    (object (is-a Vivienda) (name ?v) (amueblado ?a)) 
    (test (or (eq ?a TRUE) (eq ?a SI))) (test (not (member$ "Amueblado" $?m))) 
    => (modify ?r (puntuacion (+ ?p 10)) (motivos $?m "Amueblado")))

(defrule REFINAMIENTO::bonus-terraza 
    ?r<-(Recomendacion(vivienda ?v)(puntuacion ?p)(motivos $?m))
    (test (> ?p -150)) 
    (object (is-a Vivienda) (name ?v) (tiene_terraza ?t)) 
    (test (or (eq ?t TRUE) (eq ?t SI))) (test (not (member$ "Terraza" $?m))) 
    => (modify ?r (puntuacion (+ ?p 10)) (motivos $?m "Terraza")))

(defrule REFINAMIENTO::bonus-calefaccion 
    ?r<-(Recomendacion(vivienda ?v)(puntuacion ?p)(motivos $?m))
    (test (> ?p -150)) 
    (object (is-a Vivienda) (name ?v) (tiene_calefaccion ?c)) 
    (test (or (eq ?c TRUE) (eq ?c SI))) (test (not (member$ "Calefaccion" $?m))) 
    => (modify ?r (puntuacion (+ ?p 10)) (motivos $?m "Calefaccion")))

(defrule REFINAMIENTO::bonus-ratio-banos 
    ?r<-(Recomendacion(solicitante ?s)(vivienda ?v)(puntuacion ?p)(motivos $?m))
    (test (> ?p -150)) 
    (object (is-a Solicitante) (num_personas ?np)) 
    (object (is-a Vivienda) (name ?v) (num_banos ?nb)) 
    (test (<= ?np (* ?nb 2))) (test (not (member$ "Ratio Baños" $?m))) 
    => (modify ?r (puntuacion (+ ?p 10)) (motivos $?m "Ratio Baños")))


(defrule REFINAMIENTO::pen-oscuro 
    ?r<-(Recomendacion(vivienda ?v)(puntuacion ?p)(motivos $?m))
    (test (> ?p -150)) 
    (Rasgo(objeto ?v)(caracteristica LUMINOSIDAD)(valor OSCURO)) 
    (test (not (member$ "Piso Oscuro" $?m))) 
    => (modify ?r (puntuacion (- ?p 10)) (motivos $?m "Piso Oscuro")))

(defrule REFINAMIENTO::bonus-eficiencia 
    ?r<-(Recomendacion(vivienda ?v)(puntuacion ?p)(motivos $?m))
    (test (> ?p -150)) 
    (object (is-a Vivienda) (name ?v) (certificado_energetico ?c&:(or (eq ?c A) (eq ?c B)))) 
    (test (not (member$ "Eficiencia" $?m))) 
    => (modify ?r (puntuacion (+ ?p 10)) (motivos $?m "Eficiencia")))


(defrule REFINAMIENTO::recomendar-familia-educacion 
    ?r<-(Recomendacion(vivienda ?v)(puntuacion ?p)(motivos $?m)) 
    (test (> ?p -150))
    (object (is-a Familia)) (Rasgo(objeto ?v)(caracteristica ENTORNO)(valor EDUCATIVO)) 
    (test (not (member$ "Colegios cerca" $?m))) 
    => (modify ?r (puntuacion (+ ?p 10))(motivos $?m "Colegios cerca")))

(defrule REFINAMIENTO::recomendar-estudiante-fiesta 
    ?r<-(Recomendacion(vivienda ?v)(puntuacion ?p)(motivos $?m)) 
    (test (> ?p -150))
    (object (is-a Estudiantes)) (Rasgo(objeto ?v)(caracteristica ENTORNO)(valor RUIDOSO)) 
    (test (not (member$ "Ambiente" $?m))) 
    => (modify ?r (puntuacion (+ ?p 10))(motivos $?m "Ambiente")))

(defrule REFINAMIENTO::bonus-luminosidad-total
    ?r <- (Recomendacion (vivienda ?v) (puntuacion ?p) (motivos $?m))
    (test (> ?p -150))
    
    ;; Detectamos la nueva etiqueta
    (Rasgo (objeto ?v) (caracteristica LUMINOSIDAD) (valor MUY_LUMINOSO))
    
    (test (not (member$ "Muy Luminoso (Sol todo el día)" $?m)))
    =>
    (modify ?r (puntuacion (+ ?p 10)) (motivos $?m "Muy Luminoso (Sol todo el día)"))
)

(defrule REFINAMIENTO::recomendar-estudiante-transporte 
    ?r<-(Recomendacion(vivienda ?v)(puntuacion ?p)(motivos $?m)) 
    (test (> ?p -150))
    (object (is-a Estudiantes)) (Rasgo(objeto ?v)(caracteristica CONECTIVIDAD)(valor RAPIDA)) 
    (test (not (member$ "Buena Comunicación" $?m))) 
    => (modify ?r (puntuacion (+ ?p 10))(motivos $?m "Buena Comunicación")))

(defrule REFINAMIENTO::recomendar-anciano-relax 
    ?r<-(Recomendacion(vivienda ?v)(puntuacion ?p)(motivos $?m)) 
    (test (> ?p -150))
    (object (is-a Solicitante) (edad_mas_anciano ?e&:(> ?e 65))) 
    (Rasgo(objeto ?v)(caracteristica ENTORNO)(valor RELAX)) 
    (test (not (member$ "Zona tranquila" $?m))) 
    => (modify ?r (puntuacion (+ ?p 10))(motivos $?m "Zona tranquila")))

(defrule REFINAMIENTO::recomendar-chollo 
    ?r<-(Recomendacion(vivienda ?v)(puntuacion ?p)(motivos $?m)) 
    (test (> ?p -150))
    (Rasgo(objeto ?v)(caracteristica COSTE)(valor CHOLLO)) 
    (test (not (member$ "Gran precio" $?m))) 
    => (modify ?r (puntuacion (+ ?p 10))(motivos $?m "Gran precio")))

;;; 5. CLASIFICACIÓN FINAL POR PUNTOS 

(defrule REFINAMIENTO::clasificar-descartado
    (declare (salience -100))
    ?r <- (Recomendacion (estado INDETERMINADO) (puntuacion ?p&:(<= ?p -150)))
    =>
    (modify ?r (estado DESCARTADO)))

(defrule REFINAMIENTO::clasificar-parcial
    (declare (salience -100))
    ?r <- (Recomendacion (estado INDETERMINADO) (puntuacion ?p&:(and (> ?p -150) (< ?p 0))))
    =>
    (modify ?r (estado PARCIALMENTE_ADECUADO)))

(defrule REFINAMIENTO::clasificar-valida
    (declare (salience -100))
    ?r <- (Recomendacion (estado INDETERMINADO) (puntuacion ?p&:(and (>= ?p 0) (< ?p 30))))
    =>
    (modify ?r (estado VALID)))

(defrule REFINAMIENTO::clasificar-muy-recomendable
    (declare (salience -100))
    ?r <- (Recomendacion (estado INDETERMINADO) (puntuacion ?p&:(>= ?p 30)))
    =>
    (modify ?r (estado MUY_RECOMENDABLE)))

(defrule REFINAMIENTO::Siguiente (declare (salience -200)) => (focus INFORME))

;;; =========================================================
;;; MÓDULO INFORME
;;; =========================================================

(defrule INFORME::print 
    ?r<-(Recomendacion(vivienda ?v)(estado ?e)(puntuacion ?p)(motivos $?m)) 
    (test (neq ?e DESCARTADO)) 
    => 
    (printout t "VIVIENDA: " ?v " | Puntos: " ?p " | " ?e crlf) 
    (if (> (length$ $?m) 0) then (printout t "    " (implode$ $?m) crlf)) 
    (printout t "-----------------------------------------" crlf))

(defrule INFORME::fin (declare (salience -10)) => (printout t ">>> Fin." crlf))