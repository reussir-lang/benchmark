{-# LANGUAGE BangPatterns #-}

-- The binomial row C(200000, i) by the multiplicative recurrence
-- C(n, i + 1) = C(n, i) * (n - i) / (i + 1): every division is exact, by a
-- word-sized divisor. The row must sum to 2^n and end at 1.
module Main where

row :: Int -> Int -> Integer -> Integer -> (Integer, Integer)
row !n !i !c !s
  | i >= n = (c, s)
  | otherwise =
      let c' = c * toInteger (n - i) `quot` toInteger (i + 1)
       in row n (i + 1) c' (s + c')

main :: IO ()
main = do
  let (lastC, total) = row 200000 0 1 1
      r = total `rem` 1000000007
  if lastC /= 1 || r /= 175895282
    then error ("FAIL: expected last 1 and 175895282, got " ++ show lastC ++ " and " ++ show r)
    else pure ()
