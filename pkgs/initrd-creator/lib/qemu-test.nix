pkgs:

{
  initrd,
  timeoutSeconds ? 600
}:
let
  qemuString = pkgs.lib.concatStringsSep " " [
    "-machine q35,accel=kvm"
    "-m 2048"
    "-nographic"
    "-net none"
    "-no-reboot"
    ''-kernel "${pkgs.linuxPackages_latest.kernel}/bzImage"''
    ''-append "console=ttyS0 root=/dev/ram rw"''
  ];
in pkgs.runCommandNoCC "initrd-tests" {
  nativeBuildInputs = with pkgs; [
    qemu
    expect
  ];

  qemuArgs = qemuString + " -initrd ${initrd}";
  inherit timeoutSeconds;
} ''
  cp ${./qemu-test} qemu-test
  patchShebangs qemu-test

  ./qemu-test | tee output.log
   mkdir -p $out/nix-support
   cp output.log $out/
   echo "report testlog $out output.log" > $out/nix-support/hydra-build-products
  ''

