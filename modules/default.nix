{
  cyberus = {
    certificateAuthority = import ./cyberus-ca.nix;
    binaryCache = import ./cyberus-binary-cache.nix;
  };
}
