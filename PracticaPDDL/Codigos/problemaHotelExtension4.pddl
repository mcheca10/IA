(define (problem problemaHotelExtension4)
  (:domain dominioHotelExtension4)

  (:objects
    h_triple h_doble h_unica - habitacion
    r_grande r_primera r_segunda - reserva
  )

  (:init
    (= (total-cost) 0)

    (= (capacidad h_triple) 6)
    (= (capacidad h_doble) 4)
    (= (capacidad h_unica) 2)

    (= (personas r_grande) 6) (= (desde r_grande) 1) (= (hasta r_grande) 8)
    (= (personas r_primera) 4) (= (desde r_primera) 1) (= (hasta r_primera) 4)
    (= (personas r_segunda) 2) (= (desde r_segunda) 5) (= (hasta r_segunda) 8)
  )

  (:goal (forall (?r - reserva) (procesada ?r)))

  (:metric minimize (total-cost))
)