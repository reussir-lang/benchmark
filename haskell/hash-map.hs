{-# LANGUAGE BangPatterns #-}

-- Std-collection workload on Haskell's de-facto standard hash map
-- (Data.HashMap.Strict from unordered-containers — a persistent HAMT,
-- the same representation family as Reussir's std HashMap). Large and
-- broad: keys are raw MINSTD draws, uniform over [1, 2^31-2]; MINSTD
-- is a full-period permutation, so fresh draws never repeat, and
-- removals plus the hit half of the lookups replay the build key
-- stream through a second MINSTD state. Build 4M inserts, churn 2M
-- rounds, 2M lookups alternating replayed hits and fresh misses.
-- Final size 4,999,834; the checksum is iteration-order independent so
-- all representations agree.

import Data.Int (Int64)
import qualified Data.HashMap.Strict as HM
import System.Exit (exitFailure)

buildN, churnN, lookupN, expected :: Int64
buildN = 4000000
churnN = 2000000
lookupN = 2000000
expected = 166401892080070584

lcg :: Int64 -> Int64
lcg x = (x * 48271) `rem` 2147483647

buildLoop :: Int64 -> Int64 -> HM.HashMap Int64 Int64 -> HM.HashMap Int64 Int64
buildLoop !i !x !m
  | i == buildN = m
  | otherwise =
      let x' = lcg x
       in buildLoop (i + 1) x' (HM.insert x' i m)

churnLoop :: Int64 -> Int64 -> Int64 -> HM.HashMap Int64 Int64 -> (Int64, Int64, HM.HashMap Int64 Int64)
churnLoop !i !x !r !m
  | i == churnN = (x, r, m)
  | otherwise =
      let x' = lcg x
       in if x' `rem` 4 == 3
            then let r' = lcg r in churnLoop (i + 1) x' r' (HM.delete r' m)
            else churnLoop (i + 1) x' r (HM.insert x' (buildN + i) m)

lookupLoop :: Int64 -> Int64 -> Int64 -> HM.HashMap Int64 Int64 -> Int64 -> Int64
lookupLoop !i !x !r !m !acc
  | i == lookupN = acc
  | otherwise =
      let x' = lcg x
       in if x' `rem` 2 == 0
            then
              let r' = lcg r
               in lookupLoop (i + 1) x' r' m (acc + HM.findWithDefault (-1) r' m)
            else lookupLoop (i + 1) x' r m (acc + HM.findWithDefault (-1) x' m)

main :: IO ()
main = do
  let built = buildLoop 0 1 HM.empty
      (x2, r1, m) = churnLoop 0 111912599 1 built
      acc = lookupLoop 0 x2 r1 m 0
      folded = HM.foldlWithKey' (\a k v -> a + k * 31 + v) 0 m
      result = acc + folded + 7 * fromIntegral (HM.size m)
  if result == expected
    then pure ()
    else do
      putStrLn ("FAIL: expected " ++ show expected ++ ", got " ++ show result)
      exitFailure
