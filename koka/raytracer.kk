// Adapted from Kyle Miller's lean4-raytracer, copyright 2021 Kyle Miller.
// Apache-2.0; see licenses/raytracer.md.
import std/num/float64

value struct vec3(vx: float64, vy: float64, vz: float64)
struct ray(origin: vec3, dir: vec3)
type material
  Lambertian(albedo: vec3)
  Metal(albedo: vec3, fuzz: float64)
  Dielectric(index: float64)
  Sky
struct sphere(center: vec3, radius: float64, material: material)
struct hit(point: vec3, distance: float64, material: material, normal: vec3, front: bool)
struct camera(origin: vec3, lower: vec3, horizontal: vec3, vertical: vec3, u: vec3, v: vec3)

fun black() Vec3(0.0, 0.0, 0.0)
fun white() Vec3(1.0, 1.0, 1.0)
fun add(a: vec3, b: vec3) Vec3(a.vx + b.vx, a.vy + b.vy, a.vz + b.vz)
fun sub(a: vec3, b: vec3) Vec3(a.vx - b.vx, a.vy - b.vy, a.vz - b.vz)
fun mul(a: vec3, b: vec3) Vec3(a.vx * b.vx, a.vy * b.vy, a.vz * b.vz)
fun scale(s: float64, a: vec3) Vec3(s * a.vx, s * a.vy, s * a.vz)
fun divide(a: vec3, s: float64) Vec3(a.vx / s, a.vy / s, a.vz / s)
fun dot(a: vec3, b: vec3) (a.vx * b.vx + a.vy * b.vy) + a.vz * b.vz
fun length(a: vec3) sqrt(dot(a,a))
fun normalize(a: vec3) divide(a,length(a))
fun cross(a: vec3, b: vec3)
  Vec3(a.vy * b.vz - a.vz * b.vy, a.vz * b.vx - a.vx * b.vz, a.vx * b.vy - a.vy * b.vx)
fun reflect(v: vec3, n: vec3) sub(v,scale(2.0 * dot(v,n),n))
fun refract(v: vec3, n: vec3, ratio: float64)
  val cosine = min(0.0 - dot(v,n),1.0)
  val perp = scale(ratio,add(v,scale(cosine,n)))
  add(perp,scale(0.0 - sqrt(abs(1.0 - dot(perp,perp))),n))

// One handler owns the continuous StdGen stream for scene and rendering.
effect sampling
  fun draw(): float64

fun seeded(action: () -> <sampling|e> a): e a
  var s1 := 1
  var s2 := 1
  with fun draw()
    val k1 = s1 / 53668
    val a = 40014 * (s1 - k1 * 53668) - k1 * 12211
    s1 := (if a < 0 then a + 2147483563 else a)
    val k2 = s2 / 52774
    val b = 40692 * (s2 - k2 * 52774) - k2 * 3791
    s2 := (if b < 0 then b + 2147483399 else b)
    val z = s1 - s2
    val n = if z < 1 then z + 2147483562 else z % 2147483562
    val nm1 = if n == 0 then 0 else n - 1
    nm1.float64 / 2147483562.0
  action()

fun random(lo: float64, hi: float64): sampling float64
  lo + (hi - lo) * draw()
fun randomVec(lo: float64, hi: float64): sampling vec3
  val x = random(lo,hi)
  val y = random(lo,hi)
  val z = random(lo,hi)
  Vec3(x,y,z)
fun randomSphere(attempts: int): <sampling,div> vec3
  if attempts == 0 then Vec3(1.0,0.0,0.0) else
    val p = randomVec(-1.0,1.0)
    if dot(p,p) < 1.0 then p else randomSphere(attempts - 1)
fun randomDisk(attempts: int): <sampling,div> vec3
  if attempts == 0 then black() else
    val x = random(-1.0,1.0)
    val y = random(-1.0,1.0)
    val p = Vec3(x,y,0.0)
    if dot(p,p) < 1.0 then p else randomDisk(attempts - 1)

fun makeCamera(): camera
  val origin = Vec3(13.0,2.0,3.0)
  val w = normalize(origin)
  val u = normalize(cross(Vec3(0.0,1.0,0.0),w))
  val v = cross(w,u)
  val theta = 20.0 / 180.0 * 3.1415926535897932385
  val height = 2.0 * tan(theta / 2.0)
  val horizontal = scale(10.0 * ((128.0 / 85.0) * height),u)
  val vertical = scale(10.0 * height,v)
  val lower = sub(sub(sub(origin,divide(horizontal,2.0)),divide(vertical,2.0)),scale(10.0,w))
  Camera(origin,lower,horizontal,vertical,u,v)
fun cameraRay(cam: camera, s: float64, t: float64): <sampling,div> ray
  val rd = scale(0.05,randomDisk(100))
  val offset = add(scale(rd.vx,cam.u),scale(rd.vy,cam.v))
  Ray(add(cam.origin,offset),sub(sub(add(add(cam.lower,scale(s,cam.horizontal)),scale(t,cam.vertical)),cam.origin),offset))

fun hitSphere(s: sphere, r: ray, previous: hit): hit
  val oc = sub(r.origin,s.center)
  val a = dot(r.dir,r.dir)
  val halfB = dot(oc,r.dir)
  val c = dot(oc,oc) - s.radius * s.radius
  val discr = halfB * halfB - a * c
  if discr < 0.0 then previous else
    val rootD = sqrt(discr)
    val near = (0.0 - halfB - rootD) / a
    val root = if near < 0.001 || previous.distance < near then (0.0 - halfB + rootD) / a else near
    if root < 0.001 || previous.distance < root then previous else
      val point = add(r.origin,scale(root,r.dir))
      val outward = divide(sub(point,s.center),s.radius)
      val front = dot(r.dir,outward) < 0.0
      Hit(point,root,s.material,if front then outward else scale(-1.0,outward),front)
fun worldHit(world: vector<sphere>, r: ray): exn hit
  var nearest := Hit(black(),1.0e100,Sky,black(),True)
  world.foreach fn(s) nearest := hitSphere(s,r,nearest)
  nearest

fun rayColor(world: vector<sphere>, r: ray, depth: int, acc: vec3): <sampling,exn,div> vec3
  if depth == 0 then black() else
    val h = worldHit(world,r)
    match h.material
      Sky ->
        val t = 0.5 * (normalize(r.dir).vy + 1.0)
        mul(acc,add(scale(1.0 - t,white()),scale(t,Vec3(0.5,0.7,1.0))))
      Lambertian(albedo) ->
        val scatter = add(h.normal,normalize(randomSphere(100)))
        val direction = if dot(scatter,scatter) < 1.0e-16 then h.normal else scatter
        rayColor(world,Ray(h.point,direction),depth - 1,mul(albedo,acc))
      Metal(albedo,fuzz) ->
        val reflected = reflect(normalize(r.dir),h.normal)
        val sample = randomSphere(100)
        val direction = add(reflected,scale(fuzz,sample))
        if dot(direction,h.normal) > 0.0 then rayColor(world,Ray(h.point,direction),depth - 1,mul(albedo,acc)) else mul(acc,black())
      Dielectric(index) ->
        val ratio = if h.front then 1.0 / index else index
        val unit = normalize(r.dir)
        val cosine = min(0.0 - dot(unit,h.normal),1.0)
        val sine = sqrt(1.0 - cosine * cosine)
        val r0p = (1.0 - ratio) / (1.0 + ratio)
        val r0 = r0p * r0p
        val reflectance = r0 + (1.0 - r0) * ((1.0 - cosine)^5.0)
        val sample = random(0.0,1.0)
        val direction = if ratio * sine > 1.0 || reflectance > sample then reflect(unit,h.normal) else refract(unit,h.normal,ratio)
        rayColor(world,Ray(h.point,direction),depth - 1,mul(white(),acc))

fun sceneSpheres(i: int, reversed: list<sphere>): <sampling,div> list<sphere>
  if i == 484 then reversed else
    val a = (i / 22).float64 - 11.0
    val b = (i%22).float64 - 11.0
    val x = random(0.0,1.0)
    val z = random(0.0,1.0)
    val center = Vec3(a + 0.9 * x,0.2,b + 0.9 * z)
    if length(sub(center,Vec3(4.0,0.2,0.0))) <= 0.9 then sceneSpheres(i + 1,reversed) else
      val choice = random(0.0,1.0)
      val material = if choice < 0.9 then
        val first = randomVec(0.0,1.0)
        val second = randomVec(0.0,1.0)
        Lambertian(mul(first,second))
      elif choice < 0.95 then
        val albedo = randomVec(0.5,1.0)
        val fuzz = random(0.0,0.5)
        Metal(albedo,fuzz)
      else Dielectric(1.5)
      sceneSpheres(i + 1,Cons(Sphere(center,0.2,material),reversed))
fun makeWorld(): <sampling,div> vector<sphere>
  val ground = Sphere(Vec3(0.0, -1000.0,0.0),1000.0,Lambertian(Vec3(0.5,0.5,0.5)))
  val reversed = sceneSpheres(0,[ground])
  val spheres = Cons(Sphere(Vec3(4.0,1.0,0.0),1.0,Metal(Vec3(0.7,0.6,0.5),0.0)),
    Cons(Sphere(Vec3(-4.0,1.0,0.0),1.0,Lambertian(Vec3(0.4,0.2,0.1))),
    Cons(Sphere(Vec3(0.0,1.0,0.0),1.0,Dielectric(1.5)),reversed)))
  spheres.reverse.vector

fun pixel(world: vector<sphere>, cam: camera, x: int, y: int, n: int, acc: vec3): <sampling,exn,div> vec3
  if n == 0 then acc else
    val rx = random(0.0,1.0)
    val ry = random(0.0,1.0)
    val r = cameraRay(cam,(x.float64 + rx) / 128.0,(y.float64 + ry) / 85.0)
    val color = rayColor(world,r,10,white())
    pixel(world,cam,x,y,n - 1,add(acc,color))
fun channel(v: float64): int
  min(255.0,max(0.0,256.0 * sqrt(v / 4.0))).floor.int
fun row(world: vector<sphere>, cam: camera, line: int, x: int, checksum: int): <sampling,exn,div> int
  if x == 128 then checksum else
    val color = pixel(world,cam,x,85 - line - 1,4,black())
    val index = (line * 128 + x) * 3
    val sum = (index + 1) * channel(color.vx) + (index + 2) * channel(color.vy) + (index + 3) * channel(color.vz)
    row(world,cam,line,x + 1,checksum + sum)
fun image(world: vector<sphere>, cam: camera, line: int, checksum: int): <sampling,exn,div> int
  if line == 85 then checksum else image(world,cam,line + 1,row(world,cam,line,0,checksum))

pub fun main()
  val checksum = seeded fn() image(makeWorld(),makeCamera(),0,0)
  if checksum != 64158141444 then
    println("FAIL: expected 64158141444, got " ++ checksum.show)
    throw("wrong result")
