(* Pack consecutive duplicates of list elements into sublists. *)
let rec pack xs =
  let rec split acc = function
    | y :: ys when y = List.hd acc -> split (y :: acc) ys
    | ys -> acc, ys in match xs with
      [] -> []
      | h :: t -> let a, b = split [h] t in
                  a :: (pack b)

pack [`a; `a; `a; `a; `b; `c; `c; `a; `a; `d; `d; `e; `e; `e; `e]
= [[`a; `a; `a; `a]; [`b]; [`c; `c]; [`a; `a]; [`d; `d]; [`e; `e; `e; `e]];;
