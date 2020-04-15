{
  niv ? import nix/sources.nix,
  nixpkgs ? niv.nixpkgs,
  pkgs ? import nixpkgs {}
}:

let
  lib = import ./lib { inherit pkgs; };
  initrdSet = import ./pkgs/initrd-creator/release.nix {
    inherit pkgs;
    cbsLib = lib;
  };
  kernelSet = import ./pkgs/kernels { inherit pkgs; };
in pkgs.recurseIntoAttrs {
  inherit (niv) nixpkgs;
  inherit lib;
  modules = import ./modules { inherit niv; };

  bender = pkgs.callPackage niv.bender {};

  hydra = pkgs.callPackage ./pkgs/hydra { src = niv.hydra; };

  initrds = pkgs.recurseIntoAttrs
    (builtins.mapAttrs (_: pkgs.recurseIntoAttrs) initrdSet);

  ipxe = pkgs.callPackage ./pkgs/ipxe { src = niv.ipxe; };

  run-sotest = pkgs.callPackage ./pkgs/run-sotest {};

  sotest-kernels = pkgs.recurseIntoAttrs kernelSet;

  sotest-testruns = pkgs.recurseIntoAttrs (import ./pkgs/sotest-testruns {
    inherit pkgs;
    inherit (initrdSet) initrds;
    cbsLib = lib;
    kernels = kernelSet;
  });

  tup = pkgs.callPackage ./pkgs/tup { src = niv.tup; };
}
