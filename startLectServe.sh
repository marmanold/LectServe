#!/bin/bash

## VERSION 1.20201221 ##

export PERL5OPT=-MTry::Tiny::Tiny
git pull --rebase --depth 1
carton install
echo "Stopping old version..."
eval "pkill -f starman"
echo "Starting new LectServe version..."
cd $HOME/LectServe
nohup carton exec starman --port 5000 --preload-app $HOME/LectServe/bin/app.psgi > /dev/null 2>&1 &
echo "LectServe is now running."

exit 0