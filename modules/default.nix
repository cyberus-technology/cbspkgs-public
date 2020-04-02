{ niv }:
{
  hydra = import "${niv.hydra}/hydra-module.nix";

  cyberus = {
    certificateAuthority = import ./cyberus-ca.nix;
    binaryCache = import ./cyberus-binary-cache.nix;
  };
}
