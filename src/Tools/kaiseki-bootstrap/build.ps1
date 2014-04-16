Write-Host "######################"
Write-Host "## Starting Kaiseki ##"
Write-Host "######################"
Write-Host

Write-Host "== Restoring packages =="
.".\.nuget\NuGet.exe" restore

Write-Host "== Starting psake build =="
.\packages\psake.4.3.2\tools\psake.ps1 .\packages\Kaiseki.1.0.0\tools\Load-Modules.ps1

Write-Host
Write-Host "######################"
Write-Host "## Kaiseki Finished ##"
Write-Host "######################"