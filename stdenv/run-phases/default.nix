{runCommand}:
args:

runCommand ({
  setupRunPhases = ./setup.sh;
  builder = ./builder.sh;
} // args)
