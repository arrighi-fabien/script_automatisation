function delete_object {
    foreach ($ou_key in $ous.Keys) {
        foreach ($sub_ou in $ous[$ou_key]) {
            try {
                $sub_ou_path = "OU=$sub_ou,OU=$ou_key,$ou_path"
                Set-ADObject -Identity $sub_ou_path -ProtectedFromAccidentalDeletion $false -Server $domain_controller
                Remove-ADObject -Identity $sub_ou_path -Server $domain_controller -Recursive
                Write-Host "subOU '$sub_ou' of OU '$ou_key' deleted successfully."
            }
            catch {
                Write-Host "Failed to delete subOU '$sub_ou' of OU '$ou_key'. Error: $_"
            }
        }
        try {
            Set-ADObject -Identity "OU=$ou_key,$ou_path" -ProtectedFromAccidentalDeletion $false -Server $domain_controller
            Remove-ADObject -Identity "OU=$ou_key,$ou_path" -Server $domain_controller -Recursive
            Write-Host "OU '$ou_key' deleted successfully."
        }
        catch {
            Write-Host "Failed to delete OU '$ou_key'. Error: $_"
            break
        }
    }

    $gpos = @("Uniform lock background", "Uniform background", "Block USB", "Block powershell script", "Disalow installation of software")
    Remove-Item "C:\Ressources_partagees" -Recurse -Force
    Remove-SmbShare -Name "Ressources partagées"
    foreach ($gpo in $gpos) {
        try {
            Remove-GPO -Name $gpo -Server $domain_controller -ErrorAction Stop
            Write-Host "GPO '$gpo' deleted successfully."
        }
        catch {
            Write-Host "Failed to delete GPO '$gpo'. Error: $_"
        }
    }
}
