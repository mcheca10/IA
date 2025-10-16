package IA.PracticaGasolina;

import aima.search.framework.*;
import java.util.*;

/**
 * Genera todos los sucesores válidos de un estado
 * aplicando el operador moverPeticion().
 * Usado en Hill Climbing.
 */
public class GasolinaSuccessorFunction implements SuccessorFunction {

    @Override
    public List getSuccessors(Object aState) {
        List<Successor> retVal = new ArrayList<>();
        GasolinaBoard board = (GasolinaBoard) aState;

        int nPeticiones = board.getPeticiones().size();
        int nCamiones = GasolinaBoard.getCentros().size();

        // Para cada petición, probar moverla a otro camión/viaje
        for (int idPet = 0; idPet < nPeticiones; idPet++) {
            int actualCamion = board.getCamionDePeticion(idPet);

            for (int nuevoCamion = 0; nuevoCamion < nCamiones; nuevoCamion++) {
                if (nuevoCamion == actualCamion) continue;

                // Intentar mover a cada viaje existente + uno nuevo si <5
                int viajesDisponibles = board.getViajes().get(nuevoCamion).size();
                int maxViajes = Math.min(viajesDisponibles + 1, 5);

                for (int v = 0; v < maxViajes; v++) {
                    GasolinaBoard nuevo = new GasolinaBoard(board);
                    boolean ok = nuevo.moverPeticion(idPet, nuevoCamion, v);
                    if (ok) {
                        String accion = String.format(
                            "Mover petición %d de camión %d→%d (viaje %d)",
                            idPet, actualCamion, nuevoCamion, v
                        );
                        retVal.add(new Successor(accion, nuevo));
                    }
                }
            }
        }

        return retVal;
    }
}
