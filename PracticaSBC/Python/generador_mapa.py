import random
import sys

# --- CONFIGURACIÓN ---
NOMBRE_ARCHIVO_CLP = "new_instancies.clp"
NOMBRE_IMAGEN = "ciutat.png"
NUM_VIVIENDAS = 500
NUM_SERVICIOS = 40
NUM_SOLICITANTES = 8
CIUDAD_SIZE = 5000

print("--- INICIANDO GENERADOR MAPA v2 (Garantiza Matches) ---")

try:
    import matplotlib.pyplot as plt
    import matplotlib.patches as patches
    from faker import Faker
    fake = Faker('es_ES')
except ImportError:
    print("Falta libreria. Ejecuta: pip install matplotlib faker")
    sys.exit(1)

# Estilos visuales diferentes para cada tipo de servicio
ESTILOS = {
    "Centro_Salud": {"c": "red", "m": "P", "label": "Salud"},
    "Colegio": {"c": "cyan", "m": "s", "label": "Educación"},
    "Parque": {"c": "green", "m": "p", "label": "Zonas Verdes"},
    "Supermercado": {"c": "magenta", "m": "D", "label": "Comercio"},
    "Zona_Nocturna": {"c": "orange", "m": "*", "label": "Ocio"},
    "Parada_Metro": {"c": "black", "m": "v", "label": "Transporte"},
    "default": {"c": "gray", "m": ".", "label": "Otros"}
}

BARRIOS = [("Centro", 1000, 1000, 400), ("Universitario", 1000, 3000, 300), 
           ("Residencial", 3000, 1000, 500), ("Lujo", 4500, 4500, 600)]

def get_coords_in_barrio():
    barrio = random.choice(BARRIOS)
    bx, by, disp = barrio[1], barrio[2], barrio[3]
    x = max(0, min(CIUDAD_SIZE, int(random.gauss(bx, disp))))
    y = max(0, min(CIUDAD_SIZE, int(random.gauss(by, disp))))
    return x, y, barrio[0]

# --- ESTRUCTURAS ---
viviendas = []
servicios = []
solicitantes = []

# 1. GENERAR VIVIENDAS (Primero, porque son la base)
print("Generando viviendas...")
tipos_viv = ["Piso", "Unifamiliar", "Dúplex"]

for i in range(NUM_VIVIENDAS):
    x, y, zona = get_coords_in_barrio()
    tipo = "Unifamiliar" if zona == "Lujo" else random.choice(tipos_viv)
    
    # Datos de la casa
    precio = random.randint(600, 3000) if zona != "Lujo" else random.randint(2000, 5000)
    hd = random.randint(1, 3) # Habitaciones dobles
    hi = random.randint(0, 2) # Habitaciones individuales
    capacidad = (hd * 2) + hi
    
    v = {
        "id": f"GEN_VIV_{i+1:02d}", "tipo": tipo, "x": x, "y": y,
        "precio": precio, "capacidad": capacidad, 
        "hd": hd, "hi": hi,
        "zona": zona
    }
    viviendas.append(v)

# 2. GENERAR SERVICIOS
print("Generando servicios...")
tipos_posibles = list(ESTILOS.keys())
types_clean = [t for t in tipos_posibles if t != "default"]

for i in range(NUM_SERVICIOS):
    x, y, zona = get_coords_in_barrio()
    cls_serv = random.choice(types_clean)
    s = {"id": f"GEN_SERV_{i+1:02d}", "tipo": cls_serv, "nombre": f"{cls_serv} {fake.company()}", "x": x, "y": y}
    servicios.append(s)

# 3. GENERAR SOLICITANTES (TRUCADOS PARA ENCONTRAR CASA)
print("Generando solicitantes a medida...")
clases_sol = ["Familia", "Estudiantes", "Pareja", "Individuo"]

for i in range(NUM_SOLICITANTES):
    casa_target = random.choice(viviendas)
    # Datos básicos basados en la casa objetivo
    presupuesto = casa_target['precio'] + random.randint(100, 500) # Tienen dinero suficiente
    tipo_buscado = casa_target['tipo']
    # Ajustar ocupantes a la capacidad
    capacidad_max = casa_target['capacidad']
    num_personas = random.randint(1, max(1, capacidad_max))
    # Decidir clase de persona lógica según capacidad
    if num_personas == 1: clase = "Individuo"
    elif num_personas == 2: clase = random.choice(["Pareja", "Estudiantes"])
    else: clase = random.choice(["Familia", "Estudiantes"])
    # Ubicación trabajo (Aleatoria, esto puede penalizar pero no descartar)
    tx, ty, _ = get_coords_in_barrio()

    sol = {
        "id": f"GEN_SOL_{i+1:02d}", "clase": clase,
        "trabajo_x": tx, "trabajo_y": ty, 
        "presupuesto": presupuesto,
        "busca": tipo_buscado,
        "num_personas": num_personas,
        "match_id": casa_target['id'] # Para depuración
    }
    solicitantes.append(sol)

# 4. ESCRIBIR CLIPS
print(f"Escribiendo {NOMBRE_ARCHIVO_CLP}...")
with open(NOMBRE_ARCHIVO_CLP, "w", encoding="utf-8") as f:
    f.write(f";;; INSTANCIAS OPTIMIZADAS (Matches Garantizados)\n\n(definstances instances-generadas\n")
    
    # Viviendas
    for v in viviendas:
        f.write(f"""    ([{v['id']}] of {v['tipo']} (coordx {v['x']}) (coordy {v['y']}) 
        (precio_mensual {v['precio']}) (superficie {random.randint(60,200)}) 
        (num_habs_dobles {v['hd']}) (num_habs_individual {v['hi']}) 
        (es_soleado "Todo el dia") (tiene_ascensor TRUE) (tiene_terraza TRUE) 
        (amueblado TRUE) (tiene_calefaccion SI) (tiene_aire_acondicionado SI) 
        (permite_mascotas TRUE) (num_banos 2) (altura_piso 2))\n""")

    # Servicios
    for s in servicios:
        f.write(f"""    ([{s['id']}] of {s['tipo']} (nombre_servicio "{s['nombre']}") (servicio_en_x {s['x']}) (servicio_en_y {s['y']}))\n""")

    # Solicitantes
    for sol in solicitantes:
        extra = "(num_hijos 1) (edad_hijo_menor 10)" if sol['clase'] == "Familia" else ""
        busca_str = sol['busca']
        f.write(f"""    ([{sol['id']}] of {sol['clase']} 
        (trabaja_en_x {sol['trabajo_x']}) (trabaja_en_y {sol['trabajo_y']}) 
        (presupuesto_maximo {sol['presupuesto']}) (busca_vivienda {busca_str}) 
        (num_personas {sol['num_personas']}) (precio_minimo 0) (superficie_minima 40) 
        (tiene_coche FALSE) (tiene_mascota FALSE) (trabaja_en_casa FALSE) 
        (movilidad_reducida FALSE) (edad_mas_anciano 40) (prefiere_cerca Supermercado) 
        (presupuesto_flexible FALSE) {extra})\n""")
        
    f.write(")\n")

# 5. GENERAR MAPA
print("Generando Mapa...")
fig, ax = plt.subplots(figsize=(10, 10))

# Viviendas
vx = [v["x"] for v in viviendas]; vy = [v["y"] for v in viviendas]
ax.scatter(vx, vy, c='blue', marker='s', s=50, label='Viviendas', edgecolors='white', zorder=2)

# Servicios
servicios_por_tipo = {}
for s in servicios:
    t = s['tipo']
    if t not in servicios_por_tipo: servicios_por_tipo[t] = {'x':[], 'y':[]}
    servicios_por_tipo[t]['x'].append(s['x']); servicios_por_tipo[t]['y'].append(s['y'])

for tipo, coords in servicios_por_tipo.items():
    estilo = ESTILOS.get(tipo, ESTILOS["default"])
    ax.scatter(coords['x'], coords['y'], c=estilo['c'], marker=estilo['m'], s=80, edgecolors='black', label=estilo['label'], zorder=3)

# Dibujar lineas de "Match Esperado" (Solo visualización)
for sol in solicitantes:
    # Buscar coords de la casa target
    target = next(item for item in viviendas if item["id"] == sol["match_id"])
    # Dibujar linea punteada gris fina desde el Trabajo del solicitante a su Casa Ideal
    # (Esto muestra visualmente que hay una relación, aunque en CLIPS sea por atributos)
    # plt.plot([sol['trabajo_x'], target['x']], [sol['trabajo_y'], target['y']], 'k--', alpha=0.1)

plt.legend(bbox_to_anchor=(1.02, 1), loc='upper left', title="Leyenda")
plt.title(f"Mapa de la ciudad: {NUM_SOLICITANTES} Matches Diseñados")
plt.grid(True, alpha=0.3)
plt.tight_layout()
plt.savefig(NOMBRE_IMAGEN, dpi=100)
print(f">> ¡HECHO! Todo listo en {NOMBRE_ARCHIVO_CLP}")