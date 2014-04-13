param($installPath, $toolsPath, $package, $project)

Copy-Item "$toolsPath\kaiseki-bootstrap\" -Destination "$installPath\..\.." -Force