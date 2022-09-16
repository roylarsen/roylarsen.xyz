Title: See you in hell, Nginx
Date: 2021-07-06 00:01
Author: roy.
Tags: docker, cloud, traefik
Slug: see-you-in-hell-nginx
Summary: Details about my migratioon from Nginx to Traefik

I'm mostly kidding, I'll always love me some Nginx.

But I did decide to do some needless engineering and migrate to a new Reverse Proxy on my public webserver.

I had a few needs that I wanted to address and I felt it was time. I wanted to take advantage of more automatic configuration through Docker that some modern reverse proxies use (it's always good to get rid of extra config files), and I also wanted to take advantage of automatic Let's Encrypt renewals (because I've been doing it mostly by hand for too long). I'd also like to do all of this in Docker Compose as well (my set-up is pretty basic and I don't need to deal with the eight million ton gorilla on my off-time).

I decided to move to Traefik since it seems to handle my (limited) requirements the best.

Traefik is a Cloud Native Ingress/Reverse Proxy that has built-in support for ACME/Let's Encrypt and is pretty much completely configurable through Labels (for Docker compose) or Annotations (for Kubernetes). The extent of my configuration outside of my compose file is mounting a volume to store the certificates that are requested.

Is what I'm doing correct? Probably not. Does it work? As far as I can tell. I don't have any issues with things.

### Core Config

```yaml
    traefik:  
      image: "traefik:v2.4"
      container_name: "traefik"
      command:
        - "--log.level=DEBUG"
        - "--api.insecure=false"
        - "--api.dashboard=false"
        - "--providers.docker=true"
        - "--providers.docker.exposedbydefault=false"
        - "--entrypoints.web.address=:80"
        - "--entrypoints.websecure.address=:443"
        - "--certificatesresolvers.xyz.acme.httpchallenge=true"
        - "--certificatesresolvers.xyz.acme.httpchallenge.entrypoint=web"
        - "--certificatesresolvers.xyz.acme.email=my email addy"
        - "--certificatesresolvers.xyz.acme.storage=/letsencrypt/xyz.json"
        - "--certificatesresolvers.tde.acme.httpchallenge=true"
        - "--certificatesresolvers.tde.acme.httpchallenge.entrypoint=web"
        - "--certificatesresolvers.tde.acme.email=my email again"
        - "--certificatesresolvers.tde.acme.storage=/letsencrypt/tde.json"
```

I left out a bunch of this configuration since it wasn't important to this post.

Here are some of the more important directives:

```yaml
    - "--providers.docker.exposedbydefault=false"
```

I don't want every service exposed, I want to control things on a service-by-service basis. I'll cover that in the next section.

```yaml
     - "--certificatesresolvers.xyz.acme.httpchallenge=true"
     - "--certificatesresolvers.xyz.acme.httpchallenge.entrypoint=web"
     - "--certificatesresolvers.xyz.acme.email=my email addy"
     - "--certificatesresolvers.tde.acme.storage=/letsencrypt/xyz.json"
```

These are for ACME/Let's Encrypt. I'm a fan of the HTTP challenge, it seems like the easiest thing to set up and maintain in my opinion (it's literally just these commands for each domain I want to secure).

Since the HTTP challenge is over HTTP, we want the entrypoint to be my configured web entrypoint (as opposed to websecure, which is HTTPS).

The email command is just my email address so when the renewal comes up, I get the notification.

The storage command is just a mounted folder from the host that Docker is running on in the event something bad happens to the host, like I delete it or something - I can quickly get up and running again. /letsencrypt is a mounted NFS share frrom Digital Ocean that's backed up.

### Service Config

```yaml
    blog:
      image: "ghost:3.27-alpine"
      restart: always
      volumes:
        - /docker/ghost/:/var/lib/ghost/content
      environment:
        - url=http://www.roylarsen.xyz
      ports:
        - "2368:2368"
      labels:
        - "traefik.enable=true"
        - "traefik.http.routers.blog-http.entrypoints=web"
        - "traefik.http.routers.blog-http.rule=Host(`roylarsen.xyz`) || Host(`www.roylarsen.xyz`)"
        - "traefik.http.routers.blog-http.middlewares=blog-https"
        - "traefik.http.middlewares.blog-https.redirectscheme.scheme=https"
        - "traefik.http.routers.blog.entrypoints=websecure"
        - "traefik.http.routers.blog.rule=Host(`roylarsen.xyz`) || Host(`www.roylarsen.xyz`)"
        - "traefik.http.services.blog.loadbalancer.server.port=2368"
        - "traefik.http.routers.blog.tls.certresolver=xyz"
```

Above is how I'm exposing the container hosting my Blog.

```
  "traefik.enable=true"
```

This is how to enable/expose each service as mentioned above.

```yaml
    - "traefik.http.routers.blog-http.entrypoints=web"
    - "traefik.http.routers.blog-http.rule=Host(`roylarsen.xyz`) || Host(`www.roylarsen.xyz`)"
    - "traefik.http.routers.blog-http.middlewares=blog-https"
    - "traefik.http.middlewares.blog-https.redirectscheme.scheme=https"
```

These lines are how to enable the HTTP listener for the domains I want my blog to answer on, and then redirect to HTTPS (since things should only be served over HTTPS, but I don't want errors over HTTP).

```yaml
    - "traefik.http.routers.blog.entrypoints=websecure"
    - "traefik.http.routers.blog.rule=Host(`roylarsen.xyz`) || Host(`www.roylarsen.xyz`)"
    - "traefik.http.services.blog.loadbalancer.server.port=2368"
    - "traefik.http.routers.blog.tls.certresolver=xyz"
```

After we accept the request from the HTTP listener, we need a place to redirect to (also just straight just to HTTPS).

The biggest differences between the two are the loadbalancer forward and the certresolver.

The loadbalancer is just where requests are sent on the backend, and then the certresolver is just what resolver to pull the certificate from in the Traefik config from the previous section.

### That's It {#that-s-it}

Seriously. It was pretty easy overall to be able to swap from Nginx to Traefik (except when I forgot the url for the admin panel to write this, heh), and now I don't have to think about my cert renewals for the rest of the life of this server. It's all very exciting.

</p>
