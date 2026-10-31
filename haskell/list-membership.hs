{-# LANGUAGE BangPatterns #-}

-- list-membership: 40000 membership queries against one 10000-element list
-- that the caller keeps between queries (reussir-lang/reussir#762). Every
-- query only reads the list; half of them miss and walk all of it.

module Main where

import Data.Int (Int64)

mem :: Int64 -> [Int64] -> Bool
mem !_ [] = False
mem !x (y : ys) = if x == y then True else mem x ys

-- [1 .. n]
buildList :: Int64 -> [Int64] -> [Int64]
buildList !n acc
  | n == 0 = acc
  | otherwise = buildList (n - 1) (n : acc)

search :: Int64 -> Int64 -> [Int64] -> Int -> Int
search !q !n xs !hits
  | q == 0 = hits
  | otherwise =
      let x = (q * 7919) `rem` (2 * n) + 1
       in search (q - 1) n xs (if mem x xs then hits + 1 else hits)

main :: IO ()
main = do
  let hits = search 40000 10000 (buildList 10000 []) 0
  if hits /= 20000
    then error ("FAIL: expected 20000, got " ++ show hits)
    else pure ()
