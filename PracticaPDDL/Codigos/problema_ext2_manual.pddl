(define (problem problema_ext2_manual)
  (:domain dominioHotelExtension2)

  (:objects
    h_norte h_sur - habitacion
    r_quierenorte r_quieresur - reserva
  )

  (:init
    (= (total-cost) 0)
    
    ;; Definición de habitaciones
    (= (capacidad h_norte) 4) (orientada h_norte norte)
    (= (capacidad h_sur) 4)   (orientada h_sur sur)

    ;; Definición de reservas (mismas fechas para forzar uso simultáneo)
    (= (personas r_quierenorte) 2) 
    (= (desde r_quierenorte) 1) (= (hasta r_quierenorte) 5) 
    (quiere r_quierenorte norte)

    (= (personas r_quieresur) 2) 
    (= (desde r_quieresur) 1) (= (hasta r_quieresur) 5) 
    (quiere r_quieresur sur)
  )

  (:goal
    (forall (?r - reserva) (procesada ?r))
  )

  (:metric minimize (total-cost))
)