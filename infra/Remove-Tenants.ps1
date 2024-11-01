param(
    [string] $EnvironmentName
)

if (-not $EnvironmentName) {
    Write-Error "EnvironmentName parameter is required."
    return
}

Write-Verbose "Reading Deployed tenants in environment '$EnvironmentName'" -Verbose
$rgPrefix = "cns-$EnvironmentName-tenant-"
$existingGroups = Get-AzResourceGroup | Where-Object { $_.ResourceGroupName -like "$rgPrefix*" }
$existingGroups | ForEach-Object { 
    Write-Verbose "Deployed tenant: '$($_.ResourceGroupName)'" -Verbose
}


$paramFilePath = "main.$EnvironmentName.bicepparam"
if(test-Path $PSScriptRoot) {
    $paramFilePath  = "$PSScriptRoot/$paramFilePath"
}
Write-Verbose "Reading tenants from '$paramFilePath'" -Verbose
$tenantsobj = Get-Content $paramFilePath -Verbose
$tenants = @()
$tenantsobj -match "name: '(?<name>[^']*)'" | % {
    # "    name: 'customer1'"
    $tenants += $_.TrimStart("name: ") -replace "'", ""
}
$tenants | ForEach-Object { 
    Write-Verbose "Declared tenant: '$_'" -Verbose
}

Write-Verbose "Start deleting tenants resource groups..." -Verbose
foreach ($rg in $existingGroups) {
    $tenant = $tenants | Where-Object { $rg.ResourceGroupName -match $_ }
    if ($null -eq $tenant) {
        Write-Verbose "Deleting resource group $($rg.ResourceGroupName)..." -Verbose
        Remove-AzResourceGroup -Name $rg.ResourceGroupName -Force
        Write-Verbose "Finish Deleting resource group $($rg.ResourceGroupName)." -Verbose
        
    }
}