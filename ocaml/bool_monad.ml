(* A monadic boolean expression evaluator *)
type 'a t =
  | Return of 'a
  | Bind : 'a t * ('a -> 'b t) -> 'b t

let return t = Return t
let bind x f = Bind (x, f)
let (>>=) x f = bind x f
let (>>|) x f = x >>= fun x -> return (f x)

let rec eval: type a. a t -> a = function
  | Return t -> t
  | Bind (t,f) -> eval (f (eval t))

let () =
  let expr' =
    let expr' =
      return true >>= fun t ->
      return false >>= fun f ->
      return (Printf.printf "expr result: %b\n" (t && f)) in
    print_endline "finished creating expression";
    expr'
  in
  print_endline "before evaluating expression";
  eval expr';
  print_endline "after evaluating expression";
