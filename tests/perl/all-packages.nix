{ pkgs ? import <nixpkgs> { inherit system; }
, system ? builtins.currentSystem
}:

let
  pkgsSetupScript = import ../setup-script/all-packages.nix {
    inherit pkgs system;
  };

  pkgsMkDerivation = import ../make-derivation/all-packages.nix {
    inherit pkgs system;
  };
in
rec {
  perl-wrapper = import ./perl-wrapper {
    inherit (pkgsMkDerivation) stdenv;
    inherit (pkgs) perl;
  };

  buildPerlPackage = import ../../perl/default.nix {
    inherit (pkgsMkDerivation) stdenv;
    perl = perl-wrapper;
  };

  xmlparser = import ./xmlparser.nix {
    inherit buildPerlPackage;
    inherit (pkgsSetupScript) fetchurl;
    inherit (pkgs) expat;
  };
}
