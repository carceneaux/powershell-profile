function Get-vPCRepoInfo {
<#   
.SYNOPSIS   
	Generates a short storage report of a Veeam Repository
    
.DESCRIPTION 
	This function provides the functionality to extrapolate basic storage information about a Veeam Repository.

.PARAMETER (ValueFromPipeline)
	This value is taken from pipeline input.

.NOTES   
    Name: Get-vPCRepoInfo
    Author: Thomas McConnell
    DateUpdated: 1/27/2015
    Version: 1.1

.LINK
	http://forums.veeam.com/powershell-f26/repository-size-t10674.html

.EXAMPLE   
	Get-VBRBackupRepository -Name "My Repo" | Get-vPCRepoInfo

Description 
-----------     
Displays storage information for the Veeam Repository "My Repo".
#>

[CmdletBinding()]
   param (
      [Parameter(Position=0, ValueFromPipeline=$true)]
      [PSObject[]]$Repository
      )
   Begin {
      $outputAry = @()
      [Reflection.Assembly]::LoadFile("C:\Program Files\Veeam\Backup and Replication\Veeam.Backup.Common.dll") | Out-Null
      function Build-Object {param($name, $path, $free, $total)
         $repoObj = New-Object -TypeName PSObject -Property @{
               Target = $name
               storepath = $path
               StorageFree = [Math]::Round([Decimal]$free/1GB,2)
               StorageTotal = [Math]::Round([Decimal]$total/1GB,2)
               FreePercentage = [Math]::Round(($free/$total)*100)
            }
         return $repoObj
      }
   }
   Process {
      foreach ($r in $Repository) {
         if ($r.GetType().Name -eq [String]) {
            $r = Get-VBRBackupRepository -Name $r
         }
         if ($r.Type -eq "WinLocal") {
            $Server = $r.GetHost()
            $FileCommander = [Veeam.Backup.Core.CRemoteWinFileCommander]::Create($Server.Info)
            $storage = $FileCommander.GetDrives([ref]$null) | ?{$_.Name -eq $r.Path.Substring(0,3)}
            $outputObj = Build-Object $r.Name $r.Path $storage.FreeSpace $storage.TotalSpace
         }
         elseif ($r.Type -eq "LinuxLocal") {
            $Server = $r.GetHost()
            $FileCommander = new-object Veeam.Backup.Core.CSshFileCommander $server.info
            $storage = $FileCommander.FindDirInfo($r.Path)
            $outputObj = Build-Object $r.Name $r.Path $storage.FreeSpace $storage.TotalSize
         }
         elseif ($r.Type -eq "CifsShare") {
            $fso = New-Object -Com Scripting.FileSystemObject
            $storage = $fso.GetDrive($r.Path)
            $outputObj = Build-Object $r.Name $r.Path $storage.AvailableSpace $storage.TotalSize
         }
         $outputAry = $outputAry + $outputObj
      }
   }
   End {
      $outputAry
   }
}