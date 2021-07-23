<#
.SYNOPSIS
    Auto apply EF Core migration changes on target database and/or generate DB update script
#>
param (
  # (Alias: conn)
  # 
  # DB connection string to the target DB, default empty. 
  [Alias("conn")]
  [Parameter(Position = 0)]
  [String] $DB_Connection = [string]::Empty
)

Write-Debug "`$DB_Connection='$DB_Connection'";

# Lambda function for using in following Linq Any() operation
$checkApplyedFunc = [Func[PSCustomObject, bool]] { $args[0].applied -eq $false }

if ( -not $DB_Connection ) {
  $migrate_list = dotnet dotnet-ef migrations list --json --prefix-output | Where-Object { $_.StartsWith('data:') } | ForEach-Object { $_.Substring(5) } | ConvertFrom-Json;
}
else {
  Write-Verbose "Use `$DB_Connection='$DB_Connection'";
  $migrate_list = dotnet dotnet-ef migrations list --connection "$DB_Connection" --json --prefix-output | Where-Object { $_.StartsWith('data:') } | ForEach-Object { $_.Substring(5) } | ConvertFrom-Json;
}

if ( -not $? ) {
  throw "Get DB migration records from target DB failed, be sure to install dotnet ef cli tool and check DB connection correctness."
}

if ( [Linq.Enumerable]::Any([PSCustomObject[]]$migrate_list, $checkApplyedFunc) ) {
  # Do db migration update
  Write-Verbose "New DB migrations detected, apply `"dotnet ef database update`":";  
  PrintAndExecuteStr -exec "dotnet dotnet-ef database update --verbose"
  Write-Verbose "Create DB migration script:"
  PrintAndExecuteStr -exec "dotnet dotnet-ef migrations script --idempotent --output ../DB_script/update.sql --verbose"
  return;
}

Write-Information "No DB migrations changes detected, exit.";

function PrintAndExecuteStr {
  param (
    [String] $exec
  )
  Write-Verbose "$exec"
  Invoke-Expression "$exec";
}
