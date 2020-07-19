(* Run-length encoding of a list (direct solution). Implement the so-called
 * run-length encoding data compression method directly, i.e. don't explicitly
 * create the sublists containing the duplicates, as in problem 09, but only
 * count them. As in problem 11, simplify the result list by replacing the
 * singleton lists (1 X) by X. *)
type 'a rle =
| One of 'a
| Many of (int * 'a)

let rec encode xs =
  let f n e = if n = 1 then One e else Many (n,e) in
  let rec aux n e = function
    | [] -> [f n e]
    | y :: ys ->
      if y = e then
        aux (n+1) e ys
      else
        f n e :: aux 1 y ys in
  aux 1 (List.hd xs) (List.tl xs)

encode [`a;`a;`a;`a;`b;`c;`c;`a;`a;`d;`e;`e;`e;`e]
= [Many (4,`a); One `b; Many (2,`c); Many (2,`a); One `d; Many (4,`e)];;
