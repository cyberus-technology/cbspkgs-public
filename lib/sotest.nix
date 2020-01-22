{ pkgs }:

with pkgs.lib;

rec {
  projectConfigJSON = {
      boot_prerequisites ? [],
      extra_dependencies ? [],
      boot_panic_patterns ? [],
      boot_items ? []
    }: builtins.toJSON {
      inherit
        boot_items
        boot_panic_patterns
        boot_prerequisites
        extra_dependencies;
    };
  asJSONFile = jsonContent: pkgs.runCommandNoCC "content.json"
    { nativeBuildInputs = [ pkgs.jq ]; }
    "jq '.' ${pkgs.writeText "content.json" jsonContent} > $out";
  asYAMLFile = jsonContent: pkgs.runCommandNoCC "content.yaml"
    { nativeBuildInputs = [ pkgs.yq ]; }
    "yq -y '.' ${pkgs.writeText "content.yaml" jsonContent} > $out";
  linuxBootItem = {
      boot_item_timeout ? 300,
      name,
      kernel,
      kernelParams ? [ "console=@{linux_terminal}" ],
      initrd
    }: {
      inherit boot_item_timeout name;
      exec = builtins.concatStringsSep " " ([ kernel ] ++ kernelParams);
      load = [ initrd ];
    };
}
