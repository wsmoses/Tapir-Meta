#!/bin/sh

set -e

case "$1" in
    configure)
	# EXECUTE MY BASH COMMAND
	echo "/usr/lib/clang/6.0.0/lib/linux" > /etc/ld.so.conf.d/tapir.conf && ldconfig
	;;

    abort-upgrade|abort-remove|abort-deconfigure)
	exit 0
	;;

    *)
	echo "postinst called with unknown argument \`$1'" >&2
	exit 1
	;;
esac

exit 0
