(* Run-length encoding of a list. Use the result of problem 09 to implement
 * the so-called run-length encoding data compression method. Consecutive
 * duplicates of elements are encoded as lists (N E) where N is the number
 * of duplicates of the element E. *)
let rec pack xs =
  let rec split acc = function
    | y :: ys when y = List.hd acc -> split (y :: acc) ys
    | ys -> acc, ys in match xs with
      [] -> []
      | h :: t -> let a, b = split [h] t in
                  a :: (pack b)

let encode xs =
  let xs' = pack xs in
  List.map (fun ys -> (List.length ys, List.hd ys)) xs'

encode [`a; `a; `a; `a; `b; `c; `c; `a; `a; `d; `d; `e; `e; `e; `e]
= [4,`a; 1,`b; 2,`c; 2,`a; 2,`d; 4,`e];;
