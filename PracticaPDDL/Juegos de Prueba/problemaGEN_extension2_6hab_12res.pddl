(define (problem problema-extension2) (:domain extension2)
   (:objects
      dia1 dia2 dia3 dia4 dia5 dia6 dia7 dia8 dia9 dia10 dia11 dia12 dia13 dia14 dia15 dia16 dia17 dia18 dia19 dia20 dia21 dia22 dia23 dia24 dia25 dia26 dia27 dia28 dia29 dia30 - dia
      hab001 hab002 hab003 hab004 hab005 hab006 - habitacion
      res001 res002 res003 res004 res005 res006 res007 res008 res009 res010 res011 res012 - reserva
   )

   (:init
      (= (capacidad hab001) 2)
      (= (capacidad hab002) 3)
      (= (capacidad hab003) 1)
      (= (capacidad hab004) 1)
      (= (capacidad hab005) 2)
      (= (capacidad hab006) 3)

      (= (personas res001) 4)
      (dia-reserva dia14 res001)

      (= (personas res002) 1)
      (dia-reserva dia8 res002)

      (= (personas res003) 1)
      (dia-reserva dia13 res003)
      (dia-reserva dia14 res003)
      (dia-reserva dia15 res003)
      (dia-reserva dia16 res003)

      (= (personas res004) 4)
      (dia-reserva dia3 res004)
      (dia-reserva dia4 res004)
      (dia-reserva dia5 res004)

      (= (personas res005) 2)
      (dia-reserva dia17 res005)

      (= (personas res006) 2)
      (dia-reserva dia24 res006)

      (= (personas res007) 4)
      (dia-reserva dia2 res007)
      (dia-reserva dia3 res007)
      (dia-reserva dia4 res007)
      (dia-reserva dia5 res007)
      (dia-reserva dia6 res007)

      (= (personas res008) 3)
      (dia-reserva dia11 res008)
      (dia-reserva dia12 res008)
      (dia-reserva dia13 res008)
      (dia-reserva dia14 res008)
      (dia-reserva dia15 res008)

      (= (personas res009) 1)
      (dia-reserva dia1 res009)
      (dia-reserva dia2 res009)
      (dia-reserva dia3 res009)

      (= (personas res010) 1)
      (dia-reserva dia6 res010)
      (dia-reserva dia7 res010)
      (dia-reserva dia8 res010)
      (dia-reserva dia9 res010)
      (dia-reserva dia10 res010)

      (= (personas res011) 2)
      (dia-reserva dia9 res011)
      (dia-reserva dia10 res011)
      (dia-reserva dia11 res011)
      (dia-reserva dia12 res011)
      (dia-reserva dia13 res011)

      (= (personas res012) 2)
      (dia-reserva dia15 res012)
      (dia-reserva dia16 res012)
      (dia-reserva dia17 res012)

      (orientada hab001 oeste)
      (orientada hab002 sur)
      (orientada hab003 oeste)
      (orientada hab004 norte)
      (orientada hab005 sur)
      (orientada hab006 norte)
      (quiere res001 norte)
      (quiere res002 sur)
      (quiere res003 sur)
      (quiere res004 norte)
      (quiere res005 este)
      (quiere res006 oeste)
      (quiere res007 sur)
      (quiere res008 este)
      (quiere res009 sur)
      (quiere res010 oeste)
      (quiere res011 norte)
      (quiere res012 sur)
      (= (coste) 0)
   )

   (:goal (forall (?r - reserva) (procesada ?r)))
   (:metric minimize (coste))
)
