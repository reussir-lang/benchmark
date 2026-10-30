{-# LANGUAGE BangPatterns #-}

-- Total Collatz trajectory length over the starting values 1 .. 999999 in
-- Integer arithmetic. Every intermediate value stays below 2^37, so this
-- measures the small-integer path.
module Main where

steps :: Integer -> Int -> Int
steps 1 !c = c
steps n !c
  | even n = steps (n `quot` 2) (c + 1)
  | otherwise = steps (3 * n + 1) (c + 1)

total :: Int -> Int -> Int
total !s !acc
  | s >= 1000000 = acc
  | otherwise = total (s + 1) (acc + steps (toInteger s) 0)

main :: IO ()
main = do
  let r = total 1 0
  if r /= 131434272
    then error ("FAIL: expected 131434272, got " ++ show r)
    else pure ()
