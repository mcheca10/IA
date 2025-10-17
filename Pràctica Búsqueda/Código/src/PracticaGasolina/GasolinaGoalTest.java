package IA.PracticaGasolina;

import aima.search.framework.GoalTest;

/**
 * En búsqueda local no hay un estado objetivo concreto.
 * El algoritmo decide cuándo parar (por estancamiento o temperatura).
 */
public class GasolinaGoalTest implements GoalTest {
    @Override
    public boolean isGoalState(Object state) {
        return false;
    }
}
