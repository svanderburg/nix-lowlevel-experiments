{stdenv}:

stdenv.simpleDerivation {
  name = "hello";
  builder = ./builder.sh;
  meta = {
    description = "This is a simple testcase";
  };
}
