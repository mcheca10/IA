(define (problem problemaHotelbasico)
  (:domain dominioHotelBasico)

  (:objects
    h_pequena h_grande - habitacion
    r_pareja1 r_pareja2 r_familia - reserva
  )

  (:init
    (= (capacidad h_pequena) 2)
    (= (capacidad h_grande) 4)

    (= (personas r_pareja1) 2)
    (= (personas r_pareja2) 2)
    (= (personas r_familia) 4)

    (= (desde r_pareja1) 1)
    (= (hasta r_pareja1) 5)
    (= (desde r_pareja2) 4)
    (= (hasta r_pareja2) 8)
    (= (desde r_familia) 2)
    (= (hasta r_familia) 6)

  )

  (:goal
    (forall (?r - reserva) (asignada ?r))
  )
)