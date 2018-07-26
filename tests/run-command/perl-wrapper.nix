{stdenv, perl}:

stdenv.runCommand {
  name = "perl-wrapper";
  buildCommand = ''
    mkdir -p $out/bin
    for i in ${perl}/bin/*
    do
        ln -s $i $out/bin
    done
  '';
}
