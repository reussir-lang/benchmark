// Signed PCM mixing with a Q15 gain, linear fade, soft knee, and saturation.
// cdiv is required: ordinary Koka division uses Euclidean rounding.
import std/num/int32
import std/num/int64

fun limit( sample : int32 ) : exn int32
  val knee = if sample > 16384.int32 then
      16384.int32 + cdiv(sample - 16384.int32, 2.int32)
    elif sample < -16384.int32 then
      -16384.int32 + cdiv(sample + 16384.int32, 2.int32)
    else sample
  if knee > 32767.int32 then 32767.int32
  elif knee < -32768.int32 then -32768.int32
  else knee

// End the mutable scope before tail recursion so the destination remains unique.
fun set-at( values : vector<int32>, index : int, value : int32 ) : exn vector<int32>
  var result := values
  result[index] := value
  result

fun mix( dst : vector<int32>, src : vector<int32>, gain : int32, i : int ) : <exn,div> vector<int32>
  if i == 262144 then dst else
    val source = src[i]
    val previous = dst[i]
    val envelope = (i / 8).int32
    val scaled = cdiv(source * gain, 32768.int32)
    val faded = cdiv(scaled * envelope, 32768.int32)
    mix(set-at(dst, i, limit(previous + faded)), src, gain, i + 1)

fun tracks( dst : vector<int32>, src : vector<int32>, n : int ) : <exn,div> vector<int32>
  if n == 0 then dst else
    val gain = ((n * 1103) % 98304).int32 - 49152.int32
    tracks(mix(dst, src, gain, 0), src, n - 1)

pub fun main()
  val src = vector-init(262144) fn(i)
    val fundamental = ((i * 97) % 65536).int32 - 32768.int32
    val harmonic = ((i * 271) % 65536).int32 - 32768.int32
    val noise = ((i * 8191 + 37) % 1024).int32 - 512.int32
    cdiv(fundamental, 2.int32) + cdiv(harmonic, 4.int32) + noise
  val samples = tracks(vector(262144, 0.int32), src, 8192)
  var energy := 0.int64
  samples.foreach fn(sample)
    val value = sample.int64
    energy := energy + value * value
  if energy != 124776496343097.int64 then
    println("FAIL: expected 124776496343097, got " ++ energy.show)
    throw("wrong result")
