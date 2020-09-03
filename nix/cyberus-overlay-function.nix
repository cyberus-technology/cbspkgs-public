{ sources ? {} # niv sources attrset
, overlayRepoList ? [] # keys in the sources attrset that provide cyberus overlays
}:

let
  # Expects a repo name from overlayRepoList and returns its
  # cyberus-overlay.nix function. Optionally substitutes the repo's origin
  # using substituteFunction
  cyberusOverlayFor = repoName: substituteFunction: let
    folder = substituteFunction repoName sources."${repoName}";
  in
    import "${folder}/nix/cyberus-overlay.nix";

  # The overlay transformer is applied to all these overlays.
  # Every external overlay function is written in a way that it exports to
  # pkgs directly. But we wrap them all into pkgs.cbspkgs.
  # While they import packages, they assume these are in pkgs.cbspkgs because this
  # is our distribution.
  overlayTransformer = substituteFunction: overlayFunction: self: super: let
    current = overlayFunction substituteFunction self super;
    passthrough = attrName: {
      "${attrName}" = (super.cbspkgs."${attrName}" or {}) // (current."${attrName}" or {});
    };
    extraAttrs = builtins.foldl' (l: r: l // passthrough r) {} ["lib" "nixosModules" "sotests" "tests"];
  in
    {
      cbspkgs = (super.cbspkgs or {} // current) // extraAttrs;
    };

  # This function peforms no substitution on the overlays
  id-substituter = _: x: x;

  # This function accepts an overlay-substituter function and returns a list of
  # overlay functions. The overlay-substituter accepts a repo name from
  # overlayRepoList and a derivation and returns a derivation.
  # (such derivations are typically paths)
  overlays-with-substitutes = f: builtins.map
    (x: overlayTransformer f (cyberusOverlayFor x))
    overlayRepoList;
  overlays = overlays-with-substitutes id-substituter;
in
{
  # Users of this repo:
  # - `overlays` is the list of overlays you need to obtain the pkgs by
  #   importing nixpkgs and overlaying them yourself.
  # - `overlays-with-substitutes` is a function that returns `overlays` after
  #   applying an overlay-substituter function.
  #   Cyberus-overlay repositories would use this to substitute themselves in
  #   their release.nix/default.nix functions.
  inherit overlays overlays-with-substitutes id-substituter;
}
