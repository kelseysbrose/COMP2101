parm (
	[Switch]$System,
	[Switch]$Disks,
	[Switch]$Network
)


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
	


# Make it have a title 

Write-Host "Computer Hardware Information" 
$systemInfo | Format-Table -Autosize



# Next, Gathering the Operating System info 


$OperatingSystem = Get-CIMInstance -Classname Win32_OperatingSystem | Select-Object -Property OperatingSystem,Version

Write-Host "Operating System Information"
$OperatingSystem |Format-Table -Autosize

}




# Then you want to get the Processor Information: 

function get-processor {

$Processor = Get-CimInstance -ClassName win32_processor | Select-Object -Property Description,MaxClockSpeed,NumberOfCores,L1CacheSpeed,L2CacheSpeed,L3CacheSpeed

Write-Host "Processor Information"
$Processor | Format-Table -Autosize


$Processor | ForEach-Object {
	$_.PSObject.Properties | ForEach-Object {
		if ($_.Value -eq "Null") {
			$_.Value = "N/A"
	}
    }
}

}



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



function get-video {

# Lastly, Video card Info 

$VideoInfoList = @()
$VideoControllers = Get-WmiObject win32_videoController
foreach ($video in $videoControllers) {
	$resolution = "$($video.CurrentHorizontalResolution) x $($video.CurrentVerticalResolution)"
	$videoInfo = [PSCustomObject] {
	Vendor = $video.Processor
	Description = $video.Description
	Resolution = $resolution
	}
$VideoInfoList += $videoinfo
}

$videoInfoList | Format-Table Vendor, Description, Resolution -Autosize

} 

# To run specific commands 

if ($system) {
	'$reportSections' = @(
	(get-system),
	(get-ram),
	(get-video)
	)
}

elseif ($Disks) {
	'$reportSections' = @(get-disks)
}

elseif ($Network) {
	'$reportSections' = @(get-network)
} 

else {
	'$reportSections' = @(
	(get-system),
	(get-processor),
	(get-disks),
	(get-ram),
	(get-network),
	(get-video)

  )
}

$fullReport = $reportSections -join "'r'n"
$fullreport
