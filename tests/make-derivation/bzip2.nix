{ stdenv, fetchurl }:

stdenv.mkDerivation rec {
  name = "bzip2-${version}";
  version = "1.0.6.0.1";

  /* We use versions patched to use autotools style properly,
      saving lots of trouble. */
  src = fetchurl {
    url = "http://ftp.uni-kl.de/pub/linux/suse/people/sbrabec/bzip2/tarballs/${name}.tar.gz";
    sha256 = "0b5b5p8c7bslc6fslcr1nj9136412v3qcvbg6yxi9argq9g72v8c";
  };

  postPatch = ''
    sed -i -e '/<sys\\stat\.h>/s|\\|/|' bzip2.c
  '';

  outputs = [ "bin" "dev" "out" "man" ];

  meta = {
    homepage = http://www.bzip.org;
    description = "High-quality data compression program";

    platforms = stdenv.lib.platforms.all;
    maintainers = [];
  };
}
