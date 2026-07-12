-- Game of Life, toroidal 64x64 — ST form: two mutable unboxed buffers
-- swapped each generation (the direct-mutation shape, inside ST). Same seed
-- hash, rule, and wrap as the other variants.
{-# LANGUAGE BangPatterns #-}

module Main where

import Control.Monad (forM_)
import Control.Monad.ST
import Data.Array.ST
import Data.Int (Int32)
import System.Exit (exitFailure)

n :: Int
n = 64

cells :: Int
cells = n * n

wrap :: Int -> Int
wrap x = (x + 64) `rem` 64

stepST :: STUArray s Int Int32 -> STUArray s Int Int32 -> ST s ()
stepST src dst =
  forM_ [0 .. cells - 1] $ \k -> do
    let i = k `quot` 64
        j = k `rem` 64
        im = wrap (i - 1)
        ip = wrap (i + 1)
        jm = wrap (j - 1)
        jp = wrap (j + 1)
    a <- readArray src (im * 64 + jm)
    b <- readArray src (im * 64 + j)
    c <- readArray src (im * 64 + jp)
    d <- readArray src (i * 64 + jm)
    e <- readArray src (i * 64 + jp)
    f <- readArray src (ip * 64 + jm)
    g <- readArray src (ip * 64 + j)
    h <- readArray src (ip * 64 + jp)
    alive <- readArray src (i * 64 + j)
    let !nb = a + b + c + d + e + f + g + h
        !out =
          if alive == 1
            then (if nb == 2 || nb == 3 then 1 else 0)
            else (if nb == 3 then 1 else 0)
    writeArray dst k out

lifeST :: Int -> ST s Int
lifeST gens = do
  g0 <- newListArray (0, cells - 1) [seedCell k | k <- [0 .. cells - 1]]
  g1 <- newArray (0, cells - 1) 0
  final <- go gens g0 g1
  xs <- getElems final
  pure (sum (map fromIntegral xs))
  where
    seedCell k =
      let i = k `quot` 64
          j = k `rem` 64
       in if (i * 2654435761 + j * 40503 + i * j * 2246822519) `rem` 97 < 33
            then 1 :: Int32
            else 0
    go 0 src _ = pure src
    go !k src dst = stepST src dst >> go (k - 1) dst src

main :: IO ()
main = do
  let pop = runST (lifeST 50000)
  if pop /= 115
    then putStrLn ("FAIL: expected 115, got " ++ show pop) >> exitFailure
    else pure ()
