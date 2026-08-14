{-# LANGUAGE BangPatterns #-}

-- Std-collection workload on Haskell's standard ordered map
-- (Data.Map.Strict from containers — a persistent size-balanced tree).
-- Build 1M MINSTD-keyed inserts over a 524287 keyspace, churn 1M
-- insert/remove rounds, sum 1M lookups (-1 for a miss), then fold the
-- final map: result = lookup-sum + sum(key * 1000003 + value) + 7 * size.
--
-- Linear variant: exactly one live version — the map handle is
-- threaded linearly through every round and nothing is retained, so
-- GHC's GC sees replaced nodes die young. Final size 400,944.

import Data.Int (Int64)
import qualified Data.Map.Strict as M
import System.Exit (exitFailure)

keyspace, buildN, churnN, lookupN, expected :: Int64
keyspace = 524287
buildN = 1000000
churnN = 1000000
lookupN = 1000000
expected = 105140861851414131

lcg :: Int64 -> Int64
lcg x = (x * 48271) `rem` 2147483647

buildLoop :: Int64 -> Int64 -> M.Map Int64 Int64 -> (Int64, M.Map Int64 Int64)
buildLoop !i !x !m
  | i == buildN = (x, m)
  | otherwise =
      let x' = lcg x
       in buildLoop (i + 1) x' (M.insert (x' `rem` keyspace) i m)

churnLoop :: Int64 -> Int64 -> M.Map Int64 Int64 -> (Int64, M.Map Int64 Int64)
churnLoop !i !x !m
  | i == churnN = (x, m)
  | otherwise =
      let x' = lcg x
          k = x' `rem` keyspace
          m' =
            if x' `rem` 4 == 3
              then M.delete k m
              else M.insert k (buildN + i) m
       in churnLoop (i + 1) x' m'

lookupLoop :: Int64 -> Int64 -> M.Map Int64 Int64 -> Int64 -> Int64
lookupLoop !i !x !m !acc
  | i == lookupN = acc
  | otherwise =
      let x' = lcg x
       in lookupLoop (i + 1) x' m (acc + M.findWithDefault (-1) (x' `rem` keyspace) m)

main :: IO ()
main = do
  let (x1, built) = buildLoop 0 1 M.empty
      (x2, m) = churnLoop 0 x1 built
      acc = lookupLoop 0 x2 m 0
      result =
        acc
          + M.foldlWithKey' (\a k v -> a + k * 1000003 + v) 0 m
          + 7 * fromIntegral (M.size m)
  if result == expected
    then pure ()
    else do
      putStrLn ("FAIL: expected " ++ show expected ++ ", got " ++ show result)
      exitFailure
