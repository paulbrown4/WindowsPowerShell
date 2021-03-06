function New-WebPage
{
    <#
    .Synopsis
        Creates a new web page, with some help
    .Description
        Creates a new web page containing the most commonly used web technologies.
        
        Using New-WebPage, you can generate the scaffolding for 
        
        - Linked or nested style sheets
        - Pages built with JQuery, JQueryUI, TableSorter, or Twitter Bootstrap
        - Linked RSS feeds        
        - Global Javascript declarations
        - Global javascript error handlers
        - Simple Redirect pages 
        - Embedded Analytics        
        - Native looking applications in Safari
        - Pinned Sites in IE         

    .Example
        "<h1>Hello World</h1>" |
            New-WebPage -Title "Hello World"
    .Link
        New-Region
    .Link
        Write-Link
    .Link
        Out-HTML
    #>    
    [OutputType([string])]
    param(
    # The Title of the Web Page
    #|LinesForInput 2
    [Parameter(
        ValueFromPipelineByPropertyName=$true,
        Position=0)]
    [string]$Title,
    
    # The page content.  The page content contains quoted strings or the commands New-Region and Write-Link    
    #|LinesForInput 20
    [Parameter(ValueFromPipelineByPropertyName=$true,
        Position=1)]
    [ValidateScript({
    $nsb = "data -SupportedCommand New-Region, Write-Link { $_ }"
    $dataResult = & ([ScriptBlock]::Create($nsb))
    return $true
    })]
    [ScriptBlock]
    $PageContent,

    # Any additional content for the Page Header
    [string[]]
    $PageHeader,
    
    # The name of the template file that will be used to display the item.
    [string[]]
    $Template,
    
    # One or more links to RSS feeds, as a pair of values
    [Hashtable]
    $Rss,
        
    # The IE pinned site name    
    [string]
    $PinnedSiteName,
    
    # The IE pinned site tooltip
    [string]
    $PinnedSiteTooltip,

    # The IE pinned site url        
    [Uri]
    $PinnedSiteUrl,       
    
    # If set, the page will use JQuery
    [Switch]
    $UseJQuery,
    
    # The Version of JQuery to use
    [Version]
    $JQueryVersion = "1.7.1",
    
    # If set, the page will use JQuery UI
    [Switch]
    $UseJQueryUI,
    
    # The version of JQueryUI to use
    [Version]
    $JQueryUIVersion = "1.8.17",
        
    # Pairs of site jump item names and jump urls
    [Hashtable]
    $PinnedSiteJumpList,
    
    # The CSS style table
    [Hashtable]
    $Css,
    
    # One or more linked style sheets
    [uri[]]
    $StyleSheet,

    # A Google analytics ID
    [Parameter(ValueFromPipelineByPropertyName=$true,
        Position=5)]
    [string]
    $AnalyticsID,
    
    # If set, Javascript errors will be shown
    [switch]
    $ShowJavaScriptError,
    
    # If set, the Safari default UI elements will be hidden and 
    [switch]
    $HideSafariUI,
    
    # One or more script tags
    [string[]]
    $JavaScript,
        
    # Content to place within the body element
    [Parameter(ValueFromPipelineByPropertyName=$true, ValueFromPipeline=$true)]
    [string[]]
    $PageBody,
        
    # If set, will make the page a light redirect to another URL
    [Parameter(ValueFromPipelineByPropertyName=$true,
        Position=4)]
    [Uri]
    $RedirectTo,
    
    # The amount of time to wait before a redirect
    [Parameter(ValueFromPipelineByPropertyName=$true)]
    [Timespan]
    $RedirectIn,
    
    # The keyword list
    [Parameter(ValueFromPipelineByPropertyName=$true,
        Position=2)]
    [string[]]
    $Keyword,
    
    # The meta description
    [Parameter(ValueFromPipelineByPropertyName=$true,
        Position=3)]
    [string]$Description,        
    
    # The postal code (or zip code) list
    [string[]]
    [Alias('ZipCode')]
    $PostalCode,
    
    # A table of additional metadata
    [Hashtable]
    $Metadata = @{},
    
    # The content delivery network to use for libraries like JQuery. 
    [ValidateSet('Google', 'Microsoft', 'Local')]
    [Alias('CDN')]
    [string]$ContentDeliveryNetworkPreference = 'Microsoft',
    
    # The jQueryUI Theme.
    [string]$JQueryUITheme = 'redmond',
    
    # If set, will use the twitter bootstrap layout CSS
    [Alias('UseBootstrap')]
    [Switch]$UseTwitterBootstrap,
        
    # If set, will use the JQueryUITheme preferred by the user.
    [switch]$UseUserJQueryUITheme,
    
    # If set, will add the google checkout header.  This will allow products within the page to have an "add to cart" button
    [string]$GoogleMerchantID,
    
    # The checkout currency to use for the page
    [string]$GoogleCheckoutCurrency = "USD",
    
    # If set, will add http-equiv meta tags to force a refresh
    [Switch]$NoCache,
    
    # If set, will add http-equiv meta tags to expire the cache at a certain date
    [DateTime]$ExpirationDate,
    
    # If set, will add meta tags to hide the content from search engines.  
    [Switch]$HideFromSearchEngine, 
    
    # If set, will not add a doctype.  Otherwise, the document will be marked as HTML5.
    [Switch]$NoDocType,
    
    # The validation key for Bing Webmaster Tools
    [string]$BingValidationKey,
    
    # The Google Webmaster Tools 
    [string]$GoogleSiteVerification,
    
    # A set of opengraph data.  Do not prefix with og:
    [Hashtable]$OpenGraph,
    
    # The FaceBook AppId.  
    # 
    # 
    # This is used to initiate the Facebook JavaScript API for Like and other OpenGraph verbs
    [string]$FacebookAppId,

    # If set, will use the [jQuery tablesorter plugin](http://tablesorter.com)
    [Switch]$UseTableSorter,

    # If set, will use [Raphael](http://raphaeljs.com/)
    [Switch]$UseRaphael,

    # If set, will use [GRaphael](http://g.raphaeljs.com/)
    [Switch]$UseGRaphael,

    # If set, will use [filepicker.io](http://filepicker.io)
    [Switch]$UseFilePicker,

    # If set, will ignore settings in the pipeworks manifest.
    [Switch]$IgnoreManifest,

    # The depth of the page
    [Uint32]
    $Depth =0 
    )
    
    begin {
        $BodyArea = ""
    }
    
    process {        
        if (-not $psBoundParameters.JavaScript) {
            $javascript = @()
        }

        if (-not $psBoundParameters.StyleSheet) {
            $StyleSheet = @()
        }


        if ($PageBody -and "$PageBody".StartsWith("@{") -and $psBoundParameters.Count) {
            # No accidental property bags
            $PageBody  = ""
        }               
        #region Handle Redirects or Append Piped-In Content
        $BodyArea += if ($pagebody -or $pageContent -or  $redirectTo) {
            $redirectArea = 
                if ($redirectTo) {
                    if (-not $RedirectIn) {
@"
<script type="text/javascript">
window.location = "$redirectTo";
</script>
"@            
                    } else {
@"
<script type="text/javascript">setTimeout('window.location = "$redirectTo";', $($RedirectIn.TotalMilliseconds))
</script>
"@                
                    }
                } 
            else { "" }
            
            @"
$redirectArea
$($pagebody -join ([Environment]::NewLine))
$(if ($PageContent) {
    $nsb = "data -SupportedCommand New-Region, Write-Link { $pageContent }"
    & ([ScriptBlock]::Create($nsb))
})
"@
        } else {
            ""
        }     
        #endregion Handle Redirects or Append Piped-In Content
        
        
    
}
        end {
            if (-not $IgnoreManifest) { 
                if ($pipeworksManifest -and $pipeworksManifest.LiveConnect) {
                    $liveConnectClientId = 
                        if ($pipeworksManifest.LiveConnect.ClientId) {
                            $pipeworksManifest.LiveConnect.ClientId
                        } elseif ($pipeworksManifest.LiveConnect.ClientIdSetting) {
                            Get-WebConfigurationSetting -Setting $pipeworksManifest.LiveConnect.ClientIdSetting
                        }
                }
                if ($pipeworksManifest -and $pipeworksManifest.Facebook) {
                    $facebookAppId =
                        if ($pipeworksManifest.Facebook.AppId) {
                            $pipeworksManifest.Facebook.AppId
                        } elseif ($pipeworksManifest.Facebook.AppIdSetting) {
                            Get-WebConfigurationSetting -Setting $pipeworksManfiest.Facebook.AppIdSetting
                        }
                }
            }

            
            if ($facebookAppId) {
                $faceBookArea = @"
<script src="//connect.facebook.net/en_US/all.js"></script>
<script>(function(d, s, id) {
  var js, fjs = d.getElementsByTagName(s)[0];
  if (d.getElementById(id)) return;
  js = d.createElement(s); js.id = id;
  js.src = "//connect.facebook.net/en_US/all.js#xfbml=1";
  fjs.parentNode.insertBefore(js, fjs);
}(document, 'script', 'facebook-jssdk'));</script>
"@
            }

            
            
            $bodyattr = ""
            if ($hideSafariUI) {
                $bodyattr += " ontouchmove='event.PreventDefault();'"
            }
            $bodyArea = @"
<body $bodyattr>
$facebookArea
$bodyArea
</body>            
"@            
                                             
            
            #region Propagate Pipeworks Manifest Settings
            if (-not $IgnoreManifest) {
            # If the Pipeworks Manifest of the loaded module has a style, and wishes to reuse it automatically
            if ($pipeworksManifest -and $pipeworksManifest.Style -and 
                -not $pipeworksManifest.SimplePages -and
                -not $psBoundParameters.Css) {        
                $css = $pipeworksManifest.Style                                     
            }
            
            # Ditto JQueryUI
            if ($pipeworksManifest -and ($pipeworksManifest.UseJQueryUI -or 
                $pipeworksManifest.JQueryUITheme) -and 
                (-not $pipeworksManifest.SimplePages)) {        
                $UseJQueryUI = $true
            }

            if ($pipeworksManifest -and 
                ($pipeworksManifest.UseFilePicker -or $pipeworksManifest.UseFilePickerIO)) {
                $UseFilePicker = $true
            }
            
            # Ditto JQuery
            if (($pipeworksManifest -and $pipeworksManifest.UseJQuery) -and 
                (-not $pipeworksManifest.SimplePages)) {        
                $useJQuery = $true
            }
            
            # Ditto Analytics ID
            if ((-not $psBoundParameters.AnalyticsID) -and 
                $pipeworksManifest -and $pipeworksManifest.AnalyticsID -and 
                (-not $pipeworksManifest.SimplePages)) {        
                $AnalyticsID = $pipeworksManifest.AnalyticsID
            }                        

            # And JQueryUI Theme
            if ($pipeworksManifest -and $pipeworksManifest.JQueryUITheme -and 
                (-not $pipeworksManifest.SimplePages)) {        
                $JQueryUITheme = $pipeworksManifest.JQueryUITheme
            }
            
            # Add RSS feeds, if available       
            if ($pipeworksManifest -and $pipeworksManifest.Blog.Link -and 
                $pipeworksManifest.Blog.Name -and
                -not $pipeworksManifest.SimplePages -and
                -not $psBoundParameters.Rss) {        
                $rss = @{$pipeworksManifest.Blog.Name = $pipeworksManifest.Blog.Link}
            }
            
            
            # If The Pipeworks manifest contains the Stealth sewtting, hide pages from search engines
            if ($pipeworksManfiest - $pipeworksManifest.Stealth -or $pipeworksManifest.UseStealth) {
                $HideFromSearchEngine = $true
            }
            
            
            
            
            if ($pipeworksManifest -and $pipeworksManifest.Javascript.Count) {
                foreach ($k in $pipeworksManifest.JavaScript.Keys) {
                    if ($k -like "*.js") {
                        if ($k -notlike "//*") {                        
                            $javascript += "$($k.TrimStart("\").Replace("\", "/"))"
                        } else {
                            $javascript += "$($k)"
                        }
                        
                    } else {
                        
                    }
                }
            }

            if ($pipeworksManifest.UseRaphael) {
                $UseRaphael = $true
            }

            if ($pipeworksManifest.UseGraphael) {
                $UseGRaphael = $true
            }

            #region GitIt
            if ($pipeworksManifest.GitIt) {                                
                foreach ($git in $pipeworksManifest.GitIt) {
                    if ($git -is [Hashtable]) {
                        foreach ($kv in $git.GetEnumerator()) {
                            if ($kv.Key -like "*.js") {
                                $JavaScript += "$($kv.Value.ToString().Replace('\','/'))"
                            } elseif ($kv.Value -like "*.css") {
                                $styleSheet += "$($kv.Value.ToString().Replace('\','/'))"
                            }
                        }
                    }

                }
            } 
            #endregion GitIt


            
            if ($UseTwitterBootstrap -or $pipeworksManifest.UseBootstrap) {                                
                $UseJQuery = $true
                $JavaScript += "JS/bootstrap.min.js"
                $styleSheet += "CSS/bootstrap.css"
                if (-not $UseJQueryui -or (-not $JQueryUITheme -or $JQueryUITheme -eq 'Custom')) {
                    $ContentDeliveryNetworkPreference = 'Local'
                }
                
            } 

            if ((-not $PipeworksManifest.UseJQueryUI -and -not $PipeworksManifest.UseBootstrap) -and $module) {                
                if (-not $pipeworksManifest.Css.PipeworksCss) {
                    if (-not $pipeworksManifest.Css) {
                        $pipeworksManifest.Css = @{}
                        $PipeworksManifest.Css['PipeworksCss'] = "css/$($module).css"
                    }
                }
                
            }
            
            if ($pipeworksManifest -and $pipeworksManifest.Css.Count) {
                foreach ($k in $pipeworksManifest.Css.Values) {
                    if ($k -like "*.css") {
                        if (-not $StyleSheet) {
                            $StyleSheet = @($k)
                        } else {
                            $styleSheet += @("$k")
                        }
                        
                    } elseif ($k -like "*.less") {
                        if ($k -like "http*:*") {
                            $dest = 'css/' + ((([uri]$k).Segments[-1]) -ireplace "\.less", ".css")
                            if (-not $StyleSheet) {                                
                                $StyleSheet = @($dest)
                            } else {
                                $styleSheet += @($dest)
                            }
                        } else {
                            if (-not $StyleSheet) {
                                $StyleSheet = @(($k -ireplace "\.less", ".css").TrimStart("/"))
                            } else {
                                $styleSheet += @(($k -ireplace "\.less", ".css").TrimStart("/"))
                            }
                        }
                        
                    }
                }
            }
            
            #endregion Propagate Pipeworks Manifest Settings
               
            #region JQuery Support
            
            if ($UseUserJQueryUiTheme -and
                $request -and $request.Cookie['Theme']) {
                $JQueryUITheme = $Request.Cookie['Theme']
            }
            
            # If JQueryUI is used, -UseJQuery is implied and forced to be true
            if ($UseJQueryUI) {            
                $UseJQuery = $true
            }                        
            
            if ($UseTableSorter) {
                $UseJQuery = $true
                if (-not $JavaScript) {
                    $javascript = "js/tablesorter.min.js"
                } else {
                    $javascript += "js/tablesorter.min.js"
                }
                
            }

            if ($UseFilePicker) {
                
                if (-not $JavaScript) {
                    $javascript = "//api.filepicker.io/v1/filepicker.js"
                } else {
                    $javascript += "//api.filepicker.io/v1/filepicker.js"
                }
                
            }

            if ($UseRaphael) {
                $UseJQuery = $true
                if (-not $JavaScript) {
                    $javascript += "js/raphael-min.js"
                } else {
                    $javascript += "js/raphael-min.js"
                }
                
            }

            if ($UseGRaphael) {
                $UseJQuery = $true
                if (-not $JavaScript) {
                    $javascript = "js/g.raphael.js", "js/g.pie.js", "js/g.bar.js", "js/g.line.js"
                } else {
                    $javascript += "js/g.raphael.js", "js/g.pie.js", "js/g.bar.js", "js/g.line.js"
                }
            }
            
            if ($UseJQuery) {
                
                if ($JQueryUITheme -eq 'Custom') {

                    $customJQueryMin = 
                        
                        if ([IO.FILE]::Exists("$PWD\js\jquery.min.js")) {
                            (Get-Item "js\jquery.min.js")
                        } else {
                        Get-ChildItem "JS" -Filter "jquery*min.js" -ErrorAction SilentlyContinue | 
                            Where-Object { $_.Name -notlike "*-ui*" } |
                            Select-Object -First 1 
                        }
                    if (-not $customJQueryMin) { 
                        $customJQueryMin = Get-ChildItem "JS" -Filter "jquery-*.js" -ErrorAction SilentlyContinue | 
                            Where-Object { $_.Name -notlike "*-ui*" } |
                            Select-Object -First 1 
                    }
                    $nested = ""
                    if (-not $customJQueryMin) {
                        $nested = "../"
                        $customJQueryMin = 
                            Get-ChildItem "../JS" -Filter "jquery*min.js" -ErrorAction SilentlyContinue | 
                                Select-Object -First 1 
                        if (-not $customJQueryMin) {
                            
                            $JQueryVersion = '1.7.2'
                        } else {
                            $JQueryVersion = $customJQueryMin.Name.replace("jquery-", "").Replace(".min.js", "").Replace(".js", "")
                        }                                                
                    } elseif ($customJQueryMin.Name -eq 'jquery.min.js') {
                        $JQueryVersion = '0.0.0.0'
                        
                    } else {                        
                        $JQueryVersion = $customJQueryMin.Name.replace("jquery-", "").Replace(".min.js", "").Replace(".js", "")
                    }

                    if ($JQueryVersion -eq '0.0.0.0') {
                        $javascript = @("${nested}JS/jquery.min.js") + $JavaScript
                    } else {
                        if ($customJQueryMin.Name -like "jquery-*.min.js") {
                            $javascript = @("${nested}JS/jquery-$JQueryVersion.min.js") + $javascript 
                        } else {
                        
                            $javascript = @("${nested}JS/jquery-$JQueryVersion.js") + $javascript 
                        }
                    }
                    
                } else {                               
                    if ($ContentDeliveryNetworkPreference -eq 'Microsoft') {
                        
                        $javascript = @("http://ajax.aspnetcdn.com/ajax/jquery/jquery-$JQueryVersion.min.js") + $JavaScript
                    } elseif ($ContentDeliveryNetworkPreference -eq 'Google') {
                        $javascript = @("http://ajax.googleapis.com/ajax/libs/jquery/jquery-$JQueryVersion.min.js") + $JavaScript
                    } elseif ($ContentDeliveryNetworkPreference -eq 'Local') {
                        $javascript = @("JS/jquery.min.js") + $JavaScript
                    }
                }
            }                             
            
            if ($UseJQueryUI) {
                if ($JQueryUITheme -eq 'Custom') {
                    
                    $customJQueryUIMin = Get-ChildItem "JS" -Filter "*.custom.min.js" -ErrorAction SilentlyContinue | 
                        Select-Object -First 1 
                    $nested = ""
                    if (-not $customJQueryUIMin) {
                        $nested = "../"
                        $customJQueryUIMin = Get-ChildItem "JS" -Filter "jquery*min.js" -ErrorAction SilentlyContinue | 
                            Select-Object -First 1 
                        if (-not $customJQueryUIMin) {
                            
                            $JQueryUIVersion = '1.8.19'
                        } else {
                            $JQueryUIVersion = $customJQueryUIMin.Name.replace("jquery-ui-", "").Replace(".custom.min.js", "")
                        }                                                
                    } else {
                        $JQueryUIVersion = $customJQueryUIMin.Name.replace("jquery-ui-", "").Replace(".custom.min.js", "")
                    }
                                                                                                                       
                    
                    $javascript += "JS/jquery-ui-$JQueryUIVersion.custom.min.js"
                    $styleSheet += "CSS/custom-theme/jquery-ui-$JQueryUIVersion.custom.css"
                } else {
                    if ($ContentDeliveryNetworkPreference -eq 'Microsoft') {
                        $javascript += "http://ajax.aspnetcdn.com/ajax/jquery.ui/$JQueryUIVersion/jquery-ui.min.js"                
                        $styleSheet += "http://ajax.aspnetcdn.com/ajax/jquery.ui/$JQueryUIVersion/themes/$JQueryUITheme/jquery-ui.css"                
                    } elseif ($ContentNetworkPerference -eq 'Google') {
                        $javascript += "http://ajax.googleapis.com/ajax/libs/jqueryui/$JQueryUIVersion/jquery-ui.min.js"
                        # Not a typo here, can't find the Google one yet
                        if (-not $styleSheet) { 
                            $styleSheet = "http://ajax.googleapis.com/ajax/libs/jqueryui/$JQueryUIVersion/themes/$JQueryUITheme/jquery-ui.css"
                        } else {
                            $styleSheet += "http://ajax.googleapis.com/ajax/libs/jqueryui/$JQueryUIVersion/themes/$JQueryUITheme/jquery-ui.css"
                        }
                    } else {
                    
                    }
                }
                
            }
            }
            #endregion
            
            
            # The Google Analytics Area
            $analyticsArea = 
                if ($AnalyticsId) {
@"
    <script type="text/javascript">

      var _gaq = _gaq || [];
      _gaq.push(['_setAccount', '$AnalyticsId']);
      _gaq.push(['_trackPageview']);

      (function() {
        var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
        ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
        var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);
      })();

    </script>
"@
                
            } else { ""} 
            
            $googleCheckOutArea = 
                if ($GoogleMerchantID) {
                    $aidArea = if ($analyticsID) {
                        "aid=`"$analyticsID`""
                    } else { ""}
@"
<script id="googlecart-script" type="text/javascript"
  src="http://checkout.google.com/seller/gsc/v2/cart.js?mid=$GoogleMerchantID"
  $aidArea
  currency="${GoogleCheckoutCurrency}">
</script>
"@                
                } else { ""}
        
            # RSS Metadata
            $rssLinkArea = if ($rss) { 
                foreach ($r in $rss.GetEnumerator()) {
                    if (-not $r) {continue } 
                    "<link rel='alternate' type='application/rss+xml' title='$($r.Key)' href='$($r.Value)' />"
                } 
            } else {
                ""
            }                
           
            if (-not $depth) {
                $depth = 0
                if ($request -and $request.Params -and $request.Params["HTTP_X_ORIGINAL_URL"]) {
                    #region Determine the Relative Path, Full URL, and Depth
                    $originalUrl = $context.Request.ServerVariables["HTTP_X_ORIGINAL_URL"]
                    $urlString = $request.Url.ToString().TrimEnd("/")
                    $pathInfoUrl = $urlString.Substring(0, 
                        $urlString.LastIndexOf("/"))
                                                                
                    $protocol = ($request['Server_Protocol'].Split("/", 
                        [StringSplitOptions]"RemoveEmptyEntries"))[0] 
                    $serverName= $request['Server_Name']                     
                
                    $port=  $request.Url.Port
                    $fullOriginalUrl = 
                        if (($Protocol -eq 'http' -and $port -eq 80) -or
                            ($Protocol -eq 'https' -and $port -eq 443)) {
                            $protocol+ "://" + $serverName + $originalUrl 
                        } else {
                            $protocol+ "://" + $serverName + ':' + $port + $originalUrl 
                        }
                                                        
                    $rindex = $fullOriginalUrl.IndexOf($pathInfoUrl, [StringComparison]"InvariantCultureIgnoreCase")
                    $relativeUrl = $fullOriginalUrl.Substring(($rindex + $pathInfoUrl.Length))
                    if ($relativeUrl -like "*/*") {
                        $depth = @($relativeUrl -split "/" -ne "").Count - 1                    
                        if ($fullOriginalUrl.EndsWith("/")) { 
                            $depth++
                        }                                        
                    } else {
                        $depth  = 0
                    }
                
                }
            }
            
           
            
            
            # If debug is not silentcontinue, always show javascript errors (because they probably want to see them)
            if ($debugPreference -ne 'SilentlyContinue') {
                $ShowJavaScriptError = $true
            }

            # A nifty error handler style
            $javaScriptErrorHandler = @"
    <style type="text/css">
    .errordialog {
        position:absolute; 
        width:100%; 
        border-bottom:1px solid black;
        background:lightyellow;
        left:0;
        top:0;
        padding: 3px 0;
        text-indent: 5px;
        font: normal 11px Verdana;
    }
    </style>
    <script type="text/javascript">
    // A default error handler     
    window.onerror=function(msg, url, linenumber){
        var dialog=document.createElement("div")
        dialog.className='errordialog'
        dialog.innerHTML='&nbsp;<b style="color:red">JavaScript Error: </b>' + msg +' at line number ' + linenumber +'.'
        document.body.appendChild(dialog)
        return true 
    }
    </script>        
"@      
            
            
            $hideSafariArea  =if ($HideSafariUI) {            
                $metaData.'apple-mobile-web-app-capable'  = 'yes'
                $metaData.'apple-mobile-web-app-status-bar-style'  = 'black'
            }           

            $scriptsToRun = @()
            $scriptsToInclude = @()
            $includedJs = @{}
            foreach ($js in $javascript) {
                if ($js -like "http://*" -or 
                    $js -like "https://*" -or
                    ($js -notlike "* *" -and $js -like "*.js")) {
                    if (-not $includedJs[$js]) {
                        $includedJs[$js] = $js
                    
                        if ($js -notlike "http*" -and $js -notlike "\\*") {
                            if ($depth) {
                                $scriptsToInclude += "<script src='$((("../" * $depth) + $js))'></script>"                        
                            } else {
                                $scriptsToInclude += "<script src='$js'></script>"                        
                            }
                        } else {
                            $scriptsToInclude += "<script src='$js'></script>"                        
                        }
                    }
                } else {
                    $scriptsToRun += "<script>
    $js
</script>"
                }                    
            }
            
            
            
            if ($depth -gt 0) {
                $styleSheet = 
                    foreach ($ss in $styleSheet) {
                        if ($ss -like "http://*") {
                            $ss
                        } else {
                            ("../" * $depth) + $ss
                        }
                    }
                
                
            }
           
            # Externally linked stylesheets
            $linkedSheets = @{}
            $externalCss = if ($styleSheet) {

                foreach ($ss in $styleSheet) {
                    if (-not $linkedSheets.$ss) {
                        $linkedSheets.$ss = $true
                        "<link rel='stylesheet' type='text/css' href='$ss' />"
                    } else {
                        continue
                    }
                    
                }
            }
            
            # Inline CSS styles
            $cssArea = if ($css) {            
                Write-CSS -Css $css            
            } else { ""} 




            $javaScriptArea = if ($scriptsToRun -or $scriptsToInclude) {
@"
$($scriptsToInclude -join ([Environment]::NewLine))
$($scriptsToRun -join ([Environment]::NewLine))
"@            
            } else {
                ""
            }
            
                        
            #region Bing and Google Webmaster Tools
            if (-not $BingValidationKey -and 
                $pipeworksManifest -and 
                $pipeworksManifest.BingValidationKey) {
                $BingValidationKey = $pipeworksManifest.BingValidationKey
            }
            
            if ($BingValidationKey) {
                $metaData['msvalidate.01'] = $BingValidationKey
            }
            
            
            if (-not $GoogleSiteVerification -and 
                $pipeworksManifest -and 
                $pipeworksManifest.GoogleSiteVerification) {
                $GoogleSiteVerification = $pipeworksManifest.GoogleSiteVerification
            }
            if ($GoogleSiteVerification) {

                $metaData['google-site-verification'] = $googleSiteVerification
            }
            #endregion Bing and Google Webmaster Tools
            
            $metaDataArea = if ($metadata -and $metaData.count) {
                foreach ($kvp in $metaData.GetEnumerator()) {
                    "<meta name='$($kvp.Key)' content='$([Web.HttpUtility]::HtmlAttributeEncode($kvp.Value))' />"
                }
            } else {
                ""
            }          
            
            $metaDataArea += if ($openGraph) {
                foreach ($kvp in $openGraph.GetEnumerator()) {
                    "<meta property='og:$($kvp.Key)' content='$([Web.HttpUtility]::HtmlAttributeEncode($kvp.Value))' />"
                }
            } else {
                ""
            }
            
            $metaDataArea += if ($FacebookAppId) {
                "<meta property='fb:app_id' content='$($FacebookAppId)' />"
            } else {
                ""
            }
            
            $metaDataArea += if ($noCache) {
                ""
                #"<meta http-equiv='expires' content='$((Get-Date).ToString('r'))' />"
            } elseif ($ExpirationDate) {
                ""
                #"<meta http-equiv='expires' content='$($expirationDate.ToString('r'))' />"
            } else {
                ""
            }


            $metaDataArea += if (-not $NoViewport) {
                "<meta name='viewport' content='width=device-width, initial-scale=1.0' />"
            }
            
            
            $metaDataArea += if ($HideFromSearchEngine) {
                "<meta name='ROBOTS' content='NOINDEX, NOFOLLOW' />"
            } else { 
                
                ""
                
            }


            if ($pipeworksManifest.Keyword) {
                if ($Keyword) {
                    $keyword += $pipeworksManifest.Keyword
                } else {
                    $keyword = $pipeworksManifest.Keyword
                }


            }
        
            $pinnedSiteJumpListArea = if ($pinnedSiteJumpList) {
                foreach ($r in $rss.GetEnumerator()) {
                    if (-not $r) {continue } 
                    "<link rel='alternate' type='application/rss+xml' title='$($r.Key)' href='$($r.Value)' />"
                } 
            }

            $pinnedSiteJumpListArea=  $pinnedSiteJumpListArea -join ([Environment]::NewLine)

            $rssLinkArea = $rssLinkArea -join ([Environment]::NewLine)
            



            $metaDataArea += "
$(if ($description) { "<meta name='Description' content='$($description)' /> " })
$(if ($Keyword) { $keywords = $keyword -join ',' ; "<meta name='keywords' content='$keywords' />" } )
$(if ($PostalCode) { $zipcodes = $PostalCode -join ',' ; "<meta name='zipcode' content='$zipcodes' />" } )
$(if ($PageHeader) { $PageHeader -ne '' -join ([Environment]::NewLine) })
$(if ($PinnedSiteName) { "<meta name='application-name' content='$PinnedSiteName' />" })
$(if ($PinnedSiteTooltip) { "<meta name='msapplication-tooltip' content='$PinnedSiteTooltip' />" })
$(if ($PinnedSiteUrl) { "<meta name='msapplication-starturl' content='$PinnedSiteUrl' />" })
$pinnedSiteJumpListArea
"

            
            $javaScriptErrorHandlerArea = "$(if ($showJavaScriptError) { $javaScriptErrorHandler })"
            $docTypeText = if (-not $NoDocType) { "<!DOCTYPE html>" } else { " "}

            #Region Handle Templates

            <#
            
            5/15/2013 - Web Templates @ Last


            Web Templates will be stored in the \Templates directory of a site, and are used to create a look and feel.


            The extension will be .pswt, and may contain only HTML and variable references.  
                        
            
            Handling of web templates occurs last, so that the template can access all of the automatic variables that New-WebPage has already created.   
                                                                                 
            #>


            $pageHeaderHtml = "
        $rssLinkArea
        $externalCss 
        $cssArea 
        $analyticsArea
        $googleCheckOutArea
        $javaScriptErrorHandlerArea 
        $hideSafariArea  
        $javaScriptArea
        $metaDataArea
"
            $textFromTemplate = ""

            if ($Template) {
                foreach ($temp in $Template) {
                    if ($temp -like "*<*") {
                        # IF the template contains tags, it must be an inline template (since < isn't a legal filename)
                        $TemplateExists = $true
                    }
                    
                    $TemplateExists = if (-not $templateExists) {
                        "Templates","Template"  | 
                            Where-Object {
                                ("$pwd\$_\$temp.pswt" -as [IO.FileInfo]).Length
                            } | 
                            Select-Object -First 1 |
                            Foreach-Object {
                                "$pwd\$_\$temp.pswt" -as [IO.FileInfo]
                            }                    
                    } else {
                        $true
                        $templateText = $temp 
                    }
                    if ($TemplateExists) {
                        $templateText = if (-not $templateText) {
                            [IO.File]::ReadAllText($TemplateExists.FullName)
                        } else {
                            $templateText
                        }
                
                        $templateText  = [Regex]::Replace($templateText , 
                        "\`$([\w-]{1,})", 
                        {

                        
                        $text = $args[0].Groups[1].ToString()
                        if ($text -ieq 'pipeworksmanifest') {
                            return ('$' + $args[0].Groups[1])
                        
                        }

                        # If it's castable to a double, it's probably a currency, not a variable
                        if ($text -as [Double]) {
                            return ('$' + $text)
                        }

                        if ($text -ieq 'true') {
                            return ('$' + $true)
                        }

                        if ($text -ieq 'false') {
                            return ('$' + $false)
                        }

                        if ($text -like "*username*" -or 
                            $text -like "*password*" -or 
                            $text -like "*secret*" -or 
                            $Text -like "*key*" -or 
                            $text -eq "home") {
                            return ('$' +$args[0].Groups[1])                        
                        }

                        $v = $ExecutionContext.SessionState.PSVariable.Get($text)
                    
                        if ($v) {
                            if ($iv.Value -isnot [string] -and $iv.Value -is [Collections.IEnumerable]) {
                                $scriptHtml = foreach ($iv in $v.Value) {
                                    if ($iv -is [string] -or 
                                        $iv -is [int] -or 
                                        $iv -is [float]) {
                                        $iv
                                    } else {
                                        $iv | Out-HTML
                                    }
                                }
                            } else {
                                if ($v.Value -is [string] -or 
                                    $v.Value -is [int] -or 
                                    $v.Value -is [float]) {
                                    $v.Value
                                } else {
                                    $v.Value | Out-HTML
                                }
                            } 
                                                
                        
                        } else {
                            $scriptHtml =""
                        }


                        if ($scriptHtml) {
                            $scriptHtml
                        } else {
                            if ($debugPreference -ne 'SilentlyContinue') {
                                return ('$' + $args[0].Groups[1])
                            } else {
                                return ' ' 
                            }
                        }
                    }, 
                        "Multiline,IgnoreCase")



                        $textFromTemplate = $templateText
                    }
                }
            }
            

            #Endregion Handle Templates


            if ($textFromTemplate) {
                $page = $textFromTemplate
            } else {
            
            
            

            $page = @"
$docTypeText<html>
<Head>
<title>$Title</title>
$rssLinkArea
$externalCss 
$cssArea 
$javaScriptArea
$analyticsArea
$googleCheckOutArea
$javaScriptErrorHandlerArea 
$hideSafariArea  

$metaDataArea
</Head>
$BodyArea
</html>
"@
}
    $pageAsXml = $page.Replace('&', '&amp;') -as [xml]
    
    if ($pageAsXml -and 
        $page -notlike "*<pre*") {
        $strWrite = New-Object IO.StringWriter
        $pageAsXml.Save($strWrite)
        $strOut = "$strWrite"
        $strOut.Substring($strOut.IndexOf(">") + 3).Replace("<!DOCTYPE html[]>", "<!DOCTYPE html>").Replace("&amp;", "&")
    } else {
        $page

    }
    
    }        
}
