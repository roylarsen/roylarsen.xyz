Title: So I decided to containerize our application stack... Pt 2
Date: 2019-06-12 04:01
Author: roy.
Tags: mobileheartbeat, docker, devops, sqlserver, series
Slug: so-i-decided-to-containerize-our-application-stack-pt-2

<!--kg-card-begin: markdown-->

Here's the story so far:

</p>

-   [Part 1](https://www.roylarsen.xyz/so-i-decided-to-containerize-our-application-stack/)

</p>

Beginning to work through my list {#beginningtoworkthroughmylist}
---------------------------------

</p>

In the last post I came up with a list of tasks that I need to work through so that we can do things in Docker "correctly".

</p>

("Correctly" meaning, as close to "dev clones the repo, fills in their .env, then runs docker-compose")

</p>

### Getting SQL Server to work in Docker on Linux {#gettingsqlservertoworkindockeronlinux}

</p>

It's funny, this was actually pretty straight-forward. Faults aside over the years, Microsoft has been putting a lot of effort into building compatibility from their flagship products and also transitioning from a traditional software company to a platform company, and transitioning a lot of their major software to either being a SaaS offering (Outlook/O365) or making it run on Linux (SQL Server, Powershell) as well.

</p>

Running SQL Server is pretty easy, MS has good guides on SQL Server running on Linux on technet: <https://docs.microsoft.com/en-us/sql/linux/quickstart-install-connect-docker?view=sql-server-2017&pivots=cs1-bash>

</p>

It's super easy and all you really need to do is provide the password for the SA account as an environment variable.

</p>

### Running Flyway migrations {#runningflywaymigrations}

</p>

Everything's easier when the vendor makes docker images easily available and usable.

</p>

Now, this is still a little tricky, because while the repo that has all our application code also has all our migrations, it's more than one migration and the flyway container comes expecting to be run via `docker run` and just providing arguments to the migrate command.

</p>

That doesn't really work for me.

</p>

There's a couple of issues that I needed to overcome to get this service in my compose file working:

</p>

1.  I need the two databases the application expects
2.  I need to run the two migrations for our databases

</p>

By the time this service starts/runs, all I have is a bare SQL Server instance with no databases or accounts other than the default ones.

</p>

Normally, to create the two databases that our application needs, I just use sqlcmd or Invoke-SQLCmd, but this container doesn't have the first command and these are Linux containers and not Windows - so no Invoke-SQLCmd.

</p>

I started thinking about how (since I'm already using it in this container) I could abuse Flyway - since all it does is run specially named .sql files.

</p>

So, the first thing I did was create a new migration to do the initial Database creation. It was pretty straightforward since in the repo, there was already a script to create the base databases, I just needed to name it correctly (eg, VO\_\_createDB.sql, and write the config file for this migration)

</p>

However, since this adds to the complexity of the problem, I need to update the above list:

</p>

1.  I need the two databases the application expects
2.  I need to run the ~~two~~ three migrations for our databases

</p>

Luckily, point two are why shell scripts exist.

</p>

I threw together a [really basic shell script](https://gist.github.com/roylarsen/80eb8c536b1d391c0a18992a4b669263) to run three flyway migrations. It's nothing fancy, but at the end of the day, it didn't need to be.

</p>

Now, the fun thing was trying to figure out how to overwrite the container's command and inject my shell script.

</p>

The nice thing is that Compose gives you exactly that.

</p>

    entrypoint: /flyway/mh-scripts/mh-run-migrations.sh

</p>

The 'entrypoint' option just overrides the CMD of the container. In my case, giving me a one off container that runs the migrations.

</p>

### Building and running the Tomcat Application {#buildingandrunningthetomcatapplication}

</p>

First and foremost, shoutout to [Sammy](https://twitter.com/samstelfox) for telling me about this.

</p>

My goal was to be able to have one Dockerfile to handle doing both the build, and also running the application.

</p>

Luckily, these days Dockerfiles have multi-stage builds (thanks for pointing that out, Sammy).

</p>

[Dockerfile](https://gist.github.com/roylarsen/55e47e2e3b9e9fab2cf8be4f71955751)!

</p>

The important parts of this are the following:

</p>

    FROM gradle:5.4-jdk8 as build

</p>

The first FROM line sets up the stage to copy artifacts from. In my instance, I can refer to it as 'build'.

</p>

The next important thing is the change to the COPY command.

</p>

    COPY --from=build /home/gradle/project/heartbeatWeb/build/libs/heartbeat.war /usr/local/tomcat/webapps

</p>

The important part of this is the --from= argument. Normally, you use COPY to copy from the host to the container. When using the from argument, you can specify the first step and copy artifacts from that container instead.

</p>

### Wiring everything up in Docker {#wiringeverythingupindocker}

</p>

I'm not up to doing anything particularly fancy yet (separate netoworks for separation of concerns or anything, so a basic network configuration in compose is more than enough.

</p>

    networks:    default:

</p>

That's more than enough to get all the containers into a state where they can talk.

</p>

Example:

</p>

    web:        build: .        links:            - db        ports:            - "80:8080"        environment:            - JAVA_OPTS=$JAVA_OPTS -Ddbserver=db        depends_on:            - flyway_migrate

</p>

This is the last container. From here, we see the links to the DB service, the the dependency on running the database migrations.

</p>

The default network is enough that you can address containers by their service name (see the -Ddbserver arg for the environment above).

</p>

Now, I can't stress this enough, this set up **isn't** for production. Everything is accessible. In the future, one of my items will be to separate internal services and external services, and to put things behind a proper proxy service (probably something like HAProxy, maybe Traefik if that can handle non-http traffic).

</p>

### Task List Update {#tasklistupdate}

</p>

I did everything in my old task list, now I need a new one!

</p>

-   Our Event Management Service
-   Ejabberd
-   Maybe clustered Ejabberd
-   ActiveMQ
-   Redis

</p>

<!--kg-card-end: markdown-->
