final: prev:
let
  sources = import ./sources.nix;

  lib = import ../lib { pkgs = final; };
  initrdSet = import ../pkgs/initrd-creator/release.nix {
    pkgs = final;
    cbsLib = lib;
  };
  kernelSet = import ../pkgs/kernels { pkgs = final; };
in {
  inherit lib;

  bender = prev.callPackage sources.bender {};

  initrds = prev.recurseIntoAttrs
    (builtins.mapAttrs (_: prev.recurseIntoAttrs) initrdSet);

  ipxe = prev.callPackage ../pkgs/ipxe { src = sources.ipxe; };

  run-sotest = prev.callPackage ../pkgs/run-sotest {};

  sotest-kernels = prev.recurseIntoAttrs kernelSet;

  sotest-testruns = prev.recurseIntoAttrs (import ../pkgs/sotest-testruns {
    pkgs = prev;
    inherit (initrdSet) initrds;
    cbsLib = lib;
    kernels = kernelSet;
  });
}
