{ ... }:

{
  nix = {
    binaryCachePublicKeys = [
      "binary-cache.vpn.cyberus-technology.de:qhg25lVqyCT4sDOqxY6GJx8NF3F86eAJFCQjZK/db7Y="
    ];
    trustedBinaryCaches = [ "https://binary-cache.vpn.cyberus-technology.de" ];
    extraOptions = ''
      extra-substituters = https://binary-cache.vpn.cyberus-technology.de
    '';
  };
}
