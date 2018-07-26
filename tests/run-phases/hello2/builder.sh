source $setupRunPhases

phases="build install"

buildPhase()
{
    cat > hello <<EOF
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
