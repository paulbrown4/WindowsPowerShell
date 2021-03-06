$moduleRoot = Get-Module IsePackV2 | Split-Path

$formatting = Write-FormatView -TypeName IcicleInfo -Action {
    if ($request -and $response) {
        # Web view
        "<h3>$($_.Name)</h3>
        <hr/>
        <blockquote>
            $(Write-ScriptHTML -Script $_.Icicle )
        </blockquote>
        "
    } else {
        # Local view
        Write-Host $_.Name
        Write-Host ("-" * $_.Name.Length)
        Write-Host ($_.Icicle)
        ""
    }
} | 
    Out-FormatData

$formatPath  = Join-Path $moduleRoot "IsePackV2.Format.ps1xml"
$formatting |
    Set-Content $formatPath   
