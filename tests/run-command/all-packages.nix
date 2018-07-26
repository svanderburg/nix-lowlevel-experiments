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
  };

  hello = import ./hello.nix {
    inherit stdenv;
  };

  gcc-wrapper = import ./gcc-wrapper.nix {
    inherit stdenv;
    inherit (pkgs) gcc;
  };

  perl-wrapper = import ./perl-wrapper.nix {
    inherit stdenv;
    inherit (pkgs) perl;
  };

  gnuhello = import ./gnuhello.nix {
    inherit stdenv;
    inherit (pkgsSetupScript) fetchurl;
    inherit (pkgs) gnumake gnutar gzip;
    binutils = pkgs.binutils-unwrapped;
    gcc = gcc-wrapper;
  };

  compress-raw-zlib = import ./compress-raw-zlib.nix {
    inherit stdenv;
    inherit (pkgsSetupScript) fetchurl;
    inherit (pkgs) gnutar gzip gnumake zlib;
    binutils = pkgs.binutils-unwrapped;
    perl = perl-wrapper;
    gcc = gcc-wrapper;
  };
}
