(* Modified run-length encoding. Modify the result of problem 10 in such a
 * way that if an element has no duplicates it is simply copied into the
 * result list. Only elements with duplicates are transferred as (N E)
 * lists. *)
type 'a rle =
| One of 'a
| Many of (int * 'a)

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

let mencode xs =
  let aux (n, e) = if n = 1 then One e else Many (n, e) in
  List.map aux (encode xs)

mencode [`a;`a;`a;`a;`b;`c;`c;`a;`a;`d;`e;`e;`e;`e] =
  [Many (4,`a) ; One `b ; Many (2,`c) ; Many (2,`a) ; One `d ; Many (4,`e)];;
