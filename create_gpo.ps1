function create_gpo {
    mkdir C:\Ressources_partagees
    $file_path = "C:\script_automatisation\img\background.jpg"
    Copy-Item $file_path -Destination "C:\Ressources_partagees\background.jpg"
    $share_path = "C:\Ressources_partagees"
    $share_name = "Ressources partagées"
    $everyone_SID = New-Object System.Security.Principal.SecurityIdentifier("S-1-1-0")
    $share_cl = Get-Acl $share_path
    $share_cl.AddAccessRule((New-Object System.Security.AccessControl.FileSystemAccessRule($everyone_SID, "FullControl", "ContainerInherit,ObjectInherit", "None", "Allow")))
    Set-Acl $share_path $share_cl
    New-SmbShare -Name $share_name -Path $share_path


    $gpo = New-GPO -Name "Uniform lock background"
    $image_path = "\\Srvadds\Ressources partagées\background.jpg"
    Set-GPRegistryValue -Guid $GPO.Id -Key "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\PersonalizationCSP" -ValueName "LockScreenImagePath" -Type String -Value $image_path
    Set-GPRegistryValue -Guid $GPO.Id -Key "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\PersonalizationCSP" -ValueName "LockScreenImageStatus" -Type DWord -Value 1
    New-GPLink -Name "Uniform lock background" -Target "DC=$dc_1,DC=$dc_2" -LinkEnabled Yes


    $gpo = New-GPO -Name "Uniform background"
    Set-GPRegistryValue -Guid $GPO.Id -Key "HKCU\Control Panel\Desktop" -ValueName "Wallpaper" -Type String -Value $image_path
    New-GPLink -Name "Uniform background" -Target "DC=$dc_1,DC=$dc_2" -LinkEnabled Yes


    $gpo = New-GPO -Name "Block USB"
    Set-GPRegistryValue -Guid $GPO.Id -Key "HKLM\SOFTWARE\Policies\Microsoft\Windows\RemovableStorageDevices" -ValueName "Deny_All" -Type DWord -Value 1
    New-GPLink -Name "Block USB" -Target "DC=$dc_1,DC=$dc_2" -LinkEnabled Yes

    $gpo = New-GPO -Name "Block powershell script"
    Set-GPRegistryValue -Guid $GPO.Id -Key "HKLM\SOFTWARE\Policies\Microsoft\Windows\PowerShell" -ValueName "EnableScripts" -Type DWord -Value 0
    New-GPLink -Name "Block powershell script" -Target "DC=$dc_1,DC=$dc_2" -LinkEnabled Yes

    $gpo = New-GPO -Name "Disalow installation of software"
    Set-GPRegistryValue -Guid $GPO.Id -Key "HKLM\SOFTWARE\Policies\Microsoft\Windows\Installer" -ValueName "DisableMSI" -Type DWord -Value 1
    New-GPLink -Name "Disalow installation of software" -Target "DC=$dc_1,DC=$dc_2" -LinkEnabled Yes
}
