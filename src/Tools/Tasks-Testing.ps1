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
	$targetArgsNunitArgs = "/config:Release /noshadow /xml:$CiOutput\NUnit.UnitTests.xml"
	$solutionName = $targetSolution.Name
	$outputFolder = "bin\Release\"

    $assemblies = (Get-ChildItem *.csproj -Recurse | % {

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
	<#if ($TestCategory -ne "") {
		$targetArgsNunitArgs = $targetArgsNunitArgs + " /include:`"$TestCategory`""
		$fileCatName = $TestCategory.
			Replace(",", ".")
		$targetArgsNunitArgs = $targetArgsNunitArgs.
            Replace($nunitOut, "nunit.$fileCatName.xml")
	}#>
	
	#solution used as run target.
    $targetArgsArg = "-targetargs:$assemblies $targetArgsNunitArgs"

	if ($assemblyInclusionPrefix -eq "") {
		$assemblyInclusionPrefix = $solutionName.Substring(0, $solutionName.Length - 4)
	}
    $filterInnerArg = "+[" + $assemblyInclusionPrefix + "*]* -[*Tests]* -[*Test]*"
    $filterArg = "-filter:$filterInnerArg"

    $targetArg = "-target:$((Resolve-Path $nunitBinPath.FullName -Relative).Replace('.\', ''))"
    $outputArg = "-output:$CiOutPath$opencoverNunitOut"
	
	#run
    exec { &$opencoverBinPath $targetArg $filterArg "-register:user" $targetArgsArg $outputArg }
}