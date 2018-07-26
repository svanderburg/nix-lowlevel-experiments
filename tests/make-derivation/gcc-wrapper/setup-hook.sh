addToCPATH()
{
    addToSearchPath CPATH $1/include
}

addToLIBRARY_PATH()
{
    addToSearchPath LIBRARY_PATH $1/lib
}

envHooks+=(addToCPATH addToLIBRARY_PATH)
