{ stdenv
, writeTextFile
, daemon
, initFunctions
, createCredentials

, initialInstructions ? ". ${initFunctions}"
, startDaemon ? "start_daemon"
, startProcessAsDaemon ? "${daemon}/bin/daemon"
, stopDaemon ? "killproc"
, reloadDaemon ? "killproc"
, evaluateCommand ? "evaluate_retval"
, statusCommand ? "statusproc"
, runtimeDir ? "/var/run"
, tmpDir ? "/tmp"
, restartActivity ? ''
  $0 stop
  sleep 1
  $0 start
''
, supportedRunlevels ? stdenv.lib.range 0 6
, minSequence ? 0
, maxSequence ? 99
, forceDisableUserChange ? false
}:

{ name
, instanceName ? null
, description ? name
, globalInstructions ? ""
, umask ? null
, nice ? null
, directory ? null
, path ? []
, environment ? {}
, initialize ? ""
, process ? null
, processIsDaemon ? true
, args ? []
, pidFile ? (if instanceName == null then null else if user == null || user == "root" then "${runtimeDir}/${instanceName}.pid" else "${tmpDir}/${instanceName}.pid")
, user ? null
, reloadSignal ? "-HUP"
, instructions ? {}
, activities ? {}
, removeActivities ? []
, runlevels ? []
, defaultStart ? []
, defaultStop ? []
, dependencies ? []
, credentials ? {}
}:

let
  # Enumerates the activities in a logical order -- the common activities first, then the remaining activities in alphabetical order
  enumerateActivities = activities:
    stdenv.lib.optional (activities ? start) "start"
    ++ stdenv.lib.optional (activities ? stop) "stop"
    ++ stdenv.lib.optional (activities ? reload) "reload"
    ++ stdenv.lib.optional (activities ? restart) "restart"
    ++ stdenv.lib.optional (activities ? status) "status"
    ++ builtins.filter (activityName: activityName != "start" && activityName != "stop" && activityName != "reload" && activityName != "restart" && activityName != "status" && activityName != "*") (builtins.attrNames activities)
    ++ stdenv.lib.optional (activities ? "*") "*";

  _user = if forceDisableUserChange then null else user;

  _instructions = (stdenv.lib.optionalAttrs (process != null) {
    start = {
      activity = "Starting";
      instruction =
        initialize +
        (if processIsDaemon then "${startDaemon} ${stdenv.lib.optionalString (pidFile != null) "-f -p ${pidFile}"} ${stdenv.lib.optionalString (nice != null) "-n ${nice}"} ${stdenv.lib.optionalString (_user != null) "su ${_user} -c '"} ${process} ${toString args} ${stdenv.lib.optionalString (user != null) "'"}"
        else "${startProcessAsDaemon} -U -i ${if pidFile == null then "-P ${runtimeDir} -n $(basename ${process})" else "-F ${pidFile}"} ${stdenv.lib.optionalString (_user != null) "-u ${_user}"} ${process} ${toString args}");
    };
    stop = {
      activity = "Stopping";
      instruction = "${stopDaemon} ${stdenv.lib.optionalString (pidFile != null) "-p ${pidFile}"} ${process}";
    };
    reload = {
      activity = "Reloading";
      instruction = "${reloadDaemon} ${stdenv.lib.optionalString (pidFile != null) "-p ${pidFile}"} ${process} ${reloadSignal}";
    };
  }) // instructions;

  _activities =
    let
      convertedInstructions = stdenv.lib.mapAttrs (name: instruction:
        ''
          log_info_msg "${instruction.activity} ${description}..."
          ${instruction.instruction}
          ${evaluateCommand}
        ''
      ) _instructions;

      defaultActivities = stdenv.lib.optionalAttrs (process != null) {
        status = "${statusCommand} ${stdenv.lib.optionalString (pidFile != null) "-p ${pidFile}"} ${process}";
        restart = restartActivity;
      } // {
        "*" = ''
          echo "Usage: $0 {${builtins.concatStringsSep "|" (builtins.filter (activityName: activityName != "*") (enumerateActivities _activities))}}"
          exit 1
        '';
      };
    in
    removeAttrs (convertedInstructions // defaultActivities // activities) removeActivities;

  _defaultStart = if runlevels != [] then stdenv.lib.intersectLists runlevels supportedRunlevels
    else defaultStart;

  _defaultStop = if runlevels != [] then stdenv.lib.subtractLists _defaultStart supportedRunlevels
    else defaultStop;

  _environment = stdenv.lib.optionalAttrs (path != []) {
    PATH = "${builtins.concatStringsSep ":" (map(package: "${package}/bin" ) path)}:$PATH";
  } // environment;

  initdScript = writeTextFile {
    inherit name;
    executable = true;
    text = ''
      #! ${stdenv.shell}

      ## BEGIN INIT INFO
      # Provides:      ${name}
    ''
    + stdenv.lib.optionalString (_defaultStart != []) "# Default-Start: ${toString _defaultStart}\n"
    + stdenv.lib.optionalString (_defaultStop != []) "# Default-Stop:  ${toString _defaultStop}\n"
    + stdenv.lib.optionalString (dependencies != []) ''
      # Should-Start:  ${toString (map (dependency: dependency.name) dependencies)}
      # Should-Stop:   ${toString (map (dependency: dependency.name) dependencies)}
    ''
    + ''
      # Description:   ${description}
      ## END INIT INFO

      ${initialInstructions}
      ${globalInstructions}
    ''
    + stdenv.lib.optionalString (umask != null) ''
      umask ${umask}
    ''
    + stdenv.lib.optionalString (directory != null) ''
      cd ${directory}
    ''
    + stdenv.lib.concatMapStrings (name:
        let
          value = builtins.getAttr name _environment;
        in
        ''
          export ${name}=${stdenv.lib.escapeShellArg value}
        ''
      ) (builtins.attrNames _environment)
    + ''

      case "$1" in
        ${stdenv.lib.concatMapStrings (activityName:
          let
            instructions = builtins.getAttr activityName _activities;
          in
          ''
            ${activityName})
              ${instructions}
              ;;

          ''
        ) (enumerateActivities _activities)}
      esac
    '';
  };

  startSequenceNumber =
    if dependencies == [] then minSequence
    else builtins.head (builtins.sort (a: b: a > b) (map (dependency: dependency.sequence) dependencies)) + 1;

  stopSequenceNumber = maxSequence - startSequenceNumber + minSequence;

  sequenceNumberToString = number:
    if number < 10 then "0${toString number}"
    else toString number;

  credentialsSpec = if credentials == {} || forceDisableUserChange then null else createCredentials credentials;
in
stdenv.mkDerivation {
  inherit name;

  sequence = startSequenceNumber;

  buildCommand = ''
    mkdir -p $out/etc/rc.d
    cd $out/etc/rc.d

    mkdir -p init.d
    ln -s ${initdScript} init.d/${name}

    ${stdenv.lib.concatMapStrings (runlevel: ''
      mkdir -p rc${toString runlevel}.d
      ln -s ../init.d/${name} rc${toString runlevel}.d/S${sequenceNumberToString startSequenceNumber}${name}
    '') _defaultStart}

    ${stdenv.lib.concatMapStrings (runlevel: ''
      mkdir -p rc${toString runlevel}.d
      ln -s ../init.d/${name} rc${toString runlevel}.d/K${sequenceNumberToString stopSequenceNumber}${name}
    '') _defaultStop}

    ${stdenv.lib.optionalString (credentialsSpec != null) ''
      ln -s ${credentialsSpec}/dysnomia-support $out/dysnomia-support
    ''}
  '';
}
