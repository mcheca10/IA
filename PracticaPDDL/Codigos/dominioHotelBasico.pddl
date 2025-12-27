 (define (domain dominioHotelBasico)
  (:requirements :strips :typing :adl :fluents)

  (:types
    reserva habitacion - object
  )

  (:predicates
    (asignada ?r - reserva)
    (ocupada ?h - habitacion ?r - reserva)
  )

  (:functions
    (capacidad ?h - habitacion)
    (personas ?r - reserva)
    (desde ?r - reserva)
    (hasta ?r - reserva)
  )

  (:action asignar-habitacion
    :parameters (?r - reserva ?h - habitacion)
    :precondition (and 
        (not (asignada ?r))
        (>= (capacidad ?h) (personas ?r))
        (forall (?r2 - reserva)
            (imply (ocupada ?h ?r2) 
                   (> (desde ?r2) (hasta ?r)))
        )
    )
    :effect (and 
        (asignada ?r)
        (ocupada ?h ?r)
    )
  )
)