param(
    [string]$server,
    [string]$password,
    [string]$nugetBinPath = ".\.nuget\NuGet.exe"
)

$nugetPackages = Get-ChildItem -Path .\CiArtefact -File -Recurse -Filter  *.nupkg

$nugetPackages | % {
    Write-Host "Pushing $($_.FullName)"
    ."$nugetBinPath" push "$($_.FullName)" -s $server $password
}