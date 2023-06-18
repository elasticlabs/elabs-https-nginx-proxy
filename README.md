# HTTPS Secure reverse proxy
Automated Secure Web Application Gateway (SWAG) &amp; Authelia HTTPS reverse application proxy for your dockerized software stacks! THis stack is based on the following excellent building blocks : 
  - Secure Web Application Gateway (SWAG) for NGinx off-the-shelf gateway full of best practices
  - Authelia for securing access to your applications
  - Portainer for daily docker monitoring
  - [Homepage](https://github.com/benphelps/homepage/) for your deployment go-to... well... Homepage :-)



**Table Of Contents:**
  - [Docker environment preparation](#docker-environment-preparation)
  - [Nginx HTTPS Proxy preparation](#nginx-https-proxy-preparation)
  - [Stack deployment and management](#stack-deployment-and-management)
  - [Post-Install configuration](#post-install-configuration)
    - [Portainer](#portainer)
    - [Homepage](#homepage)
    - [SWAG](#swag)
    - [Authelia](#authelia)


----  

## Docker environment preparation
* Install utility tools: `# yum install git nano make htop elinks wget tshark nano tree`
* Double-check that you properly followed [docker post-installation steps](https://docs.docker.com/engine/install/linux-postinstall/)
* Install the [latest version of docker-compose](https://docs.docker.com/compose/install/)

## Secure Application Proxy preparation
| ▲ [Top](#https-secure-reverse-proxy) |
| --- |

* Carefully create / choose an appropriate directory to group your applications GIT reposities (e.g. `~/AppContainers/`)
* Choose & configure a selected DNS name (e.g. `portainer.your-domain.ltd`). Make sure it properly resolves from your server using `nslookup`commands
* GIT clone this repository `git clone https://github.com/elasticlabs/https-nginx-proxy-docker-compose.git`

**Configuration**

* **Rename `.env-changeme` file into `.env`** to ensure `docker-compose` gets its environement correctly.
* Modify the following variables in `.env-changeme` file :
  * `VIRTUAL_HOST=` : replace `your-domain.ltd` with your choosen subdomain for homepage (e.g. example.com).
  * `CERTBOT_EMAIL=` : replace `email@mail-provider.ltd` with the email address to get notifications on Certificates issues for your domain. 
  * `AUTHELIA_SUBDOMAIN=` : replace `auth.your-domain.ltd` with your choosen subdomain for Authelia (e.g. auth.example.com)

## Stack deployment and management
| ▲ [Top](#https-secure-reverse-proxy) |
| --- |

**Deployment**

* Get help : `make`
* Bring up the whole stack : `make up`
  * If all goes well from the `make up` set of commands point of view, the available URLs are listed at the end of the process.
  * You can now begin to use the gateway. Enjoy!!

**Useful management commands**

* Go inside a container : `docker compose exec <service-id> /bin/bash` or `/bin/sh`
* See logs of a container: `docker compose logs <service-id>`
* Monitor containers : `docker compose stats` or... use portainer!

## Post-Install configuration
| ▲ [Top](#https-secure-reverse-proxy) |
| --- |

After deploying the initial stack, comes real life! The following section describes what your get and how you can get and do more immediately after the first deployment.

### Portainer 
After deployment you have `5 minutes` to setup an `administrative user accomunt` in the Portain GUI.
* If you fail to do it and access portainer, you'll be redirected to a `timeout.html` page.
* When this happen, simply restart Portainer : `docker compose restart portainer`, then create this 1st account. The tool is ready.

**Authelia**

Once Authelia is configured and tested OK on the server homepage, you can use it to secure access to your `Portainer` deployment.
Please go to the [Authelia](#authelia) section to learn more.

### Homepage
| ▲ [Top](#https-secure-reverse-proxy) |
| --- |

This secure gateway comes with a simple and fancy pre-configured `server homepage`. 
I chose [Homepage](https://github.com/benphelps/homepage/) over others for its simplicity and its ability to be easily customized.
Built with [Vue.js](https://vuejs.org/), [Bulma](https://bulma.io/) and [Buefy](https://buefy.org/), Homepage is a single page application (SPA) that you can host on your own server. It provides a quick way for you to access your favorites websites. It is meant to be fully customizable to suit your needs.

**Configuration**

* Homepage is configured through a couple of YAML files : 
  * `bookmarks.yml` : place here a list of your favorite websites, like in your web browser, but specialized for your deployment
  * `services.yml` : where you can [manually or automatically add your dockerized services](https://gethomepage.dev/en/configs/services/)
  * `settings.yml` : to customize its behaviour
  * `widgets.yml` : where you can add fancy and useful widgets to your homepage. Please go there to learn more!

**Authelia**

Once Authelia is configured and tested OK on the server homepage, you can use it to secure access to your `Homepage` deployment.
Please go to the [Authelia](#authelia) section to learn more.

### SWAG
| ▲ [Top](#https-secure-reverse-proxy) |
| --- |

The goal of this section is to give you ideas on how to get started with the LinuxServer SWAG. We will explain some of the basic concepts and limitations, and provide you with common examples. 

Big idea short : when thinking about deplying a new stack, you have 2 major choices to make :
* Either you want your stuff to live in a subfolder of your domain (e.g. `https://your-domain.ltd/your-app/`)
* Or you want your stuff to live in a subdomain of your domain (e.g. `https://your-app.your-domain.ltd/`)

**Subfolder**

SWAG comes with tons of sample configuration files matching most common COTS on the market. You can find them in the `/config/nginx/proxy-confs/` folder. Please visit the [SWAG reverse proxy documentation](https://github.com/linuxserver/reverse-proxy-confs) to learn more.

These configuration files follow a simple naming convention : `<app-name>.subfolder.conf.sample`.
During startup, SWAG will automatically load all the `<app-name>.subfolder.conf` files and aggregate their `location` blocks to the `default.conf`live nginx file.
* Therefore, in this case you only act on the `location` blocks.

To operate, you need to :
* Copy the sample file to a new file without the `.sample` extension (e.g. `cp nextcloud.subfolder.conf.sample nextcloud.subfolder.conf`)
  * You can also move the file to the `./data/swag/config/nginx/proxy-confs/` folder to keep things clean and tidy.
  * Edit the new file to match your needs (e.g. `nano nextcloud.subfolder.conf`)
  * **Authelia** : if you want to secure access to this new app, please go to the [Authelia](#authelia) section to learn more.
* Restart SWAG to take the new configuration into account (e.g. `docker compose restart swag`)

**Subdomain**

This time, you need to create full `server` blocks for a given subdomain.
Again, you can find sample config files in the `/config/nginx/proxy-confs/` folder. Please visit the [SWAG reverse proxy documentation](https://github.com/linuxserver/reverse-proxy-confs) to learn more.

To operate, you need to :
* Copy the sample file to a new file without the `.sample` extension (e.g. `cp nextcloud.subdomain.conf.sample nextcloud.subdomain.conf`)
  * You can also move the file to the `./data/swag/config/nginx/site-confs/` folder to keep things clean and tidy.
  * Edit the new file to match your needs (e.g. `nano nextcloud.subdomain.conf`)
  * **Authelia** : if you want to secure access to this new app, please go to the [Authelia](#authelia) section to learn more.

### Authelia
| ▲ [Top](#https-secure-reverse-proxy) |
| --- |

This section will be filled soon. Please be patient. ;-)