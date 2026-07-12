type expr =
  | Val of int
  | Var of int
  | Add of expr * expr
  | Mul of expr * expr
  | Pow of expr * expr
  | Ln of expr

let rec pown a b = if b <= 0 then if b = 0 then 1 else 0 else a * pown a (b - 1)

let rec expr_add n0 m0 =
  match (n0, m0) with
  | Val n, Val m -> Val (n + m)
  | Val 0, _ -> m0
  | Val n, Add (Val m, f) -> expr_add (Val (n + m)) f
  | Val _, _ -> Add (n0, m0)
  | Add (f, g), Val 0 -> n0
  | Add (f, g), _ -> expr_add f (expr_add g m0)
  | _, Val 0 -> n0
  | _, Val n -> expr_add (Val n) n0
  | _, Add (Val n, g) -> expr_add (Val n) (expr_add n0 g)
  | _ -> Add (n0, m0)

let rec expr_mul n0 m0 =
  match (n0, m0) with
  | Val n, Val m -> Val (n * m)
  | Val 0, _ -> Val 0
  | Val 1, _ -> m0
  | Val n, Mul (Val m, f) -> expr_mul (Val (n * m)) f
  | Val _, _ -> Mul (n0, m0)
  | Mul (f, g), Val 0 -> Val 0
  | Mul (f, g), Val 1 -> n0
  | Mul (f, g), _ -> expr_mul f (expr_mul g m0)
  | _, Val 0 -> Val 0
  | _, Val 1 -> n0
  | _, Val n -> expr_mul (Val n) n0
  | _, Mul (Val n, g) -> expr_mul (Val n) (expr_mul n0 g)
  | _ -> Mul (n0, m0)

let expr_pow m0 n0 =
  match (m0, n0) with
  | Val m, Val n -> Val (pown m n)
  | Val 0, _ -> Val 0
  | Val _, _ -> Pow (m0, n0)
  | _, Val 0 -> Val 1
  | _, Val 1 -> m0
  | _ -> Pow (m0, n0)

let expr_ln = function Val 1 -> Val 0 | value -> Ln value

let rec d x = function
  | Val _ -> Val 0
  | Var y -> if x = y then Val 1 else Val 0
  | Add (f, g) -> expr_add (d x f) (d x g)
  | Mul (f, g) -> expr_add (expr_mul f (d x g)) (expr_mul g (d x f))
  | Pow (f, g) ->
      expr_mul (expr_pow f g)
        (expr_add
           (expr_mul (expr_mul g (d x f)) (expr_pow f (Val (-1))))
           (expr_mul (expr_ln f) (d x g)))
  | Ln f -> expr_mul (d x f) (expr_pow f (Val (-1)))

let rec right_depth = function
  | Val _ | Var _ -> 1
  | Add (_, g) | Mul (_, g) | Pow (_, g) -> right_depth g + 1
  | Ln f -> right_depth f + 1

let rec nest_aux n value = if n = 0 then value else nest_aux (n - 1) (d 0 value)

let derive_test seed =
  let x = Var 0 in
  right_depth (nest_aux 10 (expr_pow x x)) + seed

let () =
  let result = derive_test 0 in
  if result <> 524 then (
    Printf.eprintf "FAIL: expected 524, got %d\n" result;
    exit 1)
