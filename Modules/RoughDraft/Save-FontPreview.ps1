function Save-FontPreview
{
    <#
    .Synopsis
        Saves font preview files 
    .Description
        Saves font preview files to a directory, and makes a web page to display them
    .Example
        Get-Font | 
            Sort-Object | 
            Save-FontPreview
    .Link
        Get-Font
    #>
    param(    
    #|Default Kartika 
    [Parameter(Mandatory=$true,
        ValueFromPipeline=$true,
        ValueFromPipelineByPropertyName=$true)]
    [ValidateScript({
    if (-not $script:FontCache) {
        $script:FontCache = Get-Font
    }
    if ($script:FontCache -contains $_) {
        return $true
    } else {
        throw "$_ is not an installed font.  Installed fonts: $script:FontCache "
    }
    })]
    [string]$FontFamily,
    
    # The font size
    #|Default 36
    [ValidateRange(8,72)]
    [int]$FontSize = 36,
    #|Default The Quick Brown Fox Jumped Over The Lazy Dog    
    [string]$SampleText = "The Quick Brown Fox Jumped Over The Lazy Dog",    
    
    # The directory that should store the font preview
    [string]$OutputDirectory
    )

    begin {
        $fontPreviewMarkdown = ""
    }
    
    process {
        if (-not $psBOundParameters.OutputDirectory) {
            $OutputDirectory = $pwd
        }


        if (-not (Test-Path $OutputDirectory)) {
            New-Item -ItemType Directory -Path $OutputDirectory |
                Out-Null
        }


        
        $fontFamilyFile = Join-Path $OutputDirectory "${FontFamily}.png"
        Write-Progress "Generating Font Samples" "$fontFamily"
        $bytes = Show-Logo -Text $SampleText -Font $FontFamily -Size $FontSize -AsType png -InMemory 
        $fontPreviewMarkdown += "
### $FontFamily
! [$FontFamily](${fontFamily}.png)
"
        [IO.File]::WriteAllBytes($fontFamilyFile, $bytes)
    }

    end {
        ConvertFrom-Markdown -Markdown $fontPreviewMarkdown |
            Set-Content $OutputDirectory\index.html
        
    }
}