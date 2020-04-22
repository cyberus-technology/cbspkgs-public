{ pkgs, cbsLib }:

with pkgs.lib;

let
  initrds = import ./image_defs { inherit pkgs cbsLib; };
  transformToTest = initrdName: initrdDrv: nameValuePair
    ("${initrdName}-test")
    (cbsLib.makeInitrdQemuTest { initrd = "${initrdDrv}/initrd"; inherit (initrdDrv) timeoutSeconds; });
in {
  inherit initrds;
  tests = mapAttrs' transformToTest initrds;
}
