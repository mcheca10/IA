(define (problem problemaHotelExtension4)
  (:domain dominioHotelExtension4)

  (:objects
    h_triple h_doble h_unica - habitacion
    r_grande r_primera r_segunda - reserva
  )

  (:init
    (= (total-cost) 0)
    (= (num-habs) 0)
    
    (= (capacidad h_triple) 6)
    (= (capacidad h_doble) 4)
    (= (capacidad h_unica) 2)

    ;; DEFINICIÓN DE RESERVAS
    
    ;; 1. Grupo de 6: Días 1-8 (Bloquea la triple)
    (= (personas r_grande) 6) (= (desde r_grande) 1) (= (hasta r_grande) 8)

    ;; 2. Grupo de 4: Días 1-4 (Bloquea la doble al principio)
    (= (personas r_primera) 4) (= (desde r_primera) 1) (= (hasta r_primera) 4)

    ;; 3. Pareja: Días 5-8 (Llegan cuando el grupo de 4 se va)
    (= (personas r_segunda) 2) (= (desde r_segunda) 5) (= (hasta r_segunda) 8)
    
  )

  (:goal
    (forall (?r - reserva) (procesada ?r))
  )

  (:metric minimize (+ (total-cost) (*(num-habs) 10)))
)