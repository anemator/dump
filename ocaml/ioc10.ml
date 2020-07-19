(* Exercise 10.1 *)
Printf.printf "Hello world\n"

(* Exercise 10.2 *)
let read_lines chan =
  let rec loop acc =
    let line = try Some (input_line chan) with End_of_file -> None in
    match line with
    | None -> acc
    | Some x -> loop (x :: acc) in
  loop [] |> List.rev

(* Exercise 10.3 *)
let with_in_file (filename: string) (oper: in_channel -> 'a) : 'a =
  let file = open_in filename in
  try oper file
  with exn -> close_in file; raise exn

(* Exercise 10.4 *)
let exchange a b =
  let read_char chan =
    if in_channel_length chan = 1
    then input_char chan
    else raise (Failure "read_char") in
  let process_in filename =
    let chan = open_in filename in
    let res =
      try read_char chan
      with Failure _ -> close_in chan;
                        raise (Failure "process") in
    close_in chan;
    res in
  let char_a, char_b = try process_in a, process_in b
                       with exn -> raise (Failure "exchange") in
  let chan_a = try open_out a
               with exn -> raise (Failure "exchange") in
  let chan_b = try open_out b
               with exn -> close_out chan_a;
                           raise (Failure "exchange") in
  (output_char chan_a char_b;
   output_char chan_b char_a;
   close_out chan_a;
   close_out chan_b)

(* Exercise 10.5 *)
type exp =
  | Int of int
  | Id of string
  | List of exp list

let print_exp expression =
  let rec loop = function
    | Int m -> string_of_int m
    | Id str -> str
    | List [] -> "()"
    | List (h :: t) ->
       let concat x y = Printf.sprintf "%s %s" x (loop y) in
       Printf.sprintf "(%s)" (List.fold_left concat (loop h) t) in
  loop expression |> print_endline

(* Exercise 10.6 #TODO*)

(* Exercise 10.7 *)
let pfunc (x, y, z) = Printf.printf "%-5s0x%.8x %3s\n" x y z

(* Exercise 10.8 *)
let print_cols xs =
  let rec get_max_widths acc = function
    | [] -> acc
    | (lcol, rcol) :: t ->
       let llen, rlen = String.length lcol, String.length rcol in
       get_max_widths (max llen (fst acc), max rlen (snd acc)) t in
  let lmax, rmax = get_max_widths (0, 0) xs in
  List.iter (fun (x,y) -> Printf.printf "%-*s %-*s\n" lmax x rmax y) xs
