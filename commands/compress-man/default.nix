{stdenv}:

stdenv.runCommand {
  name = "compress-man";
  buildCommand = ''
    mkdir -p $out/bin
    sed -e "s|/bin/bash|$SHELL|" ${./compress-man.sh} > $out/bin/compress-man
    chmod +x $out/bin/compress-man
  '';
}
