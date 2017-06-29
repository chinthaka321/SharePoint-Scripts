Add-PSSnapin Microsoft.SharePoint.PowerShell –erroraction SilentlyContinue
 
$web = Get-SPWeb -Identity http://url
$list = $web.GetList($web.Url + "/Lists/" + "ListName")
 
$type = "ItemUpdated" #or any other type, like ItemDeleting, ItemAdded, ItemUpdating ...
$assembly = "CHI.Compliance.TestEventHandler, Version=1.0.0.0, Culture=neutral, PublicKeyToken=ccae91b616ee0449"
$class = "TestComplianceItemEventReceiver"
 
$list.EventReceivers.Add($type, $assembly, $class)
 
$web.Dispose()
