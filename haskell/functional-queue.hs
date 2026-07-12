{-# LANGUAGE BangPatterns #-}

module Main where

import Data.Int (Int64)
import System.Exit (exitFailure)

data List = Nil | Cons !Int64 !List

data Rotation
  = Idle
  | Reversing !Int !List !List !List !List
  | Appending !Int !List !List
  | Done !List

data Queue = Queue !Int !List !Rotation !Int !List

exec :: Rotation -> Rotation
exec (Reversing ok (Cons x f) f' (Cons y r) r') =
  Reversing (ok + 1) f (Cons x f') r (Cons y r')
exec (Reversing ok Nil f' (Cons y Nil) r') = Appending ok f' (Cons y r')
exec (Appending 0 _ r') = Done r'
exec (Appending ok (Cons x f') r') = Appending (ok - 1) f' (Cons x r')
exec state = state

invalidate :: Rotation -> Rotation
invalidate (Reversing ok f f' r r') = Reversing (ok - 1) f f' r r'
invalidate (Appending 0 _ (Cons _ r')) = Done r'
invalidate (Appending ok f' r') = Appending (ok - 1) f' r'
invalidate state = state

exec2 :: Queue -> Queue
exec2 (Queue lenF front state lenR rear) =
  case exec (exec state) of
    Done front' -> Queue lenF front' Idle lenR rear
    state' -> Queue lenF front state' lenR rear

check :: Queue -> Queue
check queue@(Queue lenF front _ lenR rear)
  | lenR <= lenF = exec2 queue
  | otherwise = exec2 (Queue (lenF + lenR) front (Reversing 0 front Nil rear Nil) 0 Nil)

snoc :: Queue -> Int64 -> Queue
snoc (Queue lenF front state lenR rear) value =
  check (Queue lenF front state (lenR + 1) (Cons value rear))

uncons :: Queue -> (Int64, Queue)
uncons (Queue lenF (Cons value front) state lenR rear) =
  (value, check (Queue (lenF - 1) front (invalidate state) lenR rear))
uncons _ = error "empty queue"

build :: Int -> Queue
build size = go 0 (Queue 0 Nil Idle 0 Nil)
  where
    go !index !queue
      | index == size = queue
      | otherwise = go (index + 1) (snoc queue (fromIntegral index))

modulus :: Int64
modulus = 1000000007

churn :: Int64 -> Int -> Queue -> Int64 -> (Queue, Int64)
churn !round !remaining !queue !checksum
  | remaining == 0 = (queue, checksum)
  | otherwise =
      let (value, rest) = uncons queue
          !next = (value + round + 1) `rem` modulus
       in churn (round + 1) (remaining - 1) (snoc rest next)
            ((checksum + value) `rem` modulus)

drain :: Int -> Queue -> Int64 -> Int64
drain 0 _ !checksum = checksum
drain !remaining !queue !checksum =
  let (value, rest) = uncons queue
   in drain (remaining - 1) rest ((checksum + value) `rem` modulus)

main :: IO ()
main = do
  let (queue, checksum) = churn 0 1000000 (build 65536) 0
      result = drain 65536 queue checksum
  if result /= 66797929
    then putStrLn ("FAIL: expected 66797929, got " ++ show result) >> exitFailure
    else pure ()
