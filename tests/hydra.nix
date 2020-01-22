{
  nixpkgs
}:
let
  cbspkgs = import ../default.nix {};
  testFunction = { pkgs, ... }:
    {
      name = "hydra-module-test";

      nodes = {
        hydra = { pkgs, lib, ... }: {
          virtualisation.memorySize = 1024;

          imports = [
            cbspkgs.modules.hydra
          ];

          services = {
            hydra-dev = {
              hydraURL = "localhost:3000";
              notificationSender = "dummy";
              enable = true;
              package = cbspkgs.hydra;
              port = 3000;
            };
          };
        };
      };

      testScript = ''
        hydra.start()
        hydra.wait_for_unit("hydra-server.service")
        hydra.wait_for_open_port(3000)
        hydra.succeed("curl --fail --connect-timeout 5 http://localhost:3000")
      '';
    };
in import (nixpkgs + "/nixos/tests/make-test-python.nix") testFunction
