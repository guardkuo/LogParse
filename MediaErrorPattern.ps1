#220A0148: Drive fail
#220A0188: Drive Failure
#020AA182: clone
#320A4509: LD fatal
#12084204: Drive Event Detected-Starting Clone
#12084244: WARN:SMART-CH 12 ID:185 (JBODId:3 SlotNum:6) Drive Event Detected-Starting Clone

#220A0749: Media Scan Failed
#22084202: No availible drive for cloning
#22084285: Drive Event Detected-Clone Failed
#22080581: Timeout Waiting for I/O to Complete
#21080282: Gross Phase/Signal Error Detected
#020A8305: Rebuild
#22081882
#12084203: SMART-CH 12 ID:552 Drive Event Detected 

# 1. 設定關鍵字與檔案路徑
# media error
$keywords = @("02081382", "02081342", "02081341", "02081381")
# drive fail, rebuild, clone, io error
$keywords1 = @("21081282", "220A0188", "220A0187", "220A0185", "220A0148", "12084204", "12084203", "12084244")

# events we want
$keywords2 = @("02081382", "02081342", "02081341", "02081381", "220A0787", "21081282", "220A0188", "22080581", "020A8305", "020AA182", "320A4509", "220A0187", "22084205", "22084202", "020A8402", "21080282", "22080181", "220A1182", "12084243", "12084244", "020AA142", "020AA281", "220A0185", "12084204", "22080541", "22080542", "220A0148", "21080242", "22080141", "02081781", "22084285", "12084284", "220A0749", "22081882", "12084203", "020A8304")

#27547  IN 22-01-18 12:23:05 [A ] 020A8304 ID:6C48F804 Logical Drive INFORM: Starting Rebuild
# 27548  IN 22-01-18 14:17:14 [A ] 00190002 
# 27549  IN 22-01-18 14:51:22 [A ] 00190002 
# 27550  IN 22-01-18 23:18:48 [A ] 020A8402 ID:6C48F804 Logical Drive INFORM: Rebuild of Logical Drive Completed
 
#22080541 CHL:12 ID:206 (JBODId:3 SlotNum:27)  Target ERROR: Timeout Waiting for I/O to Complete
#22080141 CHL:12 ID:206 (JBODId:3 SlotNum:27)  Target ERROR: Unexpected Select Timeout
#21080242 CHL:12 ID:206 (JBODId:3 SlotNum:27)  Target ERROR: Gross Phase/Signal Error Detected
$LDRebuildStart = @("020A8306", "020A8305", "020A8304")
$LDRebuildCmplt = "020A8402"
$DrvErrKeywords = @("21081282", "220A0188", "220A0187", "220A0185", "220A0148", "12084204", "22080581", "12084244", "12084203", "22084285", "22080541", "22080141", "21080242")
#$DrvErrKeywords = @("21081282", "220A0188", "220A0187", "220A0185", "220A0148", "12084204", "22080581", "12084244","12084203", "22084285")

# Drive ChlNo:21 ID:0 High latency detected(op: 2a, last request latency:1394ms, request amount:7 
$debkeywords = @("M62:", "High latency detected")

# 建立搜尋正則：鎖定第七欄
$keywordPattern = ($keywords | ForEach-Object { [regex]::Escape($_) }) -join '|'
$pattern = "^\s+\S+\s+\S+\s+\S+\s+\S+\s+\S+\s+\S+\s+($keywordPattern)"

$keywordPattern1 = ($keywords1 | ForEach-Object { [regex]::Escape($_) }) -join '|'
$pattern1 = "^\s+\S+\s+\S+\s+\S+\s+\S+\s+\S+\s+\S+\s+($keywordPattern1)"

$keywordPattern2 = ($keywords2 | ForEach-Object { [regex]::Escape($_) }) -join '|'
$pattern2 = "^\s+\S+\s+\S+\s+\S+\s+\S+\s+\S+\s+\S+\s+($keywordPattern2)"

$keywordDrvErrPattern = ($DrvErrKeywords | ForEach-Object { [regex]::Escape($_) }) -join '|'
$DrvErrPattern = "^\s+\S+\s+\S+\s+\S+\s+\S+\s+\S+\s+\S+\s+($keywordDrvErrPattern)"

$debkeywordPattern = ($debkeywords | ForEach-Object { [regex]::Escape($_) }) -join '|'

$rebuildPattern = "(" + ($LDRebuildStart -join '|') + ")"
$keywordRebuildPattern = "$rebuildPattern.* ID:(?<LD>[0-9A-Fa-f]+)"

# 定義 1GB 所佔用的 Sector 數量 (以 512-byte sector 為例)
$SectorsPerGB = 2097152
$WeekThresholdDays = 7
$minThreshhold = 10

# 建立統計物件的函式
function MediaErrorBadSector ($Entries) {
  $minSector = ($Entries | Sort-Object SectorDec)[0].SectorDec
  $duration = ($Entries | Sort-Object Time)[-1].Time - ($Entries | Sort-Object Time)[0].Time
  return [PSCustomObject]@{
    DriveID     = $Entries[0].ID
    StartSector = "0x{0:X}" -f $minSector
    SectorDec   = $minSector
    GB_Zone     = "GB_" + $Entries[0].GBZone
    StartGB     = $Entries[0].GBZone
    ErrorCount  = $Entries.Count
    StartTime   = ($Entries | Sort-Object Time)[0].Time
    EndTime     = ($Entries | Sort-Object Time)[-1].Time
    Duration    = "$([Math]::Round($duration.TotalMinutes, 1)) mins"
  }
}

function UpdateMediaErrorBadSector ($Curr, $Entries) {
  $minSector = ($Entries | Sort-Object SectorDec)[0].SectorDec
  $duration = ($Entries | Sort-Object Time)[-1].Time - ($Entries | Sort-Object Time)[0].Time
  $Curr.DriveID = $Entries[0].ID
  $Curr.StartSector = "0x{0:X}" -f $minSector
  $Curr.SectorDec = $minSector
  $Curr.GB_Zone = "GB_" + $Entries[0].GBZone
  $Curr.StartGB = $Entries[0].GBZone
  $Curr.ErrorCount = $Entries.Count
  $Curr.StartTime = ($Entries | Sort-Object Time)[0].Time
  $Curr.EndTime = ($Entries | Sort-Object Time)[-1].Time
  $Curr.Duration = "$([Math]::Round($duration.TotalMinutes, 1)) mins"
}

function Get-MediaErrorData($logFilePath) {
  $MediaErr_matches = Select-String -Path $logFilePath -Pattern $pattern -ErrorAction SilentlyContinue
  return $MediaErr_matches
}

function Set-MediaErrorMap($MediaErrorData) {
  $sortedPattern = $MediaErrorData | Sort-Object -Property @{
    # 1. 第一層：依據磁碟 ID 分組
    Expression = {
      if ($_.Line -match 'ID:(?<ID>\d+)') { [int64]$Matches['ID'] } else { 0 }
    }
  }, @{
    # 2. 第二層：1GB 區域對齊 (Grouping by GB range)
    Expression = {
      if ($_.Line -match '0x(?<Sector>[0-9A-Fa-f]+)') {
        $decSector = [Convert]::ToInt64($Matches['Sector'], 16)
        # 將 Sector 除以 1GB 的總數並取整數，得到「第幾個 GB」
        [Math]::Floor($decSector / $SectorsPerGB)
      }
      else { 0 }
    }
  }, @{
    # 3. 第三層：在同一個 1GB 區域內，按時間排序
    Expression = {
      if ($_.Line -match '(?<Date>\d{2}-\d{2}-\d{2} \d{2}:\d{2}:\d{2})') {
        [DateTime]::ParseExact($Matches['Date'], "yy-MM-dd HH:mm:ss", $null)
      }
      else { [DateTime]::MinValue }
    }
  }
  return $sortedPattern
}

function Build-ParseLog ($MediaErrorData) {
  # 1. 預處理：解析 Log 並轉為物件 (支援 64-bit Sector)
  $parsedLogs = $MediaErrorData | ForEach-Object {
    $line = $_.Line
    $foundID = $null
    $foundTime = $null
    $foundSector = 0

    # 匹配 ID (精確抓取 ID:16, ID:17 等)
    if ($line -match 'ID:(?<ID>\d+)') {
      $foundID = [int64]$Matches['ID']
    }

    # 匹配日期時間 (YY-MM-DD HH:MM:SS)
    if ($line -match '(?<DT>\d{2}-\d{2}-\d{2}\s\d{2}:\d{2}:\d{2})') {
      $foundTime = [DateTime]::ParseExact($Matches['DT'], "yy-MM-dd HH:mm:ss", $null)
    }

    # 匹配 Sector (支援 64-bit Hex，例如 0xFFFFFFFF 或更長位址)
    if ($line -match '0x(?<Hex>[0-9A-Fa-f]+)') {
      try {
        # 使用長整數處理位址
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

function Split-MediaError-Group ($LogsObj) {
  $report = @()
  $groups = $LogsObj | Group-Object ID, GBZone

  foreach ($g in $groups) {
    # 區域內按 Sector 排序，確保分析連續性
    $sortedEntries = $g.Group | Sort-Object StartGB, Time
    
    $currentEventEntries = @()
    $lastTime = $null
    foreach ($entry in $sortedEntries) {
      # 時間間隔判定：超過10 min 則分割
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


  if ($DEBUG -eq 1 ) {
    Write-Host "`n[統計摘要]" -ForegroundColor Cyan
    Write-Host "總受損 GB 區域數: " ($groups.Count)
    Write-Host "總事件處理數 (跨週分割): " ($report.Count) -ForegroundColor Yellow
    $report | Sort-Object DriveID, SectorDec | Select-Object DriveID, StartSector, GB_Zone, ErrorCount, StartTime, EndTime, Duration | Format-Table -AutoSize
  }     
  return $report
}

function Do-Analysis-MediaError-Timestamp ($LogsObj) {
  $report = @()
  $groups = $LogsObj | Group-Object ID, GBZone

  foreach ($g in $groups) {
    # 區域內按 Sector 排序，確保分析連續性
    $sortedEntries = $g.Group | Sort-Object Time, StartGB
    
    $currentEventEntries = @()
    $lastTime = $null
    $duplicated = 0
    foreach ($entry in $sortedEntries) {
      # 時間間隔判定：超過10 min 則分割
      if ($null -ne $lastTime -and [Math]::Abs(($entry.Time - $lastTime).TotalMinutes) -gt $minThreshhold) {
        $report | ForEach-Object {
          if ($($_.DriveID) -eq $currentEventEntries[0].ID -and $_.StartGB -eq $currentEventEntries[0].GBZone) {
            UpdateMediaErrorBadSector -Curr $_ -Entries $currentEventEntries
            $duplicated = 1
            break
          }
        }
        if ($duplicated -eq 0) {
          $report += MediaErrorBadSector -Entries $currentEventEntries
        }

        $currentEventEntries = @()
        $lastTime = $entry.Time
      }
      $currentEventEntries += $entry
      if ($null -eq $lastTime) {
        $lastTime = $entry.Time
      }
    }
    
    if ($currentEventEntries.Count -gt 0) {
      if ($duplicated -eq 0 ) {
        $report += MediaErrorBadSector -Entries $currentEventEntries
      }
    }
  }


  if ($DEBUG -eq 1 ) {
    Write-Host "`n[統計摘要]" -ForegroundColor Cyan
    Write-Host "總受損 GB 區域數: " ($groups.Count)
    Write-Host "總事件處理數 (跨週分割): " ($report.Count) -ForegroundColor Yellow
    $report | Sort-Object DriveID, StartTime | Select-Object DriveID, StartSector, GB_Zone, ErrorCount, StartTime, EndTime, Duration | Format-Table -AutoSize
  }     
  return $report
}

function Create-MediaErrorSect-Report($Report, $DiskMap) {
  $groupedByID = $Report | Sort-Object DriveID, SectorDec | Group-Object DriveID

  $reportOutput = New-Object System.Collections.Generic.List[string]
  $reportOutput.Add("=== Disk Media Error Analysis Report (Grouped by ID) ===")
  $reportOutput.Add("Generated on: $(Get-Date)")
  $reportOutput.Add("")

  foreach ($driveGroup in $groupedByID) {
    # 假設 $foundID 是您從 Error Log 中抓到的 ID (例如 202)
    $currentVendor = $DiskMap[$driveGroup.Name]

    $header = ">>> Drive ID: $($driveGroup.Name) (Total Events: $($driveGroup.Count))"
    $reportOutput.Add($header)
    $reportOutput.Add("-" * $header.Length)
    if ($currentVendor) {
      $reportOutput.Add($currentVendor)
    }
    
    # 格式化該 ID 下的事件清單
    $table = $driveGroup.Group | Select-Object StartSector, GB_Zone, ErrorCount, StartTime, EndTime, Duration | Format-Table -AutoSize | Out-String
    $reportOutput.Add($table)
    $reportOutput.Add("") # 空行隔開不同 ID
  }
      
  return $reportOutput
}