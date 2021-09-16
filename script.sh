#!/bin/bash

############################################################
# Setup
############################################################

# This script will have the basic setup required by Superset
# Make sure the docker daemon is running

# variables
PARENT_DIRECTORY=/Users/atirek/Documents/Couture/code # directory in which the script will run

# enter parent directory
cd $PARENT_DIRECTORY

# clone Apache Superset(if not already cloned) & switch to the version you want to use(in this case 1.3)
if [ -d "$PARENT_DIRECTORY/superset" ]; 
then
    echo "superset already cloned"
else
    git clone https://github.com/apache/superset
    cd $PARENT_DIRECTORY/superset
    git checkout 1.3
fi

# clone the superset-viz-plugins repo(if not already cloned)
cd $PARENT_DIRECTORY
if [ -d "$PARENT_DIRECTORY/superset-viz-plugins" ]; 
then
    echo "superset-viz-plugins already cloned"
else
    git clone https://github.com/nielsen-oss/superset-viz-plugins
fi
exit
# install fast-glob & fs-extra in scripts
cd $PARENT_DIRECTORY/superset-viz-plugins/scripts
npm init --yes
npm i fs-extra fast-glob

# pull nielsen Superset 1.3 image
docker pull nielsenoss/apache-superset:1.3

# extract nielsen superset-frontend folder from image
container=$(docker create nielsenoss/apache-superset:1.3)
docker cp $container:/app/superset-frontend $PARENT_DIRECTORY
docker rm -v $container

# replace superset-frontend folder with the one from nielsen image
rm -rf $PARENT_DIRECTORY/superset/superset-frontend
mv $PARENT_DIRECTORY/superset-frontend $PARENT_DIRECTORY/superset/