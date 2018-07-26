source $setupMakeDerivation

configurePhase()
{
    perl Makefile.PL PREFIX=$out INSTALLDIRS=site $makeMakerFlags
}

checkPhase()
{
    if checkForMakefile
    then
        make SHELL=$SHELL $checkFlags $makeFlags test
    else
        echo "No makefile found"
    fi
}

propagateDependencies()
{
    # If a user installs a Perl package, she probably also wants its
    # dependencies in the user environment (since Perl modules don't
    # have something like an RPATH, so the only way to find the
    # dependencies is to have them in the PERL5LIB variable).
    if [ -f $out/nix-support/propagated-build-inputs ]
    then
        ln -s $out/nix-support/propagated-build-inputs $out/nix-support/propagated-user-env-packages
    fi
}

phases="$preBuildPhases $buildPhases propagateDependencies $postBuildPhases"
