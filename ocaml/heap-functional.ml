type heap = Node of int64 * heap * heap | Leaf

let modulus = 1_000_000_007L
let lcg x = Int64.rem (Int64.mul x 48_271L) 2_147_483_647L

let gauss state =
  let rec go count sum state =
    if count = 0 then (sum, state)
    else
      let next = lcg state in
      go (count - 1) (Int64.add sum next) next
  in
  go 12 0L state

let rec insert heap value =
  match heap with
  | Leaf -> Node (value, Leaf, Leaf)
  | Node (root, left, right) ->
      if Int64.compare value root <= 0 then Node (value, insert right root, left)
      else Node (root, insert right value, left)

let rec down value left right =
  match (left, right) with
  | Node (lv, ll, lr), Node (rv, rl, rr) ->
      if Int64.compare lv rv <= 0 then
        if Int64.compare value lv <= 0 then Node (value, left, right)
        else Node (lv, down value ll lr, right)
      else if Int64.compare value rv <= 0 then Node (value, left, right)
      else Node (rv, left, down value rl rr)
  | Node (lv, ll, lr), Leaf ->
      if Int64.compare value lv <= 0 then Node (value, left, Leaf)
      else Node (lv, down value ll lr, Leaf)
  | Leaf, Node (rv, rl, rr) ->
      if Int64.compare value rv <= 0 then Node (value, Leaf, right)
      else Node (rv, Leaf, down value rl rr)
  | Leaf, Leaf -> Node (value, Leaf, Leaf)

let replace_top heap value =
  match heap with Node (_, left, right) -> down value left right | Leaf -> Node (value, Leaf, Leaf)

let top = function Node (value, _, _) -> value | Leaf -> 0L

let rec heap_sum heap acc =
  match heap with
  | Leaf -> acc
  | Node (value, left, right) ->
      heap_sum right
        (heap_sum left (Int64.rem (Int64.add acc value) modulus))

let () =
  let rec build count state heap =
    if count = 65_535 then (heap, state)
    else
      let value, next = gauss state in
      build (count + 1) next (insert heap value)
  in
  let heap, state = build 0 20_260_711L Leaf in
  let rec maintain rounds state heap checksum =
    if rounds = 0 then
      Int64.rem (Int64.add checksum (heap_sum heap 0L)) modulus
    else
      let delta, next = gauss state in
      let root = top heap in
      maintain (rounds - 1) next
        (replace_top heap (Int64.add root delta))
        (Int64.rem (Int64.add checksum root) modulus)
  in
  let result = maintain 6_500_000 state heap 0L in
  if result <> 558_972_311L then (
    Printf.eprintf "FAIL: expected 558972311, got %Ld\n" result;
    exit 1)
