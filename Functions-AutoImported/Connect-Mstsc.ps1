function Connect-Mstsc {
<#   
.SYNOPSIS   
	Function to connect an RDP session without the password prompt
    
.DESCRIPTION 
	This function provides the functionality to start an RDP session without having to type in the password
	
.PARAMETER ComputerName
    This can be a single computername or an array of computers to which RDP session will be opened

.PARAMETER User
    The user name that will be used to authenticate

.PARAMETER Password
    The user name that will be used to authenticate
	
.PARAMETER Credentials
  	The credentials that will be used to authenticate

.NOTES   
    Name: Connect-Mstsc
    Author: Jaap Brasser
	LastUpdatedBy: Chris Arceneaux
    DateUpdated: 1-6-2015
    Version: 1.1a

.LINK
http://www.jaapbrasser.com

.EXAMPLE   
	. .\Connect-Mstsc.ps1
    
Description 
-----------     
This command dot sources the script to ensure the Connect-Mstsc function is available in your current PowerShell session

.EXAMPLE   
	Connect-Mstsc -ComputerName server01 -User contoso\jaapbrasser -Password supersecretpw

Description 
-----------     
A remote desktop session to server01 will be created using the credentials of contoso\jaapbrasser

.EXAMPLE   
	Connect-Mstsc server01,server02 contoso\jaapbrasser supersecretpw

Description 
-----------     
Two RDP session to server01 and server02 will be created using the credentials of contoso\jaapbrasser

.EXAMPLE
	Connect-Mstsc -ComputerName server01 -Credentials $credential_object
	
Description
-----------
A remote desktop session to server01 will be created using the credentials stored in the PowerShell credential object $credential_object

.EXAMPLE
	Connect-Mstsc -ComputerName server01 -CN server01 -U contoso\jaapbrasser -P supersecretpw
	
Description
-----------
Abbreviations are supported as well.

.EXAMPLE
	Connect-Mstsc -ComputerName server01 -CN server01 -CR $credential_object
	
Description
-----------
Abbreviations are supported as well.
#>
    param (
        [Parameter(Mandatory=$true,Position=0)]
        [Alias("CN")]
            [String[]]$ComputerName,
		[Parameter(Mandatory=$false)]
		[Alias("U")]
			[string]$User,
		[Parameter(Mandatory=$false)]
		[Alias("P")]
			[string]$Password,
        [Parameter(Mandatory=$false)]
        [Alias("CR")] 
            [System.Management.Automation.PSCredential]$Credentials,
        [Parameter(Mandatory=$false)]
        [Alias("A")]
            [switch]$Admin
    )
    begin {
		If ($Credentials -ne $null) {
			$User = $Credentials.GetNetworkCredential().username
			$Password = $Credentials.GetNetworkCredential().password
		}
        [string]$MstscArguments = ''
        switch ($true) {
            {$Admin} {$MstscArguments += '/admin'}
        }
    }
    process {
        foreach ($Computer in $ComputerName) {
			$ProcessInfo = New-Object System.Diagnostics.ProcessStartInfo
            $Process = New-Object System.Diagnostics.Process

            $ProcessInfo.FileName = "$($env:SystemRoot)\system32\cmdkey.exe"
            $ProcessInfo.Arguments = "/generic:TERMSRV/$Computer /user:$User /pass:$Password"
            $Process.StartInfo = $ProcessInfo
            $Process.Start()

            $ProcessInfo.FileName = "$($env:SystemRoot)\system32\mstsc.exe"
            $ProcessInfo.Arguments = "$MstscArguments /v $Computer"
            $Process.StartInfo = $ProcessInfo
            $Process.Start()
        }
    }
}