function New-MergeStatement
{
    param([string]$Server, [string]$Database, [string]$Schema="dbo", [string]$Table, [boolean]$DeleteUnknown=$false)

    $FullTargetObject = Format-ObjectName -Schema $Schema -Table $Table
    $HasIdentity = (Invoke-Sqlcmd -ServerInstance $Server -Database $Database -Query "SELECT objectproperty(object_id('$FullTargetObject'), 'TableHasIdentity')").Item("Column1")

    $sqlcmd = "SELECT c.column_id, '[' + c.name + ']' name, i.is_primary_key
                FROM sys.columns C
                LEFT JOIN sys.index_columns ic ON ic.object_id = c.object_id AND ic.column_id = c.column_id
                LEFT JOIN sys.indexes i on i.object_id = c.object_id AND i.index_id = ic.index_id AND i.is_primary_key = 1
                WHERE c.OBJECT_ID = OBJECT_ID('$FullTargetObject')
	                AND is_computed = 0"

    $ColumnList = Invoke-Sqlcmd -ServerInstance $Server -Database $Database -Query $sqlcmd 
  

    if ($HasIdentity -eq 1)
    {
        $Merge = "SET IDENTITY_INSERT $FullTargetObject ON;", ""
    }
   
    $Merge += "MERGE $FullTargetObject T", "USING #$Table S ON"

    $MergeJoinList = @()
    foreach ($Column in $ColumnList | where-object {$_.is_primary_key -eq $true })
    {
        $ColName = $Column.Name
        $MergeJoinList += ("    T.$ColName = S.$ColName")
    }

    $Merge += $MergeJoinList -join " AND "

    $Merge += "WHEN MATCHED THEN UPDATE SET"

    $MergeUpdateList = @()
    foreach ($Column in $ColumnList | where-object {$_.is_primary_key -ne $true })
    {
        $ColName = $Column.Name
        $MergeUpdateList += ("    T.$ColName = S.$ColName")
    }
    
    $Merge += $MergeUpdateList -join ", `r`n"

    $Merge += "WHEN NOT MATCHED BY TARGET THEN INSERT ("+(($ColumnList.Name|Group-Object|Select-Object -ExpandProperty Name) -join ", ")+")"
    
    if ($DeleteUnknown -eq $true) {$Terminator = ")"}
        else {$Terminator = ");"}
        
    $Merge += "    VALUES (S."+(($ColumnList.Name|Group-Object|Select-Object -ExpandProperty Name) -join ", S.")+"$Terminator" 

    if ($DeleteUnknown -eq $true)
    {
        $Merge += "WHEN NOT MATCHED BY SOURCE THEN DELETE;"
    }
    else
    {
        $Merge += "-- WHEN NOT MATCHED BY SOURCE THEN DELETE;"
    }
  
     if ($HasIdentity -eq 1)
    {
        $Merge += "", "SET IDENTITY_INSERT $FullTargetObject OFF;"
    }

    return $Merge -Join "`r`n"
}