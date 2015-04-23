Extensibility Points
----
There are are a few points in Kaiseki where you can extend the build repertoire.
### Custom Tasks ###
As part of the build process, when Load-Modules.ps1 is invoked, all Task-*.ps1 are invoked. This facilitates the loading of custom defined tasks.

To actually invoke the task, modify the .\kaiseki-bootstrap\build.ps1 and supply a list of tasks through the "tasklist" parameter; for example:
```
.\packages\psake.x.x.x\tools\psake.ps1 .\packages\Kaiseki.x.x.x\tools\Load-Modules.ps1 -tasklist Execute-MsBuild,Copy-NUnit
```
This place also allows you to pass in additional parameters and properties. For full documentation, please visit [PSake](https://github.com/psake/psake)

###Extra assets to be user in later pipeline stages###
Kaiseki automatically scans the nuget packages for folders that starts with "kkm-" and copies those folders into the CiArtefact folder. One such example is the "kkm-defaults" folder that comes with Kaiseki which facilitate recursive WebDeploy, NUnit testing with target category, recursive nuget package publishing.
