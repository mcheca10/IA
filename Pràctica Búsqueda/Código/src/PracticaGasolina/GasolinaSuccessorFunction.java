package IA.PracticaGasolina;

import aima.search.framework.*;
import java.util.*;

/**
 * Genera todos los sucesores válidos posibles desde el estado actual.
 * Usado en Hill Climbing.
 */
public class GasolinaSuccessorFunction implements SuccessorFunction {

    @Override
    public List getSuccessors(Object aState) {
        ArrayList<Successor> successors = new ArrayList<>();
        GasolinaBoard board = (GasolinaBoard) aState;

        int nPeticiones = board.getPeticiones().size();
        int nCamiones = board.getViajes().size();
        Random rnd = new Random();

        // --- 1o Intercambiar dos peticiones ---
        for (int i = 0; i < nPeticiones; i++) {
            Peticion p1 = board.getPeticiones().get(i);
            if (p1.idCamion == -1) continue;

            for (int j = i + 1; j < nPeticiones; j++) {
                Peticion p2 = board.getPeticiones().get(j);
                if (p2.idCamion == -1 || p1.idCamion == p2.idCamion) continue;

                GasolinaBoard nuevo = new GasolinaBoard(board);
                boolean ok = nuevo.intercambiarPeticion(i, j, p1.idCamion, p2.idCamion);
                if (ok) {
                    String accion = String.format("Intercambiar petición %d ↔ %d", i, j);
                    successors.add(new Successor(accion, nuevo));
                }
            }
        }

        // --- 2o Añadir una petición no asignada ---
        for (int idNoAsig = 0; idNoAsig < nPeticiones; idNoAsig++) {
            Peticion pNo = board.getPeticiones().get(idNoAsig);
            if (pNo.idCamion != -1) continue;

            for (int idAsig = 0; idAsig < nPeticiones; idAsig++) {
                Peticion pAsig = board.getPeticiones().get(idAsig);
                if (pAsig.idCamion == -1) continue;

                GasolinaBoard nuevo = new GasolinaBoard(board);
                boolean ok = nuevo.añadirPeticion(idNoAsig, idAsig, pAsig.idCamion);
                if (ok) {
                    String accion = String.format("Reemplazar petición %d por %d en camión %d", idAsig, idNoAsig, pAsig.idCamion);
                    successors.add(new Successor(accion, nuevo));
                }
            }
        }
        return successors;
    }
}
