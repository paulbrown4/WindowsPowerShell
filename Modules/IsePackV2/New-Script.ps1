function New-Script 
{
    [CmdletBinding(DefaultParameterSetName='Text')]
    param(
    [Parameter(Mandatory=$true,
        ValueFromPipelineByPropertyName=$true,
        ParameterSetName='Text')]
    [string]
    $Text,
    

    [Parameter(Mandatory=$true,
        ValueFromPipelineByPropertyName=$true,
        ParameterSetName='EmptyFile')]
    [Switch]
    $EmptyFile
    )

    process 
    {
        if ($psCmdlet.ParameterSetName -eq 'Text') {
            if ($Host.Name -eq 'PowerGUIScriptEditorHost') {
                $NewWindow = [Quest.PowerGUI.SDK.ScriptEditorFactory]::CurrentInstance.DocumentWindows.Add("")
                $newWindow.Activate()
                $newWindow.Document.append($Text)
            } elseif ($Host.Name -eq 'Windows PowerShell ISE Host') {
                $count = $psise.CurrentPowerShellTab.Files.count
                $psIse.CurrentPowerShellTab.Files.Add() | Out-Null
                $Newfile = $psIse.CurrentPowerShellTab.Files[$count]
                $Newfile.Editor.Text = $Text            
            }        
        } elseif ($psCmdlet.ParameterSetName -eq '') {
            if ($Host.Name -eq 'PowerGUIScriptEditorHost') {
    			$null = [Quest.PowerGUI.SDK.ScriptEditorFactory]::CurrentInstance.DocumentWindows.Add("")
    		} elseif ($Host.Name -eq 'Windows PowerShell ISE Host') {
    			$null = $psise.CurrentPowerShellTab.Files.Add() 
    		}
        }
    } 
} 
