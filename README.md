# HTTPS Let's encrypt based Nginx reverse proxy
Automated nginx-proxy &amp; let's encrypt HTTPS reverse proxy for your dockerized applications
Based on Secure Web Application Proxy (SWAG) (), and Authelia () 

**Table Of Contents:**
  - [Docker environment preparation](#docker-environment-preparation)
  - [Nginx HTTPS Proxy preparation](#nginx-https-proxy-preparation)
  - [Stack deployment and management](#stack-deployment-and-management)

----

## Docker environment preparation 
* Install utility tools: `# yum install git nano make htop elinks wget tshark nano tree`
* Avoid `sudo`issues by adding your current username to the `docker` group: `# sudo groupadd docker && sudo usermod -aG docker <usename> && sudo systemctl restart docker`
* Avoid docker-compose issues with sudo by adding `/usr/local/lib`to the PATH `secure_path variable`
* Install the [latest version of docker-compose](https://docs.docker.com/compose/install/)

## Nginx HTTPS Proxy preparation
* Carefully create / choose an appropriate directory to group your applications GIT reposities (e.g. `~/AppContainers/`)
* Choose & configure a selected DNS name (e.g. `portainer.your-domain.ltd`). Make sure it properly resolves from your server using `nslookup`commands
* GIT clone this repository `git clone https://github.com/elasticlabs/https-nginx-proxy-docker-compose.git`

**Configuration**
* **Rename `.env-changeme` file into `.env`** to ensure `docker-compose` gets its environement correctly.
* Modify the following variables in `.env-changeme` file :
  * `PORTAINER_VHOST=` : replace `portainer.your-domain.ltd` with your choosen subdomain for portainer.
  * `LETSENCRYPT_EMAIL=` : replace `email@mail-provider.ltd` with the email address to get notifications on Certificates issues for your domain. 

## Stack deployment and management
**Deployment**
* Get help : `sudo make help`
* Bring up the whole stack : `sudo make build && sudo make up`

**Useful management commands**
* Go inside a container : `sudo docker-compose exec -it <service-id> bash` or `sh`
* See logs of a container: `sudo docker-compose logs <service-id>`
* Monitor containers : `sudo docker stats` or... use portainer!
* Access Portainer Web GUI : available at the URL defined in `.env` file.
