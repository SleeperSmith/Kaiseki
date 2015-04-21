param(
    $TestCategory = "Integration"
)

Push-Location $PSScriptRoot

$nunitRunnersDir = (Get-ChildItem ..\ -Filter NUnit.Runners.* -Directory)[0]
$nunitBinPath = Get-ChildItem $nunitRunnersDir.FullName -Filter nunit-console.exe -Recurse -File

$assemblies = (Get-ChildItem ..\TestAssemblies -Directory | % {
    return (Get-ChildItem -Path $_.FullName -Filter "$($_.Name).dll")[0]
} | % {
    return "`"$(Resolve-Path $_.FullName -Relative)`""
})
	
#args
$fileCatName = $TestCategory.Replace(",", ".")

#run
&$nunitBinPath.FullName $assemblies "/xml:..\NUnit.$fileCatName.xml" "/include:$TestCategory"

Pop-Location