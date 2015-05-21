# build transform
$specFileOriginal = Get-ChildItem -Filter *.bt.* -Recurse -File

$specFileOriginal | % {
	#'.\src\Kaiseki.bt.nuspec'
    $oldFilePath = Resolve-Path $_.FullName
    $specFileOriginalContent = [system.io.file]::ReadAllText($oldFilePath.ProviderPath)
    $specFileOriginalContent = $specFileOriginalContent.Replace('#version#', '1.0.8')

    $specFile = $oldFilePath.ProviderPath.Replace(".bt.", ".")
    Set-Content -Path $specFile -Value $specFileOriginalContent
    Remove-Item $_.FullName -Force
}


# pack
."build\Nuget.exe" pack .\src\Kaiseki.nuspec
