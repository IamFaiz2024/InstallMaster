git add --all
Write-Host "All Added"
[string]$WS=$null
if ($env:COMPUTERNAME -eq '5CD04794WV') {$WS='Home'}
else {$WS='Office'}
git commit -m "Commit $WS $(Get-Date -Format "dddd_dd-MMM-yyyy HH:mm")"
Write-Host "All Added"
git push -u origin master