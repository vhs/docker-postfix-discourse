#!/bin/bash

echo "Bootstrapping..."

if [ "$VERBOSE" = "YES" ] ; then
 sh -x /usr/local/bin/bootstrap.sh
else
 /usr/local/bin/bootstrap.sh
fi

if [ "$VERBOSE" = "YES" ] ; then
 echo "Executing CMD [$@]..."
fi

exec "$@"
