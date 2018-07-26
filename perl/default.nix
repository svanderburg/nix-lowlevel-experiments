{stdenv, perl}:
{name, buildInputs ? [], ...}@args:

let
  extraArgs = removeAttrs args [ "name" "buildInputs" ];
in
stdenv.mkDerivation ({
  name = "perl-${name}";
  buildInputs = [ perl ] ++ buildInputs;
  builder = ./builder.sh;
  setupPerl = ./setup-perl.sh;
} // extraArgs)
