{
  efi ? false,
  legacy ? true,
  lib,
  openssl,
  perl,
  src,
  stdenv,
  writeText,
  xz
}:

let
  embedScript = writeText "embed.ipxe" ''
    #!ipxe
    dhcp
    chain tftp://''${next-server}/ipxe-''${net0/mac:hexhyp}.cfg || chain tftp://''${next-server}/ipxe-default.cfg || shell
  '';
  version = with lib; let
      makefile = strings.fileContents (src + "/src/Makefile");
      makefileLines = splitString "\n" makefile;
      versionLines = builtins.filter (strings.hasPrefix "VERSION_") makefileLines;
      versionNumbers = builtins.map (line:
        builtins.elemAt (splitString "= " line) 1
      ) versionLines;
    in builtins.concatStringsSep "." versionNumbers;
in stdenv.mkDerivation rec {
  pname = "cyberus-ipxe";
  inherit src version;

  buildInputs = [ perl xz openssl ];
  hardeningDisable = [ "pic" "stackprotector" ];

  NIX_CFLAGS_COMPILE = "-Wno-error"; # project is no warning-free build

  makeFlags = [
    "ECHO_E_BIN_ECHO=echo" "ECHO_E_BIN_ECHO_E=echo" # No /bin/echo here.
    "EMBED=${embedScript}"
  ] ++ lib.optional (legacy) "bin/ipxe.kpxe"
    ++ lib.optional (efi) "bin-x86_64-efi/ipxe.efi";

  preBuild = "cd src";

  enableParallelBuilding = true;

  installPhase = ''
    mkdir -p $out/nix-support
    echo "nix-build out $out" > $out/nix-support/hydra-build-products

    ${lib.optionalString (legacy) ''
      cp bin/ipxe.kpxe $out/ipxe.kpxe
      chmod 555 $out/ipxe.kpxe
      echo "file binary-dist $out/ipxe.kpxe" >> $out/nix-support/hydra-build-products
    ''}

    ${lib.optionalString (efi) ''
      cp bin-x86_64-efi/ipxe.efi $out/ipxe.efi
      chmod 555 $out/ipxe.efi
      echo "file binary-dist $out/ipxe.efi" >> $out/nix-support/hydra-build-products
    ''}
  '';

  meta = with stdenv.lib; {
    description = "iPXE is the leading open source network boot firmware.";
    homepage = http://ipxe.org;
    license = licenses.gpl2;
  };
}

