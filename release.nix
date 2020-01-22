{
  niv ? import nix/sources.nix,
  pkgs ? import niv.nixpkgs { config = { allowUnfree = true; }; }
}:
let
  cbsLib = import ./lib { inherit pkgs; };
  cbspkgs = import ./pkgs { inherit niv pkgs cbsLib; };
  flatten = with pkgs.lib; collect isDerivation;
  tests = import ./tests { inherit (niv) nixpkgs; };
in
  assert (import ./lib/tests { inherit cbsLib; });
  cbspkgs // {
    inherit tests;
  } // {
  # we need this dummy job to make hydra's gitlab status plugin reliable
  # See https://github.com/NixOS/hydra/issues/681
  # All packages, the tests, and the complete source directory have to be dependencies for this job
  successStatus = pkgs.writeText "all-dependencies" ''
    ${builtins.concatStringsSep "\n" (flatten cbspkgs ++ flatten tests)}
    ${./.}
  '';
}
