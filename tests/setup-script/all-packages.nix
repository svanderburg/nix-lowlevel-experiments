{ pkgs ? import <nixpkgs> { inherit system; }
, system ? builtins.currentSystem
}:

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

  fetchurl = import ./fetchurl.nix;

  hello = import ./hello {
    inherit stdenv;
  };

  gnuhello = import ./gnuhello {
    inherit stdenv fetchurl;
    inherit (pkgs) gnumake gnutar gzip gcc;
    binutils = pkgs.binutils-unwrapped;
  };
}
