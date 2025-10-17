package IA.PracticaGasolina;

import aima.search.framework.HeuristicFunction;

/**
 * Heurística del problema de distribución de gasolina.
 * Queremos maximizar el beneficio total (beneficio - coste),
 * por tanto devolvemos su negativo (AIMA minimiza la heurística).
 */

public class GasolinaHeuristicFunction implements HeuristicFunction {

    @Override
    public double getHeuristicValue(Object state) {
        GasolinaBoard board = (GasolinaBoard) state;
        return -board.getBeneficioTotal();
    }
}
