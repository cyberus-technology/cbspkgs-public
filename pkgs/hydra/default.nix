{ nix, pkgs, src }:

let
  hydra = import "${src}/release.nix" {
    hydraSrc = src;

    # hydra is broken with nixpkgs-unstable, so we temporarily use the default channel defined by
    # hydra itself, which right now points to nixos-19.09-small
    # nixpkgs = pkgs.path;
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
