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
        ./nix/modules/rust.nix
      ];
      perSystem = { pkgs, self', ... }: {
        devShells.default = self'.devShells.trunk;
        packages.default = self'.packages.my-app;
        apps.default = self'.apps.my-app;

        devShells.trunk = pkgs.mkShell {
          inputsFrom = [ self'.devShells.rust ];
          packages = [ pkgs.trunk ];
          shellHook = ''
            echo "Run \`trunk serve --open\` to run locally"
          '';
        };
      };
    };
}
