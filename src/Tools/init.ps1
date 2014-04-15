param($installPath, $toolsPath, $package, $project)

Copy-Item "$toolsPath\kaiseki-bootstrap\" -Destination "$installPath\..\.." -Force

<#
# Get the open solution.
$solution = Get-Interface $dte.Solution ([EnvDTE80.Solution2])

# Create the parent solution folder.
$parentProject = $solution.AddSolutionFolder("Parent")

# Create a child solution folder.
$parentSolutionFolder = Get-Interface $parentProject.Object ([EnvDTE80.SolutionFolder])
$childProject = $parentSolutionFolder.AddSolutionFolder("Child")

# Add a file to the child solution folder.
$childSolutionFolder = Get-Interface $childProject.Object ([EnvDTE80.SolutionFolder])
$fileName = "D:\projects\MyProject\MyProject.csproj"
$projectFile = $childSolutionFolder.AddFromFile($fileName)
#>