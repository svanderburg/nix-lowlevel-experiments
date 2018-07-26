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

  hello = import ./hello {
    inherit stdenv;
  };

  gnuhello = import ./gnuhello {
    inherit stdenv;
    inherit (pkgsSetupScript) fetchurl;
    inherit (pkgs) gnumake gnutar gzip gcc;
    binutils = pkgs.binutils-unwrapped;
  };
}
