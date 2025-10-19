package IA.PracticaGasolina;

public class Peticion {
    public int idGasolinera;
    public int idCamion;
    public int dias;

    public Peticion(int idGas, int idCam, int dias) {
        this.idGasolinera = idGas;
        this.idCamion = idCam;
        this.dias = dias;
    }

    public void setIDCam(int cam) { this.idCamion = cam; }
    public int getIDCam() { return this.idCamion; }
}
