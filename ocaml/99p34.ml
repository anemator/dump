(* Calculate Euler's totient function phi(m). Euler's so-called totient
 * function phi(m) is defined as the number of positive integers
 * r (1 <= r < m) that are coprime to m. We let phi(1) = 1.
 *
 * Find out what the value of phi(m) is if m is a prime number. Euler's
 * totient function plays an important role in one of the most widely
 * used public key crypotography methods (RSA). In this exercise you should
 * use the most primitive method to calculate this function (there are
 * smarter ways that we shall discuss later). *)
let rec gcd a b = if b = 0 then a else gcd b (a mod b)

let rec range m n =
  if m = n then
    [n]
  else
    if m < n then
      m :: range (m+1) n
    else
      m :: range (m-1) n

let phi m =
  List.length (List.filter (fun n -> gcd n m = 1) (range 1 m))

phi 10 = 4;;
phi 13 = 12;;
