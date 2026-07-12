-- Quicksort workload — purely functional form: the classic list quicksort
-- (Haskell has no persistent array with efficient functional update in the
-- boot libraries, so lists are the idiomatic pure structure). Same MINSTD
-- fill and checksum as the other variants; element order before sorting is
-- irrelevant to the result.
{-# LANGUAGE BangPatterns #-}

module Main where

import Data.List (foldl')
import System.Exit (exitFailure)

lcg :: Int -> Int
lcg x = (x * 48271) `rem` 2147483647

fill :: Int -> [Int]
fill seed = go 65536 seed []
  where
    go :: Int -> Int -> [Int] -> [Int]
    go 0 _ acc = acc
    go !k !x acc = let x1 = lcg x in go (k - 1) x1 (x1 : acc)

qsort :: [Int] -> [Int]
qsort [] = []
qsort (p : xs) = qsort [x | x <- xs, x < p] ++ p : qsort [x | x <- xs, x >= p]

checksum :: [Int] -> Int
checksum = go (-1) 0
  where
    go _ !acc [] = acc
    go !prev !acc (v : vs)
      | prev > v = -1
      | otherwise = go v ((acc + v) `rem` 1000000007) vs

main :: IO ()
main = do
  let rounds = 400
      acc =
        foldl'
          (\ !a r -> (a + checksum (qsort (fill (42 + r)))) `rem` 1000000007)
          0
          (reverse [1 .. rounds])
  if acc /= 853505117
    then putStrLn ("FAIL: expected 853505117, got " ++ show acc) >> exitFailure
    else pure ()
