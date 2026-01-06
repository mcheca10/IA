(define (problem problema-extension1) (:domain extension1)
   (:objects
      dia1 dia2 dia3 dia4 dia5 dia6 dia7 dia8 dia9 dia10 dia11 dia12 dia13 dia14 dia15 dia16 dia17 dia18 dia19 dia20 dia21 dia22 dia23 dia24 dia25 dia26 dia27 dia28 dia29 dia30 - dia
      hab001 hab002 - habitacion
      res001 res002 res003 res004 res005 res006 res007 res008 res009 res010 res011 res012 res013 res014 res015 - reserva
   )

   (:init
      (= (capacidad hab001) 2)
      (= (capacidad hab002) 3)

      (= (personas res001) 2)
      (dia-reserva dia24 res001)
      (dia-reserva dia25 res001)
      (dia-reserva dia26 res001)
      (dia-reserva dia27 res001)
      (dia-reserva dia28 res001)

      (= (personas res002) 2)
      (dia-reserva dia21 res002)

      (= (personas res003) 1)
      (dia-reserva dia8 res003)
      (dia-reserva dia9 res003)

      (= (personas res004) 3)
      (dia-reserva dia3 res004)
      (dia-reserva dia4 res004)
      (dia-reserva dia5 res004)
      (dia-reserva dia6 res004)
      (dia-reserva dia7 res004)

      (= (personas res005) 4)
      (dia-reserva dia4 res005)
      (dia-reserva dia5 res005)
      (dia-reserva dia6 res005)

      (= (personas res006) 3)
      (dia-reserva dia3 res006)
      (dia-reserva dia4 res006)
      (dia-reserva dia5 res006)

      (= (personas res007) 4)
      (dia-reserva dia10 res007)
      (dia-reserva dia11 res007)
      (dia-reserva dia12 res007)

      (= (personas res008) 1)
      (dia-reserva dia6 res008)
      (dia-reserva dia7 res008)
      (dia-reserva dia8 res008)
      (dia-reserva dia9 res008)
      (dia-reserva dia10 res008)

      (= (personas res009) 3)
      (dia-reserva dia23 res009)
      (dia-reserva dia24 res009)
      (dia-reserva dia25 res009)

      (= (personas res010) 4)
      (dia-reserva dia17 res010)
      (dia-reserva dia18 res010)

      (= (personas res011) 1)
      (dia-reserva dia7 res011)

      (= (personas res012) 4)
      (dia-reserva dia20 res012)
      (dia-reserva dia21 res012)

      (= (personas res013) 2)
      (dia-reserva dia13 res013)
      (dia-reserva dia14 res013)
      (dia-reserva dia15 res013)

      (= (personas res014) 1)
      (dia-reserva dia8 res014)
      (dia-reserva dia9 res014)
      (dia-reserva dia10 res014)

      (= (personas res015) 4)
      (dia-reserva dia16 res015)
      (dia-reserva dia17 res015)
      (dia-reserva dia18 res015)
      (dia-reserva dia19 res015)
      (dia-reserva dia20 res015)

      (= (coste) 0)
   )

   (:goal (forall (?r - reserva) (procesada ?r)))
   (:metric minimize (coste))
)
