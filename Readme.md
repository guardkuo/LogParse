# Purpose
These scripts are used to analyze the support log.

# How to use
1. Executing the "searchfile.ps1" to create the list that you want to analyze.
    You can modify these varables.
    $targetFolder = "\\tsd-server\RD-Share\Japan-office"          # 搜尋起點： "." 代表目前目錄
    $minSizeMB = 0                   # 最小檔案大小 (MB)
    $daysAgo = 0                    # 最近幾天內修改過： 設為 0 代表不限日期
    $outputFile = "Search_Report_JP.txt" # 輸出的檔名
    
2. Executing LogParse.ps1.
    You must modify these 3 varables before executing.
        $inputFile = "Search_Report_EU.txt"
            Must be $outputFile in "searchfile.ps1"
        $summaryFile = "Column7_Match_Result_EU.txt"
        $summaryFile1 = "Column7_Match_Result1_EU.txt"
        
Currently, these scripts are used to analyze "media error".