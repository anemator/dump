(** circular list *)
type 'a t = 'a list * 'a * 'a list

(** Shifts the list's one position forward *)
let rec next (l, x, r as xs) : 'a t =
  match l, r with
  | [], [] -> xs
  | y::_ as ys, [] ->
    let rec loop acc = function
      | [] -> assert false
      | [x] -> x, acc
      | x::xs -> loop (x::acc) xs in
    let x', r' = loop [x] ys in
    ([], x', r')
  | _, y::ys -> (x::l, y, ys)

let size (l, _, r) =
  1 + List.(length l + length r)


(** Creates a group of [[number]] people *)
let create number : int t =
  let rec loop acc n =
    if n = 1 then acc
    else loop (n :: acc) (n-1) in
  ([], 1, loop [] number)

(** Kills every [[step]] person in [[group]] until only [[stop]] are left *)
let destroy ?(step=3) ?(stop=1) group : int t =
  let rec remove left (l, c, r as group) =
    if left > 1 then remove (left-1) (next group)
    else
    match l, r with
    | [], [] -> assert false
    | _::_, [] ->
      let rec loop acc = function
        | [] -> assert false
        | [x] -> ([], x, acc)
        | x::xs -> loop (x::acc) xs in
      loop [] l
    | xs, y::ys -> (xs, y, ys) in
  let rec loop group =
    if size group = stop then group
    else loop (remove step group) in
  loop group

let () =
  let people = create 40 in
  match destroy people with
  | [], x, [] -> Printf.printf "Person %d survived :(\n" x
  | _ -> assert false
