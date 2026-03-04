module Main where

data Expr
  = Val !Int
  | Var !Int
  | Add !Expr !Expr
  | Mul !Expr !Expr
  | Pow !Expr !Expr
  | Ln !Expr

pown :: Int -> Int -> Int
pown a b
  | b <= 0 = if b == 0 then 1 else 0
  | otherwise = a * pown a (b - 1)

exprAdd :: Expr -> Expr -> Expr
exprAdd n0 m0 =
  case (n0, m0) of
    (Val n, Val m) -> Val (n + m)
    (Val 0, _) -> m0
    (Val n, Add (Val m) f) -> exprAdd (Val (n + m)) f
    (Val _, _) -> Add n0 m0
    (Add f g, _) ->
      case m0 of
        Val 0 -> n0
        _ -> exprAdd f (exprAdd g m0)
    _ ->
      case m0 of
        Val 0 -> n0
        Val n -> exprAdd (Val n) n0
        Add (Val n) g -> exprAdd (Val n) (exprAdd n0 g)
        _ -> Add n0 m0

exprMul :: Expr -> Expr -> Expr
exprMul n0 m0 =
  case (n0, m0) of
    (Val n, Val m) -> Val (n * m)
    (Val 0, _) -> Val 0
    (Val 1, _) -> m0
    (Val n, Mul (Val m) f) -> exprMul (Val (n * m)) f
    (Val _, _) -> Mul n0 m0
    (Mul f g, _) ->
      case m0 of
        Val 0 -> Val 0
        Val 1 -> n0
        _ -> exprMul f (exprMul g m0)
    _ ->
      case m0 of
        Val 0 -> Val 0
        Val 1 -> n0
        Val n -> exprMul (Val n) n0
        Mul (Val n) g -> exprMul (Val n) (exprMul n0 g)
        _ -> Mul n0 m0

exprPow :: Expr -> Expr -> Expr
exprPow m0 n0 =
  case (m0, n0) of
    (Val m, Val n) -> Val (pown m n)
    (Val 0, _) -> Val 0
    (Val _, _) -> Pow m0 n0
    _ ->
      case n0 of
        Val 0 -> Val 1
        Val 1 -> m0
        _ -> Pow m0 n0

exprLn :: Expr -> Expr
exprLn n =
  case n of
    Val 1 -> Val 0
    _ -> Ln n

d :: Int -> Expr -> Expr
d x e =
  case e of
    Val _ -> Val 0
    Var y -> if x == y then Val 1 else Val 0
    Add f g -> exprAdd (d x f) (d x g)
    Mul f g ->
      exprAdd
        (exprMul f (d x g))
        (exprMul g (d x f))
    Pow f g ->
      exprMul
        (exprPow f g)
        ( exprAdd
            (exprMul (exprMul g (d x f)) (exprPow f (Val (-1))))
            (exprMul (exprLn f) (d x g))
        )
    Ln f -> exprMul (d x f) (exprPow f (Val (-1)))

countExpr :: Expr -> Int
countExpr e =
  case e of
    Val _ -> 1
    Var _ -> 1
    Add f g -> countExpr f + countExpr g
    Mul f g -> countExpr f + countExpr g
    Pow f g -> countExpr f + countExpr g
    Ln f -> countExpr f

nestAux :: Int -> Int -> Expr -> Expr
nestAux _s n x
  | n == 0 = x
  | otherwise = nestAux _s (n - 1) (d 0 x)

deriveTest :: Int
deriveTest =
  let x = Var 0
      f = exprPow x x
      res = nestAux 10 10 f
   in countExpr res

main :: IO ()
main = do
  let n = deriveTest
  if n /= 40230090
    then error ("FAIL: expected 40230090, got " ++ show n)
    else pure ()
