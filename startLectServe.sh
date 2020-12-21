#!/bin/bash

## VERSION 1.20201221 ##

export PERL5OPT=-MTry::Tiny::Tiny
git checkout master
git fetch origin
git reset --hard origin/master
carton install
echo "Starting new LectServe version..."
cd $HOME/LectServe
carton exec starman --port 5000 $HOME/LectServe/bin/app.psgi --daemonize --pid $HOME/lectserve.pid
echo "LectServe is now running."

exit 0