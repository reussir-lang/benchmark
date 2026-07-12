-- Game of Life, toroidal 64x64 — purely functional form: each generation is
-- a fresh immutable unboxed array built from the previous one (the
-- tabulate-equivalent). Same seed hash, rule, and wrap as the other
-- variants.
{-# LANGUAGE BangPatterns #-}

module Main where

import Data.Array.Unboxed
import Data.Int (Int32)
import System.Exit (exitFailure)

n :: Int
n = 64

cells :: Int
cells = n * n

wrap :: Int -> Int
wrap x = (x + 64) `rem` 64

step :: UArray Int Int32 -> UArray Int Int32
step g = listArray (0, cells - 1) [cell k | k <- [0 .. cells - 1]]
  where
    cell k =
      let i = k `quot` 64
          j = k `rem` 64
          im = wrap (i - 1)
          ip = wrap (i + 1)
          jm = wrap (j - 1)
          jp = wrap (j + 1)
          nb =
            g ! (im * 64 + jm) + g ! (im * 64 + j) + g ! (im * 64 + jp)
              + g ! (i * 64 + jm) + g ! (i * 64 + jp)
              + g ! (ip * 64 + jm) + g ! (ip * 64 + j) + g ! (ip * 64 + jp)
          alive = g ! (i * 64 + j)
       in if alive == 1
            then (if nb == 2 || nb == 3 then 1 else 0)
            else (if nb == 3 then 1 else 0)

run :: Int -> UArray Int Int32 -> UArray Int Int32
run 0 !g = g
run k !g = run (k - 1) (step g)

seedGrid :: UArray Int Int32
seedGrid = listArray (0, cells - 1) [cell k | k <- [0 .. cells - 1]]
  where
    cell k =
      let i = k `quot` 64
          j = k `rem` 64
       in if (i * 2654435761 + j * 40503 + i * j * 2246822519) `rem` 97 < 33
            then 1
            else 0

population :: UArray Int Int32 -> Int
population g = sum (map fromIntegral (elems g))

main :: IO ()
main = do
  let pop = population (run 50000 seedGrid)
  if pop /= 115
    then putStrLn ("FAIL: expected 115, got " ++ show pop) >> exitFailure
    else pure ()
