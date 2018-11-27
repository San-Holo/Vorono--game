(* ce qui est utile pour plusieurs fichiers et les types utilisés*)

open Graphics;;


type seed = {c : color option; x : int; y : int};;

type voronoi = {dim : int*int;seeds : seed array};;


(*renvoie la distance taxicable entre deux points (a,b) et (c,d)*)
let taxicab_distance a b c d =
  abs(a - c) + abs(b - d) ;;

(*renvoie la distance euclidienne entre deux points (a,b) et (c,d)*)
let euclidian_distance x y z t = (x-z)*(x-z)+(y-t)*(y-t);;

  (*vÃ©rifie si l'item i est dans la liste l

 l : liste...............................
 i : item................................*)
let rec  is_in l i = match l with
  |[] -> false
  |a::q -> ( a=i || is_in q i)
;;
