{ sources ? import ./nix/sources.nix // { cbspkgs-public = ./.; }
, nixpkgs ? sources.nixpkgs
, ovl ? import ./nix/cyberus-overlay-function.nix {
    inherit sources;
    overlayRepoList = [ "cbspkgs-public" ];
  }
, pkgs ? import nixpkgs { inherit (ovl) overlays; }
}:

{
  inherit pkgs;
  nixpkgs = sources.nixpkgs;
}
