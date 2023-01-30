$s = $Env:Computername

$SnipeShare = "INSERT SHARE HERE"

$WorkstationFile = "$SnipeShare\$s.csv"

Try { [io.file]::OpenWrite($WorkstationFile).close() }
Catch { 
    Write-Warning "Unable to write to output file $WshareName" 
    return 1;
}


$CpuInfo =  (Get-WmiObject win32_processor).name


$SysInfo = Get-Ciminstance -class win32_ComputerSystem

    $Model = $Sysinfo.model

    $MemorySmall = [math]::Ceiling($SysInfo.TotalPhysicalMemory / 1024 / 1024 / 1024)

    $Hostname = $SysInfo.name


$BiosInfo = Get-Ciminstance Win32_BIOS

    $Manufacturer = $BiosInfo.Manufacturer

    $Serial = $BiosInfo.SerialNumber


$DiskInfo = Get-Ciminstance Win32_logicalDisk
    
    $DiskSpace = $DiskInfo | Where-Object caption -eq "C:" | foreach-object { Write-Output "$('{0:N2}' -f ($_.Size/1gb)) GB " }


$OSInfo = (Get-CIMinstance Win32_OperatingSystem).caption


$LastUser = $(Get-WMIObject -class Win32_ComputerSystem | select username).username


$status = "Ready to Deploy"

$Categoryid = "3"


Foreach ($CPU in $CPUInfo) {
    $infoObject = [PSCustomObject][ordered]@{
      	
        "Name"                   = $Hostname
        "Asset_Tag"              = $Serial
        "Model_Number"           = $Model
        "Manufacturer"           = $Manufacturer
        "Serial Number"          = $Serial
        "CPU"                    = $CpuInfo
        "Status"                 = $status
        "OS"                     = $OSInfo
        "Last_User"              = $LastUser
        "Physical_RAM"           = $MemorySmall
        "Total_Disk_Space"       = $DiskSpace
    }
}


$infoObject | Export-Csv -Path $WorkstationFile -Force -NoTypeInformation -Encoding UTF8 
