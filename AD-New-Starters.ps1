###################################################
# Reports on Accounts created in the last 30 days	#
###################################################

# Variables
$today = Get-Date
$timestamp = Get-Date -Format ddMMyyy
$path = "C:\Scripts\Logs\starters-"+$timestamp+".txt"
$logfolder = "C:\Scripts\Logs"
$annual = $today.AddDays(-365)
$month = $today.AddDays(-30)

# Start Logging
Start-Transcript -Path $path

# Outputs the Accounts created in the last 30 days
Write-Output "--- Accounts Created - Last 30 Days ---"
Get-ADUser -Filter * -Properties Created, Company | where {$_.Created -gt $month} | Select Name, Company, Created | Out-Default

# Removes log files older than 1 year
Get-ChildItem $logfolder | Where-Object {$_.LastWriteTime -lt $annual} | Remove-Item

Stop-Transcript
# Emails the daily log to IT

Send-MailMessage -SmtpServer <emailserver> -From "<senderemail>" -Subject "New Starters - Past 30 Days" -To "<recipientemail>" -Attachments $path
