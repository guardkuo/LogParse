# --- 設定搜尋條件 (根據需求修改) ---
$targetFolder = "\\tsd-server\RD-Share\Japan-office"          # 搜尋起點： "." 代表目前目錄
$fileNamePattern = "*.evt.0.5.full.txt"           # 檔名關鍵字： 例如 "report*" 或 "*" (找全部)
$minSizeMB = 0                   # 最小檔案大小 (MB)
$daysAgo = 0                    # 最近幾天內修改過： 設為 0 代表不限日期
$outputFile = "Search_Report_JP.txt" # 輸出的檔名

# 計算日期門檻
$dateThreshold = (Get-Date).AddDays(-$daysAgo)

write-host "Searching, please wait..." -ForegroundColor Cyan

# 執行搜尋，僅選取 FullName (完整路徑)
# -ExpandProperty 可以確保輸出的是純字串，沒有標頭
$results = Get-ChildItem -Path $targetFolder -Filter $fileNamePattern -Recurse -ErrorAction SilentlyContinue | 
Where-Object { 
  !$_.PSIsContainer -and 
  $_.Length -ge ($minSizeMB * 1MB) -and 
  ($daysAgo -eq 0 -or $_.LastWriteTime -ge $dateThreshold)
} |
Select-Object -ExpandProperty FullName

# 檢查是否有結果並寫入檔案
if ($results) {
  $results | Out-File -FilePath $outputFile -Encoding utf8
  write-host "Search is finished！Find $($results.Count) fiies" -ForegroundColor Green
  write-host "Results are saved to: $outputFile" -ForegroundColor Green
}
else {
  write-host "No File is found。" -ForegroundColor Red
}

pause
