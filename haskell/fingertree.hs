{-# LANGUAGE BangPatterns #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE MultiParamTypeClasses #-}

module Main where

import Data.FingerTree
import Data.Int (Int64)
import System.Exit (exitFailure)

newtype Item = Item Int64

instance Measured () Item where
  measure _ = ()

modulus :: Int64
modulus = 1000000007

build :: Int -> FingerTree () Item
build size = go 0 empty
  where
    go !i !tree
      | i == size = tree
      | otherwise = go (i + 1) (tree |> Item (fromIntegral i))

churn :: Int64 -> Int -> FingerTree () Item -> Int64 -> (FingerTree () Item, Int64)
churn !round !remaining !tree !checksum
  | remaining == 0 = (tree, checksum)
  | otherwise =
      case viewl tree of
        EmptyL -> error "unexpected empty finger tree"
        Item value :< rest ->
          let !next = (value + round + 1) `rem` modulus
              !checksum' = (checksum + value) `rem` modulus
           in churn (round + 1) (remaining - 1) (rest |> Item next) checksum'

drain :: FingerTree () Item -> Int64 -> Int64
drain !tree !checksum =
  case viewl tree of
    EmptyL -> checksum
    Item value :< rest -> drain rest ((checksum + value) `rem` modulus)

main :: IO ()
main = do
  let (tree, checksum) = churn 0 1000000 (build 65536) 0
      result = drain tree checksum
  if result /= 66797929
    then putStrLn ("FAIL: expected 66797929, got " ++ show result) >> exitFailure
    else pure ()
