# Sympa in Docker

This project aims to containerize the Sympa mailing list daemon in a Docker container. 
It includes configuration of exim4, nginx, fcgiwrapper and is all started and managed
using supervisord. 

To start:
docker-compose up -d