#include <iostream>
#include <fstream>
#include <string>
#include <vector>
#include <algorithm>
#include <random>
#include <ctime>

using namespace std;

const string NOMBRE_FICHERO = "problema_generado.pddl";

struct Habitacion {
    int capacidad;
    bool disponible; 
};

struct Reserva {
    int personas;
    int desde;
    int hasta;
};

void generarProblema(int numHabs, int numReservas, int maxPersonas, int maxDias) {
    ofstream archivo(NOMBRE_FICHERO);
    if (!archivo.is_open()) {
        cerr << "Error al crear el archivo." << endl;
        return;
    }

    vector<Habitacion> habitaciones(numHabs);
    for (int i = 0; i < numHabs; i++) {
        habitaciones[i].capacidad = (rand() % maxPersonas) + 1; 
    }

    vector<Reserva> reservas(numReservas);
    for (int i = 0; i < numReservas; i++) {
        reservas[i].personas = (rand() % maxPersonas) + 1;
        
        reservas[i].desde = (rand() % (maxDias - 2)) + 1; 
        int duracion = (rand() % 4) + 1; 
        reservas[i].hasta = reservas[i].desde + duracion;
    }

    archivo << "(define (problem problemaHotelExtension4-Gen)" << endl;
    archivo << "  (:domain dominioHotelExtension4)" << endl;
    archivo << endl;
    archivo << "  (:objects" << endl;
    archivo << "   ";
    for (int i = 0; i < numHabs; i++) {
        archivo << " h" << i;
    }
    archivo << " - habitacion" << endl;
    
    archivo << "   ";
    for (int i = 0; i < numReservas; i++) {
        archivo << " r" << i;
    }
    archivo << " - reserva" << endl;
    archivo << "  )" << endl;
    archivo << endl;

    archivo << "  (:init" << endl;
    archivo << "    (= (total-cost) 0)" << endl;
    archivo << "    (= (num-habs) 0)" << endl;

    archivo << endl << "    ;; Habitaciones" << endl;
    for (int i = 0; i < numHabs; i++) {
        archivo << "    (= (capacidad h" << i << ") " << habitaciones[i].capacidad << ")" << endl;
    }

    archivo << endl << "    ;; Reservas" << endl;
    for (int i = 0; i < numReservas; i++) {
        archivo << "    (= (personas r" << i << ") " << reservas[i].personas << ")" << endl;
        archivo << "    (= (desde r" << i << ") " << reservas[i].desde << ")" << endl;
        archivo << "    (= (hasta r" << i << ") " << reservas[i].hasta << ")" << endl;
        archivo << endl;
    }
    archivo << "  )" << endl;
    archivo << endl;

    archivo << "  (:goal" << endl;
    archivo << "    (forall (?r - reserva) (procesada ?r))" << endl;
    archivo << "  )" << endl;
    archivo << endl;

    archivo << "  (:metric minimize (+ (total-cost) (* (num-habs) 10)))" << endl;
    archivo << ")" << endl;

    archivo.close();
    cout << "¡Generado con éxito! Archivo: " << NOMBRE_FICHERO << endl;
}

int main() {
    srand(time(NULL));
    
    int numHabs, numReservas, maxPersonas, maxDias;

    cout << "--- GENERADOR DE PROBLEMAS HOTEL (EXT 4) ---" << endl;
    cout << "Num. Habitaciones: "; cin >> numHabs;
    cout << "Num. Reservas: ";     cin >> numReservas;
    cout << "Max. Personas (Capacidad): "; cin >> maxPersonas;
    cout << "Horizonte temporal (dias): ";  cin >> maxDias;

    generarProblema(numHabs, numReservas, maxPersonas, maxDias);

    return 0;
}