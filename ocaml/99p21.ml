(* Insert an element at a given position into a list. Start counting
 * list elements with 0. *)
let rec insert_at x pos xs = match pos with
    0 -> x :: xs
  | n -> List.hd xs :: insert_at x (n-1) (List.tl xs)

insert_at `alfa 1 [`a; `b; `c; `d] = [`a; `alfa; `b; `c; `d];;
