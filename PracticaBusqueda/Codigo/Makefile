all: clean compile execute

compile:
	mkdir -p Codigo/src/Clases
	javac -cp ".:AIMA.jar:Gasolina.jar" -d src/Clases src/*.java

execute:
	java -cp "src/Clases:.:AIMA.jar:Gasolina.jar" PracticaBusqueda.Codigo.src.GasolinaDemo

clean:
	rm -rf ./src/Clases