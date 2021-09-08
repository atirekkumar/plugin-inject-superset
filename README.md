# plugin-inject-superset
Bash scripts to automatically inject plugins to Apache Superset

## Usage
1. **Run setup.sh**  
To setup the project from scratch, run the ```setup.sh``` script. Fill out the variables inside the script with relevant values. Make sure the docker daemon is running. This script only needs to be run once.  
2. Next place the folder containing the plugin code in $WORKING_DIRECTORY/superset-viz-plugins/plugins/ directory.
3. **Run inject.sh**  
To inject your plugin, run the ```inject.sh``` script. Fill out the variables inside the script with relevant values. Make sure the docker daemon is running.