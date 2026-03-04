{-# LANGUAGE BangPatterns #-}

module Main where

data Value
  = VVar !Int
  | VApp !Value !Value
  | VLam (Value -> Value)

data Tm
  = Var !Int
  | App !Tm !Tm
  | Lam !Tm

ap :: Value -> Value -> Value
ap t u =
  case t of
    VLam f -> f u
    _ -> VApp t u

ap2 :: Value -> Value -> Value -> Value
ap2 t u v = ap (ap t u) v

n2 :: Value
n2 = VLam (\s -> VLam (\z -> ap s (ap s z)))

n5 :: Value
n5 = VLam (\s -> VLam (\z -> ap s (ap s (ap s (ap s (ap s z))))))

mul :: Value
mul =
  VLam
    ( \a ->
        VLam
          ( \b ->
              VLam
                (\s -> VLam (\z -> ap (ap a (ap b s)) z))
          )
    )

suc :: Value -> Value
suc n = VLam (\s -> VLam (\z -> ap s (ap2 n s z)))

n10 :: Value
n10 = ap2 mul n2 n5

n20 :: Value
n20 = ap2 mul n2 n10

n21 :: Value
n21 = suc n20

n22 :: Value
n22 = suc n21

leaf :: Value
leaf = VLam (\l -> VLam (\_ -> l))

node :: Value
node =
  VLam
    ( \t1 ->
        VLam
          ( \t2 ->
              VLam
                (\_ -> VLam (\n -> ap2 n t1 t2))
          )
    )

fullTree :: Value
fullTree = VLam (\n -> ap2 n (VLam (\t -> ap2 node t t)) leaf)

quote :: Int -> Value -> Tm
quote l v =
  case v of
    VVar x -> Var (l - x - 1)
    VLam t -> Lam (quote (l + 1) (t (VVar l)))
    VApp t u -> App (quote l t) (quote l u)

quote0 :: Value -> Tm
quote0 = quote 0

force :: Tm -> Int
force t =
  case t of
    Var _ -> 0
    App t1 t2 -> force t1 + force t2
    Lam body -> 1 + force body

main :: IO ()
main = do
  let !lamCount = force (quote0 (ap fullTree n22))
  if lamCount /= 16777214
    then error ("FAIL: expected 16777214, got " ++ show lamCount)
    else pure ()
