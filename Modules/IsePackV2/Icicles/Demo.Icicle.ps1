@{
    Name = 'Demo'    
    UpdateFrequency = "0:0:1.01"
    UpdateOnAddOnChange = $true    
    Screen = {
        Import-Module IsePackV2 -Global
        New-Border -ControlName DemoPlayer -BorderBrush Black -CornerRadius 5 -On_Loaded {
            
        } -Child {
            New-Grid -Rows Auto, Auto, Auto, 1*, Auto, Auto, Auto -Columns 1*, Auto -Children {
                
                
                New-TextBlock -Margin "10,10, 3, 3"-FontWeight DemiBold -FontSize 24 -Text "Steps" -Name DemoName -Visibility Collapsed -Tag ($false)
                New-Grid -Row 1 -Margin "10,10, 3, 3" -Columns 2 -Children {
                    New-TextBlock -Name StepName -FontSize 22  -Visibility Collapsed -Row 1 -Tag ([Timespan]::FromSeconds(20)) 
                    New-TextBlock -Name TimeUntilNextStep -FontSize 22 -Text "Next Step In"  -Visibility Collapsed  -Tag ([Timespan]::FromSeconds(20)) -Column 1 -HorizontalAlignment Right
                }
                
                
                New-ListBox -Margin "10,10, 3, 3"  -DisplayMemberPath Name  -Padding 10 -MaxHeight 240 -Visibility Collapsed -Name DemoStepList  -Row 2 -SelectionMode Single -On_SelectionChanged {
                    if ($this.SelectedItem) {
                        
                        if ($this.SelectedItem.Explanation) {
                            
                            $innerBrowser.NavigateToString("
<span style='font-size:$(($ISE.Options.Zoom / 100) * .66)em;font-family:Segoe UI'>
    $(Write-WalkthruHTML -WalkThru @($this.SelectedItem))
</span>
")
                        }

                        if ("$($this.SelectedItem.Script)") {
                            $invokeStep.IsEnabled = $true
                        } else {
                            $invokeStep.IsEnabled = $false
                        }

                        if ($AutoPlayDemo.IsChecked -and "$($this.SelectedItem.Script)") {
                            $invokeStep.RaiseEvent((New-Object Windows.RoutedEventArgs ([Windows.Controls.Button]::ClickEvent)))
                        }
                        $CurrentDemoStep.Visibility = 'Visible'
                        
                    } else {
                        $CurrentDemoStep.Visibility = 'Collapsed'
                        $invokeStep.IsEnabled = $false
                    }
                } -On_MouseDoubleClick {
                    if ("$($this.SelectedItem.Script)") {
                        $invokeStep.RaiseEvent((New-Object Windows.RoutedEventArgs ([Windows.Controls.Button]::ClickEvent)))
                    }
                }
                                
                New-Border -Margin "10,10, 3, 3" -Row 3 -Visibility Collapsed -MinHeight 240 -Name CurrentDemoStep -Child {
                    New-WebBrowser -Name InnerBrowser
                }



                New-StackPanel -Row -Orientation Horizontal -HorizontalAlignment Center -Children {
                    $styleInfo =@{
                        Margin = 10
                        FontSize = 22
                        FontWeight = 'DemiBold'
                    }
                    
                }
                

                New-Grid -Rows 2 -Columns 4 -Margin "10,10, 3, 3" -Name ActiveButtonArea -Children {
                    
                    
                    New-Button -Column 3 -Name LoadNewDemo -Margin "10,10, 3, 3" -Content { 
                        New-StackPanel -Orientation Vertical {
                            New-TextBlock -FontWeight DemiBold -FontSize 24 -HorizontalAlignment Center -FontFamily "Segoe UI Symbol" -Text ([char]0xe1c1) 
                            New-TextBlock -Text Start-Demo 
                        }
                    } -On_Click {
                        $ise = [Windows.Window]::GetWindow($this).Resources.ISE
                        if ($ise.CurrentPowerShellTab.CanInvoke) {
                            $ise.CurrentPowerShellTab.Invoke("
                            `$fd = New-OpenFileDialog 
                            `$fd.Filter = `"Demos(*.walkthru.help.txt,*.demo.ps1)|*.walkthru.help.txt;*.demo.ps1;`" 
                        
                            if (`$fd -and `$fd.ShowDialog()) {
                                `$fd.FileNames | Get-Item | Start-Demo
                            
                            }")
                        }
                   
                    }


                    New-Button -Column 2 -Name CopyStepButton -Margin "10,10, 3, 3" -Content { 
                        New-StackPanel -Orientation Vertical {
                            New-TextBlock -FontWeight DemiBold -FontSize 24 -HorizontalAlignment Center -FontFamily "Segoe UI Symbol" -Text ([char]0xe16f) 
                            New-TextBlock -Text Copy-Step 
                        }
                    } -On_Click {
                        [Windows.Clipboard]::SetText("$($demoStepList.SelectedItem.Script)")                                           
                    }
                    
                    New-Button -Column 1 -Name InvokeStep -Margin "10,10, 3, 3" -Content { 
                        New-StackPanel -Orientation Vertical {
                            New-TextBlock -FontWeight DemiBold -FontSize 24 -HorizontalAlignment Center -FontFamily "Segoe UI Symbol" -Text ([char]0xe115) 
                            New-TextBlock -Text Invoke-Step 
                        }
                    } -IsEnabled:$false -On_Click {
                        if ($ise.CurrentPowerShellTab.CanInvoke) {
                            $ise.CurrentPowerShellTab.Invoke($demoStepList.SelectedItem.Script)
                            $AutoPlayDemo.Tag  = $false
                        }

                        $grandParent = [Windows.Media.VisualTreeHelper]::GetParent($demoPlayer.Parent)
                        $greatGrandParent = [Windows.Media.VisualTreeHelper]::GetParent($grandParent)
                        $greatGreatGrandParent = [Windows.Media.VisualTreeHelper]::GetParent($greatGrandParent )
                        $greatGreatGreatGrandParent = [Windows.Media.VisualTreeHelper]::GetParent($greatGreatGrandParent  )
                        
                        $gggggp= [Windows.Media.VisualTreeHelper]::GetParent($greatGreatGreatGrandParent  )
                        
                        $ggggggp= [Windows.Media.VisualTreeHelper]::GetParent($gggggp  )

                        $gggggggp= [Windows.Media.VisualTreeHelper]::GetParent($ggggggp  )
                        $ggggggggp= [Windows.Media.VisualTreeHelper]::GetParent($gggggggp  )
                        
                        if ([Threading.Thread]::CurrentThread.ManagedThreadId -eq $ggggggp.Dispatcher.Thread.ManagedThreadId) {                                                                                                                   
                            if ($ggggggp.ColumnDefinitions[0].ActualWidth -le 100) {
                                # $ggggggp.ColumnDefinitions.Clear()
                                $cd = New-Object Windows.Controls.ColumnDefinition
                                
                                
                                $ggggggp.ColumnDefinitions[0].Width = New-Object Windows.GridLength .75, "Star"
                                $ggggggp.ColumnDefinitions[2].Width = New-Object Windows.GridLength .25, "Star"

                                $fullScreenIcon.Text = [char]0xe1d9
                                $fullScreenText.Text = "Fullscreen"
                            }                                                         
                        }
                    }

                    New-Button -Name ToggleFullscreenButton -Margin "10,10, 3, 3" -Content { 
                        New-StackPanel -Orientation Vertical {
                            New-TextBlock -FontWeight DemiBold -FontSize 24 -HorizontalAlignment Center -FontFamily "Segoe UI Symbol" -Text ([char]0xe1d9) -Name FullScreenIcon
                            New-TextBlock -Text Fullscreen -Name FullScreenText
                        }
                    } -On_Click {
                        $grandParent = [Windows.Media.VisualTreeHelper]::GetParent($demoPlayer.Parent)
                        $greatGrandParent = [Windows.Media.VisualTreeHelper]::GetParent($grandParent)
                        $greatGreatGrandParent = [Windows.Media.VisualTreeHelper]::GetParent($greatGrandParent )
                        $greatGreatGreatGrandParent = [Windows.Media.VisualTreeHelper]::GetParent($greatGreatGrandParent  )
                        
                        $gggggp= [Windows.Media.VisualTreeHelper]::GetParent($greatGreatGreatGrandParent  )
                        
                        $ggggggp= [Windows.Media.VisualTreeHelper]::GetParent($gggggp  )

                        $gggggggp= [Windows.Media.VisualTreeHelper]::GetParent($ggggggp  )
                        $ggggggggp= [Windows.Media.VisualTreeHelper]::GetParent($gggggggp  )
                        
                        if ([Threading.Thread]::CurrentThread.ManagedThreadId -eq $ggggggp.Dispatcher.Thread.ManagedThreadId) {
                                
                            

                            
                            
                            if ($ggggggp.ColumnDefinitions[0].ActualWidth -le 100) {
                                $ggggggp.ColumnDefinitions[0].Width = New-Object Windows.GridLength .75, "Star"
                                $ggggggp.ColumnDefinitions[2].Width = New-Object Windows.GridLength .25, "Star"

                                $fullScreenIcon.Text = [char]0xe1d9
                                $fullScreenText.Text = "Fullscreen"
                                $DemoTreeView.Visibility = 'Visible'
                            } else {
                                $ggggggp.ColumnDefinitions[0].Width = New-Object Windows.GridLength 0, "Star"
                                $ggggggp.ColumnDefinitions[2].Width = New-Object Windows.GridLength 1, "Star"

                                $fullScreenIcon.Text = [char]0xe1d8
                                $fullScreenText.Text = "Collapse"
                                $DemoTreeView.Visibility = 'Collapse'
                            }
                            

                            
                        }
                        
                    }



                } -Row 4 

                


                New-StackPanel -Name AutoAdvancePanel -Margin "10,10, 3, 3" -Orientation Horizontal -HorizontalAlignment Center -Row 5 -Children {
                    
                    $styleInfo =@{
                        Margin = 5
                        FontSize = 23
                        FontWeight = 'DemiBold'
                    }
                    New-CheckBox @styleInfo -Content "Autoplay" -IsChecked:$true -Name AutoPlayDemo -Tag $false

                    New-TextBlock @styleInfo -Text "Every" 

                    New-TextBox @styleInfo -Name AutoAdvanceRate -Text "20"  -On_TextChanged {
                        if ($this.Text -as [uint32]) {
                            $TimeUntilNextStep.Tag = $TimeUntilNextStep.Tag = [Timespan]::FromMilliseconds($this.Text * 1001)
                        }
                    }

                    New-TextBlock @styleInfo -Text "Seconds" 
                }
                
                New-TreeView -Name DemoTreeView -Margin "10,10,3,3"  -MaxHeight 200 -Row 6 -On_MouseDoubleClick {
                    if ($this.SelectedItem.Tag) {
                        $ise = [Windows.Window]::GetWindow($this).Resources.ISE
                        if ($ise.CurrentPowerShellTab.CanInvoke) {                       
                            $ise.CurrentPowerShellTab.Invoke("
Start-Demo `"$($this.SelectedItem.Tag)`" -Paused
")
                        }
                    }

                }
            }
        }
    } 
    UiUpdate = {
        
        if ($args -and -not $DemoTreeView.tAg) {
            $DemoTreeView.Tag = $args   
            


            $byPath = $DemoTreeView.Tag | Group-Object { $_ | Split-Path | Split-Path | Split-Path -Leaf } | Sort-Object Name 
            
            $demoTreeView.Items.Clear()
            $moduleNames = @()
            foreach ($group in $byPath) {
                $label = New-Label -FontWeight SemiBold -FontSize 17 -Content $group.Name
                $moduleDemos = New-TreeViewItem -Header $label

                foreach ($demoFile in ($group.Group | 
                    Select-Object -Unique | 
                    Sort-Object)) {
                    
                    $thedemoName = (Get-Item -LiteralPath $demoFile).Name
                    $thedemoName = $thedemoName -ireplace '_', ' '
                    $thedemoName = $thedemoName -ireplace '\.walkthru\.help\.txt', ''
                    $thedemoName = $thedemoName -ireplace '\.demo\.ps1', ''
                    $moduleNames += $thedemoName 
                    $sublabel = New-Label -FontSize 13 -Content $thedemoName -Tag $demoFile
                    $subItem = New-TreeViewItem -Header $sublabel -Tag $demoFile
                    $moduleDemos.Items.Add($subItem)
                }
                $demoTreeView.Items.Add($moduleDemos)
            }            
            $demoTreeView.Visibility = 'Visible'
        }            
            
        
        
        if ($demoStepList.Visibility -eq 'Collapsed') { return } 
        if ($AutoPlayDemo.IsChecked) {

            if ($AutoPlayDemo.Tag -eq $true) {                
                if ("$($demoStepList.SelectedItem.Script)") {
                    if ($AutoPlayDemo.IsChecked -and "$($demoStepList.SelectedItem.Script)") {
                        $invokeStep.RaiseEvent((New-Object Windows.RoutedEventArgs ([Windows.Controls.Button]::ClickEvent)))
                    }
                }
            } else {
                
            }

            $TimeUntilNextStep.Tag -= [Timespan]"00:00:01.01"
            $TimeUntilNextStep.Visibility = 'Visible'
        
            if ($TimeUntilNextStep.Tag.TotalSeconds -lt 0) {
                $nextTime = $autoAdvanceRate.Text -as [Uint32]

                if (-not $nextTime) {
                    $TimeUntilNextStep.Tag = [Timespan]::FromSeconds($nextTime * 1001)
                } else {
                    $TimeUntilNextStep.Tag = [Timespan]::FromMilliseconds($nextTime * 1001)
                }

            
                
                if ($demoStepList.SelectedIndex -ne ($demoStepList.ItemsSource.Count - 1)) {
                    $demoStepList.SelectedIndex++     
                    $StepName.Text = "Step $($demoStepList.SelectedIndex + 1)"
                } else {
                    $DemoName.Tag = $true
                    $TimeUntilNextStep.Text = "Demo Done"
                    $AutoPlayDemo.IsChecked = $false
                    $StepName.Text = " " 
                    $demoStepList.SelectedItem = $null

                    return
                }                        
            
            }

            $TimeUntilNextStep.Text = "Next Step in..." + [Math]::Floor($TimeUntilNextStep.Tag.TotalSeconds)
        }


        
    }
    
    DataUpdate = {
        
       $moduleList = @(Get-Module)
        
        if ((-not $script:CachedModuleList) -or 
            ($moduleList.Count -ne $script:CachedModuleList.Count) -or 
            (-not $script:CachedDemoData)) {
            $script:CachedModuleList = $moduleList        
            $moduleDirs = Get-Module | 
                Split-Path

            $MyLocaleDemoDirs = @($moduleDirs |
                Get-ChildItem -Filter "$(Get-Culture)" | 
                Get-childitem -Filter "*.walkthru.help.txt")

            $EnUsDemos = @($moduleDirs |
                Get-ChildItem -Filter "en-us" | 
                Get-ChildItem -Filter "*.walkthru.help.txt")


            $allDemos = @() + $MyLocaleDemoDirs + $EnUsDemos
            
            
            $script:CachedDemoData = $allDemos | 
                Select-Object -ExpandProperty Fullname | 
                Select-Object -Unique          
        } 
        $script:CachedDemoData 

    }    
}