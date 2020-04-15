# You can use this file as a nixpkgs overlay. This is useful in the
# case where you don't want to add the whole cbspkgs namespace to your
# configuration.

self: super:

{
  cbspkgs = import ./default.nix { pkgs = super; };
}
