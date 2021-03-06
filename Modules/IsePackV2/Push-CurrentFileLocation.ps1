function Push-CurrentFileLocation {
    <#
    .Synopsis
        Runs Push-Location into the location of the current file
    .Description
        Runs Push-Location into the location of the current file
    .Example
        Push-CurrentFileLocation
    #>
    param()
	$currentScriptPath = Get-CurrentScriptPath
	if ($currentScriptPath) {
		Push-Location (Split-Path $currentScriptPath )
	}    
}