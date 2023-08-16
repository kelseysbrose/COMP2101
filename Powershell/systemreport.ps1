# Kelsey Rose 
# Not a huge fan of Scripting at all 

# Final Script 


## This will check if you entered in any Parameters with the Script 


param (
	[Switch]$System,
	[Switch]$Disks,
	[Switch]$Network
)


#########################################

#First, Need to gather the information for the table, Hardware Info: 

function get-system {

$ComputerHardware = Get-CIMInstance -Classname win32_Computersystem 

#Next, Need to display the information in user friendly table

$systemInfo = [PSCustomObject]@{
	Manufacturer = $ComputerHardware.Manufacturer
	Model = $ComputerHardware.Model
	SerialNumber = $ComputerHardware.SerialNumber
	SystemType = $ComputerHardware.SystemType
	TotalPhysicalMemory = "{0:N2} GB" -f ($ComputerHardware.TotalPhysicalMemory / 1GB)
#This makes it so the information showed is in GB, making it easier to read
	Domain = $ComputerHardware.Domain
  }
	



#############################
# Make it have a title 
################################
Write-Host "Computer Hardware Information" 
$systemInfo | Format-Table -Autosize



# Next, Gathering the Operating System info 


$OperatingSystem = Get-CIMInstance -Classname Win32_OperatingSystem | Select-Object -Property OperatingSystem,Version

Write-Host "Operating System Information"
$OperatingSystem |Format-Table -Autosize

}




###############

# Then you want to get the Processor Information: 

################
function get-processor {

$Processor = Get-CimInstance -ClassName win32_processor | Select-Object -Property Description,MaxClockSpeed,NumberOfCores,L1CacheSpeed,L2CacheSpeed,L3CacheSpeed

Write-Host "Processor Information"
$Processor | Format-Table -Autosize


$Processor | ForEach-Object {
	$_.PSObject.Properties | ForEach-Object {
		if ($_.Value -eq $null) {
			$_.Value = "N/A"
	}
    }
}

}


###########################

# For the Disk Drives 

function get-disks {

Write-Host "Disk Drive Information" 


$diskdrives = Get-CIMInstance CIM_diskdrive
$diskInfoList = @()

  foreach ($disk in $diskdrives) {
      $partitions = $disk | get-cimassociatedinstance -resultclassname CIM_diskpartition
      foreach ($partition in $partitions) {
            $logicaldisks = $partition | get-cimassociatedinstance -resultclassname CIM_logicaldisk
            foreach ($logicaldisk in $logicaldisks) {
		$usedSpacePercentage = ($logicaldisk.size - $logicaldisk.freespace) / $logicaldisk.size * 100

                 $diskInfo = [PSCustomObject]@{
			Manufacturer = $disk.Manufacturer
			Location = $partition.deviceid
			Drive = $logicaldisk.deviceid
			"Size(GB)" = [int]($logicaldisk.size / 1GB)
			"UsedSpace(%)" = [math]::Round($usedSpacePercentage, 2)
	}
		$diskinfolist += $diskinfo
                                                               
           }
      }
  }
          

$diskinfolist

}


###############################

## Now it's the RAM's turn 

function get-ram {

Write-Host "Ram Information"

$ramInfoList = @()
$ramTotal = 0
$physicalmemory = Get-WmiObject win32_physicalmemory
	foreach ($ram in $physicalmemory) {
	$ramInfo = [PSCustomObject]@{
		vendor = $ram.Manufacturer
		Description = $ram.Description
		Size = [int]($ram.Capacity / 1gb)
		BankAndSlot = "Bank $ram.Banklabel, Slot $ram.DeviceLocator"
	}
		$ramInfoList += $ramInfo
 }

$ramInfoList | Format-Table Vendor,Description, Size, BankAndSlot -Autosize

# Total Installed Ram 
$ramTotalGB = [int]($ramTotal / 1gb)
Write-Host "Total RAM Installed: $ramTotalGB GB"

}

###########################################################

# This will get the network information

function get-network {


Write-Host " Network Configuration"

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

}

#############################################

function get-video {

# Lastly, Video card Info 

Write-Host "Video Controller Information"

$videoInfo = Get-WmiObject -Class Win32_videoController | Select-Object -Property Name, Description, CurrentHorizontalResolution, CurrentVerticalResolution, AdapterCompadibility
$videoCardInfo = foreach ($video in $videoInfo) {
$resolution = "$($video.CurrentHorizontalResolution) x $($video.CurrentVerticalResolution)"
"$resolution ($($video.AdapterCompatibility)): $($video.name) - $($video.Description)"
}

return $videocardInfo

} 


#####################

# This will make it so you can ask for certain paramiters


# To run specific commands 

$reportSections = @()

if ($system) {
	$reportSections += get-system
	$reportSections += get-ram
	$reportSections += get-video
	
}

if ($Disks) {
	$reportSections += get-disks
}

if ($Network) {
	$reportSections += get-network
} 

if (-not $System -and -not $Disks -and -not $Network) {
	$reportSections += get-system
	$reportSections += get-processor
	$reportSections += get-disks
	$reportSections += get-ram
	$reportSections += get-network
	$reportSections += get-video

  
}

$fullReport = $reportSections 
$fullreport




######################

# End of report 