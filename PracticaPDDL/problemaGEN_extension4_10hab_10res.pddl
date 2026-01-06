(define (problem problema-extension4) (:domain extension4)
   (:objects
      dia1 dia2 dia3 dia4 dia5 dia6 dia7 dia8 dia9 dia10 dia11 dia12 dia13 dia14 dia15 dia16 dia17 dia18 dia19 dia20 dia21 dia22 dia23 dia24 dia25 dia26 dia27 dia28 dia29 dia30 - dia
      hab001 hab002 hab003 hab004 hab005 hab006 hab007 hab008 hab009 hab010 - habitacion
      res001 res002 res003 res004 res005 res006 res007 res008 res009 res010 - reserva
   )

   (:init
      (= (capacidad hab001) 2)
      (= (capacidad hab002) 2)
      (= (capacidad hab003) 4)
      (= (capacidad hab004) 4)
      (= (capacidad hab005) 3)
      (= (capacidad hab006) 4)
      (= (capacidad hab007) 4)
      (= (capacidad hab008) 4)
      (= (capacidad hab009) 2)
      (= (capacidad hab010) 4)

      (= (personas res001) 2)
      (dia-reserva dia13 res001)

      (= (personas res002) 1)
      (dia-reserva dia7 res002)
      (dia-reserva dia8 res002)
      (dia-reserva dia9 res002)
      (dia-reserva dia10 res002)
      (dia-reserva dia11 res002)

      (= (personas res003) 1)
      (dia-reserva dia15 res003)

      (= (personas res004) 4)
      (dia-reserva dia15 res004)
      (dia-reserva dia16 res004)
      (dia-reserva dia17 res004)
      (dia-reserva dia18 res004)

      (= (personas res005) 1)
      (dia-reserva dia7 res005)
      (dia-reserva dia8 res005)
      (dia-reserva dia9 res005)
      (dia-reserva dia10 res005)

      (= (personas res006) 4)
      (dia-reserva dia9 res006)
      (dia-reserva dia10 res006)
      (dia-reserva dia11 res006)
      (dia-reserva dia12 res006)

      (= (personas res007) 1)
      (dia-reserva dia25 res007)
      (dia-reserva dia26 res007)
      (dia-reserva dia27 res007)

      (= (personas res008) 4)
      (dia-reserva dia7 res008)
      (dia-reserva dia8 res008)

      (= (personas res009) 1)
      (dia-reserva dia11 res009)

      (= (personas res010) 3)
      (dia-reserva dia24 res010)
      (dia-reserva dia25 res010)
      (dia-reserva dia26 res010)

      (= (coste) 0)
   )

   (:goal (forall (?r - reserva) (procesada ?r)))
   (:metric minimize (coste))
)
