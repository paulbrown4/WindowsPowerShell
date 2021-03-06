param(
[Parameter(ParameterSetName='TestModuleInfo',Mandatory=$true,ValueFromPipeline=$true)]
[Management.Automation.PSModuleInfo]
$ModuleInfo
)
    
process {
    $aboutTopics =
        $ModuleInfo | 
            Split-Path | 
            Get-ChildItem -Filter "$(Get-Culture)" | 
            Get-ChildItem -Filter *walkthru.help.txt
    
    if (-not $aboutTopics) {        
        Write-Error "$ModuleInfo does not have a walkthru topic"
    }
}

 
