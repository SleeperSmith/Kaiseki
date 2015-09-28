properties {
    $TestProjectFilter = ".*Test.*"
    $TestCategory = "Unit"
    $CodeCoverageFilter = ""
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

	 try {
        try {
            ."regsvr32" packages\OpenCover.4.5.3723\x64\OpenCover.Profiler.dll /s
            ."regsvr32" packages\OpenCover.4.5.3723\x86\OpenCover.Profiler.dll /s
        } catch {
        }

	    #bin paths
	    $opencoverBinPath = ".\packages\OpenCover.4.5.3723\OpenCover.Console.exe"
        $nunitRunnersDir = (Get-ChildItem .\packages -Filter NUnit.Runners.* -Directory)[0]
        $nunitBinPath = Get-ChildItem $nunitRunnersDir.FullName -Filter nunit-console.exe -Recurse -File
	
	    #args
	    $targetArgsNunitArgs = "/config:Release /noshadow /xml:$OutputPath\NUnit.UnitTests.xml"
	    $solutionName = $script:solution.Name
	    $outputFolder = "bin\Release\"

        $assemblies = ((Get-CsprojAssemblies -filter $TestProjectFilter) | % {
            $assemblyRelativePath = (Resolve-Path $_.FullName -Relative).Replace(".\", "")

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

        if ([string]::IsNullOrWhiteSpace($CodeCoverageFilter)) {
            $CodeCoverageFilter = "+[" + $solutionName.Substring(0, $solutionName.Length - 4) + "*]* -[*Tests]* -[*Test]*"
        }
        $filterArg = "-filter:$CodeCoverageFilter"

        $targetArg = "-target:$((Resolve-Path $nunitBinPath.FullName -Relative).Replace('.\', ''))"
        $outputArg = "-output:$OutputPath\opencover.nunit.xml"
	
	    #run
        exec { &$opencoverBinPath $targetArg $filterArg "-register:user" $targetArgsArg $outputArg }
    } finally {
        ."regsvr32" -u packages\OpenCover.4.5.3723\x64\OpenCover.Profiler.dll /s
        ."regsvr32" -u packages\OpenCover.4.5.3723\x86\OpenCover.Profiler.dll /s
    }
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

task Copy-TestAssemblies -depends Execute-MsBuild {
    $testAssemblyPath = ".\$ArtefactPath\TestAssemblies\"
    if (Test-Path $testAssemblyPath) {
        Remove-Item $testAssemblyPath -Force -Recurse
	}
    New-Item -ItemType directory -Path $testAssemblyPath

    Get-CsprojAssemblies -filter $TestProjectFilter | % {
        $folderName = $_.Name.SubString(0, $_.Name.Length - 4)
        $folderName = "$testAssemblyPath\$folderName"
        New-Item -ItemType directory -Path $folderName
        Copy-Item -Path "$($_.Directory)\*.*" -Destination $folderName
    }
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
    $reportGeneratorBinPath = ".\packages\ReportGenerator.2.1.4.0\ReportGenerator.exe"

	#args
    $reportsArg = "-reports:$OutputPath\opencover.*.xml"
    $targetDirArg = "-targetdir:$OutputPath\CoverageReport"

	#run
    exec { &$reportGeneratorBinPath $reportsArg $targetDirArg}
}