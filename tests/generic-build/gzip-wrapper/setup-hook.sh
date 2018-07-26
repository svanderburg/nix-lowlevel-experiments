_tryGunzip()
{
    case "$1" in
        *.gz)
            gzip -d "$1"
            ;;
        *)
            return 1
            ;;
    esac
}

uncompressHooks+=(_tryGunzip)
