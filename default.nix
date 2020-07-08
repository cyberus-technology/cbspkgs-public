{ sources ? import ./nix/sources.nix // { cbspkgs-public = ./.; }
, ovl ? import ./nix/cyberus-overlay-function.nix {
    inherit sources;
    overlayRepoList = [ "cbspkgs-public" ];
  }
, pkgs ? import sources.nixpkgs { inherit (ovl) overlays; }
}:

{
  inherit pkgs;
  nixpkgs = sources.nixpkgs;
}
