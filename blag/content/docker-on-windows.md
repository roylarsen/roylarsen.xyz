Title: Docker on Windows
Date: 2018-09-12 17:31
Author: roy.
Tags: docker, windows, devops
Slug: docker-on-windows

<!--kg-card-begin: markdown-->

This is a thing I've beeen doing at work. Partly because I've been learning docker on my own time, and partly because it'll make deploying our chatbot code easier.

</p>

A lot of this is going to be copy and pasted from the wiki article I wrote about Docker on Windows.

</p>

I'm not going to get into what are containers and what Docker is, so, a certain level of knowledge is assumed. Smarter people who are better writers have already done that and those articles are easy to find.

</p>

### Background

</p>

So, there's a few things that we need to address first.

</p>

1.  Docker on Server 2016 is *very* different than Docker on Windows 10
2.  Everything in this doc is assumed Server 2016
3.  When did MS perform the dark ritual to get Docker working on Windows?

</p>

Docker on Server 2016 is a native feature that doesn't rely on running Hyper-V or anything, u like Windows 10. You install it just like you install any other Windows Feature.

</p>

Once the feature is installed, you're pretty much off to the races. There's no configuration or anything to do.

</p>

The only thing that you'll probably want to do once the features are installed is installing compose. Don't worry, it's not hard and I have the instructions for that.

</p>

### The Set-Up {#thesetup}

</p>

The version of Server 2016 doesn't matter that much. I've done this with both core installs, and full desktop environments.

</p>

To prep the server for Docker for Windows:

</p>

    Install-Module -Name DockerMsftProvider -Repository PSGallery -ForceInstall-Package -Name docker -ProviderName DockerMsftProviderRestart-Computer -force

</p>

Once those lines are run, you can test your installation now:

</p>

    docker run microsoft/dotnet-samples:dotnetapp-nanoserver

</p>

At this point, you should have a working Docker install.

</p>

Docker is great, but you also probably want docker-compose so that you can have something useful to run things with:

</p>

    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12Invoke-WebRequest "https://github.com/docker/compose/releases/download/1.22.0/docker-compose-Windows-x86_64.exe" -UseBasicParsing -OutFile $Env:ProgramFiles\docker\docker-compose.exe

</p>

Powershell is kinda annoying, and you have to force it to use TLS 1.2 in order to interact with sites that have a proper HTTPS set-up.

</p>

The the download is pretty straight forward. Substitute the version of compose for the version that you want. The -usebasicparsing flag just makes it go a bit quicker.

</p>

Usage
-----

</p>

Now that docker and compose are installed on your system, you can pretty much use them as you would on Linux systems.

</p>

The big things to remember when using Docker is that you can only run containers of the same OS on the host. For Windows, there are two base containers that you can use:

</p>

<https://hub.docker.com/r/microsoft/windowsservercore/> - This is about \~4GB for a container  

<https://hub.docker.com/r/microsoft/nanoserver/> - This is about \~2GB for a container, but you can't use insallers

</p>

Docker on Windows is cool and makes life easier, but for all of the sacrifices to the Dark Lord, the reality of life in Windows is that the network stack is garbage.

</p>

The workflow that I've been working with for a bit is having the Dockerfile and docker-compose.yml in my git repo for our project, then run the compose for deployments.

</p>

I haven't gotten around to using container registries yet, but that's the next improvement I plan on making. Have the container build process be part of a CI pipeline and automatically build and push the container when done. Currently I'm just cloning the git repo and building and running the container from our host.

</p>

<!--kg-card-end: markdown-->
