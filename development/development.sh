#!/usr/bin/env bash

# preserve original production files
mv ./docker-compose.yml ./docker-compose.production.yml
mv ./Dockerfile ./Dockerfile.production
mv ./static/pathfinder/environment.ini ./static/pathfinder/environment.production.ini

# copy development versions 
cp ./development/docker-compose.development.yml ./docker-compose.yml
cp ./development/Dockerfile.development ./Dockerfile
cp ./development/environment.development.ini ./static/pathfinder/environment.ini

# set up launch file for vscode
mkdir -p .vscode && cp ./development/launch.json ./.vscode/launch.json

# seed .env file with dev presets
echo "path=\"$(pwd)\"" > ./.env
cat ./development/.env.development >> ./.env
