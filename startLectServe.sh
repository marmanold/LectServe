#!/bin/bash

## VERSION 1.20170319 ##

export PERL5OPT=-MTry::Tiny::Tiny
cd $HOME/LectServe && git reset --hard HEAD && git clean -f -d && git pull
cd $HOME/statsLiteClient && git reset --hard HEAD && git clean -f -d && git pull
cd $HOME && cp statsLiteClient/build/stats-lite-client.bundle.js LectServe/public/javascripts
cd $HOME/LectServe && sudo cp nginx.conf /etc/nginx
sudo service nginx reload 
cd $HOME/LectServe && carton install
echo "Stopping old version..."
eval "pkill -f starman"
echo "Starting new LectServe version..."
cd $HOME/LectServe
nohup carton exec starman --port 5000 --preload-app $HOME/LectServe/bin/app.psgi > /dev/null 2>&1 &
echo "LectServe is now running."

exit 0