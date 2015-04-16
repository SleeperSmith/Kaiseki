param(
    [string]$target,
    [string]$username,
    [string]$password,
    [string]$xmlsuffix
)

$deploycmds = Get-ChildItem -Path .\CiArtefact -File -Recurse -Filter Site.Deploy.cmd

$deploycmds | % {
    Push-Location $_.Directory.FullName
    .".\Site.Deploy.cmd" /Y /M:$target /U:$username /P:$password -setParamFile:Site.SetParameters.$xmlsuffix.xml
    Pop-Location
}
