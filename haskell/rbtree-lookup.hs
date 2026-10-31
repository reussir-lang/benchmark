{-# LANGUAGE BangPatterns #-}

-- rbtree-lookup: rbtree's tree code with lookups. Insert 1M scattered keys
-- and after every insert look up 8 keys in the current tree, which stays
-- live for the next insert. The inserts own the tree and can update it in
-- place; the lookups only read it.

module Main where

import Data.Int (Int64)

data Color = Red | Black deriving (Eq)

data Tree
  = Branch !Color !Tree !Int64 !Bool !Tree
  | Leaf

isRed :: Tree -> Bool
isRed (Branch Red _ _ _ _) = True
isRed _ = False

balanceLeft :: Tree -> Int64 -> Bool -> Tree -> Tree
balanceLeft l k v r =
  case l of
    Branch _ lx kx vx rx ->
      case lx of
        Branch Red ll kk vv rr ->
          Branch
            Red
            (Branch Black ll kk vv rr)
            kx
            vx
            (Branch Black rx k v r)
        _ ->
          case rx of
            Branch Red lx1 kx1 vx1 rxx ->
              Branch
                Red
                (Branch Black lx kx vx lx1)
                kx1
                vx1
                (Branch Black rxx k v r)
            _ -> Branch Black (Branch Red lx kx vx rx) k v r
    Leaf -> Leaf

balanceRight :: Tree -> Int64 -> Bool -> Tree -> Tree
balanceRight l k v r =
  case r of
    Branch _ lx kx vx ry ->
      case lx of
        Branch Red ll kk vv rr ->
          Branch
            Red
            (Branch Black l k v ll)
            kk
            vv
            (Branch Black rr kx vx ry)
        _ ->
          case ry of
            Branch Red ly ky vy rr ->
              Branch
                Red
                (Branch Black l k v lx)
                kx
                vx
                (Branch Black ly ky vy rr)
            _ -> Branch Black l k v (Branch Red lx kx vx ry)
    Leaf -> Leaf

ins :: Tree -> Int64 -> Bool -> Tree
ins t k v =
  case t of
    Branch Red l kx vx r ->
      if k < kx
        then Branch Red (ins l k v) kx vx r
      else
        if k > kx
          then Branch Red l kx vx (ins r k v)
          else Branch Red l k v r
    Branch Black l kx vx r ->
      if k < kx
        then
          if isRed l
            then balanceLeft (ins l k v) kx vx r
            else Branch Black (ins l k v) kx vx r
      else
        if k > kx
          then
            if isRed r
              then balanceRight l kx vx (ins r k v)
              else Branch Black l kx vx (ins r k v)
          else Branch Black l k v r
    Leaf -> Branch Red Leaf k v Leaf

setBlack :: Tree -> Tree
setBlack (Branch _ l k v r) = Branch Black l k v r
setBlack Leaf = Leaf

insert :: Tree -> Int64 -> Bool -> Tree
insert t k v = setBlack (ins t k v)

get :: Tree -> Int64 -> Bool
get t !k =
  case t of
    Branch _ l kx _ r ->
      if k < kx then get l k else if k > kx then get r k else True
    Leaf -> False

probe :: Int64 -> Int64 -> Tree -> Int -> Int
probe !j !i t !hits
  | j == 0 = hits
  | otherwise =
      let k = (i * 31 + j * 7919) `rem` 2000000
       in probe (j - 1) i t (if get t k then hits + 1 else hits)

rounds :: Int64 -> Int64 -> Tree -> Int -> Int
rounds !i !n !t !hits
  | i == n = hits
  | otherwise =
      let !t2 = insert t ((i * 7919) `rem` n) True
          !h = probe 8 i t2 hits
       in rounds (i + 1) n t2 h

main :: IO ()
main = do
  let hits = rounds 0 1000000 Leaf 0
  if hits /= 2059798
    then error ("FAIL: expected 2059798, got " ++ show hits)
    else pure ()
