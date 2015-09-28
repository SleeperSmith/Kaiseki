task Execute-Gendarme {
    $gendarmeToolsPath = ".\packages\Mono.Gendarme.2.11.0.20121120\tools\"
    $replacingRulesXmlPath = ".\kaiseki-bootstrap\rules.xml"
    # If rule.xml do not exist, copy it over.
    if (Test-Path $replacingRulesXmlPath) {
        Write-Host "> No .\rules.xml found. Copying default one over"
        Copy-Item $replacingRulesXmlPath "$gendarmeToolsPath\rules.xml" -Force
    }

    # This is defined in the nuspec.
    $gendarmeBin = "$($gendarmeToolsPath)gendarme.exe"
    $rulesXml = "rules.xml"
    # Output Files
    $gendarmeXmlOutPath = $OutputPath + "\Gendarme.xml"
    $gendarmeHtmlOutPath = $OutputPath + "\Gendarme.html"

    $assemblies = (Get-CsprojAssemblies -filter ".*\.csproj") | % {
        $_.Fullname
    }

    &$gendarmeBin $assemblies --html $gendarmeHtmlOutPath --xml $gendarmeXmlOutPath > (Out-Null)
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
        if (Test-Path "$searchDirectory\bin\") {
            $assemblies = Get-ChildItem "$searchDirectory\bin\**\$assemblyName.dll" -Recurse
            if ($assemblies.Count -ne 0) {
                
                $assembly = $assemblies[0]
                $assemblyRelativePath = (Resolve-Path $assembly.FullName -Relative).Replace(".\", "")

                Write-Host "> Analysing: $assemblyRelativePath"
                $dllSpecificOut = $vscmOutPath.Replace(".xml", ".$assemblyName.xml")
                exec { &$VscmBin /f:$assemblyRelativePath /o:$dllSpecificOut /gac /assemblyCompareMode:StrongNameIgnoringVersion }
                Write-Host "> Analysis Result: $dllSpecificOut"
            }
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

task New-CsvOutputCollection {
    $Script:CsvOutputCollection = New-Object 'System.Collections.Generic.Dictionary[string,int]'
    #$Script:CsvOutputCollection.Add("Unit Test Coverage", 0)
}

task Write-CsvOutputCollection -depends New-CsvOutputCollection {

    $valuesCollection = $Script:CsvOutputCollection
    $csvOutput = [string]::Join("`t", $valuesCollection.Keys)
    $csvOutput += "`n"
    $csvOutput += [string]::Join("`t", $valuesCollection.Values)

    Set-Content "$($OutputPath)\OutputCollection.csv" -Value $csvOutput
}