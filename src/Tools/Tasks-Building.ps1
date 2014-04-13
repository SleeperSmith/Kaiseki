Task Find-MsBuild {
    # valid versions are [2.0, 3.5, 4.0]
    $dotNetVersion = "4.0"
    $regKey = "HKLM:\software\Microsoft\MSBuild\ToolsVersions\$dotNetVersion"
    $regProperty = "MSBuildToolsPath"

    $script:MsBuildBinPath = join-path -path (Get-ItemProperty $regKey).$regProperty -childpath "msbuild.exe"
}

Task Invoke-MsBuild -depends Find-MsBuild {
    cd $psake.context.originalDirectory
    &$script:MsBuildBinPath
}

