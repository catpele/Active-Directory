###############################################################
# Locates expired accounts over 3 months old and deletes them #
###############################################################

# Variables
$today = Get-Date
$timestamp = Get-Date -Format ddMMyyy
$path = "C:\Scripts\Logs\ad-clean-users-"+$timestamp+".txt"
$logfolder = "C:\Scripts\Logs"
$annual = $today.AddDays(-365)
$limit = $today.AddDays(-90)
$expiredusers = Search-ADAccount -AccountDisabled -UsersOnly | get-aduser -Properties whenChanged | where {$_.Name -notlike "*Template" -AND $_.Name -notlike "Guest" -AND $_.Name -notlike "krbtgt"}

# Start Logging
Start-Transcript -Path $path

#Loops through Disabled Accounts
foreach ($expireduser in $expiredusers) {
	$datedisabled = $expireduser.whenChanged
	$sam = $expireduser.SamAccountName
	
	if ($datedisabled -lt $limit) {
		Remove-ADUser -Identity $sam -Confirm:$false
		$global:deleted = $expiredusers
	}
	elseif ($datedisabled -ge $limit) {
		$global:disabled = $expiredusers
	}
}

# Outputs the Disabled and Deleted accounts
Write-Output "--- Accounts Deleted ---"
if ($deleted -eq $null) {
	Write-Output "None"
}
else {
	Write-Output $deleted.Name
}

Write-Output "--- Accounts Disabled < 30 days ago ---" $disabled.Name

Stop-Transcript

# Removes log files older than 1 year
Get-ChildItem $logfolder | Where-Object {$_.LastWriteTime -lt $annual} | Remove-Item

# Emails the daily log to IT
Send-MailMessage -SmtpServer <emailserver> -From "<emailsender>" -Subject "AD Account Cleanup" -To "<emailrecipient>" -Attachments $path
