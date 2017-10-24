function Get-StaticDataProc
{
<#
.Synopsis
Generate the script of a proc to create a temp table, script data and merge the two. Used for source controlling static/reference data.
.Description
Generate the script of a proc to create a temp table, script data and merge the two. Used for source controlling static/reference data.
.Parameter Server
The SQL Connection that the table is stored on
.Parameter Database
The Database name that the table is stored on
.Parameter Schema
Table schema
.Parameter Table
Table name with the source data
.Parameter DeleteUnknown
Should the MERGE statement delete unknown records
.Example
$server = "SQL16"
$database = "WideWorldImportersDW"
$Schema = "Dimension"
$tables = "Transaction Type"
$DeleteUnknownRecords = $true  # This param controls if the merge statement should delete not matched records

Get-StaticDataProc -Server $Server -Database $Database -Schema $Schema -Table $Table -DeleteUnknown $DeleteUnknownRecords
#>
param([string]$Server, [string]$Database, [string]$Schema="dbo", [string]$Table, [boolean]$DeleteUnknown=$false)

    $Proc = "CREATE PROCEDURE [data].[$Table]", "AS", "", "SET NOCOUNT ON;", ""

    $TempTableScript = Get-Table -Server $server -Database $database -Schema $Schema -Table $table

    # Remove Headers (SET options)
    $TempTableScript = $TempTableScript | Select-Object -Skip 2

    $Proc += Rename-ObjectToTempObject -ObjText $TempTableScript -Schema $Schema -Table $table

    $TableDataScript = Get-TableData -Server $server -Database $database -Schema $Schema -Table $table
    $Proc += Rename-ObjectToTempObject -ObjText $TableDataScript -Schema $Schema -Table $table

    $Proc += "", ""

    $Proc += New-MergeStatement -Server $Server -Database $Database -Schema $Schema -Table $Table -DeleteUnknown $DeleteUnknown

    $Proc += "", "DROP TABLE [#$Table];", "GO", ""

    Return $Proc -Join "`r`n"
}

