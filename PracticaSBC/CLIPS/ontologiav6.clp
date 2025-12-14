;;; =========================================================
;;; ONTOLOGIA DEFINITIVA
;;; =========================================================

;;; ---------------------------------------------------------
;;; CLASE PADRE: SOLICITANTE
;;; ---------------------------------------------------------
(defclass Solicitante
    (is-a USER) (role concrete) (pattern-match reactive)

    ;;; --- 1. DATOS INTELIGENTES ---
    (slot situacion_laboral (type SYMBOL) (allowed-values ESTUDIANTE TRABAJADOR JUBILADO DESEMPLEADO) (create-accessor read-write))
    (slot num_personas (type INTEGER) (default 1) (create-accessor read-write))
    (multislot edades_inquilinos (type INTEGER) (create-accessor read-write))
    (slot relacion (type SYMBOL) (allowed-values INDIVIDUO PAREJA AMIGOS FAMILIA) (create-accessor read-write))
    (slot presupuesto_esperado (type FLOAT) (create-accessor read-write))
    (slot superficie_deseada (type FLOAT) (create-accessor read-write)) 
    (slot tiene_mascota (type SYMBOL) (allowed-values SI NO TRUE FALSE) (create-accessor read-write))
    (slot teletrabajo (type SYMBOL) (allowed-values SI NO TRUE FALSE) (create-accessor read-write))
    (slot necesita_muebles (type SYMBOL) (allowed-values SI NO INDIFERENTE) (create-accessor read-write))
    (slot movilidad_reducida (type SYMBOL) (allowed-values SI NO TRUE FALSE) (create-accessor read-write))
    (slot trabaja_en_x (type FLOAT) (create-accessor read-write))
    (slot trabaja_en_y (type FLOAT) (create-accessor read-write))
    (slot medio_transporte_principal (type SYMBOL) (create-accessor read-write))
    (slot presupuesto_maximo (type FLOAT) (create-accessor read-write))
    (slot edad_mas_anciano (type INTEGER) (create-accessor read-write))
    (slot trabaja_en_casa (type SYMBOL) (allowed-values SI NO TRUE FALSE) (create-accessor read-write)) 
    (slot tiene_coche (type SYMBOL) (create-accessor read-write))
    (multislot prefiere_cerca (type SYMBOL) (create-accessor read-write))
    (slot techo_maximo_seguro (type FLOAT) (create-accessor read-write))
    (slot exigencia_termica (type SYMBOL) (allowed-values NORMAL CRITICA) (create-accessor read-write))
)

;;; SUBCLASES SOLICITANTE
(defclass Familia (is-a Solicitante) (role concrete) (pattern-match reactive)
    (slot num_hijos (type INTEGER) (create-accessor read-write))
    (slot nombre_colegio_asignado (type STRING) (create-accessor read-write)))

(defclass Estudiantes (is-a Solicitante) (role concrete) (pattern-match reactive)
    (slot necesita_fiesta (type SYMBOL) (allowed-values SI NO) (create-accessor read-write)))

(defclass Pareja (is-a Solicitante) (role concrete) (pattern-match reactive)
    (slot plan_familia_corto_plazo (type SYMBOL) (create-accessor read-write)))

(defclass CoLiving (is-a Solicitante) (role concrete) (pattern-match reactive)
    (slot bano_privado (type SYMBOL) (allowed-values SI NO) (create-accessor read-write))
    (slot habitaciones_individuales (type SYMBOL) (allowed-values SI NO) (create-accessor read-write)))

(defclass Individuo (is-a Solicitante) (role concrete) (pattern-match reactive))


;;; ---------------------------------------------------------
;;; CLASE VIVIENDA
;;; ---------------------------------------------------------
(defclass Vivienda
    (is-a USER) (role concrete) (pattern-match reactive)

    (slot precio_mensual (type FLOAT) (create-accessor read-write))
    (slot superficie (type FLOAT) (create-accessor read-write))
    (slot num_habs_dobles (type INTEGER) (create-accessor read-write))
    (slot num_habs_individual (type INTEGER) (create-accessor read-write))
    (slot num_banos (type INTEGER) (create-accessor read-write))
    (slot tiene_ascensor (type SYMBOL) (allowed-values SI NO TRUE FALSE) (create-accessor read-write))
    (slot tiene_terraza (type SYMBOL) (allowed-values SI NO TRUE FALSE) (create-accessor read-write))
    (slot amueblado (type SYMBOL) (allowed-values SI NO TRUE FALSE) (create-accessor read-write))
    (slot permite_mascotas (type SYMBOL) (create-accessor read-write))
    (slot tiene_aire_acondicionado (type SYMBOL) (allowed-values SI NO TRUE FALSE) (create-accessor read-write))
    (slot tiene_calefaccion (type SYMBOL) (allowed-values SI NO TRUE FALSE) (create-accessor read-write))
    (slot tiene_parking (type SYMBOL) (allowed-values SI NO TRUE FALSE) (create-accessor read-write))
    (slot es_soleado (type STRING) (create-accessor read-write))
    (slot coordx (type FLOAT) (create-accessor read-write))
    (slot coordy (type FLOAT) (create-accessor read-write))
    (slot altura_piso (type INTEGER) (create-accessor read-write))
    
    (multislot tiene_servicio_cercano (type INSTANCE) (create-accessor read-write))

    (slot certificado_energetico (type SYMBOL) (allowed-values A B C D E F G DESCONOCIDO) (create-accessor read-write))
    (slot acceso_portal (type SYMBOL) (allowed-values COTA_CERO RAMPA ESCALONES) (create-accessor read-write))

    
)

;;; SUBCLASES VIVIENDA
(defclass Bloque (is-a Vivienda) (role concrete) (pattern-match reactive))
(defclass Dúplex (is-a Bloque) (role concrete) (pattern-match reactive))
(defclass Piso (is-a Bloque) (role concrete) (pattern-match reactive))
(defclass Estudio (is-a Bloque) (role concrete) (pattern-match reactive))
(defclass Atico (is-a Piso) (role concrete) (pattern-match reactive))
(defclass Bajo (is-a Piso) (role concrete) (pattern-match reactive)
    (slot tiene_rejas (type SYMBOL) (allowed-values SI NO) (create-accessor read-write)))
(defclass Intermedio (is-a Piso) (role concrete) (pattern-match reactive))

(defclass Unifamiliar (is-a Vivienda) (role concrete) (pattern-match reactive))

;;; CLASES SERVICIOS
(defclass Servicio (is-a USER) (role concrete) (pattern-match reactive)
    (slot servicio_en_x (type FLOAT)) 
    (slot servicio_en_y (type FLOAT)) 
    (slot nombre_servicio (type STRING)))

(defclass Educacion (is-a Servicio) (role concrete))
(defclass Colegio (is-a Educacion) (role concrete))
(defclass Instituto (is-a Educacion) (role concrete))
(defclass Universidad (is-a Educacion) (role concrete))
(defclass Salud (is-a Servicio) (role concrete))
(defclass Centro_Salud (is-a Salud) (role concrete))
(defclass Hospital (is-a Salud) (role concrete))
(defclass Ocio (is-a Servicio) (role concrete))
(defclass Cine (is-a Ocio) (role concrete))
(defclass Zona_Nocturna (is-a Ocio) (role concrete))
(defclass Restaurante (is-a Ocio) (role concrete))
(defclass Comercio (is-a Servicio) (role concrete))
(defclass Supermercado (is-a Comercio) (role concrete))
(defclass Centro_Comercial (is-a Comercio) (role concrete))
(defclass Transporte (is-a Servicio) (role concrete))
(defclass Parada_Metro (is-a Transporte) (role concrete))
(defclass Parada_Autobús (is-a Transporte) (role concrete))
(defclass Estación_Tren (is-a Transporte) (role concrete))
(defclass Zona_Verde (is-a Servicio) (role concrete))
(defclass Parque (is-a Zona_Verde) (role concrete))