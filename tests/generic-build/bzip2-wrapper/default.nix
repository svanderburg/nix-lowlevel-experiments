{stdenv, bzip2}:

stdenv.runCommand {
  name = "bzip2-wrapper";
  buildCommand = ''
    mkdir -p $out/bin
    ln -s ${bzip2}/bin/bzip2 $out/bin
  '';
  setupHook = ./setup-hook.sh;
}
