# Print full dmidecode output

{
  cbsLib,
  coreutils,
  dmidecode,
  pkgs
}:

cbsLib.makeInitrd {
  pathPkgs = [ coreutils dmidecode ];

  initScript = cbsLib.writers.writeBashScript "myInitScript" ''
    set -euo pipefail
    echo "Hello! Running $(uname -a)"

    echo SOTEST VERSION 1 BEGIN 1
    dmidecode && echo SOTEST SUCCESS || echo SOTEST FAIL

    echo SOTEST END
  '';
}
