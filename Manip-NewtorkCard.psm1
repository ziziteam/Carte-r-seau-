function Stop-Card{
[CmdLetBinding()]
Param (
[string]$IndexCard
)

Get-NetAdapter -InterfaceIndex $IndexCard | Disable-NetAdapter -Confirm:$false
}




function List-Name-NetworkCard{

Get-NetAdapter  | fl Name, InterfaceIndex, MediaConnectionState, MacAddress
}

function Start-Card{
[CmdLetBinding()]
Param (
[string]$IndexCard
)

Get-NetAdapter -InterfaceIndex $IndexCard | Enable-NetAdapter -Confirm:$false
}

function Set-Ip-Config{
[CmdLetBinding()]
Param (
[Parameter(Mandatory=$true)][string]$Ip,
[Parameter(Mandatory=$true)][ValidateRange(2,30)][Byte]$Prefix,
[Parameter(Mandatory=$true)][string]$Gateway,
[Parameter(Mandatory=$true)][int]$Index

)

New-NetIPAddress –InterfaceIndex $Index –IPAddress $Ip –PrefixLength $Prefix –DefaultGateway $Gateway

}



