{ tup, src }:

# Nixpkgs only includes the latest release of tup, but since 0.7.8
# some details have changed and at least SuperNOVA needs the latest
# development version.
tup.overrideAttrs (oldAttrs: {
  version = "0.7.8-dev";
  inherit src;
})
