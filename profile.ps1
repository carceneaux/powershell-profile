### Global Variables ###
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Definition	#Directory where the script is located
$functionDir = "$scriptPath\Functions-AutoImported\"

### Credentials are Processed ###
# To function properly encrypted password must be decrypted on same pc by same user who encrypted it
$user = "dummyuser@lab.local"
$encrypted = Get-Content "$scriptPath\lab.local.txt"
$password = ConvertTo-SecureString -String $encrypted
$cred_lab = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $user,$password

$user = "dummyuser@prod.local"
$encrypted = Get-Content "$scriptPath\prod.local.txt"
$password = ConvertTo-SecureString -String $encrypted
$cred_prod = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $user,$password

### Custom Functions Imported ###
$functionList = (ls $functionDir).Name
foreach ($function in $functionList) {
    Import-Module ($functionDir + $function)
}

### Set Starting Location ###
Set-Location "C:\"

### Customize the console display ###
$UI = (Get-Host).UI.RawUI
#$UI.BackgroundColor = "blue"
#$UI.ForegroundColor = "white"