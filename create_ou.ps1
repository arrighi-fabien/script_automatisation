function create_ou {
    foreach ($ou_key in $ous.Keys) {
        try {
            New-ADOrganizationalUnit -Name $ou_key -Path "$ou_path" -Server $domain_controller
            Write-Host "OU '$ou_key' created successfully."
        }
        catch {
            Write-Host "Failed to create OU '$ou_key'. Error: $_"
            break
        }
        foreach ($sub_ou in $ous[$ou_key]) {
            try {
                $sub_ou_path = "OU=$ou_key,$ou_path"
                New-ADOrganizationalUnit -Name $sub_ou -Path "$sub_ou_path" -Server $domain_controller
                Write-Host "subOU '$sub_ou' of OU '$ou_key' created successfully."
            }
            catch {
                Write-Host "Failed to create OU '$ou_key'. Error: $_"
            }
        }
    }
}
