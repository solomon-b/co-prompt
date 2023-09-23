{
  description = "Co-Prompt Co-Algebraic Prompts";

  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs/nixos-23.05;

    flake-utils = {
      url = github:numtide/flake-utils;
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, flake-utils }:
    let
      overlay = import ./overlay.nix;
      overlays = [ overlay ];
    in flake-utils.lib.eachSystem [ "x86_64-linux" ] (system:
      let pkgs = import nixpkgs { inherit system overlays; };
      in rec {
        devShells.default = pkgs.haskellPackages.shellFor {
          packages = p: [ p.co-prompt ];
          buildInputs = [
            pkgs.haskellPackages.cabal-install
            pkgs.haskellPackages.ghc
            pkgs.haskellPackages.haskell-language-server
            pkgs.nixfmt

            pkgs.xorg.libX11
            pkgs.xorg.libXext
          ];
        };
        packages.default = pkgs.haskellPackages.co-prompt;
        packages.co-prompt = pkgs.haskellPackages.co-prompt;
      }) // {
        overlays.default = overlay;
      };
}
