{-# LANGUAGE BangPatterns #-}

-- The first 10000 decimal digits of pi with Gibbons' unbounded spigot (the
-- Computer Language Benchmarks Game algorithm), folded into a rolling hash.
module Main where

modulus :: Integer
modulus = 1000000007

spigot :: Int -> Int -> Integer -> Integer -> Integer -> Integer -> Integer -> Integer -> Integer
spigot !count !i !k0 !k10 !n0 !a0 !d0 !h
  | a < n = spigot count i k k1 n a d h
  | d <= u = spigot count i k k1 n a d h
  | i + 1 >= count = h'
  | otherwise = spigot count (i + 1) k k1 (n * 10) ((a - d * q) * 10) d h'
  where
    k = k0 + 1
    k1 = k10 + 2
    n = n0 * k
    a = (a0 + n0 * 2) * k1
    d = d0 * k1
    (q, r) = (n * 3 + a) `quotRem` d
    u = r + n
    h' = (h * 10 + q) `rem` modulus

main :: IO ()
main = do
  let r = spigot 10000 0 0 1 1 0 1 0
  if r /= 334354775
    then error ("FAIL: expected 334354775, got " ++ show r)
    else pure ()
