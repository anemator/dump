(* Remove the n'th element from a list. *)
let rec remove_at n xs = match n with
    0 -> List.tl xs
  | m -> List.hd xs :: remove_at (m-1) (List.tl xs)

remove_at 1 [`a; `b; `c; `d] = [`a; `c; `d];;
