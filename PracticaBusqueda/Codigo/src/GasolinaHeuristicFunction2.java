package PracticaBusqueda.Codigo.src;

import aima.search.framework.HeuristicFunction;

/**
 * Heurística del problema de distribución de gasolina.
 * Queremos maximizar el beneficio por kilometro
 */

public class GasolinaHeuristicFunction2 implements HeuristicFunction {

    @Override
    public double getHeuristicValue(Object state) {
        GasolinaBoard board = (GasolinaBoard) state;

        double beneficio = board.getBeneficioTotal();
        double kilometrostotales = board.getDistTotal();
        return -beneficio/(kilometrostotales+1.0);
    }
}
