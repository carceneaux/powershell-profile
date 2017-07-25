function Get-PSP {
    <#  .Description
        	Retrieves the Path Selection Policy for all ESX hosts within vCenter.
			
		.NOTES   
		    Name: Get-PSP
		    Author: Chris Arceneaux
		    DateUpdated: 2/18/2015
		    Version: 1
		
        .Example
	        Get-PSP
		
		Description 
		-----------
		Gets the Path Selection policy of all SCSI LUNs on all ESX hosts
		
        .Example
	        Get-PSP -WithDatastoreName:$true
			Get-PSP -WithDatastoreName $true
		
		Description 
		-----------
	 	Gets the Path Selection policy of all SCSI LUNs on all ESX hosts and tie the LUN CanonicalName to it's Datastore Name
    #>

    param (
        [Parameter(Mandatory=$false)]
            [String]$WithDatastoreName = $false
    ) ## end param
 
 
    Process {
        # Gets a list of all ESX hosts in vCenter
		$AllESXHosts = Get-VMHost | Where { ($_.ConnectionState -eq "Connected") -or ($_.ConnectionState -eq "Maintenance")} | Sort Name
		foreach ($esxhost in $AllESXHosts) {
			# Finds datastore name associated with LUN CanonicalName
			New-VIProperty -Name lunDatastoreName -ObjectType ScsiLun -Value {
			    param($lun)			 
			    $ds = $lun.VMHost.ExtensionData.Datastore | %{Get-View $_} | `
			        Where-Object {$_.Summary.Type -eq "VMFS" -and
			            ($_.Info.Vmfs.Extent | Where-Object {$_.DiskName -eq $lun.CanonicalName})}
			    if($ds){
			        $ds.Name
			    }
			} -Force | Out-Null
			# Gets LUN CanonicalName with Path Selection Policy tied to it
			if ($WithDatastoreName -eq $true) {
		    	Get-VMhost $esxhost | Get-ScsiLun -LunType disk | Select-Object @{Name="ESX Host";Expression={$esxhost.Name}},CanonicalName,MultipathPolicy,lunDatastoreName | Format-Table
			}
			else {Get-VMhost $esxhost | Get-ScsiLun -LunType disk | Select-Object @{Name="ESX Host";Expression={$esxhost.Name}},CanonicalName,MultipathPolicy | Format-Table}
		}
    } ## end process
} ## end function