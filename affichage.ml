(*Fonctions d'affichage et d'interraction avec l'utilisateur*)

open Graphics;;
open Voronoi;;

(*modification de la fonction set_color
dessinant un rond indiquant la couleur
courante de coloriage

c : nouvelle couleur courante*)
let set_color c =
  Graphics.set_color c;
  fill_circle (85*size_x()/100) (size_y()/20) (size_y()/21);
  synchronize();
;;


(* permet à l'utilisateur de choisir sa distance
parmis celles disponibles au début de la partie *)
let choisir_distance =
  open_graph " 300x300";
  moveto 0 (size_y()/2);
  lineto (size_x()) (size_y()/2);
  set_text_size 1024;
  moveto (size_x()/3) (size_y()/4);
  draw_string "TAXICAB";
  moveto (size_x()/3) (3*(size_y()/4));
  draw_string "EUCLIDIENNE";
  let ev =  wait_next_event [Button_down]in
  if(ev.mouse_y > (size_y()/2))then ( euclidian_distance )
  else ( taxicab_distance )
;;

(*Trace chaque ligne du diagramme de voronoi et colorie

mat : matrice des régions
vor : le voronoi affiché *)
let draw_voronoi mat vor =
  let i_max = (fst vor.dim)-1 and j_max = (snd vor.dim)-1 in
  for i = 0 to i_max do
    for j = 0 to j_max do
      Graphics.set_color black;
      if(i>0 && mat.(i).(j) <> mat.(i-1).(j)) then( plot i j; )
      else if(i < (i_max)-1 && mat.(i).(j) <> mat.(i+1).(j)) then( plot i j;)
      else if(j>0 && mat.(i).(j) <> mat.(i).(j-1)) then( plot i j;)
      else if(j < (j_max)-1 && mat.(i).(j) <> mat.(i).(j+1)) then( plot i j;)
      else  match vor.seeds.(mat.(i).(j)).c with
	    | Some a -> Graphics.set_color a; plot i j;
	    | None -> Graphics.set_color white; plot i j;
    done;
  done;
;;

(*vérifie si l'item i est dans la liste l

 l : liste...............................
 i : item................................*)
let rec  is_in l i = match l with
  |[] -> false
  |a::q -> ( a=i || is_in q i)
;;


(*recherche le bouton sur lequel on a cliqué utilisée seulement
si on clique dans la partie grisée de l'interface.............

x , y : les coordonnées du clic ..............................
return : un triplet permettant de réaliser l'action suivante*)
let find_button x y l =
  let y2 = size_y() and x2 = size_x() and deny = 10 in
  if( x > (8*x2/10) && x < (8*x2/10)+(x2/10) )then begin
      if(y > y2-(y2/deny)  )then (
	print_endline "reset";
	(-2,-2,-2) )
      else if( y < y2-(y2/deny) && y > y2-2*(y2/deny) )then (
	print_endline "solve";
	(-3,-3,-3) )
      else if( y < y2-2*(y2/deny) && y > y2-3*(y2/deny) )then (
	print_endline "quit";
	(-4,-4,-4) )
      else if (  y < y2-3*(y2/deny) && y > y2-4*(y2/deny) ) then(
	print_endline "next";
	(-5,-5,-5))
      else if( y < (y2/2)+(y2/deny) && y > (y2/2) && is_in l red  )then (
	set_color red;
	print_endline "color : red";
	(-1,-1,-1) )
      else if( y < (y2/2) && y > (y2/2)-(y2/deny) && is_in l blue )then (
	set_color blue;
	print_endline "color : blue";
	(-1,-1,-1) )
      else if( y < (y2/2)-(y2/deny) && y > (y2/2)-2*(y2/deny) && is_in l yellow )then (
	set_color yellow;
	print_endline "color : yellow";
	(-1,-1,-1) )
      else if( y < (y2/2)-2*(y2/deny) && y > (y2/2)-3*(y2/deny) && is_in l green )then (
	set_color green;
	print_endline "color : green";
	(-1,-1,-1) )
      else if( y < (y2/2)-3*(y2/deny) && y > (y2/2)-4*(y2/deny) )then (
	set_color white;
	print_endline "color : white";
	(-1,-1,-1) )
      else (-1,-1,-1)
    end
  else (-1,-1,-1)
;;


(*affiche les boutons permettant de changer de couleur sur l'interface

l : liste des couleurs d'un voronoi*)
let set_buttons_color l =
  let denx = 10 in
  let deny = 10 in
  let x = size_x() and y = size_y() in
  if (is_in l red) then (
    Graphics.set_color red ;
    fill_rect ((80*x)/100) (y/2) (x/denx) (y/deny) ;
    Graphics.set_color black;
    draw_rect ((80*x)/100) (y/2) (x/denx) (y/deny) ; )
  else ();
  if (is_in l blue) then (
    Graphics.set_color blue ;
    fill_rect ((80*x)/100) ((y/2)-(y/deny)) (x/denx) (y/deny) ;
    Graphics.set_color black;
    draw_rect ((80*x)/100) ((y/2)-(y/deny)) (x/denx) (y/deny) ; )
  else();
  if (is_in l yellow) then (
    Graphics.set_color yellow ;
    fill_rect ((80*x)/100) ((y/2)-2*(y/deny)) (x/denx) (y/deny) ;
    Graphics.set_color black;
    draw_rect((80*x)/100) ((y/2)-2*(y/deny)) (x/denx) (y/deny) ;)
  else ();
  if(is_in l green) then (
    Graphics.set_color green ;
    fill_rect ((80*x)/100) ((y/2)-3*(y/deny)) (x/denx) (y/deny) ;
    Graphics.set_color black;
    draw_rect ((80*x)/100) ((y/2)-3*(y/deny)) (x/denx) (y/deny); )
  else ();
  Graphics.set_color white ;
  fill_rect ((80*x)/100) ((y/2)-4*(y/deny)) (x/denx) (y/deny) ;
  Graphics.set_color black;
  draw_rect ((80*x)/100) ((y/2)-4*(y/deny)) (x/denx) (y/deny) ;
;;

(*affiche le bouton reset sur l'interface*)
let set_button_reset() =
  let x = size_x() and y = size_y() in
  set_color white;
  fill_rect ((8*x)/10) (y-(y/10)) (x/10) (y/10) ;
  set_color black;
  draw_rect ((8*x)/10) (y-(y/10)) (x/10) (y/10) ;
  moveto (((8*x)/10)+x/30) ((y-(y/10))+(y/20)) ;
  draw_string "RESET";
;;

(*affiche le bouton solve sur l'interface*)
let set_button_solve() =
  let x = size_x() and y = size_y() in
  set_color white;
  fill_rect ((8*x)/10) (y-2*(y/10)) (x/10) (y/10) ;
  set_color black;
  draw_rect ((8*x)/10) (y-2*(y/10)) (x/10) (y/10) ;
  moveto ((8*x/10)+x/30) ((y-2*(y/10))+y/20) ;
  draw_string "SOLVE";
;;

(*affiche le bouton quit sur l'interface*)
let set_button_quit() =
  let x = size_x() and y = size_y() in
  set_color white;
  fill_rect ((8*x)/10) (y-3*(y/10)) (x/10) (y/10) ;
  set_color black;
  draw_rect ((8*x)/10) (y-3*(y/10)) (x/10) (y/10) ;
  moveto ((8*x/10)+x/30) ((y-3*(y/10))+y/20) ;
  draw_string "QUIT";
;;

(*affiche le bouton quit sur l'interface*)
let set_button_next() =
  let x = size_x() and y = size_y() in
  set_color white;
  fill_rect ((8*x)/10) (y-4*(y/10)) (x/10) (y/10) ;
  set_color black;
  draw_rect ((8*x)/10) (y-4*(y/10)) (x/10) (y/10) ;
  moveto ((8*x/10)+x/30) ((y-4*(y/10))+y/20) ;
  draw_string "NEXT";
;;


(*appelle toutes les fonctions d'affichage de boutons
et autres options autres que le voronoi*)
let set_buttons l =
  set_color (rgb 100 100 100);
  fill_rect (75*size_x()/100) 0 (size_x()/4) (size_y()) ;
  set_buttons_color l;
  set_button_reset();
  set_button_solve();
  set_button_quit();
  set_button_next();
  synchronize();
;;
(*Une boucle de notre programme, repère les actions de l'utilisateur

mat : matrice des régions ..............................................
cnstr : les contraintes de coloriage imposées par le voronoi de départ
retourne un triplet indiquant la prochaine action*)
let one_loop mat cnstr l =
  let ev =  wait_next_event [Button_down]in
  if (ev.button) && ( ev.mouse_x > 75*size_x()/100 ) then (
    find_button (ev.mouse_x) (ev.mouse_y) l )
  else if (ev.button) && not(is_in cnstr mat.(ev.mouse_x).(ev.mouse_y)) then(
    plot (ev.mouse_x) (ev.mouse_y);
    (ev.mouse_x,ev.mouse_y,mat.(ev.mouse_x).(ev.mouse_y)) )
  else (-1,-1,-1)
;;
