{ stdenv, gnutar, nix-gitignore }:

stdenv.mkDerivation rec {
  name = "cbspkgs-tarball";

  src = nix-gitignore.gitignoreSourcePure [ (builtins.readFile ../../.gitignore) ".git" ".gitignore" ] ../../.;

  buildInputs = [ gnutar ];

  installPhase = ''
    mkdir -p $out/nix-support

    tar -czf $out/cbspkgs.tar.gz -C .. $(basename $PWD)

    echo "channel cbspkgs $out/cbspkgs.tar.gz" > $out/nix-support/hydra-build-products
  '';
}
