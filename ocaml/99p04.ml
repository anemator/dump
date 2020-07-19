(* Find the number of elements of a list. *)
let rec length xs = match xs with
    [] -> 0
  | [_] -> 1
  | _ :: xs' -> 1 + length xs'

length [`a; `b; `c] = 3;;
length [] = 0;;

let length xs =
  let rec tail acc = function
  | [] -> acc
  | x :: xs' -> tail (1+acc) xs'
  in tail 0 xs

length [`a; `b; `c] = 3;;
length [] = 0;;
