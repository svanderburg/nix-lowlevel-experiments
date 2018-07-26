{ stdenv, fetchurl, bzip2, gnutar, gnumake, gcc, binutils }:

let
  version = "2.12";
  name = "cpio-${version}";
in stdenv.genericBuild {
  inherit name;

  src = fetchurl {
    url = "mirror://gnu/cpio/${name}.tar.bz2";
    sha256 = "0vi9q475h1rki53100zml75vxsykzyhrn70hidy41s5c2rc8r6bh";
  };

  buildInputs = [ bzip2 gnutar gnumake gcc binutils ];

  patches = [
    # Report: http://www.openwall.com/lists/oss-security/2016/01/19/4
    # Patch from https://lists.gnu.org/archive/html/bug-cpio/2016-01/msg00005.html
    ./CVE-2016-2037-out-of-bounds-write.patch
  ];

  buildCommandPhase = ''
    ./configure --prefix=$out
    make
    make install
  '';

  meta = {
    homepage = http://www.gnu.org/software/cpio/;
    description = "A program to create or extract from cpio archives";
    priority = 6; # resolves collision with gnutar's "libexec/rmt"
  };
}
