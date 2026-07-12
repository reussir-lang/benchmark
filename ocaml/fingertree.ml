type elem = Value of int64 | Node2 of elem * elem | Node3 of elem * elem * elem

type digit =
  | One of elem
  | Two of elem * elem
  | Three of elem * elem * elem
  | Four of elem * elem * elem * elem

type tree = Empty | Single of elem | Deep of digit * tree * digit

let node_to_digit = function
  | Node2 (a, b) -> Two (a, b)
  | Node3 (a, b, c) -> Three (a, b, c)
  | Value _ -> invalid_arg "node_to_digit"

let digit_to_tree = function
  | One a -> Single a
  | Two (a, b) -> Deep (One a, Empty, One b)
  | Three (a, b, c) -> Deep (Two (a, b), Empty, One c)
  | Four (a, b, c, d) -> Deep (Two (a, b), Empty, Two (c, d))

let rec snoc tree value =
  match tree with
  | Empty -> Single value
  | Single a -> Deep (One a, Empty, One value)
  | Deep (prefix, middle, Four (a, b, c, d)) ->
      Deep (prefix, snoc middle (Node3 (a, b, c)), Two (d, value))
  | Deep (prefix, middle, One a) -> Deep (prefix, middle, Two (a, value))
  | Deep (prefix, middle, Two (a, b)) -> Deep (prefix, middle, Three (a, b, value))
  | Deep (prefix, middle, Three (a, b, c)) ->
      Deep (prefix, middle, Four (a, b, c, value))

let rec view_left = function
  | Empty -> None
  | Single value -> Some (value, Empty)
  | Deep (One value, middle, suffix) -> (
      match view_left middle with
      | None -> Some (value, digit_to_tree suffix)
      | Some (node, middle') ->
          Some (value, Deep (node_to_digit node, middle', suffix)))
  | Deep (Two (a, b), middle, suffix) -> Some (a, Deep (One b, middle, suffix))
  | Deep (Three (a, b, c), middle, suffix) ->
      Some (a, Deep (Two (b, c), middle, suffix))
  | Deep (Four (a, b, c, d), middle, suffix) ->
      Some (a, Deep (Three (b, c, d), middle, suffix))

let modulus = 1_000_000_007L

let () =
  let rec build index tree =
    if index = 65_536 then tree
    else build (index + 1) (snoc tree (Value (Int64.of_int index)))
  in
  let rec churn round remaining tree checksum =
    if remaining = 0 then (tree, checksum)
    else
      match view_left tree with
      | Some (Value value, rest) ->
          let next = Int64.rem (Int64.add value (Int64.add round 1L)) modulus in
          churn (Int64.add round 1L) (remaining - 1) (snoc rest (Value next))
            (Int64.rem (Int64.add checksum value) modulus)
      | _ -> failwith "invalid finger tree"
  in
  let rec drain tree checksum =
    match view_left tree with
    | None -> checksum
    | Some (Value value, rest) ->
        drain rest (Int64.rem (Int64.add checksum value) modulus)
    | _ -> failwith "invalid finger tree"
  in
  let tree, checksum = churn 0L 1_000_000 (build 0 Empty) 0L in
  let result = drain tree checksum in
  if result <> 66_797_929L then (
    Printf.eprintf "FAIL: expected 66797929, got %Ld\n" result;
    exit 1)
