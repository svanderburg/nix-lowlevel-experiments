{genericBuild, buildPackages}:
{buildInputs ? [], ...}@args:

let
  extraArgs = removeAttrs args [ "buildInputs" ];
in
genericBuild ({
  setupMakeDerivation = ./setup.sh;
  builder = ./builder.sh;
  buildInputs = buildPackages ++ buildInputs;
} // extraArgs)
