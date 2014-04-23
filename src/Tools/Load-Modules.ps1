Write-Host "## Loading Modules ##"

cd $psake.context.originalDirectory

Get-ChildItem Tasks-*.ps1 -Recurse -File | % {
    Write-Host Loading $_.Name
    Include $_
}

#Global properties
properties {
    $OutputPath = "CiOutput"
    # Hard code for now.
    $AssemblyVersion = "1.0.0.0"
}

Task Default -depends Clean,New-CsvOutputCollection,New-CiOutFolder,Transform-InjectBuildInfo,
    Execute-PreBuildAnalysis,Execute-MsBuild,Execute-PostBuildAnalysis,
    Execute-Nunit,
    New-NugetPackagesFromSpecFiles,Write-CsvOutputCollection

Write-Host "## Loading Modules > Done ##"
Write-Host
Write-Host