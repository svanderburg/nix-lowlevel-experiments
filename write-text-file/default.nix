{stdenv}:

{ name # the name of the derivation
, text
, executable ? false # run chmod +x ?
, destination ? ""   # relative path appended to $out eg "/bin/foo"
, checkPhase ? ""    # syntax checks, e.g. for scripts
}:

stdenv.runCommand {
  inherit name text executable;
  passAsFile = [ "text" ];

  # Pointless to do this on a remote machine.
  preferLocalBuild = true;
  allowSubstitutes = false;

  buildCommand = ''
    target=$out${destination}
    mkdir -p "$(dirname "$target")"

    if [ -e "$textPath" ]
    then
        mv "$textPath" "$target"
    else
        echo -n "$text" > "$target"
    fi

    [ "$executable" = "1" ] && chmod +x "$target" || true
  '';
}
