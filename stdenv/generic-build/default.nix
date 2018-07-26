{runPhases, genericBuildPackages}:
{buildInputs ? [], ...}@args:

let
  extraArgs = removeAttrs args [ "buildInputs" ];
in
runPhases ({
  setupGenericBuild = ./setup.sh;
  builder = ./builder.sh;
  buildInputs = genericBuildPackages ++ buildInputs;
} // extraArgs)
