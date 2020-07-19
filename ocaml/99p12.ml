(* Decode a run-length encoded list. Given a run-length code list generated
 * as specified in problem 11, construct its uncompressed version. *)
type 'a rle =
| One of 'a
| Many of (int * 'a)

let decode xs =
  let rec aux = function
    | One e -> [e]
    | Many (n, e) -> e :: aux (if n = 2 then One e else Many (n-1, e)) in
  List.flatten (List.map aux xs)

decode [Many (4,`a); One `b; Many (2,`c); Many (2,`a); One `d; Many (4,`e)]
  = [`a;`a;`a;`a;`b;`c;`c;`a;`a;`d;`e;`e;`e;`e];;
