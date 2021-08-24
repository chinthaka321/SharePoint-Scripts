<#
.Synopsis
    Obtain an app-only access token from ACS.
.DESCRIPTION
    Retrieves an app-only access token from ACS to call the specified principal 
    at the specified targetHost. The targetHost must be registered for target principal.  If specified realm is 
    null, the "Realm" setting in web.config will be used instead
.EXAMPLE
   Get-SPOAccessToken -Url "https://contoso.sharepoint.com/_api/web" -ClientId "" -ClientSecret ""
#>
Function Get-SPOAccessToken([string]$ClientId,[string]$ClientSecret,[Uri]$Url){
    $SharePointPrincipal = "00000003-0000-0ff1-ce00-000000000000"
    $realm = GetRealmFromTargetUrl -TargetApplicationUri $Url
    $accessToken = GetAppOnlyAccessToken -ClientId $ClientId -ClientSecret $ClientSecret -TargetPrincipalName $SharePointPrincipal -TargetHost $Url.Authority -TargetRealm $realm
    return $accessToken.access_token
}

function GetRealmFromTargetUrl([Uri]$TargetApplicationUri)
{

   $url = $WebUrl + "/_vti_bin/client.svc" 
   $headers = @{}
   $headers.Add('Authorization','Bearer')
   try {
       $response = Invoke-WebRequest -Uri $TargetApplicationUri -Headers $headers -Method Get
   }
   catch [Net.WebException] {
      $authResponseHeader = $_.Exception.Response.Headers["WWW-Authenticate"]
      #$bearerKey = "Bearer realm="
      $bearer = $authResponseHeader.Split(",")[0]
      $targetRealm = $bearer.Split("=")[1]
      return $targetRealm.Substring(1,$targetRealm.Length-2)
   }
   return $null
}

 
Function GetAppOnlyAccessToken([string]$ClientId,[string]$ClientSecret,[string]$TargetPrincipalName,[string]$TargetHost,[string]$TargetRealm)
{
    $resource = GetFormattedPrincipal -PrincipalName $TargetPrincipalName -HostName $TargetHost -Realm $TargetRealm
    $ClientId = GetFormattedPrincipal -PrincipalName $ClientId -Realm $TargetRealm
    $contentType = 'application/x-www-form-urlencoded'
    $stsUrl = GetSecurityTokenServiceUrl -Realm $TargetRealm
    $oauth2Request = CreateAccessTokenRequestWithClientCredentials -ClientId $ClientId -ClientSecret $ClientSecret -Scope $resource
    $oauth2Response = Invoke-RestMethod -Method Post -Uri $stsUrl -ContentType $contentType -Body $oauth2Request
    return $oauth2Response
}


Function GetSecurityTokenServiceUrl([string]$Realm)
{
   return "https://accounts.accesscontrol.windows.net/$Realm/tokens/OAuth/2"
}


Function CreateAccessTokenRequestWithClientCredentials([string]$ClientId,[string]$ClientSecret,[string]$Scope)
{
   $oauth2Request =  @{ 
     'grant_type' = 'client_credentials';
     'client_id' = $ClientId;
     'client_secret' = $ClientSecret;
     'scope' = $Scope;
     'resource' = $Scope
   } 
   return $oauth2Request
}

function GetFormattedPrincipal([string]$PrincipalName, [string]$HostName, [string]$Realm)
{
   if ($HostName)
   {
       return "$PrincipalName/$HostName@$Realm"
   }
   return "$PrincipalName@$Realm"
}


$token = Get-SPOAccessToken -Url "https://yourtenant.sharepoint.com/_api/web" -ClientId "esx7e0e31-6852-4f78-a48a-ab0eew96794ab0b" -ClientSecret "wesdersefewQOaOwSni7WD4vyNe+lDLqo="

$headers = @{
    'Authorization' = 'Bearer ' + $token
    'Accept' = 'application/json;odata=verbose'
}

Invoke-RestMethod -Method Get -Uri "https://yourtenant.sharepoint.com/sites/DevSite/_api/web/lists/getbytitle('IT%20Requests')/Items?$select=ID,Title,Category" -Header $headers