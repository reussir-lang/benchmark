// rbtree-lookup: rbtree's tree code with lookups. Insert 1M scattered keys
// and after every insert look up 8 keys in the current tree, which stays
// live for the next insert. The inserts own the tree and can update it in
// place; the lookups only read it.
import std/num/int64

type color
  Red
  Black


type tree
  Node(color : color, lchild : tree, key : int64, value : bool, rchild : tree)
  Leaf()
  

fun node-is-red(t : tree) : bool
  match t
    Node(Red) -> True
    _         -> False


fun balance-left(l :tree, k : int64, v : bool, r : tree) : tree
  match l
    Node(_, Node(Red, lx, kx, vx, rx), ky, vy, ry)
      -> Node(Red, Node(Black, lx, kx, vx, rx), ky, vy, Node(Black, ry, k, v, r))
    Node(_, ly, ky, vy, Node(Red, lx, kx, vx, rx))
      -> Node(Red, Node(Black, ly, ky, vy, lx), kx, vx, Node(Black, rx, k, v, r))
    Node(_, lx, kx, vx, rx)
      -> Node(Black, Node(Red, lx, kx, vx, rx), k, v, r)
    Leaf -> Leaf
    

fun balance-right(l : tree, k : int64, v : bool, r : tree) : tree
  match r
    Node(_, Node(Red, lx, kx, vx, rx), ky, vy, ry)
      -> Node(Red, Node(Black, l, k, v, lx), kx, vx, Node(Black, rx, ky, vy, ry))
    Node(_, lx, kx, vx, Node(Red, ly, ky, vy, ry))
      -> Node(Red, Node(Black, l, k, v, lx), kx, vx, Node(Black, ly, ky, vy, ry))
    Node(_, lx, kx, vx, rx)
      -> Node(Black, l, k, v, Node(Red, lx, kx, vx, rx))
    Leaf -> Leaf
    

fun ins(t : tree, k : int64, v : bool) : tree
  match t
    Node(Red, l, kx, vx, r)
      -> if k < kx then Node(Red, ins(l, k, v), kx, vx, r)
         elif k > kx then Node(Red, l, kx, vx, ins(r, k, v))
         else Node(Red, l, k, v, r)
    Node(Black, l, kx, vx, r)
      -> if k < kx then (if node-is-red(l) then balance-left(ins(l,k,v), kx, vx, r)
                                      else Node(Black, ins(l, k, v), kx, vx, r))
         elif k > kx then (if node-is-red(r) then balance-right(l, kx, vx, ins(r,k,v))
                                        else Node(Black, l, kx, vx, ins(r, k, v)))
         else Node(Black, l, k, v, r)
    Leaf -> Node(Red, Leaf, k, v, Leaf)


fun set-black(t : tree) : tree
  match t
    Node(_, l, k, v, r) -> Node(Black, l, k, v, r)
    _ -> t


fun insert(t : tree, k : int64, v : bool) : tree
  ins(t, k, v).set-black


fun get(t : tree, k : int64) : bool
  match t
    Node(_, l, kx, _, r) -> if k < kx then get(l, k) elif k > kx then get(r, k) else True
    Leaf -> False


fun probe(j : int64, i : int64, t : tree, hits : int64) : div int64
  if j == zero then hits
  else
    val k = (i * 31.int64 + j * 7919.int64) % 2000000.int64
    probe(j.dec, i, t, if get(t, k) then hits.inc else hits)


fun rounds(i : int64, n : int64, t : tree, hits : int64) : div int64
  if i == n then hits
  else
    val t2 = insert(t, (i * 7919.int64) % n, True)
    val h = probe(8.int64, i, t2, hits)
    rounds(i.inc, n, t2, h)


pub fun main()
  val hits = rounds(zero, 1000000.int64, Leaf, zero)
  if hits != 2059798.int64 then
    println("FAIL: expected 2059798, got " ++ hits.show)
    throw("wrong result")
