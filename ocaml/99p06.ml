(* Find out whether a list is a palindrome. A palindrome can be read forward
 * or backward; e.g. (x a m a x) *)
let is_palindrome xs =
  xs = List.rev xs;;

is_palindrome [`x; `a; `m; `a; `x];;
not (is_palindrome [`a; `b]);;
