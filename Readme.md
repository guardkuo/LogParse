# Purpose
These scripts are used to analyze the support log.

# How to use
1. Executing the "searchfile.ps1" to create the list that you want to analyze.
    You can modify these varables.
    $targetFolder = "\\tsd-server\RD-Share\Japan-office"          # 搜尋起點： "." 代表目前目錄
    $minSizeMB = 0                   # 最小檔案大小 (MB)
    $daysAgo = 0                    # 最近幾天內修改過： 設為 0 代表不限日期
    $outputFile = "Search_Report_JP.txt" # 輸出的檔名
2. Configuration files.
    LogParseCfg.ps1
      $inputFile = "Search_Report.txt"
      $resultFile = "Match_Result.txt"
      $resultFile1 = "All_Match_Result.txt"
      $errrologFile = "error.log"
      $logFile = "LogParse.log"
      $analysisFile = "AnalysisReport"
      $summaryFile = "Summary"
      $minMatchCount = 20  # 設定門檻：少於 20 行則忽略
3. Executing LogParse.ps1.
    Now, these scripts are used to analyze "media error".