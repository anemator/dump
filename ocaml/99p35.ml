(* Determine the prime factors of a given positive integer. Construct a
 * flat list containing the prime factors in ascending order. *)
let factors n =
  let rec aux k m =
    if k = n then
      []
    else
      if m mod k = 0 then
        k :: aux k (m / k)
      else
        aux (k+1) m in
  aux 2 n

factors 315 = [3; 3; 5; 7];;
