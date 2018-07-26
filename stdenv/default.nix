{bash, basePackages, genericBuildPackages ? [], buildPackages ? [], system, __noChroot ? false}:

let
  shell = "${bash}/bin/sh";

  # Layer 1: stdenv package + basic configuration properties + setup script
  stdenvProperties = derivation {
    name = "stdenv";
    inherit shell basePackages system __noChroot;
    builder = shell;
    args = [ "-e" ./builder.sh ];
  };

  stdenv = stdenvProperties // {
    # Layer 2: extra environment variables for purity, bash as builder, system set
    simpleDerivation = import ./simple-derivation {
      inherit stdenv __noChroot;
      inherit (stdenv) system shell;
    };

    # Layer 3: run commands as string parameter + buildInputs and propagated buildInputs
    runCommand = import ./run-command {
      inherit stdenv;
      inherit (stdenv) system shell;
    };

    # Layer 4: run phases with pre and post hooks + exit hook and failure hook
    runPhases = import ./run-phases {
      inherit (stdenv) runCommand;
    };

    # Layer 5: unpack, patch, build command, strip, patch shebang
    genericBuild = import ./generic-build {
      inherit (stdenv) runPhases;
      inherit genericBuildPackages;
    };

    # Layer 6: GNU Autotools/GNU Make support
    mkDerivation = import ./make-derivation {
      inherit (stdenv) genericBuild;
      inherit buildPackages;
    };
  };
in
stdenv
