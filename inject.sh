#       ⣿⣿                   ⣿⣿
#       ⣿⣿                   ⣿⣿
#       ⣿⣿                   ⣿⣿   ⣿⣿
#       ⣿⣿                   ⣿⣿   ⣿⣿
#       ⣿⣿                   ⣿⣿   ⣿⣿

#       ⣿⣿  ⣿⣿               ⣿⣿
#       ⣿⣿  ⣿⣿               ⣿⣿
#       ⣿⣿  ⣿⣿               ⣿⣿   
#       ⣿⣿  ⣿⣿               ⣿⣿   
#       ⣿⣿  ⣿⣿               ⣿⣿   ⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿


#!/bin/bash

# Make sure your plugin has been published on npm registry & 
# is placed in superset-viz-plugins/plugins

# variables
PARENT_DIRECTORY=/Users/atirek/Documents/Couture/code #directory in which the script will run
NPM_ORG=improved-octo-succotash #name of the org used to publish package on npmjs
PROJECT_PARENT_DIRECTORY=superset-viz-plugins #name of repo in which plugin is placed. Default it to 'superset-viz-plugins'
PLUGIN_NAME=plugin-chart-scatter-map #name of plugin being injected
PRESET_NAME=NewPreset4 #name of preset file
PLUGINS_EXTRA_FILENAME=NewPreset4 #name of plugins extra file

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
mv "$PLUGINS_EXTRA_FILENAME" "$PLUGINS_EXTRA_FILENAME".ts
mv "$PLUGINS_EXTRA_FILENAME".ts src/setup/


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
