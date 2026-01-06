(define (problem problema-extension4) (:domain dominioHotelExtension4)
   (:objects
      hab001 hab002 hab003 hab004 hab005 hab006 hab007 hab008 - habitacion
      res001 res002 res003 res004 res005 res006 res007 res008 - reserva
   )

   (:init
      (= (capacidad hab001) 1)
      (= (capacidad hab002) 3)
      (= (capacidad hab003) 2)
      (= (capacidad hab004) 3)
      (= (capacidad hab005) 1)
      (= (capacidad hab006) 3)
      (= (capacidad hab007) 4)
      (= (capacidad hab008) 4)

      (= (personas res001) 1)
      (= (desde res001) 8)
      (= (hasta res001) 9)

      (= (personas res002) 1)
      (= (desde res002) 9)
      (= (hasta res002) 13)

      (= (personas res003) 1)
      (= (desde res003) 21)
      (= (hasta res003) 23)

      (= (personas res004) 3)
      (= (desde res004) 10)
      (= (hasta res004) 14)

      (= (personas res005) 1)
      (= (desde res005) 5)
      (= (hasta res005) 5)

      (= (personas res006) 3)
      (= (desde res006) 4)
      (= (hasta res006) 6)

      (= (personas res007) 1)
      (= (desde res007) 13)
      (= (hasta res007) 16)

      (= (personas res008) 1)
      (= (desde res008) 22)
      (= (hasta res008) 25)

      (= (total-cost) 0)
   )

   (:goal (forall (?r - reserva) (procesada ?r)))
   (:metric minimize (total-cost))
)
