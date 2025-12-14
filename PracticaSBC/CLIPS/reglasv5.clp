;;; =========================================================
;;; SISTEMA EXPERTO FINAL (SIN BUCLES INFINITOS)
;;; =========================================================

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
    (printout t "   SISTEMA EXPERTO INMOBILIARIO            " crlf)
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
    (send ?s put-ingresos_mensuales (ask-float "5. Ingresos netos mensuales del hogar (€):"))
    (send ?s put-presupuesto_esperado (ask-float "6. Alquiler deseado aproximado (€):"))
    
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
        (printout t "10. Ubicacion Trabajo/Interes (X Y):" crlf)
        (send ?s put-trabaja_en_x (ask-float "    X: "))
        (send ?s put-trabaja_en_y (ask-float "    Y: "))
    )
    
    (bind ?tr (ask-choice "11. Transporte principal:" (create$ publico coche moto andando bici)))
    (send ?s put-medio_transporte_principal ?tr)
    (if (or (eq ?tr coche) (yes-or-no-p "    ¿Tienes coche?")) then 
        (send ?s put-num_coches (ask-int "    ¿Cuantos coches?")) 
        (send ?s put-tiene_coche TRUE)
    else 
        (send ?s put-num_coches 0)
        (send ?s put-tiene_coche FALSE))

    (if (or (eq ?tr moto) (yes-or-no-p "    ¿Tienes moto?")) then (send ?s put-num_motos (ask-int "    ¿Cuantas motos?")) else (send ?s put-num_motos 0))
    
    (send ?s put-dias_para_mudanza (ask-int "12. ¿En cuantos dias necesitas mudarte?"))
    
    (bind ?mr (yes-or-no-p "13. ¿Movilidad reducida (o silla bebe)?"))
    (send ?s put-movilidad_reducida (if ?mr then SI else NO))

    ;; Calc Edad Anciano Legacy
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

(defrule PREGUNTAS::Esp-Familia 
    (FaseEntrevista (estado especificas)) 
    ?s <- (object (is-a Familia) (nombre_colegio_asignado ?c&:(or (eq ?c nil) (eq ?c "")))) 
    =>
    (if (yes-or-no-p "F. ¿Teneis colegio asignado en la zona?") then 
        (send ?s put-nombre_colegio_asignado "SI") (slot-insert$ ?s prefiere_cerca 1 Colegio) 
    else (send ?s put-nombre_colegio_asignado "NO")))

(defrule PREGUNTAS::Esp-Estudiante 
    (FaseEntrevista (estado especificas)) 
    ?s <- (object (is-a Estudiantes) ) 
    =>
    (send ?s put-necesita_fiesta (if (yes-or-no-p "E. ¿Buscas zona de ambiente?") then SI else NO)))

(defrule PREGUNTAS::Esp-CoLiving 
    (FaseEntrevista (estado especificas)) 
    ?s <- (object (is-a CoLiving) ) 
    =>
    (send ?s put-bano_privado (if (yes-or-no-p "C. ¿Baño privado imprescindible?") then SI else NO))
    (send ?s put-habitaciones_individuales (if (yes-or-no-p "C. ¿Necesitais habitaciones individuales todos?") then SI else NO)))

(defrule PREGUNTAS::Esp-Pareja 
    (FaseEntrevista (estado especificas)) 
    ?s <- (object (is-a Pareja) ) 
    =>
    (send ?s put-plan_familia_corto_plazo (if (yes-or-no-p "P. ¿Planeais hijos a corto plazo?") then SI else NO)))


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
    (declare (salience 30)) ;; Prioridad alta para ejecutarse antes de analizar el entorno
    
    ;; Capturamos la vivienda y su lista actual de servicios
    ?v <- (object (is-a Vivienda) (coordx ?vx) (coordy ?vy) (tiene_servicio_cercano $?lista))
    
    ;; Capturamos un servicio cualquiera
    (object (is-a Servicio) (name ?s) (servicio_en_x ?sx) (servicio_en_y ?sy))
    
    ;; Comprobamos distancia (500 metros)
    (test (< (distancia ?vx ?vy ?sx ?sy) 500))
    
    ;; Comprobamos que NO esté ya en la lista para no duplicar
    (test (not (member$ ?s $?lista)))
    =>
    ;; Añadimos el servicio a la lista de la vivienda
    (slot-insert$ ?v tiene_servicio_cercano 1 ?s)
)

(defrule ABSTRACCION::Calculo-Financiero
    (declare (salience 20))
    ?s <- (object (is-a Solicitante)
                  (ingresos_mensuales ?i)
                  (techo_maximo_seguro ?t))
    ;; Algunos CLIPS inicializan FLOAT sin valor como 0.0 en vez de nil.
    ;; Con esto calculamos una sola vez (cuando esté sin calcular).
    (test (if (numberp ?t) then (<= ?t 0) else TRUE))
    =>
    (bind ?ratio 0.35)
    (if (< ?i 1500) then (bind ?ratio 0.30)
     else (if (> ?i 3000) then (bind ?ratio 0.40)))
    (bind ?techo (* ?i ?ratio))
    (send ?s put-techo_maximo_seguro ?techo)
    (send ?s put-presupuesto_maximo ?techo)
)

(defrule ABSTRACCION::Calculo-Termico
    (declare (salience 20))
    ?s <- (object (is-a Solicitante) (edades_inquilinos $?e) (exigencia_termica ?x&:(eq ?x nil)))
    =>
    (bind ?critica FALSE) 
    (progn$ (?edad ?e) (if (or (< ?edad 4) (> ?edad 70)) then (bind ?critica TRUE)))
    (if ?critica then (send ?s put-exigencia_termica CRITICA) else (send ?s put-exigencia_termica NORMAL))
)

(defrule ABSTRACCION::Inferir-Urgencia
    (declare (salience 20))
    ?s <- (object (is-a Solicitante) (dias_para_mudanza ?d) (nivel_urgencia ?u&:(eq ?u nil)))
    =>
    (if (< ?d 15) then (send ?s put-nivel_urgencia ALTA)
     else (if (< ?d 45) then (send ?s put-nivel_urgencia MEDIA)
     else (send ?s put-nivel_urgencia BAJA)))
)

;;; --- GENERACIÓN DE RASGOS (Input para Asociación) ---

(defrule ABSTRACCION::Gen-Rasgo-Coste
    (object (is-a Solicitante) (techo_maximo_seguro ?max))
    (object (is-a Vivienda) (name ?v) (precio_mensual ?p)) 
    (test (if (numberp ?max) then (> ?max 0) else FALSE)) 
    (not (Rasgo (objeto ?v) (caracteristica COSTE))) 
    =>
    (if (> ?p (+ ?max 200)) then 
        ;; Se pasa por más de 200 -> IMPAGABLE (Se descartará)
        (assert (Rasgo (objeto ?v) (caracteristica COSTE) (valor IMPAGABLE)))
    else 
        (if (> ?p ?max) then 
            ;; Se pasa, pero poco (<= 200) -> CARO (Se avisará)
            (assert (Rasgo (objeto ?v) (caracteristica COSTE) (valor CARO)))
        else 
            (if (<= ?p (- ?max 200)) then 
                ;; Muy barato -> CHOLLO
                (assert (Rasgo (objeto ?v) (caracteristica COSTE) (valor CHOLLO)))
            )
        )
    )
)

(defrule ABSTRACCION::Gen-Rasgo-Accesibilidad
    (object (is-a Vivienda) (name ?v) (tiene_ascensor ?asc) (acceso_portal ?portal) (altura_piso ?h))
    (not (Rasgo (objeto ?v) (caracteristica ACCESIBILIDAD))) ;; Evita bucle
    =>
    (bind ?mala FALSE)
    (if (eq ?portal ESCALONES) then (bind ?mala TRUE))
    (if (and (> ?h 0) (or (eq ?asc NO) (eq ?asc FALSE))) then (bind ?mala TRUE))
    
    (if ?mala then (assert (Rasgo (objeto ?v) (caracteristica ACCESIBILIDAD) (valor MALA))))
)

(defrule ABSTRACCION::Gen-Rasgo-Confort-Termico
    (object (is-a Vivienda) (name ?v) (tiene_calefaccion ?cal) (certificado_energetico ?cert))
    (not (Rasgo (objeto ?v) (caracteristica CONFORT))) ;; Evita bucle
    =>
    (if (or (eq ?cal NO) (eq ?cal FALSE) (eq ?cert F) (eq ?cert G)) then
        (assert (Rasgo (objeto ?v) (caracteristica CONFORT) (valor BAJO)))
    else (if (or (eq ?cert A) (eq ?cert B)) then
        (assert (Rasgo (objeto ?v) (caracteristica CONFORT) (valor ALTO)))))
)


(defrule ABSTRACCION::abs-espacio-hacinado 
    (object (is-a Solicitante) (num_personas ?np)) 
    (object (is-a Vivienda) (name ?v) (num_habs_dobles ?d) (num_habs_individual ?i))
    (test (> ?np (+ (* ?d 2) ?i)))
    (not (Rasgo (objeto ?v) (caracteristica ESPACIO)))
    => (assert (Rasgo (objeto ?v) (caracteristica ESPACIO) (valor INSUFICIENTE))))

(defrule ABSTRACCION::abs-mascotas 
    (object (is-a Vivienda) (name ?v) (permite_mascotas ?m))
    (test (or (eq ?m NO) (eq ?m FALSE)))
    (not (Rasgo (objeto ?v) (caracteristica POLITICA))) 
    => (assert (Rasgo (objeto ?v) (caracteristica POLITICA) (valor NO_MASCOTAS))))

(defrule ABSTRACCION::abs-luz-pobre 
    (object (is-a Vivienda) (name ?v) (es_soleado "Nada"))
    (not (Rasgo (objeto ?v) (caracteristica LUMINOSIDAD)))
    => (assert (Rasgo (objeto ?v) (caracteristica LUMINOSIDAD) (valor OSCURO))))

(defrule ABSTRACCION::abs-servicios-educacion (object (is-a Vivienda) (name ?v) (tiene_servicio_cercano $?s)) (exists (object (is-a Educacion) (name ?e)) (test (member$ ?e ?s))) (not (Rasgo (objeto ?v) (caracteristica ENTORNO) (valor EDUCATIVO))) => (assert (Rasgo (objeto ?v) (caracteristica ENTORNO) (valor EDUCATIVO))))
(defrule ABSTRACCION::abs-servicios-ocio (object (is-a Vivienda) (name ?v) (tiene_servicio_cercano $?s)) (exists (object (is-a Zona_Nocturna) (name ?zn)) (test (member$ ?zn ?s))) (not (Rasgo (objeto ?v) (caracteristica ENTORNO) (valor RUIDOSO))) => (assert (Rasgo (objeto ?v) (caracteristica ENTORNO) (valor RUIDOSO))))
(defrule ABSTRACCION::abs-servicios-relax (object (is-a Vivienda) (name ?v) (tiene_servicio_cercano $?s)) (exists (object (is-a Zona_Verde) (name ?zv)) (test (member$ ?zv ?s))) (not (Rasgo (objeto ?v) (caracteristica ENTORNO) (valor RELAX))) => (assert (Rasgo (objeto ?v) (caracteristica ENTORNO) (valor RELAX))))
(defrule ABSTRACCION::abs-zona-comercial (object (is-a Vivienda) (name ?v) (tiene_servicio_cercano $?s)) (exists (object (is-a Supermercado) (name ?sup)) (test (member$ ?sup ?s))) (not (Rasgo (objeto ?v) (caracteristica SERVICIOS) (valor ABASTECIMIENTO))) => (assert (Rasgo (objeto ?v) (caracteristica SERVICIOS) (valor ABASTECIMIENTO))))
(defrule ABSTRACCION::abs-transporte-metro (object (is-a Vivienda) (name ?v) (tiene_servicio_cercano $?s)) (exists (object (is-a Parada_Metro) (name ?m)) (test (member$ ?m ?s))) (not (Rasgo (objeto ?v) (caracteristica CONECTIVIDAD) (valor RAPIDA))) => (assert (Rasgo (objeto ?v) (caracteristica CONECTIVIDAD) (valor RAPIDA))))
(defrule ABSTRACCION::abs-transporte-solo-bus (object (is-a Vivienda) (name ?v) (tiene_servicio_cercano $?s)) (exists (object (is-a Parada_Autobús) (name ?b)) (test (member$ ?b ?s))) (not (exists (object (is-a Parada_Metro) (name ?m)) (test (member$ ?m ?s)))) (not (Rasgo (objeto ?v) (caracteristica CONECTIVIDAD) (valor LENTA))) => (assert (Rasgo (objeto ?v) (caracteristica CONECTIVIDAD) (valor LENTA))))

(defrule ABSTRACCION::abs-piso-bajo 
    (object (is-a Vivienda) (name ?v) (altura_piso 0)) 
    (not (Rasgo (objeto ?v) (caracteristica TIPOLOGIA) (valor BAJOS)))
    => (assert (Rasgo (objeto ?v) (caracteristica TIPOLOGIA) (valor BAJOS))))

(defrule ABSTRACCION::abs-piso-atico 
    (object (is-a Vivienda) (name ?v) (tiene_terraza ?t) (altura_piso ?h)) 
    (test (and (or (eq ?t TRUE) (eq ?t SI)) (> ?h 5)))
    (not (Rasgo (objeto ?v) (caracteristica TIPOLOGIA) (valor ATICO)))
    => (assert (Rasgo (objeto ?v) (caracteristica TIPOLOGIA) (valor ATICO))))

(defrule ABSTRACCION::siguiente 
    (declare (salience -10)) 
    => 
    (focus ASOCIACION)
)



;;; =========================================================
;;; MÓDULO ASOCIACION (OPTIMIZADO CON CORTE POR PUNTUACIÓN)
;;; =========================================================

(defrule ASOCIACION::init-recom 
    (object (is-a Solicitante) (name ?s)) 
    (object (is-a Vivienda) (name ?v)) 
    => (assert (Recomendacion (solicitante ?s) (vivienda ?v) (estado INDETERMINADO) (puntuacion 0))))

;;; A. RESTRICCIONES DURAS -> RESTAN 150 PUNTOS
;;; Se añade (test (> ?p -150)) para no seguir machacando si ya está descartada

(defrule ASOCIACION::filtrar-precio 
    ?r<-(Recomendacion(vivienda ?v)(puntuacion ?p)(motivos $?m)) 
    (test (> ?p -150)) ;; <-- CONDICIÓN DE CORTE
    (Rasgo(objeto ?v)(caracteristica COSTE)(valor IMPAGABLE)) 
    (test (not (member$ "Presupuesto insuficiente" $?m)))
    => (modify ?r (puntuacion (- ?p 150))(motivos $?m "Presupuesto insuficiente")))

(defrule ASOCIACION::filtrar-sin-muebles
    ?r<-(Recomendacion(vivienda ?v)(puntuacion ?p)(motivos $?m))
    (test (> ?p -150)) ;; Solo comprobamos si la vivienda sigue viva
    
    (object (is-a Solicitante) (necesita_muebles SI))
    (object (is-a Vivienda) (name ?v) (amueblado ?a))
    (test (or (eq ?a NO) (eq ?a FALSE)))
    
    ;; Evitar duplicados
    (test (not (member$ "Requiere muebles" $?m)))
    =>
    ;; Penalización dura
    (modify ?r (puntuacion (- ?p 150)) (motivos $?m "Requiere muebles"))
)

(defrule ASOCIACION::filtrar-espacio 
    ?r<-(Recomendacion(vivienda ?v)(puntuacion ?p)(motivos $?m)) 
    (test (> ?p -150))
    (Rasgo(objeto ?v)(caracteristica ESPACIO)(valor INSUFICIENTE)) 
    (test (not (member$ "Hacinamiento" $?m)))
    => (modify ?r (puntuacion (- ?p 150))(motivos $?m "Hacinamiento")))

(defrule ASOCIACION::filtrar-mascota-prohibida 
    ?r<-(Recomendacion(vivienda ?v)(puntuacion ?p)(motivos $?m)) 
    (test (> ?p -150))
    (object (is-a Solicitante) (tiene_mascota SI)) 
    (Rasgo(objeto ?v)(caracteristica POLITICA)(valor NO_MASCOTAS)) 
    (test (not (member$ "No admiten mascotas" $?m)))
    => (modify ?r (puntuacion (- ?p 150))(motivos $?m "No admiten mascotas")))

(defrule ASOCIACION::filtrar-accesibilidad-ancianos-mobilidad-reducida 
    ?r<-(Recomendacion(vivienda ?v)(puntuacion ?p)(motivos $?m)) 
    (test (> ?p -150))
    ;; Capturamos edad y movilidad
    (object (is-a Solicitante) (edad_mas_anciano ?e) (movilidad_reducida ?mr)) 
    ;; Se activa si: Es mayor de 70 O tiene movilidad reducida (SI/TRUE)
    (test (or (> ?e 70) (eq ?mr SI) (eq ?mr TRUE)))
    
    (Rasgo(objeto ?v)(caracteristica ACCESIBILIDAD)(valor MALA)) 
    (test (not (member$ "Barreras arquitectónicas (Ancianos/Movilidad)" $?m)))
    => 
    (modify ?r (puntuacion (- ?p 150))(motivos $?m "Barreras arquitectónicas (Ancianos/Movilidad)")))

(defrule ASOCIACION::filtrar-duplex-ancianos-mobilidad-reducida 
    ?r<-(Recomendacion(vivienda ?v)(puntuacion ?p)(motivos $?m)) 
    (test (> ?p -150))
    ;; Capturamos edad y movilidad
    (object (is-a Solicitante) (edad_mas_anciano ?e) (movilidad_reducida ?mr))
    ;; Se activa si: Es mayor de 75 O tiene movilidad reducida
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
    (not (exists (object (is-a Transporte) (name ?t)) 
                 (test (member$ ?t $?servicios))))
    (test (not (member$ "Sin transporte público cercano" $?m)))
    =>
    (modify ?r (puntuacion (- ?p 150)) (motivos $?m "Sin transporte público cercano"))
)

;;; B. AVISOS -> RESTAN 50 PUNTOS
;;; También comprobamos puntuación para no gastar tiempo en casas ya descartadas

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
    (object (is-a Vivienda) (name ?v) (tiene_terraza ?t)) (test (or (eq ?t FALSE) (eq ?t NO))) 
    (Rasgo(objeto ?v)(caracteristica TIPOLOGIA)(valor BAJOS)) 
    (test (not (member$ "Mascota sin exterior" $?m))) 
    => (modify ?r (puntuacion (- ?p 50))(motivos $?m "Mascota sin exterior")))

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

(defrule ASOCIACION::aviso-coche-parking 
    ?r<-(Recomendacion(vivienda ?v)(puntuacion ?p)(motivos $?m)) 
    (test (> ?p -150))
    (object (is-a Solicitante) (tiene_coche TRUE)) (test (neq (class ?v) Unifamiliar)) 
    (not (Rasgo(objeto ?v)(caracteristica ZONA)(valor COMERCIAL))) 
    (test (not (member$ "Dificil aparcar" $?m))) 
    => (modify ?r (puntuacion (- ?p 50))(motivos $?m "Dificil aparcar")))

(defrule ASOCIACION::aviso-individuo-bajos 
    ?r<-(Recomendacion(vivienda ?v)(puntuacion ?p)(motivos $?m)) 
    (test (> ?p -150))
    (object (is-a Individuo)) 
    (Rasgo(objeto ?v)(caracteristica TIPOLOGIA)(valor BAJOS)) 
    (test (not (member$ "Seguridad Bajos" $?m))) 
    => (modify ?r (puntuacion (- ?p 50))(motivos $?m "Seguridad Bajos")))

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


(defrule REFINAMIENTO::original-seguridad-bajos 
    ?r<-(Recomendacion(vivienda ?v)(puntuacion ?p)(motivos $?m))
    (test (> ?p -150)) 
    (object (is-a Bajo) (name ?v) (tiene_rejas NO)) 
    (test (not (member$ "Inseguridad" $?m))) 
    => (modify ?r (puntuacion (- ?p 20)) (motivos $?m "Inseguridad")))

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

(defrule REFINAMIENTO::recomendar-estudiante-transporte 
    ?r<-(Recomendacion(vivienda ?v)(puntuacion ?p)(motivos $?m)) 
    (test (> ?p -150))
    (object (is-a Estudiantes)) (Rasgo(objeto ?v)(caracteristica CONECTIVIDAD)(valor RAPIDA)) 
    (test (not (member$ "Conexión Uni" $?m))) 
    => (modify ?r (puntuacion (+ ?p 10))(motivos $?m "Conexión Uni")))

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

(defrule REFINAMIENTO::recomendar-pareja-atico 
    ?r<-(Recomendacion(vivienda ?v)(puntuacion ?p)(motivos $?m)) 
    (test (> ?p -150))
    (object (is-a Pareja)) (Rasgo(objeto ?v)(caracteristica TIPOLOGIA)(valor ATICO)) 
    (test (not (member$ "Ático" $?m))) 
    => (modify ?r (puntuacion (+ ?p 10))(motivos $?m "Ático")))

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