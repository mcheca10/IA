package IA.PracticaGasolina;

import aima.search.framework.*;
import java.util.*;

/**
 * Genera un solo sucesor aleatorio válido.
 * Usado en Simulated Annealing.
 */
public class GasolinaSuccessorFunctionSA implements SuccessorFunction {

    @Override
    public List<Successor> getSuccessors(Object aState) {
       List<Successor> retVal = new ArrayList<>();

        GasolinaBoard board = (GasolinaBoard) aState;

        Random rnd = new Random();
        int nPeticiones = board.getPeticiones().size();
        int nCamiones = GasolinaBoard.getCentros().size();

        // Intentar un número limitado de veces para encontrar un movimiento válido
        for (int intentos = 0; intentos < 100; intentos++) {
            int idPet = rnd.nextInt(nPeticiones);
            int actualCamion = board.getCamionDePeticion(idPet);

            int nuevoCamion = rnd.nextInt(nCamiones);
            if (nuevoCamion == actualCamion) continue;

            int viajesDisponibles = board.getViajes().get(nuevoCamion).size();
            int maxViajes = Math.min(viajesDisponibles + 1, 5);
            int nuevoViaje = rnd.nextInt(maxViajes);

            GasolinaBoard nuevo = new GasolinaBoard(board);
            boolean ok = nuevo.moverPeticion(idPet, nuevoCamion, nuevoViaje);
            if (ok) {
                String accion = String.format(
                    "Mover petición %d de camión %d→%d (viaje %d)",
                    idPet, actualCamion, nuevoCamion, nuevoViaje
                );
                retVal.add(new Successor(accion, nuevo));
                break;
            }
        }

        return retVal;
    }
}
