(define (problem problemaHotelExtension1)
  (:domain dominioHotelExtension1)

  (:objects
    h_unica - habitacion
    r1 r2 r3 - reserva
  )

  (:init
    (= (total-cost) 0)
    (= (capacidad h_unica) 2)

    (= (personas r1) 2) (= (desde r1) 1) (= (hasta r1) 5)
    (= (personas r2) 2) (= (desde r2) 1) (= (hasta r2) 5)
    (= (personas r3) 2) (= (desde r3) 1) (= (hasta r3) 5)
  )

  (:goal (forall (?r - reserva) (procesada ?r)))

  (:metric minimize (total-cost))
)