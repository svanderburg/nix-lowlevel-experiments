nix-lowlevel-experiments
========================
This repository contains a collection of low level Nix experiments in which
various concepts of the [Nix package manager](http://nixos.org/nix) and the
[NixOS](http://nixos.org/nix) Linux distribution are explored, as well as other
related low-level system concepts.

Currently, it only contains an implementation of the generic builder
infrastructure that is similar to the version in Nixpkgs, but built in a
different way.

Prerequisites
=============
* [The Nix package manager](http://nixos.org/nix)
* [Nixpkgs](http://nixos.org/nixpkgs)

The generic builder
===================
This repository contains a generic builder implementation that consists of
various abstraction layers -- it starts with a setup script that can be provided
as a dependency to a raw `derivation {}` invocation and ends with a function
abstraction that is comparable in features to the `stdenv.mkDerivation` function
in Nixpkgs.

Layer 1: setup script
---------------------
Layer 1 is a simple setup script that can be used in a "raw" derivation to add
some basic dependencies to the build environment so that basic shell tasks can
be executed:

```nix
{stdenv}:

derivation {
  name = "hello";
  inherit stdenv;
  builder = ./builder.sh;
  system = "x86_64-linux";
}
```

By adding stdenv as a parameter, we can execute the following builder script:

```bash
#!/bin/sh -e
source $stdenv/setup

mkdir -p $out/bin

cat > $out/bin/hello <<EOF
#!$SHELL -e

echo "Hello"
EOF

chmod +x $out/bin/hello
```

The above script imports the `setup` script and, as a result, can invoke external
shell commands, such as `mkdir`, `cat`, and `chmod` to generate a script
executable.

We can also install `stdenv` as a Nix package. When installing `stdenv`as a
package, it will install all basic UNIX utilities in the Nix profile of the
caller:

``bash
$ nix-env -f all-packages.nix -iA stdenv
``

Layer 2: simple derivation
--------------------------
The `stdenv.simpleDerivation` abstraction provides a default setting for the
`system` parameter and uses `bash` in the Nix store as a builder (that is
pure, unlike `/bin/sh` that can refer to any version).

We can build the same wrapper script (shown previously) by evaluating the
following Nix expression:

```nix
{stdenv}:

stdenv.simpleDerivation {
  name = "hello";
  builder = ./builder.sh;
  meta = {
    description = "This is a simple testcase";
  };
}
```

Layer 3: The run command abstraction
------------------------------------
The `stdenv.runCommand` abstraction extends the previous function abstraction
and allows build instructions to be specified through the `buildCommand`
(a string) parameter so that no separate builder script is needed.

It also supports a generic build input mechanism making it possible to configure
dependencies in a generic way. Every package can provide a setup hook that tells
the builder how a dependency can be configured.

For example, when packages with a `bin/` sub folder are provided as a build
input, the `PATH` environment variable will automatically configured.

When `perl` has been added as a build input (that includes a Perl-specific setup
hook) and a Perl module is provided as a build input, the `PERL5LIB` environment
variable will be configured.

We can use the `stdenv.runCommand` abstraction to build GNU Hello as follows:

```nix
{stdenv, fetchurl, gnumake, gnutar, gzip, gcc, binutils}:

stdenv.runCommand {
  name = "hello-2.10";
  src = fetchurl {
    url = mirror://gnu/hello/hello-2.10.tar.gz;
    sha256 = "0ssi1wpaf7plaswqqjwigppsg5fyh99vdlb9kzl7c9lng89ndq1i";
  };
  buildInputs = [ gnumake gnutar gzip gcc binutils ];
  buildCommand = ''
    tar xfv $src
    cd hello-2.10
    ./configure --prefix=$out
    make
    make install
  '';
}
```

This abstraction also supports `propagatedBuildInputs` that can be used to
automatically propagate transitive dependencies.

Layer 4: The run phases abstraction
-----------------------------------
The `stdenv.runPhases` abstraction extends the previous abstraction function
with the ability to run phases in a specified order, for example:

```nix
{stdenv}:

stdenv.runPhases {
  name = "hello";
  phases = [ "build" "install" ];
  buildPhase = ''
    cat > hello <<EOF
    #! ${stdenv.shell} -e
    echo "Hello"
    EOF
    chmod +x hello
  '';
  installPhase = ''
    mkdir -p $out/bin
    mv hello $out/bin
  '';
}
```

The above Nix expression executes a `build` and an install `phase`. The build
phase constructs a shell executable, and the `install` phase installs it into
the Nix store and makes it executable.

It is also possible to define phases in a builder script:

```nix
{stdenv}:

stdenv.runPhases {
  name = "hello2";
  builder = ./builder.sh;
}
```

In the builder script, we can include the setup script for the run phases
environment and then define our phases and implementations there:

```bash
source $setupRunPhases

phases="build install"

buildPhase()
{
    cat &gt; hello &lt;&lt;EOF
#! $SHELL -e
echo "Hello"
EOF
    chmod +x hello
}

installPhase()
{
    mkdir -p $out/bin
    mv hello $out/bin
}

genericBuild
```

Layer 5: The generic build abstraction
--------------------------------------
The `stdenv.genericBuild` abstraction adds implementations for common build
steps, such as a `unpack` phase that generically unpacks sources, a
`patchShebangs` phase that fixes all shebang lines to correspond to Nix store
paths, and a `strip` phase that strips debugging symbols.

We can build GNU Hello with by writing fewer lines of code:

```nix
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
```

Compared to the previous example, we no longer have to specify how to unpack
the sources or open the source directory.

Layer 6: GNU Make/GNU Autotools abstraction
-------------------------------------------
The `stdenv.mkDerivation` abstraction extends the previous function abstraction
with a `configure`, `build`, `check` and `install` phase that carry out steps
to build GNU Make/GNU Autotools projects. It also provides all base dependencies
that you need to build such projects.

We can build GNU Hello with this abstraction function with only a few lines of
code:

```nix
{stdenv, fetchurl}:

stdenv.mkDerivation {
  name = "hello-2.10";
  src = fetchurl {
    url = mirror://gnu/hello/hello-2.10.tar.gz;
    sha256 = "0ssi1wpaf7plaswqqjwigppsg5fyh99vdlb9kzl7c9lng89ndq1i";
  };
}
```

Test abstraction functions
==========================
There are two example abstraction functions built around the functions that the
generic builder provides. `writeTextFile` is a function that can be used to
generate text files and `buildPerlPackage` is a function abstraction that builds
Perl modules.

Test cases
==========
The `tests` directory contains test package sets for each abstraction layer.
To run them, inspect the `all-packages.nix` file, and evaluate a desired
attribute, such as:

```bash
$ nix-build all-packages.nix -A gnuhello
```

License
=======
The contents of this package is available under the same license as Nixpkgs --
the [MIT](https://opensource.org/licenses/MIT) license.
