(*fonctions permettant la résolution du voronoi via le sat_solver*)

open Voronoi;;
open Graphics;;

module Variables_Seed = struct
  type t = (color option)*int
  let compare a b = compare a b
end;;

module Sat = Sat_solver.Make(Variables_Seed);;


(*Vérifie si un voronoi est terminé

mat : matrice d'adjacence
tab : tableau de seeds
renvoie true si l'utilisateur a gagné*)
let complet mat tab =
  let b = ref true in
  for i=0 to (Array.length mat)-1 do
    for j=i to (Array.length mat.(i))-1 do
      if mat.(i).(j) then
        if tab.(i).c = tab.(j).c || tab.(i).c = None || tab.(j).c = None  then
	  b := false
    done
  done;
  !b
;;

(*retourne les contraintes de départ d'un voronoi

v : voronoi
return : liste des couleurs de départ *)
let get_cnstr v =
  let l = ref [] in
  for i = 0 to (Array.length v.seeds)-1 do
    match v.seeds.(i).c with
    |None -> ()
    |Some a -> l := !l@[i];
  done;
  !l
;;

(*retourne la liste des couleurs d'un voronoi

tab : tableau de seeds
return : liste des couleurs dans tab*)
let get_color tab =
  let i_max = (Array.length tab)-1 and l = ref [] in
  for i = 0 to i_max do
    match tab.(i).c with
    |None -> ()
    |Some a -> if not(is_in !l a) then l := a::(!l);
  done;
  !l
;;

(* contraintes d'éxistence :

l : liste des couleurs utilisables
voronoi : le voronoi à résoudre
formula : la FNC à composer *)
let exists voronoi formula l =
  let rec create_list i l l'=
    match l with
    |[] -> failwith "erreur create_list : liste vide"
    |[a] -> (true,(Some a,i))::(!l')
    |a::q -> l' := ((true,(Some a,i))::(!l')); (create_list i q l') in
  let i_max = (Array.length voronoi.seeds)-1 in
  for i=0 to i_max do
    let l' = ref [] in
    formula := [(create_list i l l')]@(!formula)
  done;
;;


(* contraintes d'unicité :

l : lise des couleurs utilisabls
voronoi : le voronoi à résoudre
formula : la FNC à composer *)
let unique voronoi formula l' =
  let c = Array.of_list l' in
  let i_max = (Array.length voronoi.seeds)-1 and  k_max = (Array.length c)-1 in
  for i=0 to i_max do
    for k = 0 to k_max do
      for k' = k+1 to k_max do
        formula := [ [ ( false, ( c.(k), i )) ; ( false, ( c.(k'), i)) ] ]@(!formula) ;
      done;
    done;
  done;
;;

(* contraintes d'instance :

voronoi : le voronoi à résoudre
formula : la FNC à composer *)
let instance_constraints voronoi formula =
  let i_max = (Array.length voronoi.seeds)-1 in
  for i=0 to i_max do
    if ( voronoi.seeds.(i).c <> None && voronoi.seeds.(i).c <> Some white ) then
      formula := [[ ( true , ( voronoi.seeds.(i).c , i )) ]]@(!formula) ;
  done;
;;

(* contraintes d'adjacence :

l' : liste des couleurs utilisables
formula : la FNC à composer
mat_adj : matrice d'adjacence du voronoi*)
let adj_constraints mat_adj formula l' =
  let c = Array.of_list l' in
  let i_max = (Array.length mat_adj)-1 and k_max = (Array.length c)-1 in
  for i = 0 to i_max do
    for j = i+1 to i_max do
      if ( mat_adj.(i).(j) ) then (
	 for k = 0 to k_max do
             formula := [ [ ( false, ( c.(k), i )) ; ( false, ( c.(k), j)) ] ]@(!formula) ;
	 done;
      )
    done;
  done;
;;

let rec create_list_option l= match l with
  |[] -> failwith "erreur create_list_option : liste vide"
  |[a] -> [Some a]
  |a::q -> [Some a]@(create_list_option q);
;;

(*toutes les contraintes

voronoi : le voronoi à résoudre
mat_adj : matrice d'adjacence du voronoi
return : la liste des contraintes*)
let all_constraints voronoi mat_adj list_color =
  let l = ref [] in
  let l' = create_list_option list_color in
  unique voronoi l l';
  adj_constraints mat_adj l l';
  instance_constraints voronoi l;
  exists voronoi l list_color;
  !l
;;

(*il faudrait créer v' pour pouvoir faire un result reversible*)
(*fonction permettant l'affichage d'une solution au voronoi

sol : la list option de litéraux (la solution)
v : le voronoi
mat_reg : matrice des régions de v*)
let instance_of_affectations sol v mat_reg=
  let rec aux v v' l = match l with
    |[] -> failwith "instance_of_affectations : liste vide"
    | [a] -> if(fst a) then v'.seeds.(snd(snd a)) <- {c = (fst(snd a)); x=v.seeds.(snd(snd a)).x; y= v.seeds.(snd(snd a)).y};v'
    | a::q -> if(fst a) then v'.seeds.(snd(snd a)) <- {c = (fst(snd a)); x=v.seeds.(snd(snd a)).x; y= v.seeds.(snd(snd a)).y};
      aux v v' q;
  in match sol with
  | None -> ()
  | Some casablanca -> let v' = aux v ({dim = v.dim ; seeds =  (Array.make (Array.length v.seeds) {c=None ; x = 0; y = 0}) }) casablanca in
  Affichage.draw_voronoi mat_reg v'; synchronize();
;;
