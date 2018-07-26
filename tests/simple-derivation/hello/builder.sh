source $setupSimpleDerivation

mkdir -p $out/bin

cat > $out/bin/hello <<EOF
#!$SHELL -e

echo "Hello"
EOF

chmod +x $out/bin/hello
