# Print full dmidecode output

{
  cbsLib,
  coreutils,
  dmidecode,
  pkgs
}:

import ../lib/patched-make-initrd.nix { inherit pkgs; } {
  pathPkgs = [ coreutils dmidecode ];

  initScript = cbsLib.writers.writeBashScript "myInitScript" ''
    set -euo pipefail
    echo "Hello! Running $(uname -a)"

    echo SOTEST VERSION 1 BEGIN 1
    dmidecode && echo SOTEST SUCCESS || echo SOTEST FAIL

    echo SOTEST END
  '';
}
