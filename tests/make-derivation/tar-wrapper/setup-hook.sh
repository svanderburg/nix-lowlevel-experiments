_tryUntar()
{
    case "$1" in
        *.tar|*.tar.gz|*.tar.bz2|*.tar.lzma|*.tar.xz)
            tar xfv "$1"
            ;;
        *)
            return 1
            ;;
    esac
}

unpackHooks+=(_tryUntar)
