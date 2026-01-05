(define (domain extension3)

    (:requirements :strips :typing :adl :equality :fluents)

    (:types reserva habitacion dia - object)

    (:predicates 
        (asignada ?r - reserva)
        (ocupada ?h - habitacion ?d - dia)
        (dia-reserva ?d - dia ?r - reserva)
        (procesada ?r - reserva )
    )

    (:functions
        ;; cuánta gente cabe en la habitación
        (capacidad ?h - habitacion)
        ;; cuánta gente tiene la reserva
        (personas ?r - reserva)
        ;; coste de la asignación
        (beneficio)
    )

    (:action asignar
        :parameters (?r - reserva ?h - habitacion)
        :precondition (and
            (not (procesada ?r))
            (>= (capacidad ?h) (personas ?r))
            (forall (?d - dia) 
                (imply (dia-reserva ?d ?r) (not (ocupada ?h ?d))))
        )
        :effect (and
            (asignada ?r)
            (forall (?d - dia) 
                (when (dia-reserva ?d ?r) (ocupada ?h ?d)))
            (procesada ?r)
            (increase (beneficio) 10) ;; Puntos base: Asignar es mucho mejor que descartar (+10)
            (decrease (beneficio) (- (capacidad ?h) (personas ?r))) ;; Puntos negativos: Desperdicio de plazas
        )
    )

    (:action descartar
        :parameters (?r - reserva)
        :precondition (not (procesada ?r))
        :effect (procesada ?r)
    )
)

;; GOAL: (forall (reserva ?r) (procesada ?r))
;; -> MAXIMIZE beneficio