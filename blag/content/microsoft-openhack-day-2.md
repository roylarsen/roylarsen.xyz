Title: Microsoft OpenHack - Day 2
Date: 2019-05-09 04:11
Author: roy.
Tags: ci, k8s, microsoft, docker, nodejs, devops
Slug: microsoft-openhack-day-2

<!--kg-card-begin: markdown-->

Where did we leave off yesterday? Oh yeah, Challenge 3.

</p>

Challenge 3 is where we start really seeing the pipelines in Azure DevOps (ADO) come together.

</p>

Side note: Days 2 and 3 I wasn't feeling super great, so starting this day, we have less screenshots.

</p>

Since we got one of the test pipelines working the end of the day before, that gave us a good starting point for getting all our other testing working.

</p>

![Screen-Shot-2018-11-28-at-12.18.17-PM](http://www.roylarsen.xyz/content/images/2018/12/Screen-Shot-2018-11-28-at-12.18.17-PM.png)

</p>

The above is where I ended up for Challenge 3 with the node.js API.

</p>

The pipeline started with getting the sources, building the container, then pushing it to ACR.

</p>

We needed to add running tests, verifying the tests, and then acting based on the outcome of the tests.

</p>

The nice thing about modern languages, is that they provide all the tools you need to do things like running tests in the same binary as what you use to run your scripts.

</p>

Now that's out of the way, lets start pulling that screen shot apart, job by job.

</p>

-   Get Sources
    </p>

    -   This is pretty straightforward. This preps the build environment for the current code base (git pull)

    </p>
-   npm install
    </p>

    -   This is also pretty straightforward. This will install the npm tooling and project dependencies

    </p>
-   npm custom
    </p>

    -   This is where the testing happens. ADO only gives two two jobs options (this is what I'm rembering seeing a few days later) and those are the npm install command and a 'custom' command to let you use the other npm tools
    -   The custom command in this intance is just for running npm test in the root of the node.js API

    </p>
-   Publish Test Results
    </p>

    -   This was me going a little above and beyond
    -   I was having some issues running my npm test command (because I don't know npm or node.js) and wasn't getting the debugging output I needed to figure out the problem
    -   This just takes the .xml output of the test results and puts it in the pipeline output so you can see the results with more output

    </p>
-   Build an Image
    </p>

    -   This is the same as it was before, it just builds the docker image from the accompanying Dockerfile

    </p>
-   Push an Image
    </p>

    -   Again, unchanged from before. This just pushes the container to the ACR on a successful build

    </p>
-   Publish Artifact helm
    </p>

    -   This is new and unneeded (for this challenge). All this does is take the /helm/ folder and publush it as a artifact to be shared in downstream pipelines

    </p>

</p>

Now, the next question should be: What about the second part of the challenge posted in the previous article? Creating a work ticket based on problems in this pipeline?

</p>

It was literally a toggle in the options for build pipelines. Between that and making sure that jobs are set to "run only if the previous job succeeded", that will keep the pipelines from moving bad code down the line.

</p>

Challenge 4)

</p>

Create a release pipeline!

</p>

(this was after lunch where I started feeling way worse than before lunch and I started forgetting to take screenshots)

</p>

So, a lot of this is a lot like setting up the build pipelines. When you have your pipelines defaulted to the drag and drop it's pretty straight-forward.

</p>

When you're building pipelines in ADO, it's mostly dragging and dropping the tools you need to where you need them. For Release Pipelines, the main difference is that they go horizontal as opposed to vertical.

</p>

Our release pipeline was roughly:  

\|Artifact\| -\> \| Stage 1 \|

</p>

(I know, my ASCII drawing is *too* good)

</p>

-Long time ago post-

</p>

So, during this day I started feeling ill and I kinda dropped this (oops). There's not much for Day 3 since it was mostly trying to get these tasks done.

</p>

I was also still not feeling well, so I actually don't remember much beyond closing things out/

</p>

<!--kg-card-end: markdown-->
