{stdenv, perl}:

stdenv.mkDerivation {
  name = "perl-wrapper";
  buildCommand = ''
    mkdir -p $out/bin
    cd $out/bin

    for i in ${perl}/bin/*
    do
        ln -s $i
    done
  '';
  setupHook = ./setup-hook.sh;
}
