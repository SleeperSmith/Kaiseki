properties {
    $OutputPath = "CiOutput"
}
task CreateCiOut -precondition {
    return !(Test-Path $OutputPath)
} {

    Write-Host
    Write-Host "== Creating output path =="
    New-Item -ItemType directory -Path $OutputPath

}

task Clean {

    Write-Host
    Write-Host "== Cleaning =="

    $packageFolder = (Resolve-Path .\packages)
    Write-Host Killing all obj and bin folders
    Get-ChildItem -Include bin,obj -Recurse |
        ? { !$_.FullName.StartsWith($packageFolder) } |
        Remove-Item -Force -Recurse

    if (Test-Path $OutputPath) {
        Write-Host Killing $OutputPath
        Remove-Item $OutputPath -Recurse -Force
    }

}

properties {
    $TargetSolution = ""
}
Task Get-TargetSolution {

    Write-Host
    Write-Host "== Determining solution to build. =="
	if(![string]::IsNullOrWhiteSpace($TargetSolution)) {
		Write-Host "Looking for target solution: " $TargetSolution
		$solutions = Get-ChildItem -R -Filter $TargetSolution
	} else {
        Write-Host "Looking for all solutions" $TargetSolution
		$solutions = Get-ChildItem *.sln
	}

    if ($solutions.count -eq 0) {
        throw "No .sln file found"
    } elseif ($solutions.count -gt 1 ) {
        Write-Host "Following solution files found:"
        $solutions | Format-List -Property FullName
        Write-Error "Only one solution can be built at a time."
    }

    $script:solution = $solutions[0]
    Write-Host "Building: " $solutions[0].Name
}

properties {
    $DotNetVersion = "4.0"
}
Task Invoke-MsBuild -depends Get-TargetSolution {

    Write-Host
    Write-Host "== Searching Msbuild path for .Net $DotNetVersion =="
    $regKey = "HKLM:\software\Microsoft\MSBuild\ToolsVersions\$DotNetVersion"
    $regProperty = "MSBuildToolsPath"
    $MsBuildBinPath = join-path -path (Get-ItemProperty $regKey).$regProperty -childpath "msbuild.exe"
    Write-Host Path: $MsBuildBinPath

    &$MsBuildBinPath

}

