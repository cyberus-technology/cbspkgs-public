{ niv, pkgs, cbsLib }:

let
  inherit (pkgs) callPackage;
in rec {
  bender = pkgs.callPackage niv.bender {};

  cbspkgs = callPackage ./cbspkgs {};

  hydra = pkgs.callPackage ./hydra { src = niv.hydra; };

  initrds = import ./initrd-creator/release.nix { inherit pkgs cbsLib; };

  ipxe = callPackage ./ipxe { src = niv.ipxe; };

  run-sotest = callPackage ./run-sotest {};

  sotest-kernels = import ./kernels { inherit pkgs; };

  sotest-testruns = import ./sotest-testruns {
    inherit pkgs cbsLib;
    inherit (initrds) initrds;
    kernels = sotest-kernels;
  };

  tup = callPackage ./tup { src = niv.tup; };
}
