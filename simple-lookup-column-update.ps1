$spWeb = Get-SPWeb -Identity http://url
$spList = $spWeb.Lists["TestList"]
$spItem = $spList.Items[2]
#$Lookup = new-object Microsoft.SharePoint.SPFieldLookupValue($spItem["LookUp"])
#$User = $Lookup.LookupValue;
$spItem["LookUp"] = '3;#LookUpValue03'
$spItem.Update()
