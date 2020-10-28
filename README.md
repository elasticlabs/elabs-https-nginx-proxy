# https-nginx-proxy-docker-compose
Automated nginx-proxy &amp; let's encrypt HTTPS reverse proxy for your dockerized applications
Based on Jason Wilder's Nginx HTTP Proxy (https://github.com/nginx-proxy/nginx-proxy) 
See [Automated Nginx Reverse Proxy for Docker][http://jasonwilder.com/blog/2014/03/25/automated-nginx-reverse-proxy-for-docker/] for why you might want to use this.

## Stack management
* get help : `sudo make help`
* Bring up the whole stack : `sudo make up`
* Go inside a container : `sudo docker-compose -f <compose-file> exec -it <service-id> bash`
* See logs of a container: `sudo docker -f <compose-file> logs <service-id>`
* Monitor containers : `sudo docker -f <compose-file> stats`