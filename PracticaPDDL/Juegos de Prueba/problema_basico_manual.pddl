(define (problem problemaHotelbasico)
  (:domain basico)

  (:objects
    dia1 dia2 dia3 dia4 dia5 dia6 dia7 dia8 - dia
    h_pequena h_grande - habitacion
    r_pareja1 r_pareja2 r_familia - reserva
  )

  (:init
    (= (capacidad h_pequena) 2)
    (= (capacidad h_grande) 4)

    (= (personas r_pareja1) 2)
    (= (personas r_pareja2) 2)
    (= (personas r_familia) 4)

    (dia-reserva dia1 r_pareja1)
    (dia-reserva dia2 r_pareja1)
    (dia-reserva dia3 r_pareja1)
    (dia-reserva dia4 r_pareja1)
    (dia-reserva dia5 r_pareja1)

    (dia-reserva dia4 r_pareja2)
    (dia-reserva dia5 r_pareja2)
    (dia-reserva dia6 r_pareja2)
    (dia-reserva dia7 r_pareja2)
    (dia-reserva dia8 r_pareja2)

    (dia-reserva dia2 r_familia)
    (dia-reserva dia3 r_familia)
    (dia-reserva dia4 r_familia)
    (dia-reserva dia5 r_familia)
    (dia-reserva dia6 r_familia)    
  )

  (:goal
    (forall (?r - reserva) (asignada ?r))
  )
)