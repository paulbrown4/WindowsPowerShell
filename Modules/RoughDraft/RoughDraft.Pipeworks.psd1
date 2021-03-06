# PowerShell|Pipeworks manifest
# Describes how the module and commands within it will become a Pipeworks Web Application
@{
    Logo  = '/Assets/RoughDraft_Tile.png'
    HideNestedCommand = $true
    WebCommand = @{
        "Get-Font" = @{
            RunWithoutInput = $true            
            DefaultParameter = @{
                IncludeDetail = $true
            }            
            FriendlyName = 'Show Fonts'
        } 
        "Show-Logo" = @{
            ParameterDefaultValue= @{
                InMemory = $true
                AsType = "Png"
            }
            FriendlyName = 'Show a Logo'                        
            PlainOutput = $true
            RunOnline = $true
            Method = "Get"
            ContentType = "image/png"
            HideParameter = 'OutputUI', 'AsJob', 'InMemory', 'AsType', 'Show', 'Row', 'RowSpan', 'Column', 'ColumnSpan', 'Top', 'Left', 'Right', 'Bottom'
        }

        "Show-Shape" = @{
            ParameterDefaultValue= @{
                InMemory = $true
                AsType = "Png"
            }                        
            FriendlyName = 'Create a Shape'
            HideParameter = 'OutputUI', 'AsJob', 'InMemory', 'AsType', 'Show', 'Row', 'RowSpan', 'Column', 'ColumnSpan', 'Top', 'Left', 'Right', 'Bottom'
            PlainOutput = $true
            RunOnline = $true
            Method = "Get"
            ContentType = "image/png"
            
        }
        "Get-BusinessCard" = @{
            ParameterDefaultValue= @{
                InMemory = $true
                AsType = "Png"
            }                        
            PlainOutput = $true
            HideParameter = 'OutputUI', 'AsJob', 'InMemory', 'AsType', 'Show', 'Row', 'RowSpan', 'Column', 'ColumnSpan', 'Top', 'Left', 'Right', 'Bottom'
            RunOnline = $true
            Method = "Get"
            ContentType = "image/png"
            FriendlyName = 'Create Simple Cards'
        }
    }
    CommandOrder = 'Show-Logo', 'Show-Shape', 'Get-BusinessCard', 'Get-Font'
    
    AnalyticsId = 'UA-24591838-9'
    
    DomainSchematics = @{
        "RoughDraft.Start-Automating.com | RoughDraft.StartAutomating.com" = "Default"
        
    }
    Win8 = @{
        Identity = @{
            Name="Start-Automating.RoughDraft"
            Publisher="CN=3B09501A-BEC0-4A17-8A3D-3DAACB2346F3"
            Version="1.0.0.0"
        }


        Assets = @{
            "splash.png" = "/RoughDraft_Splash.png"
            "smallTile.png" = "/RoughDraft_Small.png"
            "wideTile.png" = "/RoughDraft_Wide.png"
            "storeLogo.png" = "/RoughDraft_Store.png"
            "squaretile.png" = "/RoughDraft_Tile.png"
        }
        ServiceUrl = "http://RoughDraft.Start-Automating.com"

        Name = "RoughDraft"
    }    

    AllowDownload = $true
    
    
    Technet = @{
        Category="Multimedia"
        Subcategory="Graphics"
        OperatingSystem="Windows 7", "Windows Server 2008", "Windows Server 2008 R2", "Windows Vista", "Windows XP", "Windows Server 2012", "Windows 8"
        Tag='ShowUI', 'Start-Automating', 'PowerShell Tools'
        MSLPL=$true
        Summary="
RoughDraft is a collection of tools to automate the creation of graphics in Powershell.  It lets you take screenshots, resize images, convert images, create logos, and script shapes.
"
        Url = 'http://gallery.technet.microsoft.com/RoughDraft-cfeb6e98'
    }    
    #UseJQueryUI = $true
    #UseJQuery = $true
    Style = @{
        body = @{
            'background-color' = '#FFFFFF'
            'color' = '#603636'
        }
    }
    Tweet = $true
    AddPlusOne = $true

} 
