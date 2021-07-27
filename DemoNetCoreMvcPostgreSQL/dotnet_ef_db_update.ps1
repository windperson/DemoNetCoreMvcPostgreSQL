<#
.SYNOPSIS
    Auto apply EF Core migration changes on target database and/or generate DB update script
#>
param (
# (Alias: conn)
# 
# DB connection string to the target DB, default empty. 
    [Alias("conn")]
    [Parameter(Position = 0, Mandatory = $false)]
    [String] $DB_Conn = [string]::Empty,

# (Alias: out)
#
# Set if you want DB migration script, and its output path
    [Alias("out")]
    [Parameter(Mandatory = $false)]
    [String] $GenSQL = [string]::Empty
)

Write-Debug "`$DB_Conn='$DB_Conn'";

$ShouldVerbose = $false;
if ($PSBoundParameters['Verbose'] -or $VerbosePreference -eq 'Continue')
{
    $ShouldVerbose = $true;
}

# Lambda function for using in following Linq Any() operation
$checkApplyedFunc = [Func[PSCustomObject, bool]]{ $args[0].applied -eq $false }

if (-not $DB_Conn)
{
    $migrate_list = dotnet dotnet-ef migrations list --json --prefix-output | Where-Object { $_.StartsWith('data:') } | ForEach-Object { $_.Substring(5) } | ConvertFrom-Json;
}
else
{
    Write-Verbose "Use `$DB_Conn='$DB_Conn'";
    $migrate_list = dotnet dotnet-ef migrations list --connection "$DB_Conn" --json --prefix-output | Where-Object { $_.StartsWith('data:') } | ForEach-Object { $_.Substring(5) } | ConvertFrom-Json;
}

if (-not $?)
{
    throw "Get DB migration records from target DB failed, be sure to install dotnet ef cli tool and check DB connection correctness."
}

if ( [Linq.Enumerable]::Any([PSCustomObject[]]$migrate_list, $checkApplyedFunc))
{
    # Do db migration update
    Write-Information "New DB migrations detected, apply `"dotnet ef database update`":";
    if (ShouldVerbose)
    {
        PrintAndExecuteStr -exec "dotnet dotnet-ef database update --verbose"
    }
    else
    {
        PrintAndExecuteStr -exec "dotnet dotnet-ef database update"
    }
    return;
}

Write-Information "No DB migrations changes detected.";

if (-not [string]::IsNullOrEmpty($GenSQL))
{
    Write-Verbose "Create DB migration script:"
    if ($ShouldVerbose)
    {
        PrintAndExecuteStr -exec "dotnet dotnet-ef migrations script --idempotent --output $GenSQL --verbose"
    }
    else
    {
        PrintAndExecuteStr -exec "dotnet dotnet-ef migrations script --idempotent --output $GenSQL"
    }
}

function PrintAndExecuteStr
{
    param (
        [String] $exec
    )
    Write-Verbose "$exec"
    Invoke-Expression "$exec";
}
