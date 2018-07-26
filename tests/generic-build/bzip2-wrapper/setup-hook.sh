_tryBunzip2()
{
    case "$1" in
        *.bz|*.bz2)
            bzip2 -d "$1"
            ;;
        *)
            return 1
            ;;
    esac
}

uncompressHooks+=(_tryBunzip2)
