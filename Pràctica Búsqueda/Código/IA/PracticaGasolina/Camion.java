package IA.PracticaGasolina;

import java.util.*;

public class Camion {
    public int ID;
    public ArrayList<PairInt> trips;

    public Camion(int CID){
        this.ID = CID;
        this.trips = new ArrayList<>();
        for (int i = 0; i < GasolinaBoard.MAX_VIAJES; i++){
            this.trips.add(new PairInt(-1, -1));
        }
    }
}
