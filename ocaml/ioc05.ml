(* EXERCISE 3 *)
let nth i (x, y, z) =
  match i with
  | 1 -> `X x
  | 2 -> `Y y
  | 3 -> `Z z
  | _ -> raise (Invalid_argument "nth")

(* EXERCISE 4 *)
let db = [ "John", "x3456", 50.1
         ; "Jane", "x1234", 107.3
         ; "Joan", "unlisted", 12.7 ]

let find_salary (name: string) : float =
  let rec assoc database =
    match database with
    | [] -> raise Not_found
    | (n,e,s) :: t -> if n = name then s
                      else assoc t in
  assoc db

let select (pred: string * string * float -> bool)
    : (string * string * float) list =
  let rec loop = function
    | [] -> []
    | h :: t -> if pred h then h :: loop t else loop t in
  loop db

(* EXERCISE 7 *)
let append xs ys =
  let rec rev acc = function
    | [] -> acc
    | h :: t -> rev (h :: acc) t in
  rev ys (rev [] xs)

(* EXERCISE 8 *)
(* finds points of intersection in a pair of lists; doesn't take duplicates
 * into account, e.g. intersects [1; 1] [1; 1] = [1; 1] *)
let intersects xs ys =
  let rec loop acc = function
    | [], _ -> acc
    | _ :: t, [] -> loop acc (t, ys)
    | h1 :: t1, h2 :: t2 ->
       if h1 = h2 then
         loop (h1 :: acc) (t1, ys)
       else
         loop acc (h1::t1, t2) in
  loop [] (xs,ys)

let find_crooks paupers actors residents : string list =
  intersects (intersects paupers actors) (intersects actors residents)
