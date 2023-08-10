$env:path += ";$home/documents/github/comp2101/powershell"
new-item -path alias:np -value notepad

function welcome {
	$welcome = "Hello, How are you today"
}


write-output "Welcome to planet $env:computername Overlord $env:username"
write-output "$welcome"

function get-mydisks {
	$diskinfo = Get-Wmiobject win32_DiskDrive | Select-object Manufacturer, Model, SerialNumber, FirmwareRevision, Size
	$diskinfo | Format-Table -Autosize
}