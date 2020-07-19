(* Eliminate consecutive duplicates of list elements. *)
let rec compress = function
  | [] -> []
  | [x] -> [x]
  | x :: xs -> if x = List.hd xs then compress xs else x :: (compress xs)

compress [`a;`a;`a;`a;`b;`c;`c;`a;`a;`d;`e;`e;`e;`e] = [`a;`b;`c;`a;`d;`e];;
