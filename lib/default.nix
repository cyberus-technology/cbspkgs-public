{ pkgs }:

{
  cartesian = import ./cartesian.nix { inherit pkgs; };
  sotest = import ./sotest.nix { inherit pkgs; };
  writers = import ./writers.nix { inherit pkgs; };

  path = ./.;
}
