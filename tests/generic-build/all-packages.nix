{ pkgs ? import <nixpkgs> { inherit system; }
, system ? builtins.currentSystem
}:

let
  pkgsSetupScript = import ../setup-script/all-packages.nix {
    inherit pkgs system;
  };
in
rec {
  stdenv = import ../../stdenv {
    inherit system;
    inherit (pkgs) bash;

    basePackages = [
      pkgs.coreutils
      pkgs.findutils
      pkgs.diffutils
      pkgs.gnused
      pkgs.gnugrep
      pkgs.gawk
      pkgs.bash
    ];

    genericBuildPackages = [
      pkgs.patch
      compress-man
      patch-shebangs
    ];
  };

  compress-man = import ../../commands/compress-man {
    inherit (pkgsSetupScript) stdenv;
  };

  patch-shebangs = import ../../commands/patch-shebangs {
    inherit (pkgsSetupScript) stdenv;
  };

  tar-wrapper = import ./tar-wrapper {
    inherit stdenv;
    inherit (pkgs) gnutar;
  };

  gzip-wrapper = import ./gzip-wrapper {
    inherit stdenv;
    inherit (pkgs) gzip;
  };

  bzip2-wrapper = import ./bzip2-wrapper {
    inherit stdenv;
    inherit (pkgs) bzip2;
  };

  gcc-wrapper = import ./gcc-wrapper.nix {
    inherit stdenv;
    inherit (pkgs) gcc;
  };

  gnuhello = import ./gnuhello.nix {
    inherit stdenv;
    inherit (pkgsSetupScript) fetchurl;
    inherit (pkgs) gnumake;
    binutils = pkgs.binutils-unwrapped;
    gcc = gcc-wrapper;
    gnutar = tar-wrapper;
    gzip = gzip-wrapper;
  };

  cpio = import ./cpio.nix {
    inherit stdenv;
    inherit (pkgsSetupScript) fetchurl;
    inherit (pkgs) gnumake;
    gcc = gcc-wrapper;
    binutils = pkgs.binutils-unwrapped;
    gnutar = tar-wrapper;
    bzip2 = bzip2-wrapper;
  };

  hello = import ./hello.nix {
    inherit stdenv;
  };
}
