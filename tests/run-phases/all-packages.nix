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

  hello = import ./hello.nix {
    inherit stdenv;
  };

  hello2 = import ./hello2 {
    inherit stdenv;
  };

  fail = import ./fail.nix {
    inherit stdenv;
  };
}
