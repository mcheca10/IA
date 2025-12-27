(define (domain dominioHotelExtension2)
  (:requirements :strips :typing :adl :fluents)

  (:types reserva habitacion orientacion - object)

  (:constants norte sur este oeste - orientacion)

  (:predicates
    (asignada ?r - reserva)
    (ocupada ?h - habitacion ?r - reserva)
    (procesada ?r - reserva)
    (orientada ?h - habitacion ?o - orientacion)
    (quiere ?r - reserva ?o - orientacion)
  )

  (:functions
    (capacidad ?h - habitacion)
    (personas ?r - reserva)
    (desde ?r - reserva)
    (hasta ?r - reserva)
    (total-cost)
  )

  (:action asignarconorientacion
    :parameters (?r - reserva ?h - habitacion ?o - orientacion)
    :precondition (and 
        (not (procesada ?r))
        (orientada ?h ?o)
        (quiere ?r ?o)
        (>= (capacidad ?h) (personas ?r))
        (forall (?r2 - reserva)
            (imply (ocupada ?h ?r2) 
                   (or (< (hasta ?r) (desde ?r2))
                       (> (desde ?r) (hasta ?r2))))
        )
    )
    :effect (and 
        (asignada ?r)
        (ocupada ?h ?r)
        (procesada ?r)
    )
  )

  (:action asignarsinorientacion
    :parameters (?r - reserva ?h - habitacion ?o - orientacion)
    :precondition (and 
        (not (procesada ?r))
        (not (orientada ?h ?o))
        (quiere ?r ?o)
        (>= (capacidad ?h) (personas ?r))
        (forall (?r2 - reserva)
            (imply (ocupada ?h ?r2) 
                   (or (< (hasta ?r) (desde ?r2))
                       (> (desde ?r) (hasta ?r2))))
        )
    )
    :effect (and 
        (asignada ?r)
        (ocupada ?h ?r)
        (procesada ?r)
        (increase (total-cost) 1)
    )
  )

  (:action descartar
    :parameters (?r - reserva)
    :precondition (not (procesada ?r))
    :effect (and 
        (procesada ?r)
        (increase (total-cost) 100)
    )
  )
)