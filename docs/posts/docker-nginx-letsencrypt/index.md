# Setup Docker/Ngnix and Let's Encrypt on Ubuntu

This is a note for setting up a Docker, Nginx and Let's Encrypt environment on
Ubuntu 20.04 LTS.

## Create a Ubuntu 20.04 LTS instance

## Install Docker using the convenience script

```bash
$ curl -fsSL https://get.docker.com -o get-docker.sh
$ sudo sh get-docker.sh
```

## Manage Docker as a non-root user

If you don't want to preface the `docker` command with `sudo`, create a Unix
group called `docker` and add users to it. When the Docker daemon starts, it
creates a Unix socket accessible by members of the `docker` group.

To create the `docker` group and add your user:

1.  Create the `docker` group.

```bash
$ sudo groupadd docker
```

2.  Add your user to the `docker` group.

```bash
$ sudo usermod -aG docker $USER
```

3.  Log out and log back in so that your group membership is re-evaluated.
    
    On Linux, you can also run the following command to activate the changes to groups:
  
```bash 
$ newgrp docker 
```

## Configure Docker to start on boot

```bash
$ sudo systemctl enable docker
```

To disable this behavior, use `disable` instead.

```bash
$ sudo systemctl disable docker
```

## Install Docker Compose

On Linux, you can download the Docker Compose binary from the
[Compose repository release page on GitHub](https://github.com/docker/compose/releases).
Follow the instructions from the link, which involve running the `curl` command
in your terminal to download the binaries. These step-by-step instructions are
also included below.

1.  Run this command to download the current stable release of Docker Compose:

```bash
$ sudo curl -L "https://github.com/docker/compose/releases/download/1.25.5/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
```
!!! note
    To install a different version of Compose, substitute `1.25.5`
    with the version of Compose you want to use.

2.  Apply executable permissions to the binary:

``` bash
$ sudo chmod +x /usr/local/bin/docker-compose
```
    
!!! note 
    If the command `docker-compose` fails after installation, check your
    path. You can also create a symbolic link to `/usr/bin` or any other
    directory in your path. For example:

    ```
    $ sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
    ```

## Set up Nginx-Proxy

Create a unique network for nginx-proxy and other Docker containers to communicate through.

``` bash
$ docker network create nginx-proxy
```

Create a directory `nginx-proxy` for the compose file.

``` bash
$ mkdir nginx-proxy && cd nginx-proxy
```

In the nginx-proxy directory, create a new file named `docker-compose.yml` and paste in the following text:

??? example "example `docker-compose.yml` for nginx-proxy"

    ```yaml
    version: '3'

    services:
      nginx:
        image: nginx
        restart: always
        container_name: nginx-proxy
        ports:
          - "80:80"
          - "443:443"
        volumes:
          - conf:/etc/nginx/conf.d
          - vhost:/etc/nginx/vhost.d
          - html:/usr/share/nginx/html
          - certs:/etc/nginx/certs
        labels:
          - "com.github.jrcs.letsencrypt_nginx_proxy_companion.nginx_proxy=true"

      dockergen:
        image: jwilder/docker-gen
        restart: always
        container_name: nginx-proxy-gen
        depends_on:
          - nginx
        command: -notify-sighup nginx-proxy -watch -wait 5s:30s /etc/docker-gen/templates/nginx.tmpl /etc/nginx/conf.d/default.conf
        volumes:
          - conf:/etc/nginx/conf.d
          - vhost:/etc/nginx/vhost.d
          - html:/usr/share/nginx/html
          - certs:/etc/nginx/certs
          - /var/run/docker.sock:/tmp/docker.sock:ro
          - ./nginx.tmpl:/etc/docker-gen/templates/nginx.tmpl:ro

      letsencrypt:
        image: jrcs/letsencrypt-nginx-proxy-companion
        restart: always
        container_name: nginx-proxy-le
        depends_on:
          - nginx
          - dockergen
        environment:
          NGINX_PROXY_CONTAINER: nginx-proxy
          NGINX_DOCKER_GEN_CONTAINER: nginx-proxy-gen
        volumes:
          - conf:/etc/nginx/conf.d
          - vhost:/etc/nginx/vhost.d
          - html:/usr/share/nginx/html
          - certs:/etc/nginx/certs
          - /var/run/docker.sock:/var/run/docker.sock:ro

    volumes:
      conf:
      vhost:
      html:
      certs:

    networks:
      default:
        external:
          name: nginx-proxy
    ```

Inside of the `nginx-proxy` directory, use the following `curl` command to copy the developer’s sample `nginx.tmpl` file to your VPS.

``` bash
$ curl https://raw.githubusercontent.com/jwilder/nginx-proxy/master/nginx.tmpl > nginx.tmpl
```

> **Increase upload file size**
>
> To increase the maximum upload size, for example, add `client_max_body_size 100M;` to the `server{}` section in the `nginx.tmpl` template file.
> For WordPress, 

Running `nginx-proxy`.

``` bash
$ docker-compose up -d
```

## Add a WordPress container

Create a directory for the `docker-compose.yml` with:

??? example "example `docker-compose.yml` for WordPress container"

    ```yaml
    version: "3"

    services:
      db_node_domain:
        image: mysql:5.7
        volumes:
            - db_data:/var/lib/mysql
        restart: always
        environment:
            MYSQL_ROOT_PASSWORD: somewordpress
            MYSQL_DATABASE: wordpress
            MYSQL_USER: wordpress
            MYSQL_PASSWORD: wordpress
        container_name: wp_test_db

      wordpress:
        depends_on:
            - db_node_domain
        image: wordpress:latest
        expose:
            - 80
        restart: always
        environment:
            VIRTUAL_HOST: blog.example.com
            LETSENCRYPT_HOST: blog.example.com
            LETSENCRYPT_EMAIL: foo@example.com
            WORDPRESS_DB_HOST: db_node_domain:3306
            WORDPRESS_DB_USER: wordpress
            WORDPRESS_DB_PASSWORD: wordpress
        container_name: wp_test
    volumes:
      db_data:

    networks:
      default:
        external:
          name: nginx-proxy
    ```

To create a second WordPress container, add `MYSQL_TCP_PORT` environment variable and set it to a different port.

### Increase maximum WordPress upload file size

Enter the bash of the WordPress container.

``` bash
$ docker exec -t wordpress_container_name bash
```

Move inside your /var/www/html directory (already there if you’re using the standard Docker Compose image). Run the following command to insert the values.

``` bash
$ sed -i '/^# END WordPress.*/i php_value upload_max_filesize 256M\nphp_value post_max_size 256M' .htaccess
```

!!! note
    To restore the values, run `$ sed -i "11,12d" .htaccess`

