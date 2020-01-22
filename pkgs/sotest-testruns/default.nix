{ cbsLib, pkgs, initrds, kernels }:

with pkgs.lib;
with cbsLib.sotest;

let
  copyInitrds = builtins.concatStringsSep ";" (mapAttrsToList
    (name: path: "cp ${path}/initrd ${name}.initrd")
    initrds);

  # instead of linux and linux_latest use linux-1.2.3
  kernels' = mapAttrs'
    (_: kernelDrv: nameValuePair kernelDrv.name kernelDrv)
    kernels;
  copyKernels = builtins.concatStringsSep ";" (mapAttrsToList
    (name: drv: "cp ${drv}/bzImage ${name}.bzImage")
    kernels);

  kernels'' = mapAttrs (name: _: "${name}.bzImage") kernels';
  initrds' = mapAttrs (name: _: "${name}.initrd") initrds;

  merge = builtins.foldl' (l: r: l // r) {};
  pairs = merge (mapAttrsToList (kernelName: kernel:
      mapAttrs' (initrdName: initrd:
        nameValuePair
          ("Kernel " + kernelName + ", initrd " + initrdName)
          { inherit kernel initrd; }
      ) initrds'
    ) kernels'');
  boot_items = mapAttrsToList
    (name: content: linuxBootItem {
      inherit name;
      inherit (content) kernel initrd;
    })
    pairs;
  projectConfig = projectConfigJSON { inherit boot_items; };
  linux-tests = pkgs.stdenv.mkDerivation {
    name = "sotest-testrun";
    src = ./.;

    nativeBuildInputs = with pkgs; [ zip ];

    installPhase = ''
      ${copyInitrds}
      ${copyKernels}

      mkdir $out
      zip $out/binaries.zip *.initrd *.bzImage
      cp ${asJSONFile projectConfig} $out/projectconfig.json
      cp ${asYAMLFile projectConfig} $out/projectconfig.yaml
    '';
  };
in {
  inherit linux-tests;
}
