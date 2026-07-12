type color = Red | Black

type tree = Branch of color * tree * int64 * bool * tree | Leaf

type zipper =
  | NodeR of color * tree * int64 * bool * zipper
  | NodeL of color * zipper * int64 * bool * tree
  | Done

let rec move_up z t =
  match z with
  | NodeR (c, l, k, v, z1) -> move_up z1 (Branch (c, l, k, v, t))
  | NodeL (c, z1, k, v, r) -> move_up z1 (Branch (c, t, k, v, r))
  | Done -> t

let rec balance_red z l k v r =
  match z with
  | NodeR (Black, l1, k1, v1, z1) ->
      move_up z1 (Branch (Black, l1, k1, v1, Branch (Red, l, k, v, r)))
  | NodeL (Black, z1, k1, v1, r1) ->
      move_up z1 (Branch (Black, Branch (Red, l, k, v, r), k1, v1, r1))
  | NodeR (Red, l1, k1, v1, z1) -> (
      match z1 with
      | NodeR (_, l2, k2, v2, z2) ->
          balance_red z2 (Branch (Black, l2, k2, v2, l1)) k1 v1
            (Branch (Black, l, k, v, r))
      | NodeL (_, z2, k2, v2, r2) ->
          balance_red z2 (Branch (Black, l1, k1, v1, l)) k v
            (Branch (Black, r, k2, v2, r2))
      | Done -> Branch (Black, l1, k1, v1, Branch (Red, l, k, v, r)))
  | NodeL (Red, z1, k1, v1, r1) -> (
      match z1 with
      | NodeR (_, l2, k2, v2, z2) ->
          balance_red z2 (Branch (Black, l2, k2, v2, l)) k v
            (Branch (Black, r, k1, v1, r1))
      | NodeL (_, z2, k2, v2, r2) ->
          balance_red z2 (Branch (Black, l, k, v, r)) k1 v1
            (Branch (Black, r1, k2, v2, r2))
      | Done -> Branch (Black, Branch (Red, l, k, v, r), k1, v1, r1))
  | Done -> Branch (Black, l, k, v, r)

let rec ins t k v z =
  match t with
  | Branch (c, l, kx, vx, r) ->
      if k < kx then ins l k v (NodeL (c, z, kx, vx, r))
      else if k > kx then ins r k v (NodeR (c, l, kx, vx, z))
      else move_up z (Branch (c, l, kx, vx, r))
  | Leaf -> balance_red z Leaf k v Leaf

let insert t k v = ins t k v Done

let rec make_tree n t =
  if n <= 0 then t
  else
    let m = n - 1 in
    make_tree m (insert t (Int64.of_int m) (m mod 10 = 0))

let rec fold_tree t acc =
  match t with
  | Branch (_, l, _, v, r) ->
      let left = fold_tree l acc in
      fold_tree r (if v then left + 1 else left)
  | Leaf -> acc

let () =
  let result = fold_tree (make_tree 2_500_000 Leaf) 0 in
  if result <> 250_000 then (
    Printf.eprintf "FAIL: expected 250000, got %d\n" result;
    exit 1)
