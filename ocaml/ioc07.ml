(* 7.1.1 Value restriction *)
let x = ref None
(* val x : '_a option ref = {contents = None} *)

(* Since x is mutable, and None is part of a parameterized type, unspecified
 * at the moment, the type of x must be fixed after assignment, i.e.
 *
 * x := Some 1; x
 * - : int option ref = {contents = Some 1}
 * x := Some "string"
 * Error: This expression has type string but an expression was expected of type
 *          int *)

(* a function application is not a value and a mutable reference cell is not
 * a value => one_shot cannot be fully polymorphic. *)
let one_shot y =
  match !x with
  | None -> x := Some y;
            y
  | Some z -> z
(* val one_shot : '_a -> '_a = <fun> *)

(* 7.2 Queues *)
type 'a queue = ('a list * 'a list) ref

let create () : 'a queue = ref ([], [])

let add (queue: 'a queue) (x: 'a) : unit =
  let (front, back) = !queue in
  queue := (x :: front, back)

(* O(1) amortized in (front, []) *)
let rec take (queue: 'a queue) : 'a =
  match !queue with
  | [], [] -> raise (Invalid_argument "take: queue is empty")
  | front, [] -> queue := ([], List.rev front);
                   take queue
  | front, (x :: back) -> queue := (front, back);
                          x

(* 7.3 Doubly Linked Lists *)
type 'a elem =
  | Nil
  | Elem of 'a * 'a elem ref * 'a elem ref

let nil_elem : 'a elem = Nil

let create_elem (x: 'a) : 'a elem = Elem (x, ref Nil, ref Nil)

let get (x: 'a elem) : 'a =
  match x with
  | Nil -> raise (Invalid_argument "get")
  | Elem (v, _, _) -> v

let prev_elem (x: 'a elem) : 'a elem =
  match x with
  | Nil -> raise (Invalid_argument "prev_elem")
  | Elem (_, x', _) -> !x'

let next_elem (x: 'a elem) : 'a elem =
  match x with
  | Nil -> raise (Invalid_argument "next_elem")
  | Elem (_, _, x') -> !x'

type 'a dllist = 'a elem ref

let create () : 'a dllist = ref Nil

(* this differs slightly from Hickey's implementation in that it doesn't
 * assume the first node's prev elem is Nil, though it most likely is. *)
let insert (list: 'a dllist) (elem: 'a elem) : unit =
  match !list, elem with
  | _, Nil -> raise (Invalid_argument "insert")
  | Nil, Elem (_, p, n) -> p := Nil;
                           n := Nil;
                           list := elem
  | Elem (_, p1, _), Elem (_, p2, n2) -> p2 := !p1;
                                         p1 := elem;
                                         n2 := !list;
                                         list := elem

let remove (list: 'a dllist) (elem: 'a elem) : unit =
  match elem with
  | Nil -> raise (Invalid_argument "remove")
  | Elem (_, prev, next) ->
     (match !prev with
      | Nil -> list := !next
      | Elem (_, _, prev_next) -> prev_next := !next;
                                  list := !prev);
     (match !next with
      | Nil -> ()
      | Elem (_, next_prev, _) -> next_prev := !prev)

(* 7.4 Memoization *)

(* finds and returns f x if exists in the key-val list; evaluates, adds it to
 * the list otherwise *)
let memo (f: 'a -> 'b) : 'a -> 'b =
  let table = ref [] in
  let rec find_or_apply entries x =
    match entries with
    | (x', y) :: _ when x' = x -> y
    | _ :: entries -> find_or_apply entries x
    | [] -> let y = f x in
            table := (x, y) :: !table;
            y in
  (fun x -> find_or_apply !table x)

(* 7.5 Graphs -- TODO *)

(* Exercise 7.2 *)
type 'a deferred = (unit -> 'a) * 'a option ref

let defer (f: unit -> 'a) : 'a deferred = f, ref None

let force ((f, v): 'a deferred) : 'a =
  match !v with
  | Some x -> x
  | None -> let x = f () in
            v := Some x;
            x

(* Exercise 7.3 *)
type 'a lazy_list =
  | Nil
  | Cons of 'a * 'a lazy_list
  | LazyCons of 'a * 'a lazy_list deferred

let nil : 'a lazy_list = Nil

let cons (x: 'a) (xs: 'a lazy_list) : 'a lazy_list = Cons (x, xs)

let lazy_cons (x: 'a) (xs: unit -> 'a lazy_list) : 'a lazy_list =
  LazyCons (x, defer xs)

let is_nil (xs: 'a lazy_list) : bool = xs = nil

let head (xs: 'a lazy_list) : 'a =
  match xs with
  | Nil -> raise (Invalid_argument "head: empty list")
  | Cons (x, _) | LazyCons (x, _) -> x

let tail (xs: 'a lazy_list) : 'a lazy_list =
  match xs with
  | Nil -> raise (Invalid_argument "tail: empty list")
  | Cons (_, t) -> t
  | LazyCons (_, t) -> force t

(* constant time! *)
let rec ( @@ ) (xs: 'a lazy_list) (ys: 'a lazy_list) : 'a lazy_list =
  match xs with
  | Nil -> ys
  | Cons (h, t) -> LazyCons (h, defer (fun () -> t @@ ys))
  | LazyCons (h, t) -> LazyCons (h, defer (fun () -> force t @@ ys))

(* Exercise 7.4 *)
type 'a queue =
  | Empty
  | Cons of 'a * 'a queue

let empty : 'a queue = Empty

let add (q: 'a queue) (x: 'a) : 'a queue = Cons (x, q)

let rec take (q: 'a queue) : 'a * 'a queue =
  match q with
  | Empty -> raise (Invalid_argument "take")
  | Cons (h, Empty) -> h, Empty
  | Cons (h, t) -> let r = take t in
                   fst r, Cons (h, snd r)


type 'a queue = 'a list * 'a list

let empty : 'a queue = ([], [])

let add (xs, ys: 'a queue) (x: 'a) : 'a queue = (x :: xs, ys)

let take (xs, ys: 'a queue) : 'a * 'a queue =
  match ys with
  | [] -> let r = List.rev xs in
          List.hd r, ([], List.tl r)
  | h :: t -> h, (xs, ys)


(* #TODO: implement add/take in O(n) time *)
type 'a queue = 'a lazy_list * 'a lazy_list

(* Exercise 7.5 *)
type ('a, 'b) memo = ('a * 'b) list ref

let create_memo () : ('a, 'b) memo = ref []

let rec memo_find (f: ('a, 'b) memo) (a: 'a) : 'b option =
  match !f with
  | (x, y) :: t -> if a = x then Some y else memo_find (ref t) a
  | [] -> None

let memo_add (f: ('a, 'b) memo) (a: 'a) (b: 'b) : unit = f := (a, b) :: !f

let rec memo_fib (fib: (int, int) memo) (n: int) : int =
  match memo_find fib n with
  | None -> let res = if n = 0 then 0
                      else if n = 1 then 1
                      else memo_fib fib (n-1) + memo_fib fib (n-2) in
            memo_add fib n res;
            res
  | Some res -> res

let fib = memo_fib (create_memo ())

(* Exercise 7.6 #depth-first-search *)
type 'a vertex =
    (* Vertex (label, out-edges, dfs-mark, dfs-index) *)
    Vertex of 'a * 'a vertex list ref * bool ref * int option ref

type 'a directed_graph = 'a vertex list

type edge = Tree | Forward | Back | Cross

type 'a stack = 'a list ref

let create_stack () : 'a stack = ref []

let push (stack: 'a stack) (elem: 'a) : unit = stack := elem :: !stack

let pop (stack: 'a stack) : 'a =
  match !stack with
  | [] -> raise (Invalid_argument "pop_stack")
  | h :: t -> (stack := t;
               h)

let classify (Vertex (_, _, _, ui)) (Vertex (_, _, m, vi)) : edge =
  match !ui, !vi with
  | None, _ -> raise (Invalid_argument "classify")
  | _, None -> Tree
  | Some ui', Some vi' ->
     if ui' < vi' then Forward
     else if ui' > vi' then
       if !m then Back
       else Cross
     else raise (Invalid_argument "classify")

let dfsearch (g: 'a directed_graph) : unit =
  let mark (Vertex (_, vertices, m, i) as u) =
    let stack = create_stack () in
    if !m then
      ()
    else
      let c = ref 1 in
      (List.iter (fun v -> push stack (u, v)) !vertices;
       i := Some 0;
       try
         while true do
           let edge = pop stack in
           match classify (fst edge) (snd edge) with
           | Tree -> (let Vertex (_, ws, _, j) = snd edge in
                      j := Some !c;
                      c := !c + 1;
                      List.iter (fun w -> push stack (snd edge, w)) !ws)
           | Back -> () (* => graph is cyclic *)
           | Forward | Cross -> ()
         done;
       with
         Invalid_argument _ -> ());
      m := true in
  List.iter mark g

(* TODO: write tests *)

(* Exercise 7.7 -- TODO *)
type 'a vertex =
    (* Vertex (label, out-edges) *)
    Vertex of 'a * 'a vertex list ref

type 'a directed_graph = 'a vertex list
