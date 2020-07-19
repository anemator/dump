open Base

let rec permute xs =
  let rec insert = function
    | [] -> [[]]
    | hd::tl ->
      let ps = permute tl in
      let xss = ref [] in
      List.iter ps ~f:(fun xs ->
          let arr = Array.of_list xs in
          let len = Array.length arr in
          xss := (hd :: xs) :: !xss; (* Array.slice 0 0 is surprising :( *)
          for i = 1 to len do
            let lhs = Array.(slice arr 0 i |> to_list) in
            let rhs = Array.(slice arr i len |> to_list) in
            xss := (lhs @ hd :: rhs) :: !xss
          done);
      !xss
  in insert xs
