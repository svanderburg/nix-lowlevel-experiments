{stdenv, system, shell, __noChroot}@composeArgs:
{builder, __noChroot ? false, ...}@args:

let
  extraArgs = removeAttrs args [ "builder" "__noChroot" "meta" ]; # meta attribute needs to be remove because it cannot be converted to an environment variable

  noChroot = composeArgs.__noChroot
    || args.__noChroot or false;

  buildResult = derivation ({
    inherit system stdenv;
    builder = shell; # Make bash the default builder
    args = [ "-e" builder ]; # Pass builder executable as parameter to bash
    setupSimpleDerivation = ./setup.sh;
    __noChroot = noChroot;
  } // extraArgs);
in
buildResult // (if args ? meta then { inherit (args) meta; } else {}) # Readd the meta attribute to the resulting attribute set
