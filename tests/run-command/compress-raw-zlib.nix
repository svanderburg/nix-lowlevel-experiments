{stdenv, fetchurl, perl, gnutar, gzip, gnumake, gcc, binutils, zlib}:

stdenv.runCommand rec {
  name = "Compress-Raw-Zlib-2.074";

  src = fetchurl {
    url = "mirror://cpan/authors/id/P/PM/PMQS/${name}.tar.gz";
    sha256 = "08bpx9v6i40n54rdcj6invlj294z20amrl8wvwf9b83aldwdwsd3";
  };

  buildInputs = [ perl gnutar gzip gnumake gcc binutils ];

  buildCommand = ''
    tar xfv $src
    cd Compress-*

    cat > config.in <<EOF
      BUILD_ZLIB   = False
      INCLUDE      = ${zlib.dev}/include
      LIB          = ${zlib.out}/lib
      OLD_ZLIB     = False
      GZIP_OS_CODE = AUTO_DETECT
    EOF

    perl Makefile.PL PREFIX=$out
    make
    make install
  '';
}
