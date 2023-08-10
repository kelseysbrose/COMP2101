# This script will make a table for the ipconfig information that is enabled. 

$adapterConfigurations = Get-CimInstance Win32_NetworkAdapterConfiguration | Where-Object { $_.IPEnabled -eq $true }

# This gathered the information that will be displayed with the table below in the differnt headers is the information comes back enabled or true

$ipConfigReport = $adapterConfigurations | ForEach-Object {
	$dnsServers = $_.DNSServerSearchOrder -join ','
	$ipAddress = $_.IPAddress -join ','
	$subnetMasks = $_.IPSubnet -join ','

# Making the custom object table below for the headers specified. 

	[PSCustomObject]@{
	AdapterDescription =$_.Description
	Index = $_.Index
	IPAdress = $ipaddress
	SubnetMask = $subnetMasks
	DNSDomain = $_.DNSDomain
	DNSServer = $dnsServers
    }
}

# This command is to format the table and autosize it

$ipConfigReport | Format-Table -Autosize