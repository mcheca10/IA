package IA.PracticaGasolina;

import IA.Gasolina.*;
import aima.search.framework.*;
import aima.search.informed.*;
import java.util.*;

public class GasolinaDemo {

    public static void main(String[] args) throws Exception {
        // Parámetros de la instancia
        int nCentros = 5;
        int multiplicidad = 2;
        int nGasolineras = 50;
        int seed = 1234;

        // Crear el estado inicial
        GasolinaBoard estadoInicial = new GasolinaBoard(nCentros, multiplicidad, nGasolineras, seed);

        // -------- HILL CLIMBING --------
        Problem problemHC = new Problem(
                estadoInicial,
                new GasolinaSuccessorFunction(),
                new GasolinaGoalTest(),
                new GasolinaHeuristicFunction()
        );

        Search hill = new HillClimbingSearch();
        SearchAgent agentHC = new SearchAgent(problemHC, hill);

        System.out.println("\n=== HILL CLIMBING ===");
        printActions(agentHC.getActions());
        printInstrumentation(agentHC.getInstrumentation());

        // -------- SIMULATED ANNEALING --------
        int steps = 10000;
        int stiter = 100;
        int k = 5;
        double lambda = 0.001;

        Problem problemSA = new Problem(
                estadoInicial,
                new GasolinaSuccessorFunctionSA(),
                new GasolinaGoalTest(),
                new GasolinaHeuristicFunction()
        );

        Search anneal = new SimulatedAnnealingSearch(steps, stiter, k, lambda);
        SearchAgent agentSA = new SearchAgent(problemSA, anneal);

        System.out.println("\n=== SIMULATED ANNEALING ===");
        printActions(agentSA.getActions());
        printInstrumentation(agentSA.getInstrumentation());
    }

    private static void printInstrumentation(Properties properties) {
        Iterator<?> keys = properties.keySet().iterator();
        while (keys.hasNext()) {
            String key = (String) keys.next();
            String property = properties.getProperty(key);
            System.out.println(key + " : " + property);
        }
    }

    private static void printActions(List<?> actions) {
        for (Object action : actions) {
            System.out.println(action);
        }
    }
}
