if((Get-PSSnapin | Where {$_.Name -eq "Microsoft.SharePoint.PowerShell"}) -eq $null) {
    Add-PSSnapin Microsoft.SharePoint.PowerShell;
}

$sourceWebURL = "http://url"
$sourceListName = "ListName"

$spSourceWeb = Get-SPWeb -site $sourceWebURL
$spSourceList = $spSourceWeb.Lists[$sourceListName]
#$spSourceItems = $spSourceList.GetItems()
#$spSourceItems = $spSourceList.GetItemById("1")
$spSourceItems = $spSourceList.Items | where {$_['Title'] -eq '44422'}

$spSourceItems | ForEach-Object {
    Write-Host $_['ID']
    Write-Host $_['Business Unit']
} 
