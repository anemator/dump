(* Split a list into two pars; the length of the first part is given. Do not
 * use any predefined predicates. *)
let split xs n =
  let rec aux acc = function
      [] as rest, _ | rest, 0 -> (List.rev acc, rest)
    | y::ys, m -> aux (y::acc) (ys,(m-1)) in
  aux [] (xs,n)

split [`a;`b;`c;`d;`e;`f;`g;`h;`i;`j] 3
= ([`a;`b;`c] , [`d;`e;`f;`g;`h;`i;`j]);;

split [`a;`b;`c;`d] 5 = ([`a; `b; `c; `d], []);;
