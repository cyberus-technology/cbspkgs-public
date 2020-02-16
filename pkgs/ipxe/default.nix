{ stdenv, writeText, perl, xz, openssl, src, lib }:
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

  # Enable serial output
  postPatch = ''
    sed -i 's;^//\(#define\s\+CONSOLE_SERIAL\);\1;' src/config/console.h
  '';

  makeFlags = [
    "ECHO_E_BIN_ECHO=echo" "ECHO_E_BIN_ECHO_E=echo" # No /bin/echo here.
    "EMBED=${embedScript}"
    "bin/ipxe.kpxe"
  ];

  preBuild = "cd src";

  enableParallelBuilding = true;

  installPhase = ''
    mkdir -p $out/nix-support
    cp bin/ipxe.kpxe $out/ipxe.kpxe
    chmod 555 $out/ipxe.kpxe
    echo "nix-build out $out" > $out/nix-support/hydra-build-products
    echo "file binary-dist $out/ipxe.kpxe" >> $out/nix-support/hydra-build-products
  '';

  meta = with stdenv.lib; {
    description = "iPXE is the leading open source network boot firmware.";
    homepage = http://ipxe.org;
    license = licenses.gpl2;
  };
}
