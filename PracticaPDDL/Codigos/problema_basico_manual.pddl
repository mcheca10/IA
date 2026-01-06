(define (problem problema_basico_manual)
  (:domain dominioHotelBasico)

  (:objects
    h_unica - habitacion
    r_solapa1 r_solapa2 r_grande - reserva
  )

  (:init
    ;; Una sola habitación pequeña
    (= (capacidad h_unica) 2)

    ;; CONFLICTO 1: Solapamiento temporal
    ;; Ambas necesitan la habitación el día 3, 4 y 5
    (= (personas r_solapa1) 2) (= (desde r_solapa1) 1) (= (hasta r_solapa1) 5)
    (= (personas r_solapa2) 2) (= (desde r_solapa2) 3) (= (hasta r_solapa2) 7)

    ;; CONFLICTO 2: Capacidad
    ;; 4 personas no caben en capacidad 2
    (= (personas r_grande) 4) (= (desde r_grande) 10) (= (hasta r_grande) 15)
  )

  (:goal
    (forall (?r - reserva) (asignada ?r))
  )
)