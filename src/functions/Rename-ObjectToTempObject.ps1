function Rename-ObjectToTempObject{
    param([string] $ObjText, [string]$Schema="dbo", [string] $table)

    $OldName = Format-ObjectName $Schema $table
    $ObjText = [Regex]::Replace($ObjText, [regex]::Escape($OldName), ("[#" + $table+"]"), [System.Text.RegularExpressions.RegexOptions]::IgnoreCase);

    return $ObjText
}