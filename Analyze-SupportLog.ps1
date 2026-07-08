#Requires -Version 7.1

$results = .\searchfile.ps1

if ($null -ne $results) {
    Write-Verbose "--- Analyzing Media Errors ---"
    .\LogParse.ps1 -InputFile $results
}
else {
    Write-Warning "--- No files ----"
}