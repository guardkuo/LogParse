$Script:inputFile = "Search_Report.txt"
$Script:resultFile = "Match_Result.txt"
$Script:resultFile1 = "All_Match_Result.txt"
$Script:errorlogFile = "error.log"
$Script:logFile = "LogParse.log"
$Script:analysisFile = "AnalysisReport"
$Script:summaryFile = "Summary"
$Script:minMatchCount = 20
$Script:DefMaxNumOfBadSector = 9
$Script:DefMinNumOfBadSector = 2
$Script:BackupLogFile = 0

$Script:FileExtensions = @{
    Deb = ".deb.0.5.full.txt"
    Evt = ".evt.0.5.full.txt"
    EvtDeb = ".evt+deb.0.5.full.txt"
    ConfTxt = "_Conf.txt"
    ConfXml = "_Conf.xml"
}

if (-not (Test-Path $inputFile)) {
    Write-Warning "Input file '$inputFile' not found. Specify via command line parameter."
}
