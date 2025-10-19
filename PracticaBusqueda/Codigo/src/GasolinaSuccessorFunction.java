package PracticaBusqueda.Codigo.src;

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

        /* 
        // --- 1o Intercambiar dos peticiones ---
        for (int i = 0; i < nPeticiones; i++) {
            Peticion p1 = board.getPeticiones().get(i);
            if (p1.idCamion == -1) continue;

            for (int j = i + 1; j < nPeticiones; j++) {
                Peticion p2 = board.getPeticiones().get(j);
                if (p2.idCamion == -1) continue;

                GasolinaBoard nuevo = new GasolinaBoard(board);
                boolean ok = nuevo.intercambiarPeticion(i, j, p1.idCamion, p2.idCamion);
                if (ok) {
                    String accion = String.format("Intercambiar petición %d ↔ %d", i, j);
                    successors.add(new Successor(accion, nuevo));
                }
            }
        }
        */
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

        // --- 3o Intercambiar viajes completos entre camiones (SwapTrip) ---
        for (int ca = 0; ca < nCamiones; ca++) {
            ArrayList<Camion> cams = board.getViajes();
            int tripsA = cams.get(ca).trips.size(); // = 5 en tu modelo
            for (int ta = 0; ta < tripsA; ta++) {
                PairInt va = cams.get(ca).trips.get(ta);
                // si el viaje A está vacío, no aporta nada
                if (va.first == -1 && va.second == -1) continue;

                for (int cb = ca + 1; cb < nCamiones; cb++) { // evita duplicados simétricos
                    int tripsB = cams.get(cb).trips.size();  // = 5
                    for (int tb = 0; tb < tripsB; tb++) {
                        PairInt vb = cams.get(cb).trips.get(tb);
                        if (vb.first == -1 && vb.second == -1) continue;

                        GasolinaBoard nuevo = new GasolinaBoard(board);
                        boolean ok = nuevo.swapTrips(ca, ta, cb, tb);
                        if (ok) {
                            String accion = String.format(
                                "Intercambiar viaje (cam %d, trip %d) ↔ (cam %d, trip %d)",
                                ca, ta, cb, tb
                            );
                            successors.add(new Successor(accion, nuevo));
                        }
                    }
                }
            }
        }
            
        return successors;
    }
}
