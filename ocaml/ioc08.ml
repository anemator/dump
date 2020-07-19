(* 8.4 Hash Tables *)

let random_length = 2. ** 10.
                  |> int_of_float

let random_numbers =
  Random.self_init ();
  let max = 2. ** 16. |> int_of_float in
  let rec loop len acc =
    match len with
    | 0 -> acc
    | i -> loop (i-1) (Random.int max :: acc) in
  Array.of_list (loop random_length [])

type hash_info = { mutable hash_index : int; mutable hash_value : int }

(* s-box (substitution-box) hash *)
let hash_char info c =
  let i = Char.code c in
  let index = (info.hash_index + i + 1) mod random_length in
  info.hash_value <- (info.hash_value * 3) lxor random_numbers.(index);
  info.hash_index <- index

let hash s =
  let info = { hash_index = 0; hash_value = 0 } in
  for i = 0 to String.length s - 1 do
    hash_char info s.[i]
  done;
  info.hash_value

type 'a hash_entry = { key: 'a; value: 'a }
type 'a hash_table = 'a hash_entry list array (* buckets *)

(* create: unit -> 'a hash_table *)
let create () = Array.create 101 []

(* add: 'a hash_table -> string -> 'a -> unit *)
let add table key value =
  let index = (hash key) mod (Array.length table) in
  table.(index) <- { key = key; value = value } :: table.(index)

(* find: 'a hash_table -> string -> 'a *)
let rec find_entry key = function
  | { key = key'; value = value } :: _ when key' = key -> value
  | _ :: entries -> find_entry key entries
  | [] -> raise Not_found

let find table key =
  let index = (hash key) mod (Array.length table) in
  find_entry key table.(index)


(* Exercise 8.1 *)
type 'a ref = { mutable contents: 'a }

(* ref: 'a -> 'a ref *)
let ref x = { contents = x }

(* ( ! ): 'a ref -> 'a *)
let ( ! ) { contents } = contents

(* ( := ): 'a ref -> 'a -> unit *)
let ( := ) old_val new_val = old_val.contents <- new_val


(* Exercise 8.3 *)
type ('key, 'value) dictionary =
    { insert: 'key -> 'value -> ('key, 'value) dictionary
    ; find: 'key -> 'value }

(* using slists *)
let empty : ('key, 'value) dictionary =
  let rec find kvs k =
    match kvs with
    | [] -> raise Not_found
    | (k', v') :: _ when k = k' -> v'
    | _ :: t -> find t k in
  let rec insert kvs k v =
    let ckvs = (k, v) :: kvs in
    { insert = insert ckvs; find = find ckvs } in
  let kvs = [] in
  { insert = insert kvs; find = find kvs}

(* #TODO: write using nested records/functions *)

(* Exercise 8.5 *)
let string_reverse str =
  let len = String.length str in
  let j = ref (len - 1) in
  for i = 0 to len / 2 - 1 do
    let c = str.[i] in
    str.[i] <- str.[!j];
    str.[!j] <- c;
    j := !j - 1
  done

(* Exercise 8.7 *)
let isort arr =
  let insert i =
    let x = arr.(i) in
    let j = ref i in
    (while !j > 0 && x < arr.(!j - 1) do
       arr.(!j) <- arr.(!j - 1);
       j := !j - 1
     done;
     arr.(!j) <- x) in
  for i = 1 to Array.length arr - 1 do
    insert i
  done
