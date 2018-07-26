set -e

# Setup PATH for base packages
for i in $basePackages
do
    basePackagesPath="$basePackagesPath${basePackagesPath:+:}$i/bin"
done

export PATH="$basePackagesPath"

# Create setup script
mkdir $out
cat > $out/setup <<EOF
export SHELL=$shell
export PATH="$basePackagesPath"
EOF

# Allow the user to install stdenv using nix-env and get the packages
# in stdenv.
mkdir $out/nix-support
echo "$basePackages" > $out/nix-support/propagated-user-env-packages
