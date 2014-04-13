# build transform
$specFileOriginal = '.\src\Kaiseki.bt.nuspec'
$specFileOriginalContent = [system.io.file]::ReadAllText((Resolve-Path $specFileOriginal).ProviderPath)
$specFileOriginalContent = $specFileOriginalContent.Replace('#version#', '1.0.0.0')

$specFile = '.\src\Kaiseki.nuspec'
Set-Content -Path $specFile -Value $specFileOriginalContent

# pack
."build\Nuget.exe" pack $specFile