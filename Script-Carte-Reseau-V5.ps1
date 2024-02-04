Clear-Host

$continue = $true
while ($continue) {
  write-host -ForegroundColor Cyan  “---------------------- CONFIGURATION RESEAU -----------------------”
  write-host -ForegroundColor Cyan “1. Lister les cartes"
  write-host -ForegroundColor Cyan “2. Rennomer carte"
  write-host -ForegroundColor Cyan "3. Allumer carte reseau"
  write-host -ForegroundColor Cyan "4. Eteindre carte reseau"
  write-host -ForegroundColor Cyan "5. Redémmarer une carte reseau"
  write-host -ForegroundColor Cyan "6. Config static IP sur une carte"
  write-host -ForegroundColor Magenta "x. exit"
  write-host  "--------------------------------------------------------"
  $choix = read-host “faire un choix :”
  switch ($choix){
    1{List-Name-NetworkCard
    Get-NetIPConfiguration }

    2{ List-Name-NetworkCard 
    $ChoiCarte = Read-Host "Quelle carte rennomer? ##!Choisir l'index de la carte!## "
    $WhoCall = Read-Host "Comment la nommer ?"
    Get-NetAdapter -InterfaceIndex $ChoiCarte | Rename-NetAdapter -NewName $WhoCall}
    
    3{List-Name-NetworkCard 
    $ChoiCarte = Read-Host "INDEX de la carte à allumer ?"
    Start-Card $ChoiCarte}

    4{List-Name-NetworkCard 
    $ChoiCarte = Read-Host "INDEX de la carte à éteindre ?"
    Stop-Card $ChoiCarte}

    5{List-Name-NetworkCard
      $ChoiIndex = Read-Host "Choisir INDEX de carte à redémarrer"
     Get-NetAdapter -InterfaceIndex $ChoiIndex | Restart-NetAdapter} 
   
    6{List-Name-NetworkCard
     $ChoiIndex = Read-Host "Choisir INDEX de carte"
    Get-NetAdapter -InterfaceIndex $ChoiIndex | Get-NetIPAddress | Remove-NetIPAddress -Confirm:$false
    Set-DnsClientServerAddress -InterfaceIndex $ChoiIndex -ResetServerAddresses -Confirm:$false
    Remove-NetRoute -InterfaceIndex $ChoiIndex -ErrorAction SilentlyContinue -Confirm:$false
    Set-NetIPInterface -InterfaceIndex $ChoiIndex -Dhcp Enabled 

    Set-Ip-Config -Index $ChoiIndex
    $DNS = Read-Host "Ajouter un DNS à la carte ? Si oui écrire (Pour en mettre deux, séparer par une , les addresses) "
    Set-DnsClientServerAddress -InterfaceIndex $ChoiIndex -ServerAddresses $DNS }
    ‘x’ {$continue = $false}
    default {Write-Host "Choix invalide"-ForegroundColor Red}
  }
}

