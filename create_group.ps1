function create_group {
    foreach ($ou_key in $groups.Keys) {
        if ($groups[$ou_key] -is [object]) {
            foreach ($group_key in $groups[$ou_key].Keys) {
                foreach ($group in $groups[$ou_key][$group_key]) {
                    try {
                        $group_path = "OU=$group_key,OU=$ou_key,$ou_path"
                        New-ADGroup -GroupCategory Security -GroupScope DomainLocal -Name $group -Path "$group_path" -Server $domain_controller
                        Write-Host "Group '$group' of OU '$group_key' of OU '$ou_key' created successfully."
                    }
                    catch {
                        Write-Host "Failed to create Group '$group'. Error: $_"
                    }
                }
            }
        }
        elseif ($groups[$ou_key] -is [array]) {
            foreach ($group in $groups[$ou_key]) {
                try {
                    $group_path = "OU=$ou_key,$ou_path"
                    New-ADGroup -GroupCategory Security -GroupScope DomainLocal -Name $group -Path "$group_path" -Server $domain_controller
                    Write-Host "Group '$group' of OU '$ou_key' created successfully."
                }
                catch {
                    Write-Host "Failed to create Group '$group'. Error: $_"
                }
            }
        }
    }
}
