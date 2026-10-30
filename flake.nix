{
  description = "Reussir cross-language benchmark suite";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";

    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Current Reussir main (2026-10-29, LLVM/MLIR 23.1).
    reussir = {
      url = "github:reussir-lang/reussir/0cf8c9afa4f66568b52c3912debc05c046afc24c";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.fenix.follows = "fenix";
      inputs.flake-utils.follows = "flake-utils";
    };

    # Reussir uses FetchContent for Immer, mlir-sync, and mlir-rcgmp. Make them
    # explicit flake inputs so the compiler build is network-free. Keep the
    # revisions matched to cmake/{Immer,MlirSync,RCGMP}.cmake at the pinned
    # Reussir commit.
    immer = {
      url = "github:arximboldi/immer/06d94ce48a02b11d3b225083a820f82c3d3ef462";
      flake = false;
    };
    mlir-sync = {
      url = "github:reussir-lang/mlir-sync/018206f4df254fe205f0b63068cd133e5e94ba42";
      flake = false;
    };
    mlir-rcgmp = {
      url = "github:reussir-lang/mlir-rcgmp/cc73b218f6ce90b005744c4e94b2b32a0e30c725";
      flake = false;
    };
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      flake-utils,
      fenix,
      reussir,
      immer,
      mlir-sync,
      mlir-rcgmp,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        lib = pkgs.lib;
        llvmPkgs = pkgs.llvmPackages_23;

        rustToolchain = fenix.packages.${system}.fromToolchainFile {
          file = "${reussir}/rust-toolchain.toml";
          sha256 = "sha256-ko0a8G9o/p60mphrxmH0dNQsUdWkKMBaGexsqEqtCF4=";
        };

        # mlir-sys and llvm-sys require one prefix containing both the runtime
        # libraries and the development files. nixpkgs splits those outputs.
        llvmMlirJoin = pkgs.symlinkJoin {
          name = "reussir-llvm-mlir-${llvmPkgs.release_version}";
          paths = [
            llvmPkgs.llvm.dev
            llvmPkgs.llvm.lib
            llvmPkgs.mlir.dev
            llvmPkgs.mlir
            llvmPkgs.tblgen
          ];
          postBuild = ''
            sed -i \
              "s|set(LLVM_INSTALL_PREFIX \"[^\"]*\")|set(LLVM_INSTALL_PREFIX \"$out\")|" \
              "$out/lib/cmake/llvm/LLVMConfig.cmake"

            rm "$out/bin/llvm-config"
            substituteAll ${./nix/llvm-config.sh} "$out/bin/llvm-config"
            chmod +x "$out/bin/llvm-config"
          '';
          llvmConfig = "${llvmPkgs.llvm.dev}/bin/llvm-config";
          llvmDev = llvmPkgs.llvm.dev;
          llvmLib = llvmPkgs.llvm.lib;
          llvmOut = llvmPkgs.llvm;
          runtimeShell = pkgs.runtimeShell;
        };

        # clang-scan-deps and bindgen bypass the compiler wrapper and therefore
        # need the system include paths recorded explicitly.
        nixSystemFlags =
          let
            extractPaths =
              file: token:
              let
                words = builtins.filter (s: s != "") (lib.splitString " " (builtins.readFile file));
                indexed = lib.imap0 (i: value: { inherit i value; }) words;
              in
              map (entry: builtins.elemAt words (entry.i + 1)) (
                builtins.filter (entry: entry.value == token) indexed
              );
            gccCxxPaths = extractPaths "${llvmPkgs.stdenv.cc}/nix-support/libcxx-cxxflags" "-cxx-isystem";
            glibcPaths = extractPaths "${llvmPkgs.stdenv.cc}/nix-support/libc-cflags" "-idirafter";
          in
          lib.concatStringsSep " " (
            (map (path: "-isystem ${path}") gccCxxPaths) ++ (map (path: "-idirafter ${path}") glibcPaths)
          );

        reussirCargoDeps = pkgs.rustPlatform.fetchCargoVendor {
          src = reussir;
          hash = "sha256-GiUnaUZD3x3Ifx6hGrBTOj9dWjRbRpAhn9R4HMSmkvM=";
        };

        reussirCompiler = llvmPkgs.stdenv.mkDerivation {
          pname = "reussir";
          version = "0.1.0-git-${builtins.substring 0 12 reussir.rev}";
          src = reussir;

          cargoDeps = reussirCargoDeps;
          cargoRoot = ".";

          nativeBuildInputs = [
            pkgs.cmake
            pkgs.ninja
            pkgs.pkg-config
            pkgs.rustPlatform.cargoSetupHook
            rustToolchain
            llvmPkgs.clang
            llvmPkgs.lld
            llvmPkgs.clang-tools
            llvmPkgs.tblgen
            pkgs.makeWrapper
          ];

          buildInputs = [
            pkgs.gmp
            pkgs.gtest
            pkgs.spdlog
            pkgs.zlib
            pkgs.libxml2
            llvmPkgs.llvm
            llvmPkgs.llvm.dev
            llvmPkgs.llvm.lib
            llvmPkgs.mlir
            llvmPkgs.mlir.dev
          ];

          hardeningDisable = [
            "fortify"
            "fortify3"
          ];

          postPatch = ''
            # The benchmark only needs the LLVM-backed AOT compiler. TPDE is
            # an optional backend whose upstream source requires nested git
            # submodules that GitHub flake archives do not contain.
            substituteInPlace CMakeLists.txt \
              --replace-fail 'if(TARGET_OBJECT_FORMAT STREQUAL "ELF")' 'if(FALSE)'
          '';

          LLVM_DIR = "${llvmMlirJoin}/lib/cmake/llvm";
          MLIR_DIR = "${llvmMlirJoin}/lib/cmake/mlir";
          MLIR_SYS_230_PREFIX = llvmMlirJoin;
          TABLEGEN_230_PREFIX = llvmMlirJoin;
          LLVM_SYS_231_PREFIX = llvmMlirJoin;
          LIBCLANG_PATH = "${llvmPkgs.libclang.lib}/lib";
          BINDGEN_EXTRA_CLANG_ARGS = nixSystemFlags;
          MLIR_TABLEGEN_EXE_OVERRIDE = "${llvmPkgs.tblgen}/bin/mlir-tblgen";
          CXXFLAGS = nixSystemFlags;
          # Proc-macro dylibs load LLVM TableGen C++ code inside rustc.  Keep
          # the same loader path as Reussir's own development shell; without
          # libstdc++ rustc misleadingly reports that melior_macro is absent.
          LD_LIBRARY_PATH = lib.makeLibraryPath [
            llvmPkgs.llvm.lib
            llvmPkgs.mlir
            pkgs.stdenv.cc.cc.lib
            pkgs.zlib
          ];

          cmakeFlags = [
            "-GNinja"
            (lib.cmakeBool "REUSSIR_ENABLE_TESTS" false)
            (lib.cmakeBool "LLVM_ENABLE_LIBCXX" true)
            (lib.cmakeFeature "CMAKE_BUILD_TYPE" "Release")
            (lib.cmakeFeature "CMAKE_C_COMPILER" "clang")
            (lib.cmakeFeature "CMAKE_CXX_COMPILER" "clang++")
            (lib.cmakeFeature "LLVM_DIR" "${llvmMlirJoin}/lib/cmake/llvm")
            (lib.cmakeFeature "MLIR_DIR" "${llvmMlirJoin}/lib/cmake/mlir")
            (lib.cmakeFeature "FETCHCONTENT_SOURCE_DIR_IMMER" "${immer}")
            (lib.cmakeFeature "FETCHCONTENT_SOURCE_DIR_MLIRSYNC" "${mlir-sync}")
            (lib.cmakeFeature "FETCHCONTENT_SOURCE_DIR_RCGMP" "${mlir-rcgmp}")
          ];

          buildPhase = ''
            runHook preBuild
            # The CMake setup hook enters its out-of-source build directory.
            # `reussir-rt` builds the plain (non-LTO) runtime archive into
            # target-rt/; upstream no longer stages it under build/lib.
            cmake --build . --target rrc reussir-rt -j "$NIX_BUILD_CORES"
            runHook postBuild
          '';

          installPhase = ''
            runHook preInstall
            mkdir -p "$out/bin" "$out/lib"
            cp bin/rrc "$out/bin/rrc"
            cp target-rt/release/libreussir_rt.a "$out/lib/libreussir_rt.a"
            cp lib/libRCGMPRuntime.a "$out/lib/libRCGMPRuntime.a"
            wrapProgram "$out/bin/rrc" \
              --prefix LD_LIBRARY_PATH : "${
                lib.makeLibraryPath [
                  llvmPkgs.llvm.lib
                  llvmPkgs.mlir
                  pkgs.gmp
                  pkgs.stdenv.cc.cc.lib
                  pkgs.zlib
                ]
              }"
            runHook postInstall
          '';

          meta = {
            description = "Pinned Reussir compiler used by the benchmark suite";
            homepage = "https://github.com/reussir-lang/reussir";
            license = lib.licenses.asl20;
            platforms = lib.platforms.linux;
          };
        };

        # The runtime archive rrc-linked applications embed. Built with
        # linker-plugin-LTO so the application's ThinLTO link can inline the
        # allocation/RC entry points — the exact symmetry Koka gets from
        # compiling kklib with `--ccopts=-flto=thin` (compile.py): without
        # it every `__reussir_allocate(8, 40)` stays an opaque call while
        # kk_malloc_small inlines, which alone was measured worth 15% on
        # nbe-closure. The explicit CFLAGS must re-state
        # `-DMI_MAX_ALIGN_SIZE=8`: setting the variable overrides the [env]
        # entry in reussir's .cargo/config.toml, and silently losing the
        # 8-granular mimalloc bins would reopen the per-constructor-sizing
        # gap through a different door.
        reussirRtXlto = llvmPkgs.stdenv.mkDerivation {
          pname = "reussir-rt-xlto";
          version = "0.1.0-git-${builtins.substring 0 12 reussir.rev}";
          src = reussir;

          cargoDeps = reussirCargoDeps;
          cargoRoot = ".";

          nativeBuildInputs = [
            pkgs.rustPlatform.cargoSetupHook
            rustToolchain
            llvmPkgs.clang
          ];

          CFLAGS = "-flto=thin -DMI_MAX_ALIGN_SIZE=8";
          RUSTFLAGS = "-Clinker-plugin-lto";

          buildPhase = ''
            runHook preBuild
            cargo build --release -p reussir-rt -j "$NIX_BUILD_CORES"
            runHook postBuild
          '';

          installPhase = ''
            runHook preInstall
            mkdir -p "$out/lib"
            cp target/release/libreussir_rt.a "$out/lib/libreussir_rt.a"
            runHook postInstall
          '';

          meta = {
            description = "Reussir runtime archive as LLVM bitcode for consumer ThinLTO links";
            homepage = "https://github.com/reussir-lang/reussir";
            license = lib.licenses.asl20;
            platforms = lib.platforms.linux;
          };
        };

        # The rlib form of the runtime plus its dependency rlibs, laid out for
        # `rustc -L`: rrc's polymorphic-FFI textures compile generated Rust
        # against these (discovered through REUSSIR_RUSTC/REUSSIR_RUSTC_DEPS).
        # Std's package build reaches polyffi, so std-using benchmarks need
        # this even though the final link still uses the LTO staticlib above.
        reussirRtRlibs = llvmPkgs.stdenv.mkDerivation {
          pname = "reussir-rt-rlibs";
          version = "0.1.0-git-${builtins.substring 0 12 reussir.rev}";
          src = reussir;

          cargoDeps = reussirCargoDeps;
          cargoRoot = ".";

          nativeBuildInputs = [
            pkgs.rustPlatform.cargoSetupHook
            rustToolchain
            llvmPkgs.clang
          ];

          buildPhase = ''
            runHook preBuild
            cargo build --release -p reussir-rt -j "$NIX_BUILD_CORES"
            runHook postBuild
          '';

          installPhase = ''
            runHook preInstall
            mkdir -p "$out/lib/deps"
            cp target/release/libreussir_rt.rlib "$out/lib/" 2>/dev/null \
              || cp target/release/deps/libreussir_rt-*.rlib "$out/lib/"
            # The rlibs carry only stub metadata; the full metadata rides
            # sibling .rmeta files rustc must find next to them.
            cp target/release/deps/libreussir_rt.rmeta "$out/lib/" 2>/dev/null || true
            # Proc-macro crates (num_enum_derive & co.) are dylibs, and
            # rustc needs them next to the rlibs to load the metadata graph.
            cp target/release/deps/*.rlib target/release/deps/*.so "$out/lib/deps/"
            cp target/release/deps/*.rmeta "$out/lib/deps/" 2>/dev/null || true
            runHook postInstall
          '';

          meta = {
            description = "Reussir runtime rlibs for rrc's polymorphic-FFI compiles";
            homepage = "https://github.com/reussir-lang/reussir";
            license = lib.licenses.asl20;
            platforms = lib.platforms.linux;
          };
        };

        # The crates Rust cells link beyond std (rpds's persistent red-black
        # tree and HAMT for the rust-rpds variants; num-bigint and its trait
        # crates for the big-integer benchmarks), prebuilt as rlibs with the
        # same rustc that compiles the benchmark sources so compile.py can
        # pass them straight to `rustc --extern` without cargo.
        externCratesCargoDeps = pkgs.rustPlatform.fetchCargoVendor {
          src = ./rust/extern-crates;
          hash = "sha256-zeU4R0jaV7M3Mbkjn6jy9LTUKKx3NXC0j3JjkSPvl14=";
        };

        externCrates = pkgs.stdenv.mkDerivation {
          pname = "benchmark-rust-extern-crates";
          version = "1";
          src = ./rust/extern-crates;

          cargoDeps = externCratesCargoDeps;
          cargoRoot = ".";

          nativeBuildInputs = [
            pkgs.rustPlatform.cargoSetupHook
            pkgs.cargo
            pkgs.rustc
          ];

          buildPhase = ''
            runHook preBuild
            cargo build --release --offline -j "$NIX_BUILD_CORES"
            runHook postBuild
          '';

          installPhase = ''
            runHook preInstall
            mkdir -p "$out/lib"
            cp target/release/deps/*.rlib "$out/lib/"
            runHook postInstall
          '';
        };

        # Zarith, OCaml's GMP-backed big integers, for the big-integer
        # benchmarks; compile.py links it through ocamlfind.
        ocamlPackages = pkgs.ocamlPackages;

        ghcBase = pkgs.haskellPackages.ghc;
        # Hackage packages the benchmarks use beyond GHC's boot libraries:
        # fingertree (the published finger tree), and unordered-containers
        # (+ its hashable dependency) for the hash-map benchmark.
        extraHaskellPackages = [
          pkgs.haskellPackages.fingertree
          pkgs.haskellPackages.unordered-containers
          pkgs.haskellPackages.hashable
        ];
        extraPackageDb = pkgs.runCommand "benchmark-package-db" { } ''
          mkdir -p "$out"
          for pkg in ${lib.concatStringsSep " " (map toString extraHaskellPackages)}; do
            cp "$pkg"/lib/ghc-${ghcBase.version}/lib/package.conf.d/*.conf "$out/"
          done
          chmod u+w "$out"/*.conf
          ${ghcBase}/lib/ghc-${ghcBase.version}/bin/ghc-pkg-${ghcBase.version} \
            --global-package-db="$out" recache
        '';
        ghc = pkgs.writeShellScriptBin "ghc" ''
          exec ${ghcBase}/bin/ghc -package-db ${extraPackageDb} "$@"
        '';

        python = pkgs.python3.withPackages (pythonPackages: [
          pythonPackages.matplotlib
          pythonPackages.numpy
          pythonPackages.tqdm
        ]);
      in
      {
        packages.default = reussirCompiler;
        packages.reussir = reussirCompiler;
        packages.reussir-rt-xlto = reussirRtXlto;
        packages.reussir-rt-rlibs = reussirRtRlibs;
        packages.ghc = ghc;

        devShells.default =
          pkgs.mkShell.override
            {
              stdenv = llvmPkgs.stdenv;
            }
            {
              name = "reussir-benchmarks";
              packages = [
                reussirCompiler
                llvmPkgs.clang
                llvmPkgs.lld
                pkgs.lean4
                pkgs.koka
                # ocamlopt from nixpkgs is configured to invoke gcc when linking.
                pkgs.gcc
                pkgs.rustc
                pkgs.cargo
                ghc
                ocamlPackages.ocaml
                ocamlPackages.findlib
                pkgs.hyperfine
                pkgs.time
                pkgs.mimalloc
                python
              ];
              # GMP, which the big-integer cells link: the rcgmp runtime of
              # the Reussir cells and Zarith of the OCaml cells.
              buildInputs = [ pkgs.gmp ];

              REUSSIR_COMPILER = "${reussirCompiler}/bin/rrc";
              # The bitcode runtime, so reussir's link gets the same
              # runtime-LTO treatment compile.py gives kklib.
              REUSSIR_LIBS = "${reussirRtXlto}/lib";
              REUSSIR_RCGMP_RUNTIME = "${reussirCompiler}/lib/libRCGMPRuntime.a";
              # The pinned Reussir source: compile.py builds the bundled
              # core and std packages from here for std-using benchmarks.
              REUSSIR_SRC = "${reussir}";
              # Polymorphic-FFI discovery for rrc: the matching nightly rustc
              # and the runtime rlib closure it compiles textures against.
              REUSSIR_RUSTC = "${rustToolchain}/bin/rustc";
              REUSSIR_RUSTC_DEPS = "${reussirRtRlibs}/lib:${reussirRtRlibs}/lib/deps";
              BENCHMARK_CC = "${llvmPkgs.clang}/bin/clang";
              BENCHMARK_LEAN = "${pkgs.lean4}/bin/lean";
              BENCHMARK_LEANC = "${pkgs.lean4}/bin/leanc";
              BENCHMARK_KOKA = "${pkgs.koka}/bin/koka";
              BENCHMARK_RUSTC = "${pkgs.rustc}/bin/rustc";
              # Prebuilt rlibs for Rust cells that link crates beyond std.
              RUST_EXTERN_LIBS = "${externCrates}/lib";
              BENCHMARK_GHC = "${ghc}/bin/ghc";
              BENCHMARK_OCAMLOPT = "${ocamlPackages.ocaml}/bin/ocamlopt";
              BENCHMARK_OCAMLFIND = "${ocamlPackages.findlib}/bin/ocamlfind";
              OCAMLPATH = "${ocamlPackages.zarith}/lib/ocaml/${ocamlPackages.ocaml.version}/site-lib";
              BENCHMARK_HYPERFINE = "${pkgs.hyperfine}/bin/hyperfine";
              BENCHMARK_TIME = "${pkgs.time}/bin/time";
              MIMALLOC_LIB = "${pkgs.mimalloc}/lib/libmimalloc.so";

              shellHook = ''
                # These are local benchmark executables, and the configured
                # toolchains deliberately use -march=native for every native
                # backend.  Nix's purity guard would otherwise silently drop it.
                unset NIX_ENFORCE_NO_NATIVE
                echo "Reussir benchmark environment"
                echo "  Reussir: ${builtins.substring 0 12 reussir.rev}"
                echo "  Run:     python verify.py"
              '';
            };

        formatter = pkgs.nixfmt;
      }
    );
}
