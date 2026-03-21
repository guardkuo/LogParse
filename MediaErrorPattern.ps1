$MEDIRERROR_DEBUG = 0

$KeywordComments = @{
    "220A0148" = "Drive fail"
    "220A0188" = "Drive Failure / Pool Error"
    "020AA182" = "clone"
    "320A4509" = "LD fatal"
    "12084204" = "Drive Event Detected-Starting Clone"
    "12084244" = "WARN:SMART-CH 12 ID:185 (JBODId:3 SlotNum:6) Drive Event Detected-Starting Clone"
    "22084205" = "ERROR:SMART-CH 8 ID:23 Drive Event Detected-Clone Failed"
    "220A0749" = "Media Scan Failed"
    "22084202" = "No available drive for cloning"
    "22084285" = "Drive Event Detected-Clone Failed"
    "22080581" = "Timeout Waiting for I/O to Complete"
    "21080282" = "Gross Phase/Signal Error Detected"
    "22081882" = "CHL:12 ID:4 (JBODId:0 SlotNum:5) Drive ERROR: Aborted Command (0B/4B/04)"
    "020A8305" = "Rebuild"
    "12084203" = "SMART-CH 12 ID:552 Drive Event Detected"
    "020A8304" = "ID:6C48F804 Logical Drive INFORM: Starting Rebuild"
    "020A8402" = "ID:6C48F804 Logical Drive INFORM: Rebuild of Logical Drive Completed"
    "22080541" = "CHL:12 ID:206 (JBODId:3 SlotNum:27) Target ERROR: Timeout Waiting for I/O to Complete"
    "22080141" = "CHL:12 ID:206 (JBODId:3 SlotNum:27) Target ERROR: Unexpected Select Timeout"
    "21080242" = "CHL:12 ID:206 (JBODId:3 SlotNum:27) Target ERROR: Gross Phase/Signal Error Detected"
    "220A0302" = "ID:E334CFD Logical Drive ERROR: Rebuild Failed"
    "220A0188b" = "Name: Pool-1 Id: 3F9C16281CD22CF3 Pool Name: Logical_Drive_1 ID:E334CFD Logical Drive ERROR: CHL:12 ID:4 (JBODId:0 SlotNum:5) Drive Failure"
    "12084284" = "SMART-CH 12 ID:8 (JBODId:0 SlotNum:9) Drive Event Detected-Starting Clone"
    "2208C187" = "CHL:12 ID:11 (JBODId:0 SlotNum:12) Drive ERROR: Scan Drive Failed"
    "2208C107" = "CHL:9 ID:0 Drive ERROR: Scan Drive Failed"
    "22084245" = "ERROR:SMART-CH 12 ID:74 (JBODId:1 SlotNum:15) Drive Event Detected-Clone Failed"
    "21081242" = "Drive ERROR: Drive HW Error (04/32/00)"
    "0208C181" = "CHL:12 ID:12 (JBODId:0 SlotNum:13) Drive INFORM: Scan Drive Successful"
}

$KeywordDrvScan = @("0208C181", "0208C141")
$KeywordMediaError = @("02081382", "02081342", "02081341", "02081381")
$KeywordIoTimeout = @("22080541", "22080581", "22080181")
$KeywordIoError = @("21080282", "22081881", "21080242", "22081882", "22081841", "22081842", "22080101", "22080141")
$KeywordHWError = @("21081242", "21081282", "21081241", "21081281")
$KeywordSmartError = @("22084245", "12084203", "12084244", "22084205", "12084204", "12084284", "12084243", "22084285", "12084283")
$Keywords1 = @("220A0187", "220A0185", "220A0148", "2208C187", "2208C107", "220A0188") + $KeywordSmartError + $KeywordIoError + $KeywordIoTimeout + $KeywordHWError

$LDRebuildStart = @("020A8306", "020A8305", "020A8304")
$LDRebuildCmplt = @("020A8402", "220A0302")
$Keywords2 = @("220A0787", "22080581", "020AA182", "320A4509", "22084202", "22080181", "220A1182", "12084243", "020AA142", "020AA281", "22080541", "22080542", "21080242", "22080141", "02081781", "22084285", "220A0749", "22081882") + $KeywordMediaError + $Keywords1 + $LDRebuildStart + $LDRebuildCmplt

$LDRebuild = $LDRebuildCmplt + $LDRebuildStart
$KeywordDeb = @("latency", "M62:", "Drive Channel")
$DrvErrKeywords = $Keywords1

$KeywordPattern = ($KeywordMediaError | ForEach-Object { [regex]::Escape($_) }) -join '|'
$Pattern = [regex]::new("^\s+\S+\s+\S+\s+\S+\s+\S+\s+\S+\s+\S+\s+($KeywordPattern)", [System.Text.RegularExpressions.RegexOptions]::Compiled)

$SmartErrorPattern = ($KeywordSmartError | ForEach-Object { [regex]::Escape($_) }) -join '|'

$IoErrorPattern = ($KeywordIoError | ForEach-Object { [regex]::Escape($_) }) -join '|'

$IoTimeoutPattern = ($KeywordIoTimeout | ForEach-Object { [regex]::Escape($_) }) -join '|'

$HWErrorPattern = ($KeywordHWError | ForEach-Object { [regex]::Escape($_) }) -join '|'

$KeywordDrvScanPattern = ($KeywordDrvScan | ForEach-Object { [regex]::Escape($_) }) -join '|'
$DrvScanPattern = [regex]::new("^\s+\S+\s+\S+\s+\S+\s+\S+\s+\S+\s+\S+\s+($KeywordDrvScanPattern)", [System.Text.RegularExpressions.RegexOptions]::Compiled)
$DrvScanMatch = "(" + ($KeywordDrvScan -join '|') + ")"
$DrvScanMatchPattern = [regex]::new("$DrvScanMatch.* ID:(?<ScsiID>[0-9A-Fa-f]+)", [System.Text.RegularExpressions.RegexOptions]::Compiled)

$KeywordPattern1 = ($Keywords1 | ForEach-Object { [regex]::Escape($_) }) -join '|'
$Pattern1 = [regex]::new("^\s+\S+\s+\S+\s+\S+\s+\S+\s+\S+\s+\S+\s+($KeywordPattern1)", [System.Text.RegularExpressions.RegexOptions]::Compiled)

$KeywordPattern2 = ($Keywords2 | ForEach-Object { [regex]::Escape($_) }) -join '|'
$Pattern2 = [regex]::new("^\s+\S+\s+\S+\s+\S+\s+\S+\s+\S+\s+\S+\s+($KeywordPattern2)", [System.Text.RegularExpressions.RegexOptions]::Compiled)

$KeywordDrvErrPattern = ($DrvErrKeywords | ForEach-Object { [regex]::Escape($_) }) -join '|'
$DrvErrPattern = [regex]::new("^\s+\S+\s+\S+\s+\S+\s+\S+\s+\S+\s+\S+\s+($KeywordDrvErrPattern)", [System.Text.RegularExpressions.RegexOptions]::Compiled)

$KeywordRebuildPattern = ($LDRebuild | ForEach-Object { [regex]::Escape($_) }) -join '|'
$RebuildPattern = [regex]::new("^\s+\S+\s+\S+\s+\S+\s+\S+\s+\S+\s+\S+\s+($KeywordRebuildPattern)", [System.Text.RegularExpressions.RegexOptions]::Compiled)

$DebKeywordPattern = ($KeywordDeb | ForEach-Object { [regex]::Escape($_) }) -join '|'

$RebuildStartPattern = "(" + ($LDRebuildStart -join '|') + ")"
$KeywordRebuildStartPattern = [regex]::new("$RebuildStartPattern.* ID:(?<LD>[0-9A-Fa-f]+)", [System.Text.RegularExpressions.RegexOptions]::Compiled)
$RebuildCmptPattern = "(" + ($LDRebuildCmplt -join '|') + ")"
$KeywordRebuildCmpltPattern = [regex]::new("$RebuildCmptPattern.* ID:(?<LD>[0-9A-Fa-f]+)", [System.Text.RegularExpressions.RegexOptions]::Compiled)

$Script:PrecompiledRegex = @{
    MediaError    = $Pattern
    DrvScan       = $DrvScanPattern
    DrvScanID     = $DrvScanMatchPattern
    Pattern1      = $Pattern1
    Pattern2      = $Pattern2
    DrvErr        = $DrvErrPattern
    Rebuild       = $RebuildPattern
    RebuildStart  = $KeywordRebuildStartPattern
    RebuildCmplt  = $KeywordRebuildCmpltPattern
    SmartError    = $SmartErrorPattern
    IoError       = $IoErrorPattern
    IoTimeout     = $IoTimeoutPattern
    HWError       = $HWErrorPattern
    DebKeyword    = $DebKeywordPattern
}

$SectorsPerGB = 2097152
$WeekThresholdDays = 7
$minThreshhold = 10
$IgnoreErrorBeforeScan = 0
$minAnalysisDaysBeforeIssued = 180

function MediaErrorBadSector {
    param([PSCustomObject[]]$Entries)
    
    if ($null -eq $Entries -or $Entries.Count -eq 0) {
        return $null
    }
    
    $sortedBySector = $Entries | Sort-Object SectorDec
    $sortedByTime = $Entries | Sort-Object Time
    $minSector = $sortedBySector[0].SectorDec
    $duration = $sortedByTime[-1].Time - $sortedByTime[0].Time
    
    return [PSCustomObject]@{
        DriveID     = $Entries[0].ID
        StartSector = "0x{0:X}" -f $minSector
        SectorDec   = $minSector
        GB_Zone     = "GB_" + $Entries[0].GBZone
        StartGB     = $Entries[0].GBZone
        ErrorCount  = $Entries.Count
        StartTime   = $sortedByTime[0].Time
        EndTime     = $sortedByTime[-1].Time
        Duration    = "$([Math]::Round($duration.TotalMinutes, 1)) mins"
    }
}

function UpdateMediaErrorBadSector {
    param(
        [PSCustomObject]$Curr,
        [PSCustomObject[]]$Entries
    )
    
    if ($null -eq $Entries -or $Entries.Count -eq 0) {
        return
    }
    
    $sortedBySector = $Entries | Sort-Object SectorDec
    $sortedByTime = $Entries | Sort-Object Time
    $minSector = $sortedBySector[0].SectorDec
    $duration = $sortedByTime[-1].Time - $sortedByTime[0].Time
    
    $Curr.DriveID = $Entries[0].ID
    $Curr.StartSector = "0x{0:X}" -f $minSector
    $Curr.SectorDec = $minSector
    $Curr.GB_Zone = "GB_" + $Entries[0].GBZone
    $Curr.StartGB = $Entries[0].GBZone
    $Curr.ErrorCount = $Entries.Count
    $Curr.StartTime = $sortedByTime[0].Time
    $Curr.EndTime = $sortedByTime[-1].Time
    $Curr.Duration = "$([Math]::Round($duration.TotalMinutes, 1)) mins"
}

function Get-MediaErrorData {
    param([string]$LogFilePath)
    
    $MediaErr_matches = Select-String -Path $LogFilePath -Pattern $Script:PrecompiledRegex['MediaError'] -ErrorAction SilentlyContinue
    return $MediaErr_matches
}

function Set-MediaErrorMap {
    param([System.Collections.ArrayList]$MediaErrorData)
    
    $sortedPattern = $MediaErrorData | Sort-Object -Property @{
        Expression = {
            if ($_.Line -match 'ID:(?<ID>\d+)') { [int64]$Matches['ID'] } else { 0 }
        }
    }, @{
        Expression = {
            if ($_.Line -match '0x(?<Sector>[0-9A-Fa-f]+)') {
                $decSector = [Convert]::ToInt64($Matches['Sector'], 16)
                [Math]::Floor($decSector / $SectorsPerGB)
            }
            else { 0 }
        }
    }, @{
        Expression = {
            if ($_.Line -match '(?<Date>\d{2}-\d{2}-\d{2} \d{2}:\d{2}:\d{2})') {
                [DateTime]::ParseExact($Matches['Date'], "yy-MM-dd HH:mm:ss", $null)
            }
            else { [DateTime]::MinValue }
        }
    }
    return $sortedPattern
}

function Build-ParseLog {
    param([System.Collections.ArrayList]$MediaErrorData)
    
    $parsedLogs = $MediaErrorData | ForEach-Object {
        $line = $_.Line
        $foundID = $null
        $foundTime = $null
        $foundSector = 0

        if ($line -match 'ID:(?<ID>\d+)') {
            $foundID = [int64]$Matches['ID']
        }

        if ($line -match '(?<DT>\d{2}-\d{2}-\d{2}\s\d{2}:\d{2}:\d{2})') {
            $foundTime = [DateTime]::ParseExact($Matches['DT'], "yy-MM-dd HH:mm:ss", $null)
        }

        if ($line -match '0x(?<Hex>[0-9A-Fa-f]+)') {
            try {
                $foundSector = [Convert]::ToInt64($Matches['Hex'], 16)
            }
            catch {
                $foundSector = 0 
            }
        }

        if ($null -ne $foundID -and $null -ne $foundTime) {
            [PSCustomObject]@{
                ID        = $foundID
                SectorDec = $foundSector
                SectorHex = "0x{0:X}" -f $foundSector
                GBZone    = [Math]::Floor($foundSector / $SectorsPerGB)
                Time      = $foundTime
                RawLine   = $line
            }
        }
    }
    return $parsedLogs
}

function Split-MediaError-Group {
    param([PSCustomObject[]]$LogsObj)
    
    $report = @()
    $groups = $LogsObj | Group-Object ID, GBZone

    foreach ($g in $groups) {
        $sortedEntries = $g.Group | Sort-Object StartGB, Time
        
        $currentEventEntries = @()
        $lastTime = $null
        foreach ($entry in $sortedEntries) {
            if ($null -ne $lastTime -and [Math]::Abs(($entry.Time - $lastTime).TotalMinutes) -gt $minThreshhold) {
                $report += MediaErrorBadSector -Entries $currentEventEntries
                $currentEventEntries = @()
                $lastTime = $entry.Time
            }
            $currentEventEntries += $entry
            if ($null -eq $lastTime) {
                $lastTime = $entry.Time
            }
        }
        
        if ($currentEventEntries.Count -gt 0) {
            $report += MediaErrorBadSector -Entries $currentEventEntries
        }
    }

    if ($MEDIRERROR_DEBUG -eq 1) {
        Write-Host "`n[Summary]" -ForegroundColor Cyan
        Write-Host "Total damaged GB zones: $($groups.Count)"
        Write-Host "Total events processed: $($report.Count)" -ForegroundColor Yellow
        $report | Sort-Object DriveID, SectorDec | Select-Object DriveID, StartSector, GB_Zone, ErrorCount, StartTime, EndTime, Duration | Format-Table -AutoSize
    }     
    return $report
}

function Get-Drive-ScanTime {
    param(
        [PSCustomObject[]]$DriveList,
        [int]$ScsiID
    )
    
    foreach ($drv in $DriveList) {
        if ($drv.ID -eq $ScsiID) {
            return $drv.ScanTime
        }
    }
    return $null
}

function Resolve-MediaError-Timestamp {
    param(
        [PSCustomObject[]]$LogsObj,
        [PSCustomObject[]]$DriveScanList,
        [DateTime]$IssueTime
    )
    
    $report = @()
    $groups = $LogsObj | Group-Object ID, GBZone

    foreach ($g in $groups) {
        $sortedEntries = $g.Group | Sort-Object Time, StartGB
        $currentEventEntries = @()
        $lastTime = $null
        $duplicated = 0
        $foundId = -1
        
        foreach ($entry in $sortedEntries) {
            if ($IgnoreErrorBeforeScan -eq 1) {
                if ($foundId -ne $entry.ID) {
                    $scanTime = Get-Drive-ScanTime -DriveList $DriveScanList -ScsiID $entry.ID
                    $foundId = $entry.ID
                }
            }
            
            if (($null -eq $scanTime -or [Math]::Abs(($entry.Time - $scanTime).TotalMinutes) -lt 0) -and ($IssueTime - $entry.Time).TotalDays -le $minAnalysisDaysBeforeIssued) {
                if ($null -ne $lastTime -and [Math]::Abs(($entry.Time - $lastTime).TotalMinutes) -gt $minThreshhold) {
                    if ($duplicated -eq 0) {
                        $report += MediaErrorBadSector -Entries $currentEventEntries
                    }
                    else {
                        $duplicated = 0
                    }
                    $currentEventEntries = @()
                    $lastTime = $entry.Time
                }
                $currentEventEntries += $entry
                if ($null -eq $lastTime) {
                    $lastTime = $entry.Time
                }
            }
        }
        
        if ($currentEventEntries.Count -gt 0) {
            if ($duplicated -eq 0) {
                $report += MediaErrorBadSector -Entries $currentEventEntries
            }
        }
    }

    if ($MEDIRERROR_DEBUG -eq 1) {
        Write-Host "`n[Summary]" -ForegroundColor Cyan
        Write-Host "Total damaged GB zones: $($groups.Count)"
        Write-Host "Total events processed: $($report.Count)" -ForegroundColor Yellow
        $report | Format-Table -AutoSize
    }     
    return $report
}

function Save-MediaErrorSect-Report {
    param(
        [PSCustomObject[]]$Report,
        [hashtable]$DiskMap,
        [DateTime]$IssueTime
    )
    
    $groupedByID = $Report | Sort-Object DriveID, SectorDec | Group-Object DriveID
    $reportOutput = New-Object System.Collections.Generic.List[string]
    
    $reportOutput.Add("=== Disk Media Error Analysis Report (Grouped by ID) ===")
    $reportOutput.Add("Generated on: $(Get-Date)")
    $reportOutput.Add("Issued on: $IssueTime")
    $reportOutput.Add("")

    foreach ($driveGroup in $groupedByID) {
        $currentVendor = $DiskMap[$driveGroup.Name]
        $header = ">>> Drive ID: $($driveGroup.Name) (Total Events: $($driveGroup.Count))"
        $reportOutput.Add($header)
        $reportOutput.Add("-" * $header.Length)
        if ($currentVendor) {
            $reportOutput.Add($currentVendor)
        }
        $table = $driveGroup.Group | Select-Object StartSector, GB_Zone, ErrorCount, StartTime, EndTime, Duration | Format-Table -AutoSize | Out-String
        $reportOutput.Add($table)
        $reportOutput.Add("")
    }
      
    return $reportOutput
}

function New-SectorObject {
    param(
        [int]$DriveID,
        [int]$GBZone,
        [DateTime]$Time
    )
    
    return [PSCustomObject]@{
        DriveID   = $DriveID
        StartGB   = $GBZone
        StartTime = $Time
    }
}

function Add-SectorToList {
    param(
        [System.Collections.Generic.List[PSCustomObject]]$List,
        [int]$DriveID,
        [int]$GBZone,
        [DateTime]$Time
    )
    
    $NewItem = New-SectorObject -DriveID $DriveID -GBZone $GBZone -Time $Time
    $null = $List.Add($NewItem)
}

function Get-ErrorType {
    param([PSCustomObject]$DrvEvent)
    
    if ($DrvEvent.Line -match $SmartErrorPattern) {
        return [int][FailureType]::SmartError
    }
    if ($DrvEvent.Line -match $IoErrorPattern) {
        return [int][FailureType]::IOError
    }
    if ($DrvEvent.Line -match $IoTimeoutPattern) {
        return [int][FailureType]::IOTimeout
    }
    if ($DrvEvent.Line -match $HWErrorPattern) {
        return [int][FailureType]::HWError
    }
    return [int][FailureType]::Others
}
