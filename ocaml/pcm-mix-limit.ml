(* Signed PCM mixing, linear fade, soft knee, and hard saturation. *)
let samples = 262144
let passes = 8192

let limit sample =
  let knee =
    if sample > 16384 then 16384 + (sample - 16384) / 2
    else if sample < -16384 then -16384 + (sample + 16384) / 2
    else sample
  in
  max (-32768) (min 32767 knee)

let () =
  let source = Array.init samples (fun i ->
    let fundamental = (i * 97) mod 65536 - 32768 in
    let harmonic = (i * 271) mod 65536 - 32768 in
    let noise = (i * 8191 + 37) mod 1024 - 512 in
    fundamental / 2 + harmonic / 4 + noise) in
  let destination = Array.make samples 0 in
  for pass = passes downto 1 do
    let gain = (pass * 1103) mod 98304 - 49152 in
    for i = 0 to samples - 1 do
      let scaled = source.(i) * gain / 32768 in
      let faded = scaled * (i / 8) / 32768 in
      destination.(i) <- limit (destination.(i) + faded)
    done
  done;
  let energy = Array.fold_left (fun acc sample -> acc + sample * sample) 0 destination in
  if energy <> 124776496343097 then (
    Printf.eprintf "FAIL: unexpected checksum %d\n" energy;
    exit 1)
