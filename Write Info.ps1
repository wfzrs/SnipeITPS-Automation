$SnipeShare = "INSERT SHARE HERE"

Get-ChildItem $snipeshare -Filter *.csv | Select-Object -ExpandProperty FullName | Import-Csv | Export-Csv $snipeshare\merged\merged.csv -NoTypeInformation -force

$WorkstationFile = "$SnipeShare\merged\merged.csv"

$apikey = "INSERT API KET HERE"
$url = "INSERT URL HERE"

Connect-SnipeitPS -url $url -apiKey $apikey
$Categoryid = "3"

Import-Csv $WorkstationFile | ForEach-Object {

    
    $Hostname      = $_.Name
    $Serial        = $_.Asset_Tag
    $Model         = $_.Model_Number
    $Manufacturer  = $_.Manufacturer
    $CpuInfo       = $_.CPU
    $status        = $_.Status
    $OSInfo        = $_.OS
    $LastUser      = $_.Last_User
    $MemorySmall   = $_.Physical_RAM
    $DiskSpace     = $_.Total_Disk_Space

$modelSelection = Get-SnipeitModel -search  $Model


if($modelSelection -eq $null){

    $NewModel = " $Model"

    $Assetmanufacturer = Get-SnipeitManufacturer -search $Manufacturer

        if($Assetmanufacturer -eq $null)
         {
         New-SnipeitManufacturer -name $Manufacturer

         $Assetmanufacturer = Get-SnipeitManufacturer -search $Manufacturer

         }

    New-SnipeitModel -name $NewModel -category_id $Categoryid -manufacturer_id ($Assetmanufacturer).id -fieldset_id 2
 
    $modelSelection = Get-SnipeitModel -search  $Model
}
 


$assetExists = Get-SnipeitAsset -search $Hostname


if($assetExists.name -eq $Hostname){

    Set-SnipeitAsset -id $($assetExists.id) -Name $Hostname -asset_tag $Serial -serial $Serial -Model_id $modelSelection.id -Status "2" -Customfields  @{ "_snipeit_operating_system_3" = "$OSInfo" ; "_snipeit_system_memory_2" = "$MemorySmall" ; "_snipeit_last_user_4" = "$LastUser" ; "_snipeit_disk_space_5" = "$DiskSpace" ; "_snipeit_cpu_6" = "$CpuInfo"} 
    
     write-host "Registered $Hostname"
}

else{

    Write-Host "Asset Exists, $assetExists.id $Hostname $Serial $Manufacturer"

    New-SnipeitAsset -Name $Hostname -asset_tag $Serial -serial $Serial -Model_id $modelSelection.id -Status "2" -Customfields  @{ "_snipeit_operating_system_3" = "$OSInfo" ; "_snipeit_system_memory_2" = "$MemorySmall" ; "_snipeit_last_user_4" = "$LastUser" ; "_snipeit_disk_space_5" = "$DiskSpace" ; "_snipeit_cpu_6" = "$CpuInfo"} 
}

}

