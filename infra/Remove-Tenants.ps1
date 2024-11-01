param(
    [string] $EnvironmentName
)

if (-not $EnvironmentName) {
    Write-Error "EnvironmentName parameter is required."
    return
}

$rgPrefix = "cns-$EnvironmentName-tenant-"
$existingGroups = Get-AzResourceGroup | Where-Object { $_.ResourceGroupName -like "$rgPrefix*" }

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

foreach ($rg in $existingGroups) {
    $tenant = $tenants | Where-Object { $rg.ResourceGroupName -match $_ }
    if ($null -eq $tenant) {
        # Remove-AzResourceGroup -Name $rg.ResourceGroupName -Force
        Write-Host "Deleting resource group $($rg.ResourceGroupName)"
    }
}