. ./create_ou.ps1
. ./create_group.ps1
. ./create_user.ps1
. ./create_gpo.ps1
. ./delete_object.ps1

$dc_1 = "abstergo"
$dc_2 = "local"
$domain_name = "$dc_1.$dc_2"
$domain_controller = "srvadds.$domain_name"
$ou_path = "DC=$dc_1,DC=$dc_2"

$ous = @{
    "Employes" = @("Direction", "Administratif", "Production", "Commercial", "RnD")
    "Admin" = @()
}

$groups = @{
    "Employes" = @{
        "Direction" = @("Direction")
        "Administratif" = @("Administratif")
        "Production" = @("Production")
        "Commercial" = @("Commercial")
        "RnD" = @("RnD")
    }
    "Admin" = @(
        "pfSense Admin",
        "Centreon Admin"
    )
}

$create = Read-Host "Do you want to create (c) or delete (d) the AD structure?"
if ($create -eq "c") {
    create_ou
    create_group
    create_user
    create_gpo
} elseif ($create -eq "d") {
    delete_object
} else {
    Write-Host "Please enter c or d"
}
