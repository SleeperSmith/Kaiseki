properties {
    $TestProjectSuffix = "Tests"
    $TestCategory = "Unit"
}
task Execute-Nunit -depends Get-TargetSolution -precondition {
    Write-Host ?Execute-Nunit?
    $nunitRunnersDirs = Get-ChildItem .\packages -Filter NUnit.Runners.* -Directory

    if ($nunitRunnersDirs.Count -eq 0) {
        Write-Host "> No NUnit runners found."
        Write-Host "> If you want to run NUnit tests, please do Install-Packages NUnit.Runners"
        return $false
    }

    return $true

} {

	#bin paths
	$opencoverBinPath = ".\packages\OpenCover.4.5.2506\OpenCover.Console.exe"
    $nunitRunnersDir = (Get-ChildItem .\packages -Filter NUnit.Runners.* -Directory)[0]
    $nunitBinPath = Get-ChildItem $nunitRunnersDir.FullName -Filter nunit-console.exe -Recurse -File
	
	#args
	$targetArgsNunitArgs = "/config:Release /noshadow /xml:$OutputPath\NUnit.UnitTests.xml"
	$solutionName = $targetSolution.Name
	$outputFolder = "bin\Release\"

    $assemblies = (Get-ChildItem *.csproj -Recurse | ? {
        #$_.FullName.EndsWith("$TestProjectSuffix.csproj")
        $true
    } | % {

        $searchDirectory = Resolve-Path $_.Directory.FullName -Relative

        # Open up .csproj xml and find assmebly name.
        [xml]$projectXml = Get-Content $_
        $assemblyName = $projectXml.Project.PropertyGroup.AssemblyName
        $assemblyName = $assemblyName.GetValue(0)

        # Get the path to assembly relative to the solution root.
        # This is done because absolute path containing spaces cause error.
        $assembly = (Get-ChildItem "$searchDirectory\bin\**\$assemblyName.dll" -Recurse)[0]
        $assemblyRelativePath = (Resolve-Path $assembly.FullName -Relative).Replace(".\", "")

        return "`"$assemblyRelativePath`""
    }) -join ' '
    	
    # Filter test category
	if ($TestCategory -ne "") {
		$targetArgsNunitArgs = $targetArgsNunitArgs + " /include:`"$TestCategory`""
		$fileCatName = $TestCategory.Replace(",", ".")
		$targetArgsNunitArgs = $targetArgsNunitArgs.Replace("NUnit.UnitTests.xml", "NUnit.$fileCatName.xml")
	}
	
	#solution used as run target.
    $targetArgsArg = "-targetargs:$assemblies $targetArgsNunitArgs"

	if ($assemblyInclusionPrefix -eq "") {
		$assemblyInclusionPrefix = $solutionName.Substring(0, $solutionName.Length - 4)
	}
    $filterInnerArg = "+[" + $assemblyInclusionPrefix + "*]* -[*Tests]* -[*Test]*"
    $filterArg = "-filter:$filterInnerArg"

    $targetArg = "-target:$((Resolve-Path $nunitBinPath.FullName -Relative).Replace('.\', ''))"
    $outputArg = "-output:$OutputPath\opencover.nunit.xml"
	
	#run
    exec { &$opencoverBinPath $targetArg $filterArg "-register:user" $targetArgsArg $outputArg }
}

task Copy-Nunit -depends New-CiOutFolder -precondition {
    Write-Host ?Copy-Nunit?
    $nunitRunnersDirs = Get-ChildItem .\packages -Filter NUnit.Runners.* -Directory

    if ($nunitRunnersDirs.Count -eq 0) {
        return $false
    }

    return $true
} {
    $nunitRunnersDir = (Get-ChildItem .\packages -Filter NUnit.Runners.* -Directory)[0]

    Copy-Item $nunitRunnersDir.FullName $ArtefactPath -Recurse -Force
}

task Execute-ReportGenerator -depends Execute-Nunit -precondition {
    Write-Host ?Execute-Nunit?
    $nunitRunnersDirs = Get-ChildItem .\packages -Filter NUnit.Runners.* -Directory

    if ($nunitRunnersDirs.Count -eq 0) {
        Write-Host "> No NUnit runners found."
        Write-Host "> If you want to run NUnit tests, please do Install-Packages NUnit.Runners"
        return $false
    }

    return $true

} {
	#bin
    $reportGeneratorBinPath = ".\packages\ReportGenerator.1.9.1.0\ReportGenerator.exe"

	#args
    $reportsArg = "-reports:$OutputPath\opencover.*.xml"
    $targetDirArg = "-targetdir:$OutputPath\CoverageReport"

	#run
    exec { &$reportGeneratorBinPath $reportsArg $targetDirArg}
}