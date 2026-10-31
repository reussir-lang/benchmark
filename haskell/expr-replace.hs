{-# LANGUAGE BangPatterns #-}

-- expr-replace: substitution that keeps every unchanged subterm, the shape of
-- Lean's Expr.replace. The term is a balanced sum of 256 summands
-- Var(i `mod` 16) * P that all share one polynomial P of 4096 literals. Each
-- of 100 rounds substitutes one variable of the same retained term. A
-- subterm is rebuilt only where the variable occurs, which an occurs check
-- decides first (Lean caches that answer in each Expr; here it is
-- recomputed). The check reads all of P at every summand it reaches, and P
-- is shared.

module Main where

import Data.Int (Int64)

data Expr = Lit !Int64 | Var !Int64 | Add !Expr !Expr | Mul !Expr !Expr

poly :: Int -> Int64 -> Expr
poly 0 !s = Lit (s `rem` 7 + 1)
poly d !s =
  let l = poly (d - 1) (2 * s)
      r = poly (d - 1) (2 * s + 1)
   in if odd d then Add l r else Mul l r

-- Summands lo .. hi-1 as a balanced sum.
sumE :: Int64 -> Int64 -> Expr -> Expr
sumE !lo !hi p
  | hi - lo == 1 = Mul (Var (lo `rem` 16)) p
  | otherwise =
      let mid = (lo + hi) `quot` 2
       in Add (sumE lo mid p) (sumE mid hi p)

occurs :: Int64 -> Expr -> Bool
occurs !_ (Lit _) = False
occurs !v (Var x) = x == v
occurs !v (Add a b) = occurs v a || occurs v b
occurs !v (Mul a b) = occurs v a || occurs v b

replace :: Int64 -> Int64 -> Expr -> Expr
replace !v !c e
  | occurs v e = case e of
      Var _ -> Lit c
      Add a b -> Add (replace v c a) (replace v c b)
      Mul a b -> Mul (replace v c a) (replace v c b)
      Lit _ -> e
  | otherwise = e

leaf :: Expr -> Int64
leaf (Lit c) = c
leaf (Var y) = y
leaf _ = 0

-- Sum of the summands' factors (never enters the polynomial).
factors :: Expr -> Int64
factors (Add a b) = factors a + factors b
factors (Mul x _) = leaf x
factors _ = 0

rounds :: Int64 -> Int64 -> Expr -> Int64 -> Int64
rounds !k !n base !acc
  | k == n = acc
  | otherwise = rounds (k + 1) n base (acc + factors (replace (k `rem` 16) k base))

main :: IO ()
main = do
  let base = sumE 0 256 (poly 12 1)
      r = rounds 0 100 base 0
  if r /= 259584
    then error ("FAIL: expected 259584, got " ++ show r)
    else pure ()
