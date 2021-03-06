Set-StrictMode -Off

#region Script Cop Rule Commands
. $psScriptRoot\Get-ScriptCopRule.ps1
. $psScriptRoot\Register-ScriptCopRule.ps1
. $psScriptRoot\Test-ScriptCopRule.ps1
. $psScriptRoot\Unregister-ScriptCopRule.ps1
#endregion Script Cop Rule Commands

Export-ModuleMember -Function Get-ScriptCopRule, Register-ScriptCopRule, Unregister-ScriptCopRule

#region Script Cop Fixer Commands
. $psScriptRoot\Get-ScriptCopFixer.ps1
. $psScriptRoot\Register-ScriptCopFixer.ps1
. $psScriptRoot\Test-ScriptCopFixer.ps1
. $psScriptRoot\Unregister-ScriptCopFixer.ps1
#endregion Script Cop Fixer Commands
Export-ModuleMember -Function Get-ScriptCopFixer, Register-ScriptCopFixer, Unregister-ScriptCopFixer

#region Patrol Functions
. $psScriptRoot\Get-ScriptCopPatrol.ps1
. $psScriptRoot\Register-ScriptCopPatrol.ps1
. $psScriptRoot\Save-ScriptCopPatrol.ps1
. $psScriptRoot\Unregister-ScriptCopPatrol.ps1
#endregion
Export-ModuleMember -Function Get-ScriptCopPatrol, Register-ScriptCopPatrol, Unregister-ScriptCopPatrol

#region General Purpose Functions
. $psScriptRoot\Get-FunctionFromScript.ps1
. $psScriptRoot\Get-ScriptToken.ps1
. $psScriptRoot\Save-Function.ps1
#endregion

#region Major exported commands
. $psScriptRoot\Test-Command.ps1
. $psScriptRoot\Repair-Command.ps1
. $psScriptRoot\Show-ScriptCoverage.ps1
. $psScriptRoot\Test-Module.ps1

Export-ModuleMember -Function Test-Command, Test-Module,Repair-Command, Show-ScriptCoverage
#endregion
    
#region Import Rules From Rules Directory
Get-ChildItem $psScriptRoot\Rules | 
    Get-Command { $_.Fullname } -ErrorAction SilentlyContinue | 
    Where-Object { 
        $_ -is [Management.Automation.ExternalScriptInfo]
    } |     
    Foreach-Object -Verbose:($Verbose -ne 'SilentlyContinue') { 
        Write-Verbose "Attempting to Import $_"        
        $_ | Test-ScriptCopRule -ErrorAction SilentlyContinue -ErrorVariable RuleImportError
        if ($RuleImportError) {                        
            # Ok, see if it contains functions
            $functionOnly = Get-FunctionFromScript -ScriptBlock ([ScriptBlock]::Create($_.ScriptContents))
            $cmds = @()
            foreach ($f in $functionOnly) {
                . ([ScriptBlock]::Create($f))
                $matched = $f -match "function ((\w+-\w+)|(\w+))"
                if ($matched -and $matches[1]) {
                    $cmds+=Get-Command $matches[1]
                }                        
            }
            
            $cmds | 
                Where-Object {
                    $_ | Test-ScriptCopRule -ErrorAction SilentlyContinue -ErrorVariable RuleImportError2
                    
                    if ($ruleImportError2) {
                        Write-Verbose ($RuleImportError2 |Out-String)
                    } else {
                        $_
                    }
                } |
                Register-ScriptCopRule
            
            if (-not $RuleImportError2) {
                Write-Debug ($RuleImportError |Out-String)
            }
        } else {
            $_ | Register-ScriptCopRule
        }        
    
    }
    
Get-ChildItem $psScriptRoot\Fixers | 
    Get-Command { $_.Fullname } -ErrorAction SilentlyContinue | 
    Where-Object { 
        $_ -is [Management.Automation.ExternalScriptInfo]
    } |     
    Foreach-Object { 
        Write-Verbose "Attempting to Import $_"
        $_ | Test-ScriptCopFixer -ErrorAction SilentlyContinue -ErrorVariable RuleImportError
        if ($RuleImportError) {            
            Write-Verbose ($RuleImportError |Out-String)
            # Ok, see if it contains functions
            $OldFunctionList = Get-Command -CommandType Function
            . $_
            $NewFunctionList = Get-Command -CommandType Function
            $functions= Compare-Object $OldFunctionList $NewFunctionList |
                Select-Object -ExpandProperty InputObject
            $functions | 
                Where-Object {
                    $_ | Test-ScriptCopFixer -ErrorAction SilentlyContinue -ErrorVariable RuleImportError2
                    
                    if ($ruleImportError2) {
                        Write-Verbose ($RuleImportError2 |Out-String)
                    } else {
                        $_
                    }
                } |
                Register-ScriptCopFixer
            
            if (-not $RuleImportError2) {
                Write-Verbose ($RuleImportError1 |Out-String)
            }
        } else {
            $_ | Register-ScriptCopFixer
        }        
    
    }    
#endregion

#region Import Patrols
Get-ChildItem $psScriptRoot\Patrols -ErrorAction SilentlyContinue -Filter *.patrol.psd1 |
    ForEach-Object {
        $fullPath = $_.fullname  
        $name = $_.Name.Replace(".patrol.psd1", "")
        $patrolContent = try { ([PowerShell]::Create().AddScript("
            `$executionContext.SessionState.LanguageMode = 'RestrictedLanguage'
            $([IO.File]::ReadAllText($fullPath))
        ").Invoke())[0] } catch {
            Write-Debug "Error Importing $fullpath : $($_ | Out-string)"
        }
        
        if ($patrolContent) {
            $patrolContent.Name = $name
            Register-ScriptCopPatrol @patrolContent
        }        
    }
#endregion

#region Conditionally load Show-ScriptCop if ShowUI is found
if (Get-Module ShowUI) {
    . $psScriptRoot\Show-ScriptCop.ps1
    Export-ModuleMember -Function Show-ScriptCop
} else {

    # Get-Module -ListAvailable has a heisenbug, so test for ShowUI without it
    $passiveTestForModule = $env:PSModulePath -split ";" | 
        Get-ChildItem -Filter ShowUI -ErrorAction Silentlycontinue | 
        Get-ChildItem -Filter ShowUI.psd1 -ErrorAction Silentlycontinue

    if ($passiveTestforModule) {
        Import-Module ShowUI -Global
    }
    
    if (Get-Module ShowUI) {
        . $psScriptRoot\Show-ScriptCop.ps1
        Export-ModuleMember -Function Show-ScriptCop
    }
}



#endregion