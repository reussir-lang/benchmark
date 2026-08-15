{-# LANGUAGE BangPatterns #-}

-- Std-collection workload on Haskell's standard ordered map
-- (Data.Map.Strict from containers — a persistent size-balanced tree).
-- Build 1M MINSTD-keyed inserts over a 524287 keyspace, churn 1M
-- insert/remove rounds, sum 1M lookups (-1 for a miss), then fold the
-- final map: result = lookup-sum + sum(key * 1000003 + value) + 7 * size.
--
-- During the two mutating phases a second draw per round decides
-- retention: when it is divisible by 512 (3,933 times over the run) the
-- current version is parked in slot (draw / 512) mod 8 of an
-- eight-version ring, where it stays shared until that slot is next
-- overwritten; a persistent tree parks a version by keeping the handle.
-- The checksum folds the final map and every ring slot, so retained
-- versions stay live and verified. Final size 401,258; each ring slot
-- ends holding a ~401k-entry version.
--
-- Heavily shared tier: retention fires ~15x more often than
-- ordered-map-shared, past the crossover where per-event full copies
-- dominate a mutable representation.

import Data.Int (Int64)
import qualified Data.Map.Strict as M
import System.Exit (exitFailure)

keyspace, buildN, churnN, lookupN, expected :: Int64
keyspace = 524287
buildN = 1000000
churnN = 1000000
lookupN = 1000000
expected = 946706648628515214

lcg :: Int64 -> Int64
lcg x = (x * 48271) `rem` 2147483647

setAt :: Int -> a -> [a] -> [a]
setAt n v xs = case splitAt n xs of
  (before, _ : after) -> before ++ v : after
  (before, []) -> before

retain :: Int64 -> M.Map Int64 Int64 -> [M.Map Int64 Int64] -> [M.Map Int64 Int64]
retain x m ring
  | x `rem` 512 == 0 = setAt (fromIntegral ((x `div` 512) `rem` 8)) m ring
  | otherwise = ring

buildLoop ::
  Int64 -> Int64 -> M.Map Int64 Int64 -> [M.Map Int64 Int64] ->
  (Int64, M.Map Int64 Int64, [M.Map Int64 Int64])
buildLoop !i !x !m ring
  | i == buildN = (x, m, ring)
  | otherwise =
      let x' = lcg x
          m' = M.insert (x' `rem` keyspace) i m
          x'' = lcg x'
       in buildLoop (i + 1) x'' m' (retain x'' m' ring)

churnLoop ::
  Int64 -> Int64 -> M.Map Int64 Int64 -> [M.Map Int64 Int64] ->
  (Int64, M.Map Int64 Int64, [M.Map Int64 Int64])
churnLoop !i !x !m ring
  | i == churnN = (x, m, ring)
  | otherwise =
      let x' = lcg x
          k = x' `rem` keyspace
          m' =
            if x' `rem` 4 == 3
              then M.delete k m
              else M.insert k (buildN + i) m
          x'' = lcg x'
       in churnLoop (i + 1) x'' m' (retain x'' m' ring)

lookupLoop :: Int64 -> Int64 -> M.Map Int64 Int64 -> Int64 -> Int64
lookupLoop !i !x !m !acc
  | i == lookupN = acc
  | otherwise =
      let x' = lcg x
       in lookupLoop (i + 1) x' m (acc + M.findWithDefault (-1) (x' `rem` keyspace) m)

foldOne :: M.Map Int64 Int64 -> Int64 -> Int64
foldOne m acc =
  acc
    + M.foldlWithKey' (\a k v -> a + k * 1000003 + v) 0 m
    + 7 * fromIntegral (M.size m)

main :: IO ()
main = do
  let (x1, built, ring1) = buildLoop 0 1 M.empty (replicate 8 M.empty)
      (x2, m, ring) = churnLoop 0 x1 built ring1
      acc = lookupLoop 0 x2 m 0
      result = foldr foldOne (foldOne m acc) ring
  if result == expected
    then pure ()
    else do
      putStrLn ("FAIL: expected " ++ show expected ++ ", got " ++ show result)
      exitFailure
