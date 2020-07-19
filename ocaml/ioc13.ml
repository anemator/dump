(* Chapter 13: Functors *)
module type EQUAL =
sig
  type t
  val equal : t -> t -> bool
end

module MakeSet (Equal : EQUAL) = struct
  open Equal

  type elt = Equal.t
  type t = elt list

  let empty = []
  let mem x s = List.exists (equal x) s
  let add x s = x :: s
  let find x s = List.find (equal x) s
end

(* make implementation abstract *)
module MakeSet' (Equal : EQUAL) : sig
  type elt = Equal.t
  type t

  val empty : t
  val mem : elt -> t -> bool
  val add : elt -> t -> t
  val find : elt -> t -> elt
end = struct
  open Equal

  type elt = Equal.t
  type t = elt list

  let empty = []
  let mem x s = List.exists (equal x) s
  let add x s = x :: s
  let find x s = List.find (equal x) s
end

(* 13.1 Sharing constraints *)
module type SET =
sig
  type t
  type elt

  val empty : t
  val mem : elt -> t -> bool
  val add : elt -> t -> t
  val find : elt -> t -> elt
end

(* "with type ..." enriches elt in the signature, ie makes it concrete *)
module MakeSet (Equal : EQUAL) : SET with type elt = Equal.t =
struct
  open Equal
  type elt = Equal.t
  type t = elt list

  let empty = []
  let mem x s = List.exists (equal x) s
  let add x s = x :: s
  let find x s = List.find (equal x) s
end

module StringCaseEqual =
struct
  open String
  type t = string
  let equal x y = lowercase x = lowercase y
end

module SSet = MakeSet (StringCaseEqual)

(* 13.2 Module sharing constraints [for equating types] *)
module type SET =
sig
  module Equal : EQUAL

  type t
  type elt = Equal.t

  val empty : t
  val mem : elt -> t -> bool
  val add : elt -> t -> t
  val find : elt -> t -> elt
end

module MakeSet (Equal' : EQUAL) : SET with module Equal = Equal' =
struct
  open Equal'
  module Equal = Equal'
  type elt = Equal'.t
  type t = elt list

  let empty = []
  let mem x s = List.exists (equal x) s
  let add x s = x :: s
  let find x s = List.find (equal x) s
end

(* 13.3 Module re-use using functors *)
module type VALUE =
sig
  type value
end

module type MAP =
sig
  type t
  type key
  type value

  val empty : t
  val add : t -> key -> value -> t
  val find : t -> key -> value
end

module MakeMap (Equal : EQUAL) (Value : VALUE) : MAP
       with type key = Equal.t
       with type value = Value.value =
struct
  type key = Equal.t
  type value = Value.value
  type item =
    | Key of key
    | Pair of key * value

  module EqualItem =
    struct
      type t = item
      let equal (Key k1 | Pair (k1, _)) (Key k2 | Pair (k2, _)) =
        Equal.equal k1 k2
    end

  module Set = MakeSet (EqualItem)
  type t = Set.t

  let empty = Set.empty
  let add map key value = Set.add (Pair (key, value)) map
  let find map key =
    match Set.find (Key key) map with
    | Pair (_, value) -> value
    | Key _ -> raise (Invalid_argument "find")
end

(* 13.4 Higher-order functors #TODO *)
module MakeMap (Equal : EQUAL) (Value : VALUE)
               (MakeSet : functor (Equal : EQUAL) ->
                                  SET with type elt = Equal.t) : MAP
       with type key = Equal.t
       with type value = Value.value =
struct
  type key = Equal.t
  type value = Value.value
  type item =
    | Key of key
    | Pair of key * value

  module EqualItem =
    struct
      type t = item
      let equal (Key k1 | Pair (k1, _)) (Key k2 | Pair (k2, _)) =
        Equal.equal k1 k2
    end

  module Set = MakeSet (EqualItem)
  type t = Set.t

  let empty = Set.empty
  let add map key value = Set.add (Pair (key, value)) map
  let find map key =
    match Set.find (Key key) map with
    | Pair (_, value) -> value
    | Key _ -> raise (Invalid_argument "find")
end

(* 13.5 Recursive modules and functors #TODO *)
type 'set element =
  | Int of int
  | Set of 'set

module rec SetEqual : EQUAL with type t = Set.t element =
struct
  type t = Set.t element
  let equal = (=)
end
and Set : SET with type elt = SetEqual.t = MakeSet (SetEqual)

(* 13.6 A complete example #TODO *)
type comparison = LT | EQ | GT

module type COMPARE =
sig
  type t
  val compare : t -> t -> comparison
end

module type SET =
sig
  module Compare : COMPARE

  type t
  type elt = Compare.t

  val empty : t
  val add : elt -> t -> t
  val mem : elt -> t -> bool
  val find : elt -> t -> elt
  val compare : t -> t -> comparison
end

module MakeSet (Compare : COMPARE) : SET with module Compare = Compare =
struct
  module Compare = Compare

  type elt = Compare.t
  type color = Red | Black
  type t = Leaf | Node of color * elt * t * t

  let empty = Leaf

  let add x s =
    let rec insert = function
      | Leaf -> Node (Red, x, Leaf, Leaf)
      | Node (color, y, a, b) as s ->
         match Compare.compare x y with
         | LT -> balance (color, y, insert a, b)
         | GT -> balance (color, y, a, insert b)
         | EQ -> s in
    match insert s with
    | Node (_, y, a, b) -> Node (Black, y, a, b)
    | Leaf -> raise (Invalid_argument "insert")

  let mem x s =
    try
      ignore (find x s);
      true
    with
      Not_found -> false

  let rec find x = function
    | Leaf -> raise Not_found
    | Node (_, y, left, right) ->
       match Compare.compare x y with
       | LT -> find x left
       | GT -> find x right
       | EQ -> y

  let rec to_list l = function
    | Leaf -> l
    | Node (_, x, left, right) -> to_list (x :: to_list l right) left

  let rec compare_lists l1 l2 =
    match l1, l2 with
    | [], [] -> EQ
    | [], _ :: _ -> LT
    | _ :: _, [] -> GT
    | x1 :: t1, x2 :: t2 ->
       match Compare.compare x1 x2 with
       | EQ -> compare_lists t1 t2
       | LT | GT as cmp -> cmp

  let compare s1 s2 = compare_lists (to_list [] s1) (to_list [] s2)
end

type 'set element = Int of int | Set of 'set

module rec Compare : COMPARE with type t = Set.t element =
struct
  type t = Set.t element

  let compare x1 x2 =
    match x1, x2 with
    | Int i1, Int i2 -> if i1 < i2 then LT else if i1 > i2 then GT else EQ
    | Int _, Set _ -> LT
    | Set _, Int _ -> GT
    | Set s1, Set s2 -> Set.compare s1 s2
end
and Set : SET with module Compare = Compare = MakeSet (Compare)

(* Exercise 13.4-1 *)
type 'elt t = 'elt list
type 'elt set =
    { empty : 'elt t
    ; add : 'elt -> 'elt t -> 'elt t
    ; mem : 'elt -> 'elt t -> bool
    ; find : 'elt -> 'elt t -> 'elt }

let make_set equal =
  { empty = []
  ; add = (fun x xs -> x :: xs)
  ; mem = (fun x xs -> List.exists (equal x) xs)
  ; find = (fun x xs -> List.find (equal x) xs) }

(* doesn't work, can't hide implementation*)
type 'elt t
type 'elt set =
    { empty : 'elt t
    ; add : 'elt -> 'elt t -> 'elt t
    ; mem : 'elt -> 'elt t -> bool
    ; find : 'elt -> 'elt t -> 'elt }

let make_set equal =
  { empty = []
  ; add = (fun x xs -> x :: xs)
  ; mem = (fun x xs -> List.exists (equal x) xs)
  ; find = (fun x xs -> List.find (equal x) xs) }


(* Exercise 13.4-2 *)
type 'elt t = 'elt list
type 'elt set =
    { empty : 'elt t
    ; add : 'elt -> 'elt t -> 'elt t
    ; mem : 'elt -> 'elt t -> bool
    ; find : 'elt -> 'elt t -> 'elt }

let make_set equal =
  { empty = []
  ; add = (fun x xs -> x :: xs)
  ; mem = (fun x xs -> List.exists (equal x) xs)
  ; find = (fun x xs -> List.find (equal x) xs) }


type 'elt t = Nil | Cons of 'elt * 'elt t
type 'elt set =
    { empty : 'elt t
    ; add : 'elt -> 'elt t -> 'elt t
    ; mem : 'elt -> 'elt t -> bool
    ; find : 'elt -> 'elt t -> 'elt }


let make_set equal =
  let rec find f = function
    | Nil -> raise Not_found
    | Cons (x, xs) -> if f x then x else find f xs in
  let exists f xs =
    try
      find f xs;
      true
    with
      Not_found -> false in
  { empty = Nil
  ; add = (fun x xs -> Cons (x, xs))
  ; mem = (fun x xs -> exists (equal x) xs)
  ; find = (fun x xs -> find (equal x) xs) }

(* Exercise 13.4-3 *)
type ('elt, 't) set =
    { empty : 't
    ; add : 'elt -> 't -> 't    (* typo?: replaced 'elt with 't *)
    ; mem : 'elt -> 't -> bool
    ; find : 'elt -> 't -> 'elt }

let make_set equal =
  { empty = []
  ; add = (fun x xs -> x :: xs)
  ; mem = (fun x xs -> List.exists (equal x) xs)
  ; find = (fun x xs -> List.find (equal x) xs) }

(* Exercise 13.5 *)
module type FSig =
sig
  val f : int -> int
end

module type GSig =
sig
  val g : int -> int
end

module rec F : FSig =
struct
  let f = G.g
end

and G : GSig =
struct
  let g = F.f
end

(* Exercise 13.6 *)
module type Pipeline =
sig
  type t
  val f : t -> unit
end

module type Filter = functor (P : Pipeline) -> Pipeline

module Print =
struct
  type t = string
  let f s = print_string s;
            print_char '\n'
end

module Cat (Stdout : Pipeline with type t = string) =
struct
  type t = string

  let f filename =
    let fin = open_in filename in
    try
      while true do
        Stdout.f (input_line fin)
      done
    with
      End_of_file -> close_in fin
end

module CatFile = Cat(Print)

(* Exercise 13.6-1 *)
module Uniq (Stdout : Pipeline with type t = string) : Pipeline
       with type t = string list =
struct
  type t = string list

  let rec f = function
    | x :: x' :: xs ->
       if x = x' then
         f (x' :: xs)
       else
         (Stdout.f x;
          f (x' :: xs))
    | [] -> ()
    | [x] -> Stdout.f x
end

module UniqPrint = Uniq(Print)

(* Exercise 13.6-2 *)
#load "str.cma"                 (* or(?) #require "str" *)

module Grep (Stdout : Pipeline with type t = string) : Pipeline
       with type t = string * string list =
struct
  type t = string * string list

  let f (str, xs) =
    let regex = Str.regexp str in
    let rec loop = function
    | [] -> ()
    | h :: t ->
       if Str.string_match regex h 0 then
         Stdout.f h;
       loop t in
    loop xs
end

module GrepPrint = Grep(Print)

(* Exercise 13.6-3 *)
let grep regex filename =
  let fin = open_in filename in
  let rec loop acc =
    let res =
      try
        Some (input_line fin :: acc)
      with
        End_of_file -> close_in fin;
                       None in
    match res with
    | None -> acc
    | Some x -> loop x in
  GrepPrint.f (regex, loop [])

(* Exercise 13.6-4 *)
module Lowercase (Stdout : Pipeline with type t = char) =
struct
  type t = char
  let f x = Stdout.f (Char.lowercase x)
end

module StringOfChar (P : Pipeline with type t = char) : Pipeline
       with type t = string =
struct
  type t = string

  let f x = String.iter P.f x
end

module Char =
struct
  type t = char

  let f x = print_char x
end

module PrintChars = StringOfChar(Char)

(* Exercise 13.6-5 #TODO: this isn't right *)
module Compose (F1 : Filter) (F2 : Filter) (P : Pipeline) = F1 (F2 (P))
