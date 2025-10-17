package IA.PracticaGasolina;

import IA.Gasolina.*;
import java.util.*;

/**
 * Representa el estado del problema de distribución de gasolina.
 * Cada camión puede hacer hasta 5 viajes de como máximo 640 km.
 */
public class GasolinaBoard {

    // DATOS ESTÁTICOS
    public static Gasolineras gasolineras;
    public static CentrosDistribucion centros;
    private static final double COSTE_KM = 2.0;
    private static final int MAX_VIAJES = 5;
    private static final double MAX_DISTANCIA = 640.0;
    public static final double VALOR_DEPOSITO = 1000.0;

    // ESTADO
    private ArrayList<Peticion> peticiones; // todas las peticiones disponibles
    private int[] asignacion; // vector con cada peticion asignada a cada camión (cada i es el id peticion y el i-esimo elemento es el id del camion)
    ArrayList<ArrayList<ArrayList<Integer>>> viajes; // viajes[camion][viaje] = lista de peticiones

    // CONSTRUCTORES
    public GasolinaBoard(int nCentros, int mult, int nGasolineras, int seed) {
        centros = new CentrosDistribucion(nCentros, mult, seed);
        gasolineras = new Gasolineras(nGasolineras, seed);

        peticiones = new ArrayList<>();
        int idPetGlobal = 0;

        // Crear todas las peticiones a partir de las gasolineras
        for (int i = 0; i < gasolineras.size(); i++) {
            Gasolinera g = gasolineras.get(i);
            for (int dias : g.getPeticiones()) {
                peticiones.add(new Peticion(i, idPetGlobal++, g.getCoordX(), g.getCoordY(), dias));
            }
        }

        int nCamiones = centros.size();
        asignacion = new int[peticiones.size()];

        // Inicializar estructura de viajes
        viajes = new ArrayList<>(nCamiones);
        for (int i = 0; i < nCamiones; i++) {
            viajes.add(new ArrayList<>());
            viajes.get(i).add(new ArrayList<>()); // primer viaje
        }

        // Asignación inicial circular de peticiones
        int idx = 0;
        for (int p = 0; p < peticiones.size(); p++) {
            int camion = idx % nCamiones;
            asignacion[p] = camion;
            viajes.get(camion).get(0).add(p);
            idx++;
        }
    }

    /** Constructor copia */
    public GasolinaBoard(GasolinaBoard other) {
        this.peticiones = other.peticiones; // inmutable, referencias compartidas
        this.asignacion = other.asignacion.clone();
        this.viajes = new ArrayList<>();

        for (ArrayList<ArrayList<Integer>> vCamion : other.viajes) {
            ArrayList<ArrayList<Integer>> copiaCamion = new ArrayList<>();
            for (ArrayList<Integer> viaje : vCamion)
                copiaCamion.add(new ArrayList<>(viaje));
            this.viajes.add(copiaCamion);
        }
    }

    // OPERADORES

    /** Mueve una petición de un camión/viaje a otro, si cumple restricciones. */
    public boolean moverPeticion(int idPet, int nuevoCamion, int nuevoViaje) {
        int actualCamion = asignacion[idPet];
        if (actualCamion == nuevoCamion) return false;

        // Quitar de su viaje actual
        for (ArrayList<Integer> viaje : viajes.get(actualCamion)) {
            if (viaje.remove((Integer) idPet)) break;
        }

        // Crear nuevo viaje si es necesario
        while (viajes.get(nuevoCamion).size() <= nuevoViaje) {
            if (viajes.get(nuevoCamion).size() >= MAX_VIAJES) return false;
            viajes.get(nuevoCamion).add(new ArrayList<>());
        }

        // Añadir al nuevo viaje
        viajes.get(nuevoCamion).get(nuevoViaje).add(idPet);
        asignacion[idPet] = nuevoCamion;

        // Comprobar restricción de distancia
        if (calcularDistanciaViaje(nuevoCamion, nuevoViaje) > MAX_DISTANCIA) {
            // revertir si no cumple
            viajes.get(nuevoCamion).get(nuevoViaje).remove((Integer) idPet);
            viajes.get(actualCamion).get(0).add(idPet);
            asignacion[idPet] = actualCamion;
            return false;
        }

        return true;
    }

    /** Devuelve la distancia total de un viaje (ida + vuelta) */
    private double calcularDistanciaViaje(int camion, int idViaje) {
        Distribucion centro = centros.get(camion);
        int cx = centro.getCoordX(), cy = centro.getCoordY();
        ArrayList<Integer> viaje = viajes.get(camion).get(idViaje);

        if (viaje.isEmpty()) return 0.0;

        double total = 0;
        int xActual = cx, yActual = cy;

        for (int idPet : viaje) {
            Peticion p = peticiones.get(idPet);
            total += Math.abs(p.coordX - xActual) + Math.abs(p.coordY - yActual);
            xActual = p.coordX;
            yActual = p.coordY;
        }

        // vuelta al centro
        total += Math.abs(xActual - cx) + Math.abs(yActual - cy);
        return total;
    }

    // FUNCIÓN DE COSTE/BENEFICIO

    /** Devuelve el beneficio total del estado (beneficio - coste) */
    public double getBeneficioTotal() {
        double beneficio = 0, coste = 0;

        for (int c = 0; c < centros.size(); c++) {
            for (int v = 0; v < viajes.get(c).size(); v++) {
                double dist = calcularDistanciaViaje(c, v);
                coste += dist * COSTE_KM;

                for (int idPet : viajes.get(c).get(v)) {
                    beneficio += peticiones.get(idPet).beneficio;
                }
            }
        }
        return beneficio - coste;
    }

    // AUXILIARES

    public ArrayList<Peticion> getPeticiones() { return peticiones; }
    public int getCamionDePeticion(int idPet) { return asignacion[idPet]; }
    public ArrayList<ArrayList<ArrayList<Integer>>> getViajes() { return viajes; }
    public static CentrosDistribucion getCentros() { return centros; }
    public static Gasolineras getGasolineras() { return gasolineras; }

    @Override
    public String toString() {
        return String.format("Beneficio total: %.2f", getBeneficioTotal());
    }
}
