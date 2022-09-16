Title: Microsoft OpenHack - Day 1
Date: 2018-11-28 06:02
Author: roy.
Tags: azure, docker, k8s, ci, devops, microsoft
Slug: microsoft-openhack-day-1

<!--kg-card-begin: markdown-->

Lions, tigers, and Azure DevOps. Oh my!

</p>

Where to begin?

</p>

Recently my boss emailed myself and a couple other engineers at Mobile Heartbeat about an event Microsoft was running about learning Azure, Azure Kubernetes (k8s) Service, and Azure DevOps (silly name for an actually pretty cool project). Naturally, I took him up on the offer because it was free and was a training on stuff I'm interested in/not well versed in.

</p>

Alright, now the fun bit.

</p>

The task:

</p>

![Screen-Shot-2018-11-27-at-9.28.57-AM](http://www.roylarsen.xyz/content/images/2018/11/Screen-Shot-2018-11-27-at-9.28.57-AM.png)

</p>

That Architecture, but allowing for automatic rolling/zero downtime deployments of the 4 API microservices within the k8s cluster.

</p>

The event is setup in a pretty interesting way. The way that Microsoft set it up is as a series of challenges that build on the successes of the previous challenges.

</p>

When we got there this morning, they assigned everyone into different teams and after some moving me around, I settled into Team 11 with my first cup of coffee.

</p>

Challenge 1)

</p>

-   "In order to have a successful DevOps strategy, your team needs to have a plan."

</p>

The first challenge of the day, we needed to come up with a plan of how we want to run our team. Pretty basic, but it gave us a chance to work out how we like to work.

</p>

For the most part we decided that between tickets and the Wiki within Azure DevOps and the fact that we're sitting face to face, we don't need to worry about also adding some chat software into the mix.

</p>

Challenge 2)

</p>

-   Show to your coach that you can link a work item with the associated code changes and the artifacts that have been generated.
-   Demonstrate to your coach that you have implemented a policy to prevent any unreviewed code changes from being committed to master.
-   On a successful build, demonstrate that the updated version of the container is pushed to a container registry.

</p>

From here we created stories for each of these tasks, and then sub-divided them into actionable tasks.

</p>

The first thing we did was import the git repository from Github (<https://github.com/Azure-Samples/openhack-devops-team>), into Azure DevOps.

</p>

That allowed our team member working on task 2 to create the appropriate policies to institute mandatory code reviews where we need two reviewers that aren't the person who created the PR.

</p>

The rest of us tackled task 3. We broke that into feature tickets for each of the API services.

</p>

We were able to create build pipelines for each of the APIs.

</p>

Here's the Java Pipeline I worked on for example (there's an extra task, but I'll cover that in 3)

</p>

![Screen-Shot-2018-11-28-at-12.56.03-AM](http://www.roylarsen.xyz/content/images/2018/11/Screen-Shot-2018-11-28-at-12.56.03-AM.png)

</p>

On approved PR, the pipeline is kicked off for API folders that there's changes.

</p>

![Screen-Shot-2018-11-28-at-1.01.53-AM](http://www.roylarsen.xyz/content/images/2018/11/Screen-Shot-2018-11-28-at-1.01.53-AM.png)

</p>

Once these items were completed and we had containers building and being pushed to the correct repositories (there was a little confusion that was quickly cleared up), we then quickly took care of task 1 by putting everything together.

</p>

We created a couple tasks to run end to end tests of our new pipelines.

</p>

-   Create a ticket and associated branch from master
-   Make a change in our branch and create a PR to master
-   Get the required amount of approvals (2 minimum, can't be the person who created the PR) which then kicked off the pipeline
-   As soon as Azure DevOps saw the PR had the correct approvals, the build was automatically started

</p>

Challenge 3)

</p>

-   </p>

    You are expected to improve the pipeline that you have started to build in the previous challenge by validating the functionality of at least one part of the code for the APIs of your application that you have selected.

    </p>
-   </p>

    In the event that a test fail, a bug shall be created automatically and added in the backlog and the submitted changes are not integrated in your code.

    </p>

</p>

When the second challenge was accepted by our coach, we got to work on 3. Overall, it's not that complicated of a challenge - but when you're sitting at a table of non-developers, unit tests become tricky.

</p>

So, first thing I did was create stories for the two main tasks and start splitting those into features and issues.

</p>

Luckily, the APIs all already had their test suites written and had jobs in their various build systems ready to go, so all we had to do was add a task before the docker image build.

</p>

The hardest one to get going was the C\# project, because each of the APIs had documentation in the README.md about how tests are run - that project didn't.

</p>

After some trial and error, we had that pipeline ready to go and it was 4:30 and time to go.

</p>

Tomorrow is Day 2 and we're starting off strong and getting task 3 finished.

</p>

<!--kg-card-end: markdown-->
