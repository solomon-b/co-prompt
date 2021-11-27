final: prev: {
  haskellPackages = prev.haskellPackages.override (old: {
    overrides = prev.lib.composeExtensions (old.overrides or (_: _: {}))
    (hfinal: hprev: {
      co-prompt = hfinal.callCabal2nix "co-prompt" (./.) { };
        });
  });
}
