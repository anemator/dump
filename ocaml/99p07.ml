(* Flatten a nested list structure. *)
type 'a node =
| One of 'a
| Many of 'a node list

let rec flatten = function
  | [] -> []
  | One x :: xs -> x :: flatten xs
  | Many xs :: ys -> flatten xs @ flatten ys

flatten [One `a; Many [One `b; Many [One `c; One `d]; One `e]]
= [`a; `b; `c; `d; `e];;
