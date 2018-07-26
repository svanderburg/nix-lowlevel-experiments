source $setupGenericBuild

configurePhase()
{
    configureScript=${configureScript:-./configure}

    if [ -x "$configureScript" ]
    then
        if [ "$dontAddPrefix" != "1" ]
        then
            configureFlags="--prefix=$out $configureFlags"
        fi

        # Add flags for multiple output dirs
        if [[ "$outputs" = *"bin"* ]]
        then
            configureFlags="--bindir=$bin/bin $configureFlags"
        fi

        if [[ "$outputs" = *"lib"* ]]
        then
            configureFlags="--libdir=$lib/lib $configureFlags"
        fi

        if [[ "$outputs" = *"man"* ]]
        then
            configureFlags="--mandir=$man/share/man $configureFlags"
        fi

        if [[ "$outputs" = *"info"* ]]
        then
            configureFlags="--infodir=$man/share/info $configureFlags"
        fi

        if [[ "$outputs" = *"dev"* ]]
        then
            configureFlags="--includedir=$dev/include --oldincludedir=$dev/include $configureFlags"
            installFlags="pkgconfigdir=$dev/lib/pkgconfig m4datadir=$dev/share/aclocal aclocaldir=$dev/share/aclocal $installFlags"
        fi

        eval $configureScript $configureFlags
    else
        echo "No executable configure script found"
    fi
}

checkForMakefile()
{
    [ -n "$makefile" ] && [ -f "$makefile" ] || [ -f Makefile ] || [ -f makefile ] || [ -f GNUmakefile ]
}

buildPhase()
{
    if [ "$makefile" != "" ]
    then
        makeFlags="-f $makefile $makeFlags"
    fi

    if checkForMakefile
    then
        eval make SHELL=$SHELL $buildFlags $makeFlags
    else
        echo "No makefile found"
    fi
}

checkPhase()
{
    if checkForMakefile
    then
        eval make SHELL=$SHELL $checkFlags $makeFlags check
    else
        echo "No makefile found"
    fi
}

installPhase()
{
    if checkForMakefile
    then
        eval make SHELL=$SHELL $installFlags $makeFlags install
    else
        echo "No makefile found"
    fi
}

buildPhases="configure build check install"
phases="$preBuildPhases $buildPhases $postBuildPhases"
dontCheck=1
