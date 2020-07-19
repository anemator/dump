(* https://en.wikipedia.org/wiki/Boolean_algebra#Basic_operations *)
type t =
  | False
  | True
  | Not of t
  | And of t * t
  | Or of t * t

let rec eval = function
  | False -> false
  | True -> true
  | Not expr -> not (eval expr)
  | And (lhs, rhs) -> eval lhs && eval rhs
  | Or (lhs, rhs) -> eval lhs || eval rhs

let implies x y = Or ((Not x), y)

let xor x y = And (Or (x, y), Not (And (x, y)))

let equiv x y = Not (xor x y)

let () =
  let t = True and f = False in

  (* And *)
  assert (eval (And (t, t)) == true);
  assert (eval (And (t, f)) == false);
  assert (eval (And (f, t)) == false);
  assert (eval (And (f, f)) == false);

  (* Or *)
  assert (eval (Or (t, t)) == true);
  assert (eval (Or (t, f)) == true);
  assert (eval (Or (f, t)) == true);
  assert (eval (Or (f, f)) == false);

  (* Not *)
  assert (eval (Not t) == false);
  assert (eval (Not f) == true);

  (* implies *)
  assert (eval (implies t t) == true);
  assert (eval (implies t f) == false);
  assert (eval (implies f t) == true);
  assert (eval (implies f f) == true);

  (* xor *)
  assert (eval (xor t t) == false);
  assert (eval (xor t f) == true);
  assert (eval (xor f t) == true);
  assert (eval (xor f f) == false);

  (* equiv *)
  assert (eval (equiv t t) == true);
  assert (eval (equiv t f) == false);
  assert (eval (equiv f t) == false);
  assert (eval (equiv f f) == true);

  (* Miscellaneous *)
  assert (eval (And (Or (True, False), Not False)) == true)
