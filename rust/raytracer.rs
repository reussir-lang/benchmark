// Adapted from kmill/lean4-raytracer, copyright 2021 Kyle Miller.
// SPDX-License-Identifier: Apache-2.0

use std::ops::{Add, Div, Mul, Neg, Sub};

const WIDTH: usize = 128;
const HEIGHT: usize = 85;
const SAMPLES: usize = 4;
const DEPTH: usize = 10;
const EXPECTED: u64 = 64_158_141_444;

#[derive(Clone, Copy)]
struct Vec3 {
    x: f64,
    y: f64,
    z: f64,
}
impl Vec3 {
    const fn new(x: f64, y: f64, z: f64) -> Self {
        Self { x, y, z }
    }
    fn dot(self, rhs: Self) -> f64 {
        (self.x * rhs.x + self.y * rhs.y) + self.z * rhs.z
    }
    fn length(self) -> f64 {
        self.dot(self).sqrt()
    }
    fn unit(self) -> Self {
        self / self.length()
    }
    fn cross(self, rhs: Self) -> Self {
        Self::new(
            self.y * rhs.z - self.z * rhs.y,
            self.z * rhs.x - self.x * rhs.z,
            self.x * rhs.y - self.y * rhs.x,
        )
    }
    fn reflect(self, normal: Self) -> Self {
        self - normal * (2.0 * self.dot(normal))
    }
    fn refract(self, normal: Self, ratio: f64) -> Self {
        let cosine = (-self.dot(normal)).min(1.0);
        let perpendicular = (self + normal * cosine) * ratio;
        perpendicular + normal * -(1.0 - perpendicular.dot(perpendicular)).abs().sqrt()
    }
}
impl Add for Vec3 {
    type Output = Self;
    fn add(self, r: Self) -> Self {
        Self::new(self.x + r.x, self.y + r.y, self.z + r.z)
    }
}
impl Sub for Vec3 {
    type Output = Self;
    fn sub(self, r: Self) -> Self {
        Self::new(self.x - r.x, self.y - r.y, self.z - r.z)
    }
}
impl Mul for Vec3 {
    type Output = Self;
    fn mul(self, r: Self) -> Self {
        Self::new(self.x * r.x, self.y * r.y, self.z * r.z)
    }
}
impl Mul<f64> for Vec3 {
    type Output = Self;
    fn mul(self, r: f64) -> Self {
        Self::new(r * self.x, r * self.y, r * self.z)
    }
}
impl Div<f64> for Vec3 {
    type Output = Self;
    fn div(self, r: f64) -> Self {
        Self::new(self.x / r, self.y / r, self.z / r)
    }
}
impl Neg for Vec3 {
    type Output = Self;
    fn neg(self) -> Self {
        Self::new(-self.x, -self.y, -self.z)
    }
}
const BLACK: Vec3 = Vec3::new(0.0, 0.0, 0.0);
const WHITE: Vec3 = Vec3::new(1.0, 1.0, 1.0);

struct Rng {
    s1: i64,
    s2: i64,
}
impl Rng {
    fn new(seed: i64) -> Self {
        Self {
            s1: seed % 2_147_483_562 + 1,
            s2: (seed / 2_147_483_562) % 2_147_483_398 + 1,
        }
    }
    fn random(&mut self, lo: f64, hi: f64) -> f64 {
        let k1 = self.s1 / 53_668;
        let a = 40_014 * (self.s1 - k1 * 53_668) - k1 * 12_211;
        self.s1 = if a < 0 { a + 2_147_483_563 } else { a };
        let k2 = self.s2 / 52_774;
        let b = 40_692 * (self.s2 - k2 * 52_774) - k2 * 3_791;
        self.s2 = if b < 0 { b + 2_147_483_399 } else { b };
        let z = self.s1 - self.s2;
        let n = if z < 1 {
            z + 2_147_483_562
        } else {
            z % 2_147_483_562
        };
        let n = if n == 0 { 0 } else { n - 1 };
        lo + (hi - lo) * (n as f64 / 2_147_483_562.0)
    }
    fn vector(&mut self, lo: f64, hi: f64) -> Vec3 {
        let x = self.random(lo, hi);
        let y = self.random(lo, hi);
        let z = self.random(lo, hi);
        Vec3::new(x, y, z)
    }
    fn sphere(&mut self) -> Vec3 {
        for _ in 0..100 {
            let p = self.vector(-1.0, 1.0);
            if p.dot(p) < 1.0 {
                return p;
            }
        }
        Vec3::new(1.0, 0.0, 0.0)
    }
    fn disk(&mut self) -> Vec3 {
        for _ in 0..100 {
            let x = self.random(-1.0, 1.0);
            let y = self.random(-1.0, 1.0);
            let p = Vec3::new(x, y, 0.0);
            if p.dot(p) < 1.0 {
                return p;
            }
        }
        BLACK
    }
}
#[derive(Clone, Copy)]
struct Ray {
    origin: Vec3,
    direction: Vec3,
}
#[derive(Clone, Copy)]
enum Material {
    Lambertian(Vec3),
    Metal(Vec3, f64),
    Dielectric(f64),
    Sky,
}
struct Sphere {
    center: Vec3,
    radius: f64,
    material: Material,
}
struct Hit {
    point: Vec3,
    distance: f64,
    material: Material,
    normal: Vec3,
    front: bool,
}
impl Sphere {
    fn hit(&self, ray: Ray, closest: f64) -> Option<Hit> {
        let oc = ray.origin - self.center;
        let a = ray.direction.dot(ray.direction);
        let half_b = oc.dot(ray.direction);
        let c = oc.dot(oc) - self.radius * self.radius;
        let discriminant = half_b * half_b - a * c;
        if discriminant < 0.0 {
            return None;
        }
        let sqrt = discriminant.sqrt();
        let near = (-half_b - sqrt) / a;
        let root = if near < 0.001 || closest < near {
            (-half_b + sqrt) / a
        } else {
            near
        };
        if root < 0.001 || closest < root {
            return None;
        }
        let point = ray.origin + ray.direction * root;
        let outward = (point - self.center) / self.radius;
        let front = ray.direction.dot(outward) < 0.0;
        Some(Hit {
            point,
            distance: root,
            material: self.material,
            normal: if front { outward } else { -outward },
            front,
        })
    }
}
struct World {
    spheres: Vec<Sphere>,
}
impl World {
    fn push(&mut self, center: Vec3, radius: f64, material: Material) {
        self.spheres.push(Sphere {
            center,
            radius,
            material,
        });
    }
    fn random(rng: &mut Rng) -> Self {
        let mut world = Self {
            spheres: Vec::with_capacity(488),
        };
        world.push(
            Vec3::new(0.0, -1000.0, 0.0),
            1000.0,
            Material::Lambertian(Vec3::new(0.5, 0.5, 0.5)),
        );
        for i in 0..484 {
            let a = (i / 22) as f64 - 11.0;
            let b = (i % 22) as f64 - 11.0;
            let x = rng.random(0.0, 1.0);
            let z = rng.random(0.0, 1.0);
            let center = Vec3::new(a + 0.9 * x, 0.2, b + 0.9 * z);
            if (center - Vec3::new(4.0, 0.2, 0.0)).length() <= 0.9 {
                continue;
            }
            let choice = rng.random(0.0, 1.0);
            let material = if choice < 0.9 {
                let first = rng.vector(0.0, 1.0);
                let second = rng.vector(0.0, 1.0);
                Material::Lambertian(first * second)
            } else if choice < 0.95 {
                let albedo = rng.vector(0.5, 1.0);
                let fuzz = rng.random(0.0, 0.5);
                Material::Metal(albedo, fuzz)
            } else {
                Material::Dielectric(1.5)
            };
            world.push(center, 0.2, material);
        }
        world.push(Vec3::new(0.0, 1.0, 0.0), 1.0, Material::Dielectric(1.5));
        world.push(
            Vec3::new(-4.0, 1.0, 0.0),
            1.0,
            Material::Lambertian(Vec3::new(0.4, 0.2, 0.1)),
        );
        world.push(
            Vec3::new(4.0, 1.0, 0.0),
            1.0,
            Material::Metal(Vec3::new(0.7, 0.6, 0.5), 0.0),
        );
        world
    }
    fn hit(&self, ray: Ray) -> Hit {
        let mut nearest = Hit {
            point: BLACK,
            distance: 1e100,
            material: Material::Sky,
            normal: BLACK,
            front: true,
        };
        for sphere in &self.spheres {
            if let Some(hit) = sphere.hit(ray, nearest.distance) {
                nearest = hit;
            }
        }
        nearest
    }

    fn color(&self, mut ray: Ray, rng: &mut Rng) -> Vec3 {
        let mut accumulated = WHITE;
        for _ in 0..DEPTH {
            let hit = self.hit(ray);
            let direction = match hit.material {
                Material::Sky => {
                    let unit = ray.direction.unit();
                    let t = 0.5 * (unit.y + 1.0);
                    return accumulated * (WHITE * (1.0 - t) + Vec3::new(0.5, 0.7, 1.0) * t);
                }
                Material::Lambertian(albedo) => {
                    let scatter = hit.normal + rng.sphere().unit();
                    accumulated = albedo * accumulated;
                    if scatter.dot(scatter) < 1e-16 {
                        hit.normal
                    } else {
                        scatter
                    }
                }
                Material::Metal(albedo, fuzz) => {
                    let reflected = ray.direction.unit().reflect(hit.normal);
                    let direction = reflected + rng.sphere() * fuzz;
                    if direction.dot(hit.normal) <= 0.0 {
                        return accumulated * BLACK;
                    }
                    accumulated = albedo * accumulated;
                    direction
                }
                Material::Dielectric(index) => {
                    let ratio = if hit.front { 1.0 / index } else { index };
                    let unit = ray.direction.unit();
                    let cosine = (-unit.dot(hit.normal)).min(1.0);
                    let sine = (1.0 - cosine * cosine).sqrt();
                    let r0p = (1.0 - ratio) / (1.0 + ratio);
                    let r0 = r0p * r0p;
                    let reflectance = r0 + (1.0 - r0) * (1.0 - cosine).powf(5.0);
                    let sample = rng.random(0.0, 1.0);
                    accumulated = WHITE * accumulated;
                    if ratio * sine > 1.0 || reflectance > sample {
                        unit.reflect(hit.normal)
                    } else {
                        unit.refract(hit.normal, ratio)
                    }
                }
            };
            ray = Ray {
                origin: hit.point,
                direction,
            };
        }
        BLACK
    }
}
struct Camera {
    origin: Vec3,
    lower_left: Vec3,
    horizontal: Vec3,
    vertical: Vec3,
    u: Vec3,
    v: Vec3,
}
impl Camera {
    fn new() -> Self {
        let origin = Vec3::new(13.0, 2.0, 3.0);
        let w = origin.unit();
        let u = Vec3::new(0.0, 1.0, 0.0).cross(w).unit();
        let v = w.cross(u);
        let theta = 20.0 / 180.0 * std::f64::consts::PI;
        let height = 2.0 * (theta / 2.0).tan();
        let horizontal = u * (10.0 * ((WIDTH as f64 / HEIGHT as f64) * height));
        let vertical = v * (10.0 * height);
        Self {
            origin,
            lower_left: origin - horizontal / 2.0 - vertical / 2.0 - w * 10.0,
            horizontal,
            vertical,
            u,
            v,
        }
    }
    fn ray(&self, s: f64, t: f64, rng: &mut Rng) -> Ray {
        let rd = rng.disk() * 0.05;
        let offset = self.u * rd.x + self.v * rd.y;
        Ray {
            origin: self.origin + offset,
            direction: self.lower_left + self.horizontal * s + self.vertical * t
                - self.origin
                - offset,
        }
    }
}
fn channel(value: f64) -> u64 {
    (256.0 * (value / SAMPLES as f64).sqrt()).clamp(0.0, 255.0) as u64
}
fn main() {
    let mut rng = Rng::new(0);
    let world = World::random(&mut rng);
    let camera = Camera::new();
    let mut checksum = 0;
    for line in 0..HEIGHT {
        for x in 0..WIDTH {
            let mut color = BLACK;
            for _ in 0..SAMPLES {
                let rx = rng.random(0.0, 1.0);
                let ry = rng.random(0.0, 1.0);
                let ray = camera.ray(
                    (x as f64 + rx) / WIDTH as f64,
                    ((HEIGHT - line - 1) as f64 + ry) / HEIGHT as f64,
                    &mut rng,
                );
                color = color + world.color(ray, &mut rng);
            }
            let index = ((line * WIDTH + x) * 3) as u64;
            checksum += (index + 1) * channel(color.x)
                + (index + 2) * channel(color.y)
                + (index + 3) * channel(color.z);
        }
    }
    assert_eq!(checksum, EXPECTED);
    println!("{checksum}");
}
