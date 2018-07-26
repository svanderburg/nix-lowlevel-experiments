derivation {
  name = "test";
  builder = ./test.sh;
  system = "x86_64-linux";
  message = "Hello world";
  outputs = [ "dev" "out" ];
}
