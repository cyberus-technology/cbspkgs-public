{ cbsLib, pkgs, initrds, kernels }:

with pkgs.lib;

let
  combinations = cartesianProductOfSets {
    initrd = builtins.attrValues initrds;
    kernel = builtins.attrValues kernels;
  };
  projectConf =
    let
      f = { initrd, kernel }: cbsLib.sotest.linuxBootItem {
        kernel = "${kernel}/bzImage";
        initrd = "${initrd}/initrd";
        name = "Kernel ${kernel.name} initrd ${initrd.name}";
      };
    in
    {
      boot_items = builtins.map f combinations;
    };
in
{
  linux-tests = cbsLib.sotest.mkProjectBundle projectConf;
}
