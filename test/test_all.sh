#!/bin/sh

export RUBYLIB=../../sarah/lib/sarah

for t in [0-9]*.rb
do ruby $t
done
