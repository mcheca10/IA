(define (problem problemaHotelExtension2)
  (:domain dominioHotelExtension2)

  (:objects
    h_norte h_sur - habitacion
    r1 r2 r3 r4 r5 r6 - reserva
  )

  (:init
    (= (total-cost) 0)
    (= (capacidad h_norte) 2)
    (= (capacidad h_sur) 4)
    (orientada h_norte norte)
    (orientada h_sur sur)

    (= (personas r1) 2) (= (desde r1) 1) (= (hasta r1) 5) (quiere r1 norte)
    (= (personas r2) 2) (= (desde r2) 1) (= (hasta r2) 5) (quiere r2 sur)
    (= (personas r3) 2) (= (desde r3) 1) (= (hasta r3) 5) (quiere r3 sur)
    (= (personas r4) 2) (= (desde r4) 6) (= (hasta r4) 10) (quiere r4 sur)
    (= (personas r5) 2) (= (desde r5) 6) (= (hasta r5) 10) (quiere r5 sur)
    (= (personas r6) 4) (= (desde r6) 6) (= (hasta r6) 10) (quiere r6 sur)
  )

  (:goal
    (forall (?r - reserva) (procesada ?r))
  )

  (:metric minimize (total-cost))
)