import std/num/int64

type elem
  Value(value : int64)
  Node2(a : elem, b : elem)
  Node3(a : elem, b : elem, c : elem)

type digit
  One(a : elem)
  Two(a : elem, b : elem)
  Three(a : elem, b : elem, c : elem)
  Four(a : elem, b : elem, c : elem, d : elem)

type finger-tree
  Empty
  Single(value : elem)
  Deep(front-digit : digit, middle : finger-tree, back-digit : digit)

fun node-to-digit( node : elem ) : digit
  match node
    Node2(a,b) -> Two(a,b)
    Node3(a,b,c) -> Three(a,b,c)
    Value -> One(Value(0.int64))

fun digit-to-tree( digit : digit ) : finger-tree
  match digit
    One(a) -> Single(a)
    Two(a,b) -> Deep(One(a), Empty, One(b))
    Three(a,b,c) -> Deep(Two(a,b), Empty, One(c))
    Four(a,b,c,d) -> Deep(Two(a,b), Empty, Two(c,d))

fun snoc( tree : finger-tree, x : elem ) : div finger-tree
  match tree
    Empty -> Single(x)
    Single(a) -> Deep(One(a), Empty, One(x))
    Deep(pr, middle, Four(a,b,c,d)) ->
      Deep(pr, snoc(middle, Node3(a,b,c)), Two(d,x))
    Deep(pr, middle, One(a)) -> Deep(pr, middle, Two(a,x))
    Deep(pr, middle, Two(a,b)) -> Deep(pr, middle, Three(a,b,x))
    Deep(pr, middle, Three(a,b,c)) -> Deep(pr, middle, Four(a,b,c,x))

fun view-left( tree : finger-tree ) : div maybe<(elem,finger-tree)>
  match tree
    Empty -> Nothing
    Single(x) -> Just((x,Empty))
    Deep(One(x), middle, suffix) ->
      match view-left(middle)
        Nothing -> Just((x,digit-to-tree(suffix)))
        Just((node,middle1)) -> Just((x,Deep(node-to-digit(node),middle1,suffix)))
    Deep(Two(a,b), middle, suffix) -> Just((a,Deep(One(b),middle,suffix)))
    Deep(Three(a,b,c), middle, suffix) -> Just((a,Deep(Two(b,c),middle,suffix)))
    Deep(Four(a,b,c,d), middle, suffix) -> Just((a,Deep(Three(b,c,d),middle,suffix)))

val modulus = 1000000007.int64

fun build( index : int, tree : finger-tree ) : div finger-tree
  if index == 65536 then tree else build(index + 1, snoc(tree, Value(index.int64)))

fun churn( round : int64, remaining : int, tree : finger-tree, checksum : int64 ) : div (finger-tree,int64)
  if remaining == 0 then (tree,checksum) else
    match view-left(tree)
      Just((Value(x),rest)) ->
        val next = (x + round + 1.int64) % modulus
        churn(round + 1.int64, remaining - 1, snoc(rest,Value(next)), (checksum + x) % modulus)
      _ -> (tree,checksum)

fun drain( tree : finger-tree, checksum : int64 ) : div int64
  match view-left(tree)
    Nothing -> checksum
    Just((Value(x),rest)) -> drain(rest,(checksum + x) % modulus)
    _ -> checksum

pub fun main()
  val (tree,checksum) = churn(0.int64,1000000,build(0,Empty),0.int64)
  val result = drain(tree,checksum)
  if result != 66797929.int64 then
    println("FAIL: expected 66797929, got " ++ result.show)
    throw("wrong result")
