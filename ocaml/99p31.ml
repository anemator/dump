(* Determine whether a given integer number is prime. *)

(* (almost) brute force solution *)
let is_prime n =
  if n < 2 then false else
    let root = int_of_float (sqrt (float_of_int n)) in
    let rec aux k =
      if k <= root then
        if n mod k = 0 then false else aux (k+1)
      else
        true
    in aux 2

not (is_prime 1);;
is_prime 7;;
not (is_prime 12);;
not (is_prime 25);;

(* sieve of eratosthenes *)
let sieve n =
  let rec range acc = function
    | 1 -> acc
    | k -> range (k::acc) (k-1) in
  let rec sift acc k ys =
    match List.filter (fun x -> x mod k <> 0) ys with
    | [] -> k :: acc
    | hd::tl -> sift (k :: acc) hd tl in
  List.rev (sift [] 2 (range [] n))

(* TODO
let open Core_bench.Std.Bench in
[ Test.create ~name:"sieve 1000" (fun () -> ignore (sieve 1000));
  Test.create ~name:"sieve 10000" (fun () -> ignore (sieve 10000));
  Test.create ~name:"sieve 100000" (fun () -> ignore (sieve 100000)) ]
|> bench

let is_prime n = n = List.hd (List.rev (sieve n))

not (is_prime 1);;
is_prime 7;;
not (is_prime 12);;
not (is_prime 25);;
*)
