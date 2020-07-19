(* https://bernsteinbear.com/blog/lisp/ *)
type stream =
  { mutable line_num: int
  ; mutable chr: char list
  ; chan: in_channel
  }

let read_char stream =
  match stream.chr with
  | [] ->
    let ch = input_char stream.chan in
    if ch = '\n' then
      stream.line_num <- stream.line_num + 1;
    ch
  | ch::rest ->
    stream.chr <- rest;
    ch

let unread_char stream ch =
  stream.chr <- ch :: stream.chr

let is_white = function
  | ' ' | '\t' | '\n' -> true
  | _ -> false

let rec eat_whitespace stream =
  let ch = read_char stream in
  if is_white ch then
    eat_whitespace stream
  else
    unread_char stream ch

type lobject =
  | Boolean of bool
  | FixNum of int
  | Symbol of string

exception SyntaxError of string

let string_of_char ch =
  String.make 1 ch

let read_sexp stream =
  let is_digit = function
    | '0' .. '9' -> true
    | _ -> false
  in
  let rec read_fixnum acc =
    let nc = read_char stream in
    if is_digit nc then
      read_fixnum (acc ^ (Char.escaped nc))
    else
      (unread_char stream nc;
       FixNum (int_of_string acc))
  in
  let is_symstartchar ch =
    let isalpha = function
      | 'A' .. 'Z' | 'a' .. 'z' -> true
      | _ -> false
    in
    match ch with
    | '*' | '/' | '>' | '<' | '=' | '?' | '!' | '-' | '+' -> true
    | ch -> isalpha ch
  in
  let rec read_symbol () =
    let literal_quote = '"' in
    let is_delimiter = function
      | '(' | ')' | '{' | '}' | ';' -> true
      | ch -> ch = literal_quote || is_white ch
    in
    let nc = read_char stream in
    if is_delimiter nc then
      (unread_char stream nc;
       "")
    else
      string_of_char nc ^ read_symbol ()
  in
  eat_whitespace stream;
  let ch = read_char stream in
  if is_symstartchar ch then
    Symbol (string_of_char ch ^ read_symbol ())
  else if is_digit ch || ch = '~' then
    read_fixnum (Char.escaped (if ch = '~' then '-' else ch))
  else if ch = '#' then
    match (read_char stream) with
    | 't' -> Boolean true
    | 'f' -> Boolean false
    | ch -> raise (SyntaxError ("Invalid boolean literal "
                                ^ (Char.escaped ch)))
  else
    raise (SyntaxError ("Unexpected char " ^ (Char.escaped ch)))

let print_sexp = function
  | Boolean v -> print_string (if v then "#t" else "#f")
  | FixNum v -> print_int v
  | Symbol v -> print_string v

let rec repl stream =
  print_string "> ";
  flush stdout;
  let sexp = read_sexp stream in
  print_sexp sexp;
  print_newline ();
  repl stream

let main =
  let stream = { chr=[]; line_num=1; chan=stdin } in
  repl stream
