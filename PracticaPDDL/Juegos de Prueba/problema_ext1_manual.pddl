(define (problem problema_ext1_manual)
  (:domain extension1)

  (:objects
    dia1 dia2 dia3 dia4 dia5 dia6 dia7 dia8 dia9 dia10 dia11 dia12 - dia
    h1 h2 - habitacion
    r_larga1 r_larga2 - reserva
    r_corta1_a r_corta1_b r_corta1_c r_corta1_d - reserva
    r_corta2_a r_corta2_b r_corta2_c r_corta2_d - reserva
  )

  (:init
    (= (coste) 0)
    (= (capacidad h1) 4)
    (= (capacidad h2) 4)
    (= (personas r_larga1) 2)
    (dia-reserva dia1 r_larga1)
    (dia-reserva dia2 r_larga1)
    (dia-reserva dia3 r_larga1)
    (dia-reserva dia4 r_larga1)
    (dia-reserva dia5 r_larga1)
    (dia-reserva dia6 r_larga1)
    (dia-reserva dia7 r_larga1)
    (dia-reserva dia8 r_larga1)
    (dia-reserva dia9 r_larga1)
    (dia-reserva dia10 r_larga1)
    (dia-reserva dia11 r_larga1)
    (dia-reserva dia12 r_larga1)

    (= (personas r_larga2) 2)
    (dia-reserva dia1 r_larga2)
    (dia-reserva dia2 r_larga2)
    (dia-reserva dia3 r_larga2)
    (dia-reserva dia4 r_larga2)
    (dia-reserva dia5 r_larga2)
    (dia-reserva dia6 r_larga2)
    (dia-reserva dia7 r_larga2)
    (dia-reserva dia8 r_larga2)
    (dia-reserva dia9 r_larga2)
    (dia-reserva dia10 r_larga2)
    (dia-reserva dia11 r_larga2)
    (dia-reserva dia12 r_larga2)

    (= (personas r_corta1_a) 2)
    (dia-reserva dia1 r_corta1_a)
    (dia-reserva dia2 r_corta1_a)
    (dia-reserva dia3 r_corta1_a)

    (= (personas r_corta1_b) 2)
    (dia-reserva dia4 r_corta1_b)
    (dia-reserva dia5 r_corta1_b)
    (dia-reserva dia6 r_corta1_b)

    (= (personas r_corta1_c) 2)
    (dia-reserva dia7 r_corta1_c)
    (dia-reserva dia8 r_corta1_c)
    (dia-reserva dia9 r_corta1_c)

    (= (personas r_corta1_d) 2)
    (dia-reserva dia10 r_corta1_d)
    (dia-reserva dia11 r_corta1_d)
    (dia-reserva dia12 r_corta1_d)

    (= (personas r_corta2_a) 2)
    (dia-reserva dia1 r_corta2_a)
    (dia-reserva dia2 r_corta2_a)
    (dia-reserva dia3 r_corta2_a)

    (= (personas r_corta2_b) 2)
    (dia-reserva dia4 r_corta2_b)
    (dia-reserva dia5 r_corta2_b)
    (dia-reserva dia6 r_corta2_b)

    (= (personas r_corta2_c) 2)
    (dia-reserva dia7 r_corta2_c)
    (dia-reserva dia8 r_corta2_c)
    (dia-reserva dia9 r_corta2_c)

    (= (personas r_corta2_d) 2)
    (dia-reserva dia10 r_corta2_d)
    (dia-reserva dia11 r_corta2_d)
    (dia-reserva dia12 r_corta2_d)
  )

  (:goal (forall (?r - reserva) (procesada ?r)))

  (:metric minimize(coste))
)