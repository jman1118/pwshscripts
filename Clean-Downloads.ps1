#Clean-Downloads.ps1

$size = (Get-ChildItem 'C:\Users\jman1\Downloads\*' -Recurse | Measure-Object -Property Length -Sum).sum / 1GB
$size = [Math]::Round($size,2) 
$choices = '&Yes','&No'
$confirm = $host.UI.PromptForChoice("Delete all Downloads?","Downloads contains $size of files. Are you sure you want to delete all contents?",$choices,1)

function Delete {

    Write-host 'Deleting all files in Downloads'
    Get-ChildItem 'C:\Users\jman1\Downloads\*' | Remove-Item -Recurse -Force -Confirm:$false

}

if($confirm -eq 0){
    #write-host 'yes'
    Delete
}
else {
    #Write-host 'No'
}
