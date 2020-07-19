(* Extract a slice from a list. Given two indices, i and k, the slice
 * is the list containing the elements between the i'th and k'th element
 * of the original list (both limits included). Start counting the elements
 * with 0 (this is the way the List module numbers elements). *)
let rec slice xs min max =
  if min > 0 then slice (List.tl xs) (min-1) (max-1)
  else if max > 0 then (List.hd xs) :: slice (List.tl xs) 0 (max-1)
  else [List.hd xs]

slice [`a;`b;`c;`d;`e;`f;`g;`h;`i;`j] 2 6 = [`c;`d;`e;`f;`g];;
