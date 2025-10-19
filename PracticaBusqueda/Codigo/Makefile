all: clean compile execute

compile:
	mkdir -p src/Clases
	javac -cp ".:AIMA.jar:Gasolina.jar" -d src/Clases src/*.java

execute:
	java -cp "src/Clases:.:AIMA.jar:Gasolina.jar" PracticaBusqueda.Codigo.src.GasolinaDemo

clean:
	rm -rf Codigo/src/Clases