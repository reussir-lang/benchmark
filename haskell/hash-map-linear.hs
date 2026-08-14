{-# LANGUAGE BangPatterns #-}

-- Std-collection workload on Haskell's de-facto standard hash map
-- (Data.HashMap.Strict from unordered-containers — a persistent HAMT,
-- the same representation family as Reussir's std HashMap). Zipfian
-- mixed-op workload: keys follow an integer-only octave Zipf
-- (theta ~ 1) — a stratum s drawn uniform in [0, 24), then a key
-- uniform in [2^s, 2^(s+1)), so every octave carries equal mass and
-- per-key probability decays as 1/key. 8M rounds, each drawing op,
-- stratum, key from one MINSTD stream: 9/16 insert, 5/16 delete, 2/16
-- lookup (sum, -1 on miss). Deletes land on present keys ~48% of the
-- time.
--
-- Linear variant: exactly one live version — the map handle is
-- threaded linearly through every round and nothing is retained. The
-- checksum folds the final map (iteration-order independent so all
-- representations agree). Final size 1,120,773.

import Data.Bits (shiftL)
import Data.Int (Int64)
import qualified Data.HashMap.Strict as HM
import System.Exit (exitFailure)

opsN, expected :: Int64
opsN = 8000000
expected = 144585704074329

lcg :: Int64 -> Int64
lcg x = (x * 48271) `rem` 2147483647

foldOne :: HM.HashMap Int64 Int64 -> Int64 -> Int64
foldOne m acc =
  acc
    + HM.foldlWithKey' (\a k v -> a + k * 31 + v) 0 m
    + 7 * fromIntegral (HM.size m)

opsLoop :: Int64 -> Int64 -> HM.HashMap Int64 Int64 -> Int64 -> Int64
opsLoop !i !x !m !acc
  | i == opsN = foldOne m acc
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
       in opsLoop (i + 1) x3 m2 acc2

main :: IO ()
main = do
  let result = opsLoop 0 1 HM.empty 0
  if result == expected
    then pure ()
    else do
      putStrLn ("FAIL: expected " ++ show expected ++ ", got " ++ show result)
      exitFailure
