    ⣿⣿                   ⣿⣿
    ⣿⣿                   ⣿⣿
    ⣿⣿                   ⣿⣿   ⣿⣿
    ⣿⣿                   ⣿⣿   ⣿⣿
    ⣿⣿                   ⣿⣿   ⣿⣿

    ⣿⣿  ⣿⣿               ⣿⣿
    ⣿⣿  ⣿⣿               ⣿⣿
    ⣿⣿  ⣿⣿               ⣿⣿   
    ⣿⣿  ⣿⣿               ⣿⣿   
    ⣿⣿  ⣿⣿               ⣿⣿   ⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿


#!/bin/bash

# Make sure your plugin has been published on npm registry & is placed in 
# superset-viz-plugins/plugins

# variables
WORKING_DIRECTORY=/Users/atirek/Documents/Couture/code #directory in which the script will run
NPM_ORG=improved-octo-succotash #name of the org used to publish package on npmjs
PROJECT_WORKING_DIRECTORY=superset-viz-plugins #name of repo in which plugin is placed. Default it to 'superset-viz-plugins'
PLUGIN_NAME=plugins-chart-custom-echarts #name of plugin being injected
PRESET_NAME=NewPreset #name of preset file
PLUGINS_EXTRA_FILENAME= #name of plugins extra file
IMAGE_NAME= #name of docker image that will be generated

# TODO: automatically get plugin code from npmjs

# add org to .npmrc
echo @"$NPM_ORG":registry=http://registry.npmjs.org/ \
>> $WORKING_DIRECTORY/superset/superset-frontend/.npmrc

# add plugin as module to package.json
GITHUB_WORKSPACE=$WORKING_DIRECTORY \
PROJECT_WORKING_DIRECTORY=$PROJECT_WORKING_DIRECTORY \
node ../../$PROJECT_WORKING_DIRECTORY/scripts/addDependencies.js  \
$PLUGIN_NAME

# generate preset file
GITHUB_WORKSPACE=$WORKING_DIRECTORY \
PROJECT_WORKING_DIRECTORY=$PROJECT_WORKING_DIRECTORY \
PRESET_NAME=$PRESET_NAME \
node ../../$PROJECT_WORKING_DIRECTORY/scripts/generatePreset.js \
$PLUGIN_NAME

# move preset file to presets/ directory
mv "$PRESET_NAME"Preset.ts src/visualizations/presets/"$PRESET_NAME"Preset.js

# generate setuppluginsextra file
GITHUB_WORKSPACE=$WORKING_DIRECTORY \
PROJECT_WORKING_DIRECTORY=$PROJECT_WORKING_DIRECTORY \
PRESET_NAME=$PRESET_NAME \
PLUGINS_EXTRA_FILENAME=$PLUGINS_EXTRA_FILENAME \
node ../../$PROJECT_WORKING_DIRECTORY/scripts/generateSetupPluginsExtra.js \
$PLUGIN_NAME

# copy preset file to setup
mv $PLUGINS_EXTRA_FILENAME "$PLUGINS_EXTRA_FILENAME".ts
cp "$PLUGINS_EXTRA_FILENAME".ts src/setup/

