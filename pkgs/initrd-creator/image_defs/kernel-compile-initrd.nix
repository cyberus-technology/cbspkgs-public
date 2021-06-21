# unpackKernelIntoImage selects if we put the packed tarball ramdisk or if we
# unpack it into it so the guest image

{
  bash,
  bc,
  binutils,
  bison,
  cbsLib,
  coreutils,
  diffutils,
  elfutils,
  fetchurl,
  findutils,
  flex,
  gawk,
  gcc,
  gnugrep,
  gnumake,
  gnused,
  gnutar,
  gzip,
  lib,
  libelf,
  linux,
  nettools,
  openssl,
  perl,
  pkgs,
  runCommand,
  time,
  writeShellScript,
  xz
}:

let
  hostLibPackages = [ elfutils libelf openssl ];

  joinStrings = f: l: builtins.concatStringsSep ":" (map f l);
  includeFlags = joinStrings (x: "${lib.getDev x}/include") hostLibPackages;
  linkFlags = joinStrings (x: "${lib.getLib x}/lib") hostLibPackages;
in (cbsLib.makeInitrd {
  pathPkgs = [
    bc
    binutils
    binutils.bintools
    bison
    coreutils
    diffutils
    findutils
    flex
    gawk
    gcc
    gnugrep
    gnumake
    gnused
    gnutar
    gzip
    nettools
    perl
    time
    xz
  ];
  initScript = cbsLib.writers.writeBashScript "myInitScript" ''
    set -eu

    export PATH=$PATH:/bin

    # Most shellscripts in the kernel source code need this
    mkdir /bin
    ln -sf ${bash}/bin/bash /bin/sh

    # linux kernel repo's scripts/ld-version.sh needs this
    mkdir -p /usr/bin
    ln -sf ${gawk}/bin/awk /usr/bin/awk

    # At some point the kernel's build system will want to create files here
    mkdir /tmp

    # `whoami` will not work without this
    mkdir /etc
    echo "root:x:0:0:root:/root:/bin/sh" > /etc/passwd

    echo "Hello! Running $(uname -a)"

    echo "Unpacking kernel tarball ($(du -sh "$(readlink /kernel.tar.xz)"))"
    tar xf /kernel.tar.xz
    cd linux*

    export C_INCLUDE_PATH="${includeFlags}"
    export LIBRARY_PATH="${linkFlags}"

    echo "SOTEST VERSION 1 BEGIN 1"

    echo SOTEST TIMEOUT 18000

    cp ${./kernel_config} .config

    echo "Configuring kernel..."
    make olddefconfig

    echo "Building kernel with $(nproc) cores..."
    START="$(date '+%s')"
    if make -j"$(nproc)"; then
       END="$(date '+%s')"
       echo "SOTEST BENCHMARK:kernel_compile:seconds:$((END - START))"
       echo "SOTEST SUCCESS"
    else
       echo "SOTEST FAIL"
    fi

    echo "SOTEST END"
  '';

  additionalContents = [
    {
      object = linux.src;
      symlink = "/kernel.tar.xz";
    }
  ];
}) // { timeoutSeconds = 5 * 60 * 60; }
