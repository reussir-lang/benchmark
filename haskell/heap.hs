-- Binary heap maintenance under a Gaussian workload — purely functional
-- form: a Braun min-heap (size-balanced tree; the idiomatic persistent
-- binary heap), same Irwin-Hall stream and unconditional replace-top
-- maintenance as the array variants. The checksum only depends on the heap
-- *contents* (evicted minima + final multiset, mod 1e9+7), which is
-- arrangement-independent, so it matches the array implementations exactly.
{-# LANGUAGE BangPatterns #-}

module Main where

import System.Exit (exitFailure)

data Heap = Leaf | Node !Int !Heap !Heap

p :: Int
p = 1000000007

lcg :: Int -> Int
lcg x = (x * 48271) `rem` 2147483647

gauss :: Int -> (Int, Int)
gauss = go 12 0
  where
    go 0 !s !x = (s, x)
    go !k !s !x = let x1 = lcg x in go (k - 1) (s + x1) x1

insertH :: Int -> Heap -> Heap
insertH v Leaf = Node v Leaf Leaf
insertH v (Node w l r)
  | v <= w = Node v (insertH w r) l
  | otherwise = Node w (insertH v r) l

-- Replace the root value and restore the heap property downward.
replaceTop :: Int -> Heap -> Heap
replaceTop v (Node _ l r) = down v l r
replaceTop v Leaf = Node v Leaf Leaf

down :: Int -> Heap -> Heap -> Heap
down !v l r =
  case (l, r) of
    (Node lv ll lr, Node rv rl rr)
      | lv <= rv ->
          if v <= lv then Node v l r else Node lv (down v ll lr) r
      | otherwise ->
          if v <= rv then Node v l r else Node rv l (down v rl rr)
    (Node lv ll lr, Leaf) ->
      if v <= lv then Node v l r else Node lv (down v ll lr) Leaf
    (Leaf, Node rv rl rr) ->
      if v <= rv then Node v l r else Node rv Leaf (down v rl rr)
    (Leaf, Leaf) -> Node v Leaf Leaf

top :: Heap -> Int
top (Node w _ _) = w
top Leaf = 0

sumH :: Heap -> Int -> Int
sumH Leaf !acc = acc
sumH (Node w l r) !acc = sumH r (sumH l ((acc + w) `rem` p))

heapTest :: Int -> Int
heapTest m0 = go m0 x0 h0 0
  where
    (h0, x0) = build (0 :: Int) 20260711 Leaf
    build !k !x !h
      | k == 65535 = (h, x)
      | otherwise = let (g, x') = gauss x in build (k + 1) x' (insertH g h)
    go 0 _ !h !acc = (acc + sumH h 0) `rem` p
    go !k !x !h !acc =
      let (g, x') = gauss x
          !t = top h
       in go (k - 1) x' (replaceTop (t + g) h) ((acc + t) `rem` p)

main :: IO ()
main = do
  let c = heapTest 26000000
  if c /= 715063753
    then putStrLn ("FAIL: expected 715063753, got " ++ show c) >> exitFailure
    else pure ()
