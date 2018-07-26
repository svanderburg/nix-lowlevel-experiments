set -e
shopt -s nullglob

# Source the setup script to get basic UNIX utilities in our PATH
source $stdenv/setup

# Extra environment variable tweaks to make builds pure

# Set the TZ (timezone) environment variable, otherwise commands like
# `date' will complain (e.g., `Tue Mar 9 10:01:47 Local time zone must
# be set--see zic manual page 2004').
export TZ=UTC

# Set a fallback default value for SOURCE_DATE_EPOCH, used by some
# build tools to provide a deterministic substitute for the "current"
# time. Note that 1 = 1970-01-01 00:00:01. We don't use 0 because it
# confuses some applications.
export SOURCE_DATE_EPOCH
: ${SOURCE_DATE_EPOCH:=1}
