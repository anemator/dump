(* Find the k'th element of a list. *)
let rec at k xs = match (k, xs) with
    (_, []) -> None
  | (1, x::_) -> Some x
  | (n, x::xs') -> at (n-1) xs'

at 3 [`a; `b; `c; `d; `e] = Some `c;;
at 3 [`a] = None;;
