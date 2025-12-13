import random
import sys

# --- CONFIGURACIÓN ---
NOMBRE_ARCHIVO_CLP = "new_instanciesv3.clp"
NOMBRE_IMAGEN = "ciutat_v3.png"
NUM_VIVIENDAS = 100
NUM_SERVICIOS = 40
NUM_SOLICITANTES = 0
CIUDAD_SIZE = 5000

print(f"--- GENERADOR DE INSTANCIAS (COMPATIBLE ONTOLOGIA V3) ---")

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

# 1. GENERAR VIVIENDAS (Amb totes les subclasses de la V3)
print("Generando viviendas detalladas...")

# Llista de classes vàlides a la teva ontologia
tipos_posibles = ["Piso", "Unifamiliar", "Dúplex", "Estudio", "Atico", "Bajo", "Intermedio"]
certificados = ["A", "B", "C", "D", "E", "F", "G"]
accesos = ["COTA_CERO", "RAMPA", "ESCALONES"]

for i in range(NUM_VIVIENDAS):
    x, y, zona = get_coords_in_barrio()
    
    # Decisió lògica del tipus segons zona
    if zona == "Lujo":
        tipo = random.choice(["Unifamiliar", "Atico", "Dúplex"])
    elif zona == "Universitario":
        tipo = random.choice(["Piso", "Estudio", "Bajo"])
    else:
        tipo = random.choice(tipos_posibles)
    
    # Preu base
    precio = random.randint(400, 1200) # Base barata
    if zona == "Centro": precio += 500
    if zona == "Lujo": precio += 1500
    if tipo == "Estudio": precio -= 200
    
    # Superficie i Habitacions
    superficie = random.randint(40, 250)
    hd = random.randint(1, 3)
    hi = random.randint(0, 2)
    if tipo == "Estudio":
        hd = 0; hi = 0; superficie = 30
    
    # Propietats específiques segons subclasse
    altura = random.randint(1, 8)
    jardin = 0.0
    rejas = "NO"
    terraza = "NO"
    
    if tipo == "Bajo":
        altura = 0
        rejas = random.choice(["SI", "NO"])
    elif tipo == "Atico":
        altura = random.randint(6, 10)
        terraza = "SI"
    elif tipo == "Unifamiliar":
        altura = 0
        jardin = random.randint(20, 500)
        terraza = "SI" # Solen tenir
        
    # Ascensor lògic
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
        "rejas": rejas,
        "jardin": jardin,
        "cert": random.choice(certificados), 
        "acc": random.choice(accesos),
        "amueblado": random.choice(["SI", "NO"]),
        "calefaccion": random.choice(["SI", "NO"]),
        "aire": random.choice(["SI", "NO"]),
        "mascotas": random.choice(["SI", "NO"]),
        "soleado": random.choice(['"Todo el dia"', '"Manana"', '"Tarde"', '"Nada"'])
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

# 3. GENERAR SOLICITANTES (Correctament adaptats a V3)
print("Generando solicitantes...")
clases_sol = ["Familia", "Estudiantes", "Pareja", "Individuo", "CoLiving"]

for i in range(NUM_SOLICITANTES):
    casa_target = random.choice(viviendas)
    
    # Regla financera inversa: Ingressos han de ser aprox 3.5x el lloguer
    presupuesto_obj = casa_target['precio']
    ingresos = int(presupuesto_obj * random.uniform(3.0, 4.0))
    
    clase = random.choice(clases_sol)
    num_personas = 1
    extra_slots = ""
    
    if clase == "Familia":
        num_personas = random.randint(3, 5)
        extra_slots = "(num_hijos 2) (nombre_colegio_asignado \"\")"
    elif clase == "Estudiantes":
        num_personas = random.randint(2, 4)
        extra_slots = "(necesita_fiesta SI)"
    elif clase == "Pareja":
        num_personas = 2
        extra_slots = "(plan_familia_corto_plazo NO)"
    elif clase == "CoLiving":
        num_personas = random.randint(3, 6)
        extra_slots = "(bano_privado NO) (habitaciones_individuales SI)"
        
    tx, ty, _ = get_coords_in_barrio()

    sol = {
        "id": f"GEN_SOL_{i+1:02d}", 
        "clase": clase,
        "trabajo_x": tx, "trabajo_y": ty, 
        "ingresos": ingresos,
        "presupuesto": presupuesto_obj,
        "num_personas": num_personas,
        "extra": extra_slots,
        "busca": casa_target['tipo'] # Busca el tipus de la casa target
    }
    solicitantes.append(sol)

# 4. ESCRIBIR CLIPS (Amb estructura correcta per a Ontologia V3)
print(f"Escribiendo {NOMBRE_ARCHIVO_CLP}...")
with open(NOMBRE_ARCHIVO_CLP, "w", encoding="utf-8") as f:
    f.write(f";;; INSTANCIAS GENERADAS AUTOMATICAMENTE (V3 FULL)\n\n(definstances instances-generadas\n")
    
    # Escriptura de Viviendas (gestionant subclasses)
    for v in viviendas:
        # Slots comuns a Vivienda (pare)
        common_slots = f"""
        (coordx {v['x']}) (coordy {v['y']}) 
        (precio_mensual {v['precio']}) (superficie {v['superficie']}) 
        (num_habs_dobles {v['hd']}) (num_habs_individual {v['hi']}) (num_banos {v['banos']})
        (es_soleado {v['soleado']}) (tiene_ascensor {v['ascensor']}) (tiene_terraza {v['terraza']}) 
        (amueblado {v['amueblado']}) (tiene_calefaccion {v['calefaccion']}) (tiene_aire_acondicionado {v['aire']}) 
        (permite_mascotas {v['mascotas']}) (altura_piso {v['altura']})
        (certificado_energetico {v['cert']}) (acceso_portal {v['acc']})"""
        
        # Slots específics segons subclasse
        specific_slots = ""
        if v['tipo'] == "Unifamiliar":
            specific_slots = f"(tamano_jardin {v['jardin']})"
        elif v['tipo'] == "Bajo":
            specific_slots = f"(tiene_rejas {v['rejas']}) (gastos_comunidad 50.0)"
        elif v['tipo'] in ["Piso", "Dúplex", "Atico", "Estudio", "Intermedio"]:
            specific_slots = "(gastos_comunidad 50.0)" # Tots els Bloque tenen això

        f.write(f"    ([{v['id']}] of {v['tipo']} {common_slots} {specific_slots})\n")

    # Escriptura de Servicios
    for s in servicios:
        f.write(f"""    ([{s['id']}] of {s['tipo']} (nombre_servicio "{s['nombre']}") (servicio_en_x {s['x']}) (servicio_en_y {s['y']}))\n""")

    # Escriptura de Solicitantes (Sense camps prohibits)
    for sol in solicitantes:
        f.write(f"""    ([{sol['id']}] of {sol['clase']} 
        (nombre_usuario "{sol['id']}")
        (trabaja_en_x {sol['trabajo_x']}) (trabaja_en_y {sol['trabajo_y']}) 
        (ingresos_mensuales {sol['ingresos']}) 
        (presupuesto_esperado {sol['presupuesto']})
        (busca_vivienda {sol['busca']}) 
        (num_personas {sol['num_personas']}) 
        (dias_para_mudanza {random.randint(10, 60)})
        (tiene_coche FALSE) (tiene_mascota FALSE) (teletrabajo FALSE) 
        (movilidad_reducida FALSE) (edad_mas_anciano 40) (prefiere_cerca Supermercado) 
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
plt.title(f"Mapa V3: {NUM_SOLICITANTES} Solicitantes")
plt.grid(True, alpha=0.3)
plt.tight_layout()
plt.savefig(NOMBRE_IMAGEN, dpi=100)
print(f">> ¡HECHO! Generado {NOMBRE_ARCHIVO_CLP} compatible con Ontologia V3")