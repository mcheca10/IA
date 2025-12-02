(definstances instances

  ;; ==========================================================
  ;; VIVENDAS (Distribuidas por Zonas y con Confort)
  ;; ==========================================================

  ;; --- ZONA RESIDENCIAL (X=3000, Y=1000) ---
  ;; Ideal para familias (V1, V9, V11)
  
  ([V1] of Piso
       (altura_piso        3)
       (amueblado          TRUE)
       (coordx             3000.0)
       (coordy             1000.0)
       (es_soleado         "Manana")
       (num_habs_dobles    1)
       (num_habs_individual 2)
       (permite_mascotas   TRUE)
       (precio_mensual     950)
       (superficie         75)
       (tiene_ascensor     TRUE)
       (tiene_terraza      TRUE)
       ;; NUEVOS
       (tiene_calefaccion       SI)
       (tiene_aire_acondicionado SI)
       (num_banos               2)
  )

  ([V9] of Piso
       (altura_piso        1)
       (amueblado          TRUE)
       (coordx             3100.0)
       (coordy             1100.0)
       (es_soleado         "Manana")
       (num_habs_dobles    1)
       (num_habs_individual 1)
       (permite_mascotas   TRUE)
       (precio_mensual     800)
       (superficie         65)
       (tiene_ascensor     TRUE)
       (tiene_terraza      TRUE)
       (tiene_calefaccion       SI)
       (tiene_aire_acondicionado NO)
       (num_banos               1)
  )
  
  ([V11] of Unifamiliar
       (altura_piso        0)
       (amueblado          FALSE)
       (coordx             3200.0)
       (coordy             900.0)
       (es_soleado         "Tarde")
       (num_habs_dobles    2)
       (num_habs_individual 2)
       (permite_mascotas   TRUE)
       (precio_mensual     1100)
       (superficie         100)
       (tiene_ascensor     FALSE)
       (tiene_terraza      TRUE)
       (tiene_calefaccion       SI)
       (tiene_aire_acondicionado SI)
       (num_banos               2)
  )

  ;; --- ZONA UNIVERSITARIA (X=1000, Y=3000) ---
  ;; Ideal estudiantes, barata, ruidosa (V2, V6, V8)

  ([V2] of Piso
       (altura_piso        1)
       (amueblado          FALSE)
       (coordx             1000.0)
       (coordy             3000.0)
       (es_soleado         "Tarde")
       (num_habs_dobles    0)
       (num_habs_individual 2)
       (permite_mascotas   FALSE)
       (precio_mensual     750)
       (superficie         60)
       (tiene_ascensor     FALSE)
       (tiene_terraza      FALSE)
       (tiene_calefaccion       NO)
       (tiene_aire_acondicionado NO)
       (num_banos               1)
  )

  ([V6] of Piso
       (altura_piso        4)
       (amueblado          TRUE)
       (coordx             1100.0)
       (coordy             3100.0)
       (es_soleado         "Nada")
       (num_habs_dobles    0)
       (num_habs_individual 1)
       (permite_mascotas   FALSE)
       (precio_mensual     450)
       (superficie         30)
       (tiene_ascensor     FALSE)
       (tiene_terraza      FALSE)
       (tiene_calefaccion       NO)
       (tiene_aire_acondicionado NO)
       (num_banos               1)
  )

  ([V8] of Piso
       (altura_piso        2)
       (amueblado          TRUE)
       (coordx             1050.0)
       (coordy             2950.0)
       (es_soleado         "Tarde")
       (num_habs_dobles    0)
       (num_habs_individual 4)
       (permite_mascotas   FALSE)
       (precio_mensual     900)
       (superficie         90)
       (tiene_ascensor     TRUE)
       (tiene_terraza      FALSE)
       (tiene_calefaccion       SI)
       (tiene_aire_acondicionado NO)
       (num_banos               2)
  )

  ;; --- ZONA CENTRO (X=1000, Y=1000) ---
  ;; Cara, bien comunicada, muchos servicios (V3, V5, V10)

  ([V3] of Dúplex
       (altura_piso        4)
       (amueblado          TRUE)
       (coordx             1000.0)
       (coordy             1000.0)
       (es_soleado         "Todo el dia")
       (num_habs_dobles    2)
       (num_habs_individual 1)
       (permite_mascotas   TRUE)
       (precio_mensual     1300)
       (superficie         110)
       (tiene_ascensor     TRUE)
       (tiene_terraza      TRUE)
       (tiene_calefaccion       SI)
       (tiene_aire_acondicionado SI)
       (num_banos               2)
  )

  ([V5] of Piso
       (altura_piso        5)
       (amueblado          FALSE)
       (coordx             1200.0)
       (coordy             1000.0)
       (es_soleado         "Manana")
       (num_habs_dobles    1)
       (num_habs_individual 1)
       (permite_mascotas   TRUE)
       (precio_mensual     700)
       (superficie         55)
       (tiene_ascensor     TRUE)
       (tiene_terraza      FALSE)
       (tiene_calefaccion       SI)
       (tiene_aire_acondicionado NO)
       (num_banos               1)
  )
  
  ([V10] of Piso
       (altura_piso        8)
       (amueblado          TRUE)
       (coordx             950.0)
       (coordy             1050.0)
       (es_soleado         "Todo el dia")
       (num_habs_dobles    2)
       (num_habs_individual 0)
       (permite_mascotas   TRUE)
       (precio_mensual     2000)
       (superficie         90)
       (tiene_ascensor     TRUE)
       (tiene_terraza      TRUE)
       (tiene_calefaccion       SI)
       (tiene_aire_acondicionado SI)
       (num_banos               2)
  )

  ;; --- ZONA AISLADA/LUJO (X=5000, Y=5000) ---
  ;; Lejos de todo, necesita coche (V4, V7)

  ([V4] of Unifamiliar
       (altura_piso        0)
       (amueblado          TRUE)
       (coordx             5000.0)
       (coordy             5000.0)
       (es_soleado         "Todo el dia")
       (num_habs_dobles    3)
       (num_habs_individual 1)
       (permite_mascotas   TRUE)
       (precio_mensual     1500)
       (superficie         140)
       (tiene_ascensor     FALSE)
       (tiene_terraza      TRUE)
       (tiene_calefaccion       SI)
       (tiene_aire_acondicionado NO)
       (num_banos               2)
  )

  ([V7] of Unifamiliar
       (altura_piso        0)
       (amueblado          TRUE)
       (coordx             5200.0)
       (coordy             5200.0)
       (es_soleado         "Todo el dia")
       (num_habs_dobles    4)
       (num_habs_individual 2)
       (permite_mascotas   TRUE)
       (precio_mensual     2500)
       (superficie         200)
       (tiene_ascensor     FALSE)
       (tiene_terraza      TRUE)
       (tiene_calefaccion       SI)
       (tiene_aire_acondicionado SI)
       (num_banos               3)
  )

  ;; ==========================================================
  ;; SERVICIOS (Usando servicio_en_x/y)
  ;; ==========================================================

  ;; Servicios en ZONA RESIDENCIAL (cerca de V1, V9, V11)
  ([S1] of Colegio
       (nombre_servicio "Escola Publica A")
       (servicio_en_x   3050.0)
       (servicio_en_y   1050.0)
  )

  ([S2] of Parque
       (nombre_servicio "Parc Central")
       (servicio_en_x   3200.0)
       (servicio_en_y   1000.0)
  )
  
  ([S5] of Centro_Salud
       (nombre_servicio "CAP Residencial")
       (servicio_en_x   2900.0)
       (servicio_en_y   900.0)
  )

  ;; Servicios en ZONA CENTRO (cerca de V3, V5, V10)
  ([S3] of Supermercado
       (nombre_servicio "Supermercat Centro")
       (servicio_en_x   1000.0)
       (servicio_en_y   900.0)
  )
  
  ([S7] of Cine
       (nombre_servicio "Cinesa Diagonal")
       (servicio_en_x   900.0)
       (servicio_en_y   1100.0)
  )
  
  ([S6] of Hospital
       (nombre_servicio "Hospital General")
       (servicio_en_x   1500.0) ;; Entre Centro y Residencial
       (servicio_en_y   1000.0)
  )

  ;; Servicios en ZONA UNIVERSITARIA (cerca de V2, V6, V8)
  ([S4] of Parada_Metro
       (nombre_servicio "Metro L3 - Universitat")
       (servicio_en_x   1000.0)
       (servicio_en_y   2900.0)
  )

  ([S9] of Zona_Nocturna
       (nombre_servicio "Discoteca Apolo")
       (servicio_en_x   1100.0)
       (servicio_en_y   3100.0) 
  )
  
  ([S10] of Supermercado
       (nombre_servicio "Super Barato")
       (servicio_en_x   1050.0)
       (servicio_en_y   3000.0)
  )

  ;; Servicios en ZONA AISLADA (cerca de V4, V7)
  ([S8] of Parada_Autobús
       (nombre_servicio "Bus Interurbano")
       (servicio_en_x   5050.0)
       (servicio_en_y   5050.0)
  )
  
  ([S11] of Parque
       (nombre_servicio "Bosque Natural")
       (servicio_en_x   5100.0)
       (servicio_en_y   5100.0)
  )

  ;; ==========================================================
  ;; SOL·LICITANTS (Con nuevas preferencias y restricciones)
  ;; ==========================================================

  ;; SOL1: Familia. Quiere zona Residencial.
  ([SOL1] of Familia
       (edad_mas_anciano    40)
       (movilidad_reducida  FALSE)
       (tiene_mascota       TRUE)
       (num_personas        4)
       (presupuesto_flexible TRUE)
       (presupuesto_maximo  1000)
       (tiene_coche         TRUE)
       (trabaja_en_casa     FALSE)
       (trabaja_en_x        3000.0)
       (trabaja_en_y        1200.0)
       (edad_hijo_menor     6)
       (num_hijos           2)
       ;; PREFERENCIAS
       (busca_vivienda      Piso Unifamiliar Dúplex)
       (prefiere_cerca      Colegio Parque)
       (superficie_minima   80)
       (precio_minimo       600)
  )

  ;; SOL2: Estudiantes. Quieren zona Uni.
  ([SOL2] of Estudiantes
       (edad_mas_anciano    23)
       (movilidad_reducida  FALSE)
       (tiene_mascota       FALSE)
       (num_personas        3)
       (presupuesto_flexible TRUE)
       (presupuesto_maximo  1500)
       (tiene_coche         FALSE)
       (trabaja_en_casa     FALSE)
       (trabaja_en_x        1000.0)
       (trabaja_en_y        3000.0)
       (busca_vivienda      Piso Dúplex)
       (prefiere_cerca      Parada_Metro Zona_Nocturna)
       (superficie_minima   60)
       (precio_minimo       0)
  )

  ;; SOL3: Individuo. Trabaja en casa. Busca paz.
  ([SOL3] of Individuo
       (edad_mas_anciano    30)
       (movilidad_reducida  FALSE)
       (tiene_mascota       TRUE)
       (num_personas        1)
       (presupuesto_flexible FALSE)
       (presupuesto_maximo  800)
       (tiene_coche         FALSE)
       (trabaja_en_casa     TRUE)
       (trabaja_en_x        0.0)
       (trabaja_en_y        0.0)
       (busca_vivienda      Piso)
       (prefiere_cerca      Supermercado)
       (superficie_minima   40)
       (precio_minimo       400)
  )

  ;; SOL4: Pareja. Trabaja en Centro.
  ([SOL4] of Pareja
       (edad_mas_anciano    35)
       (movilidad_reducida  FALSE)
       (tiene_mascota       FALSE)
       (num_personas        2)
       (presupuesto_flexible TRUE)
       (presupuesto_maximo  1400)
       (tiene_coche         TRUE)
       (trabaja_en_casa     FALSE)
       (trabaja_en_x        1000.0)
       (trabaja_en_y        1000.0)
       (busca_vivienda      Piso Dúplex)
       (prefiere_cerca      Cine Supermercado)
       (superficie_minima   60)
       (precio_minimo       600)
  )

  ;; SOL5: Anciano. Necesita ascensor y salud.
  ([SOL5] of Individuo
       (edad_mas_anciano    80)
       (movilidad_reducida  TRUE)
       (tiene_mascota       TRUE)
       (num_personas        1)
       (presupuesto_flexible TRUE)
       (presupuesto_maximo  900)
       (tiene_coche         FALSE)
       (trabaja_en_casa     TRUE)
       (trabaja_en_x        0.0)
       (trabaja_en_y        0.0)
       (busca_vivienda      Piso)
       (prefiere_cerca      Centro_Salud Supermercado)
       (superficie_minima   50)
       (precio_minimo       0)
  )

  ;; SOL6: Familia grande. Busca casa aislada o grande.
  ([SOL6] of Familia
       (edad_mas_anciano    45)
       (movilidad_reducida  FALSE)
       (tiene_mascota       FALSE)
       (num_personas        5)
       (presupuesto_flexible FALSE)
       (presupuesto_maximo  1600)
       (tiene_coche         TRUE)
       (trabaja_en_casa     FALSE)
       (trabaja_en_x        5000.0)
       (trabaja_en_y        5000.0)
       (edad_hijo_menor     4)
       (num_hijos           3)
       (busca_vivienda      Unifamiliar Dúplex)
       (prefiere_cerca      Parque)
       (superficie_minima   110)
       (precio_minimo       800)
  )

  ;; SOL7: Estudiante pobre.
  ([SOL7] of Estudiantes
       (edad_mas_anciano    20)
       (movilidad_reducida  FALSE)
       (tiene_mascota       FALSE)
       (num_personas        1)
       (presupuesto_flexible TRUE)
       (presupuesto_maximo  500)
       (tiene_coche         FALSE)
       (trabaja_en_casa     FALSE)
       (trabaja_en_x        1000.0)
       (trabaja_en_y        3000.0)
       (busca_vivienda      Piso)
       (prefiere_cerca      Parada_Metro)
       (superficie_minima   20)
       (precio_minimo       0)
  )

  ;; SOL8: Pareja rica. Busca lujo.
  ([SOL8] of Pareja
       (edad_mas_anciano    50)
       (movilidad_reducida  FALSE)
       (tiene_mascota       TRUE)
       (num_personas        2)
       (presupuesto_flexible TRUE)
       (presupuesto_maximo  3000)
       (tiene_coche         TRUE)
       (trabaja_en_casa     TRUE)
       (trabaja_en_x        0.0)
       (trabaja_en_y        0.0)
       (busca_vivienda      Unifamiliar Dúplex Piso)
       (prefiere_cerca      Parque Cine)
       (superficie_minima   150)
       (precio_minimo       1500)
  )
)