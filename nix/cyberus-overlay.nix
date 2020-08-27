self: super:
let
  sources = import ./sources.nix;

  lib = import ../lib { pkgs = super; };
  initrdSet = import ../pkgs/initrd-creator/release.nix {
    pkgs = self;
    cbsLib = lib;
  };
  kernelSet = import ../pkgs/kernels { pkgs = self; };

in {
  inherit lib;

  bender = super.callPackage sources.bender {};

  initrds = self.recurseIntoAttrs
    (builtins.mapAttrs (_: self.recurseIntoAttrs) initrdSet);

  ipxe = super.callPackage ../pkgs/ipxe { src = sources.ipxe; };

  run-sotest = super.callPackage ../pkgs/run-sotest {};

  sotest-kernels = super.recurseIntoAttrs kernelSet;

  sotest-testruns = super.recurseIntoAttrs (import ../pkgs/sotest-testruns {
    pkgs = self;
    inherit (initrdSet) initrds;
    cbsLib = lib;
    kernels = kernelSet;
  });
}
