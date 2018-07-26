{stdenv, gzip}:

stdenv.runCommand {
  name = "gzip-wrapper";
  buildCommand = ''
    mkdir -p $out/bin
    ln -s ${gzip}/bin/gzip $out/bin
    ln -s ${gzip}/bin/gunzip $out/bin
  '';
  setupHook = ./setup-hook.sh;
}
