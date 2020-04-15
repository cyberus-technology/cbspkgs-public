{
  niv ? import nix/sources.nix,
  nixpkgs ? niv.nixpkgs,
  pkgs ? import nixpkgs { overlays = [ (import ./overlay.nix) ]; }
}:
let
  cbsLib = pkgs.cbspkgs.lib;
  tests = import ./tests { inherit nixpkgs; };
  libtests = import ./lib/tests { inherit cbsLib; };

  flatten = with pkgs.lib; collect isDerivation;
  attrFilter = n: _: n != "lib" && n != "modules" && n != "nixpkgs";

  # somehow hydra does not like the `recurseForDerivations = true;` attributes.
  # it says "in job ‘randomAttr.recurseForDerivations’: unsupported value: true"
  # if these are not filtered out. It remains to be researched why this does not
  # seem to be necessary in nixpkgs where such attributes are used, too.
  removeRecurseLabels = pkgs.lib.filterAttrsRecursive
    (n: _: n != "recurseForDerivations");
in
  assert libtests;
  removeRecurseLabels (pkgs.lib.filterAttrs attrFilter pkgs.cbspkgs)
  // { inherit tests; }
  // {
    # we need this dummy job to make hydra's gitlab status plugin reliable
    # See https://github.com/NixOS/hydra/issues/681
    # All packages, the tests, and the complete source directory have to be
    # dependencies for this job
    successStatus = pkgs.writeText "all-dependencies" ''
      ${builtins.concatStringsSep "\n" (flatten pkgs.cbspkgs ++ flatten tests)}
      ${./.}
    '';
  }
