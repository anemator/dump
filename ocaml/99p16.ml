(* Drop every n'th element from a list. *)
let drop xs n =
  let rec aux m = function
    | [] -> []
    | y :: ys -> if m = 1 then aux n ys else y :: aux (m-1) ys in
  aux n xs

drop [`a;`b;`c;`d;`e;`f;`g;`h;`i;`j] 3 = [`a;`b;`d;`e;`g;`h;`j];;
