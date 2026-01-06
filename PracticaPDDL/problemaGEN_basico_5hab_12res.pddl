(define (problem problema-basico) (:domain basico)
   (:objects
      dia1 dia2 dia3 dia4 dia5 dia6 dia7 dia8 dia9 dia10 dia11 dia12 dia13 dia14 dia15 dia16 dia17 dia18 dia19 dia20 dia21 dia22 dia23 dia24 dia25 dia26 dia27 dia28 dia29 dia30 - dia
      hab001 hab002 hab003 hab004 hab005 - habitacion
      res001 res002 res003 res004 res005 res006 res007 res008 res009 res010 res011 res012 - reserva
   )

   (:init
      (= (capacidad hab001) 1)
      (= (capacidad hab002) 4)
      (= (capacidad hab003) 4)
      (= (capacidad hab004) 4)
      (= (capacidad hab005) 4)

      (= (personas res001) 4)
      (dia-reserva dia1 res001)
      (dia-reserva dia2 res001)

      (= (personas res002) 1)
      (dia-reserva dia23 res002)

      (= (personas res003) 1)
      (dia-reserva dia18 res003)
      (dia-reserva dia19 res003)
      (dia-reserva dia20 res003)

      (= (personas res004) 3)
      (dia-reserva dia10 res004)
      (dia-reserva dia11 res004)
      (dia-reserva dia12 res004)
      (dia-reserva dia13 res004)

      (= (personas res005) 4)
      (dia-reserva dia7 res005)
      (dia-reserva dia8 res005)

      (= (personas res006) 2)
      (dia-reserva dia14 res006)
      (dia-reserva dia15 res006)
      (dia-reserva dia16 res006)
      (dia-reserva dia17 res006)
      (dia-reserva dia18 res006)

      (= (personas res007) 2)
      (dia-reserva dia12 res007)

      (= (personas res008) 1)
      (dia-reserva dia12 res008)
      (dia-reserva dia13 res008)
      (dia-reserva dia14 res008)
      (dia-reserva dia15 res008)

      (= (personas res009) 2)
      (dia-reserva dia4 res009)
      (dia-reserva dia5 res009)

      (= (personas res010) 1)
      (dia-reserva dia25 res010)

      (= (personas res011) 4)
      (dia-reserva dia7 res011)
      (dia-reserva dia8 res011)
      (dia-reserva dia9 res011)
      (dia-reserva dia10 res011)
      (dia-reserva dia11 res011)

      (= (personas res012) 2)
      (dia-reserva dia18 res012)
      (dia-reserva dia19 res012)

   )

   (:goal (forall (?r - reserva) (asignada ?r)))
)
