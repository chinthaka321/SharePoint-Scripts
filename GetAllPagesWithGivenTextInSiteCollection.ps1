[System.Reflection.Assembly]::Load(“Microsoft.SharePoint, Version=15.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c”)
[System.Reflection.Assembly]::Load(“Microsoft.SharePoint.Portal, Version=15.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c”)

#Internet site url
$siteURL = "http://sitesei.site.com.au/"
#output file url
$outputFile = "C:\pageslist.csv"
#Text to search on the page
$TextToSearch="www.sdfsd.com/sites/site/corner/site1"

$site = New-Object Microsoft.SharePoint.SPSite($siteURL)
$spSite = [Microsoft.SharePoint.SPSite] ($site)
 
if($spSite -ne $null)
{
   #"Site Collection : " + $spSite.Url | Out-File $out -Append
   foreach($subWeb in $spSite.AllWebs)
   {
      if($subWeb -ne $null)
      {
         #Print each Subsite
         Write-Host $subWeb.Url
          
         $spListColl = $subweb.Lists
         foreach($eachList in $spListColl)
         {
            if(($eachList.Title -eq "Pages") -or ($eachList.Title -eq "SitePages") -or ($eachList.Title -eq "Site Pages"))
            {
               $PagesUrl = $subweb.Url + "/"
               foreach($eachPage in $eachList.Items)
               {
                $Page = $eachPage.File
                if($Page.Properties.PublishingPageContent)
                {
                    $PageCOntent= $Page.Properties.PublishingPageContent
                    if($PageCOntent -like '*'+$TextToSearch+'*' ) 
                    {
                        Write-Output "$($Page.ServerRelativeUrl),Found a link in PageContent"  | Out-File $outputFile -Append
                    }
                }

                try{
                    #Web Part Manager to get all web parts from the file
                    $WebPartManager = $subweb.GetLimitedWebPartManager( $Page.ServerRelativeUrl,[System.Web.UI.WebControls.WebParts.PersonalizationScope]::Shared)
  
                    #Iterate through each web part
                    foreach($webPart in $WebPartManager.WebParts)
                    {
                        # Get All Content Editor web parts with specific Old Link
                        if( ($webPart.Content.InnerText -like '*'+$TextToSearch+'*' ) -and ($webPart.GetType() -eq [Microsoft.SharePoint.WebPartPages.ContentEditorWebPart]) )
                        {
                            Write-Output "$($Page.ServerRelativeUrl),Found a link in CEWP"  | Out-File $outputFile -append
                        }
                    }
                } 
                catch [System.Exception] 
                { 
                    write-host -f red $_.Exception.ToString()    
                }
               }
            }
         }
         $subWeb.Dispose()
      }
      else
      {
         Echo $subWeb "does not exist"
      }
   }
   $spSite.Dispose()
}
else
{
   Echo $siteURL "does not exist, check the site collection url"
}

Echo Finish
