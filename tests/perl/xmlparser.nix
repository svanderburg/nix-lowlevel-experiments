{buildPerlPackage, fetchurl, expat}:

buildPerlPackage {
  name = "XML-Parser-2.41";
  src = fetchurl {
    url = mirror://cpan/authors/id/T/TO/TODDR/XML-Parser-2.41.tar.gz;
    sha256 = "1sadi505g5qmxr36lgcbrcrqh3a5gcdg32b405gnr8k54b6rg0dl";
  };
  buildInputs = [ expat.out expat.dev ];
  dontStrip = true;
}
