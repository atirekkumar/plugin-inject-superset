#!/bin/bash

############################################################
# Setup
############################################################

# This script will have the basic setup required by Superset
# Make sure the docker daemon is running

# variables
PARENT_DIRECTORY=/Users/atirek/Documents/Couture/code # directory in which the script will run
SUPERSET_VERSION=1.3 # version of superset you are working on
NPM_ORG=improved-octo-succotash #name of the org used to publish package on npmjs
PROJECT_PARENT_DIRECTORY=superset-viz-plugins #name of repo in which plugin is placed. Default it to 'superset-viz-plugins'
PLUGIN_NAME=plugin-chart-scatter-map #name of plugin being injected
PRESET_NAME=NewPreset4 #name of preset file
PLUGINS_EXTRA_FILENAME=NewPreset4 #name of plugins extra file

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

# install fast-glob & fs-extra in scripts
cd $PARENT_DIRECTORY/superset-viz-plugins/scripts
npm init --yes
npm i fs-extra fast-glob

# pull nielsen Superset image of specified version
docker pull nielsenoss/apache-superset:$SUPERSET_VERSION

# extract nielsen superset-frontend folder from image
container=$(docker create nielsenoss/apache-superset:$SUPERSET_VERSION)
docker cp $container:/app/superset-frontend $PARENT_DIRECTORY
docker rm -v $container

# replace superset-frontend folder with the one from nielsen image
# if the below commands gives permission error, add sudo
rm -rf $PARENT_DIRECTORY/superset/superset-frontend
mv $PARENT_DIRECTORY/superset-frontend $PARENT_DIRECTORY/superset/

############################################################
# Inject plugin
############################################################

# Make sure your plugin has been published on npm registry & 
# is placed in superset-viz-plugins/plugins

# TODO: automatically get plugin code from npmjs

# cd into superst-frontend
cd "$PARENT_DIRECTORY"/superset/superset-frontend

# add org to .npmrc
echo @"$NPM_ORG":registry=http://registry.npmjs.org/ \
>> "$PARENT_DIRECTORY"/superset/superset-frontend/.npmrc

# add plugin as module to package.json
GITHUB_WORKSPACE="$PARENT_DIRECTORY" \
PROJECT_PARENT_DIRECTORY="$PROJECT_PARENT_DIRECTORY" \
node ../../"$PROJECT_PARENT_DIRECTORY"/scripts/addDependencies.js  \
"$PLUGIN_NAME"

# generate preset file
GITHUB_WORKSPACE="$PARENT_DIRECTORY" \
PROJECT_PARENT_DIRECTORY="$PROJECT_PARENT_DIRECTORY" \
PRESET_NAME="$PRESET_NAME" \
node ../../"$PROJECT_PARENT_DIRECTORY"/scripts/generatePreset.js \
"$PLUGIN_NAME"

# move preset file to presets/ directory
mv "$PRESET_NAME"Preset.ts src/visualizations/presets/"$PRESET_NAME"Preset.js

# generate setuppluginsextra file
GITHUB_WORKSPACE="$PARENT_DIRECTORY" \
PROJECT_PARENT_DIRECTORY="$PROJECT_PARENT_DIRECTORY" \
PRESET_NAME="$PRESET_NAME" \
PLUGINS_EXTRA_FILENAME="$PLUGINS_EXTRA_FILENAME" \
node ../../"$PROJECT_PARENT_DIRECTORY"/scripts/generateSetupPluginsExtra.js \
"$PLUGIN_NAME"

# move preset file to setup
mv "$PLUGINS_EXTRA_FILENAME" src/setup/"$PLUGINS_EXTRA_FILENAME".ts

# for MacOS
if [[ "$OSTYPE" == "darwin"* ]]; 
then
    # replace deafult function name with file name
    sed -i '' -e 's/setupPluginsExtra/'$PLUGINS_EXTRA_FILENAME'/' \
    "$PARENT_DIRECTORY"/superset/superset-frontend/src/setup/"$PLUGINS_EXTRA_FILENAME".ts
    
    # call plugins_extra file in setupPlugins.ts
    sed -i '' -e '/import MainPreset/a \
    import '$PLUGINS_EXTRA_FILENAME' from '\'./$PLUGINS_EXTRA_FILENAME\'';' \
    "$PARENT_DIRECTORY"/superset/superset-frontend/src/setup/setupPlugins.ts

    sed -i '' -e '/setupPluginsExtra();/a \
    '$PLUGINS_EXTRA_FILENAME'();' \
    "$PARENT_DIRECTORY"/superset/superset-frontend/src/setup/setupPlugins.ts
# for Linux
else
    # replace deafult function name with file name
    sed -i -e 's/setupPluginsExtra/'$PLUGINS_EXTRA_FILENAME'/' \
    "$PARENT_DIRECTORY"/superset/superset-frontend/src/setup/"$PLUGINS_EXTRA_FILENAME".ts

    # call plugins_extra file in setupPlugins.ts
    sed -i -e '/import MainPreset/a import '$PLUGINS_EXTRA_FILENAME' from '\'./$PLUGINS_EXTRA_FILENAME\'';' \
    "$PARENT_DIRECTORY"/superset/superset-frontend/src/setup/setupPlugins.ts

    sed -i -e '/setupPluginsExtra();/a '$PLUGINS_EXTRA_FILENAME'();' \
    "$PARENT_DIRECTORY"/superset/superset-frontend/src/setup/setupPlugins.ts
fi 

# update package-lock.json
cd "$PARENT_DIRECTORY"/superset/superset-frontend
npm install --package-lock-only --legacy-peer-deps
