{stdenv, fetchurl, gnumake, gnutar, gzip, gcc, binutils}:

stdenv.genericBuild {
  name = "hello-2.10";
  src = fetchurl {
    url = mirror://gnu/hello/hello-2.10.tar.gz;
    sha256 = "0ssi1wpaf7plaswqqjwigppsg5fyh99vdlb9kzl7c9lng89ndq1i";
  };
  buildInputs = [ gnumake gnutar gzip gcc binutils ];
  buildCommandPhase = ''
    ./configure --prefix=$out
    make
    make install
  '';
}
