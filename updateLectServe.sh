#!/bin/bash

## VERSION 1.20201221 ##

export PERL5OPT=-MTry::Tiny::Tiny
git fetch origin
git reset --hard origin/master
carton install
echo "Restarting Lectserve..."
kill -1 `cat $HOME/lectserve.pid`

exit 0