#First, Need to gather the information for the table, Hardware Info: 

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
	
# Replacing the empty values with N/A

$systemInfo | ForEach-Object {
	$_.PSObject.Properties | ForEach-Object {
		if ($_.Value -eq "") {
			$_.Value = "N/A"
	}
    }
}


# Make it have a title 

Write-Host "Computer Hardware Information" 
$systemInfo | Format-Table -Autosize



# Next, Gathering the Operating System info 


$OperatingSystem = Get-CIMInstance -Classname Win32_OperatingSystem | Select-Object -Property OperatingSystem,Version

Write-Host "Operating System Information"
$OperatingSystem |Format-Table -Autosize

# Replacing the empty values with N/A

$OperatingSystem | ForEach-Object {
	$_.PSObject.Properties | ForEach-Object {
		if ($_.Value -eq " ") {
			$_.Value = "N/A"
	}
    }
}


# Then you want to get the Processor Information: 

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

