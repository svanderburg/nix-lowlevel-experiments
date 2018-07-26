{stdenv}:

stdenv.genericBuild {
  name = "hello";
  dontUnpack = true;
  buildCommandPhase = ''
    mkdir -p $out/bin
    cat > $out/bin/hello <<EOF
    #!/bin/bash -e
    echo "Hello world!"
    EOF
    chmod +x $out/bin/hello
  '';
}
