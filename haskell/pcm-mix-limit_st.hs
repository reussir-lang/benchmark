{-# LANGUAGE BangPatterns #-}
module Main where

import Control.Monad.ST (ST, runST)
import Data.Array.ST (STUArray, newArray, newArray_, readArray, writeArray)
import Data.Int (Int32, Int64)
import System.Exit (exitFailure)

samples :: Int
samples = 262144

newSource :: ST s (STUArray s Int Int32)
newSource = newArray_ (0, samples - 1)

newDestination :: ST s (STUArray s Int Int32)
newDestination = newArray (0, samples - 1) 0

limit :: Int32 -> Int32
limit sample =
  let knee | sample > 16384 = 16384 + (sample - 16384) `quot` 2
           | sample < -16384 = -16384 + (sample + 16384) `quot` 2
           | otherwise = sample
  in max (-32768) (min 32767 knee)

mix :: STUArray s Int Int32 -> STUArray s Int Int32 -> Int32 -> ST s ()
mix destination source gain = go 0
  where
    go !i
      | i == samples = pure ()
      | otherwise = do
          s <- readArray source i
          d <- readArray destination i
          let !scaled = s * gain `quot` 32768
              !faded = scaled * fromIntegral (i `quot` 8) `quot` 32768
          writeArray destination i (limit (d + faded))
          go (i + 1)

workload :: ST s Int64
workload = do
  source <- newSource
  destination <- newDestination
  let initialize !i
        | i == samples = pure ()
        | otherwise = do
            let fundamental = (i * 97) `rem` 65536 - 32768
                harmonic = (i * 271) `rem` 65536 - 32768
                noise = (i * 8191 + 37) `rem` 1024 - 512
            writeArray source i (fromIntegral (fundamental `quot` 2 + harmonic `quot` 4 + noise))
            initialize (i + 1)
      tracks 0 = pure ()
      tracks !n = do
        mix destination source (fromIntegral ((n * 1103) `rem` 98304 - 49152))
        tracks (n - 1)
      energy !i !acc
        | i == samples = pure acc
        | otherwise = do
            sample <- readArray destination i
            let !value = fromIntegral sample :: Int64
            energy (i + 1) (acc + value * value)
  initialize 0
  tracks (8192 :: Int)
  energy 0 0

main :: IO ()
main = do
  let !actual = runST workload
  if actual == 124776496343097 then pure ()
    else print actual >> exitFailure
