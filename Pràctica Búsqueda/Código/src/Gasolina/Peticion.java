package IA.PracticaGasolina;

public class Peticion {
    public int idGasolinera;
    public int idPeticion;
    public int coordX, coordY;
    public int dias;
    public double beneficio;

    public Peticion(int idGas, int idPet, int cx, int cy, int dias) {
        this.idGasolinera = idGas;
        this.idPeticion = idPet;
        this.coordX = cx;
        this.coordY = cy;
        this.dias = dias;
        this.beneficio = GasolinaBoard.VALOR_DEPOSITO * (1.02 - 0.02 * dias);
    }
}
