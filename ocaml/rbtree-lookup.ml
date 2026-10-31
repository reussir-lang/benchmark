(* rbtree-lookup: rbtree's tree code with lookups. Insert 1M scattered keys
   and after every insert look up 8 keys in the current tree, which stays
   live for the next insert. The inserts own the tree and can update it in
   place; the lookups only read it. *)

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

let rec get t k =
  match t with
  | Branch (_, l, kx, _, r) ->
      if k < kx then get l k else if k > kx then get r k else true
  | Leaf -> false

let rec probe j i t hits =
  if j = 0 then hits
  else
    let k = Int64.of_int (((i * 31) + (j * 7919)) mod 2_000_000) in
    probe (j - 1) i t (if get t k then hits + 1 else hits)

let rec rounds i n t hits =
  if i = n then hits
  else
    let t2 = insert t (Int64.of_int ((i * 7919) mod n)) true in
    let h = probe 8 i t2 hits in
    rounds (i + 1) n t2 h

let () =
  let hits = rounds 0 1_000_000 Leaf 0 in
  if hits <> 2059798 then (
    Printf.eprintf "FAIL: expected 2059798, got %d\n" hits;
    exit 1)
