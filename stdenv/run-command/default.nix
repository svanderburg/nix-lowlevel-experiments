{stdenv, system, shell}:
{builder ? ./builder.sh, ...}@args:

let
  extraArgs = removeAttrs args [ "builder" "meta" ];
in
stdenv.simpleDerivation ({
  inherit builder;
  setupRunCommand = ./setup.sh;
} // extraArgs)
