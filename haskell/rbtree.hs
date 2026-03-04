{-# LANGUAGE BangPatterns #-}

module Main where

data Color = Red | Black deriving (Eq)

data Tree
  = Branch !Color !Tree !Int !Bool !Tree
  | Leaf

isRed :: Tree -> Bool
isRed (Branch Red _ _ _ _) = True
isRed _ = False

balanceLeft :: Tree -> Int -> Bool -> Tree -> Tree
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

balanceRight :: Tree -> Int -> Bool -> Tree -> Tree
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

ins :: Tree -> Int -> Bool -> Tree
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

insert :: Tree -> Int -> Bool -> Tree
insert t k v = setBlack (ins t k v)

makeTree :: Int -> Tree
makeTree n = go n Leaf
  where
    go !m !t
      | m <= 0 = t
      | otherwise =
          let m1 = m - 1
              t2 = insert t m1 (m1 `rem` 10 == 0)
           in go m1 t2

foldTree :: Tree -> Int -> Int
foldTree t !b =
  case t of
    Branch _ l _ v r ->
      let !left = foldTree l b
          !mid = if v then left + 1 else left
       in foldTree r mid
    Leaf -> b

foldTest :: Int -> Int
foldTest n = foldTree (makeTree n) 0

main :: IO ()
main = do
  let n = 4200000
      p = foldTest n
  if p /= 420000
    then error ("FAIL: expected 420000, got " ++ show p)
    else pure ()
