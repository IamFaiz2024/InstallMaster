Add-Type -AssemblyName PresentationFramework #GUI Framework

[void][System.Reflection.Assembly]::LoadWithPartialName('Microsoft.VisualBasic') #input box assembly

Import-Module -Name "$PSScriptRoot\InstallOS-Module.psm1" -Force #Importing Module

$TestLFNetwork = Test-NetworkHost -HostName "$($LFServer.Name)"

$TestLFBackupNetwork = Test-NetworkHost -HostName "$($LFBackupServer.Name)"

$MyCompInfoOffline = Get-ComputerInfo #Getting computer Information

$MyCompInfoOffline.Add('username', $([Microsoft.VisualBasic.Interaction]::InputBox('Enter Tawasul User Name', 'User Name Input', 'U'))) #GUI InputBox for User Name at the Begning.

[string]$now = "$(Get-Date -format "MMM-dd-yyyy.HH-mm")"

$DestLocationSuffix = "$($MyCompInfoOffline.compserialnumber)-$now"

#region Determine Souce Drive
$Sourcelocation = Show-Disks | Out-GridView -Title "Select Source Disk (Copy Data From)" -PassThru
if (!$($Sourcelocation)) { Write-Host "Location Not Set. Exiting Now"; Exit; }
#endregion Determine Souce Drive

#region If Backup Server Avaliable mount netowrk drive
if ($TestLFBackupNetwork)
{
	Write-Host "Found Backup Server Mapping Drive"
	$MyNWDrive = Mount-NwDrive -Path $LFBackupServer.SharePath -User $LFBackupServer.User -UserPassword $LFBackupServer.Password
	$MyNWDrive
}
#endregion If Backup Server Avaliable mount netowrk drive

#region Display Destination Drive Choice
$DestDrive = Get-WmiObject win32_logicaldisk | `
Select-Object -Property DeviceID, @{ n = "FreeSpace"; e = { [math]::Round($_.FreeSpace/1GB, 2) } }, VolumeName, DriveType |`
Where-Object { $_.VolumeName -like 'Backup*' -or $_.VolumeName -like 'IMGStorage' } |`
Out-GridView -Title "Select Destination Drive (Copy Data To)." -PassThru
#endregion Display Destination Drive Choice

#region Backup Destination Path Selected by user
Write-Debug "Selected Destination Drive is: $($DestDrive.DeviceID)"
try
{
	New-Item -ItemType Directory -Path $(Join-Path $DestDrive.DeviceID -ChildPath $DestLocationSuffix) -Verbose #Create New Folder with SrNo and DateTime	
	$BackupDestination = Join-Path $DestDrive.DeviceID -ChildPath $DestLocationSuffix #Complete Destination Path
	Write-Debug "Backup Will be done at $BackupDestination"
}
catch
{
	Write-Error "Unable to create Destination Backup Path. `n $($Error.Message) `n Backup Will Exit Now!"
	$WshObject.Popup("Unable to create Destination Backup Path. `n $($Error.Message) `n Backup Will Exit Now!", 0, "Network Error", 0 + 16)
	Exit
}
#endregion Backup Destination Path Selected by user

#region Initalaizing Backup List Table
$BackupList = New-Object System.Data.DataTable
$BackupList.Columns.AddRange(@("Path", "Size"))
#endregion Initalaizing Backup List Table 

#region Determine List of Partition for Backup (Only User and Backup Folder will be copied)
$PartitionList = Get-Partition -DiskNumber $Sourcelocation.Number | Where-Object { $_.DriveLetter -match '\w' } | Select-Object -ExpandProperty DriveLetter
$PartitionList = $PartitionList.ForEach({ $_ + ':' }) #List the Partition from Selected Source Drive
#endregion Determine List of Partition for Backup (Only User and Backup Folder will be copied)

#$ReplyGetDataSize = $WshObject.Popup("Do You Wish To Check Size Of Data Before You Start Copying?", 0, "Get Backup Size", 4 + 32) #Flag to find Data Size before backup
$ReplyGetDataSize = 0

#region Generating list of Partitoins Path to be transfered
#If Data Size is needed then $PartitionList otherwise $BackupList
$PartitionList.ForEach({
		if (Test-Path $(Join-Path $_ -ChildPath 'Users'))
		{
			#Add-Member -InputObject $BackupList -NotePropertyName $(Join-Path $_ -ChildPath 'Users') -NotePropertyValue "$($_)123"
			if ($ReplyGetDataSize -eq 6)
			{
				Write-Host "Calculating Size of Users Profile Folder"
				$UsersFolderSize = $(Get-FolderSize -FolderPath $(Join-Path $_ -ChildPath 'Users'))
				Write-Host "$(Join-Path $_ -ChildPath 'Users') Size is: $UsersFolderSize"
				[void]$BackupList.Rows.Add($(Join-Path $_ -ChildPath 'Users'), $UsersFolderSize)
			}
			else
			{ [void]$BackupList.Rows.Add($(Join-Path $_ -ChildPath 'Users'), "N/A") }
		}
		if (Test-Path $(Join-Path $_ -ChildPath 'Backup'))
		{
			if ($ReplyGetDataSize -eq 6)
			{
				Write-Host "Calculating Size of Backup Folder in Other Partition"
				$BackupFolderSize = $(Get-FolderSize -FolderPath $(Join-Path $_ -ChildPath 'Backup'))
				Write-Host "$(Join-Path $_ -ChildPath 'Users') Size is: $BackupFolderSize"
				[void]$BackupList.Rows.Add($(Join-Path $_ -ChildPath 'Backup'), $BackupFolderSize)
			}
			else { [void]$BackupList.Rows.Add($(Join-Path $_ -ChildPath 'Backup'), "N/A") }
		}
	})
#endregion Generating list of Partitoins Path to be transfered

#if ($ReplyGetDataSize -eq 6) { $CustomSelection = $BackupList | Out-GridView -Title "Select Items to Backup. ONLY SELECTED DATA WILL BE TRASNFERED!!!" -PassThru } #$Selection list with path and size
#$Backup list with path only

#region Actually Transfering Data from source partition/s to backup Destination
if ($ReplyGetDataSize -eq 6)
{
	$CustomSelection | ForEach-Object{
		if ($_.Path -match "Backup")
		{
			New-Item -ItemType Directory -Path $(Join-Path $BackupDestination -ChildPath 'Backup')
			Write-Host "Copying $($_.Path) to $(Join-Path $BackupDestination -ChildPath 'Backup')"
			#Add-Data -source $_.Path -dest $(Join-Path $BackupDestination -ChildPath 'Backup')
			Sync-Folder -SourceFolder $_.Path -TargetFolder $(Join-Path $BackupDestination -ChildPath 'Backup') -Backup
			Write-Host "Transfer of $($_.Path) Completed"
		}
		else
		{
			Write-Host "Copying $($_.Path) to $BackupDestination"
			#Add-Data -source $_.Path -dest $BackupDestination
			Sync-Folder -SourceFolder $_.Path -TargetFolder $BackupDestination -Backup
			Write-Host "Transfer of $($_.Path) Completed"
		}		
	}
}
else
{
	$BackupList | ForEach-Object{
		if ($_.Path -match "Backup")
		{
			New-Item -ItemType Directory -Path $(Join-Path $BackupDestination -ChildPath 'Backup')
			Write-Host "Copying $($_.Path) to $(Join-Path $BackupDestination -ChildPath 'Backup')"
			#Add-Data -source $_.Path -dest $(Join-Path $BackupDestination -ChildPath 'Backup')
			Sync-Folder -SourceFolder $_.Path -TargetFolder $(Join-Path $BackupDestination -ChildPath 'Backup') -Backup
			Write-Host "Transfer of $($_.Path) Completed"
		}
		else
		{
			Write-Host "Copying $($_.Path) to $BackupDestination"
			#Add-Data -source $_.Path -dest $BackupDestination
			Sync-Folder -SourceFolder $_.Path -TargetFolder $BackupDestination -Backup
			Write-Host "Transfer of $($_.Path) Completed"
		}
	}
}
#endregion Actually Transfering Data from source partition/s to backup Destination