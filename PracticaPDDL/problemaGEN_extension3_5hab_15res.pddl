(define (problem problema-extension3) (:domain dominioHotelExtension3)
   (:objects
      hab001 hab002 hab003 hab004 hab005 - habitacion
      res001 res002 res003 res004 res005 res006 res007 res008 res009 res010 res011 res012 res013 res014 res015 - reserva
   )

   (:init
      (= (capacidad hab001) 4)
      (= (capacidad hab002) 4)
      (= (capacidad hab003) 3)
      (= (capacidad hab004) 4)
      (= (capacidad hab005) 4)

      (= (personas res001) 3)
      (= (desde res001) 23)
      (= (hasta res001) 26)

      (= (personas res002) 3)
      (= (desde res002) 1)
      (= (hasta res002) 3)

      (= (personas res003) 4)
      (= (desde res003) 5)
      (= (hasta res003) 9)

      (= (personas res004) 4)
      (= (desde res004) 25)
      (= (hasta res004) 28)

      (= (personas res005) 3)
      (= (desde res005) 5)
      (= (hasta res005) 9)

      (= (personas res006) 3)
      (= (desde res006) 25)
      (= (hasta res006) 28)

      (= (personas res007) 4)
      (= (desde res007) 16)
      (= (hasta res007) 19)

      (= (personas res008) 3)
      (= (desde res008) 15)
      (= (hasta res008) 16)

      (= (personas res009) 2)
      (= (desde res009) 15)
      (= (hasta res009) 17)

      (= (personas res010) 3)
      (= (desde res010) 7)
      (= (hasta res010) 11)

      (= (personas res011) 2)
      (= (desde res011) 11)
      (= (hasta res011) 13)

      (= (personas res012) 2)
      (= (desde res012) 5)
      (= (hasta res012) 7)

      (= (personas res013) 3)
      (= (desde res013) 12)
      (= (hasta res013) 14)

      (= (personas res014) 4)
      (= (desde res014) 25)
      (= (hasta res014) 25)

      (= (personas res015) 2)
      (= (desde res015) 2)
      (= (hasta res015) 6)

      (= (total-cost) 0)
   )

   (:goal (forall (?r - reserva) (procesada ?r)))
   (:metric minimize (total-cost))
)
