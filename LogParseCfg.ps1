# EVENT ID
#220A0148: Drive fail
#220A0188: Drive Failure
#020AA182: clone
#320A4509: LD fatal
#12084204: Drive Event Detected-Starting Clone

#220A0749: Media Scan Failed
#22084202: No availible drive for cloning
#22084285: Drive Event Detected-Clone Failed
#22080581: Timeout Waiting for I/O to Complete
#21080282: Gross Phase/Signal Error Detected
#020A8305: Rebuild
#22081882

# 1. 設定關鍵字與檔案路徑
# media error
$keywords = @("02081382", "02081342", "02081341", "02081381")
# drive fail, rebuild, clone, io error
$keywords1 = @("21081282", "220A0188", "220A0187", "220A0185", "220A0148", "12084204")

# events we want
$keywords2 = @("02081382", "02081342", "02081341", "02081381", "220A0787", "21081282", "220A0188", "22080581", "020A8305", "020AA182", "320A4509", "220A0187", "22084205", "22084202", "020A8402", "21080282", "22080181", "220A1182", "12084243", "12084244", "020AA142", "020AA281", "220A0185", "12084204", "22080541", "22080542", "220A0148", "21080242", "22080141", "02081781", "22084285", "12084284", "220A0749", "22081882", "02019203", "02018101")

$debkeywords = @("M62:", "High latency detected")

# 建立搜尋正則：鎖定第七欄
$keywordPattern = ($keywords | ForEach-Object { [regex]::Escape($_) }) -join '|'
$pattern = "^\s+\S+\s+\S+\s+\S+\s+\S+\s+\S+\s+\S+\s+($keywordPattern)"

$keywordPattern1 = ($keywords1 | ForEach-Object { [regex]::Escape($_) }) -join '|'
$pattern1 = "^\s+\S+\s+\S+\s+\S+\s+\S+\s+\S+\s+\S+\s+($keywordPattern1)"

$keywordPattern2 = ($keywords2 | ForEach-Object { [regex]::Escape($_) }) -join '|'
$pattern2 = "^\s+\S+\s+\S+\s+\S+\s+\S+\s+\S+\s+\S+\s+($keywordPattern2)"

$debkeywordPattern = ($debkeywords | ForEach-Object { [regex]::Escape($_) }) -join '|'


$inputFile = "Search_Report_JP.txt"
$summaryFile = "Column7_Match_Result_JP.txt"
$summaryFile1 = "Column7_Match_Result1_JP.txt"
$errrologFile = "error.log"
$logFile= "LogPares.log"
$minMatchCount = 20  # 設定門檻：少於 20 行則忽略

# 定義 1GB 所佔用的 Sector 數量 (以 512-byte sector 為例)
$SectorsPerGB = 2097152
$WeekThresholdDays = 7
$minThreshhold = 10