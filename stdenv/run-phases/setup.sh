source $setupRunCommand

# Run a hook. A hook can be defined as function/alias/builtin, a file
# representing a script or process, or a string containing shell code

runHook()
{
    local hookName=$1
    local hookType=$(type -t $hookName)

    if [ -z "${!hookName}" ]
    then
        case "$hookType" in
            function|alias|builtin) # hook is a function/alias/builtin
                $hookName
                ;;
            file)
                source $hookName # hook is a file/process
                ;;
            *)
                eval "${!hookName}" # hook is a string
                ;;
        esac
    else
        eval "${!hookName}" # hook is a string
    fi
}

# Execute a particular phase. Every phase has a pre<phaseName> and
# post<phaseName> hook, that can be configured by the user. Every phase can be
# disabled by setting the dont<phaseName> to true / 1.
# Disabled phases can be reenabled again with do<phaseName> set to true / 1

executePhase()
{
    local phase=$1
    local dontVariableName=dont${phase^}
    local doVariableName=do${phase^}

    if [ -z "${!dontVariableName}" ] || [ -n "${!doVariableName}" ]
    then
        runHook pre${phase^}
        runHook ${phase}Phase
        runHook post${phase^}
    fi
}

# Function that gets invoked when the build exists.
# It can be used to execute a hook on failure or success.

exitHandler()
{
    exitCode="$?"

    if [ "$exitCode" = "0" ]
    then
        runHook exitHook
    else
        runHook failureHook
    fi

    exit "$exitCode"
}

# Executes the generic build procedure. If a build command is given
# it will get executed, otherwise it will executed the specified phases.

genericBuild()
{
    runCommand

    # Only run phases if no buildCommand was given
    if [ -z "$buildCommand" ] && [ -z "$buildCommandPath" ]
    then
        # Execute phases
        for phase in $phases
        do
            echo "Executing phase: $phase"
            executePhase $phase
        done
    fi
}

trap "exitHandler" EXIT
