function Switch-SelectedCommentOrText {
    <#
    .Synopsis
        Toggles Comments on the selected text
    .Description
        Toggles comments on the currently selected text.
        Comment lines will be uncommented and uncommented lines will be commented
    .Example
        Switch-SelectedCommentOrText
    #>    
    param()
	$editor = Get-CurrentDocumentEditor
    $selection = Select-CurrentText -NotInCommandPane -NotInOutput
    if ($selection) {
        $toggled = Switch-CommentOrText $selection
        Add-TextToCurrentDocument -Text $toggled
    }
}
