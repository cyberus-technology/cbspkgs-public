{
  niv ? import nix/sources.nix,
  pkgs ? import niv.nixpkgs { config = { allowUnfree = true; }; }
}:
let
  cbsLib = import ./lib { inherit pkgs; };
  cbspkgs = import ./pkgs { inherit niv pkgs cbsLib; };
  cbsModules = import ./modules { inherit niv cbspkgs pkgs; };
in cbspkgs //
  {
    lib = cbsLib;
    nixpkgs = pkgs;
    modules = cbsModules;
  }
