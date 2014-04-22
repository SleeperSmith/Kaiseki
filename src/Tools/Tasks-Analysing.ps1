task Execute-Gendarme {
    $gendarmeToolsPath = ".\packages\Mono.Gendarme.2.11.0.20121120\tools\"
    # If rule.xml do not exist, copy it over.
    if (Test-Path .\rules.xml) {
        Write-Host "> No .\rules.xml found. Copying default one over"
        Copy-Item ".\rules.xml" "$gendarmeToolsPath\rules.xml" -Force
    }

    # This is defined in the nuspec.
    $gendarmeBin = "$($gendarmeToolsPath)gendarme.exe"
    $gendarmeOutPath = $OutputPath + "\Gendarme.xml"
    $rulesXml = "rules.xml"

    Get-ChildItem *.csproj -Recurse | %{

        $searchDirectory = Resolve-Path $_.Directory.FullName -Relative

        # Open up .csproj xml and find assmebly name.
        [xml]$projectXml = Get-Content $_
        $assemblyName = $projectXml.Project.PropertyGroup.AssemblyName
        $assemblyName = $assemblyName.GetValue(0)

        # Get the path to assembly relative to the solution root.
        # This is done because absolute path containing spaces cause error.
        $assembly = (Get-ChildItem "$searchDirectory\bin\**\$assemblyName.dll" -Recurse)[0]
        $assemblyRelativePath = (Resolve-Path $assembly.FullName -Relative).Replace(".\", "")

        Write-Host "> Analysing: $assemblyRelativePath"
        $dllSpecificOut = $gendarmeOutPath.Replace(".xml", ".$assemblyName.xml")
        Write-Host "> Analysis Result: $dllSpecificOut"

        &$gendarmeBin $assemblyRelativePath --xml $dllSpecificOut > (Out-Null)
    }
}

properties {
    $VscmBin = "C:\Program Files (x86)\Microsoft Visual Studio 12.0\Team Tools\Static Analysis Tools\FxCop\metrics.exe"
}
task Execute-VisualStudioCodeMetrics -precondition {

    Write-Host "?Execute-VisualStudioCodeMetrics?"

    $vscmExist = Test-Path $VscmBin
    if ($vscmExist) {
        Write-Host "> Visual Studio Code Metrics Tools found at:"
        Write-Host "> $VscmBin"
        return $true
    }
    Write-Host "> Visual Stduio Code Metrics analysist exe file not found."
    Write-Host "> Default: $VscmBin"
    Write-Host "> Please download at: http://www.microsoft.com/en-au/download/details.aspx?id=41647"
    return $false

} {

    $vscmOutPath = $OutputPath + "\Vscm.xml"

    Get-ChildItem *.csproj -Recurse | %{

        $searchDirectory = Resolve-Path $_.Directory.FullName -Relative

        # Open up .csproj xml and find assmebly name.
        [xml]$projectXml = Get-Content $_
        $assemblyName = $projectXml.Project.PropertyGroup.AssemblyName
        $assemblyName = $assemblyName.GetValue(0)

        # Get the path to assembly relative to the solution root.
        # This is done because absolute path containing spaces cause error.
        try {
            $assembly = (Get-ChildItem "$searchDirectory\bin\**\$assemblyName.dll" -Recurse)[0]
            $assemblyRelativePath = (Resolve-Path $assembly.FullName -Relative).Replace(".\", "")

            Write-Host "> Analysing: $assemblyRelativePath"
            $dllSpecificOut = $vscmOutPath.Replace(".xml", ".$assemblyName.xml")
            exec { &$VscmBin /f:$assemblyRelativePath /o:$dllSpecificOut /gac }
            Write-Host "> Analysis Result: $dllSpecificOut"
        } catch {
        }

    }

    # Apparently build fails if nothing exist.
    Get-ChildItem "$($vscmOutPath.Replace(".xml",".*.xml"))" -File -Recurse | ? {
        $_.Length -eq 0
    } | % {
        Write-Host "> Removing: $($_.Name)"
        return $_
    } | Remove-Item -Force
}

task Execute-PreBuildAnalysis #-depends DryAnalysis,CcmAnalysis,StyleCopAnalysis
task Execute-PostBuildAnalysis -depends Execute-VisualStudioCodeMetrics,Execute-Gendarme