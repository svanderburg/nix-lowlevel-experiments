{stdenv}:

stdenv.runPhases {
  name = "hello2";
  builder = ./builder.sh;
}
