(* 9.3.3 Unwind-protect (#finally) *)
type 'a result =
  | Success of 'a
  | Failed of exn

let finally f x cleanup =
  let res =
    try Success (f x) with
    | exn -> Failed exn in
  cleanup ();
  match res with
  | Success y -> y
  | Failed exn -> raise exn

let process_file file_name =
  let in_channel = open_in file_name in
  finally (fun x -> ()) in_channel (fun () -> close_in in_channel)

(* 9.3.4 The exn type
 * - they are open similar to poplymorphic variants
 * - exception matching is not required to be exhaustive *)
exception String of string
exception Int of int

let succ xs =
  List.map (function
             | Int i -> Int (i + 1)
             | x -> x)
           xs

(* # succ [Int 1; String "b"]
 * -: exn list = [Int(2); String("b")] *)

exception Float of float

let succ_f xs =
  List.map (function
             | Float x -> Float (x +. 1.0)
             | x -> x)
           xs

(* # succ_f [Int 1; String "b"; Float 3.]
 * -: exn list = [Int(1); String("b"); Float(4.)] *)

(* Exercise 9.5 *)
let input_lines () =
  let rec loop acc =
    try
      loop (input_line stdin :: acc)
    with
      End_of_file -> acc in
  loop []
