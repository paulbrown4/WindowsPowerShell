param([string]$ModuleName)
$moduleRoot = Get-Module $moduleName | Split-Path

$pipeworksManifestPath = Join-Path $moduleRoot "$($ModuleName).Pipeworks.psd1"
$pipeworksManifest = if (Test-Path $pipeworksManifestPath) {
try {                     
    & ([ScriptBlock]::Create(
        "data -SupportedCommand Add-Member, New-WebPage, New-Region, Write-CSS, Write-Ajax, Out-Html, Write-Link { $(
            [ScriptBlock]::Create([IO.File]::ReadAllText($pipeworksManifestPath))                    
        )}"))            
} catch {
    Write-Error "Could not read pipeworks manifest" 
    return
}
}
    

$table = $pipeworksManifest.ParkingMeter.MeterTable
$storageAccount = Get-SecureSetting -Name $pipeworksManifest.ParkingMeter.StorageAccountSetting -ValueOnly
$storageKey = Get-SecureSetting -Name $pipeworksManifest.ParkingMeter.StorageKeySetting -ValueOnly


$tableExists = Get-AzureTable -TableName $table -StorageAccount $storageAccount -StorageKey $storageKey 

if (-not $tableExists) { 
    return
}


foreach ($meter in @($pipeworksManifest.ParkingMeter.Meters)) {
    $meterObject = New-Object PSObject -Property $meter
    $itemsInPartition = Search-AzureTable -TableName $table -Filter "PartitionKey eq '$($meter.Partition)'"
    $itemsInPartition  | 
        Group-Object UserID |
        ForEach-Object {
            $userRecord = 
                Search-AzureTable -TableName $pipeworksManifest.UserTable.Name -Filter "PartitionKey eq '$($pipeworksManifest.UserTable.Partition)' and RowKey eq '$($_.Name)'"
         
            if (-not $userRecord) { return }        
            $meterCost = ([Double]$meterObject.Cost) * $_.Group.Count
            $balance = 
                $userRecord.Balance -as [Double]
                    
                        
            $balance += $meterCost
            $userRecord  |
                Add-Member NoteProperty Balance $balance -Force -PassThru |                        
                Update-AzureTable -TableName $pipeworksManifest.UserTable.Name -Value { $_ } 

        }            
}