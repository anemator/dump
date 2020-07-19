(* http://dave.fayr.am/posts/2012-10-4-finding-fizzbuzz.html *)
let printers : (int -> bool) list =
  let gen_fun (prime, word) = fun n ->
    if n mod prime = 0 then (print_string word; true)
    else false
  in
  List.map gen_fun [3, "Fizz"; 5, "Buzz"; 7, "Bazz"]

let fb : int -> unit = fun n ->
  let rec loop m =
    if m > n then () else
    let test b f = if f m then true else b in
    if not @@ List.fold_left test false printers then
      print_int m;
    print_newline ();
    loop (m+1)
  in
  loop 1
