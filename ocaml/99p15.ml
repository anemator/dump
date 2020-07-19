(* Replicate the elements of a list a given number of times. *)
let replicate xs n =
  let rec repel e = function
    | 0 -> []
    | m -> e :: repel e (m-1) in
  let rec repal n = function
      [] -> []
    | h :: t -> repel h n :: repal n t in
  List.flatten (repal n xs)

replicate [`a; `b; `c] 3 = [`a; `a; `a; `b; `b; `b; `c; `c; `c];;
