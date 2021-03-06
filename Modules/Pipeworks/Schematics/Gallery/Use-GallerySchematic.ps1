function Use-GallerySchematic
{
    <#
    .Synopsis
        Builds a web application according to a schematic
    .Description
        Use-Schematic builds a web application according to a schematic.
        
        Web applications should not be incredibly unique: they should be built according to simple schematics.        
    .Notes
    
        When ConvertTo-ModuleService is run with -UseSchematic, if a directory is found beneath either Pipeworks 
        or the published module's Schematics directory with the name Use-Schematic.ps1 and containing a function 
        Use-Schematic, then that function will be called in order to generate any pages found in the schematic.
        
        The schematic function should accept a hashtable of parameters, which will come from the appropriately named 
        section of the pipeworks manifest
        (for instance, if -UseSchematic Blog was passed, the Blog section of the Pipeworks manifest would be used for the parameters).
        
        It should return a hashtable containing the content of the pages.  Content can either be static HTML or .PSPAGE                
    #>
    [OutputType([Hashtable])]
    param(
    # Any parameters for the schematic
    [Parameter(Mandatory=$true)]
    [Hashtable]$Parameter,
    
    # The pipeworks manifest, which is used to validate common parameters
    [Parameter(Mandatory=$true)][Hashtable]$Manifest,
    
    # The directory the schemtic is being deployed to
    [Parameter(Mandatory=$true)][string]$DeploymentDirectory,
    
    # The directory the schematic is being deployed from
    [Parameter(Mandatory=$true)][string]$InputDirectory     
    )
    
    process {
    
        if (-not $Parameter.Collection) {
            Write-Error "No collection found in parameters"
            return
        }
        
        
        
        $requiresTableConnection = 
            $parameter.Collection |
                Where-Object { $_.Partition }
        
        
        $localInventory =
            $parameter.Collection |
                Where-Object { $_.Directory } 
        
        if (-not $localInventory) {
            $requiresTableConnection  = $true
        }
        if ($requiresTableConnection ) {
            if (-not $Manifest.Table.Name) {
                Write-Error "No table found in manifest"
                return
            }
            
            if (-not $Manifest.Table.StorageAccountSetting) {
                Write-Error "No storage account name setting found in manifest"
                return
            }
            
            if (-not $manifest.Table.StorageKeySetting) {
                Write-Error "No storage account key setting found in manifest"
                return
            }
        }
        
        $manifest.AcceptAnyUrl = $true
                                        
        
        $anyPage = {
        
        
        
            if ($pipeworksManifest.Table) {
            
                # Pick out the storage account and storage key from the manifest.  If they are not present, the values will be blank.
                $storageAccount = (Get-WebConfigurationSetting -Setting $pipeworksManifest.Table.StorageAccountSetting)
                $storageKey = (Get-WebConfigurationSetting -Setting $pipeworksManifest.Table.StorageKeySetting)                                                           
            }

            #region Get collection metadata
            $CollectionNames  = @()

            
            $Collections = 
                foreach ($CollectionInfo in $pipeworksManifest.Gallery.Collection) {
                    $Collection = New-Object PSObject -Property $CollectionInfo
                    $CollectionNames += $Collection.Name
                    $Collection 
                }
        
            #endregion Get collection metadata
               
                
            
            # Determine relative URL and original URL
            $originalUrl = $context.Request.ServerVariables["HTTP_X_ORIGINAL_URL"]

            $pathInfoUrl = $request.Url.ToString().Substring(0, $request.Url.ToString().LastIndexOf("/"))
            
                
                
            $pathInfoUrl = $pathInfoUrl.ToLower()
            $protocol = ($request['Server_Protocol'].Split("/", [StringSplitOptions]"RemoveEmptyEntries"))[0]  # Split out the protocol
            
            

            $serverName= $request['Server_Name']                     # And what it thinks it called the server
            
            $fullOriginalUrl = $protocol.ToLower() + "://" + $serverName + $request.Params["HTTP_X_ORIGINAL_URL"]
            $fullOriginalUrl = $fullOriginalUrl.ToLower()
            
            $pathInfoUrl = $pathInfoUrl.ToLower()
            $relativeUrl = $fullOriginalUrl.Replace("$pathInfoUrl", "")            
            
            
            if (-not $fullOriginalUrl) {
                "No Original URL"
                return
            }
            
            $pageCss = @{
    "body" = @{
        "line-height" = "160%"
        "padding-top" = "0px"
        "padding-left" = "0px"
        "padding-right" = "0px"
        "padding-bottom" = "0px"
        "margin-top" = "0px"
        "margin-left" = "0px"
        "margin-right" = "0px"
        "margin-bottom" = "0px"
    }
} 
            $ShowThing= {

param([Parameter(Mandatory=$true)][string]$Name,
[string[]]$Caption,
[string[]]$Url,
[string]$FirstColor = "#012456",
[string]$HeaderTextColor = "#fff",
[string]$MainTextColor = "#000000",
[string]$SecondColor = "#010c1d",
[string]$ThirdColor = "#ffffff",
[string]$Thing)
"<h1 style='top:25px;font-variant:normal;font-weight:bold;font-size:24px;margin-bottom:5px;line-height:2em'>$Name</h1>" | 
    New-Region -LayerID MainHeaderContainer -Style @{
        "color" = "$HeaderTextColor"
        "letter-spacing" = "-1px"
        "margin-left" = "17%"
        "padding-right" = "40px"
        "padding-left" = "40px"
        "padding-bottom" = "0px"
        "padding-top" = "0px"
        "min-width" = "480px"
        "max-width" = "960px"
        #"text-shadow" ="0 2px 0 #510000"
    } |
    New-Region -LayerID PageHeader -Style @{
        width = "100%"
        "height" = "80px"
        "background-image" = "none"
        "background-attachment" = "scroll"
        "background-repeat" = "repeat"        
        "background-position-x" = "0%"
        "background-position-y" = "0%"
        "background-origin" = "padding-box"
        "background-clip" = "border-box"
        "background-size" = "auto"
        "background-color" = "$FirstColor"
        "text-align" = "left"
        
    }
    
$count=  0
$urlLinks = foreach ($u in $url) {
    if (-not $u) { continue }
    $c = $caption[$count] 
    New-Object PSObject -Property @{
        Url = $u
        Caption = $c
    }
    $count++
}

if ($urlLinks) {
    $urlLinks = $urlLinks|
        Write-Link -Horizontal -Button -Style @{"padding" = "6px" }
}
$urlLinks|    
    New-Region -LayerID HeaderContainer -Style @{        
        "color" = "$HeaderTextColor"
        "margin-right" = "17%"
        "letter-spacing" = "1.1px"
        "padding" = "4px"
        "min-width" = "350px"
        "max-width" = "960px"
        "font-size" = "xx-small"
        "float" = "right"
    } |
    New-Region -LayerID PageSecondHeader -Style @{
        width = "100%"
        "height" = "40px"
        "background-image" = "none"
        "background-attachment" = "scroll"
        "background-repeat" = "repeat"        
        "background-position-x" = "0%"
        "background-position-y" = "0%"
        "background-origin" = "padding-box"
        "background-clip" = "border-box"
        "background-size" = "auto"
        "background-color" = "$SecondColor"
        "color" = "#fff"
    }    
    
$thing |
    New-Region -LayerID MainContainer -Style @{        
        
        "margin-right" = "auto"
        "margin-left" = "auto"
        "margin-top" = ".5em"
        "letter-spacing" = "-1px"
        "padding-right" = "40px"
        "padding-left" = "40px"
        "min-width" = "350px"
        "max-width" = "960px"
        "font-size" = "medium"
                
        "text-align" = "left"
    } |
    New-Region -LayerID MainContent -Style @{
        width = "66%"
        "height" = "40px"
        "background-image" = "none"
        "background-attachment" = "scroll"
        "background-repeat" = "repeat"        
        "background-position-x" = "0%"
        "background-position-y" = "0%"
        "background-origin" = "padding-box"
        "background-size" = "auto"
        "background-color" = "$ThirdColor"
        "color" = "$mainTextcolor"
        
    } 
    
            
            }
            
            $loadFilesInSet = {
                            
                if ($_.PSIsContainer) { return }
                
                if ($_.Fullname -like '*.psd1') {
                    # Treat as a data file
                    
                    Import-PSData -FilePath $_.fullname -AllowCommand ConvertFrom-Markdown, Write-ScriptHTML, Write-Link, New-Region, New-WebPage, Out-HTML, Add-Member |
                        Add-Member NoteProperty FullName $fullname -Force -PassThru
                } else {
                    $_
                }
            } 
            
            
            $optionalStyleSheet = @{
            
            }
            
            if ($pipeworksManifest.gallery.StyleSheet) {
                $optionalStyleSheet.StyleSheet = $gallery.StyleSheet
            }
            
            
            
            
            $sortSetItems = {
                if ($_.DatePublished) {
                    [DateTime]$_.DatePublished 
                } elseif ($_.Timestamp) {
                    [DateTime]$_.Timestamp
                } elseif ($_.LastWriteTime) {
                    $_.LastWriteTime
                }
            }                         
            
            
            $renderLayers = {
                if ($collection.StyleSheet) {
                    $optionalStyleSheet.StyleSheet = $collection.StyleSheet
                }
                $thingTitle= 
                    if ($itemIdentifier) { 
                        "$($CollectionFriendlyName) | $($itemIdentifier)"
                        $exactMatch = $popouts.Keys | Where-Object { $_ -eq $itemIdentifier }
                        if ($exactMatch) {
                            $Newpopouts = @{}
                            $Newpopouts[$itemIdentifier] = $popouts[$itemIdentifier] 
                            $popOuts = $Newpopouts
                        }
                    } else {
                        "$($CollectionFriendlyName)"
                    }
                    
                    
                
                if ($popouts.Count -gt 1) {
                    if ($Collection.Directory) {
                        $thingHtml = New-Region -LayerID InventoryItems -Order $order -Layer $popouts  -AsPopout
                        & $showThing @colorScheme -Name $thingTitle -Thing $thingHtml |
                            New-WebPage -Title $thingTitle -UseJQueryUI @optionalStyleSheet
                    } elseif ($Collection.Partition) {
                        $thingHtml =  
                            New-Region -LayerID InventoryItems -Order $order -Layer $popouts -LayerUrl $popoutUrls -AsPopout 
                        & $showThing @colorScheme -Name $thingTitle -Thing $thingHtml |
                            New-WebPage -Title $thingTitle  -UseJQueryUI @optionalStyleSheet
                    }
                } else {

                    if ($Collection.Directory) {
                        if ($order) {
                            $exactMatch = @($order -eq $itemIdentifier)
                            
                            if ($exactMatch.Count -eq 1 ) {
                                $name = "$($exactMatch)"
                                $thingHtml = $popouts[$name]                            
                            } else {
                                $thingHtml = "$($popouts[$order])"
                            }                            
                            & $showThing @colorScheme -Name $thingTitle -Thing $thingHtml |
                                New-WebPage -Title $thingTitle -UseJQueryUI @optionalStyleSheet

                        } else {                        
                            
                            #$thingHtml = $popouts[$name]
                            & $showThing @colorScheme -Name $thingTitle -Thing "<h3>Topic $Name not found</h3>" |
                                New-WebPage -Title $thingTitle -UseJQueryUI @optionalStyleSheet

                        }
                    } elseif ($Collection.Partition) {
                    
                        $name = ""
                        $realThing = Get-AzureTable -TableName $pipeworksManifest.Table.Name -Partition $Collection.Partition -Row  ($items).RowKey 
                        $thingHtml = $realThing | 
                            Out-HTML -ItemType $realThing.pstypenames[-1]
                        & $showThing @colorScheme -Name $thingTitle -Thing $thingHtml |
                            New-WebPage -Title $thingTitle -UseJQueryUI @optionalStyleSheet
                        
                        # Get the row
                    }
                }
            }
            
            $handleLayers = {
                
                $items += $_
                $layername = 
                    if ($_.Name) {
                        if ($_.Extension) {
                            # Pick out everything up to the first .
                            $_.Name.Substring(0, $_.Name.IndexOf(".") - 1)
                        } else {
                            $_.Name
                        }
                    } else {
                        " " + ($order.Count + 1)
                    }
                
                if ($Collection.Partition -and $_.RowKey) {
                    $popoutUrls[$layername] = ("../" * $depth) + "Module.ashx?id=$($Collection.Partition):$($_.RowKey)"
                    $popouts[$layername] = " "                                        
                } elseif ($Collection.Directory) {
                    if ($_ -is [IO.FileInfo]) {
                        if ($_.Extension -eq '.md') {
                            $popouts[$layername] = [IO.File]::ReadAllText($_.fullname) |
                                ConvertFrom-Markdown
                        } elseif ($_.Fullname -like '*demo.ps1' -or 
                            $_.Fullname -like '*walkthru.help.txt' -or
                            $_.fullname -like '*demo.txt') {
                            $popouts[$layername] = Write-WalkthruHTML -WalkThru (Get-Walkthru -File $_.FullName)
                        } elseif ($_.Extension -eq '.ps1') {
                            $popouts[$layername] = & $_.Fullname | Out-HTML 
                        }
                    } else {
                        $itemType = $_.pstypenames[-1]
                        $popouts[$layername]  = $_ | Out-HTML -ItemType $itemType
                    }
                    # Read files that can be read
                }
                $order += $layername
            }             $initLayers = {
                $popouts = @{}
                $popoutUrls = @{}
                $items = @()
                $order = @()
                $depth = 0
                if ($request -and 
                    $request.Params -and 
                    $request.Params["HTTP_X_ORIGINAL_URL"]) {
                
                    $originalUrl = $context.Request.ServerVariables["HTTP_X_ORIGINAL_URL"]

                    $pathInfoUrl = $request.Url.ToString().Substring(0, $request.Url.ToString().LastIndexOf("/"))
                            
                        
                        
                    $pathInfoUrl = $pathInfoUrl.ToLower()
                    $protocol = ($request['Server_Protocol'].Split("/", [StringSplitOptions]"RemoveEmptyEntries"))[0]  # Split out the protocol
                    $serverName= $request['Server_Name']                     # And what it thinks it called the server

                    $fullOriginalUrl = $protocol.ToLower() + "://" + $serverName + $request.Params["HTTP_X_ORIGINAL_URL"]
                    $fullOriginalUrl  = $fullOriginalUrl.ToLower()
                    $pathInfoUrl = $pathInfoUrl.ToLower()
                    $relativeUrl = $fullOriginalUrl.Replace("$pathInfoUrl", "")            
                   
                    if ($relativeUrl -like "*/*") {
                        $depth = @($relativeUrl -split "/" -ne "").Count - 1                    
                        if ($fullOriginalUrl.EndsWith("/")) { 
                            $depth++
                        }                                        
                    } else {
                        $depth  = 0
                    }
                }
                $colorScheme=  @{}
                if ($pipeworksManifest.Gallery.HeaderPrimaryColor) {
                    $colorScheme["FirstColor"] = $pipeworksManifest.Gallery.HeaderPrimaryColor
                }
                
                if ($collection.HeaderPrimaryColor) {
                    $colorScheme["FirstColor"] = $collection.HeaderPrimaryColor
                }
                
                
                
                if ($pipeworksManifest.Gallery.HeaderSecondaryColor) {
                    $colorScheme["SecondColor"] = $pipeworksManifest.Gallery.HeaderSecondaryColor
                }
                
                if ($collection.HeaderSecondaryColor) {
                    $colorScheme["SecondColor"] = $collection.HeaderSecondaryColor
                }
                
                if ($pipeworksManifest.Gallery.MainColor) {
                    $colorScheme["ThirdColor"] = $pipeworksManifest.Gallery.MainColor
                }
                
                if ($pipeworksManifest.Gallery.MainTextColor) {
                    $colorScheme["MainTextColor"] = $pipeworksManifest.Gallery.MainTextColor
                }
                
                if ($pipeworksManifest.Gallery.HeaderTextColor) {
                    $colorScheme["HeaderTextColor"] = $pipeworksManifest.Gallery.HeaderTextColor
                }
                    
            }            $renderObjects = @{                Begin = $initLayers                Process = $handleLayers                End = $renderLayers                } 
            
            
            
            if ($relativeUrl -eq "/" -or -not $relativeUrl) {
                # Display the page
            
            
            }
            
            
            $CollectionName, $itemIdentifier = $relativeUrl.Split("/", [StringSplitOptions]"RemoveEmptyEntries")
            
            if ($CollectionNames -notcontains $CollectionName) {
                if (-not $pipeworksManifest.Gallery.DefaultCollection) {
                    Write-Error "No collection named $($CollectionName).  Try $CollectionNames.   <br/> Relative URL was: $relativeUrl .  <br/> Original URL was: $fullOriginalUrl"
                    return
                } else {
                    # There's a default collection, so the collection name attempted value is really the item identifier
                    $ItemIdentifier = $CollectionName
                    $CollectionName = $pipeworksManifest.Gallery.DefaultCollection
                    
                }
            }
            
            $Collection = $Collections | Where-Object { $_.Name -eq $CollectionName -or $_.Name -contains $CollectionName} 
            $CollectionFriendlyName =
                    if ($Collection.FriendlyName) {
                        $Collection.FriendlyName
                    } else {
                        $CollectionName
                    }
            
            if ($collection.SortBy) {
                $sortSetItems = @{
                    Property = $collection.SortBy
                } 
            } else {
                $sortSetItems = @{
                    Property = $sortSetItems
                    Descending = $true
                }
                
            }
            if (-not $ItemIdentifier) {
            
                 
                    if ($collection.Directory) {
                        # Getting all of the items is reasonable, so do so
                        Get-ChildItem -Path "bin\$($module.Name)\$($Collection.Directory)" -Recurse |
                            ForEach-Object $loadFilesInSet |
                            Sort-Object @sortSetItems  |                            
                            ForEach-Object @renderObjects
                    } elseif ($collection.Partition) {
                        $selectItems = (@($Collection.By) + "RowKey" + "Name") | Select-Object -Unique
                            Search-AzureTable -TableName $pipeworksManifest.Table.Name -Filter "PartitionKey eq '$($Collection.Partition)'" -StorageAccount $storageAccount -StorageKey $storageKey -Select $selectItems |
                            Sort-Object @sortSetItems |
                            ForEach-Object @renderObjects
                    }
            
                <## Render the gallery instead of complain
                & $showThing @colorScheme -Name "$($CollectionFriendlyName) | No Item Identifier" -Thing $thingHtml |
                    New-WebPage -Title "$($CollectionFriendlyName) | No Item Identifier" -UseJQueryUI
                                    
                  #>  
                return
            }            

            $itemIdentifier = foreach ($i in $itemIdentifier) {
                [Web.httpUtility]::UrlDecode($i)
            }

            if ($itemIdentifier.Count) {
                
                
                
                
                
            } else {
                # One one ID
                
                
                             
                
                
                if ($Collection.Partition) {                    
                    $selectItems = (@($Collection.By) + "RowKey" + "Name") | Select-Object -Unique
                    $ItemsInSet = Search-AzureTable -TableName $pipeworksManifest.Table.Name -Filter "PartitionKey eq '$($Collection.Partition)'" -StorageAccount $storageAccount -StorageKey $storageKey -Select $selectItems               
                } elseif ($Collection.Directory) {
                    $ItemsInSet  = Get-ChildItem -Path "bin\$($module.Name)\$($Collection.Directory)" -Recurse |
                        ForEach-Object $loadFilesInSet 
                }
                
                
                # Calculate the depth of the virtual URL compared to the real page. 
                # This gets used to convert links to local resources, such as a custom JQuery theme
                
                $depth =0 
                if ($relativeUrl -like "*/*") {
                    $depth = @($relativeUrl -split "/" -ne "").Count - 1                    
                    if ($fullOriginalUrl.EndsWith("/")) { 
                        $depth++
                    }                    
                    
                } else {
                    $depth  = 0
                }
                
                
                
                
                
                
                foreach ($byTerm in $Collection.By) {
                    $ItemsInSet |
                        Sort-Object @sortSetItems | 
                        Where-Object {
                            $_.$byTerm -ilike "*${itemIdentifier}*"
                        } |
                        ForEach-Object @renderObjects
                        
                }
                   
            }
            
            
            return

        
         }      
        
        # If the gallery is public, then there is a page to add items if the person is logged in
        if ($parameter.IsPublic) {
        
        }
        
               
        @{
            "AnyUrl.pspage" = "<| $anyPage |>"
            
        }                                   
    }        
} 
