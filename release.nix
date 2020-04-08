{
  niv ? import nix/sources.nix,
  nixpkgs ? niv.nixpkgs,
  pkgs ? import nixpkgs { overlays = [ (import ./overlay.nix) ]; }
}:
let
  cbsLib = (import ./default.nix { inherit nixpkgs; }).lib;
  tests = import ./tests { inherit nixpkgs; };
  libtests = import ./lib/tests { inherit cbsLib; };

  flatten = with pkgs.lib; collect isDerivation;
  attrFilter = n: _: n != "lib" && n != "modules" && n != "nixpkgs";
in
  assert libtests;
  pkgs.lib.filterAttrs attrFilter pkgs.cbspkgs
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
