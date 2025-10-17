package IA.PracticaGasolina;

import IA.Gasolina.*;
import java.util.*;

/**
 * Representa un estado del problema de distribución de gasolina.
 */
public class GasolinaBoard {

    // -------------------- CONSTANTES --------------------
    public static final double COSTE_KM = 2.0;
    public static final double MAX_DISTANCIA = 640.0; // km por día
    public static final double VALOR_DEPOSITO = 1000.0;
    public static final int MAX_VIAJES = 5;
    public static final int MAX_PETICIONES_POR_VIAJE = 2;

    // -------------------- ATRIBUTOS --------------------
    private static Gasolineras gasolineras;
    private static CentrosDistribucion centros;

    private ArrayList<Peticion> peticiones;                     // Todas las peticiones
    private ArrayList<Camion> camiones;    // camiones[camion][viaje] = lista de idPeticiones

    // -------------------- CONSTRUCTOR PRINCIPAL --------------------
    public GasolinaBoard(int nGasolineras, int nCentros, int mult, int seed, int method) {
        centros = new CentrosDistribucion(nCentros, mult, seed);
        gasolineras = new Gasolineras(nGasolineras, seed);
        peticiones = new ArrayList<>();
        camiones = new ArrayList<>();

        // Crear estructura de peticiones
        for (int idGas = 0; idGas < gasolineras.size(); idGas++) {
            Gasolinera g = gasolineras.get(idGas);
            for (int dias : g.getPeticiones()) {
                peticiones.add(new Peticion(idGas,-1, dias));
            }
        }

        // Crear estructura de camiones

        int nCamiones = centros.size();
        for (int c = 0; c < nCamiones; c++) {
            camiones.addLast(new Camion(c)); // Se añade el camión con la lista de camiones vacia.
        }
        // Segun el input creara el estado inicial de una manera u otra.
        if (method == 1) asignaPeticionesRandom();
        else if (method == 2) asignaPeticionesMinimaDistancia();
        else asignaPeticionesGreedy();
        
    }

    // -------------------- CONSTRUCTOR DE COPIA --------------------

    public GasolinaBoard(GasolinaBoard other) {
        this.peticiones = other.peticiones; // Peticiones se comparten (si son inmutables)
        this.camiones = new ArrayList<>();
        for (Camion c : other.camiones) {
            Camion copiaC = new Camion(c.ID);
            // copiar trips
            for (int i = 0; i < c.trips.size(); i++) {
                PairInt p = c.trips.get(i);
                copiaC.trips.set(i, new PairInt(p.first, p.second));
            }
            this.camiones.add(copiaC);
        }
    }

    // -------------------- MÉTODO AUXILIAR: ASIGNACIÓN INICIAL --------------------

    /** ESTRATEGIA 1: Aleatoria
     * Petición por petición, va asignando al primer camión que esté libre
     * En caso que todos los camiones estén completos, las deja como pendientes
     */
    private void asignaPeticionesRandom() {
        int nCamiones = camiones.size();

        for (int idPet = 0; idPet < peticiones.size(); idPet++) {
            Peticion p = peticiones.get(idPet);
            boolean asignada = false;

            for (int c = 0; c < nCamiones && !asignada; c++) {
                Camion cam = camiones.get(c);
                for (int v = 0; v < cam.trips.size() && !asignada; v++) {
                    PairInt trip = cam.trips.get(v);

                    if (trip.first != -1 && trip.second != -1) continue;
                    // se añade el viaje primero y luego se prueba que se cumplen  las caracteristicas
                    if (trip.first == -1) trip.first = idPet;
                    else trip.second = idPet;
                    // calculo distancia
                    if (getDistanciaPorCamion(c) <= MAX_DISTANCIA) {
                        p.idCamion = c;
                        asignada = true;
                    } else { // la distancia total excede del maximo
                        if (trip.second == idPet) trip.second = -1;
                        else trip.first = -1;
                    }
                }
            }

            // Si no se pudo asignar, queda sin camión
            if (!asignada) p.idCamion = -1;
        }
    }

/** ESTRATEGIA 2:
 * Asigna las peticiones al camión más cercano (mínima distancia al centro).
 * Para cada petición, buscar el camión más cercano y asignarla
 * al primer hueco disponible (máx 2 por viaje, 5 viajes por camión)
 * sin superar la distancia máxima total (640 km).
 */
private void asignaPeticionesMinimaDistancia() {
    int nCamiones = camiones.size();

    for (int idPet = 0; idPet < peticiones.size(); idPet++) {
        Peticion p = peticiones.get(idPet);
        Gasolinera g = gasolineras.get(p.idGasolinera);

        // 1 Buscar el centro (camión) más cercano
        double minDist = Double.MAX_VALUE;
        int mejorCamion = -1;
        for (int idCam = 0; idCam < nCamiones; idCam++) {
            Distribucion centro = centros.get(idCam);
            double d = distancia(g.getCoordX(), g.getCoordY(), centro.getCoordX(), centro.getCoordY());
            if (d < minDist) {
                minDist = d;
                mejorCamion = idCam;
            }
        }

        // 2 Intentar asignarla al camión más cercano (en el primer hueco libre)
        Camion cam = camiones.get(mejorCamion);
        boolean asignada = false;

        for (int v = 0; v < MAX_VIAJES && !asignada; v++) {
            PairInt trip = cam.trips.get(v);

            // Saltar viajes llenos
            if (trip.first != -1 && trip.second != -1) continue;

            // Asignar temporalmente
            if (trip.first == -1) trip.first = idPet;
            else trip.second = idPet;

            // Comprobar restricción de distancia
            if (getDistanciaPorCamion(mejorCamion) <= MAX_DISTANCIA) {
                p.idCamion = mejorCamion;
                asignada = true;
            } else {
                // Revertir si se excede
                if (trip.second == idPet) trip.second = -1;
                else trip.first = -1;
            }
        }

        // 3 Si no cabe en su camión ideal, intentar con otros
        if (!asignada) {
            for (int idCam = 0; idCam < nCamiones && !asignada; idCam++) {
                Camion alt = camiones.get(idCam);
                for (int v = 0; v < MAX_VIAJES && !asignada; v++) {
                    PairInt trip = alt.trips.get(v);
                    if (trip.first != -1 && trip.second != -1) continue;

                    if (trip.first == -1) trip.first = idPet;
                    else trip.second = idPet;

                    if (getDistanciaPorCamion(idCam) <= MAX_DISTANCIA) {
                        p.idCamion = idCam;
                        asignada = true;
                    } else {
                        if (trip.second == idPet) trip.second = -1;
                        else trip.first = -1;
                    }
                }
            }
        }

        // 4 Si no se pudo asignar a ningún camión, queda pendiente
        if (!asignada) p.idCamion = -1;
    }
}


    /**
     * Algoritmo Greedy:
     * Ordena las peticiones por urgencia (días DESCENDENTE).
     * Para cada petición, busca la mejor asignación (menor coste marginal) a cualquier hueco de cualquier camión.
     * Aplica la asignación si no excede la distancia máxima del camión.
     * Esta estrategia prioriza reducir las pérdidas totales de  la empresa priorizando las peticiones que llevan más dias sin hacerse.
     */
    private void asignaPeticionesGreedy() {

        // Crear una lista de peticiones y ordenarla por urgencia (dias, de mayor a menor)
        List<Peticion> peticionesOrdenadas = new ArrayList<>(this.peticiones);
        Collections.sort(peticionesOrdenadas, (p1, p2) -> Integer.compare(p2.dias, p1.dias));

        // Iterar sobre las peticiones ordenadas
        for (int idPet = 0; idPet < peticionesOrdenadas.size(); idPet++) {
            
            Peticion p = peticionesOrdenadas.get(idPet);
            int p_ID = peticiones.indexOf(p); // Obtener el ID original de la peticion en el ArrayList peticiones

            double menorCosteMarginal = Double.MAX_VALUE;
            int mejorCamion = -1;
            int mejorViaje = -1;
            int mejorPos = -1; 

            // Buscar la mejor asignación
            for (int idCam = 0; idCam < camiones.size(); idCam++) {
                Camion cam = camiones.get(idCam);

                for (int idViaje = 0; idViaje < MAX_VIAJES; idViaje++) {
                    PairInt trip = cam.trips.get(idViaje);
                    
                    // Evaluar el hueco 'first'
                    if (trip.first == -1) {
                        double coste = calcularCosteMarginal(idCam, idViaje, p_ID, 0);

                        if (coste < menorCosteMarginal) {
                            // Comprobar la restricción de distancia total *antes* de aceptar
                            double distActual = getDistanciaPorCamion(idCam);
                            if (distActual + coste <= MAX_DISTANCIA) {
                                menorCosteMarginal = coste;
                                mejorCamion = idCam;
                                mejorViaje = idViaje;
                                mejorPos = 0;
                            }
                        }
                    }

                    // Evaluar el hueco 'second'
                    if (trip.second == -1) {
                        double coste = calcularCosteMarginal(idCam, idViaje, p_ID, 1);

                        if (coste < menorCosteMarginal) {
                            // Comprobar la restricción de distancia total *antes* de aceptar
                            double distActual = getDistanciaPorCamion(idCam);
                            if (distActual + coste <= MAX_DISTANCIA) {
                                menorCosteMarginal = coste;
                                mejorCamion = idCam;
                                mejorViaje = idViaje;
                                mejorPos = 1;
                            }
                        }
                    }
                }
            }
            
            // Aplicar la mejor asignación encontrada
            if (mejorCamion != -1) {
                Camion camOptimo = camiones.get(mejorCamion);
                PairInt tripOptimo = camOptimo.trips.get(mejorViaje);

                if (mejorPos == 0) tripOptimo.first = p_ID;
                else tripOptimo.second = p_ID;

                p.setIDCam(mejorCamion);
            } else {
                // Si no se pudo asignar de forma válida, la petición queda con idCamion = -1 (pendiente)
                p.setIDCam(-1); 
            }
        }
    }

    // -------------------- OPERADORES --------------------

    // intercambiar de camion (de c1 a c2)
    
    public boolean intercambiarPeticion(int idPet1, int idPet2, int C1, int C2) {
        if (C1 == C2) return false;
        if (C1 < 0 || C2 < 0 || C1 >= camiones.size() || C2 >= camiones.size()) return false;

        Peticion p1 = peticiones.get(idPet1);
        Peticion p2 = peticiones.get(idPet2);

        Camion cam1 = camiones.get(C1);
        Camion cam2 = camiones.get(C2);

        // Buscar sus posiciones dentro de los camiones
        int viaje1 = -1, viaje2 = -1, pos1 = -1, pos2 = -1;

        for (int v = 0; v < cam1.trips.size(); v++) {
            if (cam1.trips.get(v).first == idPet1) { viaje1 = v; pos1 = 0; break; }
            if (cam1.trips.get(v).second == idPet1) { viaje1 = v; pos1 = 1; break; }
        }

        for (int v = 0; v < cam2.trips.size(); v++) {
            if (cam2.trips.get(v).first == idPet2) { viaje2 = v; pos2 = 0; break; }
            if (cam2.trips.get(v).second == idPet2) { viaje2 = v; pos2 = 1; break; }
        }

        if (viaje1 == -1 || viaje2 == -1) return false;

        if (pos1 == 0) cam1.trips.get(viaje1).first = idPet2;
        else cam1.trips.get(viaje1).second = idPet2;

        if (pos2 == 0) cam2.trips.get(viaje2).first = idPet1;
        else cam2.trips.get(viaje2).second = idPet1;

        // deshacer  cambios
        if (getDistanciaPorCamion(C1) > MAX_DISTANCIA || getDistanciaPorCamion(C2) > MAX_DISTANCIA) {
            if (pos1 == 0) cam1.trips.get(viaje1).first = idPet1;
            else cam1.trips.get(viaje1).second = idPet1;
            if (pos2 == 0) cam2.trips.get(viaje2).first = idPet2;
            else cam2.trips.get(viaje2).second = idPet2;
            return false;
    }

    // Actualizar asignaciones
    p1.idCamion = C2;
    p2.idCamion = C1;

    return true;
}

    // asignar peticion sin asignar a un camion (posibilidad de hacer intercambio y que camion 2 tenga id -1)
    public boolean añadirPeticion(int idNoAsignada, int idAsignada, int C) {
        if (C < 0 || C >= camiones.size()) return false;

        Peticion pNueva = peticiones.get(idNoAsignada);
        Peticion pVieja = peticiones.get(idAsignada);

        if (pVieja.idCamion != C) return false;
        if (pNueva.idCamion != -1) return false; // ya asignada

        Camion cam = camiones.get(C);
        int viaje = -1, pos = -1;

        for (int v = 0; v < cam.trips.size(); v++) {
            PairInt trip = cam.trips.get(v);
            if (trip.first == idAsignada) { viaje = v; pos = 0; break; }
            if (trip.second == idAsignada) { viaje = v; pos = 1; break; }
        }

        if (viaje == -1) return false;

        // Sustituir temporalmente
        if (pos == 0) cam.trips.get(viaje).first = idNoAsignada;
        else cam.trips.get(viaje).second = idNoAsignada;

        // Verificar restricción de distancia
        if (getDistanciaPorCamion(C) > MAX_DISTANCIA) {
            // Revertir
            if (pos == 0) cam.trips.get(viaje).first = idAsignada;
            else cam.trips.get(viaje).second = idAsignada;
            return false;
        }

        // Actualizar estado
        pNueva.idCamion = C;
        pVieja.idCamion = -1;

        return true;
    }


// -------------------- FUNCIONES AUXILIARES --------------------


    // -------------------- CÁLCULOS DE COSTES Y BENEFICIOS --------------------

    // Cálculo del beneficio - Coste de los camiones que se realizarán
    public double getBeneficioTotal() {
        double total = 0.0;

        for (Camion c : camiones) {
            for (int i = 0; i < c.trips.size(); i++) {
                PairInt viaje = c.trips.get(i);
                double dist = calcularDistanciaViaje(c.ID, i);

                double beneficioViaje = 0.0;

                if (viaje.first != -1) {
                    Peticion p1 = peticiones.get(viaje.first);
                    double valor1 = VALOR_DEPOSITO * (1.02 - 0.02 * p1.dias);
                    beneficioViaje += valor1;
                }

                if (viaje.second != -1) {
                    Peticion p2 = peticiones.get(viaje.second);
                    double valor2 = VALOR_DEPOSITO * (1.02 - 0.02 * p2.dias);
                    beneficioViaje += valor2;
                }
                beneficioViaje -= COSTE_KM * dist;
                total += beneficioViaje;
            }
        }
        return total;
    }

    // Cálculo del valor de las peticiones que no se asignarán
    public double getValorPeticionesNoAsignadas() {
        double totalPerdido = 0.0;

        for (Peticion p : peticiones) {
            if (p.idCamion == -1) {
                double valor = VALOR_DEPOSITO * (1.02 - 0.02 * p.dias);
                totalPerdido += valor;
            }
        }

        return totalPerdido;
    }

    // Funcion para calcular los beneficios de un viaje nuevo

    private double calcularCosteMarginal(int idCamion, int idViaje, int idPet, int pos) {
        
        Camion cam = camiones.get(idCamion);
        PairInt trip = cam.trips.get(idViaje);

        // Calcular Distancia original
        double distOriginal = getDistanciaPorCamion(idCamion);

        // Almacenar estado original del hueco y hacer la asignación TEMPORAL
        int originalValue = (pos == 0) ? trip.first : trip.second;
        
        if (pos == 0) trip.first = idPet;
        else trip.second = idPet;

        // Calcular Distancia nueva
        double distNueva = getDistanciaPorCamion(idCamion);

        // Revertir el estado original del hueco
        if (pos == 0) trip.first = originalValue;
        else trip.second = originalValue;

        // El coste marginal es la diferencia
        return distNueva - distOriginal;
    }

    // -------------------- CÁLCULO DE DISTANCIAS --------------------


    private double calcularDistanciaViaje(int idCamion, int idViaje) {
        Distribucion centro = centros.get(idCamion);
        double cx = centro.getCoordX();
        double cy = centro.getCoordY();

        PairInt v = camiones.get(idCamion).trips.get(idViaje);
        double dist = 0.0;

        if (v.first != -1) {
            Gasolinera g = gasolineras.get(peticiones.get(v.first).idGasolinera);
            dist += distancia(cx, cy, g.getCoordX(), g.getCoordY()) * 2;
        }
        if (v.second != -1) {
            Gasolinera g = gasolineras.get(peticiones.get(v.second).idGasolinera);
            dist += distancia(cx, cy, g.getCoordX(), g.getCoordY()) * 2;
        }

        return dist;
    }

    // Calcula para idCamion cual es la distancia total que  recorre
    public double getDistanciaPorCamion(int idCamion) {
        if (idCamion < 0 || idCamion >= camiones.size()) return 0.0;
        double total = 0.0;
        Camion c = camiones.get(idCamion);
        for (int v = 0; v < c.trips.size(); v++) {
            total += calcularDistanciaViaje(idCamion, v);
        }
        return total;
    }

    private double distancia(double x1, double y1, double x2, double y2) {
        double dx = x1 - x2;
        double dy = y1 - y2;
        return Math.sqrt(dx * dx + dy * dy);
    }

    // -------------------- EXTRA --------------------
    public static CentrosDistribucion getCentros() { return centros; }
    public static Gasolineras getGasolineras() { return gasolineras; }
    public ArrayList<Peticion> getPeticiones() { return peticiones; }
    public ArrayList<Camion> getViajes() { return camiones; }

}
