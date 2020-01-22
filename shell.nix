{
  niv ? import nix/sources.nix,
  pkgs ? import niv.nixpkgs { config = { allowUnfree = true; }; }
}:
pkgs.mkShell {
  nativeBuildInputs = [ pkgs.niv ];
}
