{stdenv}:

stdenv.runPhases {
  name = "hello";
  phases = [ "build" "install" ];
  buildPhase = ''
    cat > hello <<EOF
    #! ${stdenv.shell} -e
    echo "Hello"
    EOF
    chmod +x hello
  '';
  installPhase = ''
    mkdir -p $out/bin
    mv hello $out/bin
  '';
}
