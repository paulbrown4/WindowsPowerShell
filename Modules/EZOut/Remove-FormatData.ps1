function Remove-FormatData
{
    <#
    .Synopsis
        Removes formatting to the current session.
    .Description
        The Remove-FormatData command removes the formatting data for the current session.                
    #>
    [CmdletBinding(DefaultParameterSetName="ByModule")]
    param(
    # The module containing formatting information that should be unloaded.  
    # Since the only modules Remove-FormatData will remove are ones that are not 
    # globally visible, the only way to provide information to this parameter is to 
    # use the -PassThru parameter of Add-FormatData
    [Parameter(Mandatory=$true,
        ValueFromPipeline=$true,
        ParameterSetName="ByModule")]
    [Management.Automation.PSModuleInfo]
    [ValidateScript({
        if ($formatModules -notcontains $_) {
            throw "$_ was not added with Add-FormatData"
        }
        return $true
    })]
    $FormatModule,
    
    # The name of the format module.  If there is only one type name,then 
    # this is the name of the module.
    [Parameter(ParameterSetName='ByModuleName',
        Mandatory=$true,
        ValueFromPipeline=$true)]
    [String]
    $ModuleName
    )    
    
  
    process {
        # Use @() to walk the hashtable first, 
        # so we can modify it within the foreach
        foreach ($kv in @($FormatModules.GetEnumerator())) {
            if ($psCmdlet.ParameterSetName -eq "ByModuleName") {
                if ($kv.Key -eq $ModuleName) {
                    Remove-Module $kv.Key                    
                    $null = $FormatModules.Remove($kv.Key)
                }
            } elseif ($psCmdlet.ParameterSetName -eq "FormatModule") {
                if ($kv.Value -eq $FormatModule) {
                    Remove-Module $kv.Key                    
                    $null = $FormatModules.Remove($kv.Key)                    
                }
            }           
        }
    }    
}
