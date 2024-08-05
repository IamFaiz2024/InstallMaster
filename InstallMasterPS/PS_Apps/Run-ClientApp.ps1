<#	
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2017 v5.4.140
	 Created on:   	04-Jul-19 7:29 AM
	 Created by:   	W10User
	 Organization: 	
	 Filename:     	
	===========================================================================
	.DESCRIPTION
		A description of the file.
#>
$WshObject = New-Object -ComObject WScript.Shell #VbScript MessageBox Object
[void][System.Reflection.Assembly]::LoadWithPartialName('Microsoft.VisualBasic') #input box assembly

$LFServer = [ordered]@{ Name = '155.180.254.13'; SharePath = '\\155.180.254.13\Soft'; User = 'weblogin'; Password = '123456' }
$LFAppStruct = @{ Drivers = 'Drivers'; Apps = 'PS_Apps'; Utility = 'Utility'; Wim = 'WIM' }

#region Sync-Folder
<#
	.SYNOPSIS
		Sync Folder
	
	.DESCRIPTION
		Sync Folder
	
	.PARAMETER SourceFolder
		A description of the SourceFolder parameter.
	
	.PARAMETER TargetFolder
		A description of the TargetFolder parameter.
	
	.EXAMPLE
		PS C:\> Sync-Folder
	
	.NOTES
		Additional information about the function.
#>
function Sync-Folder
{
	[CmdletBinding()]
	[OutputType([bool])]
	param
	(
		[string]$SourceFolder,
		[string]$TargetFolder,
		[switch]$Backup,
		[switch]$File
	)
	try
	{
		$CommonArgs = "/S /XA:ST /XJ /XJD /XJF /R:0 /W:0 /V /ETA /TEE"
		
		$SyncRobocopyArgs = "$SourceFolder $TargetFolder $CommonArgs /xf *Temp*.* "
		
		$BackupRobocopyArgs = "$SourceFolder $TargetFolder $CommonArgs /LOG:$(Join-Path $TargetFolder -ChildPath 'LogFile.txt') /JOB:$(Join-Path $PSScriptRoot -ChildPath 'JOBFILE.RCJ') "
		
		Write-Host "Start Copying From $SourceFolder $TargetFolder"
		
		if ($Backup) { Start-Process -FilePath Robocopy -ArgumentList $BackupRobocopyArgs -Verbose -Wait }
		elseif ($File) { Copy-Item -Path $SourceFolder -Destination $TargetFolder -Recurse -Force -Verbose -PassThru }
		else { Start-Process -FilePath Robocopy -ArgumentList $SyncRobocopyArgs -Verbose -Wait }
		
		Write-Host "Copying Done"
	}
	catch
	{
		Write-Error -Message "Unable to Update files from Server" -ErrorAction SilentlyContinue
	}
	
}

#endregion Sync-Folder

#region Test-NetworkHost
<#
	.SYNOPSIS
		Test if Network host is reachable
	
	.DESCRIPTION
		Test if Network Host is reachable
	
	.PARAMETER HostName
		Host Name of the remote computer
	
	.EXAMPLE
				PS C:\> Test-NetworkHost HostName
	
	.NOTES
		Additional information about the function.
#>
function Test-NetworkHost
{
	[CmdletBinding()]
	[OutputType([bool])]
	param ([string]$HostName)
	[bool]$FlagNetworkHost = $false
	do
	{
		try
		{
			Test-Connection -ComputerName $HostName -Count 3 -ErrorAction Stop | Out-Null
			$FlagNetworkHost = $true
			break
		}
		catch #[System.Net.NetworkInformation.PingException] exception only for failed Ping
		{
			$FlagNetworkHost = $false
			$NwErrorMessageBoxReply = $WshObject.Popup("Unable to Connect $HostName `n $($_.Exception.Message)", 0, "Network Error", 5)
		}
	}
	Until ($FlagNetworkHost -eq $true -or $NwErrorMessageBoxReply -eq 2)
	return $FlagNetworkHost
}

#endregion Test-NetworkHost	

#region Get-AvaliableDriveLette
<#
	.SYNOPSIS
		Gets a drive letter avaliable
	
	.DESCRIPTION
		Gets a Drive letter which is not yet assinged. Example A:, R: etc...
	
	.EXAMPLE
		PS C:\> Get-AvaliableDriveLetter
	
	.NOTES
		Additional information about the function.
#>
function Get-AvaliableDrive
{
	[CmdletBinding()]
	[OutputType([hashtable])]
	param ()
	
	BEGIN
	{
		Write-Host "Getting Avaliable Drive Letter"
		$drvlist = (Get-PSDrive -PSProvider filesystem).Name
		$Drive = [ordered]@{ 'drivechar' = $null; 'drive' = $null }
	}
	PROCESS
	{
		try
		{
			Foreach ($drvletter in "ABCDEFGHIJKLMNOPQRSTUVWXYZ".ToCharArray())
			{ If ($drvlist -notcontains $drvletter) { Write-Debug "Found $drvletter unassinged"; break } } #found avaliable drive letter. If no break Z comes first			
		}
		catch { Write-Error "Serious Error in $($MyInvocation.MyCommand.Name). `n $($_.Exception.Message) `n Exiting Now" }
	}
	END
	{
		Write-Debug "Found $drvletter unassinged"
		$Drive.drivechar = $drvletter
		$Drive.drive = "$($drvletter):"
		return $Drive
	}
}
#endregion Get-AvaliableDriveLetter

#region Updating USB Installlation Drive
if (Test-NetworkHost -HostName $LFServer.Name)
{
	try
	{
		#$UpdateMessageBoxReply = $WshObject.Popup("Found $($LFServer.Name) Online. Do you wish to update `n App from Server before running?", 20, "Scanner Installation", 4 + 32)
		#if ($UpdateMessageBoxReply -eq 6)
		#{
		$NetworkDriveObj = New-SmbMapping -LocalPath (Get-AvaliableDrive).drive -RemotePath $LFServer.SharePath -UserName $LFServer.User -Password $LFServer.Password
		
		#region Cloning $LFServer Hashtable to update for Nw and Usb
		$UsbLFAppStruct = $LFAppStruct.Clone()
		$NwLFAppStruct = $LFAppStruct.Clone()
		#endregion Cloning $LFServer Hashtable to update for Nw and Usb			
		
		#region Updating $NwLFAppStruct for Network Path
		foreach ($key in ($NwLFAppStruct.Clone()).keys) { $NwLFAppStruct[$key] = $(Join-Path $NetworkDriveObj.LocalPath -ChildPath "LF_Offline_Apps\$($NwLFAppStruct[$key])") }
		Write-Host "Updated NwLFAppStruct Path"
		#$NwLFAppStruct
		#endregion Updating $NwLFAppStruct for Network Path
		
		
		#region Updating $UsbLFAppStruct for Network Path
		foreach ($key in ($UsbLFAppStruct.Clone()).keys) { $UsbLFAppStruct[$key] = $(Join-Path $(Split-Path -Path $PSScriptRoot -Qualifier) -ChildPath $UsbLFAppStruct[$key]) }
		Write-Host "Updated UsbLFAppStruct Path"
		#$UsbLFAppStruct
		#endregion Updating $UsbLFAppStruct for Network Path
		
		
		Sync-Folder -SourceFolder $NwLFAppStruct.Apps -TargetFolder $UsbLFAppStruct.Apps
		
		foreach ($Folder in $(Get-ChildItem -Directory -Path $NwLFAppStruct.Wim))
		{
			Sync-Folder -SourceFolder $("$($NwLFAppStruct.Wim)\$Folder") -TargetFolder $("$($UsbLFAppStruct.Wim)\$Folder")
		}
		#Sync-Folder -File -SourceFolder $(Join-Path $NwLFAppStruct.Wim -ChildPath 'SWSetup') -TargetFolder $(Join-Path $UsbLFAppStruct.Wim -ChildPath 'SWSetup')
		
		Remove-SmbMapping -LocalPath $NetworkDriveObj.LocalPath -Force
		#}		
	}
	catch { $_ }
}

#endregion Updating USB Installlation Drive

$TaskPerformed = @()

do
{
	$Selection = Get-ChildItem -Path $PSScriptRoot -File -Filter *.ps1 |`
	Where-Object{ $_ -notmatch "Client" -and $_.BaseName -notin $TaskPerformed } |`
	Select-Object -Property @{ Label = 'Application_Name'; Expression = { $_.BaseName } } |`
	Out-GridView -OutputMode Single -Title "Select Application You Wish To Run"
	
	#Get-Variable * -Exclude Selection, SelectedFile | Remove-Variable -ErrorAction SilentlyContinue #removing variables
		
	$TaskPerformed += $Selection.Application_Name
			
	if ($Selection)
	{
		$SelectedFile = Join-Path $PSScriptRoot -ChildPath "$($Selection.Application_Name).ps1"
		Start-Process -FilePath "Powershell.exe" -ArgumentList $SelectedFile -Wait		
	}
	
}
While ($Selection)
Exit