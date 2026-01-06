(define (problem problema_ext1_manual)
  (:domain dominioHotelExtension1)

  (:objects
    h_unica - habitacion
    r_larga - reserva
    r_corta1 r_corta2 r_corta3 r_corta4 - reserva
  )

  (:init
    (= (total-cost) 0)
    (= (capacidad h_unica) 4) ;; Capacidad suficiente para todos

    ;; Reserva Larga: Ocupa todo el periodo (Coste de descarte: 1)
    (= (personas r_larga) 2) (= (desde r_larga) 1) (= (hasta r_larga) 20)

    ;; Reservas Cortas: Ocupan el mismo periodo por tramos (Coste descarte total: 4)
    (= (personas r_corta1) 2) (= (desde r_corta1) 1)  (= (hasta r_corta1) 5)
    (= (personas r_corta2) 2) (= (desde r_corta2) 6)  (= (hasta r_corta2) 10)
    (= (personas r_corta3) 2) (= (desde r_corta3) 11) (= (hasta r_corta3) 15)
    (= (personas r_corta4) 2) (= (desde r_corta4) 16) (= (hasta r_corta4) 20)
  )

  (:goal
    (forall (?r - reserva) (procesada ?r))
  )

  (:metric minimize (total-cost))
)