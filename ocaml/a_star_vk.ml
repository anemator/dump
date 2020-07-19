(* Keith's version of A* in OCaml: https://youtu.be/ThbtUN4jOF0 *)
type point = int * int

module Grid : sig
  type node = Vacant of point | Filled of point
  type t

  val at : row:int -> col:int -> grid:t -> node option

  val ofCoords : rows:int -> cols:int -> xs:(point list) -> t option

end = struct
  type node = Vacant of point | Filled of point
  type t = node array array

  let at ~row ~col ~grid =
    try Some grid.(row).(col)
    with _ -> None

  let ofCoords ~rows ~cols ~xs =
    if rows < 1 || cols < 1 then None
    else
    let init = Vacant (0, 0) in
    let rec loop acc rows' =
      let arr = Array.make cols init in
      for ii = 0 to cols-1 do
        let p = (rows'-1, ii) in
        arr.(ii) <- if List.mem p xs then Filled p else Vacant p
      done;
      match rows' with
      | 0 -> acc
      | _ -> loop (arr :: acc) (rows' - 1)
    in
    Some (loop [] rows |> Array.of_list)
end

module AStarPathFinder : sig
  val findPath : grid:Grid.t -> first:Grid.node -> last:Grid.node -> Grid.node list

end = struct
  let dist p1 p2 =
    let x1, y1 = p1 in
    let x2, y2 = p2 in
    let xsq = (x1 - x2 |> float_of_int) ** 2. in
    let ysq = (y1 - y2 |> float_of_int) ** 2. in
    sqrt (xsq +. ysq)

  let pointOfNode = function
    | Grid.Vacant c
    | Grid.Filled c -> c

  (* XXX: check if first/last are valid*)
  let findPath ~grid ~first ~last =
    (* let module Set = Set.Make(struct *)
    (*     type t = int * int *)
    (*     let compare x y = dist x y |> int_of_float *)
    (*   end) in *)
    let rec loop path visited =
      let pos = List.hd path |> pointOfNode in
      let row = fst pos and col = snd pos in
      let trim acc = function
        | None -> acc
        | Some node -> if List.mem node visited then acc else node :: acc in
      let neighbors = List.fold_left trim []
        [ Grid.at ~row:(row + 1) ~col ~grid;
          Grid.at ~row:(row - 1) ~col ~grid;
          Grid.at ~col:(col + 1) ~row ~grid;
          Grid.at ~col:(col - 1) ~row ~grid; ] in
      if List.mem last neighbors then last :: path
      else
      let f acc n =
        match n, last with
        | Grid.Vacant c1, Grid.Vacant c2 -> (n, dist c1 c2) :: acc
        | _, _ -> acc in
      let costs : (Grid.node * float) list = List.fold_left f [] neighbors in
      let findLeast previous current =
        if snd current < snd previous then current
        else previous in
      if List.length costs < 1 then [] (* Return empty list if no path exists *)
      else
      let cheapest = List.(fold_left findLeast (hd costs) (tl costs)) in
      let path    = fst cheapest :: path and
          visited = neighbors @ visited in
      loop path visited
    in
    loop [first] [first] |> List.rev
end

let demo xs =
  let Some grid = Grid.ofCoords ~rows:100 ~cols:100 ~xs and
      first     = Grid.Vacant (0, 0) and
      last      = Grid.Vacant (99, 99) in
  AStarPathFinder.findPath ~grid ~first ~last

(*
let benchmark () =
  let open Core_bench.Std in
  Bench.bench [Bench.Test.create ~name:"A*" (fun () -> demo [] |> ignore)]
*)
