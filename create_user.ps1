function create_user {
    $csv_output = @()
    $sub_ou_path = "OU=Employes,$ou_path"
    $data = Import-Csv -Path "$PSScriptRoot/data/user.csv" -Delimiter ";"
    foreach ($row in $data) {
        $password = generatePassword
        $secured_password = ConvertTo-SecureString -String $password -AsPlainText -Force
        $first_name = $row.FirstName
        $last_name = $row.LastName
        $email = $first_name + "." + $last_name + "@" + $domain_name
        $user_params = @{
            'DisplayName' = $first_name + " " + $last_name
            'GivenName' = $first_name
            'Surname' = $last_name
            'Name' = $first_name + " " + $last_name
            'SamAccountName' = $first_name + "." + $last_name
            'UserPrincipalName' = $email
            'EmailAddress' = $email
            'Path' = "OU=" + $row.Service + "," + $sub_ou_path
            'Server' = $domain_controller
            'Type' = 'user'
            'Enabled' = $true
            'AccountPassword' = $secured_password
            'ChangePasswordAtLogon' = $true
            'PassThru' = $true
        }
        try {
            $new_user = New-ADUser @user_params
            $group_path = "CN=" + $row.Service + ",OU=" + $row.Service + "," + $sub_ou_path
            Add-ADGroupMember -Identity $group_path -Members $new_user -Server $domain_controller
            Write-Host "User '$($user_params['Name'])' created successfully and added to "$row.Service" Group."
            $csv_output += [PSCustomObject]@{
                'FirstName' = $row.FirstName
                'LastName' = $row.LastName
                'Password' = $password
            }
        }
        catch {
            Write-Host "Failed to create user '$($user_params.DisplayName)'. Error: $_"
        }
    }

    $csv_output | Export-Csv -Path "$PSScriptRoot/data/user_passwords.csv" -Delimiter ";" -Encoding UTF8 -NoTypeInformation
}

function generatePassword {
    $lenght = 16

    $lower_case = "abcdefghijklmnopqrstuvwxyz"
    $upper_case = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    $numbers = "0123456789"
    $special_characters = "!@#$%^&*()_-+=<>?/{}[]"

    $random = New-Object System.Random

    $password = $lower_case[$random.Next(0, $lower_case.Length)]
    $password += $upper_case[$random.Next(0, $upper_case.Length)]
    $password += $numbers[$random.Next(0, $numbers.Length)]
    $password += $special_characters[$random.Next(0, $special_characters.Length)]

    for ($i = $password.Length; $i -lt $lenght; $i++) {
        $chars_set = $lower_case + $upper_case + $numbers + $special_characters
        $random_index = $random.Next(0, $chars_set.Length)
        $password += $chars_set[$random_index]
    }

    $secure_password = $password.ToCharArray() | Sort-Object {Get-Random}
    return -join $secure_password
}
