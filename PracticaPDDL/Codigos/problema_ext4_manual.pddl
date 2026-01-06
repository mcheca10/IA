(define (problem problema_ext4_manual)
  (:domain dominioHotelExtension4)

  (:objects
    h1 h2 h3 - habitacion
    r_primera r_segunda r_tercera - reserva
  )

  (:init
    (= (total-cost) 0)
    
    ;; 3 habitaciones idénticas vacías
    (= (capacidad h1) 4)
    (= (capacidad h2) 4)
    (= (capacidad h3) 4)

    ;; 3 reservas consecutivas (No se solapan)
    ;; Deben ir todas a la misma habitación (ej: h1)
    (= (personas r_primera) 4) (= (desde r_primera) 1)  (= (hasta r_primera) 5)
    (= (personas r_segunda) 4) (= (desde r_segunda) 6)  (= (hasta r_segunda) 10)
    (= (personas r_tercera) 4) (= (desde r_tercera) 11) (= (hasta r_tercera) 15)
  )

  (:goal
    (forall (?r - reserva) (procesada ?r))
  )

  (:metric minimize (total-cost))
)