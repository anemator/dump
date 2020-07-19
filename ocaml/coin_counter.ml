(* Calculates change optimizing for least number of coins *)
type t = { pennies: int; nickels: int; dimes: int; quarters: int; }

let penny = 1
let nickel = 5
let dime = 10
let quarter = 25

let make_counter ignore =
  let rec count acc left =
    if not (List.mem `quarter ignore) && left >= quarter then
      count { acc with quarters = acc.quarters+1 } (left-quarter)
    else if not (List.mem `dime ignore) && left >= dime then
      count { acc with dimes = acc.dimes+1 } (left-dime)
    else if not (List.mem `nickel ignore) && left >= nickel then
      count { acc with nickels = acc.nickels+1 } (left-nickel)
    else if not (List.mem `penny ignore) && left >= penny then
      count { acc with pennies = acc.pennies+1 } (left-penny)
    else
      acc
  in count

let count : int -> t =
  make_counter [] { pennies=0; nickels=0; dimes=0; quarters=0 }

let () =
  let { pennies; nickels; dimes; quarters } = count 19 in
  Printf.printf "%d, %d, %d, %d\n" pennies nickels dimes quarters
