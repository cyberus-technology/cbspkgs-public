pkgs:

{
  initrd,
  timeoutSeconds ? 600
}:

pkgs.stdenv.mkDerivation {
  name = "initrd-test";
  src = ./.;

  nativeBuildInputs = with pkgs; [
    qemu
    expect
  ];

  kernelFile = "${pkgs.linuxPackages_latest.kernel}/bzImage";
  initrdFile = initrd;
  inherit timeoutSeconds;

  postPatch = ''
    patchShebangs ./qemu-test
  '';


  buildPhase = ''
    ./qemu-test | tee output.log
  '';

  installPhase = ''
    mkdir -p $out/nix-support
    cp output.log $out/
    echo "report testlog $out output.log" > $out/nix-support/hydra-build-products
  '';
}
