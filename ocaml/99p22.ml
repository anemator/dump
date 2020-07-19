(* Create a list containing all integers within a given range. If the
 * first argument is smaller than the second, produce a list in
 * decreasing order. *)
let rec range m n =
  if m = n then
    [n]
  else
    if m < n then
      m :: range (m+1) n
    else
      m :: range (m-1) n

range 4 9 = [4; 5; 6; 7; 8; 9];;
range 9 4 = [9; 8; 7; 6; 5; 4];;
