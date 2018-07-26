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

    buildPackages = [
      tar-wrapper # pkgs.gnutar
      pkgs.gzip
      pkgs.bzip2
      pkgs.xz
      pkgs.gnumake
      pkgs.binutils-unwrapped
      gcc-wrapper
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

  gnuhello = import ./gnuhello.nix {
    inherit stdenv;
    inherit (pkgsSetupScript) fetchurl;
  };

  bzip2 = import ./bzip2.nix {
    inherit stdenv;
    inherit (pkgsSetupScript) fetchurl;
  };

  gcc-wrapper = import ./gcc-wrapper {
    inherit stdenv;
    inherit (pkgs) gcc;
  };

  zlib = import ./zlib.nix {
    inherit stdenv;
    inherit (pkgsSetupScript) fetchurl;
  };

  zlib-wrapper = import ./zlib-wrapper.nix {
    inherit stdenv zlib;
  };

  file = import ./file.nix {
    inherit stdenv;
    zlib = zlib-wrapper;
    inherit (pkgsSetupScript) fetchurl;
  };
}
