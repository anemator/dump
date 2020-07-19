(* Find the last element of a list. *)
let rec last xs = match xs with
    [] -> None
  | x :: [] -> Some x
  | x :: xs' -> last xs'

last [`a; `b; `c; `d] = Some `d;;
last [] = None;;
