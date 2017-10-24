Set-Location $PSScriptRoot
Import-Module '..\src\StaticDataProc.psd1' -Force
Import-Module -Name SqlServer -Force   # This module is a dependancy, use Install-Module SQLServer -Force -AllowClobber if not available

$server = "SQL16"
$database = "WideWorldImportersDW"
$Schema = "Dimension"
$tables = "Transaction Type"
$DeleteUnknownRecords = $true  # This param controls if the merge statement should delete not matched records

# Example 1 - Return a single table to the console output
Get-StaticDataProc -Server $Server -Database $Database -Schema $Schema -Table $Table -DeleteUnknown $DeleteUnknownRecords

# Example 2 - As above but results to text file
$outFile = "C:\Temp\script.txt"
Get-StaticDataProc -Server $Server -Database $Database -Schema $Schema -Table $Table -DeleteUnknown $DeleteUnknownRecords  | Out-File $outFile -Append

# Example 3 - Bunch of tables output to a file
$outFile = "C:\Temp\script.txt"
$tables = "Table1", "Table2", "Table3"
foreach ($table in $tables)
{
    Get-StaticDataProc -Server $Server -Database $Database -Schema $Schema -Table $Table -DeleteUnknown $DeleteUnknownRecords  | Out-File $outFile -Append
}





