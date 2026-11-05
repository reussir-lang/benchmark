(* Packed RGBA8 source-over blending onto an opaque destination. *)
let pixels = 262144
let passes = 4096

let channel source destination alpha =
  (source * alpha + destination * (255 - alpha) + 127) / 255

let blend destination source opacity =
  let alpha = ((source lsr 24) * opacity + 127) / 255 in
  let red = channel (source land 255) (destination land 255) alpha in
  let green = channel ((source lsr 8) land 255) ((destination lsr 8) land 255) alpha in
  let blue = channel ((source lsr 16) land 255) ((destination lsr 16) land 255) alpha in
  red lor (green lsl 8) lor (blue lsl 16) lor 0xff000000

let () =
  let source = Array.init pixels (fun i ->
    ((i * 17 + 23) mod 256) lor (((i * 43 + 7) mod 256) lsl 8)
    lor (((i * 97 + 61) mod 256) lsl 16) lor (((i * 31 + 13) mod 256) lsl 24)) in
  let destination = Array.init pixels (fun i ->
    ((i * 29 + 5) mod 256) lor (((i * 11 + 101) mod 256) lsl 8)
    lor (((i * 67 + 19) mod 256) lsl 16) lor 0xff000000) in
  for pass = passes downto 1 do
    let opacity = 96 + pass mod 160 in
    for i = 0 to pixels - 1 do
      destination.(i) <- blend destination.(i) source.(i) opacity
    done
  done;
  let checksum = Array.fold_left (+) 0 destination in
  if checksum <> 1123699998887936 then (
    Printf.eprintf "FAIL: unexpected checksum %d\n" checksum;
    exit 1)
