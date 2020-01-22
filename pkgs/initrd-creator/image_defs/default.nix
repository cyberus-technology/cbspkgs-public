{
  pkgs,
  cbsLib
}:

{
  dmidecode = pkgs.callPackage ./dmidecode.nix { inherit cbsLib; };
  kernel-compile = pkgs.callPackage ./kernel-compile-initrd.nix { inherit cbsLib; };
}
