type ('a, 'b) result = Ok of 'a | Error of 'b
let rec ( -- ) a b = if a > b then [] else a :: (a+1 -- b)
let _TODO = let exception TODO in fun () -> raise TODO

module Ship = struct
  type id = int
  type status = Hit | Ready
  type kind = Carrier | Battleship | Cruiser | Submarine | Destroyer
  type t = id * status * kind

  let size = function
    | Carrier -> 5
    | Battleship -> 4
    | Cruiser -> 3
    | Submarine -> 3
    | Destroyer -> 2
end

module Board : sig
  type place = char * int
  type t
  val add_ship : kind:Ship.kind -> p1:place -> p2:place -> t ->
    (t, [> `Conflict | `InvalidMove | `InvalidShip ]) result
  val attack : place:place -> t -> [> `Hit | `Invalid | `Miss ] * t
  val empty : t
  (* val get_ships : t -> (Ship.kind * place list) list *)
end = struct
  type place = char * int
  module Places = Map.Make(struct
      type t = place
      let compare = compare (* TODO fix polymorphic comparison *)
    end)
  type t = { max_id: Ship.id; places: Ship.t Places.t }

  let empty = { max_id=0; places=Places.empty }

  (* let get_ships { places; _ } = *)
  (*   _TODO() *)

  let valid (row,col) =
    col > 0 && col <= 10 && match row with
    | 'A' .. 'J' -> true
    | _ -> false

  let add_ship =
    let map2 f x y = f x, f y in
    let row_to_int ch = int_of_char ch - int_of_char 'A' in
    let row_to_char n = n + int_of_char 'A' |> char_of_int in
    let occupied ~path ~places = List.fold_left (fun acc place ->
        acc || Places.mem place places) false path
    in
    let gen_path ~f ~kind p1 p2 =
      let p1, p2 = if p1 < p2 then p1, p2 else p2, p1 in
      if Ship.size kind <> p2 - p1 + 1 then Error `InvalidShip else
        Ok (List.fold_right (fun p acc -> f p :: acc) (p1 -- p2) [])
    in
    let add ~kind ~path ~board:{max_id; places} =
      if occupied ~path ~places then Error `Conflict else
      let max_id = max_id + 1 in
      let ship = (max_id, Ship.Ready, kind) in
      let places = List.fold_left (fun places ((_r,_c) as place) ->
          (* Printf.printf "%c,%d\n" r c; *)
          Places.add place ship places) places path in
      Ok { max_id; places }
    in
    fun ~kind ~p1:(r1,c1) ~p2:(r2,c2) board ->
      match r1 = r2, c1 = c2 with
      | true, true | false, false -> Error `InvalidMove
      | true, false ->
        (match gen_path ~f:(fun c -> r1, c) ~kind c1 c2 with
         | Error _ as err -> err
         | Ok path -> add ~kind ~path ~board)
      | false, true ->
        let r1, r2 = map2 row_to_int r1 r2 in
        (match gen_path ~f:(fun r -> row_to_char r, c1) ~kind r1 r2 with
         | Error _ as err -> err
         | Ok path -> add ~kind ~path ~board)

  let attack ~place ({places; _} as board) =
    if not @@ valid place then `Invalid, board
    else match Places.find_opt place places with
      | None -> `Miss, board
      | Some (id, _status, kind) ->
        let ship = (id, Ship.Hit, kind) in
        let places = Places.(remove place places |> add place ship) in
        `Hit, { board with places }
end

let () =
  ()
