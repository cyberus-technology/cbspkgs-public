{ pkgs, cbsLib }:

with pkgs.lib;

let
  initrds = import ./image_defs { inherit pkgs cbsLib; };
  initrdTest = import ./lib/qemu-test.nix pkgs;
  transformToTest = initrdName: initrdDrv: nameValuePair
    ("${initrdName}-test")
    (initrdTest { initrd = "${initrdDrv}/initrd"; inherit (initrdDrv) timeoutSeconds; });
in {
  inherit initrds;
  tests = mapAttrs' transformToTest initrds;
}
