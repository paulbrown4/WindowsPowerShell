function Get-Font
{
    <#
    .Synopsis
        Gets the fonts available
    .Description
        Gets the fonts available on the current installation    
    .Example
        Get-Font
    .Example
        Get-Font -IncludeDetail        
    #>
    [OutputType([Windows.Media.FontFamily], [string])]
    param(
    # If set, finds finds with this name
    [Parameter(Position=0,ValueFromPipelineByPropertyName=$true)]
    [string]$Name,
    # If set, includes all details about the font.

    [switch]$IncludeDetail
    )
    
    begin {
        $fontList = [Windows.Media.Fonts]::SystemFontFamilies
    }

    process {
        #region Filter Font List
        if ($Name.Trim()){
            
            $currentFontList = foreach ($f in $fontList) {
                if ($f.Source -like "$name*") {
                    $f
                }
            }
        } else {
            $currentFontList = $fontList
        }
        #endregion Filter Font List

        if ($IncludeDetail) {
             $currentFontList  | 
                Add-Member ScriptProperty Name { $this.Source } -PassThru -Force
        } else {
            $currentFontList  | 
                Select-Object -ExpandProperty Source
        }

    }
    
}