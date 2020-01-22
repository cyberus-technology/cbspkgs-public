# nix initrd builder

## How to build an initrd

```bash
$ nix-build release.nix -A <tab-completion>
boot-hello-initrd                    kernel-compile-initrd-packed-test
boot-hello-initrd-test               kernel-compile-initrd-unpacked
kernel-compile-initrd-packed         kernel-compile-initrd-unpacked-test

$ nix-build release.nix -A boot-hello-initrd

$ ls ./result
closure_sizes.txt  initrd nix-support

$ file result/initrd
result/initrd: gzip compressed data, max compression, from Unix, original size 37034496
```

## How to test an initrd

Just add it to `release.nix` and run one of the targets that are suffixed with
`-test`.

The tests run images in qemu and check for the expected output.

## Files of interest

- `image_defs/`: This folder contains all image definition expressions.
  Always add new images to `image_defs/default.nix` in order to get them
  automatically added to the set of tests.
- `image_defs/boot-initrd.nix`: This nix expression produces an initrd that
  just says hello after booting up.
- `image_defs/kernel-compile-initrd.nix`: This nix expression produces an
  initrd that contains linux kernel source that it compiles at runtime.
- `lib/`: This folder contains nix expressions and scripts that build and test
  images from image definitions in `image_defs/`.
