(define (domain extension2)

    (:requirements :strips :typing :adl :equality :fluents)

    (:types reserva habitacion dia orientacion - object)

    (:constants norte sur este oeste - orientacion)

    (:predicates 
        (asignada ?r - reserva)
        (ocupada ?h - habitacion ?d - dia)
        ;; orientación de la habitación
        (orientada ?h - habitacion ?o - orientacion)
        ;; orientación preferente de la reserva
        (orientacion-preferida ?r - reserva ?o - orientacion)
        (dia-reserva ?d - dia ?r - reserva)
        (procesada ?r - reserva )
    )

    (:functions
        ;; cuánta gente cabe en la habitación
        (capacidad ?h - habitacion)
        ;; cuánta gente tiene la reserva
        (personas ?r - reserva)
        ;; coste de la asignación
        (coste)
    )

    (:action asignar
        :parameters (?r - reserva ?h - habitacion)
        :precondition (and
            (not (procesada ?r))
            (>= (capacidad ?h) (personas ?r))
            (forall (?d - dia) 
                (imply (dia-reserva ?d ?r) (not (ocupada ?h ?d))))
        )
        :effect (and
            (asignada ?r)
            (forall (?d - dia) 
                (when (dia-reserva ?d ?r) (ocupada ?h ?d)))
            (procesada ?r)
            (forall (?o - orientacion) 
                (when (and (orientada ?h ?o) (not (orientacion-preferida ?r ?o)))
                    (increase (coste) 1))) ;; Penalizamos si la habitación tiene una orientación no deseada
        )
    )

    (:action descartar
        :parameters (?r - reserva)
        :precondition (not (procesada ?r))
        :effect (and
            (procesada ?r)
            (increase (coste) 10)) ;; Penalizamos descartar
    )
)
    
;; GOAL: (forall (reserva ?r) (procesada ?r))
;; -> MINIMZE coste





;; ESTRATEGIA: Dividir en dos predicados
    
;;  (:action asignar-sin-orientacion
;;      :parameters (?r - reserva ?h - habitacion ?o - orientacion)
;;      :precondition (and
;;          (not (procesada ?r))
;;          (not (orientada ?h ?o))
;;          (orientacion-preferida ?r ?o)
;;          (>= (capacidad ?h) (personas ?r))
;;          (forall (?d - dia) 
;;              (imply (dia-reserva ?d ?r) (not (ocupada ?h ?d))))
;;      )
;;      :effect (and
;;          (asignada ?r)
;;          (forall (?d - dia) 
;;              (when (dia-reserva ?d ?r) (ocupada ?h ?d)))
;;          (procesada ?r)
;;          (increase (beneficio) 10)
;;      )
;;  )
  
;;  (:action asignar-con-orientacion
;;      :parameters (?r - reserva ?h - habitacion ?o - orientacion)
;;      :precondition (and
;;          (not (procesada ?r))
;;          (orientada ?h ?o)
;;          (orientacion-preferida ?r ?o)
;;          (>= (capacidad ?h) (personas ?r))
;;          (forall (?d - dia) 
;;              (imply (dia-reserva ?d ?r) (not (ocupada ?h ?d))))
;;      )
;;      :effect (and
;;          (asignada ?r)
;;          (forall (?d - dia) 
;;              (when (dia-reserva ?d ?r) (ocupada ?h ?d)))
;;          (procesada ?r)
;;          (increase (beneficio) 10)
;;          (increase (beneficio) 1)
;;      )
;;  )
