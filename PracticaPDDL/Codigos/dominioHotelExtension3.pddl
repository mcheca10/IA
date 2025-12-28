(define (domain dominioHotelExtension3)
  (:requirements :strips :typing :adl :fluents)

  (:types reserva habitacion - object)

  (:predicates
    (asignadaR ?r - reserva)
    (ocupada ?h - habitacion ?r - reserva)
    (procesada ?r - reserva)
  )

  (:functions
    (capacidad ?h - habitacion)
    (personas ?r - reserva)
    (desde ?r - reserva)
    (hasta ?r - reserva)
    (total-cost)
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