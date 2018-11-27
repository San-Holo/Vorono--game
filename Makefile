# COMPILATION DU PROJET
#Pour compiler en .native :
# ==> taper "make" dans le terminal
#Sinon :
# ==> taper "make other" dans le terminal (ne fonctionne pas encore correctement)
# NETTOYAGE DE REPERTOIRE
#Pour supprimer les .cmo .cmi
# ==> taper "make clean" dans le terminal
#Pour effacer tous les exécutables
# ==> taper "make mrproper" dans le terminal
AFF=affichage
RSV=resolve
JEU=jeu
VOR=voronoi
EXP=examples
SSV=sat_solver

all:$(JEU)

#compilation .native
$(JEU):
	ocamlbuild -pkg graphics $(JEU).native

#compilation fichier par fichier avec ocamlc
other: $(JEU).cmo 
	ocamlc -o $(JEU) $(EXP).cmo graphics.cma $(JEU).cmo $(AFF).cmo $(RSV).cmo $(SSV).cmo

#compilation de jeu.ml
$(JEU).cmo: $(JEU).ml $(AFF).cmo $(EXP).cmo $(RSV).cmo $(SSV).cmo
	ocamlc -c $(JEU).ml

#compilation de voronoi.ml
$(VOR).cmo: $(VOR).ml
	ocamlc -c $(VOR).ml

#compilation de sat_solver.ml
$(SSV).cmo: $(SSV).ml $(SSV).cmi
	ocamlc -c $(SSV).ml

#compilation de sat_solver.mli
$(SSV).cmi: $(SSV).mli
	ocamlc $(SSV).mli

#compilation de examples.ml
$(EXP).cmo: $(EXP).ml $(VOR).cmo
	ocamlc -c $(EXP).ml

#compilation de affichage.ml
$(AFF).cmo: $(VOR).cmo $(AFF).ml
	ocamlc -c $(AFF).ml

#compilation de resolve.ml
$(RSV).cmo: $(VOR).cmo $(SSV).cmo
	ocamlc -c $(RSV).ml

clean:
	rm -rf *.cmi *.cmo

mrproper:
	rm -rf *.cmi *.cmo *.native _build $(JEU)
