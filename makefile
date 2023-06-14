# Set default no argument goal to help
.DEFAULT_GOAL := help

# Ensure that errors don't hide inside pipes
SHELL         = /bin/bash
.SHELLFLAGS   = -o pipefail -c

# Setup variables
PROJECT_NAME?=$(shell cat .env | grep -v ^\# | grep COMPOSE_PROJECT_NAME | sed 's/.*=//')
APP_BASEURL?=$(shell cat .env | grep PORTAINER_VHOST | sed 's/.*=//')
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
	@bash ./.utils/message.sh info "[INFO] Create ${APPS_NETWORK} and ${ADMIN_NETWORK} networks if they don't already exist"
	docker network inspect ${APPS_NETWORK} >/dev/null 2>&1 || docker network create --driver bridge ${APPS_NETWORK}
	docker network inspect ${ADMIN_NETWORK} >/dev/null 2>&1 || docker network create --driver bridge ${ADMIN_NETWORK}
	# Set server_name in reverse proxy
	sed -i "s/changeme/${APP_BASEURL}/" ./proxy/portainer.subfolder.conf
	# Build the stack
	@bash ./.utils/message.sh info "[INFO] Building the application"
	docker compose -f docker-compose.yml build
	@bash ./.utils/message.sh info "[INFO] Build OK. Use make up to activate the automated proxy."

.PHONY: up
up: build
	@bash ./.utils/message.sh info "[INFO] Building the HTTPS automated proxy"
	docker compose up -d --remove-orphans
	@make urls

.PHONY: hard-cleanup
hard-cleanup:
	@bash ./.utils/message.sh info "[INFO] Bringing done the HTTPS automated proxy"
	docker compose -f docker-compose.yml down --remove-orphans
	# Delete all hosted persistent data available in volumes
	@bash ./.utils/message.sh info "[INFO] Cleaning up static volumes"
	docker volume rm -f $(PROJECT_NAME)_certs
	docker volume rm -f $(PROJECT_NAME)_vhost.d
	docker volume rm -f $(PROJECT_NAME)_html
	@bash ./.utils/message.sh info "[INFO] Cleaning up containers & images"
	docker system prune -a
	@bash ./.utils/message.sh info "[INFO] Cleaning up portainer static volume and data (/opt/portainer/data)."
	rm -rf /opt/portainer/data

.PHONY: urls
urls:
	@bash ./.utils/message.sh headline "[INFO] You may now access your project at the following URL:"
	@bash ./.utils/message.sh link "Portainer docker admin GUI:  https://${APP_BASEURL}/portainer"
	@echo ""

.PHONY: pull
pull: 
	docker compose pull

.PHONY: update
update: pull up wait
	docker image prune

.PHONY: wait
wait: 
	sleep 5
