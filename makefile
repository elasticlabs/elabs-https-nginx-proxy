# Set default no argument goal to help
.DEFAULT_GOAL := help

# Ensure that errors don't hide inside pipes
SHELL         = /bin/bash
.SHELLFLAGS   = -o pipefail -c

# Setup variables
PROJECT_NAME?=$(shell cat .env | grep -v ^\# | grep COMPOSE_PROJECT_NAME | sed 's/.*=//')
APP_BASEURL?=$(shell cat .env | grep VIRTUAL_HOST | sed 's/.*=//')
AUTHELIA?=$(shell cat .env | grep AUTHELIA_SUBDOMAIN | sed 's/.*=//')
APPS_NETWORK?=$(shell cat .env | grep -v ^\# | grep APPS_NETWORK | sed 's/.*=//')
ADMIN_NETWORK?=$(shell cat .env | grep -v ^\# | grep ADMIN_NETWORK | sed 's/.*=//')

# Every command is a PHONY, to avoid file naming confliction -> strengh comes from good habits!
.PHONY: help
help:
	@echo "=================================================================================="
	@echo "        Secure HTTPS reverse proxy based on SWAG, Portainer and Authelia  "
	@echo "       >> https://github.com/elasticlabs/https-nginx-proxy-docker-compose"
	@echo " "
	@echo " Hints for developers:"
	@echo "  make build            # Checks that everythings's OK then builds the stack"
	@echo "  make up               # With working proxy, brings up the software stack"
	@echo "  make update           # Update the whole stack"
	@echo "  make authelia-hash    # Create a hashed password for Authelia users"
	@echo "  make hard-cleanup     # /!\ Remove images, containers, networks, volumes & data"
	@echo "=================================================================================="

.PHONY: build
build:
	# Network creation if not done yet
	@bash ./.utils/message.sh info "[INFO] Create ${APPS_NETWORK} and ${ADMIN_NETWORK} networks if they don't already exist"
	docker network inspect ${APPS_NETWORK} >/dev/null 2>&1 || docker network create --driver bridge ${APPS_NETWORK}
	docker network inspect ${ADMIN_NETWORK} >/dev/null 2>&1 || docker network create --driver bridge ${ADMIN_NETWORK}
	#
	@bash ./.utils/message.sh info "Set Homepage base URL"
	sed -i "s/changeme/${APP_BASEURL}/" ./data/homepage/settings.yaml
	#
	@bash ./.utils/message.sh info "Set Authelia base URL"
	sed -i "s/changeme/${APP_BASEURL}/g" ./data/authelia/config/configuration.yaml
	sed -i "s/changeme/${APP_BASEURL}/g" ./data/authelia/config/configuration.acl.yaml
	@bash ./.utils/message.sh info "Set Authelia subdomain in 401 error redirection URL"
	sed -i "s/changeme/${AUTHELIA}/" ./data/swag/config/nginx/snippets/authelia-authrequest.conf
	@bash ./.utils/message.sh warn "[WARN] Checking if at least 1 Authelia user is configured"
	grep -q "change" ./data/authelia/config/*.yaml && echo "Please create at least 1 user" && exit 1 || echo "All set!"
	#
	# Build the stack
	@bash ./.utils/message.sh info "[INFO] Building the Secure proxy"
	docker compose -f docker-compose.yml build
	@bash ./.utils/message.sh info "[INFO] Build OK. Use make up to activate the automated proxy."

.PHONY: up
up: build
	@bash ./.utils/message.sh info "[INFO] Bringing up the secure proxy"
	docker compose up -d --remove-orphans
	@make urls

.PHONY: authelia-hash
authelia-hash:
	@bash ./.utils/message.sh info "[INFO] Hash a password in Argon2 for Authelia"
	read -p "Password: " PASSWORD
	docker run authelia/authelia:latest authelia hash-password ${PASSWORD} 
	@echo ""
	@bash ./.utils/message.sh info "[INFO] You can now use it for any user in "
	@bash ./.utils/message.sh link "./data/authelia/config/users_database.yml"

.PHONY: hard-cleanup
hard-cleanup:
	@bash ./.utils/message.sh info "[INFO] Bringing done the HTTPS automated proxy"
	docker compose -f docker-compose.yml down --remove-orphans
	# Delete all hosted persistent data available in volumes
	@bash ./.utils/message.sh info "[INFO] Cleaning up static volumes"
	#docker volume rm -f $(PROJECT_NAME)_html
	@bash ./.utils/message.sh info "[INFO] The Letsencrypt CERT volumes are not deleted to avoid rate limiting"
	@bash ./.utils/message.sh info "[INFO] Cleaning up containers & images"
	docker system prune -a

.PHONY: urls
urls:
	@bash ./.utils/message.sh headline "[INFO] You may now access your project at the following URL:"
	@bash ./.utils/message.sh link "Homepage: https://${APP_BASEURL}/"
	@bash ./.utils/message.sh link "Portainer docker admin GUI: https://${APP_BASEURL}/portainer"
	@bash ./.utils/message.sh link "Authelia portal: https://${AUTHELIA}/"
	@bash ./.utils/message.sh link "(Optional) SWAG dashboard: https://dash.${APP_BASEURL}"
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
