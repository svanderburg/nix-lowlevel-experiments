{stdenv}:

stdenv.runCommand {
  name = "patch-shebangs";
  buildCommand = ''
    mkdir -p $out/bin
    sed -e "s|/bin/bash|$SHELL|" ${./patch-shebangs.sh} > $out/bin/patch-shebangs
    chmod +x $out/bin/patch-shebangs
  '';
}
