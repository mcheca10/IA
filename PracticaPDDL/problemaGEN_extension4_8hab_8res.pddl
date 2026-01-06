(define (problem problema-extension4) (:domain extension4)
   (:objects
      dia1 dia2 dia3 dia4 dia5 dia6 dia7 dia8 dia9 dia10 dia11 dia12 dia13 dia14 dia15 dia16 dia17 dia18 dia19 dia20 dia21 dia22 dia23 dia24 dia25 dia26 dia27 dia28 dia29 dia30 - dia
      hab001 hab002 hab003 hab004 hab005 hab006 hab007 hab008 - habitacion
      res001 res002 res003 res004 res005 res006 res007 res008 - reserva
   )

   (:init
      (= (capacidad hab001) 2)
      (= (capacidad hab002) 2)
      (= (capacidad hab003) 4)
      (= (capacidad hab004) 2)
      (= (capacidad hab005) 4)
      (= (capacidad hab006) 4)
      (= (capacidad hab007) 3)
      (= (capacidad hab008) 3)

      (= (personas res001) 2)
      (dia-reserva dia8 res001)

      (= (personas res002) 3)
      (dia-reserva dia15 res002)

      (= (personas res003) 2)
      (dia-reserva dia3 res003)
      (dia-reserva dia4 res003)

      (= (personas res004) 4)
      (dia-reserva dia13 res004)
      (dia-reserva dia14 res004)

      (= (personas res005) 2)
      (dia-reserva dia20 res005)
      (dia-reserva dia21 res005)
      (dia-reserva dia22 res005)
      (dia-reserva dia23 res005)

      (= (personas res006) 3)
      (dia-reserva dia6 res006)
      (dia-reserva dia7 res006)
      (dia-reserva dia8 res006)
      (dia-reserva dia9 res006)
      (dia-reserva dia10 res006)

      (= (personas res007) 2)
      (dia-reserva dia12 res007)
      (dia-reserva dia13 res007)

      (= (personas res008) 1)
      (dia-reserva dia25 res008)
      (dia-reserva dia26 res008)
      (dia-reserva dia27 res008)
      (dia-reserva dia28 res008)
      (dia-reserva dia29 res008)

      (= (coste) 0)
   )

   (:goal (forall (?r - reserva) (procesada ?r)))
   (:metric minimize (coste))
)
