param(
    [string]$target,
    [string]$username,
    [string]$password,
    [string]$xmlsuffix
)

$deploycmds = Get-ChildItem -Path .\CiArtefact -File -Recurse -Filter Site.Deploy.cmd

$deploycmds | % {
    Push-Location $_.Directory.FullName
    $params = @("/Y","/M:$target")

    if ($username -ne "") {
        $params += "/U:$username"
        $params += "/P:$password"
    }
    $params += "-setParamFile:Site.SetParameters.$xmlsuffix.xml"

    .".\Site.Deploy.cmd" $params
    Pop-Location
}
