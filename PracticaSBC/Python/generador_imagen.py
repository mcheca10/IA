import random
import sys

# --- CONFIGURACIÓN ---
NOMBRE_ARCHIVO_CLP = "instancies.clp"
NOMBRE_IMAGEN = "mapa_ciutat.png"
NUM_VIVIENDAS = 100
NUM_SERVICIOS = 40
NUM_SOLICITANTES = 8
CIUDAD_SIZE = 5000

print("--- INICIANDO GENERADOR V2 (VISUAL) ---")

try:
    import matplotlib.pyplot as plt
    import matplotlib.patches as patches
    from faker import Faker
    fake = Faker('es_ES')
except ImportError:
    print("Falta libreria faker o matplotlib. Ejecuta: pip install matplotlib faker")
    sys.exit(1)

# --- ESTILOS VISUALES POR TIPO DE SERVICIO ---
# c = color, m = marker (forma), label = nombre en leyenda
# Formas: 'P' (Cruz), '*' (Estrella), 'p' (Pentágono), 'D' (Diamante), 's' (Cuadrado)
ESTILOS = {
    "Centro_Salud":  {"c": "red",       "m": "P", "label": "Salud (Hosp/CAP)"},
    "Hospital":      {"c": "red",       "m": "P", "label": "_nolegend_"}, # Mismo estilo
    "Colegio":       {"c": "cyan",      "m": "s", "label": "Educación"},
    "Parque":        {"c": "green",     "m": "p", "label": "Zonas Verdes"},
    "Supermercado":  {"c": "magenta",   "m": "D", "label": "Comercio"},
    "Zona_Nocturna": {"c": "orange",    "m": "*", "label": "Ocio/Fiesta"},
    "Cine":          {"c": "orange",    "m": "*", "label": "_nolegend_"},
    "Parada_Metro":  {"c": "black",     "m": "v", "label": "Transporte"},
    "default":       {"c": "gray",      "m": ".", "label": "Otros"}
}

BARRIOS = [
    ("Centro", 1000, 1000, 400),
    ("Universitario", 1000, 3000, 300),
    ("Residencial", 3000, 1000, 500),
    ("Lujo/Aislado", 4500, 4500, 600)
]

def get_coords_in_barrio():
    barrio = random.choice(BARRIOS)
    bx, by, disp = barrio[1], barrio[2], barrio[3]
    x = int(random.gauss(bx, disp))
    y = int(random.gauss(by, disp))
    x = max(0, min(CIUDAD_SIZE, x))
    y = max(0, min(CIUDAD_SIZE, y))
    return x, y, barrio[0]

# --- ESTRUCTURAS DE DATOS ---
viviendas = []
servicios = []
solicitantes = []

# 1. Datos de entrada
print("Generando datos...")

# Viviendas
tipos_viv = ["Piso", "Unifamiliar", "Dúplex"]
for i in range(NUM_VIVIENDAS):
    x, y, zona = get_coords_in_barrio()
    tipo = "Unifamiliar" if zona == "Lujo/Aislado" else random.choice(tipos_viv)
    # Lógica precio
    base = 1500 if zona == "Lujo/Aislado" else 600
    precio = random.randint(base, base + 2000)
    
    # Flags aleatorios
    ascensor = "TRUE" if (tipo != "Unifamiliar" and random.random() > 0.3) else "FALSE"
    
    v = {"id": f"GEN_VIV_{i+1:02d}", "tipo": tipo, "x": x, "y": y, "precio": precio, "ascensor": ascensor}
    viviendas.append(v)

# Servicios (Usamos las claves del diccionario ESTILOS)
tipos_posibles = ["Colegio", "Supermercado", "Parque", "Parada_Metro", "Centro_Salud", "Zona_Nocturna", "Cine", "Hospital"]

for i in range(NUM_SERVICIOS):
    x, y, zona = get_coords_in_barrio()
    cls_serv = random.choice(tipos_posibles)
    s = {
        "id": f"GEN_SERV_{i+1:02d}", "tipo": cls_serv,
        "nombre": f"{cls_serv} {fake.company()}", "x": x, "y": y
    }
    servicios.append(s)

# Solicitantes
clases_sol = ["Familia", "Estudiantes", "Pareja", "Individuo"]
for i in range(NUM_SOLICITANTES):
    x, y, zona = get_coords_in_barrio()
    clase = random.choice(clases_sol)
    sol = {
        "id": f"GEN_SOL_{i+1:02d}", "clase": clase,
        "trabajo_x": x, "trabajo_y": y, "presupuesto": random.randint(600, 2500)
    }
    solicitantes.append(sol)

# 2. GENERAR ARCHIVO .CLP
print(f"Escribiendo {NOMBRE_ARCHIVO_CLP}...")
with open(NOMBRE_ARCHIVO_CLP, "w", encoding="utf-8") as f:
    f.write(f";;; GENERADO AUTOMATICAMENTE POR SCRIPT VISUAL\n\n(definstances instances-generadas\n")
    
    for v in viviendas:
        f.write(f"""    ([{v['id']}] of {v['tipo']} (coordx {v['x']}) (coordy {v['y']}) (precio_mensual {v['precio']}) 
        (superficie {random.randint(50,150)}) (num_habs_dobles 1) (num_habs_individual 2) (es_soleado "Manana") 
        (tiene_ascensor {v['ascensor']}) (tiene_terraza TRUE) (amueblado TRUE) (tiene_calefaccion SI) 
        (tiene_aire_acondicionado NO) (permite_mascotas TRUE) (num_banos 1) (altura_piso 2))\n""")

    for s in servicios:
        f.write(f"""    ([{s['id']}] of {s['tipo']} (nombre_servicio "{s['nombre']}") (servicio_en_x {s['x']}) (servicio_en_y {s['y']}))\n""")

    for sol in solicitantes:
        extra = "(num_hijos 2) (edad_hijo_menor 10)" if sol['clase'] == "Familia" else ""
        f.write(f"""    ([{sol['id']}] of {sol['clase']} (trabaja_en_x {sol['trabajo_x']}) (trabaja_en_y {sol['trabajo_y']}) 
        (presupuesto_maximo {sol['presupuesto']}) (busca_vivienda Piso) (precio_minimo 0) (superficie_minima 40) 
        (num_personas 2) (tiene_coche TRUE) (tiene_mascota FALSE) (trabaja_en_casa FALSE) 
        (movilidad_reducida FALSE) (edad_mas_anciano 40) (prefiere_cerca Supermercado) 
        (presupuesto_flexible TRUE) {extra})\n""")
        
    f.write(")\n")

# 3. GENERAR MAPA VISUAL CON LEYENDA
print("Generando Mapa con Iconos...")
fig, ax = plt.subplots(figsize=(12, 10))

# Dibujar Barrios (Fondo)
colores_barrio = {"Centro": "yellow", "Universitario": "purple", "Residencial": "green", "Lujo/Aislado": "orange"}
for b_name, bx, by, disp in BARRIOS:
    circle = patches.Circle((bx, by), disp*1.5, color=colores_barrio[b_name], alpha=0.1)
    ax.add_patch(circle)
    ax.text(bx, by-disp*1.5, b_name.upper(), ha='center', fontsize=9, alpha=0.4, fontweight='bold')

# Dibujar Viviendas (Todas iguales: Cuadrado Azul)
vx = [v["x"] for v in viviendas]
vy = [v["y"] for v in viviendas]
ax.scatter(vx, vy, c='blue', marker='s', s=50, label='Viviendas', edgecolors='white', zorder=2)

# Dibujar Servicios (Agrupados por tipo para la leyenda)
# Primero agrupamos
servicios_por_tipo = {}
for s in servicios:
    t = s['tipo']
    if t not in servicios_por_tipo: servicios_por_tipo[t] = {'x':[], 'y':[]}
    servicios_por_tipo[t]['x'].append(s['x'])
    servicios_por_tipo[t]['y'].append(s['y'])

# Ahora pintamos cada grupo con su estilo
for tipo, coords in servicios_por_tipo.items():
    estilo = ESTILOS.get(tipo, ESTILOS["default"])
    # Solo ponemos label si no empieza por _
    label = estilo["label"] if not estilo["label"].startswith("_") else None
    
    ax.scatter(coords['x'], coords['y'], 
               c=estilo['c'], 
               marker=estilo['m'], 
               s=100, # Tamaño grande para que se vean bien
               edgecolors='black', # Borde negro para resaltar
               label=label,
               zorder=3)

# Configuración Final
plt.title(f"Mapa de Instancias ({NUM_VIVIENDAS} vivs, {NUM_SERVICIOS} servs)", fontsize=16)
plt.xlim(-500, CIUDAD_SIZE + 500); plt.ylim(-500, CIUDAD_SIZE + 500)
plt.grid(True, linestyle=':', alpha=0.5)

# Leyenda fuera del gráfico para que no tape nada
plt.legend(bbox_to_anchor=(1.02, 1), loc='upper left', borderaxespad=0, title="Leyenda")
plt.tight_layout()

plt.savefig(NOMBRE_IMAGEN, dpi=150)
print(f">> ¡HECHO! Imagen guardada: {NOMBRE_IMAGEN}")
print(f">> ¡HECHO! Instancias guardadas: {NOMBRE_ARCHIVO_CLP}")