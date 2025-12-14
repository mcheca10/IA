import random
import sys

# --- CONFIGURACIÓN ---
NOMBRE_ARCHIVO_CLP = "instancias_v9.clp"  
NOMBRE_IMAGEN = "mapa_v9.png"
NUM_VIVIENDAS = 100
NUM_SERVICIOS = 40
NUM_SOLICITANTES = 0 
CIUDAD_SIZE = 5000

print(f"--- GENERADOR DE INSTANCIAS (COMPATIBLE ONTOLOGIA V9) ---")

try:
    import matplotlib.pyplot as plt
    from faker import Faker
    fake = Faker('es_ES')
except ImportError:
    print("Falta libreria. Ejecuta: pip install matplotlib faker")
    sys.exit(1)

# Estilos visuales
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

# 1. GENERAR VIVIENDAS
print("Generando viviendas detalladas...")

# Clases válidas según ontologiav9.clp (SUBCLASES VIVIENDA)
# Atico y Bajo se han eliminado como clases, ahora son Pisos con características
tipos_posibles = ["Piso", "Unifamiliar", "Dúplex", "Estudio"]
certificados = ["A", "B", "C", "D", "E", "F", "G"]
accesos = ["COTA_CERO", "RAMPA", "ESCALONES"]

for i in range(NUM_VIVIENDAS):
    x, y, zona = get_coords_in_barrio()
    
    # Decisión lógica del tipo según zona
    if zona == "Lujo":
        tipo = random.choice(["Unifamiliar", "Dúplex"])
    elif zona == "Universitario":
        tipo = random.choice(["Piso", "Estudio"])
    else:
        tipo = random.choice(tipos_posibles)
    
    # Precio base
    precio = random.randint(400, 1200)
    if zona == "Centro": precio += 500
    if zona == "Lujo": precio += 1500
    if tipo == "Estudio": precio -= 200
    
    # Superficie y Habitaciones
    superficie = random.randint(40, 250)
    hd = random.randint(1, 3)
    hi = random.randint(0, 2)
    if tipo == "Estudio":
        hd = 0; hi = 0; superficie = 30
    
    # Propiedades específicas
    altura = random.randint(0, 8) # 0 es Bajo
    terraza = "NO"
    jardin = 0.0
    
    # Lógica de simulación de "Tipos" (Bajo/Atico)
    if altura == 0:
        # Es un Bajo funcionalmente
        pass
    elif altura >= 6:
        # Es un Ático funcionalmente si tiene terraza
        if random.random() > 0.3: terraza = "SI"
    
    if tipo == "Unifamiliar":
        altura = 0
        terraza = "SI" 
        jardin = round(random.uniform(0, 100), 2) # Slot tamano_jardin existe en Unifamiliar
        
    # Ascensor lógico
    ascensor = "SI" if altura > 3 else random.choice(["SI", "NO"])
    
    v = {
        "id": f"GEN_VIV_{i+1:03d}", 
        "tipo": tipo, 
        "x": x, "y": y,
        "precio": precio, 
        "superficie": superficie,
        "hd": hd, "hi": hi,
        "banos": random.randint(1, 3),
        "altura": altura,
        "ascensor": ascensor,
        "terraza": terraza,
        "jardin": jardin, # Solo para Unifamiliar
        "cert": random.choice(certificados), 
        "acc": random.choice(accesos),
        "amueblado": random.choice(["SI", "NO"]),
        "calefaccion": random.choice(["SI", "NO"]),
        "aire": random.choice(["SI", "NO"]),
        "mascotas": random.choice(["SI", "NO"]),
        "soleado": random.choice(['"Todo el dia"', '"Manana"', '"Tarde"', '"Nada"']),
        "parking": random.choice(["SI", "NO"]) 
    }
    viviendas.append(v)

# 2. GENERAR SERVICIOS
print("Generando servicios...")
tipos_serv = list(ESTILOS.keys())
types_clean = [t for t in tipos_serv if t != "default"]

for i in range(NUM_SERVICIOS):
    x, y, zona = get_coords_in_barrio()
    cls_serv = random.choice(types_clean)
    s = {"id": f"GEN_SERV_{i+1:02d}", "tipo": cls_serv, "nombre": f"{cls_serv} {fake.company()}", "x": x, "y": y}
    servicios.append(s)

# 3. GENERAR SOLICITANTES (Adaptados a V9)
print("Generando solicitantes...")
clases_sol = ["Familia", "Estudiantes", "Pareja", "Individuo", "CoLiving"]

for i in range(NUM_SOLICITANTES):
    casa_target = random.choice(viviendas)
    
    # Presupuesto ajustado
    presupuesto_obj = casa_target['precio']
    superficie_deseada = int(casa_target['superficie'] * 0.9)
    
    clase = random.choice(clases_sol)
    num_personas = 1
    extra_slots = ""
    
    if clase == "Familia":
        num_personas = random.randint(3, 5)
        # num_hijos sigue existiendo en ontologiav9 [cite: 14]
        hijos = random.randint(1, num_personas-1)
        extra_slots = f"(num_hijos {hijos})"
    elif clase == "Estudiantes":
        num_personas = random.randint(2, 4)
    elif clase == "Pareja":
        num_personas = 2
    elif clase == "CoLiving":
        num_personas = random.randint(3, 6)
        
    tx, ty, _ = get_coords_in_barrio()

    sol = {
        "id": f"GEN_SOL_{i+1:02d}", 
        "clase": clase,
        "trabajo_x": tx, "trabajo_y": ty, 
        "presupuesto": presupuesto_obj,
        "superficie_deseada": superficie_deseada,
        "num_personas": num_personas,
        "extra": extra_slots
    }
    solicitantes.append(sol)

# 4. ESCRIBIR CLIPS
print(f"Escribiendo {NOMBRE_ARCHIVO_CLP}...")
with open(NOMBRE_ARCHIVO_CLP, "w", encoding="utf-8") as f:
    f.write(f";;; INSTANCIAS GENERADAS AUTOMATICAMENTE (V9 COMPATIBLE)\n\n(definstances instances-generadas\n")
    
    # Escriptura de Viviendas
    for v in viviendas:
        # Slots comunes (Vivienda)
        common_slots = f"""
        (coordx {v['x']}) (coordy {v['y']}) 
        (precio_mensual {v['precio']}) (superficie {v['superficie']}) 
        (num_habs_dobles {v['hd']}) (num_habs_individual {v['hi']}) (num_banos {v['banos']})
        (es_soleado {v['soleado']}) (tiene_ascensor {v['ascensor']}) (tiene_terraza {v['terraza']}) 
        (amueblado {v['amueblado']}) (tiene_calefaccion {v['calefaccion']}) (tiene_aire_acondicionado {v['aire']}) 
        (permite_mascotas {v['mascotas']}) (altura_piso {v['altura']}) (tiene_parking {v['parking']})
        (certificado_energetico {v['cert']}) (acceso_portal {v['acc']})"""
        
        # Slots específicos
        specific_slots = ""
        
        # Slot tamano_jardin SOLO si es Unifamiliar 
        if v['tipo'] == "Unifamiliar":
            specific_slots = f"(tamano_jardin {v['jardin']})"

        f.write(f"    ([{v['id']}] of {v['tipo']} {common_slots} {specific_slots})\n")

    # Escriptura de Servicios
    for s in servicios:
        f.write(f"""    ([{s['id']}] of {s['tipo']} (nombre_servicio "{s['nombre']}") (servicio_en_x {s['x']}) (servicio_en_y {s['y']}))\n""")

    # Escriptura de Solicitantes Test
    for sol in solicitantes:
        f.write(f"""    ([{sol['id']}] of {sol['clase']} 
        (trabaja_en_x {sol['trabajo_x']}) (trabaja_en_y {sol['trabajo_y']}) 
        (presupuesto_esperado {sol['presupuesto']})
        (superficie_deseada {sol['superficie_deseada']})
        (num_personas {sol['num_personas']}) 
        (tiene_coche FALSE) (tiene_mascota FALSE) (teletrabajo FALSE) (necesita_muebles NO)
        (movilidad_reducida FALSE) (edad_mas_anciano 40) 
        (medio_transporte_principal publico)
        {sol['extra']})\n""")
        
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

plt.legend(bbox_to_anchor=(1.02, 1), loc='upper left', title="Leyenda")
plt.title(f"Mapa V9: {NUM_SOLICITANTES} Solicitantes")
plt.grid(True, alpha=0.3)
plt.tight_layout()
plt.savefig(NOMBRE_IMAGEN, dpi=100)
print(f">> ¡HECHO! Generado {NOMBRE_ARCHIVO_CLP} compatible con Ontologia V9")