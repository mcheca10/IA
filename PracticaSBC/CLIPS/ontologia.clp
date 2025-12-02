;;; ---------------------------------------------------------
;;; /mnt/c/Users/marti/checa-owl/ontologia.clp
;;; Translated by owl2clips
;;; Translated to CLIPS from ontology /mnt/c/Users/marti/checa-owl/ontologia.ttl
;;; :Date 02/12/2025 14:46:55

(defclass Vivienda
    (is-a USER)
    (role concrete)
    (pattern-match reactive)
    ;;; Si una vivienda tiene una distancia menor a 500 a un servicio
    (multislot tiene_servicio_cercano
        (type INSTANCE)
        (create-accessor read-write))
    (multislot altura_piso
        (type INTEGER)
        (create-accessor read-write))
    (multislot amueblado
        (type SYMBOL)
        (create-accessor read-write))
    (multislot coordx
        (type FLOAT)
        (create-accessor read-write))
    (multislot coordy
        (type FLOAT)
        (create-accessor read-write))
    ;;; Tiene diferentes valores: Mañana, Tarde, Todo el día
    (multislot es_soleado
        (type STRING)
        (create-accessor read-write))
    (multislot num_banos
        (type INTEGER)
        (create-accessor read-write))
    (multislot num_habs_dobles
        (type INTEGER)
        (create-accessor read-write))
    (multislot num_habs_individual
        (type INTEGER)
        (create-accessor read-write))
    (multislot permite_mascotas
        (type SYMBOL)
        (create-accessor read-write))
    (multislot precio_mensual
        (type INTEGER)
        (create-accessor read-write))
    (multislot superficie
        (type INTEGER)
        (create-accessor read-write))
    (multislot tiene_aire_acondicionado
        (type SYMBOL)
        (create-accessor read-write))
    (multislot tiene_ascensor
        (type SYMBOL)
        (create-accessor read-write))
    (multislot tiene_calefaccion
        (type SYMBOL)
        (create-accessor read-write))
    (multislot tiene_terraza
        (type SYMBOL)
        (create-accessor read-write))
)

(defclass Dúplex
    (is-a Vivienda)
    (role concrete)
    (pattern-match reactive)
)

(defclass Piso
    (is-a Vivienda)
    (role concrete)
    (pattern-match reactive)
)

(defclass Unifamiliar
    (is-a Vivienda)
    (role concrete)
    (pattern-match reactive)
)

(defclass Solicitante
    (is-a USER)
    (role concrete)
    (pattern-match reactive)
    (multislot busca_vivienda
        (type SYMBOL)
        (create-accessor read-write))
    (multislot edad_mas_anciano
        (type INTEGER)
        (create-accessor read-write))
    (multislot movilidad_reducida
        (type SYMBOL)
        (create-accessor read-write))
    (multislot num_personas
        (type INTEGER)
        (create-accessor read-write))
    (multislot precio_minimo
        (type INTEGER)
        (create-accessor read-write))
    (multislot prefiere_cerca
        (type SYMBOL)
        (create-accessor read-write))
    (multislot presupuesto_flexible
        (type SYMBOL)
        (create-accessor read-write))
    (multislot presupuesto_maximo
        (type INTEGER)
        (create-accessor read-write))
    (multislot superficie_minima
        (type INTEGER)
        (create-accessor read-write))
    (multislot tiene_coche
        (type SYMBOL)
        (create-accessor read-write))
    (multislot tiene_mascota
        (type SYMBOL)
        (create-accessor read-write))
    (multislot trabaja_en_casa
        (type SYMBOL)
        (create-accessor read-write))
    (multislot trabaja_en_x
        (type FLOAT)
        (create-accessor read-write))
    (multislot trabaja_en_y
        (type FLOAT)
        (create-accessor read-write))
)

(defclass Estudiantes
    (is-a Solicitante)
    (role concrete)
    (pattern-match reactive)
)

(defclass Familia
    (is-a Solicitante)
    (role concrete)
    (pattern-match reactive)
    (multislot edad_hijo_menor
        (type INTEGER)
        (create-accessor read-write))
    (multislot num_hijos
        (type INTEGER)
        (create-accessor read-write))
)

(defclass Individuo
    (is-a Solicitante)
    (role concrete)
    (pattern-match reactive)
)

(defclass Pareja
    (is-a Solicitante)
    (role concrete)
    (pattern-match reactive)
)

(defclass Servicio
    (is-a USER)
    (role concrete)
    (pattern-match reactive)
    (multislot servicio_en_x
        (type FLOAT)
        (create-accessor read-write))
    (multislot servicio_en_y
        (type FLOAT)
        (create-accessor read-write))
    (multislot nombre_servicio
        (type STRING)
        (create-accessor read-write))
)

(defclass Comercio
    (is-a Servicio)
    (role concrete)
    (pattern-match reactive)
)

(defclass Centro_Comercial
    (is-a Comercio)
    (role concrete)
    (pattern-match reactive)
)

(defclass Hipermercado
    (is-a Comercio)
    (role concrete)
    (pattern-match reactive)
)

(defclass Supermercado
    (is-a Comercio)
    (role concrete)
    (pattern-match reactive)
)

(defclass Educacion
    (is-a Servicio)
    (role concrete)
    (pattern-match reactive)
)

(defclass Colegio
    (is-a Educacion)
    (role concrete)
    (pattern-match reactive)
)

(defclass Instituto
    (is-a Educacion)
    (role concrete)
    (pattern-match reactive)
)

(defclass Universidad
    (is-a Educacion)
    (role concrete)
    (pattern-match reactive)
)

(defclass Ocio
    (is-a Servicio)
    (role concrete)
    (pattern-match reactive)
)

(defclass Cine
    (is-a Ocio)
    (role concrete)
    (pattern-match reactive)
)

(defclass Restaurante
    (is-a Ocio)
    (role concrete)
    (pattern-match reactive)
)

(defclass Zona_Nocturna
    (is-a Ocio)
    (role concrete)
    (pattern-match reactive)
)

(defclass Salud
    (is-a Servicio)
    (role concrete)
    (pattern-match reactive)
)

(defclass Centro_Salud
    (is-a Salud)
    (role concrete)
    (pattern-match reactive)
)

(defclass Hospital
    (is-a Salud)
    (role concrete)
    (pattern-match reactive)
)

(defclass Transporte
    (is-a Servicio)
    (role concrete)
    (pattern-match reactive)
)

(defclass Estación_Tren
    (is-a Transporte)
    (role concrete)
    (pattern-match reactive)
)

(defclass Parada_Autobús
    (is-a Transporte)
    (role concrete)
    (pattern-match reactive)
)

(defclass Parada_Metro
    (is-a Transporte)
    (role concrete)
    (pattern-match reactive)
)

(defclass Zona_Verde
    (is-a Servicio)
    (role concrete)
    (pattern-match reactive)
)

(defclass Parque
    (is-a Zona_Verde)
    (role concrete)
    (pattern-match reactive)
)
