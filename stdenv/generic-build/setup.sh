source $setupRunPhases

# Unpacks a specified file by determining what file type it is and by invoking
# the appropriate unpack hook.

unpackFile()
{
    local src="$1"
    local hasUnpacked=0

    if [ -f "$src" ]
    then
        for unpackHook in ${unpackHooks[@]}
        do
            $unpackHook $src && hasUnpacked=1
        done
    elif [ -d "$src" ]
    then
        cp -a "$src" . && hasUnpacked=1
    fi

    if [ "$hasUnpacked" = "0" ]
    then
        echo "Don't know how to unpack: $src"
        exit 1
    fi
}

# Executes the unpack phase. It unpacks all provided sources, makes them
# writable and then attempts to enter the source root directory.

unpackPhase()
{
    if [ -z "$srcs" ] && [ -n "$src" ]
    then
        srcs="$src"
    fi

    # Check the directory structure before unpacking
    local dirsBefore=""
    for i in *
    do
        if [ -d "$i" ]
        then
            dirsBefore="$dirsBefore $i "
        fi
    done

    # Unpack all sources
    for src in $srcs
    do
        unpackFile "$src"
    done

    # Attempt to determine the source root directory
    if [ -z "$sourceRoot" ]
    then
        # When no source root has been specified, compare the current directory
        # content with the last recorded directory contents
        for i in *
        do
            if [ -d "$i" ]
            then
                case $dirsBefore in
                    *\ $i\ *)
                        ;;
                    *)
                        if [ -n "$sourceRoot" ]
                        then
                            echo "unpacker produced multiple directories"
                            exit 1
                        fi
                        sourceRoot="$i"
                        ;;
                esac
            fi
        done

        if [ -z "$sourceRoot" ]
        then
            echo "unpack did not produce a directory"
            exit 1
        fi
    fi

    echo "source root is $sourceRoot"

    # Restore write permissions
    if [ "${dontMakeSourcesWritable:-0}" != 1 ]
    then
        chmod -R u+w -- "$sourceRoot"
    fi

    # Open the source root
    cd "$sourceRoot"
}

# Uncompresses a file by looking at the file type and invoking the appropriate
# uncompress hook.

uncompressFile()
{
    local src="$1"
    local hasUncompressed=0

    for uncompressHook in ${uncompressHooks[@]}
    do
        $uncompressHook "$src" && hasUncompressed=1
    done

    if [ "$hasUncompressed" = "0" ]
    then
        cat "$src"
    fi
}

# Executes the patch phase by uncompression the patch files and applying them.

patchPhase()
{
    for i in $patches
    do
        echo "applying patch $i"
        uncompressFile "$i" 2>&1 | patch ${patchFlags:--p1}
    done
}

# Executes the strip phase that processes all binary directories and strips
# debugging symbols from them

stripPhase()
{
    for target in ${outputs:-out}
    do
        cd ${!target}
        stripDebugList=${stripDebugList:-lib lib32 lib64 bin}

        for dir in $stripDebugList
        do
            if [ -d "$dir" ]
            then
                find $dir -type f -name \*.so -or -name \*.so.\* | while read i
                do
                    strip --strip-debug "$i"
                done
            fi
        done
    done
}

# Executes a phase that patches shebang lines of all executables to Nix store
# paths

patchShebangsPhase()
{
    for target in ${outputs:-out}
    do
        patch-shebangs ${!target}/bin
    done
}

# Executes a phases that compress all manual pages

compressManPagesPhase()
{
    for target in ${outputs:-out}
    do
        compress-man "${!target}"
    done
}

preBuildPhases="unpack patch"
postBuildPhases="strip patchShebangs compressManPages"

phases="$preBuildPhases buildCommand $postBuildPhases"
