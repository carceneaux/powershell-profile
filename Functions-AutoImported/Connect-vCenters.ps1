function Connect-vCenters {
<#   
.SYNOPSIS   
	Function to connect to multiple vCenters at once
    
.DESCRIPTION 
	Connect to multiple vCenters at once on a per environment basis
	
.PARAMETER Environment
    This will specify the vSphere environment you want to connect to

.PARAMETER Credential
  	The credentials that will be used to authenticate

.NOTES   
    Name: Connect-vCenters
    Author: Chris Arceneaux

.EXAMPLE   
	Connect-vCenters -Environment lab -Credential (Get-Credential)
    
Description 
-----------     
Connect to the specified lab environment and poll me for the username/password to be used

.EXAMPLE   
	Connect-vCenters -Environment lab -Credential $cred
    
Description 
-----------     
Connect to the specified lab environment using the specified credentials

#>
    param (
        [Parameter(Mandatory=$true,Position=0)]
        [String[]]$Environment,
		[Parameter(Mandatory=$true,Position=1)]
		[System.Management.Automation.PSCredential]$Credential		
    )
    begin {
		switch ($Environment) {
            "lab" {
                $vCenters = "vcenter01.lab.local","vcenter02.lab.local"
                break
            }
            "prod" {
                $vCenters = "vcenter01.prod.local","vcenter02.prod.local"
                break
            }
            Default {
                Write-Output "No matching environments specified. Please use one of the following environments:"
                Write-Output "- lab"
                Write-Output "- prod"
                Exit
            }
        }
    }
    process {
        Connect-VIServer $vCenters -Credential $Credential
    }
}