{stdenv, gcc}:

stdenv.runCommand {
  name = "gcc-wrapper";
  buildCommand = ''
    mkdir -p $out/bin
    for i in ${gcc}/bin/*
    do
        ln -s $i $out/bin
    done
  '';
  setupHook = ./setup-hook.sh;
}
