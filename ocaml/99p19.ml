(* Rotate a list N places to the left. Hint: use the predefined functions
 * length and (@). *)
let rotate xs n =
  let rec aux left right = function
    | 0 -> right @ (List.rev left)
    | m -> aux (List.hd right :: left) (List.tl right) (m-1) in
  if n < 0 then List.rev (aux [] (List.rev xs) (-n)) else aux [] xs n

rotate [`a;`b;`c;`d;`e;`f;`g;`h] 3 = [`d;`e;`f;`g;`h;`a;`b;`c];;
rotate [`a;`b;`c;`d;`e;`f;`g;`h] (-2) = [`g;`h;`a;`b;`c;`d;`e;`f];;
