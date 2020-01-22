{ pkgs }:

with pkgs.lib;

let
  kernelConfig = import ./sotestconfig.nix;
  kernels = { inherit (pkgs) linux linux_latest; };
in
  mapAttrs (_: kernel: kernel.override kernelConfig) kernels
