#!/bin/sh

# Do we have a local development copy of the sarah gem?
SARAH=../../sarah/lib/sarah
if [ -d "$SARAH" ]
then
    export RUBYLIB="$SARAH"
fi

# Run the requested tests (or all of them)
for t in ${*:-[0-9]*.rb}
do ruby $t
done
