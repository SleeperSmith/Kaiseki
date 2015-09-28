function Get-CsprojAssemblies {

    param(
        $filter = ".*"
    )

    $packagePath = (Get-Item packages).FullName
    return Get-ChildItem *.csproj -Recurse | ? {
        !$_.FullName.StartsWith($packagePath)
    } | ? {
        $_.Name -match $filter
    } | % {
        [xml]$projectXml = Get-Content $_.FullName  
        $assemblyName = $projectXml.Project.PropertyGroup.AssemblyName.GetValue(0)
        $assembliesFound = Get-ChildItem "$($_.Directory.FullName)\bin\**\$assemblyName.dll" -Recurse
        
        if ($assembliesFound.Count -eq 0) { return $null }    
        return $assembliesFound[0]
    } | ? {
        $_ -ne $null
    }

}