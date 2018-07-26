{stdenv, zlib}:

stdenv.runCommand {
  name = "zlib-wrapper";
  propagatedBuildInputs = [ zlib ];
  buildCommand = ''
    mkdir -p $out/bin
    cat > $out/bin/wrap <<EOF
    #! ${stdenv.shell} -e
    echo "wrap"
    EOF
    chmod +x $out/bin/wrap
  '';
}
