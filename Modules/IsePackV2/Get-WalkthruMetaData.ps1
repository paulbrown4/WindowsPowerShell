# Some Demo Text
# Some More Demo Text
#.Audio MyAudioFile
#.Video MyVideoFile
#.Question "What Color is the Sky?"
#.Answer {$input -like "*Blue*" }
#.Hint { "Look Outside", "On a Nice Day", "Are you color blind?" }
function Get-WalkthruMetaData {
    <#
        .SynsopsiS
            Gets information from a file as a walkthru
    #>
    param(
    [Parameter(ValueFromPipelineByPropertyName=$true)]
    [Alias('Fullname')]
    [string]$file
    )
    
    begin {
        if (-not ('PSWalkthru.WalkthruData' -as [Type])) {
            Add-Type -UsingNamespace System.Management.Automation -Namespace PSWalkthru -Name WalkthruData -MemberDefinition '
public string SourceFile = String.Empty;','
public string Explanation = String.Empty;','
public string AudioFile = String.Empty;','
public string VideoFile = String.Empty;','
public string Question = String.Empty;','
public string Answer = String.Empty;','
public string[] Hint;','
public ScriptBlock Script;'
        }
    }
    process {
        $realItem = Get-Item $file -ErrorAction SilentlyContinue
        if (-not $realItem) { return } 
        $err = $null
        $text = [IO.File]::ReadAllText($realItem.FullName)
        $tokens = [Management.Automation.PSParser]::Tokenize($text, [ref]$err)
        if ($err.Count) { return } 

        $lastToken = $null
        $isInContent = $false
        $lastResult = New-Object PSWalkthru.WalkthruData

        foreach ($token in $tokens) { 
            if ($token.Type -eq "Newline") { continue }
            if ($token.Type -ne "Comment" -or $token.StartColumn -gt 1) {
                $isInContent = $true
                if (-not $lastToken) { $lastToken = $token } 
            } else {
                if ($lastToken.Type -ne "Comment" -and $lastToken.StartColumn -eq 1) {
                    $chunk = $text.Substring($lastToken.Start, 
                        $token.Start - 1 - $lastToken.Start)
                    $lastResult.Script = [ScriptBlock]::Create($chunk)
                    # mutliparagraph, split up the results if multiparagraph
                    
                    $paragraphs = @()
                    $lastIndex = -1
                    $index = $lastResult.Explanation.IndexOf("." + [Environment]::NewLine)
                    while ($index -ne -1) {
                        $paragraphs+= $lastResult.Explanation.Substring($lastIndex + 1, $index - $lastIndex)
                        $lastindex = $index
                        $index = $lastResult.Explanation.IndexOf("." + [Environment]::NewLine, 
                            $index + 1)
                    }
                    if (-not $paragraphs) {
                        $lastResult
                    } else {
                        foreach ($p in $paragraphs) {
                            New-Object PSWalkthru.WalkthruData -Property @{Explanation = $p}
                        }
                        if ($lastIndex -ne -1) {
                            $lastResult.Explanation = $lastResult.Explanation.Substring($lastIndex + 1)
                        }
                        $lastResult
                    }

                    $null = $paragraphs
                    $lastToken = $null
                    $lastResult = New-Object PSWalkthru.WalkthruData
                    $isInContent = $false                
                }
            }
            if (-not $isInContent) {
                $lines = $token.Content.Trim("<>#")
                $lines = $lines.Split([Environment]::NewLine, 
                    [StringSplitOptions]"RemoveEmptyEntries")
                foreach ($l in $lines) {
                    switch ($l) {
                        {$_ -like ".Audio *" } {
                            $lastResult.AudioFile =
                                $l.Substring(".Audio ".Length)
                        }
                        {$_ -like ".Video *" } {
                            $lastResult.VideoFile =
                                $l.Substring(".Video ".Length)
                        }                        
                        {$_ -like ".Question *" } {
                            $lastResult.Question =
                                $l.Substring(".Question ".Length)
                        }                        
                        {$_ -like ".Answer *" } {
                            $lastResult.Question =
                                $l.Substring(".Answer ".Length)
                        }
                        {$_ -like ".Hint *" } {
                            $lastResult.Question =
                                $l.Substring(".Hint ".Length) -split ','
                        }                        
                        default {
                            $lastResult.Explanation += ($l + [Environment]::NewLine)                        
                        }
                    }
                }
            }            
        }
        
        if ($lastToken -and $lastResult) {
            $chunk = $text.Substring($lastToken.Start)
            $lastResult.Script = [ScriptBlock]::Create($chunk)
            $lastResult
        }
    }
}

# More commments
$null = Get-Process
