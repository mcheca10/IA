(define (domain dominioHotelExtension4)
  (:requirements :strips :typing :adl :fluents)

  (:types reserva habitacion - object)

  (:predicates
    (asignada ?r - reserva)
    (ocupada ?h - habitacion ?r - reserva)
    (procesada ?r - reserva)
    (asignadaH ?h - habitacion)
  )

  (:functions
    (capacidad ?h - habitacion)
    (personas ?r - reserva)
    (desde ?r - reserva)
    (hasta ?r - reserva)
    (total-cost)
    (num-habs)
  )

  (:action asignar
    :parameters (?r - reserva ?h - habitacion)
    :precondition (and 
        (not (procesada ?r))
        (>= (capacidad ?h) (personas ?r))
        (forall (?r2 - reserva)
            (imply (ocupada ?h ?r2) 
                   (or (< (hasta ?r) (desde ?r2))
                       (> (desde ?r) (hasta ?r2))))
        )
    )
    :effect (and 
        (asignadaR ?r)
        (ocupada ?h ?r)
        (procesada ?r)
        (increase (total-cost) (- (capacidad ?h) (personas ?r)))
        (when (not (asignadaH ?h)) (increase (num-habs) 1))
        (asignadaH ?h)
    )
  )

  (:action descartar
    :parameters (?r - reserva)
    :precondition (not (procesada ?r))
    :effect (and 
        (procesada ?r)
        (increase (total-cost) (* (personas ?r) 10))
    )
  )
)