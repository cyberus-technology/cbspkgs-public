# The original makeInitrd function from
# <nixpkgs/pkgs/build-support/kernel/make-initrd.nix>
# does not use pkgs.closureInfo because this does not work for nix versions 1.x
# --> We don't have this constraint and i did not get how to use makeInitrd
# easily, so let's patch closureInfo in.

{ pkgs }:

{ initScript, additionalContents ? [], name ? "initrd", pathPkgs ? [], prepend ? [] }:

let
  fileSizeList = pkgs.writeText "stats.sh" ''
    for path in $(cat $storePathFile); do
      echo $(du -sm $path) >> closure_sizes.txt
    done
    sort -n closure_sizes.txt > $out/closure_sizes.txt
  '';

  hydraSupport = pkgs.writeText "hydra.sh" ''
    mkdir -p $out/nix-support
    echo "file initrd $out/initrd" > $out/nix-support/hydra-build-products
    echo "report unpacked_content_size_contributions $out closure_sizes.txt" >> $out/nix-support/hydra-build-products
  '';

  patchStorePath = script: pkgs.runCommand "builder.sh" {} ''
    sed 's/^storePaths=.*$/storePaths=$(cat $storePathFile)/' ${script} > $out
    cat ${fileSizeList} >> $out
    cat ${hydraSupport} >> $out
  '';

  pathsFromGraph = rootPaths: pkgs.closureInfo { inherit rootPaths; };

  f = x: (pkgs.makeInitrd x).overrideAttrs (old: {
    builder = patchStorePath old.builder;
    storePathFile = "${pathsFromGraph old.objects}/store-paths";
  });

  initScriptFrame = pkgs.writeScript "init" ''
    #!${pkgs.busybox}/bin/sh
    ${pkgs.busybox}/bin/mount -t devtmpfs none /dev
    ${pkgs.busybox}/bin/mount -t proc none /proc
    ${pkgs.busybox}/bin/mount -t sysfs none /sys

    # Let Linux calibrate its TSC without interfering with script output
    ${pkgs.busybox}/bin/sleep 1

    export PATH=${pkgs.lib.makeBinPath pathPkgs}

    ${initScript}

    # Avoid ugly kernel panic.
    while true; do ${pkgs.busybox}/bin/sleep 3600; done
  '';

  initScriptContent = [ {
    object = initScriptFrame;
    symlink = "/init";
  } ];
in (f { inherit name prepend; contents = initScriptContent ++ additionalContents; }) // { timeoutSeconds = 60; }
