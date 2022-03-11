{ pkgs }:

with pkgs.lib;

rec {
  # Create an attribute set of a sotest test run with the format specified in
  # https://docs.sotest.io/project_config
  # In order to upload it to a sotest instance, it should be converted to
  # JSON or YAML, see `asJSONFile` and `asYAMLFile`.
  projectConfigJSON =
    { boot_prerequisites ? []
    , extra_dependencies ? []
    , boot_panic_patterns ? []
    , boot_items ? []
    , local_tags_list ? []
    }: builtins.toJSON {
      inherit
        boot_items
        boot_panic_patterns
        boot_prerequisites
        extra_dependencies
        local_tags_list
        ;
    };

  # Create a pretty-printed JSON file from the input
  asJSONFile = jsonContent: pkgs.runCommandNoCC "content.json"
    { nativeBuildInputs = [ pkgs.jq ]; }
    "jq '.' ${pkgs.writeText "content.json" jsonContent} > $out";

  # Create a pretty-printed YAML file from the input
  asYAMLFile = jsonContent: pkgs.runCommandNoCC "content.yaml"
    { nativeBuildInputs = [ pkgs.yq ]; }
    "yq -y '.' ${pkgs.writeText "content.yaml" jsonContent} > $out";

  # Calculate list of direct dependencies of a derivation
  flatReferences = drv: pkgs.stdenv.mkDerivation {
    name = "flat-closure-info";
    __structuredAttrs = true;
    exportReferencesGraph.closure = [ drv ];
    PATH = "${pkgs.jq}/bin";
    builder = builtins.toFile "builder" ''
      . .attrs.sh
      jq -r '.exportReferencesGraph.closure[0] as $x | .closure[] | select(.path == $x) | .references[]' \
        < .attrs.json \
        > ''${outputs[out]}
    '';
  };

  # Generate a ZIP bundle that contains all direct dependencies of a derivation
  # In case any of these deps have runtime deps themselves, this will *not* work!
  zipBundleFromTestrunClosure = drv: pkgs.runCommandNoCC "${drv.name}-bundle.zip" {} ''
    cd /nix/store
    paths=""
    for path in $(cat ${flatReferences drv}); do
      paths="$paths $(basename $path)"
    done
    ${pkgs.zip}/bin/zip -r $out --names-stdin <<< ''${paths// /$'\n'}
  '';

  # Pick a subset of paths from within a derivation and create a new derivation
  # that links to only these paths.
  # This can be used to reduce the size of a derivation if only parts of it are
  # needed.
  pickSubPaths = paths: drv: pkgs.runCommandNoCC "${drv.name}-selection" { inherit paths; } ''
    mkdir $out
    for path in $paths; do
      mkdir -p "$out/$(dirname $path)"
      ln -s "${drv}/$path" "$out/$path"
    done
  '';

  # Given a test run document, generate a derivation that contains both an
  # automatically generated ZIP bundle containing all dependencies as well as
  # the test run document with corrected paths that match the ZIP bundle's
  # content.
  projectBundleFromTestrunClosure = testrunDoc: pkgs.runCommandNoCC "${testrunDoc.name}-sotest-bundle" {} ''
    mkdir $out
    ln -sf ${zipBundleFromTestrunClosure testrunDoc} $out/bundle.zip
    FILE=${testrunDoc}
    sed 's#/nix/store/##g' ${testrunDoc} > $out/project-config.''${FILE##*.}
  '';

  # This is a simple helper function that creates a standard boot item for
  # sotest from a kernel-ramdisk pair
  linuxBootItem =
    { boot_item_timeout ? 300
    , name
    , kernel
    , kernelParams ? [ "console=@{linux_terminal}" ]
    , initrd
    }: {
      inherit boot_item_timeout name;
      exec = builtins.concatStringsSep " " ([ kernel ] ++ kernelParams);
      load = [ initrd ];
    };
}
