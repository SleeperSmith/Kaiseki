Why?
----
Kaiseki aims to address the following points during the build step:

 1. Generation of the artifacts automatically; Web Deploy packages, test binaries, nuget packages
 2. Facilitate as many static analysis as possible.
 3. Automatic unit testing and coverage report generation.
 4. Prepare the artifacts in a multi-stage deployment pipeline friendly structure.
 5. Supply scripts to activate common tasks at later stage; WebDeploy, testing, pushing nuget packages, etc.
 6. All in PowerShell.

At an even higher level, Kaiseki basically aims to build any .Net solution with as much sophistication as possible while asserting as little effort as possible from the developers.