type list_ = Nil | Cons of int64 * list_

type rotation =
  | Idle
  | Reversing of int * list_ * list_ * list_ * list_
  | Appending of int * list_ * list_
  | Done of list_

type queue = Queue of int * list_ * rotation * int * list_

let exec = function
  | Reversing (ok, Cons (x, f), f', Cons (y, r), r') ->
      Reversing (ok + 1, f, Cons (x, f'), r, Cons (y, r'))
  | Reversing (ok, Nil, f', Cons (y, Nil), r') -> Appending (ok, f', Cons (y, r'))
  | Appending (0, _, r') -> Done r'
  | Appending (ok, Cons (x, f'), r') -> Appending (ok - 1, f', Cons (x, r'))
  | state -> state

let invalidate = function
  | Reversing (ok, f, f', r, r') -> Reversing (ok - 1, f, f', r, r')
  | Appending (0, _, Cons (_, r')) -> Done r'
  | Appending (ok, f', r') -> Appending (ok - 1, f', r')
  | state -> state

let exec2 (Queue (len_f, front, state, len_r, rear)) =
  match exec (exec state) with
  | Done front' -> Queue (len_f, front', Idle, len_r, rear)
  | state' -> Queue (len_f, front, state', len_r, rear)

let check (Queue (len_f, front, state, len_r, rear) as queue) =
  if len_r <= len_f then exec2 queue
  else exec2 (Queue (len_f + len_r, front, Reversing (0, front, Nil, rear, Nil), 0, Nil))

let snoc (Queue (len_f, front, state, len_r, rear)) value =
  check (Queue (len_f, front, state, len_r + 1, Cons (value, rear)))

let uncons = function
  | Queue (len_f, Cons (value, front), state, len_r, rear) ->
      (value, check (Queue (len_f - 1, front, invalidate state, len_r, rear)))
  | _ -> failwith "empty queue"

let modulus = 1_000_000_007L

let () =
  let rec build index queue =
    if index = 65_536 then queue
    else build (index + 1) (snoc queue (Int64.of_int index))
  in
  let rec churn round remaining queue checksum =
    if remaining = 0 then (queue, checksum)
    else
      let value, rest = uncons queue in
      let next = Int64.rem (Int64.add value (Int64.add round 1L)) modulus in
      churn (Int64.add round 1L) (remaining - 1) (snoc rest next)
        (Int64.rem (Int64.add checksum value) modulus)
  in
  let rec drain remaining queue checksum =
    if remaining = 0 then checksum
    else
      let value, rest = uncons queue in
      drain (remaining - 1) rest (Int64.rem (Int64.add checksum value) modulus)
  in
  let queue, checksum = churn 0L 1_000_000 (build 0 (Queue (0, Nil, Idle, 0, Nil))) 0L in
  let result = drain 65_536 queue checksum in
  if result <> 66_797_929L then (
    Printf.eprintf "FAIL: expected 66797929, got %Ld\n" result;
    exit 1)
