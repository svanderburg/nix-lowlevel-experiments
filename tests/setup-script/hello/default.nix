{stdenv}:

derivation {
  name = "hello";
  inherit stdenv;
  builder = ./builder.sh;
  system = builtins.currentSystem;
}
