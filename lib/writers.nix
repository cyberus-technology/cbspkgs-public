{ pkgs }:

{
  # This function works like pkgs.writeShellScript but will run
  # `shellcheck` over your script. If `shellcheck` finds any code smells,
  # the derivation will not build.
  writeBashScript = pkgs.writers.makeScriptWriter {
    interpreter = "${pkgs.bash}/bin/bash";
    check = pkgs.writeShellScript "shellcheck.sh" ''
      ${pkgs.shellcheck}/bin/shellcheck --external-sources "$1"
    '';
  };
}
