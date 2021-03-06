function Find-FormatView
{
    <#
    .Synopsis
        Finds a format view for a typename
    .Description
        Finds a format view for a given typename
    .Example
        Find-FormatView System.Diagnostics.Process
    .Link
        Get-FormatFile  
    #>
    param(
    # The name of the type of format view to find
    [ParameteR(Mandatory=$true,
        Position=0,
        ValueFromPipelineByPropertyName=$true,
        ValueFromPipeline=$true)][string]
    $TypeName
    )
    begin {
        $formatFiles = Get-FormatFile
        
        $allViews = $formatFiles | 
            Select-Xml //View
        
        $selectionSets = $formatFiles | 
            Select-Xml //SelectionSet | 
            Select-Object @{
                Label='Name'
                Expression={$_.Node.Name}
            }, @{
                Label='Types'
                Expression={$_.Node.Types}
            }
            
        $viewByType = @{}
        
        $allViews | 
            Where-Object { 
                $selectionSetName = $_.Node.ViewSelectedBy.SelectionSetName 
                if (-not $selectionSetName) {
                    $viewByType[$_.Node.ViewSelectedBy.TypeName] = $_.Node                    
                } else {
                    $selectionSetName
                }
            } |
            ForEach-Object { 
                $node = $_.Node
                $selectionSet = $selectionSets | 
                    Where-Object  { $_.Name -eq $node.ViewSelectedBy.SelectionSetName } 
                $selectionSet.Types.TypeName | 
                    Foreach-Object {
                        if ($viewByType.Contains($_)) {
                            $viewByType[$_] = @($viewByType[$_]) + $node
                        } else {
                            $viewByType[$_] = $node                        
                        }
                    }
            } 
    }
    
    process {
        $formatByType= $formatFiles | 
            Select-Xml //ViewSelectedBy/TypeName | 
            Where-Object { $_.Node.'#text' -eq $TypeName } 
            
        

        if ($formatByType) {
            foreach ($ft in $formatByType) {
                $psObject = $ft.Node.SelectSingleNode("../..")
                $psobject.psobject.typenames.Insert(0,"FormatView")
                $psobject
            }
        } else {                    
            $hasSelectionSet = $formatFiles | 
                Select-Xml //SelectionSet |
                Where-Object { $_.Node.Types.TypeName -contains $TypeName } |
                Select-Object -Unique
            
            if ($hasSelectionSet) {
                $formatFiles | 
                    Select-Xml //ViewSelectedBy/SelectionSetName |
                    Where-Object {$_.node.'#text' -eq $hasSelectionSet.Node.Name } |
                    Select-Object -Unique | 
                    ForEach-Object { 
                        $psObject = $_.Node.SelectSingleNode("../..") -as [psobject]
                        $psobject.psobject.typenames.Insert(0,"FormatView")
                        $psobject
                    }                                        
            }
        }
    }
}
