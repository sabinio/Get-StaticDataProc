function Get-TableData{
    param([string] $Server, [string]$database, [string] $schema="dbo", [string]$table)

    $srv = new-object "Microsoft.SqlServer.Management.SMO.Server" $Server
    $db = $srv.databases[$database]
    $options = New-Object Microsoft.SqlServer.Management.Smo.ScriptingOptions

    $options.ScriptData = $true
    $options.ScriptSchema = $false
    $options.ScriptDrops = $false

    $tbl = $db.tables | Where-object { $_.schema -eq $schema -and $_.name -eq $table -and -not $_.IsSystemObject } 

    $script += $tbl.EnumScript($options)

    return $script -Join "`r`n"
}