pkgs:

{
  initrd,
  timeoutSeconds ? 600
}:
let
  linuxCmd = "console=ttyS0 root=/dev/ram rw";
in pkgs.runCommandNoCC "initrd-tests" {
  nativeBuildInputs = with pkgs; [
    qemu
    expect
  ];

  kernelFile = "${pkgs.linuxPackages_latest.kernel}/bzImage";
  inherit initrd;
  inherit linuxCmd;
  inherit timeoutSeconds;
} ''
  cp ${./qemu-test} qemu-test
  patchShebangs qemu-test

  ./qemu-test | tee output.log
   mkdir -p $out/nix-support
   cp output.log $out/
   echo "report testlog $out output.log" > $out/nix-support/hydra-build-products
  ''

