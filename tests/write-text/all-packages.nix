{ pkgs ? import <nixpkgs> { inherit system; }
, system ? builtins.currentSystem
}:

let
  pkgsRunCommand = import ../run-command/all-packages.nix {
    inherit pkgs system;
  };
in
rec {
  writeText = import ../../write-text-file {
    inherit (pkgsRunCommand) stdenv;
  };

  textTest = writeText {
    name = "hello";
    text = "Hello world!";
  };
}
