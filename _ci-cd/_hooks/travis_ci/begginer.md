Core Concepts for Beginners

    What Is Continuous Integration?
    CI Builds and Automation: Build, Test, and Deploy
    Builds, Stages, Jobs, and Phases
    Broken Builds
    Infrastructure and Environment Notes

Welcome to Travis CI! This page provides some contexts and terminologies used throughout the platform and documentation, which might be helpful, if you are new here or new to Continuous Integration (CI).
What Is Continuous Integration? #

Continuous Integration is the practice of merging in small code changes frequently - rather than merging in a large change at the end of a development cycle. The goal is to build healthier software by developing and testing in smaller increments. This is where Travis CI comes in.

As a continuous integration platform, Travis CI supports your development process by automatically building and testing code changes, providing immediate feedback on the success of the change. Travis CI can also automate other parts of your development process by managing deployments and notifications.
CI Builds and Automation: Build, Test, and Deploy #

When you run a build, Travis CI clones your GitHub repository into a brand-new virtual environment, and carries out a series of tasks to build and test your code. If one or more of those tasks fail, the build is considered broken. If none of the tasks fail, the build is considered passed and Travis CI can deploy your code to a web server or application host.

CI builds can also automate other parts of your delivery workflow. This means you can have jobs depend on each other with Build Stages, set up notifications, prepare deployments after builds and many other tasks.
Builds, Stages, Jobs, and Phases #

In the Travis CI documentation, some common words have specific meanings:

    build - a group of jobs that run in sequence. For example, a build might have two jobs, each of which tests a project with a different version of a programming language. A build finishes when all of its jobs are finished.
    stage - a group of jobs that run in parallel as part of a sequential build process composed of multiple stages.
    job - an automated process that clones your repository into a virtual environment and then carries out a series of phases such as compiling your code, running tests, etc. A job fails, if the return code of the script phase is non-zero.
    phase - the sequential steps of a job. For example, the install phase, comes before the script phase, which comes before the optional deploy phase.

Broken Builds #

The build is considered broken, when one or more of its jobs complete with a state that is not passed:

    errored - a command in the before_install, install, or before_script phase returned a non-zero exit code. The job stops immediately.
    failed - a command in the script phase returned a non-zero exit code. The job continues to run until it completes.
    canceled - a user cancels the job before it completes.

Our Common Builds Problems page is a good place to start troubleshooting why your build is broken.
Infrastructure and Environment Notes #

    Travis CI will stop support for macOS starting March 31st, 2025.

Travis CI offers a few different infrastructure environments, so you can select the setup that suits your project best:

    Ubuntu Linux - these Linux Ubuntu environments run inside full virtual machines, provide plenty of computational resources, and support the use of sudo, setuid, and setgid. Check out more information on the Ubuntu Linux Build Environment.
    macOS - uses one of several versions of the macOS operating system. This environment is useful for building projects that require macOS software, such as projects written in Swift. It is not a requirement to use the macOS environment, if you develop on a macOS machine. Here you can find more details on the macOS Build Environment.
    Windows - currently Windows Server version 1803 is supported. If you want to know more about it, see the Windows Build Environment.
