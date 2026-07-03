# Purpose
These scripts are used to analyze the support log.

# How to use
1. Executing the "searchfile.ps1" to create the list that you want to analyze. You can modify these varables.

    $targetFolder = "\\tsd-server\RD-Share\Japan-office"          # 搜尋起點： "." 代表目前目錄

    $minSizeMB = 0                   # 最小檔案大小 (MB)

    $daysAgo = 0                    # 最近幾天內修改過： 設為 0 代表不限日期

    $outputFile = "Search_Report_JP.txt" # 輸出的檔名

    $Folder = @("Japan-office", "Pan-asia-office", "CN", "EU", "USA_office") # 允許搜尋多個子目錄

2. Configuration files.

    LogParseCfg.ps1

      $inputFile = "Search_Report.txt"

      $resultFile = "Match_Result.txt"

      $resultFile1 = "All_Match_Result.txt"

      $errrologFile = "error.log"

      $logFile = "LogParse.log"

      $analysisFile = "AnalysisReport"

      $summaryFile = "Summary"

      $mediaErrorSummaryFile = "mediaerror_event.txt"

      $minMatchCount = 20  # 設定門檻：少於 20 行則忽略

      $DefMaxNumOfBadSector = 9 # 設定門檻：大於 9 個區域(不含)才處理

      $DefMinNumOfBadSector = 2  #設定門檻, 大於 2 個區域(不含)才記錄

      $BackupLogFile = 0 # 是否要備份Log

    dhioParse.ps1

      DHIO files存放的路徑, 目前不支援子目錄. 但支援多路徑
      $targetFolderList = @("\\172.22.111.5\RD-share\Japan-office\MUL-799909\10 DHIO\disk5001_to_disk5010",
        "\\172.22.111.5\RD-share\Japan-office\MUL-799909\10 DHIO\disk5002_to_disk5010")

      針對不同的問題, 可設定不同的latency. 例如可以縮小這個值, 分析SSD.
      $LongReadLatency = 90
      $LongWriteLatency = 0


      If more than `$maxOfGroupHighLatency` HDDs exhibit high latency within the same time slot, we assume the issue lies with the system—for example, the CPU being overloaded.
      $maxOfGroupHighLatency = 3

3. Executing LogParse.ps1 or dhioParse.ps1 .

    Now, these scripts are used to analyze "media error" or the latency of hard disks or ssd.