$checkApplyedFunc = [Func[PSCustomObject, bool]] { $args[0].applied -eq $false }

$previous = dotnet ef migrations list --json --prefix-output | Where-Object { $_.StartsWith('data:') } | ForEach-Object { $_.Substring(5) } | ConvertFrom-Json;

if ( -not $? ) {
  throw "get db migration infos from target db failed!"
}

if ( [Linq.Enumerable]::Any([PSCustomObject[]]$previous, $checkApplyedFunc) ) {
  Write-Host "New DB migrations detected, apply `"dotnet ef database update`"";
  # Do db migration update
  $execStr = "dotnet ef database update --verbose"
  Write-Verbose "$execStr"
  Invoke-Expression "$execStr";

  return;
}

Write-Host "No DB migrations changes detected, exit.";
