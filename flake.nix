{
  description = "nix flake";
  inputs.haskellNix.url = "github:input-output-hk/haskell.nix";
  inputs.nixpkgs.follows = "haskellNix/nixpkgs-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";
  outputs = { self, haskellNix, nixpkgs, flake-utils }:
    let systems = [ "x86_64-linux" "aarch64-linux" ]; in
    flake-utils.lib.eachSystem systems (system:
      let pkgs = haskellNix.legacyPackages.${system}; in
      let drv = compiler-nix-name: pkgs': pkgs'.haskell-nix.project {
        index-state = "2022-01-24T00:00:00Z";
        src = pkgs.haskell-nix.haskellLib.cleanGit {
          name = "test";
          src = ./.;
        };
        inherit compiler-nix-name;
      }; in
      rec {
        packages = {
            "exe:repro@8107" = (drv "ghc8107" pkgs).ghc-repro21767.components.exes.ghc-repro21767;
            "exe:repro@922"  = (drv "ghc922"  pkgs).ghc-repro21767.components.exes.ghc-repro21767;
        } // ({
            "x86_64-linux" = {
              "aarch64-linux:exe:repro@8107" = (drv "ghc8107" pkgs.pkgsCross.aarch64-multiplatform).ghc-repro21767.components.exes.ghc-repro21767;
              "aarch64-linux:exe:repro@922"  = (drv "ghc922"  pkgs.pkgsCross.aarch64-multiplatform).ghc-repro21767.components.exes.ghc-repro21767;
            };
        }.${system} or {});
        # build all packages in hydra.
        hydraJobs = packages;
      }
    );
  # --- Flake Local Nix Configuration ----------------------------
  nixConfig = {
    extra-substituters = ["https://cache.iog.io"];
    extra-trusted-public-keys = ["hydra.iohk.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ="];
    # post-build-hook = "./upload-to-cache.sh";
    allow-import-from-derivation = "true";
  };
}