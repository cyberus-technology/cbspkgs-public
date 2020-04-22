{ pkgs }:

{
  cartesian = import ./cartesian.nix { inherit pkgs; };
  sotest = import ./sotest.nix { inherit pkgs; };
  writers = import ./writers.nix { inherit pkgs; };
  makeInitrd = import ./patched-make-initrd.nix { inherit pkgs; };
  makeInitrdQemuTest = import ./qemu-test/qemu-test.nix { inherit pkgs; };

  path = ./.;
}
