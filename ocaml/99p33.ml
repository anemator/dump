(* Determine whether two positive integer numbers are coprime. Two
 * numbers are coprime if their greatest common divisor equals 1. *)
let coprime a b = gcd a b = 1

coprime 13 27;;
not (coprime 20536 7826);;
