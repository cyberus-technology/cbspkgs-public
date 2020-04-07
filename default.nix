{
  niv ? import nix/sources.nix,
  nixpkgs ? niv.nixpkgs,
  pkgs ? import nixpkgs {}
}:
rec {
  inherit (niv) nixpkgs;
  lib = import ./lib { inherit pkgs; };
  modules = import ./modules { inherit niv; };

  bender = pkgs.callPackage niv.bender {};

  hydra = pkgs.callPackage ./pkgs/hydra { src = niv.hydra; };

  initrds = import ./pkgs/initrd-creator/release.nix {
    inherit pkgs ;
    cbsLib = lib;
  };

  ipxe = pkgs.callPackage ./pkgs/ipxe { src = niv.ipxe; };

  run-sotest = pkgs.callPackage ./pkgs/run-sotest {};

  sotest-kernels = import ./pkgs/kernels { inherit pkgs; };

  sotest-testruns = import ./pkgs/sotest-testruns {
    inherit pkgs;
    inherit (initrds) initrds;
    cbsLib = lib;
    kernels = sotest-kernels;
  };

  tup = pkgs.callPackage ./pkgs/tup { src = niv.tup; };
}
