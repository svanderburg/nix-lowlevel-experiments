source $setupSimpleDerivation

export PATH=$PATH:$gnumake/bin:$gnutar/bin:$gzip/bin:$gcc/bin:$binutils/bin

tar xfv $src
cd hello-*
./configure --prefix=$out
make
make install
