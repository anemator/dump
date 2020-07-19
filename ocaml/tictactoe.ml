(* Generate a list [m, n) *)
let ( -- ) m n =
  let rec loop acc m =
    if m = n then List.rev acc
    else loop (m::acc) (m+1) in
  loop [] m

let get_int str =
  let rec get str =
    print_string str;
    try read_int ()
    with
    | Failure err ->
      ("Error <<" ^ err ^ ">>...try again" |> print_endline;
       get str)
    | End_of_file ->
      (print_newline ();
       exit 0)
  in
  get str

module MakeLimitedInt(Limits: sig val min: int val max: int end) : sig
  type t
  include module type of Limits
  val create : int -> t option
  val get : t -> int
  val offset : n:int -> t -> t option
end = struct
  type t = { min: int; n: int; max: int }
  include Limits

  let is_valid n = min <= n && n <= max

  let create n =
    if is_valid n then Some {min; n; max} else None

  let get t = t.n

  let offset ~n t = create (t.n + n)
end
module Num = MakeLimitedInt(struct let min = 3 let max = 10 end)

module Game : sig
  val start : dim:Num.t -> unit
end = struct
  type piece = X | O

  let string_of_piece = function
    | X -> "X"
    | O -> "O"

  let print_piece piece =
    "Piece " ^ (string_of_piece piece) |> print_endline

  let rec print_list print = function
    | [] -> print_newline ()
    | hd :: tl ->
      print hd;
      print_char ' ';
      print_list print tl

  type position = {row: int; col: int}
  module Moves = Set.Make(struct
      type t = position
      let compare = compare
    end)

  type board = { x: Moves.t; o: Moves.t; dim: int }

  type 'a result = OutOfBounds | InUse | Ok of 'a

  let move ~row ~col ~piece ~board =
    let { x; o; dim } = board in
    if row < 0 || row >= dim || col < 0 || col >= dim then OutOfBounds
    else
    let point = {row; col} in
    if Moves.(mem point x || mem point o) then InUse
    else
    match piece with
    | X -> Ok { board with x=Moves.add point x }
    | O -> Ok { board with o=Moves.add point o }

  (* TODO: fix output when board size is > 10 *)
  let print_board { x; o; dim } =
    for row = 0 to dim-1 do
      for col = 0 to dim-1 do
        if Moves.mem {row; col} x then print_string "X "
        else if Moves.mem {row; col} o then print_string "O "
        else print_string "- "
      done;
      print_int row;
      print_newline ()
    done;
    print_list print_int (0 -- dim)

  let is_draw ~board =
    let { x; o; dim } = board in
    Moves.(cardinal x + cardinal o) = dim * dim

  let is_winner ~board ~piece =
    let { x; o; dim } = board in
    let is_winner board =
      let rec check_path f ({row; col} as point) last =
        if point = last then true
        else if Moves.mem point board then check_path f (f row col) last
        else false in
      let shift row_n col_n = fun row col -> {row=row + row_n; col=col + col_n} in
      let check_row row = check_path (shift 0 1) {row; col=0} {row; col=dim} in
      let check_col col = check_path (shift 1 0) {row=0; col} {row=dim; col}
      in
      List.exists check_row (0 -- dim)
      || List.exists check_col (0 -- dim)
      || check_path (shift 1 1) {row=0; col=0} {row=dim; col=dim}
      || check_path (shift (-1) 1) {row=dim-1; col=0} {row=(-1); col=dim}
    in
    is_winner (if piece = X then x else o)

  let start ~dim =
    let rec loop board piece =
      let print_board_and board print item =
        print_newline ();
        print_board board;
        print item
      in
      print_board_and board print_piece piece;
      let row = get_int "row? " in
      let col = get_int "col? " in
      match move ~row ~col ~piece ~board with
      | OutOfBounds ->
        print_endline "Warning out of bounds...try again";
        loop board piece
      | InUse ->
        print_endline "Warning point in use...try again";
        loop board piece
      | Ok board ->
        if is_winner ~board ~piece then
          (print_board_and board print_endline (string_of_piece piece ^ " WON!");
           exit 0)
        else if is_draw ~board then
          (print_board_and board print_endline "DRAW!";
           exit 0)
        else
          loop board (if piece = X then O else X)
    in
    loop { x=Moves.empty; o=Moves.empty; dim=Num.get dim } X
end

let () =
  let rec get_dim () =
    let output =
      let min, max = Num.(min, Num.max) in
      Printf.sprintf "board dimensions (min = %d, max = %d)? " min max in
    match Num.create (get_int output) with
    | None -> get_dim ()
    | Some num -> num
  in
  Game.start ~dim:(get_dim ())
