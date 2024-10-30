$existingGroups = Get-AzResourceGroup | Where-Object { $_.ResourceGroupName -like "rg-tenant-*" }
$tenants = Get-Content tenants.json | ConvertFrom-Json

foreach ($rg in $existingGroups) {
    $tenant = $tenants | Where-Object { $_.name -eq $rg.ResourceGroupName.TrimStart("rg-tenant-") }
    if ($tenant -eq $null) {
        # Remove-AzResourceGroup -Name $rg.ResourceGroupName
        Write-Host "Deleting resource group $($rg.ResourceGroupName)"
    }
}