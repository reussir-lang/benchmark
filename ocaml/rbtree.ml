type color = Red | Black

type tree =
  | Branch of color * tree * int64 * bool * tree
  | Leaf

let is_red = function Branch (Red, _, _, _, _) -> true | _ -> false

let balance_left l k v r =
  match l with
  | Branch (_, Branch (Red, ll, kk, vv, rr), kx, vx, rx) ->
      Branch
        ( Red,
          Branch (Black, ll, kk, vv, rr),
          kx,
          vx,
          Branch (Black, rx, k, v, r) )
  | Branch (_, lx, kx, vx, Branch (Red, lx1, kx1, vx1, rxx)) ->
      Branch
        ( Red,
          Branch (Black, lx, kx, vx, lx1),
          kx1,
          vx1,
          Branch (Black, rxx, k, v, r) )
  | Branch (_, lx, kx, vx, rx) ->
      Branch (Black, Branch (Red, lx, kx, vx, rx), k, v, r)
  | Leaf -> Leaf

let balance_right l k v r =
  match r with
  | Branch (_, Branch (Red, ll, kk, vv, rr), kx, vx, ry) ->
      Branch
        ( Red,
          Branch (Black, l, k, v, ll),
          kk,
          vv,
          Branch (Black, rr, kx, vx, ry) )
  | Branch (_, lx, kx, vx, Branch (Red, ly, ky, vy, rr)) ->
      Branch
        ( Red,
          Branch (Black, l, k, v, lx),
          kx,
          vx,
          Branch (Black, ly, ky, vy, rr) )
  | Branch (_, lx, kx, vx, rx) ->
      Branch (Black, l, k, v, Branch (Red, lx, kx, vx, rx))
  | Leaf -> Leaf

let rec ins t k v =
  match t with
  | Branch (Red, l, kx, vx, r) ->
      if k < kx then Branch (Red, ins l k v, kx, vx, r)
      else if k > kx then Branch (Red, l, kx, vx, ins r k v)
      else Branch (Red, l, k, v, r)
  | Branch (Black, l, kx, vx, r) ->
      if k < kx then
        if is_red l then balance_left (ins l k v) kx vx r
        else Branch (Black, ins l k v, kx, vx, r)
      else if k > kx then
        if is_red r then balance_right l kx vx (ins r k v)
        else Branch (Black, l, kx, vx, ins r k v)
      else Branch (Black, l, k, v, r)
  | Leaf -> Branch (Red, Leaf, k, v, Leaf)

let set_black = function
  | Branch (_, l, k, v, r) -> Branch (Black, l, k, v, r)
  | Leaf -> Leaf

let insert t k v = set_black (ins t k v)

let make_tree n =
  let rec go n t =
    if n <= 0 then t
    else
      let m = n - 1 in
      go m (insert t (Int64.of_int m) (m mod 10 = 0))
  in
  go n Leaf

let rec fold_tree t acc =
  match t with
  | Branch (_, l, _, v, r) ->
      let left = fold_tree l acc in
      fold_tree r (if v then left + 1 else left)
  | Leaf -> acc

let () =
  let result = fold_tree (make_tree 2_500_000) 0 in
  if result <> 250_000 then (
    Printf.eprintf "FAIL: expected 250000, got %d\n" result;
    exit 1)
