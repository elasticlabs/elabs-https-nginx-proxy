# HTTPS Secure reverse proxy
An opinionated Secure Web Application Gateway (SWAG) &amp; Authelia HTTPS reverse application proxy for your dockerized software stacks! This stack implements the following building blocks : 
  - [Secure Web Application Gateway (SWAG)](https://www.linuxserver.io/blog/2020-08-21-introducing-swag) for Nginx best practice gateway + certbot + fail2ban + goaccess
  - [Authelia](https://www.authelia.com/integration/proxies/swag/) with built-in elegant 2FA for secure access to your apps
  - [Portainer CE](https://www.portainer.io/) for daily docker monitoring
  - [Homepage](https://github.com/benphelps/homepage/) for your deployments... well... Homepage :-)

<p>
  <img src="https://raw.githubusercontent.com/elasticlabs/elabs-https-nginx-proxy/main/Architecture.png" alt="Elasticlabs Secure Proxy architecture" height="400px">
</p>

**Table Of Contents:**
  - [Preparation steps](#preparation-steps)
    - [DNS configuration](#dns-configuration)
    - [Stack preparation](#stack-preparation)
  - [Stack initial deployment](#stack-initial-deployment)
  - [Post-Install configuration](#post-install-configuration)
    - [Portainer](#portainer)
    - [Homepage](#homepage)
    - [SWAG](#swag)
    - [Authelia](#authelia)

----  

## Preparation steps
Please 1st ensure that you deployed a fresh docker + compose environment on your server. If not, please follow the [docker installation guide](https://docs.docker.com/engine/install/) and the [docker-compose installation guide](https://docs.docker.com/compose/install/). Dont forget to follow the [post-installation steps](https://docs.docker.com/engine/install/linux-postinstall/) to ensure your docker environment is properly configured. 

* Install utility tools: `# yum install git nano make htop wget tshark nano tree`
* Carefully create / choose an appropriate directory to group your stacks GIT reposities (e.g. `~/AppContainers/`)
* GIT clone this repository `git clone https://github.com/elasticlabs/https-nginx-proxy-docker-compose.git`

### DNS configuration
To successfully implement this solution, you'll need to ensure that the following DNS records are existing and properly pointing towards your server's IP address (replace `example.com` with your own domain name). Ensure those properly resolve from your server using `nslookup`commands

| Tool | Record | description |
|---|---|---|
| Homepage | `example.com` | Your server homepage URL. Portainer will be accessed through `example.com/portainer` URL |
| Authelia | `auth.example.com` | Your Authelia URL. Authelia API will be accessed through `auth.example.com/api` URL |
| SWAG Dashboard | `dash.example.com` | Your SWAG Dashboard (GoAccess) URL |

### Stack preparation
This stack is composed of 4 main services : SWAG, Authelia, Portainer and Homepage. Therefore, preparing the deployment has to follow a progressive order to complete successfully.

| Tool | Steps |
|---|---|
| Docker Compose | * Rename `.env-changeme` file into `.env` to ensure `docker compose` sets its environement correctly.<br>* Modify the following variables in `.env` file :<br>  * `VIRTUAL_HOST=` : replace `example.com` with your homepage domain name (usually ROOT domain).<br>  * `CERTBOT_EMAIL=` : used for let'sencrypt account.<br>  * `SUBDOMAINS`=auth,dash.<br>  * `AUTHELIA_SUBDOMAIN`=auth.example.com.<br>  * `TZ`=Europe/Paris by your timezone. |
| SWAG | * Rename `.env_swag-variables-changeme` file into `.env_swag-variables` to ensure `docker compose` sets its environement correctly.<br>* Modify the following variables in `.env_swag-variables` file :<br>  * `TZ`=Europe/Paris by your timezone.<br>  * `MAXMINDDB_LICENSE_KEY=` : replace `<license-key>` with your [Maxmind licence key](https://www.maxmind.com/en/geolite2/signup) personal licence key.<br>  * `DOCKER_MODS=` : uncomment this line to use SWAG Dashboard + Maxmind GeoIP2 database. |
| Authelia | Apart from the `AUTHELIA_SUBDOMAIN` variable in the `.env` file, it's not recommanded to setup and run Authelia immediately at this step. Please make the whole stack work before enabling security. When ready, please navigate to [Authelia](#authelia) |
| Homepage | No need to change anything in the configuration of Homepage for now, the makefile gets you covered! | 


## Stack initial deployment
| ▲ [Top](#https-secure-reverse-proxy) |
| --- |

A lot of work has been done to make the deployment of this stack as easy as possible. The following section describes how to deploy the stack and how to use it. It is based on the `Makefile` and following operators : 
* Get help : `make`
* `make up` : brings up the whole stack. `up` always triggers a `make build` before, so you don't have to worry about it.
* `make build` : (Optional) checks that everythings's OK then builds the stack images.
* `make hard-cleanup` : /!\ Remove images, containers, networks, volumes & data

<p>
If all runs well, you should check for services status, especially SWAG with the following command : `docker compose logs swag-proxy`. Especially, negociating the certificates creation with Let's Encrypt can take a while. Please be patient. Once SWAG becomes ready, you should see something like this :

```bash	
elabs-secure-proxy_swag-entrypoint  | Server ready
```

* `make logs` : shows the logs of the whole stack
* `make logs-<service-id>` : shows the logs of a specific service (double-tab to list available services)
* `make exec-<service-id>` : opens a shell inside a specific service container
* `make ps` : shows the status of the whole stack
* `make ps-<service-id>` : shows the status of a specific service
* `make update` : (Optional) updates the stack images.


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

* Homepage is configured through [a couple of YAML files](https://gethomepage.dev/en/configs/service-widgets/): 
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

**Dashboard**

This opinionated SWAG deployment comes with a pre-configured dashboard. It is based on the [SWAG Dashboard](https://github.com/linuxserver/docker-mods/tree/swag-dashboard) and [Maxmind GeoIP2 database](https://github.com/linuxserver/docker-mods/tree/swag-maxmind) docker mods.

To operate, you need to :
1. In the `.env_swag-variables` file : 
  * Uncomment the `DOCKER_MODS` variable
  * Replace `<licence-key>` with your [Maxmind licence key](https://www.maxmind.com/en/geolite2/signup) personal licence key 

2. Rename the `./data/swag/config/nginx/site-confs/dash.subdomain.conf.sample` file to `./data/swag/config/nginx/site-confs/dash.subdomain.conf`
Please ensure that the `server_name` directive matches your choosen subdomain (e.g. `dash.your-domain.ltd`) and that a matching DNS records exists. 

3. (Re)start SWAG to take the new configuration into account (e.g. `docker compose restart swag-proxy`)

4. Add the following line to `/config/nginx/nginx.conf` under the `http` section:
   
   ```nginx
   include /config/nginx/maxmind.conf;
   ```
5. Edit `/config/nginx/maxmind.conf` and add countries to the blocklist / whitelist according to the comments, for example:
   
    ```nginx
    map $geoip2_data_country_iso_code $geo-whitelist {
        default no;
        GB yes;
    }

    map $geoip2_data_country_iso_code $geo-blacklist {
        default yes;
        US no;
    }
    ```
6. Use the definitions in the following way:
   ```nginx
    server {
        listen 443 ssl;
        listen [::]:443 ssl;

        server_name some-app.*;
        include /config/nginx/ssl.conf;
        client_max_body_size 0;

        if ($lan-ip = yes) { set $geo-whitelist yes; }
        if ($geo-whitelist = no) { return 404; }

        location / {
    ```
7. Restart the container to apply the changes.

### Authelia
| ▲ [Top](#https-secure-reverse-proxy) |
| --- |

This section will be filled soon. Please be patient. ;-)