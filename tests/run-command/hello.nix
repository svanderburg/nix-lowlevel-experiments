{stdenv}:

stdenv.runCommand {
  name = "hello";
  buildCommand = ''
    mkdir -p $out/bin
    cat > $out/bin/hello <<EOF
    #! ${stdenv.shell} -e

    echo "Test"
    EOF
    chmod +x $out/bin/hello
  '';
}
