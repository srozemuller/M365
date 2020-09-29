function get-tenantInfo {
    param
    (
        [Parameter (Mandatory = $true)][object] $tenantId,
        [Parameter (Mandatory = $true)][object] $clientId,
        [Parameter (Mandatory = $true)][object] $clientSecret
    )
    $results = @()
    # Construct URI
    $uri = "https://login.microsoftonline.com/$tenantId/oauth2/v2.0/token"
    # Construct Body
    $body = @{
        client_id     = $clientId
        scope         = "https://graph.microsoft.com/.default"
        client_secret = $clientSecret
        grant_type    = "client_credentials"
    }
    write-host  "Get OAuth 2.0 Token"
    # Get OAuth 2.0 Token
    $tokenRequest = Invoke-WebRequest -Method Post -Uri $uri -ContentType "application/x-www-form-urlencoded" -Body $body -UseBasicParsing
    # Access Token
    $token = ($tokenRequest.Content | ConvertFrom-Json).access_token
    # Graph API call in PowerShell using obtained OAuth token (see other gists for more details)
    # Specify the URI to call and method
    $method = "GET"
    $uri = "https://graph.microsoft.com/beta/security/securescores?`$top=1"
    write-host "Run Graph API Query"
    # Run Graph API query 
    $query = Invoke-WebRequest -Method $method -Uri $uri -ContentType "application/json" -Headers @{Authorization = "Bearer $token" } -ErrorAction Stop 
    write-host  "Parse results"
    $ConvertedOutput = $query | Select-Object -ExpandProperty content | ConvertFrom-Json

    write-host  "Display results`n"
    foreach ($obj in $convertedoutput.value) {
        $mainCustomerObject = [PSCustomObject][Ordered]@{
            objectId         = $obj.id
            tenantId         = $obj.azureTenantId
            activeUsers      = $obj.activeUserCount
            date             = $obj.createdDateTime
            enabledServices  = ($obj.enabledServices).replace("Has", $null)
            currentScore     = $obj.currentScore
            maxPossibleScore = $obj.maxScore
        }
        $results += $mainCustomerObject
    }
    return $results
}

$tenantParameters = @{
tenantId = xxx
clientId = xxx
clientSecret = xxx
}
$tenantInfo = get-TenantInfo @tenantParameters
