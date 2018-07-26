{stdenv}:

stdenv.runPhases {
  name = "fail";
  phases = [ "build" "install" ];
  buildPhase = ''
    echo "EPIC FAIL"
    false;
  '';
  installPhase = ''
    echo "SHOULD FAIL" > $out
  '';
  failureHook = ''
    echo "THIS IS WHAT YOU SHOULD SEE AFTER FAILING"
  '';
}
