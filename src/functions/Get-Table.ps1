function Get-Table{
    param([string] $Server, [string]$database, [string]$schema="dbo", [string]$table)

    $srv = new-object "Microsoft.SqlServer.Management.SMO.Server" $Server
    $db = $srv.databases[$database]

    $tableObj = $db.Tables | where-Object {$_.Schema -eq $schema -and $_.Name -eq $table}

    $options = New-Object Microsoft.SqlServer.Management.Smo.ScriptingOptions
    $options.AnsiPadding = $False
    $options.NonClusteredIndexes = $false
    $options.DriPrimaryKey = $True
    $options.NoFileGroup = $true
    $options.ScriptData = $false
    $options.AnsiFile = $False

    return $tableObj.script($options)
}