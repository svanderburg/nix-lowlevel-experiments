{stdenv, basePackages, runtimeDir}:

let
  basePath = builtins.concatStringsSep ":" (map (package: "${package}/bin") basePackages);
in
stdenv.mkDerivation {
  name = "init-functions";

  buildCommand = ''
    sed \
      -e "s|/bin:/usr/bin:/sbin:/usr/sbin|${basePath}|" \
      -e "s|/bin/sh|${stdenv.shell}|" \
      -e "s|/bin/echo|echo|" \
      -e "s|/bin/head|head|" \
      -e "s|/run/bootlog|${runtimeDir}/bootlog|" \
      -e "s|/var/run|${runtimeDir}|" \
      ${../lfs-bootscripts-20190524/lfs/lib/services/init-functions} > $out
  '';
}
