{-# LANGUAGE BangPatterns #-}

-- Std-collection workload on Haskell's de-facto standard hash map
-- (Data.HashMap.Strict from unordered-containers — a persistent HAMT,
-- the same representation family as Reussir's std HashMap). Zipfian
-- mixed-op workload: keys follow an integer-only octave Zipf
-- (theta ~ 1) — a stratum s drawn uniform in [0, 24), then a key
-- uniform in [2^s, 2^(s+1)), so every octave carries equal mass and
-- per-key probability decays as 1/key. 2M rounds, each drawing op,
-- stratum, key from one MINSTD stream: 9/16 insert, 5/16 delete, 2/16
-- lookup (sum, -1 on miss). Deletes land on present keys ~48% of the
-- time.
--
-- After each round one more draw decides retention: when it is
-- divisible by 8192 (266 times over the run) the current version is
-- parked in slot (draw / 8192) mod 8 of an eight-version ring, where
-- it stays shared until that slot is next overwritten. A persistent
-- HAMT parks a version by keeping the handle; nothing is copied at the
-- event. The checksum folds the working map and every ring slot, so
-- retained versions stay live and verified. Final size 373,649; each
-- ring slot ends holding a ~360k-entry version. The checksum is
-- iteration-order independent so all representations agree.

import Data.Bits (shiftL)
import Data.Int (Int64)
import qualified Data.HashMap.Strict as HM
import System.Exit (exitFailure)

opsN, expected :: Int64
opsN = 2000000
expected = 317327888655435

lcg :: Int64 -> Int64
lcg x = (x * 48271) `rem` 2147483647

foldOne :: HM.HashMap Int64 Int64 -> Int64 -> Int64
foldOne m acc =
  acc
    + HM.foldlWithKey' (\a k v -> a + k * 31 + v) 0 m
    + 7 * fromIntegral (HM.size m)

setAt :: Int -> a -> [a] -> [a]
setAt n v xs = case splitAt n xs of
  (before, _ : after) -> before ++ v : after
  (before, []) -> before

opsLoop ::
  Int64 -> Int64 -> HM.HashMap Int64 Int64 ->
  [HM.HashMap Int64 Int64] -> Int64 -> Int64
opsLoop !i !x !m ring !acc
  | i == opsN = foldr foldOne (foldOne m acc) ring
  | otherwise =
      let x1 = lcg x
          op = x1 `rem` 16
          x2 = lcg x1
          s = fromIntegral (x2 `rem` 24) :: Int
          x3 = lcg x2
          k = (1 `shiftL` s) + (x3 `rem` (1 `shiftL` s))
          m2
            | op < 9 = HM.insert k i m
            | op < 14 = HM.delete k m
            | otherwise = m
          acc2
            | op < 14 = acc
            | otherwise = acc + HM.findWithDefault (-1) k m2
          x4 = lcg x3
       in if x4 `rem` 8192 == 0
            then
              let slot = fromIntegral ((x4 `div` 8192) `rem` 8) :: Int
               in opsLoop (i + 1) x4 m2 (setAt slot m2 ring) acc2
            else opsLoop (i + 1) x4 m2 ring acc2

main :: IO ()
main = do
  let result = opsLoop 0 1 HM.empty (replicate 8 HM.empty) 0
  if result == expected
    then pure ()
    else do
      putStrLn ("FAIL: expected " ++ show expected ++ ", got " ++ show result)
      exitFailure
