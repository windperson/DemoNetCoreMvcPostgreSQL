$current = dotnet ef migrations list --no-connect --json --prefix-output | Where-Object { $_.StartsWith('data:') } | ForEach-Object { $_.Substring(5) } | ConvertFrom-Json;

$previous = dotnet ef migrations list --json --prefix-output | Where-Object { $_.StartsWith('data:') } | ForEach-Object { $_.Substring(5) } | ConvertFrom-Json;

# TODO: just compare the "applied" field of each list entry. 
if ( $previous -and (-not (Compare-Object $current.PSObject.Properties $previous.PSObject.Properties)) ) {
  Write-Host "No DB migrations changes detected, exit.";
  return;
}

Write-Host "New DB migrations detected, apply `"dotnet ef database update`"";
# Do db migration update
$execStr = "dotnet ef database update --verbose --no-color "
Write-Verbose "$execStr"
Invoke-Expression "$execStr";
