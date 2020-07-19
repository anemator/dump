(* Reverse a list. *)
let rev xs =
  let rec tail ys acc = match ys with
      [] -> acc
    | y :: ys' -> tail ys' (y :: acc)
  in tail xs []

rev [`a; `b; `c] = [`c; `b; `a];;
