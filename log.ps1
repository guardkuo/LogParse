function Write-Ticket-Title {
    param(
        [System.Collections.Generic.List[string]]$LogList,
        [string]$Qms,
        [string]$SerialNumber,
        [PSCustomObject]$StorageConf
    )
    
    $LogList.Add("QMS: $Qms SerialNumber: $SerialNumber")
    $LogList.Add("  Maximum Drive Response Timeout: $($StorageConf.maxRespTime)")
    $LogList.Add("  Maximum Tag Count: $($StorageConf.maxTag)")
    $LogList.Add("  Disk I/O Timeout(Sec): $($StorageConf.MaxIOTimeout)")
}

$Readme = @(
    "Failure",
    "1: Bad sectors exceed threshold",
    "2: Bad sectors below threshold but HDD has error",
    "0: Bad sectors below threshold and no HDD error",
    "When Failure=1, FailureReason determines error timing and type",
    "FailureReason",
    "1: IO timeout",
    "2: SMART Error",
    "3: IO Error",
    "4: HW error",
    "-1: First error is Smart Error before bad sectors exceed threshold",
    "-2: Others, need more analysis"
)

function Write-Ticket-Summary-Readme {
    $today = Get-Date -Format "yyyyMMdd"
    $excelPath = "summary$today.xlsx"
    try {
        $Readme | Export-Excel -Path $excelPath -WorksheetName "Readme" -AutoSize -BoldTopRow -FreezeTopRow
    }
    catch {
        Write-Warning "Export-Excel not available. README not exported."
    }
}

function Write-Ticket-Summary {
    param(
        [string]$CvsFilePath,
        [System.Collections.Generic.List[PSCustomObject]]$QmsDB
    )
    
    $AllDiskReport = New-Object System.Collections.Generic.List[PSCustomObject]
    
    foreach ($ticket in $QmsDB) {
        $dup = Search-TicketMap -TicketMap $QmsDB -Ticket $ticket
        if ($dup -le 0) {
            foreach ($disk in $ticket.DiskList) {
                $Path = $ticket.LogLocation
                $PathTag = $ticket.QMS
                $ExcelLink = "=HYPERLINK(""$Path"",""$PathTag"")"
                
                $AllDiskReport.Add([PSCustomObject]@{
                    Model                = $ticket.ModelName
                    QMS                  = $ticket.QMS
                    LogLocation          = $ExcelLink
                    ChassisSN            = $ticket.SN
                    MaxRespTime          = $ticket.MaxRespTime
                    MaxTag               = $ticket.MaxTag
                    MaxIOTimeout         = $ticket.MaxIOTimeout
                    Timestamp            = $ticket.ReportTime
                    DiskID               = $disk.ID
                    LDID                 = $disk.LDID
                    VendorProduct        = $disk.VendorProduct
                    Revision             = $disk.Revision
                    DiskSN               = $disk.SerialNumber
                    SizeGB               = $disk.SizeGB
                    Failure              = $disk.Failure
                    FailureReason        = $disk.FailureReason
                    numOfBadSector       = $disk.numOfBadSector
                    IgnorenumOfBadSector = $disk.IgnorenumOfBadSector
                })
            }
        }
    }
    
    $cvsFile = "$CvsFilePath.cvs"
    $AllDiskReport | Select-Object Model, QMS, ChassisSN, MaxRespTime, MaxTag, MaxIOTimeout, DiskID, LDID, VendorProduct, Revision, DiskSN, SizeGB, Failure, FailureReason, numOfBadSector, IgnorenumOfBadSector, LogLocation, Timestamp | 
    Export-Csv -Path $cvsFile -NoTypeInformation -Encoding UTF8
    
    $today = Get-Date -Format "yyyyMMdd"
    $excelPath = "summary$today.xlsx"
    
    try {
        $AllDiskReport | Select-Object Model, LogLocation, ChassisSN, MaxRespTime, MaxTag, MaxIOTimeout, DiskID, LDID, VendorProduct, Revision, DiskSN, SizeGB, Failure, FailureReason, numOfBadSector, IgnorenumOfBadSector, Timestamp | 
        Export-Excel -Path $excelPath -WorksheetName $CvsFilePath -AutoSize -BoldTopRow -FreezeTopRow
    }
    catch {
        Write-Warning "Export-Excel not available. Excel report not exported."
    }
}

function Backup-Log-Files {
    param(
        [System.IO.FileInfo]$FileInfo,
        [string]$SerialNumber,
        [string]$BaseName,
        [string]$TimeStamp,
        [string]$OutPutDir
    )
    
    $fileExtensions = $Script:FileExtensions
    
    $SrcFileName = "$SerialNumber$($fileExtensions.Deb)"
    $SrcPath = Join-Path $FileInfo.DirectoryName $SrcFileName
    if (Test-Path $SrcPath) {
        $debFileInfo = Get-Item $SrcPath
        $debbaseName = $debFileInfo.BaseName
        Copy-Item -Path $SrcPath -Destination (Join-Path $OutPutDir "${debbaseName}_${TimeStamp}.txt") -Force
    }
    
    $SrcFileName = "$SerialNumber$($fileExtensions.Evt)"
    $SrcPath = Join-Path $FileInfo.DirectoryName $SrcFileName
    if (Test-Path $SrcPath) {
        $debFileInfo = Get-Item $SrcPath
        $debbaseName = $debFileInfo.BaseName
        Copy-Item -Path $SrcPath -Destination (Join-Path $OutPutDir "${debbaseName}_${TimeStamp}.txt") -Force
    }
    
    $SrcFileName = "$SerialNumber$($fileExtensions.EvtDeb)"
    $SrcPath = Join-Path $FileInfo.DirectoryName $SrcFileName
    if (Test-Path $SrcPath) {
        $debFileInfo = Get-Item $SrcPath
        $debbaseName = $debFileInfo.BaseName
        Copy-Item -Path $SrcPath -Destination (Join-Path $OutPutDir "${debbaseName}_${TimeStamp}.txt") -Force
    }
}
