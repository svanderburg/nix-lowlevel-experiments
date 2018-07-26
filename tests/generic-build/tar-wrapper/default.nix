{stdenv, gnutar}:

stdenv.runCommand {
  name = "tar-wrapper";
  buildCommand = ''
    mkdir -p $out/bin
    ln -s ${gnutar}/bin/tar $out/bin
  '';
  setupHook = ./setup-hook.sh;
}
