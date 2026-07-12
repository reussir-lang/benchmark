-- Quicksort workload — ST form: in-place Lomuto partition on a mutable
-- unboxed array, the same algorithm the other variants use. Same MINSTD
-- fill and checksum.
{-# LANGUAGE BangPatterns #-}

module Main where

import Control.Monad (forM_, when)
import Control.Monad.ST
import Data.Array.ST
import System.Exit (exitFailure)

lcg :: Int -> Int
lcg x = (x * 48271) `rem` 2147483647

fillST :: Int -> ST s (STUArray s Int Int)
fillST seed = do
  a <- newArray (0, 65535) 0
  let go 65536 _ = pure ()
      go !i !x = do
        let x1 = lcg x
        writeArray a i x1
        go (i + 1) x1
  go 0 seed
  pure a

swapST :: STUArray s Int Int -> Int -> Int -> ST s ()
swapST a i j = do
  x <- readArray a i
  y <- readArray a j
  writeArray a i y
  writeArray a j x

qsortST :: STUArray s Int Int -> Int -> Int -> ST s ()
qsortST a lo hi =
  when (lo < hi) $ do
    p <- readArray a hi
    let go !i !j
          | j == hi = pure i
          | otherwise = do
              v <- readArray a j
              if v < p
                then swapST a i j >> go (i + 1) (j + 1)
                else go i (j + 1)
    i <- go lo lo
    swapST a i hi
    qsortST a lo (i - 1)
    qsortST a (i + 1) hi

roundST :: Int -> ST s Int
roundST seed = do
  a <- fillST seed
  qsortST a 0 65535
  let go 65536 !prev !acc = pure acc
      go !k !prev !acc = do
        v <- readArray a k
        if prev > v
          then pure (-1)
          else go (k + 1) v ((acc + v) `rem` 1000000007)
  go 0 (-1) 0

main :: IO ()
main = do
  let acc =
        runST $ do
          let go 0 !a = pure a
              go !r !a = do
                c <- roundST (42 + r)
                go (r - 1) ((a + c) `rem` 1000000007)
          go (100 :: Int) 0
  if acc /= 276066679
    then putStrLn ("FAIL: expected 276066679, got " ++ show acc) >> exitFailure
    else pure ()
