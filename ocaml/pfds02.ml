(* 2.1 lISTS ***********************************************************)
module type STACK = sig
  type 'a stack

  exception Empty
  exception Subscript

  val empty: 'a stack
  val is_empty: 'a stack -> bool

  val cons: 'a * 'a stack -> 'a stack
  val head: 'a stack -> 'a
  val tail: 'a stack -> 'a stack

  val concat: 'a stack -> 'a stack -> 'a stack
  val update: 'a stack * int * 'a -> 'a stack
end

module List: STACK = struct
  type 'a stack = 'a list

  exception Empty
  exception Subscript

  let empty = []
  let is_empty = function
    | [] -> true
    | _  -> false

  let cons (x,xs) = x :: xs
  let head = function
    | [] -> raise Empty
    | x::_ -> x
  let tail = function
    | [] -> raise Empty
    | _::xs -> xs

  let rec concat xs ys = match xs with
    | [] -> ys
    | h::t -> h :: concat t ys
  let rec update = function
    | ([],_,_) -> raise Subscript
    | (_::t,0,y) -> y :: t
    | (h::t,i,y) -> h :: update (t,i-1,y)
end

module CustomStack: STACK = struct
  type 'a stack = Nil | Cons of 'a * 'a stack

  exception Empty
  exception Subscript

  let empty = Nil
  let is_empty = function
    | Nil -> true
    | _ -> false

  let cons (x,xs) = Cons (x,xs)
  let head = function
    | Nil -> raise Empty
    | Cons (x,xs) -> x
  let tail = function
    | Nil -> raise Empty
    | Cons (x,xs) -> xs

  let rec concat xs ys = match xs with
    | Nil -> ys
    | Cons (h,t) -> Cons (h,concat t ys)
  let rec update = function
    | (Nil,_,_) -> raise Subscript
    | (Cons (_,t),0,y) -> Cons(y,t)
    | (Cons (h,t),i,y) -> Cons(h,update (t,i-1,y))
end

(* EXERCISE 2.1 *)
let rec suffixes (xs: 'a list): 'a list list = match xs with
    [] -> [[]]
  | h :: t -> (h :: t) :: suffixes t

(* tail recursive *)
let rev xs =
  let rec loop acc = function
    | [] -> acc
    | h::t -> loop (h::acc) t in
  loop [] xs

let suffixes (xs: 'a list): 'a list list =
  let rec aux acc = function
    | [] -> [] :: acc
    | h :: t -> aux ((h::t) :: acc) t
  in aux [] xs |> rev
;;

(* REMARKS
 * - Note the use of inner parens in the recursive call to aux, this is
 *   necessary because cons is right associative; if we try h :: t :: acc, ie
 *   its natural associative order, it will not pass the type checker because
 *   a :: 'a list list doesn't make sense.
 * - For the linear recursive method on a list of size n, there are n calls
 *   to suffixes and 2n calls to :: for a total running time of 3n = O(n)
 *   and the space required is 2n. For the tail call, space is constant,
 *   but running time is n=O(n) not including the call to rev which is most
 *   likely linear as well, i.e. the tail call has O(n) running time. *)

(* TESTS *)
suffixes [1; 2; 3; 4] = [[1; 2; 3; 4]; [2; 3; 4]; [3; 4]; [4]; []]

(* 2.2 BINARY SEARCH TREES *********************************************)
module type SET = sig
  type elem
  type set

  val empty: set
  val insert: elem * set -> set
  val member: elem * set -> bool
end

module type ORDERED = sig
  type t

  val eq: t * t -> bool
  val lt: t * t -> bool
  val leq: t * t -> bool
end

(* functor *)
module UnbalancedSet (Element: ORDERED): SET = struct
  type elem = Element.t
  type tree = E | T of tree * elem * tree
  type set = tree

  let empty = E

  let rec member = function
    | (_,E) -> false
    | (x,T (a,y,b)) ->
      if Element.lt (x,y) then member (x,a)
      else if Element.lt (y,x) then member (x,b)
      else true

  let rec insert = function
    | (x,E) -> T (E,x,E)
    | (x,T (a,y,b)) ->
      if Element.lt (x,y) then T (insert (x,a),y,b)
      else if Element.lt (y,x) then T (a,y,insert (x,b))
      else T (a,y,b)
end

(* EXERCISE 2.2 *)
module FastSet (Element: ORDERED): SET with type elem = Element.t = struct
  type elem = Element.t
  type tree = E | T of tree * elem * tree
  type set = tree

  let empty = E

  let member (e,t) = match t with
    | E -> false
    | T (_,root,_) ->
      let rec aux cand = function
    | E -> Element.eq (cand,e) || false
    | T (a,y,b) -> if Element.leq (e,y) then aux y a else aux cand b in
      aux root t

  let rec insert = function
    | (x,E) -> T (E,x,E)
    | (x,T (a,y,b)) ->
      if Element.lt (x,y) then T (insert (x,a),y,b)
      else if Element.lt (y,x) then T (a,y,insert (x,b))
      else T (a,y,b)
end

(* TESTS *)
module IntNaturalOrder: ORDERED with type t = int = struct
  type t = int

  let eq (a,b) = a = b
  let lt (a,b) = a < b
  let leq (a,b) = a <= b
end

module IntSet = FastSet(IntNaturalOrder)

let one_set = IntSet.insert (1,IntSet.empty)
let two_set = IntSet.insert (2,one_set)
let three_set = IntSet.insert (4,two_set)
;;

IntSet.member (1,one_set);;
not (IntSet.member (2,one_set));;
IntSet.member (1,two_set);;
IntSet.member (2,two_set);;
not (IntSet.member (3,three_set));;
IntSet.member (4,three_set);;

(* EXERCISE 2.3 *)
module ExceptionSet (Element: ORDERED): SET with type elem = Element.t = struct
  type elem = Element.t
  type tree = E | T of tree * elem * tree
  type set = tree

  let empty = E

  let rec member = function
    | (_,E) -> false
    | (x,T (a,y,b)) ->
      if Element.lt (x,y) then member (x,a)
      else if Element.lt (y,x) then member (x,b)
      else true

  let rec insert = function
    | (x,E) -> T (E,x,E)
    | (x,T (a,y,b)) ->
      if Element.lt (x,y) then T (insert (x,a),y,b)
      else if Element.lt (y,x) then T (a,y,insert (x,b))
      else failwith "insert: element already exists"
end

(* TESTS *)
module IntNaturalOrder: ORDERED with type t = int = struct
  type t = int

  let eq (a,b) = a = b
  let lt (a,b) = a < b
  let leq (a,b) = a <= b
end

module IntSet = ExceptionSet(IntNaturalOrder)

let one_set = IntSet.insert (1,IntSet.empty)
let two_set = IntSet.insert (2,one_set)
let three_set = IntSet.insert (4,two_set)

(* TODO
try let _ = IntSet.insert (1,one_set) in false with Failure _ -> true;;
IntSet.member (2,IntSet.insert (2,one_set));;
try let _ = IntSet.insert (1,two_set) in false with Failure _ -> true;;
try let _ = IntSet.insert (2,two_set) in false with Failure _ -> true;;
IntSet.member (3,IntSet.insert (3,three_set));;
try let _ = IntSet.insert (4,three_set) in false with Failure _ -> true;;
*)

(* EXERCISE 2.4 *)
module FastSet (Element: ORDERED): SET with type elem = Element.t = struct
  type elem = Element.t
  type tree = E | T of tree * elem * tree
  type set = tree

  let empty = E

  let member (e,t) = match t with
    | E -> false
    | T (_,root,_) ->
      let rec aux cand = function
    | E -> Element.eq (cand,e) || false
    | T (a,y,b) -> if Element.leq (e,y) then aux y a else aux cand b in
      aux root t

  let insert (e,t) = match t with
    | E -> T (E,e,E)
    | T (_,root,_) ->
      let rec aux cand = function
    | E ->
      if Element.eq (cand,e) then
        failwith "insert: element already exists"
      else
        T (E,e,E)
    | T (a,y,b) ->
      if Element.leq (e,y) then
        T (aux y a, y, b)
      else
        T (a, y, aux cand b) in
      aux root t
end

(* TESTS *)
module IntNaturalOrder: ORDERED with type t = int = struct
  type t = int

  let eq (a,b) = a = b
  let lt (a,b) = a < b
  let leq (a,b) = a <= b
end

module IntSet = FastSet(IntNaturalOrder)

let one_set = IntSet.insert (1,IntSet.empty)
let two_set = IntSet.insert (2,one_set)
let three_set = IntSet.insert (4,two_set)

(* TODO
try let _ = IntSet.insert (1,one_set) in false with Failure _ -> true;;
IntSet.member (2,IntSet.insert (2,one_set));;
try let _ = IntSet.insert (1,two_set) in false with Failure _ -> true;;
try let _ = IntSet.insert (2,two_set) in false with Failure _ -> true;;
IntSet.member (3,IntSet.insert (3,three_set));;
try let _ = IntSet.insert (4,three_set) in false with Failure _ -> true;;
*)

(* EXERCISE 2.5 *)
module type TREE = sig
  type 'a node = Empty | Node of 'a node * 'a * 'a node

  val complete: 'a * int -> 'a node
end

module CompletionTree = struct
  type 'a node = Empty | Node of 'a node * 'a * 'a node

  let rec complete (x,d) = match d with
    | 0 -> Empty
    | _ -> let child = complete (x,(d-1)) in Node (child,x,child)

  let balance (x,size) =
    if size < 1 then
      failwith "balance: invalid size"
    else
      let leaf = Node (Empty,x,Empty) in
      let rec aux = function
    | 0 -> Empty
    | 1 -> leaf
    | m ->
      let child = aux (m/2) in
      if m mod 2 = 0 then
        Node (child,x,aux (m/2-1))
      else
        Node (child,x,child) in
      aux size
end

(* TODO
let open Core_bench.Std.Bench in
[ Test.create ~name:"complete 100" (fun () ->
  ignore (CompletionTree.complete (`x,100)))
; Test.create ~name:"complete 1000" (fun () ->
  ignore (CompletionTree.complete (`x,1000)))
; Test.create ~name:"complete 10000" (fun () ->
  ignore (CompletionTree.complete (`x,10000))) ]
|> bench

(* TODO: Determine why balance is not within O(log n) time *)
let open Core_bench.Std.Bench in
[ Test.create ~name:"balance 100" (fun () ->
  ignore (CompletionTree.balance (`x,1024)))
; Test.create ~name:"balance 1000" (fun () ->
  ignore (CompletionTree.balance (`x,8192)))
; Test.create ~name:"balance 10000" (fun () ->
  ignore (CompletionTree.balance (`x,65536))) ]
|> bench
*)

(* EXERCISE 2.6 *)
module type FINITEMAP = sig
  type key
  type 'a map

  exception NotFound

  val empty: 'a map
  val bind: key * 'a * 'a map -> 'a map
  val lookup: key * 'a map -> 'a (* raise NotFound if key is not found *)
end

module UnbalancedSet (Element: ORDERED): FINITEMAP with type key = Element.t =
struct
  type key = Element.t
  type 'a tree = Empty | Node of 'a tree * key * 'a * 'a tree
  type 'a map = 'a tree

  exception NotFound

  let empty = Empty

  let rec bind (k,v,d) = match d with
    | Empty -> Node (Empty,k,v,Empty)
    | Node (left,k',v',right) ->
      if Element.eq (k,k') then Node (left,k,v,right)
      else if Element.lt (k,k') then Node (bind (k,v,left),k',v',right)
      else Node (left,k',v',bind (k,v,right))

  let rec lookup (k,d) = match d with
    | Empty -> raise NotFound
    | Node (Empty,k',v',Empty) -> if k = k' then v' else raise NotFound
    | Node (left,k',v',right) ->
      if Element.eq (k,k') then v'
      else if Element.lt (k,k') then lookup (k,left)
      else lookup (k,right)
end

module IntNaturalOrder: ORDERED with type t = int =
struct
  type t = int

  let eq (a,b) = a = b
  let lt (a,b) = a < b
  let leq (a,b) = a <= b
end

module IntMap = UnbalancedSet(IntNaturalOrder)
