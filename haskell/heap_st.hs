-- Binary heap maintenance under a Gaussian workload — ST form: min-heap of
-- 65535 Int64 values in an STUArray, Irwin-Hall draws (sum of 12 consecutive MINSTD
-- outputs), 6.5M rounds of unconditional replace-top. Checksum = (evicted
-- minima + final contents) mod 1e9+7.
{-# LANGUAGE BangPatterns #-}

module Main where

import Control.Monad.ST
import Data.Array.ST
import Data.Int (Int64)
import System.Exit (exitFailure)

n :: Int
n = 65535

p :: Int64
p = 1000000007

lcg :: Int64 -> Int64
lcg x = (x * 48271) `rem` 2147483647

gauss :: Int64 -> (Int64, Int64)
gauss = go 12 0
  where
    go 0 !s !x = (s, x)
    go !k !s !x = let x1 = lcg x in go (k - 1) (s + x1) x1

siftUp :: STUArray s Int Int64 -> Int -> ST s ()
siftUp a = go
  where
    go 0 = pure ()
    go !i = do
      let q = (i - 1) `quot` 2
      vi <- readArray a i
      vq <- readArray a q
      if vi < vq
        then writeArray a i vq >> writeArray a q vi >> go q
        else pure ()

siftDown :: STUArray s Int Int64 -> Int -> ST s ()
siftDown a = go
  where
    go !i = do
      let l = 2 * i + 1
      if l >= n
        then pure ()
        else do
          let r = l + 1
          vl <- readArray a l
          c <-
            if r < n
              then do
                vr <- readArray a r
                pure (if vr < vl then r else l)
              else pure l
          vc <- readArray a c
          vi <- readArray a i
          if vc < vi
            then writeArray a i vc >> writeArray a c vi >> go c
            else pure ()

heapTest :: Int -> Int64
heapTest m = runST $ do
  a <- newArray (0, n - 1) 0
  let buildGo !k !x
        | k == n = pure x
        | otherwise = do
            let (g, x') = gauss x
            writeArray a k g
            siftUp a k
            buildGo (k + 1) x'
  x0 <- buildGo 0 20260711
  let maintainGo 0 _ !acc = pure acc
      maintainGo !k !x !acc = do
        let (g, x') = gauss x
        top <- readArray a 0
        writeArray a 0 (top + g)
        siftDown a 0
        maintainGo (k - 1) x' ((acc + top) `rem` p)
  acc <- maintainGo m x0 0
  let sumGo !k !s
        | k == n = pure s
        | otherwise = do
            v <- readArray a k
            sumGo (k + 1) ((s + v) `rem` p)
  s <- sumGo 0 0
  pure ((acc + s) `rem` p)

main :: IO ()
main = do
  let c = heapTest 6500000
  if c /= 558972311
    then putStrLn ("FAIL: expected 558972311, got " ++ show c) >> exitFailure
    else pure ()
