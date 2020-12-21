#!/bin/bash

## VERSION 1.20201221 ##

export PERL5OPT=-MTry::Tiny::Tiny
git reset --hard origin/master
carton install
echo "Stopping old version..."
kill -1 `cat $HOME/lectserve.pid`
echo "Starting new LectServe version..."
cd $HOME/LectServe
carton exec starman --port 5000 $HOME/LectServe/bin/app.psgi --daemonize --pid $HOME/lectserve.pid
echo "LectServe is now running."

exit 0