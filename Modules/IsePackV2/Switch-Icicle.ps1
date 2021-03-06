function Switch-Icicle
{
    <#
    .Synopsis
        Switches the visibility of an icicle
    .Description
        Shows an icicle that is hidden.  Hides an Icicle that is shown.  Icicles are little apps for the PowerShell ISE.
    .Example
        Get-Icicle | Shows-Icicle
        # Shows all icicles
    .Link
        Hide-Icicle
    .Link
        Get-Icicle
    .Link
        Add-Icicle
    .Link
        Remove-Icicle
    #>
    [CmdletBinding(SupportsShouldProcess=$true,ConfirmImpact='Low')]    
    [OutputType([Nullable])]
    param(
    # The Icicle that will be hidden.
    [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
    [ValidateScript({
        if ($_ -isnot [Microsoft.PowerShell.Host.ISE.ISEAddOnTool]) {
            throw "Must be an ISE Add On"
        }
        return $true
    })]
    $Icicle,

    # If set, will output the icicle
    [Switch]
    $PassThru
    )
    
    process {
        if ($psCmdlet.ShouldProcess($icicle.Name)) {             
            if ($Icicle.IsVisible) {
                $Icicle|  Hide-Icicle
            } else {
                $Icicle|  Show-Icicle
            }
        }
    }
}

 
