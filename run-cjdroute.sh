#!/bin/bash

cd "${BASH_SOURCE%/*}" || { echo "Can not find my working directory" ; exit 1 ; }
basedir="$PWD"

echo "Starting the run-loop in pwd=$PWD"
nohup ./run-cjdroute-loop.sh &
echo "It should be now running in background"

