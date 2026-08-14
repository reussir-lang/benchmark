{-# LANGUAGE BangPatterns #-}

-- Std-collection workload on Haskell's de-facto standard hash map
-- (Data.HashMap.Strict from unordered-containers — a persistent HAMT,
-- the same representation family as Reussir's std HashMap). Same
-- workload and checksum as ordered-map.hs; the checksum is
-- iteration-order independent so the representations agree.

import Data.Int (Int64)
import qualified Data.HashMap.Strict as HM
import System.Exit (exitFailure)

keyspace, buildN, churnN, lookupN, expected :: Int64
keyspace = 524287
buildN = 1000000
churnN = 1000000
lookupN = 1000000
expected = 105140861851414131

lcg :: Int64 -> Int64
lcg x = (x * 48271) `rem` 2147483647

buildLoop :: Int64 -> Int64 -> HM.HashMap Int64 Int64 -> (Int64, HM.HashMap Int64 Int64)
buildLoop !i !x !m
  | i == buildN = (x, m)
  | otherwise =
      let x' = lcg x
       in buildLoop (i + 1) x' (HM.insert (x' `rem` keyspace) i m)

churnLoop :: Int64 -> Int64 -> HM.HashMap Int64 Int64 -> (Int64, HM.HashMap Int64 Int64)
churnLoop !i !x !m
  | i == churnN = (x, m)
  | otherwise =
      let x' = lcg x
          k = x' `rem` keyspace
          m' =
            if x' `rem` 4 == 3
              then HM.delete k m
              else HM.insert k (buildN + i) m
       in churnLoop (i + 1) x' m'

lookupLoop :: Int64 -> Int64 -> HM.HashMap Int64 Int64 -> Int64 -> Int64
lookupLoop !i !x !m !acc
  | i == lookupN = acc
  | otherwise =
      let x' = lcg x
       in lookupLoop (i + 1) x' m (acc + HM.findWithDefault (-1) (x' `rem` keyspace) m)

main :: IO ()
main = do
  let (x1, built) = buildLoop 0 1 HM.empty
      (x2, m) = churnLoop 0 x1 built
      acc = lookupLoop 0 x2 m 0
      folded = HM.foldlWithKey' (\a k v -> a + k * 1000003 + v) 0 m
      result = acc + folded + 7 * fromIntegral (HM.size m)
  if result == expected
    then pure ()
    else do
      putStrLn ("FAIL: expected " ++ show expected ++ ", got " ++ show result)
      exitFailure
