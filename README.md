## plugin-inject-superset
Bash script that automatically injects published plugins to Apache Superset

## superset-inject.md  
Contains documentation on the process of injecting plugins.  

## Prequisites  
1. Make sure the docker daemon is running while you run the scripts.  
2. Make sure your plugin is properly published on npmjs.

## Usage
1. To run the script, open the ```script.sh``` file, & fill in the parameter variables. The details of the parameters are commented inside the script.  
2. Run ```./script.sh```. Ensure that the docker daemon is runnning while you run the script.  
3. After the run is finished, relevant changes have been made to the Superset code so that your plugin will be available & working. Go inside the superset folder and build the Superset image using ```docker build -t "imagename" .```. After the image build has finished (approx. 20-35  minutes depending on the processing power of your system), replace the Superset image in docker-compose.yml with the one you just built.  
4. Run Superset & you will be able to use your plugin.  

## Limitations  
1. Currently the script is only able to work with npm packages that have been published using an organisation, ex. @improved-octo-succotash/plugin-chart-hello-world  
2. The script only works for plugins made such that only 1 plugin is associated with 1 package.json file.   
