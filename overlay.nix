final: prev: {
  haskellPackages = prev.haskellPackages.override (old: {
    overrides = prev.lib.composeExtensions (old.overrides or (_: _: {}))
    (hfinal: hprev: {
      co-prompt = hfinal.callCabal2nix "co-prompt" (./.) { };
      fudgets =
        let pkg = final.fetchFromGitHub {
          owner = "solomon-b";
          repo = "fudgets";
          rev = "0.18.2";
          sha256 = "sha256-+TDE6LN+KRD0DiVbim7N7rvlUcQ8HB4jm22Bxc+Frj8=";
        };
        in hfinal.callCabal2nix "fudgets" pkg { };
        });
  });
}
