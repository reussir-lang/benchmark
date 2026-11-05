{-# LANGUAGE BangPatterns #-}
module Main where

import Control.Monad.ST (ST, runST)
import Data.Array.ST (STUArray, newArray_, readArray, writeArray)
import Data.Bits ((.&.), (.|.), shiftL, shiftR)
import Data.Int (Int64)
import Data.Word (Word32)
import System.Exit (exitFailure)

pixels :: Int
pixels = 262144

newImage :: ST s (STUArray s Int Word32)
newImage = newArray_ (0, pixels - 1)

channel :: Word32 -> Word32 -> Word32 -> Word32
channel source destination alpha =
  (source * alpha + destination * (255 - alpha) + 127) `quot` 255

blend :: Word32 -> Word32 -> Word32 -> Word32
blend destination source opacity =
  let !alpha = ((source `shiftR` 24) * opacity + 127) `quot` 255
      !red = channel (source .&. 255) (destination .&. 255) alpha
      !green = channel ((source `shiftR` 8) .&. 255) ((destination `shiftR` 8) .&. 255) alpha
      !blue = channel ((source `shiftR` 16) .&. 255) ((destination `shiftR` 16) .&. 255) alpha
  in red .|. (green `shiftL` 8) .|. (blue `shiftL` 16) .|. 0xff000000

composite :: STUArray s Int Word32 -> STUArray s Int Word32 -> Word32 -> ST s ()
composite destination source opacity = go 0
  where
    go !i
      | i == pixels = pure ()
      | otherwise = do
          s <- readArray source i
          d <- readArray destination i
          writeArray destination i (blend d s opacity)
          go (i + 1)

workload :: ST s Int64
workload = do
  source <- newImage
  destination <- newImage
  let initialize !i
        | i == pixels = pure ()
        | otherwise = do
            let k = fromIntegral i :: Word32
                s = ((k * 17 + 23) `rem` 256) .|. (((k * 43 + 7) `rem` 256) `shiftL` 8)
                  .|. (((k * 97 + 61) `rem` 256) `shiftL` 16) .|. (((k * 31 + 13) `rem` 256) `shiftL` 24)
                d = ((k * 29 + 5) `rem` 256) .|. (((k * 11 + 101) `rem` 256) `shiftL` 8)
                  .|. (((k * 67 + 19) `rem` 256) `shiftL` 16) .|. 0xff000000
            writeArray source i s
            writeArray destination i d
            initialize (i + 1)
      layers 0 = pure ()
      layers !n = composite destination source (96 + n `rem` 160) >> layers (n - 1)
      checksum !i !acc
        | i == pixels = pure acc
        | otherwise = do
            value <- readArray destination i
            checksum (i + 1) (acc + fromIntegral value)
  initialize 0
  layers 4096
  checksum 0 0

main :: IO ()
main = do
  let !actual = runST workload
  if actual == 1123699998887936 then pure ()
    else print actual >> exitFailure
