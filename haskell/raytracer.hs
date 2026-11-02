-- Adapted from kmill/lean4-raytracer, copyright 2021 Kyle Miller.
-- Apache-2.0; see licenses/raytracer.md.
{-# LANGUAGE BangPatterns #-}

module Main where

import Control.Monad (foldM)
import Control.Monad.Trans.State.Strict (State, evalState, state)
import Data.Array (Array, elems, listArray)
import Data.Int (Int64)
import Data.Word (Word64)
import System.Exit (exitFailure)

data Vec3 = Vec3 {-# UNPACK #-} !Double {-# UNPACK #-} !Double {-# UNPACK #-} !Double
data Ray = Ray !Vec3 !Vec3
data Material = Lambertian !Vec3 | Metal !Vec3 !Double | Dielectric !Double | Sky
data Sphere = Sphere !Vec3 !Double !Material
data Hit = Hit !Vec3 !Double !Material !Vec3 !Bool
data Camera = Camera !Vec3 !Vec3 !Vec3 !Vec3 !Vec3 !Vec3 !Double
type World = Array Int Sphere

add, sub, mul :: Vec3 -> Vec3 -> Vec3
add (Vec3 x y z) (Vec3 a b c) = Vec3 (x + a) (y + b) (z + c)
sub (Vec3 x y z) (Vec3 a b c) = Vec3 (x - a) (y - b) (z - c)
mul (Vec3 x y z) (Vec3 a b c) = Vec3 (x * a) (y * b) (z * c)

scale :: Double -> Vec3 -> Vec3
scale s (Vec3 x y z) = Vec3 (s * x) (s * y) (s * z)

divide :: Vec3 -> Double -> Vec3
divide (Vec3 x y z) s = Vec3 (x / s) (y / s) (z / s)

dot :: Vec3 -> Vec3 -> Double
dot (Vec3 x y z) (Vec3 a b c) = (x * a + y * b) + z * c

normalize :: Vec3 -> Vec3
normalize v = divide v (sqrt (dot v v))

cross :: Vec3 -> Vec3 -> Vec3
cross (Vec3 x y z) (Vec3 a b c) = Vec3 (y * c - z * b) (z * a - x * c) (x * b - y * a)

reflect :: Vec3 -> Vec3 -> Vec3
reflect v n = sub v (scale (2 * dot v n) n)

refract :: Vec3 -> Vec3 -> Double -> Vec3
refract v n ratio = add perpendicular parallel
  where
    cosine = min (-dot v n) 1
    perpendicular = scale ratio (add v (scale cosine n))
    parallel = scale (-sqrt (abs (1 - dot perpendicular perpendicular))) n

black, white :: Vec3
black = Vec3 0 0 0
white = Vec3 1 1 1

camera :: Camera
camera = Camera origin lowerLeft horizontal vertical u v 0.05
  where
    origin = Vec3 13 2 3
    w = normalize origin
    u = normalize (cross (Vec3 0 1 0) w)
    v = cross w u
    theta = 20 / 180 * 3.1415926535897932385
    viewportHeight = 2 * tan (theta / 2)
    viewportWidth = (128 / 85) * viewportHeight
    horizontal = scale (10 * viewportWidth) u
    vertical = scale (10 * viewportHeight) v
    lowerLeft = sub (sub (sub origin (divide horizontal 2)) (divide vertical 2)) (scale 10 w)

hitSphere :: Ray -> Hit -> Sphere -> Hit
hitSphere (Ray origin direction) previous@(Hit _ previousT _ _ _) (Sphere center radius material)
  | discriminant < 0 = previous
  | root < 0.001 || previousT < root = previous
  | otherwise = Hit point root material normal front
  where
    oc = sub origin center
    a = dot direction direction
    halfB = dot oc direction
    c = dot oc oc - radius * radius
    discriminant = halfB * halfB - a * c
    sqrtD = sqrt discriminant
    near = (-halfB - sqrtD) / a
    root = if near < 0.001 || previousT < near then (-halfB + sqrtD) / a else near
    point = add origin (scale root direction)
    outward = divide (sub point center) radius
    front = dot direction outward < 0
    normal = if front then outward else scale (-1) outward

hitWorld :: World -> Ray -> Hit
hitWorld world ray = foldl' (hitSphere ray) initial (elems world)
  where
    initial = Hit black 1e100 Sky black True

-- Lean's StdGen stream is part of the workload, including its zero case.
data Rng = Rng !Int64 !Int64
type Random = State Rng

randomRange :: Double -> Double -> Random Double
randomRange lo hi = state $ \(Rng old1 old2) ->
  let k1 = old1 `quot` 53668
      a = 40014 * (old1 - k1 * 53668) - k1 * 12211
      s1 = if a < 0 then a + 2147483563 else a
      k2 = old2 `quot` 52774
      b = 40692 * (old2 - k2 * 52774) - k2 * 3791
      s2 = if b < 0 then b + 2147483399 else b
      z = s1 - s2
      n = if z < 1 then z + 2147483562 else z `rem` 2147483562
      nm1 = if n == 0 then 0 else n - 1
      !value = lo + (hi - lo) * (fromIntegral nm1 / 2147483562)
   in (value, Rng s1 s2)

randomVec :: Double -> Double -> Random Vec3
randomVec lo hi = do
  x <- randomRange lo hi
  y <- randomRange lo hi
  z <- randomRange lo hi
  pure (Vec3 x y z)

randomSphere :: Random Vec3
randomSphere = go (100 :: Int)
  where
    go 0 = pure (Vec3 1 0 0)
    go n = do
      p <- randomVec (-1) 1
      if dot p p < 1 then pure p else go (n - 1)

randomDisk :: Random Vec3
randomDisk = go (100 :: Int)
  where
    go 0 = pure black
    go n = do
      x <- randomRange (-1) 1
      y <- randomRange (-1) 1
      let p = Vec3 x y 0
      if dot p p < 1 then pure p else go (n - 1)

cameraRay :: Camera -> Double -> Double -> Random Ray
cameraRay (Camera origin lowerLeft horizontal vertical u v lensRadius) s t = do
  disk <- randomDisk
  let Vec3 dx dy _ = scale lensRadius disk
      offset = add (scale dx u) (scale dy v)
      direction = sub (sub (add (add lowerLeft (scale s horizontal)) (scale t vertical)) origin) offset
  pure (Ray (add origin offset) direction)

rayColor :: World -> Ray -> Int -> Vec3 -> Random Vec3
rayColor _ _ 0 _ = pure black
rayColor world ray@(Ray _ direction) depth acc =
  case hitWorld world ray of
    Hit _ _ Sky _ _ ->
      let Vec3 _ y _ = normalize direction
          t = 0.5 * (y + 1)
       in pure (mul acc (add (scale (1 - t) white) (scale t (Vec3 0.5 0.7 1))))
    Hit point _ (Lambertian albedo) normal _ -> do
      sample <- randomSphere
      let scatter = add normal (normalize sample)
          next = if dot scatter scatter < 1e-16 then normal else scatter
      rayColor world (Ray point next) (depth - 1) (mul albedo acc)
    Hit point _ (Metal albedo fuzz) normal _ -> do
      sample <- randomSphere
      let reflected = reflect (normalize direction) normal
          next = add reflected (scale fuzz sample)
      if dot next normal > 0
        then rayColor world (Ray point next) (depth - 1) (mul albedo acc)
        else pure (mul acc black)
    Hit point _ (Dielectric index) normal front -> do
      let ratio = if front then 1 / index else index
          unit = normalize direction
          cosine = min (-dot unit normal) 1
          sine = sqrt (1 - cosine * cosine)
          r0p = (1 - ratio) / (1 + ratio)
          r0 = r0p * r0p
          reflectance = r0 + (1 - r0) * ((1 - cosine) ** 5)
      -- The original samples before testing total internal reflection.
      sample <- randomRange 0 1
      let next = if ratio * sine > 1 || reflectance > sample
                   then reflect unit normal else refract unit normal ratio
      rayColor world (Ray point next) (depth - 1) (mul white acc)

randomScene :: Random World
randomScene = do
  objects <- foldM addSphere [ground] [0 .. 483 :: Int]
  let spheres = reverse objects ++ foreground
  pure (listArray (0, length spheres - 1) spheres)
  where
    ground = Sphere (Vec3 0 (-1000) 0) 1000 (Lambertian (Vec3 0.5 0.5 0.5))
    foreground = [Sphere (Vec3 0 1 0) 1 (Dielectric 1.5),
                  Sphere (Vec3 (-4) 1 0) 1 (Lambertian (Vec3 0.4 0.2 0.1)),
                  Sphere (Vec3 4 1 0) 1 (Metal (Vec3 0.7 0.6 0.5) 0)]
    addSphere objects i = do
      x <- randomRange 0 1
      z <- randomRange 0 1
      let a = fromIntegral (i `quot` 22) - 11
          b = fromIntegral (i `rem` 22) - 11
          center = Vec3 (a + 0.9 * x) 0.2 (b + 0.9 * z)
          offset = sub center (Vec3 4 0.2 0)
      if sqrt (dot offset offset) <= 0.9 then pure objects else do
        choice <- randomRange 0 1
        material <- if choice < 0.9 then do
          first <- randomVec 0 1
          second <- randomVec 0 1
          pure (Lambertian (mul first second))
        else if choice < 0.95 then do
          albedo <- randomVec 0.5 1
          fuzz <- randomRange 0 0.5
          pure (Metal albedo fuzz)
        else pure (Dielectric 1.5)
        pure (Sphere center 0.2 material : objects)

pixel :: World -> Int -> Int -> Random Vec3
pixel world x y = go (4 :: Int) black
  where
    go 0 !acc = pure acc
    go n !acc = do
      rx <- randomRange 0 1
      ry <- randomRange 0 1
      ray <- cameraRay camera ((fromIntegral x + rx) / 128) ((fromIntegral y + ry) / 85)
      color <- rayColor world ray 10 white
      go (n - 1) (add acc color)

channel :: Double -> Word64
channel value = truncate (min 255 (max 0 (256 * sqrt (value / 4))))

render :: Random Word64
render = do
  world <- randomScene
  foldM (row world) 0 [0 .. 84 :: Int]
  where
    row world !checksum line = foldM (column world line) checksum [0 .. 127 :: Int]
    column world line !checksum x = do
      Vec3 r g b <- pixel world x (84 - line)
      let index = fromIntegral ((line * 128 + x) * 3)
          !next = checksum + (index + 1) * channel r + (index + 2) * channel g + (index + 3) * channel b
      pure next

main :: IO ()
main = do
  let checksum = evalState render (Rng 1 1)
  if checksum /= 64158141444
    then putStrLn ("FAIL: expected 64158141444, got " ++ show checksum) >> exitFailure
    else print checksum
