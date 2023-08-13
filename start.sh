#!/bin/bash

# Start the docker-compose services
echo "Starting docker container, you can tail this process with the command"
echo "docker logs -f resonite-headless-headless-core-1"
echo
docker-compose up -d

