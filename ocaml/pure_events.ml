module One = struct
  let () = print_endline "==Immutable Trade Events=="

  type state = High of int
  type event = state -> state

  let on_trade price (High h) =
    if price > h then High price else High h

  let rec loop state events =
    match events with
    | [] -> state
    | f :: tl -> loop (f state) tl

let () =
  let events = [on_trade 5; on_trade 2; on_trade 10; on_trade 5] in
  let High result = loop (High 0) events in
  Printf.printf "Result: %d\n" result
end

module Two = struct
  let () = print_endline "==RPN Calculator=="

  type domain = Domain of int

  type event = EventAdd of int
             | EventSub of int
             | EventMul of int
             | EventDiv of int
             | EventExit

  let dmUpdate (Domain d) = function
    | EventAdd v -> Domain (d+v)
    | EventSub v -> Domain (d-v)
    | EventMul v -> Domain (d*v)
    | EventDiv v -> Domain (d/v)
    | EventExit  -> Domain d

  let parseLn l =
    let v = Char.escaped l.[1] |> int_of_string in
    match l.[0] with
    | '+' -> EventAdd v
    | '-' -> EventSub v
    | '*' -> EventMul v
    | '/' -> EventDiv v
    | _   -> EventExit

  let rec uiUpdate (Domain d) =
    Printf.printf "Result: %d\n" d;
    let line =
      try read_line ()
      with End_of_file -> exit 0 in
    parseLn line
    |> dmUpdate (Domain d)
    |> uiUpdate

  let () = 
    print_endline "e.g. +1<CR> -2<CR> ...";
    uiUpdate (Domain 0)
end
