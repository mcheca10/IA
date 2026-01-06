(define (problem problema-basico) (:domain dominioHotelBasico)
   (:objects
      hab001 hab002 hab003 hab004 hab005 - habitacion
      res001 res002 res003 res004 res005 res006 res007 res008 res009 res010 res011 res012 - reserva
   )

   (:init
      (= (capacidad hab001) 2)
      (= (capacidad hab002) 4)
      (= (capacidad hab003) 1)
      (= (capacidad hab004) 2)
      (= (capacidad hab005) 4)

      (= (personas res001) 1)
      (= (desde res001) 23)
      (= (hasta res001) 27)

      (= (personas res002) 1)
      (= (desde res002) 4)
      (= (hasta res002) 8)

      (= (personas res003) 2)
      (= (desde res003) 18)
      (= (hasta res003) 22)

      (= (personas res004) 1)
      (= (desde res004) 25)
      (= (hasta res004) 28)

      (= (personas res005) 3)
      (= (desde res005) 7)
      (= (hasta res005) 10)

      (= (personas res006) 1)
      (= (desde res006) 14)
      (= (hasta res006) 17)

      (= (personas res007) 4)
      (= (desde res007) 11)
      (= (hasta res007) 14)

      (= (personas res008) 3)
      (= (desde res008) 15)
      (= (hasta res008) 15)

      (= (personas res009) 1)
      (= (desde res009) 12)
      (= (hasta res009) 12)

      (= (personas res010) 1)
      (= (desde res010) 25)
      (= (hasta res010) 26)

      (= (personas res011) 1)
      (= (desde res011) 23)
      (= (hasta res011) 27)

      (= (personas res012) 2)
      (= (desde res012) 11)
      (= (hasta res012) 12)

   )

   (:goal (forall (?r - reserva) (asignada ?r)))
)
