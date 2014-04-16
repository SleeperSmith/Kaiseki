

cd $psake.context.originalDirectory

Write-Host "== Loading Modules =="
Get-ChildItem Tasks-*.ps1 -Recurse -File | % {
    Write-Host Loading $_.Name
    Include $_
}
Write-Host "== Loading Modules > Done =="

Task Default -depends Clean,CreateCiOut,Invoke-MsBuild