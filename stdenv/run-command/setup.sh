source $setupSimpleDerivation

# Process buildInputs to allow processes to find their dependencies
PATH_DELIMITER=':'

envHooks=("addToPATH")

# Executes all function in the envHooks array and propagates the package path to
# each of them. This can be used to make a package available to the environment,
# typically by modifying environment variables containing search paths (e.g.
# PATH).

addToEnv()
{
    local pkg="$1"

    for hook in "${envHooks[@]}"
    do
        $hook "$pkg"
    done
}

addToSearchPathWithCustomDelimeter()
{
    local delimiter="$1"
    local varName="$2"
    local dir="$3"

    if [ -d "$dir" ]
    then
        eval export $varName="$dir${!varName:+$delimiter}${!varName}"
    fi
}

addToSearchPath()
{
    addToSearchPathWithCustomDelimeter "$PATH_DELIMITER" "$1" "$2"
}

addToPATH()
{
    addToSearchPath PATH "$1/bin"
}

findInputs()
{
    local inputs="$1"

    for input in $inputs
    do
        if [ -f "$input/nix-support/setup-hook" ]
        then
            source "$input/nix-support/setup-hook"
        fi
    done

    for input in $inputs
    do
        addToEnv "$input"
    done

    for input in $inputs
    do
       if [ -f "$input/nix-support/propagated-build-inputs" ]
       then
           findInputs "$(cat $input/nix-support/propagated-build-inputs)"
       fi
    done
}

runCommand()
{
    findInputs "$buildInputs"
    findInputs "$propagatedBuildInputs"

    # Write propagated build inputs to config file

    if [ -n "$propagatedBuildInputs" ]
    then
        mkdir -p $out/nix-support
        echo "$propagatedBuildInputs" > $out/nix-support/propagated-build-inputs
    fi

    # Write setup hooks to config file

    if [ -n "$setupHook" ]
    then
        mkdir -p $out/nix-support
        cp $setupHook $out/nix-support/setup-hook
    fi

    # Execute build command, if defined
    if [ -n "$buildCommandPath" ]
    then
        source "$buildCommandPath"
    elif [ -n "$buildCommand" ]
    then
        eval "$buildCommand"
    fi
}
