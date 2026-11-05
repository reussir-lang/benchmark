// Packed RGBA8 source-over compositing. int32 slots hold unsigned pixel bits;
// logical shifts extract channels, and uint64 zero-extends the final checksum.
import std/num/int32
import std/num/int64

fun channel( s : int32, d : int32, alpha : int32 ) : int32
  (s * alpha + d * (255.int32 - alpha) + 127.int32) / 255.int32

fun blend( dst : int32, src : int32, opacity : int32 ) : int32
  val alpha = (shr(src, 24) * opacity + 127.int32) / 255.int32
  val r = channel(and(src, 255.int32), and(dst, 255.int32), alpha)
  val g = channel(and(shr(src, 8), 255.int32), and(shr(dst, 8), 255.int32), alpha)
  val b = channel(and(shr(src, 16), 255.int32), and(shr(dst, 16), 255.int32), alpha)
  or(or(or(r, shl(g, 8)), shl(b, 16)), -16777216.int32)

// End the mutable scope before tail recursion so the destination remains unique.
fun set-at( values : vector<int32>, index : int, value : int32 ) : exn vector<int32>
  var result := values
  result[index] := value
  result

fun composite( dst : vector<int32>, src : vector<int32>, opacity : int32, i : int ) : <exn,div> vector<int32>
  if i == 262144 then dst else
    val d = dst[i]
    val s = src[i]
    composite(set-at(dst, i, blend(d, s, opacity)), src, opacity, i + 1)

fun layers( dst : vector<int32>, src : vector<int32>, n : int ) : <exn,div> vector<int32>
  if n == 0 then dst else
    layers(composite(dst, src, (96 + n % 160).int32, 0), src, n - 1)

pub fun main()
  val src = vector-init-total(262144) fn(i)
    val r = ((i * 17 + 23) % 256).int32
    val g = ((i * 43 + 7) % 256).int32
    val b = ((i * 97 + 61) % 256).int32
    val a = ((i * 31 + 13) % 256).int32
    or(or(or(r, shl(g, 8)), shl(b, 16)), shl(a, 24))
  val dst = vector-init-total(262144) fn(i)
    val r = ((i * 29 + 5) % 256).int32
    val g = ((i * 11 + 101) % 256).int32
    val b = ((i * 67 + 19) % 256).int32
    or(or(or(r, shl(g, 8)), shl(b, 16)), -16777216.int32)
  val pixels = layers(dst, src, 4096)
  var checksum := 0.int64
  pixels.foreach fn(pixel) checksum := checksum + pixel.uint64
  if checksum != 1123699998887936.int64 then
    println("FAIL: expected 1123699998887936, got " ++ checksum.show)
    throw("wrong result")
