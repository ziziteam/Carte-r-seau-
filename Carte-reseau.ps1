Clear-Host
Write-Host "Par défaut, la GPO Serveur sera appliquée tous les dimanches de la quatrième semaine du mois à l'heure choisie" -ForegroundColor Green

Read-Host "Appuyez sur Entrée pour continuer..." 
Clear-Host
 $DomainName = (Get-ADDomain).DistinguishedName

 $ou_serveur = Get-ADOrganizationalUnit -Filter * | Select-Object Name, DistinguishedName
 $ServerTargetGroup = ($ou_serveur | Out-GridView -Title "Choisir OU Serveurs CTRL+CLIC POUR CHOISIR PLUSIEURS OU" -OutputMode Multiple).DistinguishedName

 $ou_postes = Get-ADOrganizationalUnit -Filter * | Select-Object Name, DistinguishedName
 $CompTargetGroup = ($ou_postes | Out-GridView -Title "Choisir OU Postes client CTRL+CLIC POUR CHOISIR PLUSIEURS OU" -OutputMode Multiple).DistinguishedName

# GPO Paramètre Communs
$nomGPO = "WSUS - Paramètre Communs"

$WSUSserv = Read-Host "Tapez l'adresse du serveur WSUS"

# Créer la nouvelle GPO
New-GPO -Name $nomGPO

# Obtenir le chemin de l'unité d'organisation (OU) dans Active Directory où vous souhaitez lier la GPO
# Remplacez "OU=MonOU,DC=MonDomaine,DC=com" par le chemin correct de votre OU
$ouPath = @($ServerTargetGroup) + @($CompTargetGroup)

# Lier la GPO à l'OU spécifiée
$gpo = Get-GPO -Name $nomGPO

foreach($gplink in $ouPath){
    New-GPLink -Name $gpo.DisplayName -Target $gplink -LinkEnabled Yes
}


# Configurer les paramètres de la GPO
Set-GPRegistryValue -Name $nomGPO -Key "HKLM\Software\Policies\Microsoft\Windows\WindowsUpdate" -ValueName 'WUServer' -Type String -Value $WSUSserv
Set-GPRegistryValue -Name $nomGPO -Key "HKLM\Software\Policies\Microsoft\Windows\WindowsUpdate" -ValueName 'WUStatusServer' -Type String -Value $WSUSserv
Set-GPRegistryValue -Name $nomGPO -Key "HKLM\Software\Policies\Microsoft\Windows\WindowsUpdate\AU" -ValueName 'UseWUServer' -Type DWord -Value 1
Set-GPRegistryValue -Name $nomGPO -Key "HKLM\Software\Policies\Microsoft\Windows\WindowsUpdate\AU" -ValueName 'IncludeRecommendedUpdates' -Type DWord -Value 1



$OUWsus = Read-Host "Tapez le nom de l'OU coté serveur WSUS"

Write-Host "Choisir l'option de Configuration de la mise à jour automatique " -ForegroundColor Green
Write-Host "2 = Notifier les téléchargements et les installations automatiques" -ForegroundColor Green
Write-Host "3 = Téléchargement automatique et notification des installations" -ForegroundColor Green
Write-Host "4 = Téléchargement automatique et planifications des installations" -ForegroundColor Green 
Write-Host "5 = Autoriser l'administrateur local à choisir les paramètres" -ForegroundColor Green 
Write-Host "7 = Téléchargement automatique, avertir de l'installation, avertir du redémarrage" -ForegroundColor Green
[int]$Param = Read-Host "Entrez votre choix" 

Write-Host "Choisir l'heure de redémarrage, taper une chiffre ( ex: 8 pour 8h du matin) :  " -ForegroundColor Green
[int]$Heure = Read-Host "Entrez votre choix"

# GPO WSUS Serveurs
$nomGPO1 = "WSUS - Serveurs"

# Créer la nouvelle GPO
New-GPO -Name $nomGPO1

# Lier la GPO à l'OU spécifiée
$gpo = Get-GPO -Name $nomGPO1

$ouPath = $ServerTargetGroup

foreach($gplink in $ServerTargetGroup){
    New-GPLink -Name $gpo.DisplayName -Target $gplink -LinkEnabled Yes
}

Set-GPRegistryValue -Name $nomGPO1 -Key "HKLM\Software\Policies\Microsoft\Windows\WindowsUpdate" -ValueName "TargetGroupEnabled" -Value 1 -Type DWord
Set-GPRegistryValue -Name $nomGPO1 -Key "HKLM\Software\Policies\Microsoft\Windows\WindowsUpdate" -ValueName "TargetGroup" -Value $OUWsus -Type String

# GPO Configuration du service de mise à jours automatique
Set-GPRegistryValue -Name $nomGPO1 -Key "HKLM\Software\Policies\Microsoft\Windows\WindowsUpdate\AU" -ValueName "NoAutoUpdate" -Type DWord -Value 0
Set-GPRegistryValue -Name $nomGPO1 -Key "HKLM\Software\Policies\Microsoft\Windows\WindowsUpdate\AU" -ValueName "AUOptions" -Type DWord -Value $Param
Set-GPRegistryValue -Name $nomGPO1 -Key "HKLM\Software\Policies\Microsoft\Windows\WindowsUpdate\AU" -ValueName "ScheduledInstallDay" -Type DWord -Value 1
Set-GPRegistryValue -Name $nomGPO1 -Key "HKLM\Software\Policies\Microsoft\Windows\WindowsUpdate\AU" -ValueName "ScheduledInstallTime" -Type DWord -Value $Heure
Set-GPRegistryValue -Name $nomGPO1 -Key "HKLM\Software\Policies\Microsoft\Windows\WindowsUpdate\AU" -ValueName "ScheduledInstallEveryWeek" -Type DWord -Value 0
Set-GPRegistryValue -Name $nomGPO1 -Key "HKLM\Software\Policies\Microsoft\Windows\WindowsUpdate\AU" -ValueName "ScheduledInstallFourthWeek" -Type DWord -Value 1


$OUWsus2 = Read-Host "Tapez le nom de l'OU coté poste client WSUS"

Write-Host "Choisir l'option de Configuration de la mise à jour automatique " -ForegroundColor Green
Write-Host "2 = Notifier les téléchargements et les installations automatiques" -ForegroundColor Green
Write-Host "3 = Téléchargement automatique et notification des installations" -ForegroundColor Green
Write-Host "4 = Téléchargement automatique et planifications des installations" -ForegroundColor Green 
Write-Host "5 = Autoriser l'administrateur local à choisir les paramètres" -ForegroundColor Green 
Write-Host "7 = Téléchargement automatique, avertir de l'installation, avertir du redémarrage" -ForegroundColor Green
[int]$Param2 = Read-Host "Entrez votre choix" 

Write-Host "Choisir l'heure de redémarrage, taper une chiffre ( ex: 8 pour 8h du matin) :  " -ForegroundColor Green
[int]$Heure2 = Read-Host "Entrez votre choix"

# GPO WSUS Poste client
$nomGPO2 = "WSUS - Poste"

# Créer la nouvelle GPO
New-GPO -Name $nomGPO2

# Lier la GPO à l'OU spécifiée
$gpo = Get-GPO -Name $nomGPO2

foreach($gplink in $CompTargetGroup){
    New-GPLink -Name $gpo.DisplayName -Target $gplink -LinkEnabled Yes
}

Set-GPRegistryValue -Name $nomGPO2 -Key "HKLM\Software\Policies\Microsoft\Windows\WindowsUpdate" -ValueName "TargetGroupEnabled" -Value 1 -Type DWord
Set-GPRegistryValue -Name $nomGPO2 -Key "HKLM\Software\Policies\Microsoft\Windows\WindowsUpdate" -ValueName "TargetGroup" -Value $OUWsus2 -Type String
 
# GPO Configuration du service de mise à jours automatique
Set-GPRegistryValue -Name $nomGPO2 -Key "HKLM\Software\Policies\Microsoft\Windows\WindowsUpdate\AU" -ValueName "NoAutoUpdate" -Type DWord -Value 0
Set-GPRegistryValue -Name $nomGPO2 -Key "HKLM\Software\Policies\Microsoft\Windows\WindowsUpdate\AU" -ValueName "AUOptions" -Type DWord -Value $Param2
Set-GPRegistryValue -Name $nomGPO2 -Key "HKLM\Software\Policies\Microsoft\Windows\WindowsUpdate\AU" -ValueName "ScheduledInstallDay" -Type DWord -Value 3
Set-GPRegistryValue -Name $nomGPO2 -Key "HKLM\Software\Policies\Microsoft\Windows\WindowsUpdate\AU" -ValueName "ScheduledInstallTime" -Type DWord -Value $Heure2
Set-GPRegistryValue -Name $nomGPO2 -Key "HKLM\Software\Policies\Microsoft\Windows\WindowsUpdate\AU" -ValueName "ScheduledInstallEveryWeek" -Type DWord -Value 1



