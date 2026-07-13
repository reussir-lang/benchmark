{
  description = "Reussir cross-language benchmark suite";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";

    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Current Reussir main (2026-07-12).
    reussir = {
      url = "github:reussir-lang/reussir/15a6e37e99b067e5722a7ec4544f5b976de67d54";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.fenix.follows = "fenix";
      inputs.flake-utils.follows = "flake-utils";
    };

    # Reussir uses FetchContent for Immer. Make it an explicit flake input so
    # the compiler build is network-free.
    immer = {
      url = "github:arximboldi/immer/06d94ce48a02b11d3b225083a820f82c3d3ef462";
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
      ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        lib = pkgs.lib;
        llvmPkgs = pkgs.llvmPackages_22;

        rustToolchain = fenix.packages.${system}.fromToolchainFile {
          file = "${reussir}/rust-toolchain.toml";
          sha256 = "sha256-7gtdtMrnS61/fyYXzXomlz9yIODc+zU9kfn2mIVsPYM=";
        };

        rustChannel =
          (builtins.fromTOML (builtins.readFile "${reussir}/rust-toolchain.toml")).toolchain.channel;

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
          hash = "sha256-GkAB8xFH6tNZqx+EnZyU0W7LlDQ8fhJgGzJnfXHyLZk=";
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

            # rrc needs libreussir_rt.a, not a private copy of the complete
            # nightly Rust toolchain in build/{bin,lib}.
            substituteInPlace crates/reussir-rt/CMakeLists.txt \
              --replace-fail 'DEPENDS reussir-rt-install reussir-rust-install' 'DEPENDS reussir-rt-install' \
              --replace-fail 'add_dependencies(reussir-rt reussir-rt-install reussir-rust-install)' 'add_dependencies(reussir-rt reussir-rt-install)'

            # rrc's Rust link consumes every archive listed by
            # reussir-backend-sys/build.rs.  Upstream's ReussirCAPI dependency
            # list currently omits these two, so an explicit `rrc` build can
            # reach cargo before the archives exist.
            substituteInPlace lib/CAPI/CMakeLists.txt \
              --replace-fail \
                '  # transformations' \
                $'  # transformations\n  MLIRReussirClosureBetaReduction' \
              --replace-fail \
                '  MLIRReussirTokenReuse' \
                $'  MLIRReussirTokenReuse\n  MLIRReussirSpecialPointerTag'
          '';

          LLVM_DIR = "${llvmMlirJoin}/lib/cmake/llvm";
          MLIR_DIR = "${llvmMlirJoin}/lib/cmake/mlir";
          MLIR_SYS_220_PREFIX = llvmMlirJoin;
          MLIR_SYS_210_PREFIX = llvmMlirJoin;
          TABLEGEN_220_PREFIX = llvmMlirJoin;
          LLVM_SYS_221_PREFIX = llvmMlirJoin;
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
          ];

          preConfigure = ''
            rust_host=$(rustc -vV | sed -n 's/^host: //p')
            toolchain_dir="build/.rustup/toolchains/${rustChannel}-$rust_host"
            mkdir -p "$(dirname "$toolchain_dir")"
            ln -s ${rustToolchain} "$toolchain_dir"
          '';

          buildPhase = ''
            runHook preBuild
            # The CMake setup hook enters its out-of-source build directory.
            cmake --build . --target rrc -j "$NIX_BUILD_CORES"
            runHook postBuild
          '';

          installPhase = ''
            runHook preInstall
            mkdir -p "$out/bin" "$out/lib"
            cp bin/rrc "$out/bin/rrc"
            cp lib/libreussir_rt.a "$out/lib/libreussir_rt.a"
            wrapProgram "$out/bin/rrc" \
              --prefix LD_LIBRARY_PATH : "${
                lib.makeLibraryPath [
                  llvmPkgs.llvm.lib
                  llvmPkgs.mlir
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

        ghcBase = pkgs.haskellPackages.ghc;
        fingertreePackage = pkgs.haskellPackages.fingertree;
        fingertreePackageDb = pkgs.runCommand "fingertree-package-db" { } ''
          mkdir -p "$out"
          cp ${fingertreePackage}/lib/ghc-${ghcBase.version}/lib/package.conf.d/*.conf "$out/"
          chmod u+w "$out"/*.conf
          ${ghcBase}/lib/ghc-${ghcBase.version}/bin/ghc-pkg-${ghcBase.version} \
            --global-package-db="$out" recache
        '';
        ghc = pkgs.writeShellScriptBin "ghc" ''
          exec ${ghcBase}/bin/ghc -package-db ${fingertreePackageDb} "$@"
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
                pkgs.ocaml
                pkgs.hyperfine
                pkgs.time
                pkgs.mimalloc
                python
              ];

              REUSSIR_COMPILER = "${reussirCompiler}/bin/rrc";
              # The bitcode runtime, so reussir's link gets the same
              # runtime-LTO treatment compile.py gives kklib.
              REUSSIR_LIBS = "${reussirRtXlto}/lib";
              BENCHMARK_CC = "${llvmPkgs.clang}/bin/clang";
              BENCHMARK_LEAN = "${pkgs.lean4}/bin/lean";
              BENCHMARK_LEANC = "${pkgs.lean4}/bin/leanc";
              BENCHMARK_KOKA = "${pkgs.koka}/bin/koka";
              BENCHMARK_RUSTC = "${pkgs.rustc}/bin/rustc";
              BENCHMARK_GHC = "${ghc}/bin/ghc";
              BENCHMARK_OCAMLOPT = "${pkgs.ocaml}/bin/ocamlopt";
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
