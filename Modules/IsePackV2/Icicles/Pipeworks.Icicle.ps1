@{
    Name = 'PowerShell Pipeworks'
    Screen = {
        Import-Module IsePackV2 -Global 
        New-Border  -BorderBrush Black -CornerRadius 5 -On_SizeChanged {            
            if ($loadedModulesList) {
                $LoadedModulesList.Height = $_.NewSize.Height * .2
            }
            if ($pipeworksButtonHolder) {
                $pipeworksButtonHolder.Height = $_.NewSize.Height * .33;
            }
            if ($LogoOfCurrentModule) {
                $LogoOfCurrentModule.Height = 100 * ($_.NewSize.Height / 1080);
                $LogoOfCurrentModule.Width = 100 * ($_.NewSize.Height / 1080);
            }
        } -Child {
            $newPipeworksManifestHandler = {
                Import-Module Pipeworks, EzOut -Global
                $sb = [ScriptBLock]::Create("`$_ | 
    Set-Content '$($loadedModulesList.SelectedItem | Split-Path |Join-Path -ChildPath { $loadedModulesList.SelectedItem.ToString() + '.pipeworks.psd1' })' 
        
    Edit-Script -File '$($loadedModulesList.SelectedItem | Split-Path |Join-Path -ChildPath { $loadedModulesList.SelectedItem.ToString() + '.pipeworks.psd1' })'
    
Get-Icicle -Name 'New-$($loadedModulesList.SelectedItem)PipeworksManifest' | 
    Remove-Icicle -Confirm:`$false |
    Out-Null
    ")
                            $cmdOverload = Write-CommandOverload -Command (Get-Command New-PipeworksManifest) -ProcessEachItem $sb -Name "New-$($loadedModulesList.SelectedItem)PipeworksManifest"
                            $ise = $loadedModulesList.Tag
                            $ise.CurrentPowerShellTab.Invoke(
"$cmdOverload

Add-Icicle -Command (Get-Command 'New-$($loadedModulesList.SelectedItem)PipeworksManifest') -Force" 



                )
            }
            New-grid -rows auto, auto, 1*, auto -children {
                    New-StackPanel -HorizontalAlignment Right -Margin 12 -Children {
                        New-TextBlock -Text "Loaded Modules" -TextAlignment Right -FontSize 16 -FontWeight DemiBold

                        New-CheckBox -Name "AutoPublish" -Content "AutoPublish Modules" -Visibility Collapsed -On_Checked {
                            $ise = $LoadedModulesList.Tag
                            if ($ise.CurrentPowershelltab.CanInvoke) {
                                $null = $ise.CurrentPowerShellTab.InvokeSynchronous(
                                    "`$global:autoPublishPipeworks = `$true
                                    
`$sub = Get-EventSubscriber -SourceIdentifier autopublishtimer -errorAction SilentlyContinue
if (-not `$sub) {
    `$timer =New-Object Timers.Timer -Property @{Interval=3000}
    `$timer.Start()
    Register-ObjectEvent -SourceIdentifier autopublishtimer -InputObject `$timer -EventName Elapsed -Action {" + {
$modulesToCheck = Get-Module | ?{ $_ | Get-PipeworksManifest } 

foreach ($m in $modulesToCheck) {
    
    $hash = Get-Hash "$($m | Split-Path | Get-ChildItem -Recurse | Get-Hash)"    
    $lashHash = Invoke-Expression "`$global:LashHash$($m)"
    if (-not $lastHash -or $lastHash -ne $hash) {
        Invoke-Expression "`$global:LashHash$($m) ='$hash'"
        ConvertTo-ModuleService -Name $m -AsJob 
    }
}
    } + "
        
    }
}

                                    ", $false)                                
                            }
                        } -On_Unchecked {
                            $ise = $LoadedModulesList.Tag
                            if ($ise.CurrentPowershelltab.CanInvoke) {
                                $null = $ise.CurrentPowerShellTab.InvokeSynchronous(
                                    "`$global:autoPublishPipeworks = `$false", $false 
                                )
                            }
                        }
                    }
                    
                    New-ListBox -Margin 12 -verticalAlignment Top -Row 1 -SelectionMode Extended -Name LoadedModulesList -DisplayMemberPath Name -On_SelectionChanged {
                        
                        $GenerateDeployments.IsEnabled = $this.SelectedItems                        
                        $Win8AppOMatic.IsEnabled = $this.SelectedItems                        
                        $BotInstaller.IsEnabled = $this.SelectedItems                        
                        $EditModule.IsEnabled  = 
                        $publishModule.IsEnabled = $this.SelectedItems
                        $UserOptions.IsEnabled = $this.SelectedItems -and @($this.SelectedItems).Count -eq 1                       

                        $EditOptionsHolder.Visibility = "Collapsed"
                        $UserOptionsHolder.Visibility = "Collapsed"
                    }

                    $buttonStyle = @{
                        FontWeight="DemiBold"
                        FontSize=15
                        
                    }

                    New-ScrollViewer -Row 3 -Name pipeworksButtonHolder -Margin 12 -Content {
                        New-StackPanel -Row 3 -Margin 12 -VerticalAlignment Bottom -Children {
                            New-Button -Name "NewModule" -Content "_New Module" @buttonstyle -Margin 3 -On_Click {
                                $NewModuleHolder.Visibility    = "Visible"


                                $DeploymentOptionsHolder.Visibility  =
                                    $PublishOptionsHolder.Visibility =
                                    $UserOptionsHolder.Visibility    = 
                                    $EditOptionsHolder.Visibility    = "Collapsed"
                            }
                            

                            New-Button -Name "EditModule" -Content "_Edit Module" @buttonstyle -IsEnabled:$false -Margin 3 -On_Click {
                                
                                $EditOptionsHolder.Visibility    = "Visible"

                                $DeploymentOptionsHolder.Visibility  =
                                    $PublishOptionsHolder.Visibility =
                                    $UserOptionsHolder.Visibility    = 
                                    $NewModuleHolder.Visibility      = "Collapsed"
                                
                                
                                
                            }
                            New-Button -Name PublishModule -Content "P_ublish Module" -IsEnabled:$false  @buttonstyle -Margin 3 -On_Click {
                                $DeploymentOptionsHolder.Visibility = "Collapsed"
                                $PublishOptionsHolder.Visibility = "Visible"
                                $EditOptionsHolder.Visibility = "Collapsed"
                                $UserOptionsHolder.Visibility = "Collapsed"
                                $NewModuleHolder.Visibility = "Collapsed"
                            }

                            New-Button -Name GenerateDeployments -Content "_Generate Azure Deployments" -ToolTip "Publishes the modules and generates a .cspkg" @buttonstyle -Margin 3 -IsEnabled:$false -On_Click {
                            
                                $DeploymentOptionsHolder.Visibility = "Visible"
                                $PublishOptionsHolder.Visibility = "Collapsed"
                                $EditOptionsHolder.Visibility = "Collapsed"
                                $UserOptionsHolder.Visibility = "Collapsed"
                                $NewModuleHolder.Visibility = "Collapsed"                                
                            }
                        
                            New-Button -Name Win8AppOMatic -Content "Build _Win8 Apps" @buttonstyle -Margin 3 -IsEnabled:$false -On_Click {
                        
                                $modules = ($LoadedModulesList.SelectedItems | Select-Object -ExpandProperty Name)                            
                                $ise = $LoadedModulesList.Tag
                                $ise.CurrentPowerShellTab.Invoke(
                                    "'$($modules -join "','")' | 
                                        Import-Module -Force -PassThru | 
                                        Get-PipeworksManifest | 
                                        Where-Object { `$_.Win8 } |
                                        Use-Schematic -SchematicName Win8 -OutputDirectory { `"`$home\Documents\VisualStudio 2012\Projects\`$(`$_.Name)`" } " 
                                )
                            }
                       
                            New-Button -Name BotInstaller -Content "Install _Bots" @buttonstyle -Margin 3 -IsEnabled:$false -On_Click {
                            
                                $modules = ($LoadedModulesList.SelectedItems | Select-Object -ExpandProperty Name)                            
                                $ise = $LoadedModulesList.Tag
                                $ise.CurrentPowerShellTab.Invoke(
                                    "'$($modules -join "','")' | 
                                        Import-Module -Force -PassThru | 
                                        Get-PipeworksManifest | 
                                        Where-Object { `$_.Bot } |
                                        Use-Schematic -SchematicName Bot" 
                                )

                            }
                            New-Button -Name UserOptions -Content "Module _Users" @buttonstyle -Margin 3 -IsEnabled:$false -On_Click {
                                $DeploymentOptionsHolder.Visibility  =
                                    $PublishOptionsHolder.Visibility =
                                    $EditOptionsHolder.Visibility    =
                                    $NewModuleHolder.Visibility      = "Collapsed"
                            
                                $UserOptionsHolder.Visibility = "Visible"
                            
                            }
                        }
                    }

                    
                    New-StackPanel -Margin 12 -VerticalAlignment Center -Visibility Collapsed -Row 2 -Name EditOptionsHolder -Children {
                        New-TextBlock -Name NameOfCurrentModule -Margin 4 @buttonStyle -TextAlignment Center
                        New-Image -Name LogoOfCurrentModule -Margin 4 -MaxWidth 125 -MaxHeight 125 -HorizontalAlignment Center 
                        New-Button -Content "Set Logo" @buttonStyle -Margin 4 -On_Click {
                            $moduleRoot = $loadedModulesList.SelectedItem | Split-Path
                            $ise = $loadedModulesList.Tag
                            $ise.CurrentPowerShellTab.Invoke(@"
                            `$moduleRoot = '$($moduleRoot.replace("'","''"))'
                            `$ofd = New-OpenFileDialog 

                            if (-not (Test-Path "`$moduleRoot\Assets")) {
                                `$dir = New-Item -ItemType Directory -Path "`$moduleRoot\Assets"
                            } else {
                                `$dir = Get-Item "`$moduleRoot\Assets"
                            }

                            if (`$ofd.ShowDialog()) {
                                foreach (`$file in `$ofd.FileNames) {
                                    `$realFile = Get-Item -LiteralPath `$file -Force
                                    if (`$realFile){
                                        Copy-Item -Path `$realFile.FullNAme -Destination "`$dir\`$(`$realFile.Name)"
                                        `$manifest = Get-Module '$($module.Name)' | Get-PipeworksManifest 
                                        `$manifest.Logo = "/Assets/`$(`$realFile.Name)"
                                        `$manifest | 
                                            Write-PowerShellHashtable -Sort |                                 
                                            Set-Content -Path "$moduleRoot\$($module.Name).pipeworks.psd1"


                                    }
                                }
                            }


"@)
                        }


                        New-Button -Content "Add Asset" @buttonStyle -Margin 4 -On_Click {
                            $moduleRoot = $loadedModulesList.SelectedItem | Split-Path
                            $ise = $loadedModulesList.Tag
                            $ise.CurrentPowerShellTab.Invoke(@"
                            `$moduleRoot = '$($moduleRoot.replace("'","''"))'
                            `$ofd = New-OpenFileDialog -Multiselect 

                            if (-not (Test-Path "`$moduleRoot\Assets")) {
                                `$dir = New-Item -ItemType Directory -Path "`$moduleRoot\Assets"
                            } else {
                                `$dir = Get-Item "`$moduleRoot\Assets"
                            }

                            if (`$ofd.ShowDialog()) {
                                foreach (`$file in `$ofd.FileNames) {
                                    `$realFile = Get-Item -LiteralPath `$file -Force
                                    if (`$realFile){
                                        Copy-Item -Path `$realFile.FullNAme -Destination "`$dir\`$(`$realFile.Name)"
                                    }
                                }
                            }
"@)
                        }


                        New-ComboBox -Margin 4 -Name ModuleEditItems -On_SelectionChanged {
                            $EditModuleContent.IsEnabled = $This.SelectedItem
                        }
                        New-Button -Content "Edit Content" @buttonStyle -Margin 4 -IsEnabled:$false -Name "EditModuleContent" -On_Click {
                            $ise = $LoadedModulesList.Tag
                            $fileToedit =  ''
                            if ($ModuleEditItems.SelectedItem -eq 'Script Module') {
                                $fileToedit  = $loadedModulesList.SelectedItem  | 
                                    Split-Path |
                                    Join-Path -ChildPath { $LoadedModulesList.SelectedItem.Name + ".psm1" } 
                            } elseif ($ModuleEditItems.SelectedItem -eq 'Module Manifest') {
                                $fileToedit  =  $loadedModulesList.SelectedItem  | 
                                    Split-Path |
                                    Join-Path -ChildPath  { $LoadedModulesList.SelectedItem.Name + ".psd1" } 

                            } elseif ($ModuleEditItems.SelectedItem -eq 'Pipeworks Manifest') {
                                $fileToedit  = $loadedModulesList.SelectedItem  | 
                                    Split-Path |
                                    Join-Path -ChildPath  { $LoadedModulesList.SelectedItem.Name + ".pipeworks.psd1" } 
                            } elseif ($ModuleEditItems.SelectedItem -eq '----') {
                                return
                            } else {                             
                                $topicList = $loadedModulesList.SelectedItem  | 
                                    Split-Path | 
                                    Get-ChildItem -Filter "$(Get-culture)" -ErrorAction SilentlyContinue | 
                                    Get-ChildItem -Filter *.help.txt |
                                    ForEach-Object {
                                        $_.Name -ireplace 
                                            "\.walkthru\.help\.txt","" -ireplace 
                                            "\.help\.txt", "" -ireplace "_", " "
                                    }

                                $fileToedit = 
                                if ($loadedModulesList.SelectedItem.ExportedFunctions[$ModuleEditItems.SelectedItem]) {
                                    $loadedModulesList.SelectedItem.ExportedFunctions[$ModuleEditItems.SelectedItem].ScriptBlock.File
                                } elseif ($topicList -contains $ModuleEditItems.SelectedItem) {
                                    $loadedModulesList.SelectedItem  | 
                                    Split-Path |
                                    Join-Path -ChildPath {
                                        "$(Get-Culture)"
                                    } | 
                                    Get-ChildItem -Filter "$($ModuleEditItems.SelectedItem.Replace(' ','_'))*" | 
                                    Select-Object -First 1 -ExpandProperty Fullname


                                    
                                }
                            }
                            $ise.CurrentPowerShellTab.Invoke(

"
`$fileToEdit = '$($fileToEdit.Replace("'","''"))'
if (`$fileToEdit) {
    Edit-Script -File `$fileToEdit -Force
    `$t=  @(Get-CurrentOpenedFileToken)
    for (`$i =0;`$i -lt `$t.Count; `$i++) {
        if (`$t[`$i].Content -ieq 'function' -and 
            `$t[`$i].Type -eq 'Keyword' -and 
            `$t[`$i + 1].Type -eq 'CommandArgument' -and
            `$t[`$i + 1].Content -ieq '$($ModuleEditItems.SelectedItem)') {
            `$psISE.CurrentFile.Editor.SetCaretPosition(`$t[`$i].StartLine, `$t[`$i].StartColumn)        
            break
        }
    }
}" 
                                )

                            
                            
                        }

                        

                        
                                                
                        New-Button -Content "New Content" @buttonStyle -Margin 4 -On_Click {
                            $createArea.Visibility = 'Visible'
                        }
                        New-Border -Name CreateArea -Visibility Collapsed -Child {
                            New-Grid -Rows 1*, Auto -Children { 
                            New-Grid -Columns 2 -HorizontalAlignment Center -Children {
                                New-StackPanel -Children {
                                    New-TextBlock -Text "Name" -Margin 3
                                    New-TextBox -Name NameOfNewThing -Margin 3 -HorizontalAlignment Stretch
                                }
                                New-StackPanel -Column 1 -Children {
                                    New-TextBlock -Text "Type" -Margin 3
                                    
                                    New-ComboBox -Name TypeOfNewThing -Items {
                                        New-ComboBoxItem -Content "Function" -ToolTip "A New PowerShell Function"
                                        New-ComboBoxItem -Content "Topic" -ToolTip "A PowerShell about Topic"
                                        New-ComboBoxItem -Content "Walkthru" -ToolTip "A step-by-step walkthru"
                                        New-ComboBoxItem -Content "HTML Page" -ToolTip "A HTML page"
                                        New-ComboBoxItem -Content "Inline Page" -ToolTip "A HTML page with Inline PowerShell"
                                        New-ComboBoxItem -Content "PS1 PAge" -ToolTip "A pure Powershell page"
                                        New-ComboBoxItem -Content "Javascript" -ToolTip "A javascript file"
                                        New-ComboBoxItem -Content "CSS" -ToolTip "A css file"
                                    }  -On_SelectionChanged {
                                        $CreateFileButton.IsEnabled = $this.SelectedItem -and $nameOfNewThing.Text
                                    }
                                    #New-RadioButton -Name "Command" -ToolTip "Creates a new command in the module" -GroupName NewStuff -Content Command @buttonstyle -Margin 3 -On_Checked $enableCreateFile 
                                    #New-RadioButton -Name "HTML" -ToolTip "Creates a new HTML page" -GroupName NewStuff -Content "Web Page" @buttonstyle -Margin 3 -On_Checked $enableCreateFile 
                                    #New-RadioButton -Name "InlinePage" -ToolTip "Creates a new HTML/inline PowerShell page" -GroupName NewStuff -Content "Inline Page" @buttonstyle -Margin 3 -On_Checked $enableCreateFile 
                                    #New-RadioButton -Name "PS1Page" -ToolTip "Creates a new HTML/inline PowerShell page" -GroupName NewStuff -Content "PS1 Page" @buttonstyle -Margin 3 -On_Checked $enableCreateFile 
                                }
                            }
                            New-Button -Row 1 @buttonStyle -Name CreateFileButton -Content "Create File" -IsEnabled:$false -On_Click { 
                                
                                $type = $typeOfNewThing.SelectedItem.Content 
                                $name = $nameofNewThing.Text
                                $module = $loadedModulesList.SelectedItem
                                $ise = $loadedModulesList.Tag
                                $moduleRoot = $module.Path | Split-Path
                                if ($type -eq 'CSS') {
                                    $ise.CurrentPowerShellTab.Invoke(@"
Edit-Script -File "$moduleRoot\CSS\${Name}.css" -Force
"@)
                                } elseif ($type -eq 'JavaScript') {
                                    $ise.CurrentPowerShellTab.Invoke(@"
                                    Edit-Script -File "$moduleRoot\JS\${Name}.js" -Force
"@)
                                } elseif ($type -eq 'PS1 Page') {
                                    $ise.CurrentPowerShellTab.Invoke(@"
                                    Edit-Script -File "$moduleRoot\Pages\${Name}.ps1" -Force
"@)
                                } elseif ($type -eq 'Inline Page') {
                                    $ise.CurrentPowerShellTab.Invoke(@"
                                    Edit-Script -File "$moduleRoot\Pages\${Name}.pspage" -Force
"@)
                                } elseif ($type -eq 'HTML Page') {
                                    $ise.CurrentPowerShellTab.Invoke(@"
                                    Edit-Script -File "$moduleRoot\Pages\${Name}.html" -Force
"@)
                                } elseif ($type -eq 'Topic') {
                                    $ise.CurrentPowerShellTab.Invoke(@"
                                    Edit-Script -File "$moduleRoot\$(Get-Culture)\$($Name.Replace(" ", "_"))}.help.txt" -Force
"@)
                                } elseif ($type -eq 'Walkthru') {
                                    $ise.CurrentPowerShellTab.Invoke(@"
                                    Edit-Script -File "$moduleRoot\$(Get-Culture)\$($Name.Replace(" ", "_")).walkthru.help.txt" -Force
"@)
                                } elseif ($type -eq 'Function') {
                                    $ise.CurrentPowerShellTab.Invoke(@"
                                    Edit-Script -File "$moduleRoot\${Name}.ps1" -Force -InsertText "function $Name {
    param(
    )

    begin {
    }

    process {
    }

    end {
    }
}"
"@)
                                }
                            }
                            }
                        }

                        

                        New-Button -Name NewPipeworksManifestButtonInEdit -Content "New Pipeworks Manifest" @buttonStyle -Margin 4 -On_Click $newPipeworksManifestHandler -Visibility Collapsed


                    } -On_IsVisibleChanged {
                        if ($this.Visibility -eq 'Collapsed') { return }
                        if (-not $LoadedModulesList.SelectedItem) { return }
                        $currentManifest = $null
                        


                        $ManifestList = $loadedModulesList.Resources.Manifests
                        
                        $moduleName = $loadedModulesList.SelectedItem.Name
                        $NameOfCurrentModule.Text = $moduleName

                        $currentManifest = $ManifestList | 
                            Where-Object { $_.Name -ieq $loadedModulesList.SelectedItem.Name } 
                        

                        if ($currentManifest.Logo) {
                            $bi = New-Object windows.Media.Imaging.BitmapImage
                            $bi.BeginInit()

                            $logoPath = if ($currentManifest.Logo -notlike "/Assets/*") {
                                ($LoadedModulesList.SelectedItem | 
                                Split-Path | 
                                Join-Path -ChildPath { 
                                    "/Assets/$($currentManifest.Logo)"
                                }) -as [uri]
                            } else {
                                ($LoadedModulesList.SelectedItem | 
                                Split-Path | 
                                Join-Path -ChildPath { 
                                    $currentManifest.Logo 
                                }) -as [uri]
                            }

                            try {
                                $bi.UriSource  = $logoPath
                            
                             
                            
                                $bi.EndInit()
                                $LogoOfCurrentModule.Source =$bi
                            } catch {
                            }
                        }
                        $functionList = $loadedModulesList.SelectedItem.ExportedFunctions.Keys
                        $topicList = $loadedModulesList.SelectedItem  | 
                            Split-Path | 
                            Get-ChildItem -Filter "$(Get-culture)" -ErrorAction SilentlyContinue | 
                            Get-ChildItem -Filter *.help.txt |
                            ForEach-Object {
                                $_.Name -ireplace 
                                    "\.walkthru\.help\.txt","" -ireplace 
                                    "\.help\.txt", "" -ireplace "_", " "
                            }

                        $ModuleEditItems.ItemsSource = @("Script Module", "Module Manifest", "Pipeworks Manifest", "----") + $functionList + "----" + $topicList 

                        $NewPipeworksManifestButtonInEdit.Visibility = if (-not $currentManifest) {
                            "Visible"
                        } else {
                            "Collapsed"
                        }
                    }

                    New-StackPanel -Margin 12 -VerticalAlignment Center -Visibility Collapsed -Row 2 -Name UserOptionsHolder  -Children {
                        New-Button -Name LoadAllUsers -Content "Load All Users" @buttonstyle -Margin 6 -On_Click {
                        
                        
                            $modules = ($LoadedModulesList.SelectedItems | Select-Object -ExpandProperty Name)                            
                            $ise = $LoadedModulesList.Tag
                            $ise.CurrentPowerShellTab.Invoke(
                                "'$($modules -join "','")' | 
                                    Import-Module -PassThru | 
                                    Get-PipeworksManifest | 
                                    Where-Object { `$_.UserTable } |
                                    Foreach-Object { 
                                        `$manifest = `$_
                                        `$UserTable = `$_.UserTable
                                        `$userTableStorageAccount = Get-SecureSetting `$UserTable.StorageAccountSetting -ValueOnly
                                        `$userTableStorageKey = Get-SecureSetting `$UserTable.StorageKeySetting -ValueOnly

                                        `$UsersInTable = Search-AzureTable -TableName `$UserTable.Name -Filter `"PartitionKey eq '`$(`$UserTable.Partition)'`" -StorageAccount `$userTableStorageAccount -StorageKey `$UserTableStorageKey
                                        `$allUsersVariableName = `$Manifest.Name.Replace('.', '').Replace('-','') + 'Users'
                                        Set-Variable -Option AllScope -Name `$allUsersVariableName -Value `$UsersInTable
                                    }" 
                            )
                        }
                        
                        New-TextBlock -TextAlignment Center -Text "Name, Email, or ID" -Name UserInfoText

                        New-TextBox -Name "UserInfo" -On_TextChanged {
                            $ShowOwnedObjects.IsEnabled = $this.Text
                            $FindSpecificUser.IsEnabled = $this.Text
                            $ShowRelatedObjects.IsEnabled = $ObjectRelationshipType.Text -and $UserInfo.Text

                        }
                        
                        New-Button -Content "Find Specific User" -Name FindSpecificUser @buttonstyle -Margin 6 -IsEnabled:$false -On_Click {

                            $modules = ($LoadedModulesList.SelectedItems | Select-Object -ExpandProperty Name)                            
                            $personOfInterest = $UserInfo.Text

                            $personIdType = if ($personOfInterest -as [guid]) {
                                "UserID"
                            } elseif ($personOfInterest -like "*@*") {
                                "Email"
                            } else {
                                "Name"
                            }

                            $ise = $LoadedModulesList.Tag
                            $ise.CurrentPowerShellTab.Invoke(
                                "'$($modules -join "','")' | 
                                    Import-Module -PassThru | 
                                    Get-PipeworksManifest | 
                                    Where-Object { `$_.UserTable } |
                                    Foreach-Object { 
                                        `$manifest = `$_
                                        `$UserTable = `$_.UserTable
                                        `$userTableStorageAccount = Get-SecureSetting `$UserTable.StorageAccountSetting -ValueOnly
                                        `$userTableStorageKey = Get-SecureSetting `$UserTable.StorageKeySetting -ValueOnly


                                        $(if ($personIdType -eq 'Name') {
                                            @"
`$thePerson = Search-AzureTable -TableName `$UserTable.Name -Filter `"PartitionKey eq '`$(`$UserTable.Partition)' and name eq '$($personOfInterest.Replace("'","''"))' or Name eq '$($personOfInterest.Replace("'","''"))'`" -StorageAccount `$userTableStorageAccount -StorageKey `$UserTableStorageKey 
"@
                                        } elseif ($personIdType -eq 'UserID') {
                                            @"
`$thePerson = Search-AzureTable -TableName `$UserTable.Name -Filter `"PartitionKey eq '`$(`$UserTable.Partition)' and RowKey eq '$($personOfInterest)'`" -StorageAccount `$userTableStorageAccount -StorageKey `$UserTableStorageKey
"@

                                        } elseif ($personIdType -eq 'Email') {
                                            @"
`$thePerson = Search-AzureTable -TableName `$UserTable.Name -Filter `"PartitionKey eq '`$(`$UserTable.Partition)' and UserEmail eq '$($personOfInterest.Replace("'","''"))'`" -StorageAccount `$userTableStorageAccount -StorageKey `$UserTableStorageKey
"@

                                        })
                                        
                                        `$thePerson
                                    }" 
                            )
                        }
                        New-Button -Content "Owned Objects" -Name ShowOwnedObjects @buttonstyle -Margin 6 -IsEnabled:$false -On_Click {
                            $modules = ($LoadedModulesList.SelectedItems | Select-Object -ExpandProperty Name)                            
                            $personOfInterest = $UserInfo.Text

                            $personIdType = if ($personOfInterest -as [guid]) {
                                "UserID"
                            } elseif ($personOfInterest -like "*@*") {
                                "Email"
                            } else {
                                "Name"
                            }

                            $ise = $LoadedModulesList.Tag
                            $ise.CurrentPowerShellTab.Invoke(
                                "'$($modules -join "','")' | 
                                    Import-Module -PassThru | 
                                    Get-PipeworksManifest | 
                                    Where-Object { `$_.UserTable } |
                                    Foreach-Object { 
                                        `$manifest = `$_
                                        `$UserTable = `$_.UserTable
                                        `$userTableStorageAccount = Get-SecureSetting `$UserTable.StorageAccountSetting -ValueOnly
                                        `$userTableStorageKey = Get-SecureSetting `$UserTable.StorageKeySetting -ValueOnly


                                        $(if ($personIdType -eq 'Name') {
                                            @"
`$thePerson = Search-AzureTable -TableName `$UserTable.Name -Filter `"PartitionKey eq '`$(`$UserTable.Partition)' and Name eq '$($personOfInterest.Replace("'","''"))'`" -StorageAccount `$userTableStorageAccount -StorageKey `$UserTableStorageKey 
"@
                                        } elseif ($personIdType -eq 'UserID') {
                                            @"
`$thePerson = Search-AzureTable -TableName `$UserTable.Name -Filter `"PartitionKey eq '`$(`$UserTable.Partition)' and RowKey eq '$($personOfInterest)'`" -StorageAccount `$userTableStorageAccount -StorageKey `$UserTableStorageKey
"@

                                        } elseif ($personIdType -eq 'Email') {
                                            @"
`$thePerson = Search-AzureTable -TableName `$UserTable.Name -Filter `"PartitionKey eq '`$(`$UserTable.Partition)' and UserEmail eq '$($personOfInterest.Replace("'","''"))'`" -StorageAccount `$userTableStorageAccount -StorageKey `$UserTableStorageKey
"@

                                        })
                                        
                                        if (`$thePerson) {
                                            Search-AzureTable -TableName `$UserTable.Name -Filter `"OwnerID eq '`$(`$ThePerson.UserID)'`"
                                        }                                        
                                    }" 
                            )
                        }

                        New-Button -Content "Related Objects" -Name ShowRelatedObjects @buttonstyle -Margin 6 -IsEnabled:$false -On_Click {
                            $modules = ($LoadedModulesList.SelectedItems | Select-Object -ExpandProperty Name)                            
                            $personOfInterest = $UserInfo.Text

                            $personIdType = if ($personOfInterest -as [guid]) {
                                "UserID"
                            } elseif ($personOfInterest -like "*@*") {
                                "Email"
                            } else {
                                "Name"
                            }

                            $ise = $LoadedModulesList.Tag
                            $ise.CurrentPowerShellTab.Invoke(
                                "'$($modules -join "','")' | 
                                    Import-Module -PassThru | 
                                    Get-PipeworksManifest | 
                                    Where-Object { `$_.UserTable } |
                                    Foreach-Object { 
                                        `$manifest = `$_
                                        `$UserTable = `$_.UserTable
                                        `$userTableStorageAccount = Get-SecureSetting `$UserTable.StorageAccountSetting -ValueOnly
                                        `$userTableStorageKey = Get-SecureSetting `$UserTable.StorageKeySetting -ValueOnly


                                        $(if ($personIdType -eq 'Name') {
                                            @"
`$thePerson = Search-AzureTable -TableName `$UserTable.Name -Filter `"PartitionKey eq '`$(`$UserTable.Partition)' and Name eq '$($personOfInterest.Replace("'","''"))'`" -StorageAccount `$userTableStorageAccount -StorageKey `$UserTableStorageKey 
"@
                                        } elseif ($personIdType -eq 'UserID') {
                                            @"
`$thePerson = Search-AzureTable -TableName `$UserTable.Name -Filter `"PartitionKey eq '`$(`$UserTable.Partition)' and RowKey eq '$($personOfInterest)'`" -StorageAccount `$userTableStorageAccount -StorageKey `$UserTableStorageKey
"@

                                        } elseif ($personIdType -eq 'Email') {
                                            @"
`$thePerson = Search-AzureTable -TableName `$UserTable.Name -Filter `"PartitionKey eq '`$(`$UserTable.Partition)' and UserEmail eq '$($personOfInterest.Replace("'","''"))'`" -StorageAccount `$userTableStorageAccount -StorageKey `$UserTableStorageKey
"@

                                        })
                                        
                                        if (`$thePerson) {
                                            Search-AzureTable -TableName `$UserTable.Name -Filter `"PartitionKey eq '$($ObjectRelationshipType.Text)`$(`$ThePerson.UserID)'`"
                                        }                                        
                                    }" 
                            )
                        }

                        New-Button -Name NewPipeworksManifestButton -Content "New Pipeworks Manifest" @ButtonStyle -On_Click $newPipeworksManifestHandler -Visibility Collapsed 

                        New-TextBlock -TextAlignment Center -Name RelationshipTypeText -Text "Relationship Type" -ToolTip "The Prefix on data attached to this user in Table Storage"

                        New-TextBox -Name "ObjectRelationshipType" -On_TextChanged {
                            #$ShowOwnedObjects.IsEnabled = $this.Text
                            #$FindSpecificUser.IsEnabled = $this.Text
                            $ShowRelatedObjects.IsEnabled = $ObjectRelationshipType.Text -and $UserInfo.Text

                        }
                        

                        New-Button -Visibility Collapsed -Name NewLiveIdApp -Content "New Live App" @buttonstyle -Margin 6 -On_Click {
                            Start-Process "https://manage.dev.live.com/Applications/Create?tou=1"

                            $ObjectRelationshipType.Visibility     =
                                $NewLiveIdApp.Visibility           = 
                                $NewFacebookApp.Visibility         = 
                                $LoadAllUsers.Visibility           =                              
                                $RelationshipTypeText.Visibility   = 
                                $ShowRelatedObjects.Visibility     = 
                                $ShowOwnedObjects.Visibility       = 
                                $FindSpecificUser.Visibility       = 
                                $UserInfoText.Visibility           = 
                                $CreateFacebookApp.Visibility      =
                                $EnterFacebookAppIdText.Visibility =
                                $EnterFacebookAppId.Visibility     =
                                $UserInfo.Visibility               = 'Collapsed'

                            $enterLiveIdSecretText.Visibility =
                                $enterLiveIdText.Visibility   = 
                                $enterLiveId.Visibility       = 
                                $enterLiveIdSecret.Visibility = 
                                $CreateLiveApp.Visibility     = 'Visible'
                        }

                        New-TextBlock -Visibility Collapsed -Name EnterLiveIdText -Text "Live Connect Client ID" @buttonstyle -Margin 3 

                        New-TextBox -Visibility Collapsed -Name EnterLiveId -Margin 3 

                        New-TextBlock -Visibility Collapsed -Name EnterLiveIdSecretText @buttonstyle -Text "Live Connect Client Secret" -Margin 3 
                        
                        New-PasswordBox -Visibility Collapsed -Name EnterLiveIdSecret -Margin 3 

                        New-Button -Visibility Collapsed -Name CreateLiveApp -Content Save @buttonstyle -Margin 3 -On_Click {
                            $module = $loadedModulesList.SelectedItem
                            $moduleRoot = $module | Split-Path
                            $pipeworksManifestPath = Join-Path $moduleRoot "$($module.Name).Pipeworks.psd1"
                            $MypipeworksManifest  = if (Test-Path $pipeworksManifestPath) {
                                try {                     
                                    & ([ScriptBlock]::Create(
                                        "data -SupportedCommand Add-Member, New-WebPage, New-Region, Write-CSS, Write-Ajax, Out-Html, Write-Link { $(
                                            [ScriptBlock]::Create([IO.File]::ReadAllText($pipeworksManifestPath))                    
                                        )}"))            
                                } catch {
                                    Write-Error "Could not read pipeworks manifest" 
                                    return
                                }                                                
                            }



                            $secretSettingName = "$($module.Name.Replace('-', '').Replace('.', ''))ClientSecret"
                            Add-SecureSetting -Name $secretSettingName -String $enterLiveIdSecret


                            $MyPipeworksManifest.LiveConnect = @{
                                ClientId = $EnterLiveId.Text
                                ClientSecretSetting = $secretSettingName
                            }


                            $MyPipeworksManifest | 
                                Write-PowerShellHashtable -Sort |                                 
                                Set-Content -Path "$moduleRoot\$($module.Name).pipeworks.psd1"
                        
                            $enterLiveIdSecretText.Visibility =
                                $enterLiveIdText.Visibility   = 
                                $enterLiveId.Visibility       = 
                                $enterLiveIdSecret.Visibility = 
                                $newLiveIdApp.Visibility      =
                                $CreateLiveApp.Visibility     = 'Collapsed'



                        }

                        New-Button -Visibility Collapsed -Name NewFacebookApp -Content "New Facebook App" @buttonstyle -Margin 6 -On_Click {
                            Start-Process "https://developers.facebook.com/apps"

                            $ObjectRelationshipType.Visibility   =
                                $NewLiveIdApp.Visibility         = 
                                $NewFacebookApp.Visibility       = 
                                $LoadAllUsers.Visibility         =                              
                                $RelationshipTypeText.Visibility = 
                                $ShowRelatedObjects.Visibility   = 
                                $ShowOwnedObjects.Visibility     = 
                                $FindSpecificUser.Visibility     = 
                                $UserInfoText.Visibility         = 
                                $enterLiveIdSecretText.Visibility=
                                $enterLiveIdText.Visibility      = 
                                $enterLiveId.Visibility          = 
                                $enterLiveIdSecret.Visibility    = 
                                $newLiveIdApp.Visibility         =
                                $CreateLiveApp.Visibility        =
                                $UserInfo.Visibility             = 'Collapsed'

                            $EnterFacebookAppIdText.Visibility   =
                                $EnterFacebookAppId.Visibility   = 
                                $createFacebookApp.Visibility    = 'Visible'
                        }
                        New-TextBlock -Visibility Collapsed -Name EnterFacebookAppIdText -Text "Facebook App Id" @buttonstyle -Margin 3 

                        New-TextBox -Visibility Collapsed -Name EnterFacebookAppId  -Margin 3 


                        New-Button -Visibility Collapsed -Name CreateFacebookApp -Content Save @buttonstyle -Margin 3 -On_Click {
                            $module = $loadedModulesList.SelectedItem
                            $moduleRoot = $module | Split-Path
                            $pipeworksManifestPath = Join-Path $moduleRoot "$($module.Name).Pipeworks.psd1"
                            $MypipeworksManifest  = if (Test-Path $pipeworksManifestPath) {
                                try {                     
                                    & ([ScriptBlock]::Create(
                                        "data -SupportedCommand Add-Member, New-WebPage, New-Region, Write-CSS, Write-Ajax, Out-Html, Write-Link { $(
                                            [ScriptBlock]::Create([IO.File]::ReadAllText($pipeworksManifestPath))                    
                                        )}"))            
                                } catch {
                                    Write-Error "Could not read pipeworks manifest" 
                                    return
                                }                                                
                            }

                            $MyPipeworksManifest.Facebook = @{
                                App = $EnterFacebookAppId.Text
                            }


                            $MyPipeworksManifest | 
                                Write-PowerShellHashtable -Sort |                                 
                                Set-Content -Path "$moduleRoot\$($module.Name).pipeworks.psd1"
                        
                            $enterLiveIdSecretText.Visibility        =
                                $enterFacebookAppIdText.Visibility   = 
                                $enterFacebookAppId.Visibility       =                                 
                                $CreateFacebookApp.Visibility        = 'Collapsed'
                            
                        }

                    } -On_IsVisibleChanged {
                        if ($this.Visibility -eq 'Collapsed') { return }
                        if (-not $LoadedModulesList.SelectedItem) { return }
                        $currentManifest = $null
                        
                        $ManifestList = $loadedModulesList.Resources.Manifests
                        
                        $moduleName = $loadedModulesList.SelectedItem.Name

                        $currentManifest = $ManifestList | 
                            Where-Object { $_.Name -ieq $loadedModulesList.SelectedItem.Name } 
                        
                        
                        

                    
                        $LoadAllUsers.Visibility           = 
                        $ObjectRelationshipType.Visibility = 
                        $RelationshipTypeText.Visibility   = 
                        $ShowRelatedObjects.Visibility     = 
                        $ShowOwnedObjects.Visibility       = 
                        $FindSpecificUser.Visibility       = 
                        $UserInfoText.Visibility           = 
                        $UserInfo.Visibility               =
                            if ($currentManifest -as [bool] -and $currentManifest.UserTable -as [bool]) {
                                "Visible"
                            } else {
                                "Collapsed"
                            }


                        if (! $currentManifest) {
                            $NewpipeworksManifestButton.Visibility = 'Visible'
                            return
                        }
                        
                        if (! $currentManifest.LiveConnect.ClientId) {
                            $NewLiveIdApp.Visibility = "Visible"
                        } else {
                            $NewLiveIdApp.Visibility = "Collapsed"
                        }

                        if (! $currentManifest.Facebook.AppId) {
                            $NewFacebookApp.Visibility = "Visible"
                        } else {
                            $NewFacebookApp.Visibility = "Collapsed"
                        }
                    }
                    New-StackPanel -Margin 12 -VerticalAlignment Center -Visibility Collapsed -Row 2 -Name PublishOptionsHolder -Children {
                        New-Grid -Columns 2 -Children {
                            New-CheckBox -Content "Intranet Site" -Name IntranetSite -Margin 6 -On_Checked {
                                
                                $PortContainer.Visibility = "Visible"
                            } -On_Unchecked {
                                
                                $PortContainer.Visibility = "Collapsed"
                            }

                            New-StackPanel -Name PortContainer -Visibility Collapsed -HorizontalAlignment Center -Orientation Horizontal -Column 1 -children {
                                New-TextBlock -Text "Port" -Margin 4 -FontWeight DemiBold -FontSize 14
                                New-TextBox -Name "PublishToPort" -Margin 4 -FontWeight DemiBold -FontSize 14 -MaxLength 5 -MinWidth 100
                            }

                        }

                        New-Grid -Columns 2 -Children {
                            New-CheckBox -Content "Allow Download" -Name AllowModuleDownload -Margin 6                             
                        }

                        New-Button -Content "GO" @buttonstyle -Margin 6 -On_Click { 
                            $modules = ($LoadedModulesList.SelectedItems | Select-Object -ExpandProperty Name)                            
                            $ise = $LoadedModulesList.Tag


                            if ($IntranetSite.IsChecked) {
                                $portNumber = $PublishToPort.Text -as [Uint32]
                                if (-not $portNumber) {
                                    $portNumber = Get-Random -Maximum (64kb)
                                }
                                $fullScript = "'$($modules -join "','")' | Import-Module -Force -PassThru | ConvertTo-ModuleService -Force -AsIntranetSite -Port $portNumber"
                            } else {
                                $fullScript = "'$($modules -join "','")' | Import-Module -Force -PassThru | ConvertTo-ModuleService -Force"
                            }

                            if ($AllowModuleDownload.IsChecked) {
                                $fullScript += " -AllowDownload"
                            }
                            
                            $ise.CurrentPowerShellTab.Invoke($fullScript)
                            $this.Parent.Visibility = "Collapsed"

                        }
                    }
                    New-StackPanel -Margin 12 -VerticalAlignment Center -Visibility Collapsed -Name NewModuleHolder -Row 2 -Children {
                        
                         
                        New-TextBlock -TextAlignment Center @ButtonStyle -Text "Module Name" -Margin 6
                        New-TextBox -Name NameOfNewModule @buttonStyle -Margin 6 -On_TextChanged {
                            $CreateModuleButton.IsEnabled = $true
                        }

                        New-TextBlock -TextAlignment Center @ButtonStyle -Text "Domain" -Margin 6
                        New-TextBox -Name DomainOfNewModule @buttonStyle -Margin 6 
                        New-Grid -Columns 2 -Children {
                            New-Checkbox -Name NewModuleAllowDownload -Content "Allow Download" @buttonStyle -Margin 6 -ToolTip "Can this module be downloaded?"
                            New-Checkbox -Name NewModuleIsService -Content "Is Service" @buttonStyle -Margin 6 -ToolTip "Is this a software service?" -Column 1 
                        }                        


                        New-Button -Name "CreateModuleButton" -Content "Create Module" @buttonStyle -IsEnabled:$false -Margin 6 -On_Click {
                            $NewmoduleName = $NameOfNewModule.Text
                            $NewModuleDomain = $DomainOfNewModule.Text

                            $myModulePath = "$home\Documents\WindowsPowerShell\Modules"

                            if (Test-Path "$myModulePath\$NewModuleName") {
                                throw "Module already exists"
                                return
                            }

                            $modulePath = New-Item -ItemType Directory -Path "$myModulePath\$NewModuleName" 


                            $EzFormatFile = @"
`$moduleRoot = '$($modulePath)'
`$formatViews = @()
Import-Module EZOut
<#


# This is a quick example format view.  
# Simply change the typename in the parameter below to be anything you'd like.
# Then change the typename of whatever object you output in a function, like so:
# - 
`$formatViews += Write-FormatView -TypeName 'My.Custom.Type' -Action {
    if (`$request -and `$response) {
        # Show the object inside of a web page
    } else {
        # Show the object inside of a console
    }
}


#>
`$formatViews | Out-FormatData | Set-Content '$modulePath\$NewModuleName.format.ps1xml'
"@

                            $ezFormatFile | Set-Content "$modulePath\$NewModuleName.ezformat.ps1"

                            (& (Get-Command "$modulePath\$NewModuleName.ezformat.ps1"))


                            $modulePsd1 = if ($NewModuleIsService.IsChecked) {
                                @{
                                    ModuleVersion = '1.0'
                                    ModuleToProcess = "$newModuleName.psm1"
                                    RequiredModules = 'Pipeworks'
                                    FormatsToProcess = "$newModuleName.format.ps1xml"
                                } | 
                                    Write-PowerShellHashtable -Sort 
                            } else {
                                @{
                                    ModuleVersion = '1.0'
                                    ModuleToProcess = "$newModuleName.psm1"
                                    FormatsToProcess = "$newModuleName.format.ps1xml"
                                } | 
                                    Write-PowerShellHashtable -Sort 
                            }

                            $pipeworksManifestParams = @{
                                Name=$newModuleName
                                
                                AllowDownload=$NewModuleAllowDownload.IsChecked
                            }
                            if ($NewModuleDomain) {
                                $pipeworksManifestParams+=$NewModuleDomain
                            }
                            $manifestText = 
                                if ($newModuleIsService.IsChecked) {
                                    New-PipeworksManifest @pipeworksManifestParams -UserTable "$($NewModuleName.Replace('-','').Replace('.',''))Users"
                                } else {
                                    New-PipeworksManifest @pipeworksManifestParams
                                }
                            
                            "" |
                                Set-Content "$modulePath\$NewModuleName.psm1"
                            
                            $modulePsd1 | 
                                Set-Content "$modulePath\$NewModuleName.psd1"

                            $manifestText |
                                Set-Content "$modulePath\$NewModuleName.Pipeworks.psd1"

                            $ise = $loadedModulesList.Tag
                            $ise.currentPowerShellTab.Invoke(@"
Edit-Script '$modulePath\$NewModuleName.psm1'
Edit-Script '$modulePath\$NewModuleName.psd1'
Edit-Script '$modulePath\$NewModuleName.Pipeworks.psd1'
Edit-Script '$modulePath\$(Get-Culture)\about_$NewModuleName.help.txt' -Force
"@)

                            
                        }


                        


                    }
                    New-StackPanel -Margin 12 -VerticalAlignment Center -Visibility Collapsed -Name DeploymentOptionsHolder -Row 2 -Children {
                        New-TextBlock "Deployment Name" -FontWeight DemiBold -FontSize 14 -Margin 6
                                
                        New-TextBox -text "MyDeployment" -Name PipeworksDeploymentName -FontSize 14 -Margin 6
                                
                        New-ComboBox -SelectedItem "M" -Items "XS", "S", "M", "L", "XL" -Name PipeworksVMSize -Margin 6                                                                

                        New-CheckBox -Content "Push to Staging" -Name PushToStaging -Margin 6
                         
                        New-TextBlock "Service Name" -FontWeight DemiBold -FontSize 14 -Margin 6       
                                
                        New-TextBox -text "MyAzureService" -Name AzureServiceName -FontSize 14 -Margin 6                 
                            
                        New-Button -Content "GO" @buttonstyle -Margin 6 -On_Click {
                            $modules = ($LoadedModulesList.SelectedItems | Select-Object -ExpandProperty Name)                            
                            $ise = $LoadedModulesList.Tag

                            $fullScript = "'$($modules -join "','")' | Publish-AzureService -DeploymentName '$($PipeworksDeploymentName.Text)' -VMSize $($PipeworksVMSize.SelectedItem)"
                            

                            if ($PushToStaging.IsChecked) {
                                $myServiceName = $AzureServiceName.Text
                                $myDeployment = $PipeworksDeploymentName.Text
                                $fullScript += "
Import-Module Azure

`$currentDeployment = Get-AzureDeployment -ServiceName '$myServiceName'

`$newlabel = `$myServiceName + '_' + `$((get-date).tostring().Replace('/', '-').Replace(':', '-'))

Remove-AzureDeployment -ServiceName startautomating -Slot Staging -Force -ErrorAction SilentlyContinue

`$deploymentParameters = @{
Package=  `"`$home\Documents\$MyDeployment\$MyDeployment.cspkg`"
Configuration =  `"`$home\Documents\$MyDeployment\$MyDeployment.cscfg`"
Label = `$newLabel
}

New-AzureDeployment @deploymentParameters -ServiceName $MyServiceName -Slot Staging                                                
"
                            }

                            $ise.CurrentPowerShellTab.Invoke($fullScript)
                            $this.Parent.Visibility = "Collapsed"
                        }
                    }

                    
                
            }
        }
    }
    DataUpdate = {
        New-Object PSObject -Property @{
            Modules = Get-Module |
                Where-Object { $_.Path -notlike "*.ps1" -and $_.Name -notlike "Microsoft.*"} 
            Manifests = Get-Module | 
                Get-PipeworksManifest | 
                ForEach-Object {
                    New-Object PSObject -Property $_
                }
            Ise = $psISE
        }                
    } 
    UiUpdate = {
        $hi = $Args

        
        
        
        $this.Content | 
            Get-ChildControl -ByName LoadedModulesList | 
            ForEach-Object {  
                $_.Tag = ($hi.ise)
                $_.itemssource = @($hi.Modules)
                $_.Resources.Manifests = $($hi.Manifests)
            }
        $this.Content.Resources.Ise = $this.Parent.HostObject
    }
    UpdateFrequency = "00:00:43"
#    ShortcutKey = "Ctrl + P"
}