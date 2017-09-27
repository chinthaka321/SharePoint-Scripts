$spWeb = Get-SPWeb -Identity http://SharePoint #Replace with your URL
$spList = $spWeb.Lists["LIST"] #List name
$spItem = $spList.GetItemById(8158) #Item ID

$assembly = [Reflection.Assembly]::LoadWithPartialName("Microsoft.SharePoint");
$type = $assembly.GetType("Microsoft.SharePoint.SPEventManager");
$prop = $type.GetProperty([string]"EventFiringDisabled",[System.Reflection.BindingFlags] ([System.Reflection.BindingFlags]::NonPublic -bor [System.Reflection.BindingFlags]::Static));
 
$prop.SetValue($null, $true, $null); #Disable event firing
 
$spItem["Column Name"]= "Desired Value"
$spItem.SystemUpdate($false)
$prop.SetValue($null, $false, $null);#Enable event firing

write-host "done."
