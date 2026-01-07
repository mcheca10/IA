(define (problem problema-extension3) (:domain extension3)
   (:objects
      dia1 dia2 dia3 dia4 dia5 dia6 dia7 dia8 dia9 dia10 dia11 dia12 dia13 dia14 dia15 dia16 dia17 dia18 dia19 dia20 dia21 dia22 dia23 dia24 dia25 dia26 dia27 dia28 dia29 dia30 - dia
      hab001 hab002 hab003 hab004 hab005 - habitacion
      res001 res002 res003 res004 res005 res006 res007 res008 res009 res010 res011 res012 res013 res014 res015 - reserva
   )

   (:init
      (= (capacidad hab001) 4)
      (= (capacidad hab002) 1)
      (= (capacidad hab003) 2)
      (= (capacidad hab004) 4)
      (= (capacidad hab005) 2)

      (= (personas res001) 1)
      (dia-reserva dia22 res001)
      (dia-reserva dia23 res001)
      (dia-reserva dia24 res001)
      (dia-reserva dia25 res001)

      (= (personas res002) 3)
      (dia-reserva dia10 res002)
      (dia-reserva dia11 res002)
      (dia-reserva dia12 res002)
      (dia-reserva dia13 res002)

      (= (personas res003) 2)
      (dia-reserva dia12 res003)
      (dia-reserva dia13 res003)
      (dia-reserva dia14 res003)
      (dia-reserva dia15 res003)
      (dia-reserva dia16 res003)

      (= (personas res004) 1)
      (dia-reserva dia15 res004)
      (dia-reserva dia16 res004)
      (dia-reserva dia17 res004)
      (dia-reserva dia18 res004)
      (dia-reserva dia19 res004)

      (= (personas res005) 1)
      (dia-reserva dia16 res005)
      (dia-reserva dia17 res005)
      (dia-reserva dia18 res005)

      (= (personas res006) 4)
      (dia-reserva dia3 res006)
      (dia-reserva dia4 res006)

      (= (personas res007) 3)
      (dia-reserva dia25 res007)
      (dia-reserva dia26 res007)
      (dia-reserva dia27 res007)
      (dia-reserva dia28 res007)
      (dia-reserva dia29 res007)

      (= (personas res008) 2)
      (dia-reserva dia2 res008)
      (dia-reserva dia3 res008)

      (= (personas res009) 4)
      (dia-reserva dia20 res009)

      (= (personas res010) 2)
      (dia-reserva dia19 res010)
      (dia-reserva dia20 res010)

      (= (personas res011) 4)
      (dia-reserva dia17 res011)
      (dia-reserva dia18 res011)
      (dia-reserva dia19 res011)
      (dia-reserva dia20 res011)

      (= (personas res012) 4)
      (dia-reserva dia24 res012)

      (= (personas res013) 4)
      (dia-reserva dia15 res013)

      (= (personas res014) 3)
      (dia-reserva dia23 res014)
      (dia-reserva dia24 res014)
      (dia-reserva dia25 res014)

      (= (personas res015) 3)
      (dia-reserva dia7 res015)

      (= (coste) 0)
   )

   (:goal (forall (?r - reserva) (procesada ?r)))
   (:metric minimize (coste))
)
