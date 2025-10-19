package PracticaBusqueda.Codigo.src;

import aima.search.framework.*;
import aima.search.informed.*;
import java.util.*;

public class GasolinaDemo {

    public static void main(String[] args) throws Exception {
        // ----------- LECTURA DE PARÁMETROS -----------
        Scanner sc = new Scanner(System.in);
        System.out.print("Número de gasolineras: ");
        int nGas = sc.nextInt();
        System.out.print("Número de centros: ");
        int nCent = sc.nextInt();
        System.out.print("Multiplicador: ");
        int mult = sc.nextInt();
        System.out.print("Seed: ");
        int seed = sc.nextInt();
        System.out.println("Introduce que método quieres utilizar para generar el estado inicial:");
        System.out.println("1: Aleatorio, se asigna cualquier peticion a cualquier camión.");
        System.out.println("2: Asigna las peticiones más cercanas al camión, minimizando las distancias a recorrer.");
        System.out.println("3: Greedy, se utiliza un algoritmo que prioriza aquellas peticiones con mínimo coste general.");
        int method = sc.nextInt();
        sc.close();

        GasolinaBoard initial = new GasolinaBoard(nGas, nCent, mult, seed, method);
        HeuristicFunction hf = new GasolinaHeuristicFunction();

        // ----------- HILL CLIMBING -----------
        System.out.println("\n=== HILL CLIMBING ===");
        Problem p1 = new Problem(initial, new GasolinaSuccessorFunction(), new GasolinaGoalTest(), hf);

        long t1 = System.currentTimeMillis();
        Search search1 = new HillClimbingSearch();
        SearchAgent agent1 = new SearchAgent(p1, search1);
        long t2 = System.currentTimeMillis();

        GasolinaBoard result1 = (GasolinaBoard) search1.getGoalState();

        printActions(agent1.getActions());
        printInstrumentation(agent1.getInstrumentation());

        System.out.printf("Beneficio total: %.2f\n", result1.getBeneficioTotal());
        System.out.printf("Valor peticiones no asignadas: %.2f\n", result1.getValorPeticionesNoAsignadas());
        System.out.println("Tiempo total: " + (t2 - t1) + " ms");


        // ----------- SIMULATED ANNEALING -----------
        System.out.println();
        System.out.println("=== SIMULATED ANNEALING ===");
        Problem p2 = new Problem(initial, new GasolinaSuccessorFunctionSA(), new GasolinaGoalTest(), hf);

        t1 = System.currentTimeMillis();
        // parámetros: steps, stiter, k, lambda
        Search search2 = new SimulatedAnnealingSearch(20000, 100, 10, 0.001);
        SearchAgent agent2 = new SearchAgent(p2, search2);
        t2 = System.currentTimeMillis();

        GasolinaBoard result2 = (GasolinaBoard) search2.getGoalState();

        printActions(agent2.getActions());
        printInstrumentation(agent2.getInstrumentation());

        System.out.printf("Beneficio total: %.2f", result2.getBeneficioTotal());
        System.out.println();
        System.out.printf("Valor peticiones no asignadas: %.2f", result2.getValorPeticionesNoAsignadas());
        System.out.println();
        System.out.println("Tiempo total: " + (t2 - t1) + " ms");
    }

    // -------------------- MÉTODOS AUXILIARES --------------------

    private static void printActions(List actions) {
        System.out.println("\n--- Acciones realizadas ---");
        if (actions == null || actions.isEmpty()) {
            System.out.println("No se realizaron movimientos (estado óptimo o estancado).");
            return;
        }

        for (Object action : actions) {
            System.out.println(action.toString());
        }
        System.out.println();
    }

    private static void printInstrumentation(Properties props) {
        System.out.println("--- Instrumentación ---");
        for (Object key : props.keySet()) {
            System.out.println(key + " : " + props.getProperty((String) key));
        }
        System.out.println();
    }
}
