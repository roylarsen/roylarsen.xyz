Title: So I decided to containerize our application stack...
Date: 2019-05-12 17:28
Author: roy.
Tags: docker, mobileheartbeat, tomcat, linux, devops, work, series
Slug: so-i-decided-to-containerize-our-application-stack

<!--kg-card-begin: markdown-->

This is going to be the first part of a series of posts where I'm going to document my journey containerizing our Platform.

</p>

Here's the story so far:

</p>

-   [Part 2](https://www.roylarsen.xyz/so-i-decided-to-containerize-our-application-stack-pt-2/)

</p>

First Forays {#firstforays}
------------

</p>

The beginning of this journey was extremely haphazard (aka, I was bored one night and wanted something to work on while watching TV). For fun I spun up a Server 2016 box with our software installed on it and set up [Docker on Windows](https://www.roylarsen.xyz/docker-on-windows/) since (due to our Customers) our Platform is Windows first.

</p>

Once that was all done, I copied the .wars that make up our admin application and the distribution of tomcat that we use and threw all of that into a Dockerfile and spun it up to talk to the SQL Server instance installed on that box.

</p>

It was pretty cool to type `docker run` and connect to that tomcat instance and see it work. [Server 2016 Dockerfile](https://gist.github.com/roylarsen/14f0f87775e4d039e47d2c42002d0d87)

</p>

It's all fun to get this to work on Windows, but lets face it, Windows is a limiting factor when all the new developments in DevOps treats Windows as a Second Class Citizen at best.

</p>

Moving Forward {#movingforward}
--------------

</p>

Those first steps were done back in November of 2018 and I eventually picked this back up in May of 2019.

</p>

This is when I started to want to get more serious about my personal projects and wanting to learn more about containers and take learning Docker more seriously.

</p>

### Deploying our wars to linux {#deployingourwarstolinux}

</p>

This is where things get really fun.

</p>

With the help of my awesome co-worker Valerie answering my really basic questions, I got things working.

</p>

The nice thing about Java is the WORA (write once, run anywhere) principal it follows. For the most part the initial getting things working was a case of pulling the image for Tomcat 8.5.40 and building my container by writing another pretty basic Dockerfile. [Linux Dockerfile](https://gist.github.com/roylarsen/6c9bb232120e04ef913d20cae01e52a4)

</p>

After some trial and error and tracking down dependencies (jar with the SQL Server driver, a mail library) to get things working, I got a connection to an existing database on another server, and authentication via LDAP that was already pre-configured in that database.

</p>

Getting our webapps to work on Linux has been fun, because I'm getting to learn more about Tomcat. For the most part, the server.xml is a static entity but there are items that I want to be able to pass to the container as it starts up. Mainly the DB connection string and information.

</p>

That's where I learned how to use the \$JAVA\_OPTS to populate variables in the server.xml.

</p>

`docker run -it -p 80:8080 -e "JAVA_OPTS=$JAVA_OPTS -Ddbserver=sql1" --net test mhb/heartbeat:1.0`

</p>

Is what I've been using to launch the tomcat container with the environment variable to set the JAVA\_OPTS environment variable in the container.

</p>

With `-e "JAVA_OPTS=$JAVA_OPTS -Ddbserver=sql1"` option, that sets the \$JAVA\_OPTS environment variable in the container. Within the server.xml I have access to the dbserver variable that I can set with \${dbserver}.

</p>

The next iteration of this is going to involve learning the setenv.sh script so I can use environment files in my compose file so I can more securly set the variables.

</p>

### Coming up with a task list {#comingupwithatasklist}

</p>

Once I saw that working, I came up with a list of tasks to go from the most basic of POC to an actual MVP that I can show off and see what people think.

</p>

-   Get [SQL Server on Linux working in Docker](https://docs.microsoft.com/en-us/sql/linux/quickstart-install-connect-docker?view=sql-server-2017&pivots=cs1-bash)
-   Figure out how to run our [Flyway](https://flywaydb.org/) migrations in Docker
-   Wire everything up in docker
-   Perform builds and deploy to Docker
-   Docker Compose

</p>

Now I have a task list to work through

</p>

<!--kg-card-end: markdown-->
