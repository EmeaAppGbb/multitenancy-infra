$rgPrefix = "cns-prod-tenant-"
$existingGroups = Get-AzResourceGroup | Where-Object { $_.ResourceGroupName -like "$rgPrefix*" }
$tenants = Get-Content $PSScriptRoot/tenants.json | ConvertFrom-Json

foreach ($rg in $existingGroups) {
    $tenant = $tenants | Where-Object { $_.name -eq $rg.ResourceGroupName.TrimStart($rgPrefix) }
    if ($tenant -eq $null) {
        # Remove-AzResourceGroup -Name $rg.ResourceGroupName -Force
        Write-Host "Deleting resource group $($rg.ResourceGroupName)"
    }
}