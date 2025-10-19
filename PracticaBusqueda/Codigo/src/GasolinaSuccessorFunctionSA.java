package PracticaBusqueda.Codigo.src;

import aima.search.framework.*;
import java.util.*;

/**
 * Genera un único sucesor aleatorio válido.
 * Usado en Simulated Annealing.
 */
public class GasolinaSuccessorFunctionSA implements SuccessorFunction {

    @Override
    public List getSuccessors(Object aState) {
        ArrayList<Successor> successors = new ArrayList<>();
        GasolinaBoard board = (GasolinaBoard) aState;

        int nPeticiones = board.getPeticiones().size();
        int nCamiones = board.getViajes().size();
        Random rnd = new Random();

        for (int intentos = 0; intentos < 50; intentos++) {
            int tipo = rnd.nextInt(2); // 0: intercambiar, 1: añadir

            GasolinaBoard nuevo = new GasolinaBoard(board);
            boolean ok = false;
            String accion = "";

            if (tipo == 0) {
                int p1 = rnd.nextInt(nPeticiones);
                int p2 = rnd.nextInt(nPeticiones);
                if (p1 != p2) {
                    Peticion pet1 = board.getPeticiones().get(p1);
                    Peticion pet2 = board.getPeticiones().get(p2);
                    if (pet1.idCamion != -1 && pet2.idCamion != -1 && pet1.idCamion != pet2.idCamion) {
                        ok = nuevo.intercambiarPeticion(p1, p2, pet1.idCamion, pet2.idCamion);
                        accion = "Intercambiar aleatorio";
                    }
                }
            }
            else {
                int pNo = rnd.nextInt(nPeticiones);
                int pAsig = rnd.nextInt(nPeticiones);
                if (pNo != pAsig) {
                    Peticion pn = board.getPeticiones().get(pNo);
                    Peticion pa = board.getPeticiones().get(pAsig);
                    if (pn.idCamion == -1 && pa.idCamion != -1) {
                        ok = nuevo.añadirPeticion(pNo, pAsig, pa.idCamion);
                        accion = "Añadir aleatorio";
                    }
                }
            }

            if (ok) {
                successors.add(new Successor(accion, nuevo));
                break;
            }
        }

        return successors;
    }
}
