function Write-Ticket-Title($LogList, $Qms, $SerialNumber, $StorageConf) {
  $LogList.Add("QMS: $Qms SerialNumber: $SerialNumber")
  $LogList.Add("  Maximum Drive Response Timeout: $($StorageConf.maxRespTime)")
  $LogList.Add("  Maximum Tag Count: $($StorageConf.maxTag)")
  $LogList.Add("  Disk I/O Timeout(Sec): $($StorageConf.MaxIOTimeout)")
}

function Write-Ticket-Summary($cvsFilePath, $QmsDB) {
  $AllDiskReport = New-Object System.Collections.Generic.List[string]
  # 透過 Select-Object 的自定義屬性，將外層資訊與內層 DiskList 合併
  foreach ($ticket in $QmsDB) {
    foreach ($disk in $ticket.DiskList) {
      $Path = $ticket.LogLocation
      $PathTag = $ticket.QMS
      $ExcelLink = "=HYPERLINK(""$Path"",""$PathTag"")"
      $AllDiskReport += [PSCustomObject]@{
        Model                = $ticket.ModelName
        QMS                  = $ticket.QMS
        LogLocation          = $ExcelLink
        ChassisSN            = $ticket.SN  # 區分機箱 SN 與硬碟 SN
        MaxRespTime          = $ticket.MaxRespTime
        MaxTag               = $ticket.MaxTag
        MaxIOTimeout         = $ticket.MaxIOTimeout
        Timestamp            = $ticket.ReportTime
        # ... 其他總體資訊 ...

        # Disk 詳細資訊
        DiskID               = $disk.ID
        LDID                 = $disk.LDID
        VendorProduct        = $disk.VendorProduct
        Revision             = $disk.SerialNumber
        DiskSN               = $disk.SerialNumber
        SizeGB               = $disk.SizeGB
        Failure              = $disk.Failure
        FailureReason        = $disk.FailureReason
        numOfBadSector       = $disk.numOfBadSector
        IgnorenumOfBadSector = $disk.IgnorenumOfBadSector
      }
    }
  }
  $cvsFile = $cvsFilePath + ".cvs"
  $AllDiskReport | Select-Object Model, QMS, ChassisSN, MaxRespTime, MaxTag, MaxIOTimeout, DiskID, LDID, VendorProduct, SizeGB, Failure, FailureReason, numOfBadSector, IgnorenumOfBadSector, LogLocation, Timestamp | 
  Export-Csv -Path $cvsFile -NoTypeInformation -Encoding UTF8
  $excelPath = "summary.xlsx"
  $AllDiskReport | Select-Object Model, LogLocation, ChassisSN, MaxRespTime, MaxTag, MaxIOTimeout, DiskID, LDID, VendorProduct, SizeGB, Failure, FailureReason, numOfBadSector, IgnorenumOfBadSector, Timestamp | 
  Export-Excel -Path $excelPath -WorksheetName $cvsFilePath -AutoSize -BoldTopRow -FreezeTopRow
}

function Backup-Log-Files($FileInfo, $SerialNumber, $BaseName, $TimeStamp, $OutPutDir) {
  # deb
  $SrcFileName = "$SerialNumber.deb.0.5.full.txt"
  $SrcPath = Join-Path $FileInfo.DirectoryName $SrcFileName
  if (Test-Path $SrcPath) {
    $debFileInfo = Get-Item $SrcPath
    $debbaseName = $debFileInfo.BaseName # 不含副檔名的檔名
    Copy-Item -Path $SrcPath -Destination (Join-Path $OutPutDir "${debbaseName}_${TimeStamp}.txt") -Force
  }
  $SrcFileName = "$SerialNumber.evt.0.5.full.txt"
  $SrcPath = Join-Path $FileInfo.DirectoryName $SrcFileName
  if (Test-Path $SrcPath) {
    $debFileInfo = Get-Item $SrcPath
    $debbaseName = $debFileInfo.BaseName # 不含副檔名的檔名
    Copy-Item -Path $SrcPath -Destination (Join-Path $OutPutDir "${debbaseName}_${TimeStamp}.txt") -Force
  }
  $SrcFileName = "$SerialNumber.evt+deb.0.5.full.txt"
  $SrcPath = Join-Path $FileInfo.DirectoryName $SrcFileName
  if (Test-Path $SrcPath) {
    $debFileInfo = Get-Item $SrcPath
    $debbaseName = $debFileInfo.BaseName # 不含副檔名的檔名
    Copy-Item -Path $SrcPath -Destination (Join-Path $OutPutDir "${debbaseName}_${TimeStamp}.txt") -Force
  }

}