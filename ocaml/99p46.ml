type bool_expr =
| Var of string
| Not of bool_expr
| And of bool_expr * bool_expr
| Or of bool_expr * bool_expr

(* Truth tables for logical expressions. Define a function, table2 which
 * returns the truth table of a given logical expression in two variables
 * (specified as arguments). The return value must be a list of triples
 * containing (a_val, b_val, expr_val). *)
let table2 a b expr =
  let rec aux va vb = function
    | Var x -> if x = a then va else if x = b then vb else failwith "BAM!"
    | Not x -> not (aux va vb x)
    | And (x,y) -> aux va vb x && aux va vb y
    | Or (x,y) -> aux va vb x || aux va vb y in
  [(true, true, aux true true expr);
   (true, false, aux true false expr);
   (false, true, aux false true expr);
   (false, false, aux false false expr)]

table2 "a" "b" (And(Var "a", Or(Var "a", Var "b")))
=  [(true, true, true);
   (true, false, true);
   (false, true, false);
   (false, false, false)]
;;
