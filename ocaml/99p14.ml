(* Duplicate the elements of a list. *)
let rec duplicate = function
  | [] -> []
  | x :: xs -> x :: x :: duplicate xs

duplicate [`a;`b;`c;`c;`d] = [`a;`a;`b;`b;`c;`c;`c;`c;`d;`d];;
