{ cbsLib, pkgs, initrds, kernels }:

with pkgs.lib;

let
  pickOnlyKernel = cbsLib.sotest.pickSubPaths ["bzImage"];
  combinations = cbsLib.cartesian.cartesianProductFromSet {
      initrd = builtins.attrValues initrds;
      kernel = builtins.attrValues kernels;
    };
  projectConf = let
    f = { initrd, kernel }: cbsLib.sotest.linuxBootItem {
      kernel = "${pickOnlyKernel kernel}/bzImage";
      initrd = "${initrd}/initrd";
      name = "Kernel ${kernel.name} initrd ${initrd.name}";
    };
  in cbsLib.sotest.asJSONFile (cbsLib.sotest.projectConfigJSON {
    boot_items = builtins.map f combinations;
  });
in {
  linux-tests = cbsLib.sotest.projectBundleFromTestrunClosure projectConf;
}
