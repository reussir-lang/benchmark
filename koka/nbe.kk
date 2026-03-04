type term
  Var(id: int)
  Lam(id: int, body: term)
  App(t1: term, t2: term)
  Let(id: int, value: term, body: term)

div type value
  VVar(id: int)
  VApp(v1: value, v2: value)
  VLam(id: int, body: value -> value)

type env
    EnvCons(id: int, value: value, env: env)
    EnvNil

type names
    NameCons(id: int, names: names)
    NameNil

fun max-of-names(n: names, acc: int) : int
    match n
        NameCons(id, n1) -> max-of-names(n1, max(acc, id))
        NameNil -> acc

fun names-of-env(env: env, acc: names) : names
    match env
        EnvCons(id, _, env1) -> names-of-env(env1, NameCons(id, acc))
        EnvNil -> acc

fun fresh(n: names) : int
    max-of-names(n, 0).inc

fun vapp(v1: value, v2: value) : value
    match v1
        VLam(_, body) -> body(v2)
        _ -> VApp(v1, v2)

fun lookup(env: env, id: int) : value
    match env
        EnvCons(id1, v, env1) -> if id == id1 then v else lookup(env1, id)
        EnvNil -> VVar(id)

fun eval(env: env, x: term) : value
    match x
        Var(id) -> lookup(env, id)
        App(t, u) -> vapp(eval(env, t), eval(env, u))
        Lam(x, t) -> VLam(x, fn(u: value) -> eval(EnvCons(x, u, env), t))
        Let(x, t, u) -> eval(EnvCons(x, eval(env, t), env), u)

fun quote(n: names, v: value) : <div> term
    match v
        VVar(i) -> Var(i)
        VApp(v1, v2) -> App(quote(n, v1), quote(n, v2))
        VLam(_, f) -> val y = fresh(n) in Lam(y, quote(NameCons(y, n), f(VVar(y))))

fun norm-form(env: env, t: term) : <div> term
    quote(names-of-env(env, NameNil), eval(env, t))

fun five() : term
    Lam(0, Lam(1, App(Var(0), App(Var(0), App(Var(0), App(Var(0), App(Var(0), Var(1))))))))

fun add() : term
    Lam(0, Lam(1, Lam(2, Lam(3, App(App(Var(0), Var(2)), App(App(Var(1), Var(2)), Var(3)))))))

fun mul() : term
    Lam(0, Lam(1, Lam(2, Lam(3, App(App(Var(0), App(Var(1), Var(2))), Var(3))))))

fun ten() : term
    val x = five()
    val y = add()
    App(App(y, x), x)

fun hundred() : term
    val x = ten()
    val y = mul()
    App(App(y, x), x)

fun two-hundred() : term
    val x = hundred()
    val y = add()
    App(App(y, x), x)

fun thousand() : term
    val x = hundred()
    val z = ten()
    val y = mul()
    App(App(y, x), z)

fun term200000() : term
    val x = two-hundred()
    val y = mul()
    val z = thousand()
    App(App(y, x), z)

fun term40000000() : term
    val x = term200000()
    val y = mul()
    val z = two-hundred()
    App(App(y, z), x)

fun nf-to-int(t: term, acc: int) : int
    match t
        Lam(_, x) -> nf-to-int(x, acc)
        App(_, x) -> nf-to-int(x, acc.inc)
        _ -> acc

fun main()
    val t = term40000000()
    val n = norm-form(EnvNil, t)
    nf-to-int(n, 0).show.println
