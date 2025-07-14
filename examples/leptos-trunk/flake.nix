{
  description = "leptos-trunk example";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    rust-flake.url = "github:juspay/rust-flake";
  };

  outputs = inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
      imports = [
        inputs.rust-flake.flakeModules.default
        inputs.rust-flake.flakeModules.nixpkgs
      ];
      perSystem = { pkgs, self', lib, config, ... }:
        let
          rustToolchainFor =
            p:
            p.rust-bin.stable.latest.default.override {
              # Set the build targets supported by the toolchain,
              # wasm32-unknown-unknown is required for trunk
              targets = [ "wasm32-unknown-unknown" ];
            };

          craneLib = config.rust-project.crane-lib.overrideToolchain rustToolchainFor;
          src = lib.cleanSourceWith {
            src = ./.; # The original, unfiltered source
            filter = path: type:
              (lib.hasSuffix "\.html" path) ||
              # Default filter from crane (allow .rs files)
              (craneLib.filterCargoSources path type);
          };

          commonArgs = {
            inherit src;
            strictDeps = true;
            # We must force the target, otherwise cargo will attempt to use your native target
            CARGO_BUILD_TARGET = "wasm32-unknown-unknown";

            buildInputs =
              [
                # Add additional build inputs here
              ]
              ++ lib.optionals pkgs.stdenv.isDarwin [
                # Additional darwin specific inputs can be set here
                pkgs.libiconv
              ];
          };

          cargoArtifacts = craneLib.buildDepsOnly (
            commonArgs
            // {
              # You cannot run cargo test on a wasm build
              doCheck = false;
            }
          );
          my-app = craneLib.buildTrunkPackage (
            commonArgs
            // {
              inherit cargoArtifacts;
              # The version of wasm-bindgen-cli here must match the one from Cargo.lock.
              # When updating to a new version replace the hash values with lib.fakeHash,
              # then try to do a build, which will fail but will print out the correct value
              # for `hash`. Replace the value and then repeat the process but this time the
              # printed value will be for the second `hash` below
              wasm-bindgen-cli = pkgs.buildWasmBindgenCli rec {
                src = pkgs.fetchCrate {
                  pname = "wasm-bindgen-cli";
                  version = "0.2.100";
                  hash = "sha256-3RJzK7mkYFrs7C/WkhW9Rr4LdP5ofb2FdYGz1P7Uxog=";
                };

                cargoDeps = pkgs.rustPlatform.fetchCargoVendor {
                  inherit src;
                  inherit (src) pname version;
                  hash = "sha256-qsO12332HSjWCVKtf1cUePWWb9IdYUmT+8OPj/XP2WE=";
                };
              };
            }
          );

          # Quick example on how to serve the app,
          # This is just an example, not useful for production environments
          serve-app = pkgs.writeShellScriptBin "serve-app" ''
            ${pkgs.python3Minimal}/bin/python3 -m http.server --directory ${my-app} 8000
          '';
        in
        {
          packages.default = my-app;
          apps.default = {
            type = "app";
            program = serve-app;
          };

          devShells.default = pkgs.mkShell {
            inputsFrom = [ self'.devShells.rust ];
            packages = [ pkgs.trunk ];
            shellHook = ''
              echo "Run \`trunk serve --open\` to run locally"
            '';
          };
        };
    };
}
