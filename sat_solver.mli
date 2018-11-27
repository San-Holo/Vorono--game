(* Code extrait de:
   SAT-MICRO: petit mais costaud !
  *)

module type VARIABLES = sig
  type t
  val compare : t -> t -> int
end

module Make (V : VARIABLES) : sig

  type literal = bool * V.t

  val solve : literal list list -> literal list option

end
