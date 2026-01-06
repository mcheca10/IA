(define (problem problema-extension4) (:domain dominioHotelExtension4)
   (:objects
      hab001 hab002 hab003 hab004 hab005 hab006 hab007 hab008 hab009 hab010 - habitacion
      res001 res002 res003 res004 res005 res006 res007 res008 res009 res010 - reserva
   )

   (:init
      (= (capacidad hab001) 3)
      (= (capacidad hab002) 2)
      (= (capacidad hab003) 2)
      (= (capacidad hab004) 1)
      (= (capacidad hab005) 4)
      (= (capacidad hab006) 1)
      (= (capacidad hab007) 1)
      (= (capacidad hab008) 2)
      (= (capacidad hab009) 3)
      (= (capacidad hab010) 4)

      (= (personas res001) 2)
      (= (desde res001) 22)
      (= (hasta res001) 26)

      (= (personas res002) 3)
      (= (desde res002) 1)
      (= (hasta res002) 5)

      (= (personas res003) 4)
      (= (desde res003) 15)
      (= (hasta res003) 19)

      (= (personas res004) 1)
      (= (desde res004) 2)
      (= (hasta res004) 2)

      (= (personas res005) 2)
      (= (desde res005) 19)
      (= (hasta res005) 22)

      (= (personas res006) 4)
      (= (desde res006) 17)
      (= (hasta res006) 18)

      (= (personas res007) 2)
      (= (desde res007) 13)
      (= (hasta res007) 14)

      (= (personas res008) 4)
      (= (desde res008) 21)
      (= (hasta res008) 23)

      (= (personas res009) 3)
      (= (desde res009) 4)
      (= (hasta res009) 7)

      (= (personas res010) 1)
      (= (desde res010) 9)
      (= (hasta res010) 9)

      (= (total-cost) 0)
   )

   (:goal (forall (?r - reserva) (procesada ?r)))
   (:metric minimize (total-cost))
)
