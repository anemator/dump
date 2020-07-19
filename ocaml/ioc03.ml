(* EXERCISE 3 *)
let rec sum n m f =
  match n = m with
  | true -> f n
  | false -> f n + sum (n+1) m f

let sum_tail n m f =
  let rec loop acc i =
    match i = m with
    | true -> f i + acc
    | false -> loop (f i + acc) (i+1) in
  loop 0 n

(* EXERCISE 4 *)
let rec ( %% ) n m =
  match n > m, m with
  | _, 0 -> n
  | true, _ -> (n-m) %% m
  | false, _ -> n %% (m-n)

(* EXERCISE 5 *)
let search f n =
  let rec loop i =
    match i=n, f i >= 0 with
    | false, false -> loop (i+1)
    | false, true -> i
    | true, _ -> n in
  loop 1

(* EXERCISE 6 *)
let empty = (fun key -> 0)

let add dict key value =
  (fun key' ->
   match key' = key with
   | true -> value
   | false -> dict key')

let find dict key = dict key

(* EXERCISE 7 *)
let find_root b c =
  (fun a -> (-.b +. sqrt (b ** 2. -. 4. *. a *. c)) /. (2. *. a))

let fix_root = find_root 0. (-1.)

(* EXERCISE 8 *)
(* TODO: this exercise is weird and awesome, must revisit *)
type stream = int -> int

let hd (s: stream) : int = s 0

let tl (s: stream) : stream = (fun i -> s (i + 1))

let ( +: ) (s: stream) (c: int) : stream = (fun i -> s i + c)

let ( -| ) (s: stream) (t: stream) : stream = (fun i -> s i - t i)

let map (f: int -> int) (s: stream) : stream = (fun i -> f (s i))

let deriv (s: stream) : stream = tl s -| s

(* TODO: fix this function, it doesn't satisfy,
 *       integ (deriv s) = S +: c for some c *)
let rec integ (s: stream) : stream = fun i ->
  match i with
  | 0 -> s 0
  | _ -> s i + integ s (i-1)

