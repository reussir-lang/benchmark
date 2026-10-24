{-# LANGUAGE BangPatterns #-}

-- 120000! by sequential multiplication 2 * 3 * ... * n: a growing big
-- integer times a word-sized factor.
module Main where

factLoop :: Int -> Int -> Integer -> Integer
factLoop !i !n !acc
  | i > n = acc
  | otherwise = factLoop (i + 1) n (acc * toInteger i)

main :: IO ()
main = do
  let r = factLoop 2 120000 1 `rem` 1000000007
  if r /= 118586228
    then error ("FAIL: expected 118586228, got " ++ show r)
    else pure ()
