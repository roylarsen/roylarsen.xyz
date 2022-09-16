Title: Ghost + NGINX + Docker, OH MY
Date: 2018-07-10 04:47
Author: roy.
Tags: docker, devops, cloud
Slug: ghost-nginx-docker-oh-my

<!--kg-card-begin: markdown-->![Ghost + NGINX + Docker, OH MY](http://www.roylarsen.xyz/content/images/2018/07/It-s_a_mystery.png)

So, I recently decided to redo my website and this is a active work in progress.

</p>

Enter:

</p>

### DOCKER

</p>

~WHAAAAAA~

</p>

I've been using this as an excuse to finally get my shit together and actually learn Docker.

</p>

Up until now I've done basic docker work (docker run hello-world, etc...), but I haven't done anything particularly serious with it.

</p>

I'm not going to get into details and explain the internals and how docker works. I'm not super great at that, plus, there ware way smarter people who've beaten that horse to death.

</p>

### Putting it together {#puttingittogether}

</p>

So, after some furious research (aka, typing the words "docker", "ghost", and "blog" into google) I found their official docker image.

</p>

I then went and set up a new VM in DigitalOcean to act as my docker host with a external volume to hold all the persistent data (blog DB, config info for nginx, etc...) so that all can be easily backed up and I don't have to worry about it.

</p>

At first, my set-up was kinda clunky. I was building containers and running those with all the static content (tastefuldinosaurerotica.com, keybase challenge) pre-baked into the container. For simple set-ups that don't change - this is fine for the most part.

</p>

Here was the initial Dockerfile I was using to run nginx:

</p>

    FROM nginxMAINTAINER Roy LarsenCOPY nginx.conf /etc/nginx/nginx.confCOPY keybase.txt /usr/share/nginx/htmlCOPY tde/* /usr/share/nginx/html/tde/

</p>

See? Not very exciting, not very portable/maintainable since now I need to maintain my own container that only exists on this one server.

</p>

Part of the portability, maintainability problem was was made this blog possible: a container running ghost.

</p>

So, now I have two containers that are essentially running the default software and I'm re-building at least one of them.

</p>

### Enter Compose: {#entercompose}

</p>

So, the first big change that I made was create a symlink on the host to be what the containers expect for their persistent storage instead of building the containers with the static content inside of them.

</p>

Here's how I'm now defining my containers:

</p>

    version: "2.2"services:        nginx:               image: "nginx:latest"               ports:                        - "80:80"                        - "443:443"               volumes:                       - /docker/nginx/conf/nginx.conf:/etc/nginx/nginx.conf                       - /docker/nginx/www:/usr/share/nginx/html               networks:                        - default               links:                       - "blog"        blog:                image: "ghost:1-alpine"                volumes:                        - /docker/ghost/:/var/lib/ghost/content                environment:                        - URL=http://www.roylarsen.xyz                networks:                        - defaultnetworks:        default:                external:                        name: web

</p>

When that file is in place, all you need to do is sudo docker-compose up -d from that directory and you're good to go.

</p>

So, the nice thing about this is that when I want to tackle that first bullet point in Future, I can just have the container hosting certbot place the certs into the volume mapped to /docker/nginx/conf/certs and that will be that.

</p>

For portability, as long as the appropriate drive is mapped and symlink is created - I can always spin up these containers the same way every time. It's pretty sweet.

</p>

### Future:

</p>

-   ~~Let's Encrypt for doing SSL.~~ Ha, notice how this is served over HTTPS? Need to write that article
-   ~~<https://mastodon.social/>~~ Ha, <https://social.tastefuldinosaurerotica.com>. Need to write that up
-   Separating internal and external container networks.
-   Ansible to prep the host server
-   ~~Get more serious about Docker on Windows (I know: boo, hiss, etc...)~~ Ha, I wrote this

</p>

<!--kg-card-end: markdown-->
