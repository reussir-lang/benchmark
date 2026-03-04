type term
  Var(index: int)
  App(t1: term, t2: term)
  Lam(body: term)

div type value
  VVar(level: int)
  VApp(v1: value, v2: value)
  VLam(body: value -> value)

fun ap(t: value, u: value) : value
  match t
    VLam(f) -> f(u)
    _ -> VApp(t, u)

fun ap2(t: value, u: value, v: value) : value
  ap(ap(t, u), v)

fun n2() : value
  VLam(fn(s: value) -> VLam(fn(z: value) -> ap(s, ap(s, z))))

fun n5() : value
  VLam(fn(s: value) -> VLam(fn(z: value) -> ap(s, ap(s, ap(s, ap(s, ap(s, z)))))))

fun mul() : value
  VLam(
    fn(a: value) ->
      VLam(
        fn(b: value) ->
          VLam(
            fn(s: value) ->
              VLam(fn(z: value) -> ap(ap(a, ap(b, s)), z))
          )
      )
  )

fun suc(n: value) : value
  VLam(fn(s: value) -> VLam(fn(z: value) -> ap(s, ap2(n, s, z))))

fun n10() : value
  ap2(mul(), n2(), n5())

fun n20() : value
  ap2(mul(), n2(), n10())

fun n21() : value
  suc(n20())

fun n22() : value
  suc(n21())

fun leaf() : value
  VLam(fn(l: value) -> VLam(fn(_: value) -> l))

fun node() : value
  VLam(
    fn(t1: value) ->
      VLam(
        fn(t2: value) ->
          VLam(
            fn(_: value) ->
              VLam(fn(n: value) -> ap2(n, t1, t2))
          )
      )
  )

fun full-tree() : value
  VLam(fn(n: value) -> ap2(n, VLam(fn(t: value) -> ap2(node(), t, t)), leaf()))

fun quote(level: int, v: value) : <div> term
  match v
    VVar(x) -> Var(level - x - 1)
    VLam(f) -> Lam(quote(level.inc, f(VVar(level))))
    VApp(t, u) -> App(quote(level, t), quote(level, u))

fun quote0(v: value) : <div> term
  quote(0, v)

fun force(t: term) : int
  match t
    Var(_) -> 0
    App(t1, t2) -> force(t1) + force(t2)
    Lam(body) -> force(body).inc

pub fun main()
  val tree8m = ap(full-tree(), n22())
  val lam-count = force(quote0(tree8m))
  lam-count.show.println
