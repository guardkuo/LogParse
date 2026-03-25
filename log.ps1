function Write-Ticket-Title($LogList, $Qms, $SerialNumber, $StorageConf) {
  $LogList.Add("QMS: $Qms SerialNumber: $SerialNumber")
  $LogList.Add("  Maximum Drive Response Timeout: $($StorageConf.maxRespTime)")
  $LogList.Add("  Maximum Tag Count: $($StorageConf.maxTag)")
  $LogList.Add("  Disk I/O Timeout(Sec): $($StorageConf.MaxIOTimeout)")
}

#Variable	Value
$Readme = @(
  "Failure",
  "1:Bad sectors的數量超過threshold",
  "2:Bad sectors的數量小於threshold, 但HDD有error",
  "0:Bad sectors的數量小於threshold, 而且HDD沒有error",
  "當Failure為1時, FailureReason可以判斷HDD error發生時間及型態",
  "FailureReason",
  "1: Bad sectors的數量超過threshold, 但沒有任何error",
  "2:	第一個error是Smart Error, 而且時間早於Bad sectors的數量超過threshold",
  "3:	第一個error是Drive Fail, 而且時間早於Bad sectors的數量超過threshold",
  "4:	第一個error是LUN reset, 而且時間早於Bad sectors的數量超過threshold",
  "5:	第一個error是IO high latency, 而且時間早於Bad sectors的數量超過threshold",
  "6:	第一個error是Target reset, 而且時間早於Bad sectors的數量超過threshold",
  "-1:	第一個error是Smart Error, 而且時間早於Bad sectors的數量超過threshold",
  "當Failure為2時, FailureReason可以判斷HDD error發生的型態",
  "FailureReason",
  "1: IO timeout",
  "2:	SMART Error",
  "3:	IO Error",
  "4:	HW error",
  "-2: Others, need more analysis"
)

function Write-Ticket-Summary-Readme() {
  $today = Get-Date -Format "yyyyMMdd"
  $excelPath = "summary" + $today + ".xlsx"
  $Readme | Export-Excel -Path $excelPath -WorksheetName "Readme" -AutoSize -BoldTopRow -FreezeTopRow   
}
function Write-Ticket-Summary($cvsFilePath, $QmsDB) {
  $AllDiskReport = New-Object System.Collections.Generic.List[PSCustomObject]
  # 透過 Select-Object 的自定義屬性，將外層資訊與內層 DiskList 合併
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
  $cvsFile = $cvsFilePath + ".cvs"
  $AllDiskReport | Select-Object Model, QMS, ChassisSN, MaxRespTime, MaxTag, MaxIOTimeout, DiskID, LDID, VendorProduct, Revision, DiskSN, SizeGB, Failure, FailureReason, numOfBadSector, IgnorenumOfBadSector, LogLocation, Timestamp | 
  Export-Csv -Path $cvsFile -NoTypeInformation -Encoding UTF8
  $today = Get-Date -Format "yyyyMMdd"
  $excelPath = "summary" + $today + ".xlsx"
  $AllDiskReport | Select-Object Model, LogLocation, ChassisSN, MaxRespTime, MaxTag, MaxIOTimeout, DiskID, LDID, VendorProduct, Revision, DiskSN, SizeGB, Failure, FailureReason, numOfBadSector, IgnorenumOfBadSector, Timestamp | 
  Export-Excel -Path $excelPath -WorksheetName $cvsFilePath -AutoSize -BoldTopRow -FreezeTopRow
}

function Backup-Log-Files($FileInfo, $SerialNumber, $BaseName, $TimeStamp, $OutPutDir) {
  # deb
  if (-not (Test-Path $OutPutDir)) {
    return
  }
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