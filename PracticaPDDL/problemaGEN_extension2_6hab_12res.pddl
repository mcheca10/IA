(define (problem problema-extension2) (:domain dominioHotelExtension2)
   (:objects
      hab001 hab002 hab003 hab004 hab005 hab006 - habitacion
      res001 res002 res003 res004 res005 res006 res007 res008 res009 res010 res011 res012 - reserva
   )

   (:init
      (= (capacidad hab001) 2)
      (= (capacidad hab002) 4)
      (= (capacidad hab003) 1)
      (= (capacidad hab004) 3)
      (= (capacidad hab005) 3)
      (= (capacidad hab006) 4)

      (= (personas res001) 4)
      (= (desde res001) 5)
      (= (hasta res001) 9)

      (= (personas res002) 2)
      (= (desde res002) 25)
      (= (hasta res002) 26)

      (= (personas res003) 2)
      (= (desde res003) 10)
      (= (hasta res003) 13)

      (= (personas res004) 3)
      (= (desde res004) 4)
      (= (hasta res004) 8)

      (= (personas res005) 4)
      (= (desde res005) 11)
      (= (hasta res005) 11)

      (= (personas res006) 1)
      (= (desde res006) 4)
      (= (hasta res006) 5)

      (= (personas res007) 2)
      (= (desde res007) 10)
      (= (hasta res007) 10)

      (= (personas res008) 4)
      (= (desde res008) 16)
      (= (hasta res008) 17)

      (= (personas res009) 3)
      (= (desde res009) 20)
      (= (hasta res009) 20)

      (= (personas res010) 2)
      (= (desde res010) 11)
      (= (hasta res010) 11)

      (= (personas res011) 3)
      (= (desde res011) 24)
      (= (hasta res011) 24)

      (= (personas res012) 3)
      (= (desde res012) 16)
      (= (hasta res012) 20)

      (orientada hab001 norte)
      (orientada hab002 norte)
      (orientada hab003 sur)
      (orientada hab004 este)
      (orientada hab005 sur)
      (orientada hab006 norte)
      (quiere res001 sur)
      (quiere res002 norte)
      (quiere res003 norte)
      (quiere res004 este)
      (quiere res005 este)
      (quiere res006 oeste)
      (quiere res007 norte)
      (quiere res008 norte)
      (quiere res009 norte)
      (quiere res010 oeste)
      (quiere res011 norte)
      (quiere res012 sur)
      (= (total-cost) 0)
   )

   (:goal (forall (?r - reserva) (procesada ?r)))
   (:metric minimize (total-cost))
)
