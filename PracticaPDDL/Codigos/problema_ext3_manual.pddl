(define (problem problema_ext3_manual)
  (:domain dominioHotelExtension3)

  (:objects
    h_grande h_peque - habitacion
    r_grupo r_solo - reserva
  )

  (:init
    (= (total-cost) 0)
    
    (= (capacidad h_grande) 4)
    (= (capacidad h_peque) 1)

    ;; Mismas fechas para obligar a usar ambas habitaciones a la vez
    (= (personas r_grupo) 4) 
    (= (desde r_grupo) 1) (= (hasta r_grupo) 5)

    (= (personas r_solo) 1) 
    (= (desde r_solo) 1) (= (hasta r_solo) 5)
  )

  (:goal
    (forall (?r - reserva) (procesada ?r))
  )

  (:metric minimize (total-cost))
)