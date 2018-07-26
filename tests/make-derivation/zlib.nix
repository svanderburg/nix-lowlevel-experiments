{ stdenv, fetchurl }:

stdenv.mkDerivation rec {
  name = "zlib-${version}";
  version = "1.2.11";

  src = fetchurl {
    url = "http://www.zlib.net/fossils/${name}.tar.gz";
    sha256 = "c3e5e9fdd5004dcb542feda5ee4f0ff0744628baf8ed2dd5d66f8ca1197cb1a1";
  };

  configureFlags = "--shared";

  makeFlags = [
    "PREFIX=$out"
  ];

  meta = {
    description = "Lossless data-compression library";
  };
}
