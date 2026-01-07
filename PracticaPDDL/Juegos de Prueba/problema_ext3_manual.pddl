(define (problem problema_ext3_manual)
  (:domain extension3)

  (:objects
    dia1 dia2 dia3 dia4 dia5 - dia
    h_cap4 h_cap3 h_cap2 h_cap1 - habitacion
    r_pax4 r_pax3 r_pax2 r_pax1 - reserva
  )

  (:init
    (= (coste) 0)

    (= (capacidad h_cap4) 4)
    (= (capacidad h_cap3) 3)
    (= (capacidad h_cap2) 2)
    (= (capacidad h_cap1) 1)

    (= (personas r_pax4) 4)
    (dia-reserva dia1 r_pax4)
    (dia-reserva dia2 r_pax4)
    (dia-reserva dia3 r_pax4)
    (dia-reserva dia4 r_pax4)
    (dia-reserva dia5 r_pax4)

    (= (personas r_pax3) 3)
    (dia-reserva dia1 r_pax3)
    (dia-reserva dia2 r_pax3)
    (dia-reserva dia3 r_pax3)
    (dia-reserva dia4 r_pax3)
    (dia-reserva dia5 r_pax3)

    (= (personas r_pax2) 2)
    (dia-reserva dia1 r_pax2)
    (dia-reserva dia2 r_pax2)
    (dia-reserva dia3 r_pax2)
    (dia-reserva dia4 r_pax2)
    (dia-reserva dia5 r_pax2)

    (= (personas r_pax1) 1)
    (dia-reserva dia1 r_pax1)
    (dia-reserva dia2 r_pax1)
    (dia-reserva dia3 r_pax1)
    (dia-reserva dia4 r_pax1)
    (dia-reserva dia5 r_pax1)
  )

  (:goal (forall (?r - reserva) (procesada ?r)))
  (:metric minimize (coste))
)