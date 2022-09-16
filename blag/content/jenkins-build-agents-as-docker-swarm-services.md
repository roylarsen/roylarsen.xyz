Title: Jenkins Build Agents as Docker Swarm Services
Date: 2019-09-25 20:07
Author: roy.
Tags: docker, jenkins, mobileheartbeat, devops, swarm
Slug: jenkins-build-agents-as-docker-swarm-services

Lately I've been working on (re-)learning Jenkins and learning how to use their Pipelines feature.

We had set up a Jenkins server at MHB to off-load some of the potential work from Bamboo, and also just because we're trying as a DevOps team to move away from Bamboo since we're not too happy with it.

------------------------------------------------------------------------

### Docker Swarm

First, let's address the ten thousand pound elephant in the room: Docker Swarm is less cool than Kubernetes.

For small, easy to set up/manage Docker clusters on-prem, Docker Swarm is fine and perfectly serviceable. The automatic load balancing of published ports to all nodes/manager by default is really slick.

That being said, not everything is great. For this to work, you need to expose the Docker Swarm API and to do that is fairly ugly. I'm not going to get into securing it, since this is a lab set-up.

Exposing the swarm in an insecure manner is fairly straight-forward. Find the systemd unit file and add this to the end of the ExecStart line and then restart the service: -H tcp://0.0.0.0:2375

### Jenkins Service

Here's my docker-compose.yml I used to deploy this:

```yaml
    version: '3'
    services:  jenkins:
    image: jenkins/jenkins
    ports:
      - 8080:8080
      - 50000:50000
    restart: always
    volumes:
      - /usr/bin/docker:/usr/bin/docker
    environment:
      - "JENKINS_SLAVE_AGENT_PORT=50000"
```

Beyond the Docker/Swarm stuff, I'm not getting into Jenkins configuration. There's plenty of documentation that exists for general Jenkins configuration and usage.

I can't stress this isn't a production service. Nothing is persistant.

### Jenkins Docker Swarm Plug-In

The next two sections are the most annoying. The documentation is definitely lacking when it exists.

To enable Docker Swarm access in Jenkins, you need to install 'Docker Swarm Plugin' and then reload Jenkins.

That adds a couple things to Jenkins. First and foremost, the Docker Swarm Dashboard:

![Screenshot of Jenkins console showing Docker Swarm Dashboard](http://www.roylarsen.xyz/content/images/2019/09/Screen-Shot-2019-09-25-at-3.31.31-PM.png){.kg-image}

Then the more important thing, in Manage Jenkins -\> Configure System, at the bottom there's an option for Adding a Cloud:

![Screenshot of Jenkins console showing configuration for adding Docker Swarm Cloud](http://www.roylarsen.xyz/content/images/2019/09/Screen-Shot-2019-09-25-at-3.34.16-PM.png){.kg-image}

The configuration for that is pretty straight forward:

![Ignore the 403's, I obviously changed the FQDNs](http://www.roylarsen.xyz/content/images/2019/09/Screen-Shot-2019-09-25-at-12.15.36-PM.png){.kg-image}

The 'Test' button is a little flaky from what I've seen, you might need to save your configuration before it will succeed.

### Jenkins JNLP Agents

This was the most interesting part. And by interesting, I mean frustrating. This is where the documetation was really lacking and I happened to find a blog post with a quick explanation of how this all works.

When you configure your cluster above, you get a button to add templates:

![](http://www.roylarsen.xyz/content/images/2019/09/Screen-Shot-2019-09-25-at-3.53.10-PM.png){.kg-image}

Clicking that button gives you this:

![Overall, very cool, with caveats](http://www.roylarsen.xyz/content/images/2019/09/Screen-Shot-2019-09-25-at-12.13.04-PM.png){.kg-image}

The label is what you can use for targetting, the image is the Docker Container to pull from. They actually provide a bunch of containers to use: <https://github.com/jenkinsci/jnlp-agents>

The docker image is different from the other containers and works as documented/is fine with the example configuration. The general idea on how it's supposed to work is that when the container starts, it does a curl to the Jenkins master and downloads the JNLP agent to ensure there's no version mis-matches.

As far as I can tell, none of the other agent images work that way. They're all based on their languages/toolsets alpine image and don't have tools like curl or git installed, but in the Dockerfile, Jenkins copies the agent .jar from the base JNLP agent image.

jnlp-docker command:

```
    sh -cx curl --connect-timeout 20 --max-time 60 -o agent.jar $DOCKER_SWARM_PLUGIN_JENKINS_AGENT_JAR_URL && java -jar agent.jar -jnlpUrl $DOCKER_SWARM_PLUGIN_JENKINS_AGENT_JNLP_URL -secret $DOCKER_SWARM_PLUGIN_JENKINS_AGENT_SECRET -noReconnect -workDir /tmp
```

jnlp-python command:

```
    sh -cx apk -u add git && java -jar /usr/share/jenkins/agent.jar -jnlpUrl $DOCKER_SWARM_PLUGIN_JENKINS_AGENT_JNLP_URL -secret $DOCKER_SWARM_PLUGIN_JENKINS_AGENT_SECRET -noReconnect -workDir /tmp
```

It took a bit of debugging and digging to figure out what was different between the two container images and figure out why my Docker container was working but my Python container wasn't.

The other big 'gotchas' I ran into is that the container needs to be run as root, or it will fail to launch. For Docker, you also need to make sure you mount /var/run/docker.sock from the host into the container so the Docker client in the container has a Docker daemon to work against.

### Jenkinsfile

```
    pipeline{
      agent {
        label 'jenkins-docker'
      }
      stages {
        stage('Print Test'){
          agent {
            label 'jenkins-docker'
          }
          steps {
            sh "uname -a"
            sh "docker run hello-world"
          }
        }
        stage('Schedule Tests'){
          agent {
            label 'jenkins-python'
          }
          steps{
            sh 'python --version'
            sh 'ls .'
            sh 'printenv'
          }
        }
      }
    }
```

The above Jenkinsfile is a working example where I have the agents for the Pipeline level, and each stage (the job spawns as the first agent, then that spawns the agents for each of the stages).

![Jobs running, agents in various stages](http://www.roylarsen.xyz/content/images/2019/09/Screen-Shot-2019-09-25-at-2.03.09-PM.png){.kg-image}

I'm not going to get into setting up builds on API calls, again, that gets into Jenkins documentation that is good and there's plenty of.

------------------------------------------------------------------------

Hopefully this helps. It'll be nice to have this reference for myself in the future.

</p>
