{ sources ? import ./nix/sources.nix // { cbspkgs-public = ./.; }
, nixpkgs ? sources.nixpkgs
, pkgs ? import nixpkgs { }
}:

import ./nix/cyberus-overlay.nix pkgs pkgs
