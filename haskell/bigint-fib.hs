{-# LANGUAGE BangPatterns #-}

-- Iterative Fibonacci over Integer: 600000 steps of (a, b) -> (b, a + b), so
-- both operands soon grow far beyond a machine word.
module Main where

fibLoop :: Int -> Integer -> Integer -> Integer
fibLoop 0 !a _ = a
fibLoop n !a !b = fibLoop (n - 1) b (a + b)

main :: IO ()
main = do
  let r = fibLoop 600000 0 1 `rem` 1000000007
  if r /= 555579099
    then error ("FAIL: expected 555579099, got " ++ show r)
    else pure ()
