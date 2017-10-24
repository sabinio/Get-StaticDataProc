
function Format-ObjectName
{
    param([string]$Schema, [string]$Table)
    $full = "[" + $Schema + "].[" + $Table + "]"
    return $full.Replace("[[","[").Replace("]]","]")
}
