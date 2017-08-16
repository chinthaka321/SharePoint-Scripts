Add-PSSnapin Microsoft.SharePoint.PowerShell

[System.reflection.Assembly]::LoadWithPartialName("Microsoft.SharePoint")
$web = Get-SPWeb "http://zdc1ws048:4321/sites/compliance"
$list = $web.Lists["List Title"]
$DeleteBeforeDate = [Microsoft.SharePoint.Utilities.SPUtility]::CreateISO8601DateTimeFromSystemDateTime([DateTime]::Now.AddDays(-7))
$caml='<Where> <Lt> <FieldRef Name="ID" /><Value Type="Counter">{0}</Value> </Lt> </Where> ' -f 1000
$query=new-object Microsoft.SharePoint.SPQuery
$query.Query=$caml
$col=$list.GetItems($query)
Write-Host $col.Count
$col | % {$list.GetItemById($_.Id).Delete()}



$web.Dispose()
