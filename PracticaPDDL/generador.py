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
    # INIT (adicional según extensión)
    contenido += "      (= (beneficio) 0)\n"
    contenido += "   )\n\n"

    # GOAL (estado final)
    contenido += "   (:goal (forall (?r - reserva) (procesada ?r)))\n"

    # METRIC (optimización)
    contenido += "   (:metric maximize (beneficio))\n"
    return contenido

# ---------- ESCRITURA ESPECÍFICA EXTENSIÓN 3 ------------------------------
# --------------------------------------------------------------------------
def extension3():
    contenido = ""
    # INIT (adicional según extensión)
    contenido += "      (= (beneficio) 0)\n"
    contenido += "   )\n\n"

    # GOAL (estado final)
    contenido += "   (:goal (forall (?r - reserva) (procesada ?r)))\n"

    # METRIC (optimización)
    contenido += "   (:metric maximize (beneficio))\n"
    return contenido

# ---------- ESCRITURA ESPECÍFICA EXTENSIÓN 2 ------------------------------
# --------------------------------------------------------------------------
def extension2(lista_habitaciones, lista_reservas):
    contenido = ""
    orientaciones = ["norte", "sur", "este", "oeste"]
    # INIT (adicional según extensión)
    for h in lista_habitaciones: # Generar orientación para cada habitación
        o = random.choice(orientaciones) 
        contenido += f"      (orientada {h.id} {o})\n"
    for r in lista_reservas: # Generar preferencia para cada reserva
        o = random.choice(orientaciones)
        contenido += f"      (orientacion-preferida {r.id} {o})\n"
    contenido += "      (= (beneficio) 0)\n" # Beneficio inicial
    contenido += "   )\n\n"

    # GOAL (estado final)
    contenido += "   (:goal (forall (?r - reserva) (procesada ?r)))\n"

    # METRIC (optimización)
    contenido += "   (:metric maximize (beneficio))\n"
    return contenido

# ---------- ESCRITURA ESPECÍFICA EXTENSIÓN 1 ------------------------------
# --------------------------------------------------------------------------
def extension1():
    contenido = ""
    # INIT (adicional según extensión)
    contenido += "      (= (beneficio) 0)\n"
    contenido += "   )\n\n"

    # GOAL (estado final)
    contenido += "   (:goal (forall (?r - reserva) (procesada ?r)))\n"

    # METRIC (optimización)
    contenido += "   (:metric maximize (beneficio))\n"
    return contenido

# ---------- ESCRITURA ESPECÍFICA NIVEL BÁSICO -----------------------------
# --------------------------------------------------------------------------
def basico():
    contenido = ""
    # INIT (adicional según extensión)
        # No requiere inicialización extra
    contenido += "   )\n\n"

    # GOAL (estado final)
    contenido += "   (:goal (forall (?r - reserva) (asignada ?r)))\n"

    # METRIC (optimización)
        # No hay ninguna métrica de optimización
    return contenido


# ---------- ESCRITURA GENERAL ---------------------------------------------
# --------------------------------------------------------------------------
def generar_problema(numHabs, numReservas, dominio, nombre_fichero):
    # Generamos las habitaciones (hab001, hab002...)
    lista_habitaciones = []
    for i in range(1, numHabs + 1):
        nombre = f"hab{i:03d}"
        capacidad = random.randint(1, MAX_CAPACIDAD)
        lista_habitaciones.append(Habitacion(nombre, capacidad))
    str_habs = " ".join([h.id for h in lista_habitaciones])

    # Generamos las reservas (res001, res002...)
    lista_reservas = []
    for i in range(1, numReservas + 1):
        nombre = f"res{i:03d}"
        personas = random.randint(1, MAX_PERSONAS)
        inicio = random.randint(1, 25) 
        duracion = random.randint(1, 5) 
        lista_reservas.append(Reserva(nombre, personas, inicio, duracion))
    str_res = " ".join([r.id for r in lista_reservas])

    # Generamos los dias (dia1, dia2 ... dia30)
    str_dias = " ".join([f"dia{d}" for d in range(1, MAX_DIAS + 1)])

    # ---------- ESCRITURA DEL FICHERO DE PROBLEMA (PDDL) ------------------
    contenido = ""

    # CABECERA
    contenido += f"(define (problem problema-{dominio}) (:domain {dominio})\n"
    
    # OBJETOS
    contenido += f"   (:objects\n"
    contenido += f"      {str_dias} - dia\n"
    contenido += f"      {str_habs} - habitacion\n"
    contenido += f"      {str_res} - reserva\n"
    contenido += f"   )\n\n"

    # INIT (general)
    contenido += "   (:init\n"
    for h in lista_habitaciones: # Capacidades de habitaciones
        contenido += f"      (= (capacidad {h.id}) {h.capacidad})\n"
    contenido += "\n"
    for r in lista_reservas: # Datos de reservas (Personas y Días)
        contenido += f"      (= (personas {r.id}) {r.personas})\n"
        for d in range(r.inicio, r.inicio + r.duracion):
            contenido += f"      (dia-reserva dia{d} {r.id})\n"
        contenido += "\n"

    # GOAL + METRIC (específico según extensión)
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

    # Comprobamos si el archivo existe para evitar errores feos
    if not os.path.isfile(ruta_ff):
        print(f"Error: No se encuentra el ejecutable en '{ruta_ff}'")
        return

    # Construimos el comando: ./ff -o dominio.pddl -f problema.pddl
    comando = f"{ruta_ff} -o {archivo_dominio} -f {archivo_problema}"
    print("\n\n")
    
    # Ejecutamos el comando y mostramos la salida directamente
    try: subprocess.run(comando, shell=True, check=True)
    except subprocess.CalledProcessError:
        print("\nError durante la ejecución del planificador.")


# ---------- MAIN ----------------------------------------------------------
# --------------------------------------------------------------------------
if __name__ == "__main__":
    print("--- GENERADOR DE PROBLEMAS PDDL ---")
    
    try:
        # Definir la extensión a probar
        print("Que estensión quieres probar [0/1/2/3/4]?: ", end="")
        extension = int(input()) 
        match extension: # Mapeo del número a nombre de dominio/extensión
            case 0: dominio = "basico"
            case 1: dominio = "extension1"
            case 2: dominio = "extension2"
            case 3: dominio = "extension3"
            case 4: dominio = "extension4"
            case _: # por defecto usamos el básico
                print("-> Extensión no válida, usando básico por defecto")
                dominio = "basico"

        # Numero de habitaciones
        print("Introduce el número de habitaciones: ", end="")
        num_habs = int(input()) 

        # Numero de reservas
        print("Introduce el número de reservas: ", end="")
        num_res = int(input())

        # Semilla aleatoria
        print("Introduce una semilla (Enter para usar una semilla aleatoria): ", end="")
        semilla_str = input()
        if semilla_str == "":
            semilla = random.randint(1, 1000000)
            print(f"-> Semilla no especificada. Usando aleatoria: {semilla}")
        else:
            semilla = int(semilla_str)

        random.seed(semilla) # Configuración de la semilla
        nombre_fichero = f"{NOMBRE_FICHERO}_{dominio}_{num_habs}hab_{num_res}res.pddl" # Configuración del nombre del archivo

        # Generamos el archivo
        generar_problema(num_habs, num_res, dominio, nombre_fichero)

        # Ejecutamos la planifiación (con el archivo de problema creado)
        print("\n¿Quieres ejecutar el planificador ahora? (y/n): ", end="")
        if input().lower() == 'y':
            match extension:
                case 0: archivo_dominio = "dominioHotel.pddl"
                case 1: archivo_dominio = "dominioHotel1.pddl"
                case 2: archivo_dominio = "dominioHotel2.pddl"
                case 3: archivo_dominio = "dominioHotel3.pddl"
                case 4: archivo_dominio = "dominioHotel4.pddl"
                case _: archivo_dominio = "dominioHotel.pddl" # por defecto usamos el básico
            
            if archivo_dominio: ejecutar_planificador(archivo_dominio, nombre_fichero)
            else:
                print("Error: No se ha identificado el archivo de dominio.")

    except ValueError:
        print("Error: Por favor, introduce números enteros válidos.")