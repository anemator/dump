open Core.Std

(* 6.1 Binary Trees *)
type 'a tree =
  | Leaf
  | Node of 'a * 'a tree * 'a tree

let rec cardinality = function
  | Leaf -> 0
  | Node (_, l, r) -> 1 + cardinality l + cardinality r

(* 6.2 Unbalanced Binary Trees *)
let empty = Leaf

(* Push a value onto a tree *)
let insert x s = Node (x, Leaf, s)

(* Convert a list to a set; creates a super inefficient tree -- right heavy. *)
let rec set_of_list = function
  | [] -> empty
  | h :: t -> insert h (set_of_list t)

(* Check for element membership *)
let rec mem x = function
  | Leaf -> false
  | Node (x', l, r) -> x = x' || mem x l || mem x r

(* 6.3 Unbalanced, Ordered, Binary Trees *)

(* Inserts a value into an ordered tree, preserving the order/invariant: for any
 * interior Node (x, l, r) node all the labels in l are smaller than x and all
 * those in r are greater than x *)
let rec insert x = function
  | Leaf -> Node (x, Leaf, Leaf)
  | Node (x', l, r) as node ->
     if x < x' then Node (x', insert x l, r)
     else if x > x' then Node (x', l, insert x r)
     else node

(* creates an ordered (not necessarily balanced) tree *)
let rec set_of_list = function
  | [] -> Leaf
  | h :: t -> insert h (set_of_list t)

(* checks for membership in O(d) time, in this case O(n) since the insert
 * function does not necessarily create balanced trees *)
let rec mem x = function
  | Leaf -> false
  | Node (x', l, r) -> x = x' || (x < x' && mem x l) || (x > x' && mem x r)

(* 6.4 Balanced Red-Black Trees *)

(* Invariants
 * - Every leaf is black
 * - Direct children of a red node are black
 * - The number of black nodes in the path from the root to any leaf node
 *   is constant
 * - The root node is always black *)
type color =
  | Red
  | Black

type 'a rbtree =
  | Leaf
  | Node of color * 'a * 'a rbtree * 'a rbtree

let rec mem x = function
  | Leaf -> false
  | Node (_, x', l, r) -> x = x' || (x < x' && mem x l) || (x > x' && mem x r)

(* balances the tree by considering all cases where a red node has a red child *)
let balance = function
  | Black, z, Node (Red, y, Node (Red, x, a, b), c), d
  | Black, z, Node (Red, x, a, Node (Red, y, b, c)), d
  | Black, x, a, Node (Red, z, Node (Red, y, b, c), d)
  | Black, x, a, Node (Red, y, b, Node (Red, z, c, d)) ->
     Node (Red, y, Node (Black, x, a, b), Node (Black, z, c, d))
  | a, b, c, d -> Node (a, b, c, d)

let insert x s =
  let rec loop = function
    | Leaf -> Node (Red, x, Leaf, Leaf)
    | Node (c, y, a, b) as s ->
       if x < y then balance (c, y, loop a, b)
       else if x > y then balance (c, y, a, loop b)
       else s in
  match loop s with
  | Node (_, y, a, b) -> Node (Black, y, a, b)
  | Leaf -> raise (Invalid_argument "insert")

let empty = Leaf

let rec set_of_list = function
  | [] -> empty
  | h :: t -> insert h (set_of_list t)

(* 6.5 Open Union Types (Polymorphic Variants) *)
let string_of_number1 = function
  | `Integer n -> string_of_int n
  | _ -> raise (Invalid_argument "unknown number")

let string_of_number2 = function
  | `Real x -> string_of_float x
  | n -> string_of_number1 n

(* 6.5.1 Type Definitions for Open Types *)
type 'a number = [> `Integer of int | `Real of float] as 'a

let (zero: 'a number) = `Zero

(* 6.5.2 Closed Union Types *)
let string_of_number = function
  | `Integer i -> string_of_int i
  | `Real x -> string_of_float x

(* 6.6 Some Common Built-In Unions *)
type bool =
  | true
  | false

type 'a list =
  | []
  | (::) of 'a * 'a list

type 'a option =
  | None
  | Some of 'a

(* EXERCISE 1 *)
type 'a mylist =
  | Nil
  | Cons of 'a * 'a mylist

let rec map f = function
  | Nil -> Nil
  | Cons (h, t) -> Cons (f h, map f t)

let map_tail f xs =
  let rec rev acc = function
    | Nil -> acc
    | Cons (h, t) -> rev (Cons (h, acc)) t in
  let rec loop acc = function
    | Nil -> acc
    | Cons (h, t) -> loop (Cons (f h, acc)) t in
  loop Nil xs |> rev Nil


(* linear time (in xs), linear space (in xs) *)
let rec append xs ys =
  match xs with
  | Nil -> ys
  | Cons (h, t) -> Cons (h, append t ys)

(* linear time (in xs+ys), constant space *)
let append_tail xs ys =
  let rec rev acc = function
    | Nil -> acc
    | Cons (h, t) -> rev (Cons (h, acc)) t in
  rev Nil xs |> rev ys

(* reference: http://stackoverflow.com/a/2867646 *)
let append_cps xs ys =
  let rec loop cont xs' ys' =
    match xs' with
    | Nil -> cont ys'
    | Cons (h, t) -> loop (fun acc -> cont (Cons (h, acc))) t ys' in
  loop (fun z -> z) xs ys

(* append_cps [1; 2] [2; 3]
 *   loop id [1; 2] [2; 3]
 *   loop (fun acc -> id (1 :: acc)) [2] [2; 3]
 *   loop (fun acc -> (fun acc -> id (1 :: acc)) (2 :: acc)) [] [2; 3]
 *   cont [2; 3]
 *   (fun acc -> (fun acc -> id (1 :: acc)) (2 :: acc)) [2; 3]
 *   (fun acc -> id (1 :: acc)) [2; 2; 3]
 *   id [1; 2; 2; 3]
 * [1; 2; 2; 3] *)

(* EXERCISE 2 *)
type unary_number =
  | Z
  | S of unary_number

let rec add x y =
  match x with
  | Z -> y
  | S x' -> add x' (S y)

let add_tail x y =
  let rec loop acc = function
    | Z -> acc
    | S x' -> loop (S acc) x' in
  loop y x

let add_cps x y =
  let rec loop cont = function
    | Z -> cont y
    | S x' -> loop (fun acc -> cont (S acc)) x' in
  loop (fun z -> z) x


let rec mult x y =
  match x with
  | Z -> Z
  | S Z -> y
  | S x' -> mult x' y |> add y

let mult_tail x y =
  let rec loop acc = function
    | Z -> Z
    | S Z -> acc
    | S x' -> loop (add_tail y acc) x' in
  loop y x

let mult_cps x y =
  let rec loop cont = function
    | Z -> Z
    | S Z -> cont y
    | S x' -> loop (fun acc -> cont (add_cps y acc)) x' in
  loop (fun z -> z) x

(* EXERCISE 3 *)
type small =
  | Four
  | Three
  | Two
  | One

let lt_small (x: small) (y: small) = not (x <= y)

(* EXERCISE 4 *)
type unop = Neg

type binop =
  | Add
  | Sub
  | Mul
  | Div

type exp =
  | Constant of int
  | Unary of unop * exp
  | Binary of exp * binop * exp

let rec eval x =
  let f_of = function
    | Add -> ( + )
    | Sub -> ( - )
    | Mul -> ( * )
    | Div -> ( / ) in
  match x with
  | Constant x -> x
  | Unary (Neg, exp) -> -1 * (eval exp)
  | Binary (l, op, r) -> (f_of op) (eval l) (eval r)

(* EXERCISE 5 *)
type ('a, 'b) t =
  | Empty
  | Node of ('a, 'b) t * 'a * 'b * ('a, 'b) t

let empty = Empty

let rec add d k v =
  match d with
  | Empty -> Node (Empty, k, v, Empty)
  | Node (l, k', v', r) ->
     if k <= k' then Node (add l k v, k', v', r)
     else Node (l, k', v', add r k v)

let rec find d k =
  match d with
  | Empty -> None
  | Node (l, k', v, r) ->
     if k = k' then Some v
     else if k < k' then find l k
     else find r k

(* EXERCISE 6 *)
type ('a, 'b) t =
  | Empty
  | Node of ('a, 'b) t * 'a * 'b * ('a, 'b) t

let empty = Empty

let rec add d k v =
  match d with
  | Empty -> Node (Empty, k, v, Empty)
  | Node (l, k', v', r) ->
     if k <= k' then Node (add l k v, k', v', r)
     else Node (l, k', v', add r k v)

let rec find d k =
  match d with
  | Empty -> None
  | Node (l, k', v, r) ->
     if k = k' then Some v
     else if k < k' then find l k
     else find r k

(***********************************************************************)

type vertex = int

type graph = (vertex, vertex list) t

let rec reachable (g: graph) (v1: vertex) (v2: vertex) : bool =
  match find g v1 with
  | None -> false
  | Some xs ->
     let rec loop = function
       | [] -> false
       | h :: t -> if h = v2 || reachable g h v2 then true else loop t in
     loop xs

(* EXERCISE 7 *)
type 'a t =
  | Leaf
  | Node of 'a t * 'a * 'a t

type comparison =
  | LessThan
  | Equal
  | GreaterThan

let rec insert compare x = function
  | Leaf -> Node (Leaf, x, Leaf)
  | Node (t1, x', t2) as node ->
     match compare x x' with
     | LessThan -> Node (insert compare x t1, x', t2)
     | Equal -> node
     | GreaterThan -> Node (t1, x', insert compare x t2)

(* EXERCISE 8 *)
(* TODO: pairing heaps are apparently efficient in practice, prove it. *)
type 'a t =
  | Empty
  | Heap of 'a * 'a t list

exception Error

let makeheap i = Heap (i, [])

let meld h1 h2 =
  match h1, h2 with
  | Empty, Empty -> Empty
  | Empty, h  | h, Empty -> h
  | Heap (i, xs), Heap (j, ys) ->
     if i < j then
       Heap (i, h2 :: xs)
     else
       Heap (j, h1 :: ys)

let insert h i = meld h (makeheap i)

let findmin = function
  | Empty -> raise Error
  | Heap (x, _) -> x

let deletemin = function
  | Empty -> raise Error
  | Heap (_, []) -> Empty
  | Heap (_, xs) -> List.fold_left meld Empty xs

(* TODO: is this idiomatic? is tail-call optimization possible? *)
let heapsort xs =
  let rec loop acc heap =
    try
      loop (findmin heap :: acc) (deletemin heap)
    with
      Error -> List.rev acc in
  loop [] (List.fold_left insert Empty xs)
