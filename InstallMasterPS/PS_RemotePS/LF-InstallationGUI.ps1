#Start-Transcript -Force

Add-Type -AssemblyName PresentationFramework #GUI Framework

[void][System.Reflection.Assembly]::LoadWithPartialName('Microsoft.VisualBasic') #input box assembly

Import-Module -Name "$PSScriptRoot\InstallOS-Module.psm1" -Force #Importing Module

$LFSQLConnection = New-Object System.Data.SqlClient.SqlConnection #SQL Object

$LFSQLConnection.ConnectionString = "Server=$($LFServer.Name)\COMMSQLSVR;Database=Maintenance;Integrated Security = false;User ID=$($LFServer.User);Password=$($LFServer.Password)" #SQL Server Parameters

$TestLFNetwork = Test-NetworkHost -HostName "$($LFServer.Name)"

[bool]$BackupDone = $false

#region Getting and Setting WIM & WimImage and Drivers & DriverSelection
#$WimPath = Join-Path $((Get-Item $PSSCriptRoot).PSDrive.Name + ":\") -ChildPath "WIM" #By default going to root WIM folder
$WimPath = Join-Path $(Split-Path -Path $PSScriptRoot -Qualifier) -ChildPath "WIM" #Getting WIM Root Folder
$ImgSelection = Select-WindowsImage -SearchPath $WimPath #Image Selection

#$AllDrvPath = Join-Path $((Get-Item $PSSCriptRoot).PSDrive.Name + ":\") "Drivers"
$AllDrvPath = Join-Path $(Split-Path -Path $PSScriptRoot -Qualifier) -ChildPath "Drivers" #Getting Driver Root Folder
$DriverSelection = Get-DriverPath -DriverCollectionRoot $AllDrvPath #Driver Selection
#endregion Getting and Setting WIM & WimImage and Drivers & DriverSelection


$WinNTSetup = Join-Path $(Split-Path -Path $PSScriptRoot -Qualifier) -ChildPath "Utility\WinNTSetup4\WinNTSetup_x64.exe" #Setting WiNTSetup_x64.exe path
Write-Debug $WinNTSetup

$DiskSelection = Show-Disks #Getting Physical Disks attached

$MyCompInfoOffline = Get-ComputerInfo #Getting computer Information

$MyCompInfoOffline.Add('username', $([Microsoft.VisualBasic.Interaction]::InputBox('Enter Tawasul User Name', 'User Name Input', 'U'))) #GUI InputBox for User Name at the Begning.

#region If LFServer Avaliable get distinct domain name from server 
if ($TestLFNetwork)
{
	Write-Debug "LF Server Found."
	Write-Debug -Message "Connecting Sql Server to get Distinct Network Type List"
	
	$Query = "SELECT DISTINCT [NetworkType],[DomainName] FROM [SysNameDeviceTbl]"
	$NetworkSelection = Get-SqlData -SqlConnection $LFSQLConnection -SqlQuery $Query |`
	Where-Object { $_.NetworkType -notlike $null } | Select-Object NetworkType, DomainName	
}
#endregion If LFServer Avaliable get distinct domain name from server 

#region LF-InstallationGUI Declare and Initialization
$LFInstallationGuiPath = "$PSScriptRoot\LF-InstallationGUI.xaml"

$LFInstallationGuiCnt = Get-Content $LFInstallationGuiPath -Raw
$LFInstallationGuiCnt = $LFInstallationGuiCnt -replace 'mc:Ignorable="d"', '' -replace "x:N", 'N' -replace '^<Win.*', '<Window'
[XML]$LFInstallationGuiXML = $LFInstallationGuiCnt

$reader = (New-Object System.Xml.XmlNodeReader $LFInstallationGuiXML)
try
{
	$LFInstallationGuiWindow = [Windows.Markup.XamlReader]::Load($reader)
}
catch
{
	Write-Warning $_.Exception
	throw
}

$LFInstallationGuiXML.SelectNodes("//*[@Name]") | ForEach-Object {
	#"trying item $($_.Name)"
	try
	{
		Set-Variable -Name "var_$($_.Name)" -Value $LFInstallationGuiWindow.FindName($_.Name) -ErrorAction Stop
	}
	catch
	{
		throw
	}
}

Get-Variable var_*

#Start-Job -Name 'LogWindow' { $Null = $LFInstallationGuiWindow.ShowDialog() }
#endregion LF-InstallationGUI Declare and Initialization

#region ManualGUI Declare and Initialization
$ManualGUIGuiPath = "$PSScriptRoot\ManualGUI.xaml"

$ManualGuiCnt = Get-Content $ManualGUIGuiPath -Raw
$ManualGuiCnt = $ManualGuiCnt -replace 'mc:Ignorable="d"', '' -replace "x:N", 'N' -replace '^<Win.*', '<Window'
[XML]$ManualGuiXML = $ManualGuiCnt

$Mreader = (New-Object System.Xml.XmlNodeReader $ManualGuiXML)
try
{
	$ManualGuiWindow = [Windows.Markup.XamlReader]::Load($Mreader)
}
catch
{
	Write-Warning $_.Exception
	throw
}

$ManualGuiXML.SelectNodes("//*[@Name]") | ForEach-Object {
	#"trying item $($_.Name)"
	try
	{
		Set-Variable -Name "var_$($_.Name)" -Value $ManualGuiWindow.FindName($_.Name) -ErrorAction Stop
	}
	catch
	{
		throw
	}
}

Get-Variable var_M*
#endregion ManualGUI Declare and Initialization

#region If LFServer Not Avaliable enable OfflineInstall $true and Load ManualFrm Enter NetworkType and System Number Manually
if (!$TestLFNetwork)
{
	$ManulEntryMessageBoxReply = $WshObject.Popup("$($LFServer.Name) Not Found. Do you wish to `n Enter Details Manually?", 120, "Enter Details Manually", 4 + 32)
	if ($ManulEntryMessageBoxReply -eq 6)
	{
		#region Manual Form Load Srno, Model and MAC get values auto from MyComputerInfo
		$var_ManualFrm.Add_Loaded({
				if ($MyCompInfoOffline.compserialnumber) { $var_MSrNo_txt.Text = $MyCompInfoOffline.compserialnumber; $var_MSrNo_txt.IsEnabled = $false }
				else { $var_MSrNo_txt.IsEnabled = $true }
				if ($MyCompInfoOffline.compmacaddress) { $var_MMac_txt.Text = $MyCompInfoOffline.compmacaddress; $var_MMac_txt.IsEnabled = $false }
				else { $var_MMac_txt.IsEnabled = $true }
				if ($MyCompInfoOffline.compmodelnumber) { $var_MModel_txt.Text = $MyCompInfoOffline.compmodelnumber; $var_MModel_txt.IsEnabled = $false }
				else { $var_MModel_txt.IsEnabled = $true }
			})
		#endregion Manual Form Load Srno, Model and MAC get values auto from MyComputerInfo
		
		#region MCN_txt Accept only Numbers RND
		<#$var_MCN_txt.Add_TextChanged({
				$this.Text = $this.Text -replace '\D'
			})#>
		#endregion MCN_txt Accept only Numbers
				
		#region MSave_btn Click Save all values to MyComputerInfo
		$var_MSave_btn.Add_Click({
				Write-Debug "Saving Offline Values"
				if (!$MyCompInfoOffline.compserialnumber) { $MyCompInfoOffline.compserialnumber = $var_MSrNo_txt.Text }
				if (!$MyCompInfoOffline.compmacaddress) { $MyCompInfoOffline.compmacaddress = $var_MMac_txt.Text }
				if (!$MyCompInfoOffline.compmodelnumber) { $MyCompInfoOffline.compmodelnumber = $var_MModel_txt.Text }
				if ($var_MCN_txt.Text) { $MyCompInfoOffline.SystemName = $var_MCN_txt.Text; $MyCompInfoOffline.computername = $var_MCN_txt.Text}
				if ($var_MDomain_txt.Text) { $MyCompInfoOffline.Add('DomainName', $var_MDomain_txt.Text); $MyCompInfoOffline.NetworkType = $var_MDomain_txt.Text } #SystemName = $var_MCN_txt.Text }											
				$ManualGuiWindow.Close()
			})
		#endregion MSave_btn Click Save all values to MyComputerInfo
		
		$ManualGuiWindow.ShowDialog()
	}	
}
#endregion If LFServer Not Avaliable enable OfflineInstall $true and Load ManualFrm Enter NetworkType and System Number Manually

#region MainFrm_OnLoad
$var_MainFrm.Add_Loaded({
		$var_User_lbl.Content = $MyCompInfoOffline.username #Setting Form Title as UserName
		#$var_CN_txt.Visibility = "Hidden" #CN_txt is hidden
		$DiskSelection | Select-Object Number, FriendlyName, Size | ForEach-Object { $var_Disk_cmb.Items.Add($_) } #Populating Disk_cmb with disks
		$PartitionSchemeTable | Select-Object SchemeName, Supported_Model | ForEach-Object { $var_Partition_cmb.Items.Add($_) } #Populating Partition_cmb with defined partition scheme
		$ImgSelection | Select-Object ImageName, Architecture, ImageFileSizeGB, XMLFilePath | ForEach-Object { $var_WinImage_cmb.Items.Add($_) } #Populating WinImage_cmb with avaliable images		
		$DriverSelection | ForEach-Object{ $var_DriverPath_cmb.Items.Add($_) } #Populating DriverPath_cmb with filtered drivers		
		if ($TestLFNetwork) { $NetworkSelection | ForEach-Object{ $var_Domain_cmb.Items.Add($_) } } #if No Network Domain_cmb is Disabled
		else { $var_Domain_cmb.IsEnabled = $false; $var_CN_txt.Text = $MyCompInfoOffline.SystemName } #No Network Found
	})
#endregion MainFrm_OnLoad

#region Disk_cmb Selection Changed to get Disk Number
$var_Disk_cmb.Add_SelectionChanged({
		$DiskSelection = $DiskSelection | Where-Object { $_.Number -eq $var_Disk_cmb.SelectedItem.Number }
		$global:SelectedDisk = $DiskSelection.Number
		$global:SelectedDisk = $global:SelectedDisk -as [int]
		Write-Host $global:SelectedDisk
	})
#endregion Disk_cmb Selection Changed to get Disk Number

#region Partition_cmb Selection changed to Backup Selected Disk
$var_Partition_cmb.Add_SelectionChanged({
		if ($var_Disk_cmb.SelectedIndex -eq 0) { $WshObject.Popup("Please Select a Disk ", 20, "Disk Error", 0 + 16) }		
		else
		{
			$global:SelectedPartScheme = $var_Partition_cmb.SelectedItem.SchemeName		
		}
        Write-Host $global:SelectedPartScheme		
	})
#endregion Partition_cmb Selection changed to Backup and Format Selected Disk

#region WinImage_cmb Selection Changed to get Image Name and Path
$var_WinImage_cmb.Add_SelectionChanged({
		$ImgSelection = $ImgSelection | Where-Object { $_.ImageName -eq $var_WinImage_cmb.SelectedItem.ImageName } #| Select-Object -ExpandProperty ImagePath
		$global:ImageFilePath = $ImgSelection.ImagePath
		Write-Debug $global:ImageFilePath		
		#region Creating $ImgSelection.XMLFilePath and Assinging it to $global:ImageXMLPath        
		Copy-Item -Path $ImgSelection.XMLFilePath -Destination $(Join-Path $env:TEMP -ChildPath $(Split-Path -Path $ImgSelection.XMLFilePath -Leaf -Resolve))        
		$global:ImageXMLPath = $(Join-Path $env:TEMP -ChildPath $(Split-Path -Path $ImgSelection.XMLFilePath -Leaf -Resolve))		
		Write-Debug $global:ImageXMLPath
		#endregion Creating $ImgSelection.XMLFilePath and Assinging it to $global:ImageXMLPath
		
	})
#endregion WinImage_cmb Selection Changed to get Image Name and Path

#region DriverPath_cmb Selection Changed to get Driver Path
$var_DriverPath_cmb.Add_SelectionChanged({
		$global:DriverPath = Join-Path $AllDrvPath -ChildPath $var_DriverPath_cmb.SelectedItem.Name
		Write-Debug $global:DriverPath
	})
#endregion DriverPath_cmb Selection Changed to get Driver Path

#region Domain_cmb Selection Changed only occur if Network avaliable. Get CN and Enable CN_lbl and update CN_txt and update default xml file with CN and worgroup
$var_Domain_cmb.Add_SelectionChanged({
		
		#region Generating/Retriving System Name from DB
		Write-Debug -Message "Getting System Name and Update Database"
		$MyCompInfoOnline = Get-SqlDataStoredProc -SqlConnection $LFSQLConnection -PS_CSR $($MyCompInfoOffline.compserialnumber) `
												  -PS_MOD $($MyCompInfoOffline.compmodelnumber) `
												  -PS_MAD $($MyCompInfoOffline.compmacaddress) `
												  -SP_TaskName "Windows 10 $($var_WinImage_cmb.SelectedItem.ImageName) Image Installation" `
												  -SP_TaskUserName $($MyCompInfoOffline.username)`
												  -SP_IPAddress '' `
												  -PS_NetworkType $($var_Domain_cmb.SelectedItem.NetworkType)
		#endregion Generating/Retriving System Name from DB
		
		#region Adding System Name to Unattended XML file
		if ($MyCompInfoOnline.SystemName -and $global:ImageXMLPath)
		{
			$var_CN_txt.Text = $MyCompInfoOnline.SystemName
			[xml]$TempImageXMLPath = Get-Content $global:ImageXMLPath
			($TempImageXMLPath.unattend.settings | Where-Object -Property pass -EQ 'specialize' | ` #Adding System Name to ImageXML file
				Select-Object -ExpandProperty component | `
				Where-Object -Property name -EQ 'Microsoft-Windows-Shell-Setup').ComputerName = $MyCompInfoOnline.SystemName
			$TempImageXMLPath.Save($global:ImageXMLPath)
		}
		#endregion Adding System Name to Unattended XML file
		
		#region Adding Workgroup Name to Unattended XML file
		if ($MyCompInfoOnline.DomainName) { $WorkGroup = $MyCompInfoOnline.DomainName }
		elseif ($MyCompInfoOnline.NetworkType) { $WorkGroup = $MyCompInfoOnline.NetworkType }
		
		if ($WorkGroup -and $global:ImageXMLPath) #Domain Name or Workgroup Updating Workgroup in XML file
		{
			[xml]$TempImageXMLPath = Get-Content $global:ImageXMLPath
			($TempImageXMLPath.unattend.settings | Where-Object -Property pass -EQ 'specialize' |`
				Select-Object -ExpandProperty component |`
				Where-Object -Property name -EQ 'Microsoft-Windows-UnattendedJoin').Identification.JoinWorkgroup = $WorkGroup
			$TempImageXMLPath.Save($global:ImageXMLPath)
			$global:AllInfo = $MyCompInfoOnline			
		}
		#endregion Adding Workgroup/Domain Name to Unattended XML file		
	})
#endregion Domain_cmb Selection Changed only occur if Network avaliable. Get CN and Enable CN_lbl and update CN_txt and update default xml file with CN and worgroup

#region Format_btn Click to begin Formatting
$var_Format_btn.Add_Click({
		if ($var_Disk_cmb.SelectedIndex -eq 0) { $WshObject.Popup("Please Select a Disk ", 20, "Disk Error", 0 + 16) }
		elseif ($var_Partition_cmb.SelectedIndex -eq 0) { $WshObject.Popup("Please Select Partition Scheme", 20, "Partition Error", 0 + 16) }
		else
		{
			#$tempTitle = $var_MainFrm.Title
			#$var_MainFrm.Title = "Please Wait Formatting Disk $global:SelectedDisk ..."
			$var_MainFrm.IsEnabled = $false			
			Write-Host "Formatting Disk $global:SelectedDisk for $global:SelectedPartScheme Partition"
			
			$ResetDisk = Reset-Disk -DiskNumber $global:SelectedDisk -PartitionScheme $global:SelectedPartScheme #Formatting Selected Disk			
			
			$var_MainFrm.IsEnabled = $true #enabling Mainform
			#$var_MainFrm.Title = $tempTitle #setting previous Mainform Title 
			if ($ResetDisk) { Write-Host 'Format Disk Completed Successfully!'; $var_Format_btn.IsEnabled = $false}
			else #if format not successful
			{
				$WshObject.Popup("Error During Formatting Disk. Please Reformat Disk $global:SelectedDisk", 20, "Disk $global:SelectedDisk Format Error", 0 + 16)
				$var_Format_btn.IsEnabled = $true
			}
		}
	})
#endregion Format_btn Click to begin Formatting

#region Install_btn Click to begin Windows Installation using WiNTSetup
$var_Install_btn.Add_Click({
		try
		{
			#region Adding info to AllInfo from MyCompInfoOnline/MyCompInfoOffline RND
			#Write-Debug "Adding info to AllInfo from MyCompInfoOnline/MyCompInfoOffline"
			#if ($MyCompInfoOnline) { Write-Host "Online Installation"; $global:AllInfo = $MyCompInfoOnline.Clone() }
			#elseif ($MyCompInfoOffline) { Write-Host "Offline Installation"; $global:AllInfo = $MyCompInfoOffline }
			#$global:AllInfo | Out-GridView -Wait
			#Exit
			#endregion Adding info to AllInfo from MyCompInfoOnline/MyCompInfoOffline RND
			
			if (!$($global:ImageFilePath)) { $WshObject.Popup("Please Select Windows Image ", 20, "Image Error", 0 + 16) }
			elseif (!$($global:DriverPath)) {$WshObject.Popup("Please Select Driver", 20, "Driver Error", 0 + 16) }			
			else
			{
				Write-Host "Installing Windows"
				$WinNTSetupArgumentList = "NT6 /source:$global:ImageFilePath /sysPart:S: /tempDrive:W: /wimIndex:1 /silent /setup "
				if ($global:ImageXMLPath) { $WinNTSetupArgumentList += "/unattend:$global:ImageXMLPath " }
				if ($global:DriverPath) { $WinNTSetupArgumentList += "/drivers:$global:DriverPath " }                
							
				Write-Debug "XML FILE: $global:ImageXMLPath"
				Write-Debug "XML FILE: $global:DriverPath"
				
				Write-Debug "Running $WinNTSetup $WinNTSetupArgumentList"
				
				$RunSetup = Start-Process -Wait $WinNTSetup -ArgumentList $WinNTSetupArgumentList -ErrorAction Stop
				#$RunSetup
				#Read-Host -Prompt "Press Any Key to Continue"
				Write-Host "Installation Completed..."
				if (! $(Test-Path "W:\SWSetup")) { New-Item -Path 'W:\' -Name 'SWSetup' -ItemType Directory }
				$global:AllInfo | Export-Clixml -Path $(Join-Path 'W:\SWSetup' -ChildPath "$($MyCompInfoOnline.compserialnumber).xml")
				$SWSetupUdate = Join-Path $(Join-Path $WimPath -ChildPath 'SWSetup') -ChildPath $(Split-Path -Path $($global:ImageFilePath.split('.\')[-2])) #checking for update file is USB
				$SWSetupUdate
				<#if (Test-Path $SWSetupUdate) #if Update for SWSetup Avaliable
				{
					Sync-Folder -File -SourceFolder $SWSetupUdate -TargetFolder 'W:\SWSetup'
				}#>
				Write-Host "Updating BIOS Now!"
				[console]::beep(2000, 10000)
				if (Test-Path "$global:DriverPath\BIOS")
				{
					$EXEPath = ""
					
					$WinDir = $env:windir
										
					if (Test-Path -Path "$global:DriverPath\BIOS\HPQFlash.exe")
					{
						$EXEPath = "$global:DriverPath\BIOS\HPQFlash.exe"
						#$args = "-s"
					}
					elseif (Test-Path -Path "$global:DriverPath\BIOS\HPBIOSUPDREC.exe")
					{
						$EXEPath = "$global:DriverPath\BIOS\HPBIOSUPDREC.exe"
						#$args = "-s -r"
					}
					
					if ($EXEPath -ne "")
					{
						Write-Host $EXEPath #$args
						#$Process = start-process -FilePath $EXEPath -ArgumentList $args -WorkingDirectory "$global:DriverPath\BIOS" -PassThru -wait
						#$Process = Start-Process -FilePath $EXEPath -WorkingDirectory "$global:DriverPath\BIOS" -PassThru -wait
						Start-Process -FilePath $EXEPath -WorkingDirectory "$global:DriverPath\BIOS" -wait
						#Start-Sleep -Seconds 30
					}
				}
				Write-Host "Installation Completed. Restarting Computer Now. Please Remove USB Storage Drive"
				#Restart-Computer -Force -Verbose
				#While ($1) { [console]::beep(2000, 500) }				
			}
		}
		catch { $_ }
	})
#endregion Install_btn Click to begin Windows Installation using WiNTSetup

$LFInstallationGuiWindow.ShowDialog()
#END

