{ nix, pkgs, src }:

let
  hydra = import "${src}/release.nix" {
    hydraSrc = src;

    # the targeted hydra version needs a specific nixpkgs snapshot to build, which can't be too new.
    # this is the latest snapshot we can use before it breaks
    nixpkgs = builtins.fetchTarball {
      url = "https://github.com/NixOS/nixpkgs/archive/9fef2ce7cfb1b6b7ea28948878311947f1681b04.tar.gz";
      sha256 = "0qs6vk24ivn75k071jv8rgnswpys27wlfl98dg77dv2vsi56ldlc";
    };
  };
in hydra.build.x86_64-linux.overrideAttrs (old: rec {
  version = "${src.rev}-gitlab-patches";
  name = "hydra-${version}";
  patches = [
    ./hydra_gitlab_auth.patch           # read gitlab auth token from /var/lib/gitlab_auth.key
    ./hydra_gitlab_url_fix.patch        # use ssh instead of http
    ./hydra_gitlab_status_url_fix.patch # hardcode gitlab.vpn.cyberus-technology.de
    ./hydra_no_restrict.patch           # allow builds to access external resources (like nixpkgs)
  ];
  postInstall = ''
    mkdir -p $out/nix-support
    for i in $out/bin/*; do
        read -n 4 chars < $i
        if [[ $chars =~ ELF ]]; then continue; fi
        wrapProgram $i \
            --prefix PERL5LIB ':' $out/libexec/hydra/lib:$PERL5LIB \
            --prefix PATH ':' $out/bin:$hydraPath \
            --set HYDRA_RELEASE ${version} \
            --set HYDRA_HOME $out/libexec/hydra \
            --set NIX_RELEASE ${nix.name or "unknown"}
    done
  '';
})
