{
  description = "Co-Prompt Co-Algebraic Prompts";

  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs/nixos-21.05;

    flake-utils = {
      url = github:numtide/flake-utils;
      inputs.nixpkgs.follows = "nixpkgs";
    };

    easy-hls = {
      url = github:jkachmar/easy-hls-nix;
      inputs.nixpkgs.follows = "nixpkgs";
   };

  };

  outputs = { self, nixpkgs, easy-hls, flake-utils }:
    let
      overlay = import ./overlay.nix;
      overlays = [ overlay ];
    in flake-utils.lib.eachDefaultSystem (system:
      let pkgs = import nixpkgs { inherit system overlays; };
          haskell-language-server = pkgs.callPackage easy-hls {};
      in rec {
        devShell = pkgs.haskellPackages.shellFor {
          packages = p: [ p.co-prompt ];
          buildInputs = [
            pkgs.haskellPackages.cabal-install
            pkgs.haskell.compiler.ghc8107
            pkgs.xorg.libX11
            pkgs.xorg.libXext
            haskell-language-server
          ];
        };
        defaultPackage = pkgs.haskellPackages.co-prompt;
      }) // { inherit overlay overlays; };
}
