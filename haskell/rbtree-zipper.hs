{-# LANGUAGE BangPatterns #-}

module Main where

data Color = Red | Black deriving (Eq)

data Tree
  = Branch !Color !Tree !Int !Bool !Tree
  | Leaf

data Zipper
  = NodeR !Color !Tree !Int !Bool !Zipper
  | NodeL !Color !Zipper !Int !Bool !Tree
  | Done

moveUp :: Zipper -> Tree -> Tree
moveUp z t =
  case z of
    NodeR c l k v z1 -> moveUp z1 (Branch c l k v t)
    NodeL c z1 k v r -> moveUp z1 (Branch c t k v r)
    Done -> t

balanceRed :: Zipper -> Tree -> Int -> Bool -> Tree -> Tree
balanceRed z l k v r =
  case z of
    NodeR Black l1 k1 v1 z1 ->
      moveUp z1 (Branch Black l1 k1 v1 (Branch Red l k v r))
    NodeL Black z1 k1 v1 r1 ->
      moveUp z1 (Branch Black (Branch Red l k v r) k1 v1 r1)
    NodeR Red l1 k1 v1 z1 ->
      case z1 of
        NodeR _ l2 k2 v2 z2 ->
          balanceRed
            z2
            (Branch Black l2 k2 v2 l1)
            k1
            v1
            (Branch Black l k v r)
        NodeL _ z2 k2 v2 r2 ->
          balanceRed
            z2
            (Branch Black l1 k1 v1 l)
            k
            v
            (Branch Black r k2 v2 r2)
        Done -> Branch Black l1 k1 v1 (Branch Red l k v r)
    NodeL Red z1 k1 v1 r1 ->
      case z1 of
        NodeR _ l2 k2 v2 z2 ->
          balanceRed
            z2
            (Branch Black l2 k2 v2 l)
            k
            v
            (Branch Black r k1 v1 r1)
        NodeL _ z2 k2 v2 r2 ->
          balanceRed
            z2
            (Branch Black l k v r)
            k1
            v1
            (Branch Black r1 k2 v2 r2)
        Done -> Branch Black (Branch Red l k v r) k1 v1 r1
    Done -> Branch Black l k v r

ins :: Tree -> Int -> Bool -> Zipper -> Tree
ins t k v z =
  case t of
    Branch c l kx vx r ->
      if k < kx
        then ins l k v (NodeL c z kx vx r)
      else
        if k > kx
          then ins r k v (NodeR c l kx vx z)
          else moveUp z (Branch c l kx vx r)
    Leaf -> balanceRed z Leaf k v Leaf

insert :: Tree -> Int -> Bool -> Tree
insert t k v = ins t k v Done

makeTree :: Int -> Tree -> Tree
makeTree n t
  | n <= 0 = t
  | otherwise =
      let m = n - 1
          t2 = insert t m (m `rem` 10 == 0)
       in makeTree m t2

foldTree :: Tree -> Int -> Int
foldTree t !b =
  case t of
    Branch _ l _ v r ->
      let !left = foldTree l b
          !mid = if v then left + 1 else left
       in foldTree r mid
    Leaf -> b

foldTest :: Int -> Int
foldTest n = foldTree (makeTree n Leaf) 0

main :: IO ()
main = do
  let n = 4200000
      p = foldTest n
  if p /= 420000
    then error ("FAIL: expected 420000, got " ++ show p)
    else pure ()
