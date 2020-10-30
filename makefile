# Set default no argument goal to help
.DEFAULT_GOAL := help

# Ensure that errors don't hide inside pipes
SHELL         = /bin/bash
.SHELLFLAGS   = -o pipefail -c

# For cleanup, get Compose project name from .env file
DC_PROJECT?=$(shell cat .env | sed 's/^*=//')


# Every command is a PHONY, to avoid file naming confliction -> strengh comes from good habits!
.PHONY: help
help:
	@echo "=============================================================================="
	@echo " Automated HTTPS reverse proxy using Let's Encrypt SSL certificates "
	@echo "  https://github.com/elasticlabs/https-nginx-proxy-docker-compose"
	@echo " "
	@echo "Hints for developers:"
	@echo "  make up                     # With working proxy, brings up the SDI"
	@echo "  make logs                   # Follows whole SDI logs (Geoserver, Geonetwork, PostGIS, Client app)"
	@echo "  make down                   # Brings the SDI down. "
	@echo "  make cleanup                # Complete hard cleanup of images, containers, networks, volumes & data of the SDI"
	@echo "  make update                 # Update the whole stack"
	@echo "=============================================================================="


.PHONY: up
up:
	@echo "[INFO] Building the HTTPS automated proxy"
	docker-compose up -d --remove-orphans --build nginx-proxy
	docker-compose up -d --remove-orphans --build letsencrypt-companion
	docker-compose up -d --remove-orphans --build portainer

.PHONY: logs
logs:
    @echo "[INFO] Following latest logs"
	docker-compose logs --follow

.PHONY: down
down:
    @echo "[INFO] Bringing done the HTTPS automated proxy"
	docker-compose down --remove-orphans
	@echo "[INFO] Done. See (sudo make cleanup) for containers, images, and static volumes cleanup"

.PHONY: cleanup
cleanup:
    @echo "[INFO] Bringing done the HTTPS automated proxy"
	docker-compose -f docker-compose.yml down --remove-orphans
	# 2nd : clean up all containers & images, without deleting static volumes
    @echo "[INFO] Cleaning up containers & images"
	docker rm $(docker ps -a -q)
	docker rmi $(docker images -q)
	docker system prune -a
    # Delete all hosted persistent data available in volumes
	@echo "[INFO] Cleaning up static volumes"
    docker volume rm -f $(DC_PROJECT)_certs
	docker volume rm -f $(DC_PROJECT)_vhost.d
	docker volume rm -f $(DC_PROJECT)_html
	@echo "[INFO] Cleaning up portainer volume and data (/opt/portainer/data)."
	rm -rf /opt/portainer/data
	# Remove all dangling docker volumes
	@echo "[INFO] Remove all dangling docker volumes"
	docker volume rm $(shell docker volume ls -qf dangling=true)

.PHONY pull
pull: 
    docker-compose pull    

.PHONY: update
update: pull up wait
	docker image prune

.PHONY: wait
wait: 
	sleep 5