(* Adapted from kmill/lean4-raytracer, copyright 2021 Kyle Miller.
   SPDX-License-Identifier: Apache-2.0 *)

let width = 128
let height = 85
let samples = 4
let depth = 10
let expected = 64_158_141_444

type vec3 = { x : float; y : float; z : float }
let vec x y z = { x; y; z }
let black = vec 0. 0. 0.
let white = vec 1. 1. 1.
let add a b = vec (a.x +. b.x) (a.y +. b.y) (a.z +. b.z)
let sub a b = vec (a.x -. b.x) (a.y -. b.y) (a.z -. b.z)
let mul a b = vec (a.x *. b.x) (a.y *. b.y) (a.z *. b.z)
let scale s a = vec (s *. a.x) (s *. a.y) (s *. a.z)
let divide a s = vec (a.x /. s) (a.y /. s) (a.z /. s)
let neg a = vec (-.a.x) (-.a.y) (-.a.z)
let dot a b = ((a.x *. b.x) +. (a.y *. b.y)) +. (a.z *. b.z)
let length a = sqrt (dot a a)
let unit a = divide a (length a)
let cross a b =
  vec ((a.y *. b.z) -. (a.z *. b.y)) ((a.z *. b.x) -. (a.x *. b.z))
    ((a.x *. b.y) -. (a.y *. b.x))
let reflect a normal = sub a (scale (2. *. dot a normal) normal)
let refract a normal ratio =
  let cosine = min (-.(dot a normal)) 1. in
  let perpendicular = scale ratio (add a (scale cosine normal)) in
  let parallel = scale (-.(sqrt (abs_float (1. -. dot perpendicular perpendicular)))) normal in
  add perpendicular parallel

module Rng = struct
  type t = { mutable s1 : int; mutable s2 : int }
  let create seed =
    { s1 = (seed mod 2_147_483_562) + 1;
      s2 = ((seed / 2_147_483_562) mod 2_147_483_398) + 1 }
  let random rng lo hi =
    let k1 = rng.s1 / 53_668 in
    let a = (40_014 * (rng.s1 - (k1 * 53_668))) - (k1 * 12_211) in
    rng.s1 <- (if a < 0 then a + 2_147_483_563 else a);
    let k2 = rng.s2 / 52_774 in
    let b = (40_692 * (rng.s2 - (k2 * 52_774))) - (k2 * 3_791) in
    rng.s2 <- (if b < 0 then b + 2_147_483_399 else b);
    let z = rng.s1 - rng.s2 in
    let n = if z < 1 then z + 2_147_483_562 else z mod 2_147_483_562 in
    let n = if n = 0 then 0 else n - 1 in
    lo +. ((hi -. lo) *. (float_of_int n /. 2_147_483_562.))
  let vector rng lo hi =
    let x = random rng lo hi in
    let y = random rng lo hi in
    let z = random rng lo hi in
    vec x y z
  let sphere rng =
    let rec draw attempts =
      if attempts = 0 then vec 1. 0. 0.
      else
        let p = vector rng (-1.) 1. in
        if dot p p < 1. then p else draw (attempts - 1)
    in draw 100
  let disk rng =
    let rec draw attempts =
      if attempts = 0 then black
      else
        let x = random rng (-1.) 1. in
        let y = random rng (-1.) 1. in
        let p = vec x y 0. in
        if dot p p < 1. then p else draw (attempts - 1)
    in draw 100
end

type ray = { origin : vec3; direction : vec3 }
type material = Lambertian of vec3 | Metal of vec3 * float | Dielectric of float | Sky
type sphere = { center : vec3; radius : float; material : material }
type hit = { point : vec3; distance : float; material : material; normal : vec3; front : bool }
let hit_sphere (sphere : sphere) ray previous =
  let oc = sub ray.origin sphere.center in
  let a = dot ray.direction ray.direction in
  let half_b = dot oc ray.direction in
  let c = dot oc oc -. (sphere.radius *. sphere.radius) in
  let discriminant = (half_b *. half_b) -. (a *. c) in
  if discriminant < 0. then previous
  else
    let sqrt_d = sqrt discriminant in
    let near = (-.half_b -. sqrt_d) /. a in
    let root =
      if near < 0.001 || previous.distance < near then (-.half_b +. sqrt_d) /. a else near
    in
    if root < 0.001 || previous.distance < root then previous
    else
      let point = add ray.origin (scale root ray.direction) in
      let outward = divide (sub point sphere.center) sphere.radius in
      let front = dot ray.direction outward < 0. in
      { point; distance = root; material = sphere.material;
        normal = (if front then outward else neg outward); front }

module World = struct
  type t = sphere array
  let random rng =
    let spheres = ref [] in
    let push center radius material = spheres := { center; radius; material } :: !spheres in
    push (vec 0. (-1000.) 0.) 1000. (Lambertian (vec 0.5 0.5 0.5));
    for i = 0 to 483 do
      let a = float_of_int (i / 22) -. 11. in
      let b = float_of_int (i mod 22) -. 11. in
      let x = Rng.random rng 0. 1. in
      let z = Rng.random rng 0. 1. in
      let center = vec (a +. (0.9 *. x)) 0.2 (b +. (0.9 *. z)) in
      if length (sub center (vec 4. 0.2 0.)) > 0.9 then (
        let choice = Rng.random rng 0. 1. in
        let material =
          if choice < 0.9 then
            let first = Rng.vector rng 0. 1. in
            let second = Rng.vector rng 0. 1. in
            Lambertian (mul first second)
          else if choice < 0.95 then
            let albedo = Rng.vector rng 0.5 1. in
            let fuzz = Rng.random rng 0. 0.5 in
            Metal (albedo, fuzz)
          else Dielectric 1.5
        in push center 0.2 material)
    done;
    push (vec 0. 1. 0.) 1. (Dielectric 1.5);
    push (vec (-4.) 1. 0.) 1. (Lambertian (vec 0.4 0.2 0.1));
    push (vec 4. 1. 0.) 1. (Metal (vec 0.7 0.6 0.5, 0.));
    Array.of_list (List.rev !spheres)
  let hit world ray =
    Array.fold_left (fun nearest sphere -> hit_sphere sphere ray nearest)
      { point = black; distance = 1e100; material = Sky; normal = black; front = true }
      world
  let color world ray rng =
    let rec bounce remaining ray accumulated =
      if remaining = 0 then black
      else
        let hit = hit world ray in
        match hit.material with
        | Sky ->
            let direction = unit ray.direction in
            let t = 0.5 *. (direction.y +. 1.) in
            mul accumulated (add (scale (1. -. t) white) (scale t (vec 0.5 0.7 1.)))
        | Lambertian albedo ->
            let sample = Rng.sphere rng in
            let scattered = add hit.normal (unit sample) in
            let direction = if dot scattered scattered < 1e-16 then hit.normal else scattered in
            bounce (remaining - 1) { origin = hit.point; direction } (mul albedo accumulated)
        | Metal (albedo, fuzz) ->
            let reflected = reflect (unit ray.direction) hit.normal in
            let sample = Rng.sphere rng in
            let direction = add reflected (scale fuzz sample) in
            if dot direction hit.normal > 0. then
              bounce (remaining - 1) { origin = hit.point; direction } (mul albedo accumulated)
            else mul accumulated black
        | Dielectric index ->
            let ratio = if hit.front then 1. /. index else index in
            let direction = unit ray.direction in
            let cosine = min (-.(dot direction hit.normal)) 1. in
            let sine = sqrt (1. -. (cosine *. cosine)) in
            let r0p = (1. -. ratio) /. (1. +. ratio) in
            let r0 = r0p *. r0p in
            let reflectance = r0 +. ((1. -. r0) *. ((1. -. cosine) ** 5.)) in
            let sample = Rng.random rng 0. 1. in
            let direction =
              if ratio *. sine > 1. || reflectance > sample then reflect direction hit.normal
              else refract direction hit.normal ratio
            in
            bounce (remaining - 1) { origin = hit.point; direction } (mul white accumulated)
    in bounce depth ray white
end

type camera = { origin : vec3; lower_left : vec3; horizontal : vec3; vertical : vec3; u : vec3; v : vec3 }
let camera () =
  let origin = vec 13. 2. 3. in
  let w = unit origin in
  let u = unit (cross (vec 0. 1. 0.) w) in
  let v = cross w u in
  let theta = 20. /. 180. *. Float.pi in
  let viewport_height = 2. *. tan (theta /. 2.) in
  let viewport_width = (float_of_int width /. float_of_int height) *. viewport_height in
  let horizontal = scale (10. *. viewport_width) u in
  let vertical = scale (10. *. viewport_height) v in
  let lower_left = sub (sub (sub origin (divide horizontal 2.)) (divide vertical 2.)) (scale 10. w) in
  { origin; lower_left; horizontal; vertical; u; v }
let camera_ray camera s t rng =
  let sample = Rng.disk rng in
  let rd = scale 0.05 sample in
  let offset = add (scale rd.x camera.u) (scale rd.y camera.v) in
  { origin = add camera.origin offset;
    direction = sub (sub (add (add camera.lower_left (scale s camera.horizontal)) (scale t camera.vertical)) camera.origin) offset }
let channel value = int_of_float (min 255. (max 0. (256. *. sqrt (value /. float_of_int samples))))
let () =
  let rng = Rng.create 0 in
  let world = World.random rng in
  let camera = camera () in
  let checksum = ref 0 in
  for line = 0 to height - 1 do
    for x = 0 to width - 1 do
      let color = ref black in
      for _ = 1 to samples do
        let rx = Rng.random rng 0. 1. in
        let ry = Rng.random rng 0. 1. in
        let ray = camera_ray camera ((float_of_int x +. rx) /. float_of_int width)
            ((float_of_int (height - line - 1) +. ry) /. float_of_int height) rng in
        color := add !color (World.color world ray rng)
      done;
      let index = (line * width + x) * 3 in
      checksum := !checksum + ((index + 1) * channel !color.x)
        + ((index + 2) * channel !color.y) + ((index + 3) * channel !color.z)
    done
  done;
  if !checksum <> expected then (
    Printf.eprintf "FAIL: expected %d, got %d\n" expected !checksum;
    exit 1);
  Printf.printf "%d\n" !checksum
