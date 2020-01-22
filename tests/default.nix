{
  nixpkgs
}:
{
  hydra = import ./hydra.nix { inherit nixpkgs; };
}
