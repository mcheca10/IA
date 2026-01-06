(define (problem problema-extension1) (:domain dominioHotelExtension1)
   (:objects
      hab001 hab002 - habitacion
      res001 res002 res003 res004 res005 res006 res007 res008 res009 res010 res011 res012 res013 res014 res015 - reserva
   )

   (:init
      (= (capacidad hab001) 2)
      (= (capacidad hab002) 3)

      (= (personas res001) 1)
      (= (desde res001) 13)
      (= (hasta res001) 16)

      (= (personas res002) 4)
      (= (desde res002) 15)
      (= (hasta res002) 15)

      (= (personas res003) 2)
      (= (desde res003) 9)
      (= (hasta res003) 10)

      (= (personas res004) 4)
      (= (desde res004) 11)
      (= (hasta res004) 11)

      (= (personas res005) 3)
      (= (desde res005) 1)
      (= (hasta res005) 1)

      (= (personas res006) 1)
      (= (desde res006) 5)
      (= (hasta res006) 7)

      (= (personas res007) 1)
      (= (desde res007) 1)
      (= (hasta res007) 3)

      (= (personas res008) 3)
      (= (desde res008) 19)
      (= (hasta res008) 23)

      (= (personas res009) 2)
      (= (desde res009) 19)
      (= (hasta res009) 20)

      (= (personas res010) 4)
      (= (desde res010) 13)
      (= (hasta res010) 17)

      (= (personas res011) 2)
      (= (desde res011) 3)
      (= (hasta res011) 5)

      (= (personas res012) 4)
      (= (desde res012) 25)
      (= (hasta res012) 26)

      (= (personas res013) 4)
      (= (desde res013) 17)
      (= (hasta res013) 19)

      (= (personas res014) 2)
      (= (desde res014) 1)
      (= (hasta res014) 3)

      (= (personas res015) 2)
      (= (desde res015) 9)
      (= (hasta res015) 10)

      (= (total-cost) 0)
   )

   (:goal (forall (?r - reserva) (procesada ?r)))
   (:metric minimize (total-cost))
)
