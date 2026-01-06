import random
import subprocess
import os
from dataclasses import dataclass

NOMBRE_FICHERO = "problemaGEN"

MAX_CAPACIDAD = 4
MAX_PERSONAS = 4
MAX_DIAS = 30


@dataclass
class Habitacion:
    id: str
    capacidad: int

@dataclass
class Reserva:
    id: str
    personas: int
    inicio: int
    duracion: int

# ---------- ESCRITURA ESPECÍFICA EXTENSIÓN 4 ------------------------------
# --------------------------------------------------------------------------
def extension4():
    contenido = ""
    # INIT
    contenido += "      (= (total-cost) 0)\n"
    contenido += "   )\n\n"

    # GOAL (estado final)
    contenido += "   (:goal (forall (?r - reserva) (procesada ?r)))\n"

    # METRIC (optimización)
    contenido += "   (:metric minimize (total-cost))\n"
    return contenido

# ---------- ESCRITURA ESPECÍFICA EXTENSIÓN 3 ------------------------------
# --------------------------------------------------------------------------
def extension3():
    contenido = ""
    # INIT
    contenido += "      (= (total-cost) 0)\n"
    contenido += "   )\n\n"

    # GOAL
    contenido += "   (:goal (forall (?r - reserva) (procesada ?r)))\n"

    # METRIC
    contenido += "   (:metric minimize (total-cost))\n"
    return contenido

# ---------- ESCRITURA ESPECÍFICA EXTENSIÓN 2 ------------------------------
# --------------------------------------------------------------------------
def extension2(lista_habitaciones, lista_reservas):
    contenido = ""
    orientaciones = ["norte", "sur", "este", "oeste"]
    # INIT
    for h in lista_habitaciones: 
        o = random.choice(orientaciones) 
        contenido += f"      (orientada {h.id} {o})\n"
    for r in lista_reservas: 
        o = random.choice(orientaciones)
        contenido += f"      (quiere {r.id} {o})\n"
    
    contenido += "      (= (total-cost) 0)\n"
    contenido += "   )\n\n"

    # GOAL
    contenido += "   (:goal (forall (?r - reserva) (procesada ?r)))\n"

    # METRIC
    contenido += "   (:metric minimize (total-cost))\n"
    return contenido

# ---------- ESCRITURA ESPECÍFICA EXTENSIÓN 1 ------------------------------
# --------------------------------------------------------------------------
def extension1():
    contenido = ""
    # INIT
    contenido += "      (= (total-cost) 0)\n"
    contenido += "   )\n\n"

    # GOAL
    contenido += "   (:goal (forall (?r - reserva) (procesada ?r)))\n"

    # METRIC
    contenido += "   (:metric minimize (total-cost))\n"
    return contenido

# ---------- ESCRITURA ESPECÍFICA NIVEL BÁSICO -----------------------------
# --------------------------------------------------------------------------
def basico():
    contenido = ""
    # INIT
    contenido += "   )\n\n"

    # GOAL: El básico usa (asignada ?r) y NO tiene procesada
    contenido += "   (:goal (forall (?r - reserva) (asignada ?r)))\n"

    # METRIC: No tiene métrica
    return contenido


# ---------- ESCRITURA GENERAL ---------------------------------------------
# --------------------------------------------------------------------------
def generar_problema(numHabs, numReservas, dominio, nombre_fichero):
    # Generamos habitaciones
    lista_habitaciones = []
    for i in range(1, numHabs + 1):
        nombre = f"hab{i:03d}"
        capacidad = random.randint(1, MAX_CAPACIDAD)
        lista_habitaciones.append(Habitacion(nombre, capacidad))
    str_habs = " ".join([h.id for h in lista_habitaciones])

    # Generamos reservas
    lista_reservas = []
    for i in range(1, numReservas + 1):
        nombre = f"res{i:03d}"
        personas = random.randint(1, MAX_PERSONAS)
        inicio = random.randint(1, 25) 
        duracion = random.randint(1, 5) 
        lista_reservas.append(Reserva(nombre, personas, inicio, duracion))
    str_res = " ".join([r.id for r in lista_reservas])

    # ---------- ESCRITURA DEL FICHERO PDDL ------------------
    contenido = ""

    suffix = dominio.capitalize() if dominio == "basico" else dominio.replace("extension", "Extension")
    nombre_dominio_real = f"dominioHotel{suffix}"
    
    contenido += f"(define (problem problema-{dominio}) (:domain {nombre_dominio_real})\n"
    
    # OBJETOS
    contenido += f"   (:objects\n"
    contenido += f"      {str_habs} - habitacion\n"
    contenido += f"      {str_res} - reserva\n"
    contenido += f"   )\n\n"

    # INIT
    contenido += "   (:init\n"
    for h in lista_habitaciones: 
        contenido += f"      (= (capacidad {h.id}) {h.capacidad})\n"
    contenido += "\n"
    for r in lista_reservas: 
        contenido += f"      (= (personas {r.id}) {r.personas})\n"
        contenido += f"      (= (desde {r.id}) {r.inicio})\n"
        contenido += f"      (= (hasta {r.id}) {r.inicio + r.duracion - 1})\n" 
        contenido += "\n"

    # Llamada a la función específica que cierra el INIT y añade GOAL/METRIC
    match dominio:
        case "basico": contenido += basico()
        case "extension1": contenido += extension1()
        case "extension2": contenido += extension2(lista_habitaciones, lista_reservas)
        case "extension3": contenido += extension3()
        case "extension4": contenido += extension4()
    contenido += ")\n"

    try:
        with open(nombre_fichero, "w") as f:
            f.write(contenido)
        print(f"Archivo generado con éxito: {nombre_fichero}")
    except IOError as e:
        print(f"Error: al escribir el archivo [{e}]")


# ---------- EJECUTAR PLANIFICADOR -----------------------------------------
# --------------------------------------------------------------------------
def ejecutar_planificador(archivo_dominio, archivo_problema):
    print("\n--- EJECUCIÓN DEL PLANIFICADOR ---")
    print("Introduce la ruta relativa al ejecutable 'ff' (ej: ./ff o ../Metric-FF/ff)")
    ruta_ff = input("Ruta: ").strip()

    if not os.path.isfile(ruta_ff):
        print(f"Error: No se encuentra el ejecutable en '{ruta_ff}'")
        return

    # Usamos flag -O para optimizar métricas (excepto en básico que no tiene)
    flag_opt = "-O " if "Basico" not in archivo_dominio else ""
    comando = f"{ruta_ff} {flag_opt}-o Codigos/{archivo_dominio} -f {archivo_problema}"
    print(f"Ejecutando: {comando}\n\n")
    
    try: 
        subprocess.run(comando, shell=True, check=True)
    except subprocess.CalledProcessError:
        print("\nError durante la ejecución del planificador.")


# ---------- MAIN ----------------------------------------------------------
# --------------------------------------------------------------------------
if __name__ == "__main__":
    print("--- GENERADOR DE PROBLEMAS PDDL (ESTRATEGIA 2) ---")
    
    try:
        print("Que extensión quieres probar [0/1/2/3/4]?: ", end="")
        extension = int(input()) 
        match extension: 
            case 0: dominio = "basico"
            case 1: dominio = "extension1"
            case 2: dominio = "extension2"
            case 3: dominio = "extension3"
            case 4: dominio = "extension4"
            case _: 
                print("-> Extensión no válida, usando básico por defecto")
                dominio = "basico"

        print("Introduce el número de habitaciones: ", end="")
        num_habs = int(input()) 

        print("Introduce el número de reservas: ", end="")
        num_res = int(input())

        print("Introduce una semilla (Enter para aleatoria): ", end="")
        semilla_str = input()
        if semilla_str == "":
            semilla = random.randint(1, 1000000)
            print(f"-> Semilla usada: {semilla}")
        else:
            semilla = int(semilla_str)

        random.seed(semilla) 
        nombre_fichero = f"{NOMBRE_FICHERO}_{dominio}_{num_habs}hab_{num_res}res.pddl" 

        generar_problema(num_habs, num_res, dominio, nombre_fichero)

        print("\n¿Quieres ejecutar el planificador ahora? (y/n): ", end="")
        if input().lower() == 'y':
            # Selección automática del nombre del archivo de dominio real
            match extension:
                case 0: archivo_dominio = "dominioHotelBasico.pddl"
                case 1: archivo_dominio = "dominioHotelExtension1.pddl"
                case 2: archivo_dominio = "dominioHotelExtension2.pddl"
                case 3: archivo_dominio = "dominioHotelExtension3.pddl"
                case 4: archivo_dominio = "dominioHotelExtension4.pddl"
                case _: archivo_dominio = "dominioHotelBasico.pddl"
            
            if archivo_dominio: ejecutar_planificador(archivo_dominio, nombre_fichero)
            else:
                print("Error: No se ha identificado el archivo de dominio.")

    except ValueError:
        print("Error: Por favor, introduce números enteros válidos.")