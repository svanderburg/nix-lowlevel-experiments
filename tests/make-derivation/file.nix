{ stdenv, fetchurl, zlib }:

stdenv.mkDerivation rec {
  name = "file-${version}";
  version = "5.32";

  src = fetchurl {
    url = "https://distfiles.macports.org/file/${name}.tar.gz";
    sha256 = "0l1bfa0icng9vdwya00ff48fhvjazi5610ylbhl35qi13d6xqfc6";
  };

  buildInputs = [ zlib ];

  meta = {
    homepage = http://darwinsys.com/file;
    description = "A program that shows the type of files";
  };
}
