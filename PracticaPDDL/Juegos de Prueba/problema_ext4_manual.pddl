(define (problem problema_ext4_manual)
  (:domain extension4)

  (:objects
    ;; Días necesarios para 3 bloques de reservas
    dia1 dia2 dia3 dia4 dia5 dia6 dia7 dia8 dia9 - dia

    ;; 4 Habitaciones (3 Necesarias + 1 Sobrante para tentar al planificador)
    h1 h2 h3 h4 - habitacion

    ;; 3 Cadenas de 3 reservas cada una
    c1_r1 c1_r2 c1_r3 - reserva ;; Cadena 1
    c2_r1 c2_r2 c2_r3 - reserva ;; Cadena 2
    c3_r1 c3_r2 c3_r3 - reserva ;; Cadena 3
    )

  (:init
    (= (coste) 0)

    (= (capacidad h1) 4)
    (= (capacidad h2) 4)
    (= (capacidad h3) 4)
    (= (capacidad h4) 4)

    (= (personas c1_r1) 4)
    (dia-reserva dia1 c1_r1)
    (dia-reserva dia2 c1_r1)
    (dia-reserva dia3 c1_r1)
    (= (personas c1_r2) 4)
    (dia-reserva dia4 c1_r2)
    (dia-reserva dia5 c1_r2)
    (dia-reserva dia6 c1_r2)
    (= (personas c1_r3) 4)
    (dia-reserva dia7 c1_r3)
    (dia-reserva dia8 c1_r3)
    (dia-reserva dia9 c1_r3)

    (= (personas c2_r1) 4)
    (dia-reserva dia1 c2_r1)
    (dia-reserva dia2 c2_r1)
    (dia-reserva dia3 c2_r1)
    (= (personas c2_r2) 4)
    (dia-reserva dia4 c2_r2)
    (dia-reserva dia5 c2_r2)
    (dia-reserva dia6 c2_r2)
    (= (personas c2_r3) 4)
    (dia-reserva dia7 c2_r3)
    (dia-reserva dia8 c2_r3)
    (dia-reserva dia9 c2_r3)

    (= (personas c3_r1) 4)
    (dia-reserva dia1 c3_r1)
    (dia-reserva dia2 c3_r1)
    (dia-reserva dia3 c3_r1)
    (= (personas c3_r2) 4)
    (dia-reserva dia4 c3_r2)
    (dia-reserva dia5 c3_r2)
    (dia-reserva dia6 c3_r2)
    (= (personas c3_r3) 4)
    (dia-reserva dia7 c3_r3)
    (dia-reserva dia8 c3_r3)
    (dia-reserva dia9 c3_r3)
  )

  (:goal(forall (?r - reserva) (procesada ?r)))
  (:metric minimize (coste))
)