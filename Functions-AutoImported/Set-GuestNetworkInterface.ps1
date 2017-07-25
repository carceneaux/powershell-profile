function Set-GuestNetworkInterface {
<#   
.SYNOPSIS   
	Configures guest network interface on a virtual machine.
    
.DESCRIPTION 
	This function provides the functionality to set the IP address and DNS server on the Guest OS of a virtual machine.

.PARAMETER VM
	Specifiies virtual machine name.

.PARAMETER Interface
	Specifies the network interface to modify.
	
.PARAMETER IPAddress
	Specifies the IP address for the network interface. 

.PARAMETER SubnetMask
	Specifies the CIDR for the network interface.

.PARAMETER DefaultGateway
	Specifies the default gateway for the network interface.

.PARAMETER DNSServer
	Specifies the primary DNS server for the network interface.

.PARAMETER GuestUser
	Specify the username to run the script inside the guest operating system.

.PARAMETER GuestPassword
	Specify the password to run the script inside the guest operating system.

.PARAMETER GuestCredential
	Specify the credentials to run the script inside the guest operating system.

.NOTES   
    Name: Set-GuestNetworkInterface
    Author: Chris Arceneaux
    DateUpdated: 1/12/2015
    Version: 1

.LINK

.EXAMPLE   
	Set-GuestNetworkInterface -VM server1 -GuestUser DOMAIN\admin -GuestPassword supersecretpw

Description 
-----------     
Checks the configuration of all network interfaces on virtual machine server1 and displays that output

.EXAMPLE   
	Set-GuestNetworkInterface -VM server1 -Interface Ethernet0 -IPAddress 10.0.0.5 -SubnetMask 24 -DefaultGateway 10.0.0.254 -DNSServer 10.0.0.1 -GuestUser DOMAIN\admin -GuestPassword supersecretpw

Description 
-----------     
Configures the network interface Ethernet0 on virtual machine server1 with the IP Address 10.0.0.5/24, Default Gateway 10.0.0.254 and DNS server 10.0.0.1

.EXAMPLE   
	Set-GuestNetworkInterface -VM server1 -Interface Ethernet0 -IPAddress 10.0.0.5 -SubnetMask 24 -DefaultGateway 10.0.0.254 -GuestUser DOMAIN\admin -GuestPassword supersecretpw

Description 
-----------     
Configures the network interface Ethernet0 on virtual machine server1 with the IP Address 10.0.0.5/24, Default Gateway 10.0.0.254

.EXAMPLE   
	Set-GuestNetworkInterface -VM server1 -Interface Ethernet0 -DNSServer 10.0.0.1 -GuestUser DOMAIN\admin -GuestPassword supersecretpw

Description 
-----------     
Configures the network interface Ethernet0 on virtual machine server1 with the DNS servers 10.0.0.1

.EXAMPLE   
	Set-GuestNetworkInterface -VM server1 -Interface Ethernet0 -DNSServer 10.0.0.1 -GuestCredential $Credentials

Description 
-----------     
A PowerShell Credential object may be used instead of typical Username/Password

.EXAMPLE   
	Set-GuestNetworkInterface -VM server1 -INT Ethernet0 -IP 10.0.0.5 -SM 24 -DG 10.0.0.254 -DNS 10.0.0.1 -U DOMAIN\admin -P supersecretpw -CR $Credentials

Description 
-----------     
Aliases are also supported.
#>

# Specifies  parameters required for the powershell session.
	param (
        [Parameter(Mandatory=$true)]
			[String[]]$VM,
		[Parameter(Mandatory=$false)]
		[Alias("INT")]
			[String]$Interface,
        [Parameter(Mandatory=$false)]
        [Alias("IP")] 
            [String]$IPAddress,
        [Parameter(Mandatory=$false)]
        [Alias("SM")] 
            [String]$SubnetMask,
		[Parameter(Mandatory=$false)]
        [Alias("DG")] 
            [String]$DefaultGateway,
		[Parameter(Mandatory=$false)]
        [Alias("DNS")] 
            [String]$DNSServer,
		[Parameter(Mandatory=$false)]
        [Alias("U")] 
            [String]$GuestUser,
		[Parameter(Mandatory=$false)]
        [Alias("P")] 
            [String]$GuestPassword,
		[Parameter(Mandatory=$false)]
        [Alias("CR")] 
            [System.Management.Automation.PSCredential]$GuestCredential
    )

	# Conditional logic to determine if Username/Password or Credentials were used.
	If ($GuestCredential -ne $null) {
		$GuestUser = $GuestCredential.GetNetworkCredential().username
		$GuestPassword = $GuestCredential.GetNetworkCredential().password
	}

	# Conditional logic to determine if IP addresses or DNS server addresses are being modified or BOTH.
	If (!$Interface)	{
		"" + (Get-Date).toString('dd/MM/yyyy HH:mm:ss') + ": INFORMATION: Checking IPv4 address and DNS server settings for " + $VM + "."
		$ScriptText = "c:\windows\system32\netsh.exe interface ipv4 show address & c:\windows\system32\netsh.exe interface ipv4 show dnsservers"
		Invoke-VMScript -VM $VM -ScriptText $ScriptText -GuestUser $GuestUser -GuestPassword $GuestPassword -ScriptType Bat
	}
	ElseIf (!$DNSServer) { 
		"" + (Get-Date).toString('dd/MM/yyyy HH:mm:ss') + ": INFORMATION: Modifying IPv4 address settings for " + $Interface + "."
		$ScriptText = "c:\windows\system32\netsh.exe interface ip set address ""$Interface"" static $IPAddress $SubnetMask $DefaultGateway 1"
		Invoke-VMScript -VM $VM -ScriptText $ScriptText -GuestUser $GuestUser -GuestPassword $GuestPassword -ScriptType Bat | Out-Null
	} 
	ElseIf (!$IPAddress) { 
		"" + (Get-Date).toString('dd/MM/yyyy HH:mm:ss') + ": INFORMATION: Modifying DNS server addresses for " + $Interface + "."
		$ScriptText = "c:\windows\system32\netsh.exe interface ipv4 set DNSServer ""$Interface"" static $DNSServer primary"
		Invoke-VMScript -VM $VM -ScriptText $ScriptText -GuestUser $GuestUser -GuestPassword $GuestPassword -ScriptType Bat | Out-Null
	} 
	Else { 
		"" + (Get-Date).toString('dd/MM/yyyy HH:mm:ss') + ": INFORMATION: Modifying IPv4 address settings and DNS server addresses for " + $Interface + "."
		$ScriptText = "c:\windows\system32\netsh.exe interface ip set address ""$Interface"" static $IPAddress $SubnetMask $DefaultGateway 1 & c:\windows\system32\netsh.exe interface ipv4 set DNSServer ""$Interface"" static $DNSServer primary"
		Invoke-VMScript -VM $VM -ScriptText $ScriptText -GuestUser $GuestUser -GuestPassword $GuestPassword -ScriptType Bat | Out-Null
	}
}