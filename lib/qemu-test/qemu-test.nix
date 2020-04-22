{ pkgs }:

{ initrd, timeoutSeconds ? 600 }:
let
  linuxCmd = "console=ttyS0 root=/dev/ram rw";
  qemuArguments = pkgs.lib.concatStringsSep " " [
    "-machine q35,accel=kvm"
    "-m 4096"
    "-nographic"
    "-net none"
    "-no-reboot"
  ];
in pkgs.runCommandNoCC "initrd-tests" {
  nativeBuildInputs = with pkgs; [ qemu expect ];

  kernelFile = "${pkgs.linuxPackages_latest.kernel}/bzImage";
  inherit initrd;
  inherit linuxCmd;
  inherit timeoutSeconds;
  inherit qemuArguments;
} ''
  cp ${./qemu-test} qemu-test
  patchShebangs qemu-test

  ./qemu-test | tee output.log
   mkdir -p $out/nix-support
   cp output.log $out/
   echo "report testlog $out output.log" > $out/nix-support/hydra-build-products
''

