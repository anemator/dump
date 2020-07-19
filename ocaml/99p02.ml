(* Find the last but one element of a list. *)
let rec but_last xs = match xs with
    [] | [_] -> None
  | [x; y]   -> Some x
  | _ :: xs' -> but_last xs'

but_last [`a; `b; `c; `d] = Some `c;;
but_last [`a] = None;;
