# Set default no argument goal to help
.DEFAULT_GOAL := help

# Ensure that errors don't hide inside pipes
SHELL         = /bin/bash
.SHELLFLAGS   = -o pipefail -c

# Setup variables
PROJECT_NAME?=$(shell cat .env | grep -v ^\# | grep COMPOSE_PROJECT_NAME | sed 's/.*=//')
APPS_NETWORK?=$(shell cat .env | grep -v ^\# | grep APPS_NETWORK | sed 's/.*=//')
ADMIN_NETWORK?=$(shell cat .env | grep -v ^\# | grep ADMIN_NETWORK | sed 's/.*=//')

# Every command is a PHONY, to avoid file naming confliction -> strengh comes from good habits!
.PHONY: help
help:
	@echo "=================================================================================="
	@echo " Automated HTTPS reverse proxy using Let's Encrypt SSL certificates "
	@echo "  https://github.com/elasticlabs/https-nginx-proxy-docker-compose"
	@echo " "
	@echo " Hints for developers:"
	@echo "  make build            # Checks that everythings's OK then builds the stack"
	@echo "  make up               # With working proxy, brings up the software stack"
	@echo "  make update           # Update the whole stack"
	@echo "  make hard-cleanup     # /!\ Remove images, containers, networks, volumes & data"
	@echo "=================================================================================="

.PHONY: build
build:
	# Network creation if not done yet
	@echo "[INFO] Create ${APPS_NETWORK} and ${ADMIN_NETWORK} networks if they don't already exist"
	docker network inspect ${APPS_NETWORK} >/dev/null 2>&1 || docker network create --driver bridge ${APPS_NETWORK}
	docker network inspect ${ADMIN_NETWORK} >/dev/null 2>&1 || docker network create --driver bridge ${ADMIN_NETWORK}
	# Build the stack
	@echo "[INFO] Building the application"
	docker-compose -f docker-compose.yml build
	@echo "[INFO] Build OK. Use make up to activate the automated proxy."

.PHONY: up
up: build
	@echo "[INFO] Building the HTTPS automated proxy"
	docker-compose up -d --remove-orphans

.PHONY: hard-cleanup
hard-cleanup:
	@echo "[INFO] Bringing done the HTTPS automated proxy"
	docker-compose -f docker-compose.yml down --remove-orphans
	# 2nd : clean up all containers & images, without deleting static volumes
	@echo "[INFO] Cleaning up containers & images"
	docker rm $(docker ps -a -q)
	docker rmi $(docker images -q)
	docker system prune -a
	# Delete all hosted persistent data available in volumes
	@echo "[INFO] Cleaning up static volumes"
	docker volume rm -f $(PROJECT_NAME)_certs
	docker volume rm -f $(PROJECT_NAME)_vhost.d
	docker volume rm -f $(PROJECT_NAME)_html
	@echo "[INFO] Cleaning up portainer volume and data (/opt/portainer/data)."
	rm -rf /opt/portainer/data
	# Remove all dangling docker volumes
	@echo "[INFO] Remove all dangling docker volumes"
	docker volume rm $(shell docker volume ls -qf dangling=true)

.PHONY: pull
pull: 
	docker-compose pull

.PHONY: update
update: pull up wait
	docker image prune

.PHONY: wait
wait: 
	sleep 5