@{
    WebCommand = @{
        "Test-Command" = @{
            HideParameter = "Command"
            RunOnline=$true
            FriendlyName = "Test a Command"
        }
        "Get-ScriptCopRule" = @{
            RunWithoutInput = $true
            RunOnline=$true
            FriendlyName = "ScriptCop Rules"
        }
        "Get-ScriptCopPatrol" = @{
            RunWithoutInput = $true
            RunOnline=$true
            FriendlyName = "ScriptCop Patrols"
        }
    }
    JQueryUITheme = 'Smoothness'
    AnalyticsId = 'UA-24591838-3'
    CommandOrder = "Test-Command", 
        "Get-ScriptCopRule", 
        "Get-ScriptCopPatrol"    
        
    Style = @{
        Body = @{
            'Font' = "14px/2em 'Rockwell', 'Verdana', 'Tahoma'"                                    
            
        }        
    }
    Logo = '/ScriptCop_125_125.png'
    AddPlusOne = $true
    TwitterId = 'jamesbru'
    Facebook = @{
        AppId = '250363831747570'
    }
    
    DomainSchematics = @{
        "ScriptCop.Start-Automating.com | Scriptcop.StartAutomating.com" = 
            "Default"        
    }

    AdSense = @{
        Id = '7086915862223923'
        BottomAdSlot = '6352908833'
    }


    PubCenter = @{
        ApplicationId = "9be78ae9-fd79-428a-a325-966034e35715"
        BottomAdUnit = "10049443"
    }


    Win8 = @{
        Identity = @{
            Name="Start-Automating.ScriptCop"
            Publisher="CN=3B09501A-BEC0-4A17-8A3D-3DAACB2346F3"
            Version="1.0.0.0"
        }
        Assets = @{
            "splash.png" = "/ScriptCop_Splash.png"
            "smallTile.png" = "/ScriptCop_Small.png"
            "wideTile.png" = "/ScriptCop_Wide.png"
            "storeLogo.png" = "/ScriptCop_Store.png"
            "squaretile.png" = "/ScriptCop_Tile.png"
        }
        ServiceUrl = "http://ScriptCop.start-automating.com"

        Name = "ScriptCop"
        PublishedUrl = 'http://apps.microsoft.com/windows/en-us/app/scriptcop/4d061ee7-c124-4840-85ee-b7ab9866208a'
    }
    
    AllowDownload = $true   

    Technet = @{
        Category="Scripting Techniques"
        Subcategory="Writing Scripts"
        OperatingSystem="Windows 7", "Windows Server 2008", "Windows Server 2008 R2", "Windows Vista", "Windows XP", "Windows Server 2012", "Windows 8"
        Tag ='ScriptCop', 'Start-Automating', 'Static Analysis', 'Testing', 'Code Coverage'
        MSLPL=$true
        Summary="
ScriptCop is a tool to help sure your scripts are following the rules.  It performs static analysis on PowerShell scripts to help identify common problems.
"
        Url = 'http://gallery.technet.microsoft.com/ScriptCop-0896dd1e'
    }
}