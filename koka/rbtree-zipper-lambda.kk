import std/os/env

type color
  Red
  Black

type tree
  Node(color : color, lchild : tree, key : int, value : bool, rchild : tree)
  Leaf
  
type zipper
  NodeR(color : color, lchild : tree, key : int, value : bool, zip : zipper)
  NodeL(color : color, zip : zipper, key : int, value : bool, rchild : tree)
  Done

fun move-up(z : zipper, t : tree)
  match z
    NodeR(c, l, k, v, z1) -> z1.move-up(Node(c, l, k, v, t))
    NodeL(c, z1, k, v, r) -> z1.move-up(Node(c, t, k, v, r))
    Done -> t

fun balance-red( z : zipper, l : tree, k : int, v : bool, r : tree ) : tree
  match z
    NodeR(Black, l1, k1, v1, z1) -> z1.move-up( Node( Black, l1, k1, v1, Node(Red,l,k,v,r) ) )
    NodeL(Black, z1, k1, v1, r1) -> z1.move-up( Node( Black, Node(Red,l,k,v,r), k1, v1, r1 ) )
    NodeR(Red, l1, k1, v1, z1) -> match z1
      NodeR(_c2, l2, k2, v2, z2) -> z2.balance-red( Node(Black, l2, k2, v2, l1), k1, v1, Node(Black, l, k, v, r) )
      NodeL(_c2, z2, k2, v2, r2) -> z2.balance-red( Node(Black, l1, k1, v1, l), k, v, Node(Black, r, k2, v2, r2) )
      Done -> Node(Black, l1, k1, v1, Node(Red,l,k,v,r))
    NodeL(Red, z1, k1, v1, r1) -> match z1
      NodeR(_c2, l2, k2, v2, z2) -> z2.balance-red( Node(Black, l2, k2, v2, l), k, v, Node(Black, r, k1, v1, r1) )
      NodeL(_c2, z2, k2, v2, r2) -> z2.balance-red( Node(Black, l, k, v, r), k1, v1, Node(Black, r1, k2, v2, r2) )              
      Done -> Node(Black, Node(Red,l,k,v,r), k1, v1, r1)
    Done -> Node(Black,l,k,v,r)

fun ins(t : tree, k : int, v : bool, z : zipper, cmp: (int, int) -> int) : tree
  match t
    Node(c, l, kx, vx, r)
      -> if cmp(k, kx) < 0 then ins(l, k, v, NodeL(c, z, kx, vx, r), cmp)
         elif cmp(k, kx) > 0 then ins(r, k, v, NodeR(c, l, kx, vx, z), cmp)
         else z.move-up(Node(c, l, kx, vx, r))  // z.move-up(t) is slower (but not a reuse bug); to be investigated
    Leaf -> z.balance-red(Leaf, k, v, Leaf)

fun insert(t : tree, k : int, v : bool) : tree
  ins(t, k, v, Done, fn (a:int, b:int) -> b - a)


fun fold(t : tree, b : a, f: (int, bool, a) -> a) : a
  match t
    Node(_, l, k, v, r) -> r.fold( f(k, v, l.fold(b, f)), f)
    Leaf                -> b

fun make-tree(n : int, t : tree) : div tree
  if n <= 0 then t else
    val m = n - 1
    make-tree(m, insert(t, m, m % 10 == 0))

pub fun main()
  val n = get-args().head("").parse-int.default(4200000)
  val t = make-tree(n, Leaf)
  val v = t.fold(0) fn(k,v,r:int){ if v then r.inc else r }
  v.show.println