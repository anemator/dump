(* EXERCISE 3 *)

(* this is actually tail recursive even though the call to loop does not
 * appear to be in the tail position; check with 'ocamlopt -annot' *)
let check s1 s2 =
  let swap = function
    | 'a' -> 'c'
    | 'b' -> 'a'
    | 'c' -> 'd'
    | 'd' -> 'b'
    | 'e' .. 'z' as c -> c
    | _ -> failwith "check: not a plaintext string"
  and rest s = String.sub s 1 (String.length s - 1) in
  let rec loop = function
    | "", "" -> true
    | _, "" | "", _ -> false
    | x, y -> (swap x.[0]) = y.[0] && loop ((rest x), (rest y)) in
  loop (s1, s2)
