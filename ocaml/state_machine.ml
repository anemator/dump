type event = Coin | Push
type state = Locked | Unlocked

type dfa =
  { start: state
  ; accept: state list
  ; step : state -> event -> state
  }

let step state event =
  match state, event with
  | Locked, Coin -> Unlocked
  | Locked, Push -> Locked
  | Unlocked, Coin -> Unlocked
  | Unlocked, Push -> Locked

let run { start; accept; step } xs =
  List.(mem (fold_left step start xs) accept)

let () =
  let sm = { start=Locked; accept=[Unlocked]; step } in
  let _ = run sm in ()
