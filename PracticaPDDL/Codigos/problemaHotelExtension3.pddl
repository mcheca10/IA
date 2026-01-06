(define (problem problemaHotelExtension3)
  (:domain dominioHotelExtension3)

  (:objects
    h_unica h_doble h_triple h_mediana - habitacion
    r1 r2 r3 r4 r5 - reserva
  )

  (:init
    (= (total-cost) 0)
    
    (= (capacidad h_unica) 2)
    (= (capacidad h_doble) 4)
    (= (capacidad h_triple) 6)
    (= (capacidad h_mediana) 3)

    (= (personas r1) 2) (= (desde r1) 1) (= (hasta r1) 5)
    (= (personas r2) 2) (= (desde r2) 1) (= (hasta r2) 5)
    (= (personas r3) 2) (= (desde r3) 1) (= (hasta r3) 5)

    (= (personas r4) 4) (= (desde r4) 1) (= (hasta r4) 5)
    (= (personas r5) 4) (= (desde r5) 1) (= (hasta r5) 5)
  )

  (:goal (forall (?r - reserva) (procesada ?r)))

  (:metric minimize (total-cost))
)