(* contient les fonctions principales du programme ainsi que le main*)

open Graphics;;
open Affichage;;
open Voronoi;;
open Resolve;;

(*la liste des voronois du jeu, à modifier dans examples.ml*)
let l_vor = Examples.list;;

(* determine l index de la region la plus proche du pixel a b *)
(* f : fonction de calcul de distance ------------------------*)
(* a, b : coordonnees du pixel -------------------------------*)
(* tab : seeds array d un voronoi ----------------------------*)
(* idx : index courrant, iterateur ---------------------------*)
(* tmp : index de la region la plus proche jusqu a maintenant-*)
let rec plus_proche_region f a b tab idx tmp =
  if (idx < (Array.length tab)-1) then
    begin
      if f a b tab.(tmp).x tab.(tmp).y > f a b tab.(idx).x tab.(idx).y then
	plus_proche_region f a b tab (idx+1) idx
      else
	plus_proche_region f a b tab (idx+1) tmp
    end
  else
    begin
      if f a b tab.(tmp).x tab.(tmp).y > f a b tab.(idx).x tab.(idx).y then
	idx
      else
	tmp
    end
;;


(* matrice des regions : mat(i)(j) = k <=> pixel i j dans la region d index k du germ array
   vor : Voronoï
   f : fonction de distance *)
let regions_voronoi f vor =
  let mat = Array.make_matrix  (fst vor.dim) (snd vor.dim) (-1) in
  for i = 0 to ((fst vor.dim)-1) do
    for j = 0 to ((snd vor.dim)-1) do
      (mat).(i).(j) <- (plus_proche_region f i j vor.seeds 0 0)
    done
  done;
  mat
;;




(* matrice d adjacence : mat_reg(i)(j) = true <=> mat_reg(j)(i) = true
..................................... <=> regions i et j se touchent

mat_reg : matrice des régions........................................
vor : le voronoi courant.............................................*)
let adjacences_voronoi vor mat_reg =
  let mat : bool array array = Array.make_matrix (Array.length vor.seeds) (Array.length vor.seeds) false in
  let i_max = (fst vor.dim)-1 and j_max = (snd vor.dim)-1in
  for i = 0 to i_max do
    for j = 0 to j_max do
      if (j>0 && (mat_reg.(i).(j)) <> (mat_reg.(i).(j-1)) ) then(
	mat.((mat_reg.(i).(j))).((mat_reg.(i).(j-1))) <- true;
	mat.((mat_reg.(i).(j-1))).((mat_reg.(i).(j))) <- true;)
      else ();
      if( j < j_max && (mat_reg.(i).(j)) <> (mat_reg.(i).(j+1)) ) then (
	mat.((mat_reg.(i).(j))).((mat_reg.(i).(j+1))) <- true;
	mat.((mat_reg.(i).(j+1))).((mat_reg.(i).(j))) <- true;)
      else ();
      if( i < i_max && (mat_reg.(i).(j)) <> (mat_reg.(i+1).(j)) ) then(
	mat.((mat_reg.(i).(j))).((mat_reg.(i+1).(j))) <- true;
	mat.((mat_reg.(i+1).(j))).((mat_reg.(i).(j))) <- true;)
      else ();
      if(i>0&& (mat_reg.(i).(j)) <> (mat_reg.(i-1).(j)) ) then (
	mat.((mat_reg.(i).(j))).((mat_reg.(i-1).(j))) <- true;
	mat.((mat_reg.(i-1).(j))).((mat_reg.(i).(j))) <- true;)
      else ();
    done
  done;
  mat
;;

(*supprime un élément d'une liste liste_vor

liste_vor : liste de voronoi
a : élément à supprimer
return : liste avec l'élément supprimé*)
let rec supp_vor liste_vor a = match liste_vor with
  | [] -> failwith "erreur supp_vor liste vide"
  | [v] -> if not(v = a) then [v] else []
  | v::q -> if v = a then supp_vor q a else [v]@(supp_vor q a);;

(*choisi un voronoi depuis une liste de façon aléatoire
si la liste est vide on retourne un voronoi "nul"

liste_vor : liste de voronois
return : un voronoi*)
let choisir_voronoi liste_vor =
  Random.self_init ();
  if (List.length !liste_vor) > 0 then (
    let r = Random.int (List.length !liste_vor) in
    let choosen = List.nth (!liste_vor) r in
    liste_vor := (supp_vor (!liste_vor) choosen);
    choosen )
  else
    {dim = 0,0; seeds = [||]}
;;

(*fonction permettant de reset une partie

seeds : tableau de seeds à reset
save : sauvegarde de ce tableau*)
let reset seeds save =
  let i_max = (Array.length seeds)-1 in
  for i = 0 to i_max do
    if save.(i).c = None then
      seeds.(i) <- {c = None ;x = seeds.(i).x ;y =  seeds.(i).y };
  done;
;;

let main =
  let playing = ref true and in_game = ref true in
  let dist = choisir_distance in
  let l = ref l_vor in
  while (!in_game) do
    playing := true ;
    let v =  ref (choisir_voronoi l) in
    if( (!v).dim = (0,0) ) then(in_game := false; playing :=false;)
    else (
      resize_window ((fst !v.dim)+(fst !v.dim)/3) (snd !v.dim);
      let save = Array.copy !v.seeds in
      let mat_reg = regions_voronoi dist !v in
      let mat_adj =  adjacences_voronoi !v mat_reg in
      let cnstr = get_cnstr !v in
      let color_list = get_color !v.seeds in
      let all_cnstr = ref  (all_constraints !v mat_adj color_list) in
      auto_synchronize false;
      draw_voronoi mat_reg !v;
      set_buttons color_list;
      synchronize();
      let triplet = ref (-1,-1,-1) in
      set_color white;
      while(not(complet mat_adj !v.seeds) && !playing)do
	triplet := one_loop mat_reg cnstr color_list;
	match !triplet with
	|(-1,-1,-1) -> ()
	|(-2,-2,-2) -> (v := {dim = (fst !v.dim),(snd !v.dim) ; seeds = (Array.copy save)};
			draw_voronoi mat_reg !v;
			synchronize();
			set_color white;)
	|(-3,-3,-3) -> (let x = ref [] in
			instance_constraints !v x;
			let x' = ref ((!all_cnstr)@(!x)) in
			let sl = Sat.solve (!x') in
			instance_of_affectations sl !v mat_reg;
			wait_next_event [Button_up];
			draw_voronoi mat_reg !v;
			synchronize();
        )
	|(-4,-4,-4) -> (playing:=false; in_game:=false;)
	|(-5,-5,-5) -> ( playing := false ;)
	|(a,b,d) -> ( if b = white then
	    !v.seeds.(d) <- {c = None ;x = !v.seeds.(d).x ;y =  !v.seeds.(d).y }
	  else
	    !v.seeds.(d) <- {c = Some (point_color a b) ;x = !v.seeds.(d).x ;y =  !v.seeds.(d).y } ;
		      draw_voronoi mat_reg !v;
		      synchronize();
		      if ((point_color a b)=black) then
			( set_color white;)
		      else
			(set_color (point_color a b);) );
      done;
      if (complet mat_adj !v.seeds) then
	( print_endline "Congratulation, YOU WIN !!"; ))
  done;
  close_graph ();
;;


