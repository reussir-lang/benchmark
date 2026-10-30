// rbtree with int keys and values: insert the keys 2499999 .. 0, each mapped
// to itself, then sum the values. Every key and value is a small integer, so
// this measures the immediate path of big-integer arithmetic.

type color
  Red
  Black


type tree
  Node(color : color, lchild : tree, key : int, value : int, rchild : tree)
  Leaf()
  

fun node-is-red(t : tree) : bool
  match t
    Node(Red) -> True
    _         -> False


fun balance-left(l :tree, k : int, v : int, r : tree) : tree
  match l
    Node(_, Node(Red, lx, kx, vx, rx), ky, vy, ry)
      -> Node(Red, Node(Black, lx, kx, vx, rx), ky, vy, Node(Black, ry, k, v, r))
    Node(_, ly, ky, vy, Node(Red, lx, kx, vx, rx))
      -> Node(Red, Node(Black, ly, ky, vy, lx), kx, vx, Node(Black, rx, k, v, r))
    Node(_, lx, kx, vx, rx)
      -> Node(Black, Node(Red, lx, kx, vx, rx), k, v, r)
    Leaf -> Leaf
    

fun balance-right(l : tree, k : int, v : int, r : tree) : tree
  match r
    Node(_, Node(Red, lx, kx, vx, rx), ky, vy, ry)
      -> Node(Red, Node(Black, l, k, v, lx), kx, vx, Node(Black, rx, ky, vy, ry))
    Node(_, lx, kx, vx, Node(Red, ly, ky, vy, ry))
      -> Node(Red, Node(Black, l, k, v, lx), kx, vx, Node(Black, ly, ky, vy, ry))
    Node(_, lx, kx, vx, rx)
      -> Node(Black, l, k, v, Node(Red, lx, kx, vx, rx))
    Leaf -> Leaf
    

fun ins(t : tree, k : int, v : int) : tree
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


fun insert(t : tree, k : int, v : int) : tree
  ins(t, k, v).set-black


fun fold(t : tree, b : int) : int
  match t
    Node(_, l, _, v, r) -> r.fold(l.fold(b) + v)
    Leaf                -> b


fun make-tree-aux(n : int, t : tree) : div tree
  if n <= 0 then t else
    val n1 = n - 1
    make-tree-aux(n1, insert(t, n1, n1))

pub fun make-tree(n : int) : div tree
  make-tree-aux(n, Leaf)


pub fun main()
  val v = make-tree(2500000).fold(0)
  if v != 3124998750000 then
    println("FAIL: expected 3124998750000, got " ++ v.show)
    throw("wrong result")
