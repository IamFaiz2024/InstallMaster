<#	
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2019 v5.6.160
	 Created on:   	1/9/2020 8:54 AM
	 Created by:   	SS26
	 Organization: 	
	 Filename:     	InstallOS-Module.psm1
	-------------------------------------------------------------------------
	 Module Name: InstallOS-Module
	===========================================================================
#>


#region Reset-Disk
<#
	.SYNOPSIS
		Clears the selected disk and creates required Partition
	
	.DESCRIPTION
		A detailed description of the Reset-Disk function.
	
	.PARAMETER DiskNumber
		A description of the DiskNumber parameter.
	
	.PARAMETER PartitionScheme
		A description of the PartitionScheme parameter.
	
	.EXAMPLE
		PS C:\> Reset-Disk -DiskNumber 0 -PartitionScheme UEFI
	
	.NOTES
		Additional information about the function.
#>
function Reset-Disk
{
	[CmdletBinding()]
	[OutputType([bool])]
	param
	(
		[int]$DiskNumber,
		[ValidateSet('UEFI', 'BIOS', 'Flat')]
		[string]$PartitionScheme = $null		
	)
	
	try
	{        		
		$SelectedDisk = "Disk $DiskNumber"
        $SelectedDisk		
		if (!$PartitionScheme)
		{
        $PartitionSchemeTable = New-Object System.Data.DataTable
		$PartitionSchemeTable.Columns.AddRange(@("SchemeName", "Supported Model"))
		[void]$PartitionSchemeTable.Rows.Add('UEFI', 'Z220 And Above')
		[void]$PartitionSchemeTable.Rows.Add('BIOS', '8300 And Below (Max 2 TB)')
		[void]$PartitionSchemeTable.Rows.Add('Flat', 'Flat NTFS Partition Scheme (Non Bootable)')
			$SelectedPartitionScheme = $PartitionSchemeTable | Out-GridView -Title 'Please Select the Type of Partition Scheme for Hardisk' -PassThru
			if ($SelectedPartitionScheme -eq $null) { exit }
		}        
		else { $SelectedScheme = $PartitionScheme }	

		
		$MessageBoxObject = New-Object -ComObject WScript.Shell
		$AlertResponse = $MessageBoxObject.Popup("All Data in $SelectedDisk will be ERASED and cannot be recovered", 0, "CAUTION: Hard Disk Data Alert!", 1 + 16)
		if ($AlertResponse -ne 1) { exit }
		Stop-Service -Name ShellHWDetection
				
		$UEFIPartition = {
			@"
    	    Select $SelectedDisk
            clean
            convert gpt
            create partition efi size=100
            format quick fs=fat32 label="System"
            assign letter="S"
            create partition msr size=16
            create partition primary
            shrink minimum=500
            format quick fs=ntfs label="Windows"
            assign letter="W"
            create partition primary
            format quick fs=ntfs label="Recovery tools"
            assign letter="R"
            set id="de94bba4-06d1-4d40-a16a-bfd50179d6ac"
            gpt attributes=0x8000000000000001
            list volume
            exit
"@ | diskpart
		}
		$BISOPartition = {
			@"
			Select $SelectedDisk            
            clean
            create partition primary size=100
            format quick fs=ntfs label="System"
            assign letter="S"
            active
            create partition primary
            shrink minimum=500
            format quick fs=ntfs label="Windows"
            assign letter="W"
            create partition primary
            format quick fs=ntfs label="Recovery"
            assign letter="R"
            set id=27
            list volume
            exit
"@ | diskpart
		}
		$NTFSFlat = {
			@"
			        Select $SelectedDisk
                    clean
                    create partition primary
                    format fs=ntfs quick Label=OSPartition
                    assign letter="W"
                    active
                    exit
"@ | diskpart
		}
		
			
		switch ($SelectedScheme)
		{
			'UEFI' {
				Invoke-Command -ScriptBlock $UEFIPartition
			}
			'BIOS' {
				Invoke-Command -ScriptBlock $BISOPartition
			}
			'Flat' {
				Invoke-Command -ScriptBlock $NTFSFlat
			}
			default
			{
				Write-Error "Invalid Partition Scheme Selected"; return $false
			}
		}
		#$AlertResponse = $MessageBoxObject.Popup("$SelectedDisk Cleared and Re-Partitioned using ($($SelectedPartitionScheme.SchemeName)) Successfully ", 30, "Format Complete", 0 + 16)
		Start-Service -Name ShellHWDetection
		return $true
	}
	
	catch
	{
		Write-Error $Error.ErrorDetails
		return $false
	}
}
#endregion Format-Disk
Export-ModuleMember -Function Reset-Disk

#region Get-ComputerInfo
	<#
	.SYNOPSIS
		Get computer information. Edited version from InstallOS-Module
	
	.DESCRIPTION
		Gets an array of ComputerName, Model Number, Serial Number, MAC Address and IP Address
	
	.EXAMPLE
		PS C:\> Get-ComputerInfo
	
	.NOTES
		Additional information about the function.
	#>
function Get-ComputerInfo
{
	[CmdletBinding()]
	[OutputType([hashtable])]
	param ()
	
	Begin
	{
		Try
		{
			[regex]$ip4 = "\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}"
			$NetConfig = Get-WmiObject Win32_NetworkAdapterConfiguration | ` #Get all network configuration
			Select-Object Description, @{ Name = "IPv4"; Expression = { $_.IPAddress -match $ip4 } }, MACAddress | ` #Express to get only IPv4 Address and not IPv6 Address
			Where-Object { $_.MACAddress -ne $null -and $_.Description -notmatch 'RAS' -and $_.Description -notmatch 'WAN' -and $_.Description -notmatch 'Kernel' -and $_.IPv4 -ne $false } #Filter out default RAS network adapter
			if ($NetConfig.Count -gt 1) { $NetConfig = $NetConfig | Out-GridView -OutputMode Single -Title "Select Appropriate MAC Address" } #if More than one network give option to select network card
			$SerialNumber = Get-WmiObject Win32_Bios | Select-Object -ExpandProperty SerialNumber
			$MACAddress = $NetConfig.MACAddress
			if ($SerialNumber -eq $null) { $SerialNumber = $MACAddress }
			$ModelNumber = Get-WmiObject Win32_ComputerSystem | Select-Object -ExpandProperty Model
			$IPAddress = $NetConfig.IPv4
		}
		Catch { Write-Error "Error While Retriving Computer Hardware Information $($_.Exception.Message)" }		
	}
	Process
	{
		$ComputerInfo =
		[ordered]@{
			'compserialnumber' = $SerialNumber; 'computername' = $env:COMPUTERNAME; 'compmacaddress' = $MACAddress; 'compmodelnumber' = $ModelNumber; 'ipaddress' = $IPAddress; 'SystemName' = $null; 'NetworkType' = $null	}		
	}
	End
	{
		Return $ComputerInfo
	}
}
#endregion Get-ComputerInfo
Export-ModuleMember -Function Get-ComputerInfo

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
			Foreach ($drvletter in "BCDEFGHIJKLMNOPQRSTUVWXYZ".ToCharArray())
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
Export-ModuleMember -Function Get-AvaliableDrive

#region Test-Credential
<#
    .SYNOPSIS
    Test a credential

    .DESCRIPTION
    Test a credential object or a username and password against a machine or domain.
    Can be used to validate service account passwords.

    .PARAMETER Credential
    Credential to test

    .PARAMETER UserName
    Username to test

    .PARAMETER Password
    Clear text password to test. 
    ATT!: Be aware that the password is written to screen and memory in clear text, it might also be stored in clear text on your computer.

    .PARAMETER ContextType
    Set where to validate the credential.
    Can be Domain, Machine or ApplicationDirectory

    .PARAMETER Server
    Set remote computer or domain to validate against.

    .EXAMPLE
    Test-Credential -UserName svc-my-service -Password Kgse(70g!S.
    True

    .EXAMPLE
    Test-Credential -Credential $Cred
    True
#>
function Test-Credential
{
	[CmdletBinding(DefaultParameterSetName = 'Credential')]
	Param
	(
		[Parameter(Mandatory = $true, ParameterSetName = 'Credential')]
		[pscredential]$Credential,
		[Parameter(Mandatory = $true, ParameterSetName = 'Cleartext')]
		[ValidateNotNullOrEmpty()]
		[string]$UserName,
		[Parameter(Mandatory = $true, ParameterSetName = 'Cleartext')]
		[string]$Password,
		[Parameter(Mandatory = $false, ParameterSetName = 'Cleartext')]
		[Parameter(Mandatory = $false, ParameterSetName = 'Credential')]
		[ValidateSet('ApplicationDirectory', 'Domain', 'Machine')]
		[string]$ContextType = 'Domain',
		[Parameter(Mandatory = $false, ParameterSetName = 'Cleartext')]
		[Parameter(Mandatory = $false, ParameterSetName = 'Credential')]
		[String]$Server
	)
	
	try
	{
		[bool]$ValidateRemoteMachine = $false
		Add-Type -AssemblyName System.DirectoryServices.AccountManagement -ErrorAction Stop
		if ($PSCmdlet.ParameterSetName -eq 'ClearText')
		{
			$EncPassword = ConvertTo-SecureString -String $Password -AsPlainText -Force
			$Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $UserName, $EncPassword
		}
		try
		{
			if ($ContextType -eq 'Domain' -and $PSBoundParameters.ContainsKey('Server'))
			{ $PrincipalContext = New-Object System.DirectoryServices.AccountManagement.PrincipalContext($ContextType, $Server) }
			elseif ($ContextType -eq 'Machine' -and $PSBoundParameters.ContainsKey('Server'))
			{
				$ValidateRemoteMachine = $true
				$GetRemotePCDetails = Get-WmiObject Win32_ComputerSystem -ComputerName $Server -Credential $Credential #| Out-Null
				if ($GetRemotePCDetails.Name) { return $true }
				else { return $false }
			}
			else { $PrincipalContext = New-Object System.DirectoryServices.AccountManagement.PrincipalContext($ContextType) }
		}
		catch { Write-Error -Message "Failed to connect to server using contect: $ContextType"; return $false }
		if ($ValidateRemoteMachine -eq $false)
		{
			try { $PrincipalContext.ValidateCredentials($Credential.UserName, $Credential.GetNetworkCredential().Password, 'Negotiate') }
			catch [UnauthorizedAccessException]{ Write-Warning -Message "Access denied when connecting to server."; return $false }
			
			catch { Write-Error -Exception $_.Exception -Message $_.Exception.Message; return $false }
		}
	}
	catch { throw }
}
#endregion Test-Credential
Export-ModuleMember -Function Test-Credential

#region Convert-ToEncryptDecryptString
<#
	.SYNOPSIS
		Encrypt/Decrypt String
	
	.DESCRIPTION
		Encrypt/Decrypt String with the default key
	
	.PARAMETER ActionType
		A description of the ActionType parameter.
	
	.PARAMETER UserString
		User Encrypted/Decrypted String
	
	.EXAMPLE
		PS C:\> Convert-ToEncryptDecryptString

	.NOTES
		Additional information about the function.
#>
function Convert-ToEncryptDecryptString
{
	[CmdletBinding()]
	[OutputType([string])]
	param
	(
		[ValidateSet('Encrypt', 'Decrypt')]
		[string]$ActionType = 'Encrypt',
		[string]$UserString
	)
	
	[string]$OutString
	$AESKey = Get-Content $PSScriptRoot\LFEnCrypt.key
	switch ($ActionType)
	{
		'Encrypt' {
			if ($UserString.Length -le 30)
			{
				$OutString = $UserString | ConvertTo-SecureString -AsPlainText -Force
				$OutString = $OutString | ConvertFrom-SecureString -key $AESKey
				#return $Enpassword
			}
			else { $OutString = 'Error. Already Encrypted' }
		}
		'Decrypt' {
			if ($UserString.Length -gt 30)
			{
				$OutString = $UserString | ConvertTo-SecureString -Key $AESKey
				$OutString = [System.Net.NetworkCredential]::new("", $OutString).Password
				#return $Depassword
			}
			else { Write-Host "Error. Already Plain text"; $OutString = '' }
		}
	}
	#Use ReturnVaiable[1] As ReturnVaiable[0] gettng empty line for some reason
	return $OutString.Trim()
}
#endregion Convert-ToEncryptDecryptString
Export-ModuleMember -Function Convert-ToEncryptDecryptString

#region Clear-Encryption by using EnDeCrypt-String
<#
	.SYNOPSIS
		check if string encrypted and return decrepted string
	
	.DESCRIPTION
		check if string encrypted and return decrepted string
	
	.PARAMETER UserString
		Encrypted or Decrepted string
	
	.EXAMPLE
		PS C:\> Clear-Encryption -UserString $MyString
	
	.NOTES
		Additional information about the function.
#>
function Clear-Encryption
{
	[CmdletBinding()]
	[OutputType([string])]
	param
	(
		[string]$UserString
	)
	
	if ($UserString.Length -gt 30)
	{
		$UserString = Convert-ToEncryptDecryptString -ActionType Decrypt -UserString $UserString
	}
	return $UserString.Trim()
}
#endregion Clear-Encryption using EnDeCrypt-String
Export-ModuleMember -Function Clear-Encryption

#region Show-Disks
<#
	.SYNOPSIS
		List the Physical/Logical Disks
	
	.DESCRIPTION
		List the Physical/Logical Disks and filter out to hide disk drive from where script is being run.
	
	.PARAMETER $Filter
		hides Disk Drive provided.
	
	.EXAMPLE
				PS C:\> Show-Disks
	
	.NOTES
		Additional information about the function.
#>
function Show-Disks
{
	[CmdletBinding()]
	[OutputType([System.Data.DataTable])]
	param (
		[int]$Filter = (Get-Partition -DriveLetter (Get-Item $PSScriptRoot).PSDrive.Name).DiskNumber #Find the Disk number running the script		
	)
	try
	{
		#[int]$Filter = (Get-Partition -DriveLetter (Get-Item $PSScriptRoot).PSDrive.Name).DiskNumber #Find the Disk number running the script		
		#Write-Verbose "[BEGIN  ] Starting: $($MyInvocation.Mycommand)"
		
		#Select-Object Number, FriendlyName, SerialNumber, OperationalStatus, Size, PartitionStyle | 
		$DrivesObject = Get-Disk | Sort-Object -Property Number | Where-Object { $_.Number -ne $Filter }
		$DrivesTable = New-Object System.Data.DataTable
		$DrivesTable.Columns.AddRange(@("Number", "FriendlyName", "SerialNumber", "OperationalStatus", "Size", "PartitionStyle"))
		
		
		foreach ($drive in $DrivesObject)
		{
			#region Step Necessary to avoid error 'You cannot call a method on a null-valued expression' due to Trim())
			$driveFName = $drive.FriendlyName
			if ($driveFName) { $driveFName = $driveFName.Trim() }
			$driveSrNo = $drive.SerialNumber
			#endregion Step Necessary to avoid error 'You cannot call a method on a null-valued expression' due to Trim())			
			if ($driveSrNo) { $driveSrNo = $driveSrNo.Trim() }
			[void]$DrivesTable.Rows.Add($drive.Number, $driveFName, $driveSrNo, $drive.OperationalStatus, "$([Math]::Round($drive.Size/1GB, 0))GB", $drive.PartitionStyle)
		}
	}
	catch
	{
		Write-Error $_.Exception.Message
		[void]$DrivesTable.Rows.Add($null, $null, $null) #, $null, $null, $null, $null)		
	}
	
	Return $DrivesTable
}
#endregion Show-Disks
Export-ModuleMember -Function Show-Disks

#region Select-WindowsImage
<#
	.SYNOPSIS
		Returns Select Image Details
	
	.DESCRIPTION
		List the Windows Images avaliable from define path and returns the selected image details
	
	.PARAMETER SearchPath
		Path to Search for Image Files
	
	.EXAMPLE
		PS C:\> Select-WindowsImage
	
	.NOTES
		Additional information about the function.
#>
function Select-WindowsImage
{
	[CmdletBinding()]
	[OutputType([System.Data.DataTable])]
	param
	(
		[string]$SearchPath = $PSScriptRoot
	)
	$WimFolderList = Get-ChildItem -Path $SearchPath -Filter "*.wim"
	$SwmFolderList = Get-ChildItem -Path "$SearchPath\SWM" -Filter "*.swm" | Sort-Object | Select-Object -First 1
	$GhoFolderList = Get-ChildItem -Path "$SearchPath\GHO" -Filter "*.gho" | Sort-Object | Select-Object -First 1
	$ImageFileCollection = @($WimFolderList) + @($SwmFolderList) + @($GhoFolderList)
    
	if ($ImageFileCollection -eq $null) { Write-Host "Windows Image Not Found"; exit }
	$ImageTable = New-Object System.Data.DataTable
    $ImageTable.Columns.AddRange(@("ImageName", "Architecture", "ImageSizeGB", "ImageFileSizeGB", "ImagePath", "XMLFilePath","ImageDescription","ImageType","DeployProgram"))

	foreach ($ImageFile in $ImageFileCollection)
	{
		$ImageFilePath = $ImageFile.FullName
		$FileExtension = (Split-Path -Path $ImageFilePath -Leaf).Split(".")[1]
		$XMLFilePath = $ImageFile.FullName -replace "$($FileExtension)$", 'xml'
		if (!(Test-Path -Path $XMLFilePath)) { $XMLFilePath = '' }
		if ($FileExtension -eq 'GHO')
		{
			$JsonFilePath = $ImageFile.FullName -replace "$($FileExtension)$", 'json'
            $GhostFileDetail = Get-Content $JsonFilePath | ConvertFrom-Json
			if (Test-Path $JsonFilePath)
			{
				[void]$ImageTable.Rows.Add($GhostFileDetail.ImageName, $GhostFileDetail.Architecture, $GhostFileDetail.ImageSizeGB, $GhostFileDetail.ImageFileSizeGB, $ImageFilePath, $XMLFilePath, $GhostFileDetail.ImageDescription,$FileExtension,"$(Split-Path -Path $PSScriptRoot -Qualifier)\$($GhostFileDetail.DeployProgram)")
			}			
		}
		else
		{
			$ImageFileObject = Get-WindowsImage -ImagePath $ImageFilePath -Index 1
			$ImageArchitecture = $ImageFileObject.Architecture
			if (($ImageArchitecture -eq 0) -or ($ImageArchitecture -match 0)) { $ImageArchitecture = 'x86' }
			elseif (($ImageArchitecture -eq 9) -or ($ImageArchitecture -match 9)) { $ImageArchitecture = 'x64' }
			else { $ImageArchitecture = 'N/A' }
			[void]$ImageTable.Rows.Add($ImageFileObject.ImageName, $ImageArchitecture, [Math]::Round(($ImageFileObject.ImageSize)/1024/1024/1024), [Math]::Round((Get-Item $ImageFilePath).length/1GB), $ImageFilePath, $XMLFilePath, $ImageFileObject.ImageDescription,$FileExtension,"$(Split-Path -Path $PSScriptRoot -Qualifier)\Utility\WinNTSetup4\WinNTSetup_x64.exe")
		}		
	}
	#$SelectedImage = $ImageTable | Out-GridView -PassThru -Title "Select the desired Windows Image from the list"    
	#$ImageTable
	return $ImageTable
}
#endregion Select-WindowsImage
Export-ModuleMember -Function Select-WindowsImage

#region Get-IniContent
Function Get-IniContent
{
    <#
    .Synopsis
        Gets the content of an INI file
 
    .Description
        Gets the content of an INI file and returns it as a hashtable
 
    .Notes
        Author : Oliver Lipkau <oliver@lipkau.net>
        Source : https://github.com/lipkau/PsIni
                      http://gallery.technet.microsoft.com/scriptcenter/ea40c1ef-c856-434b-b8fb-ebd7a76e8d91
        Version : 1.0.0 - 2010/03/12 - OL - Initial release
                      1.0.1 - 2014/12/11 - OL - Typo (Thx SLDR)
                                              Typo (Thx Dave Stiff)
                      1.0.2 - 2015/06/06 - OL - Improvment to switch (Thx Tallandtree)
                      1.0.3 - 2015/06/18 - OL - Migrate to semantic versioning (GitHub issue#4)
                      1.0.4 - 2015/06/18 - OL - Remove check for .ini extension (GitHub Issue#6)
                      1.1.0 - 2015/07/14 - CB - Improve round-tripping and be a bit more liberal (GitHub Pull #7)
                                           OL - Small Improvments and cleanup
                      1.1.1 - 2015/07/14 - CB - changed .outputs section to be OrderedDictionary
                      1.1.2 - 2016/08/18 - SS - Add some more verbose outputs as the ini is parsed,
                                                  allow non-existent paths for new ini handling,
                                                  test for variable existence using local scope,
                                                  added additional debug output.
 
        #Requires -Version 2.0
 
    .Inputs
        System.String
 
    .Outputs
        System.Collections.Specialized.OrderedDictionary
 
    .Example
        $FileContent = Get-IniContent "C:\myinifile.ini"
        -----------
        Description
        Saves the content of the c:\myinifile.ini in a hashtable called $FileContent
 
    .Example
        $inifilepath | $FileContent = Get-IniContent
        -----------
        Description
        Gets the content of the ini file passed through the pipe into a hashtable called $FileContent
 
    .Example
        C:\PS>$FileContent = Get-IniContent "c:\settings.ini"
        C:\PS>$FileContent["Section"]["Key"]
        -----------
        Description
        Returns the key "Key" of the section "Section" from the C:\settings.ini file
 
    .Link
        Out-IniFile
    #>
	
	[CmdletBinding()]
	[OutputType(
				[System.Collections.Specialized.OrderedDictionary]
				)]
	Param (
		# Specifies the path to the input file.
		[ValidateNotNullOrEmpty()]
		[Parameter(Mandatory = $true, ValueFromPipeline = $true)]
		[String]$FilePath,
		# Specify what characters should be describe a comment.

		# Lines starting with the characters provided will be rendered as comments.

		# Default: ";"

		[Char[]]$CommentChar = @(";"),
		# Remove lines determined to be comments from the resulting dictionary.

		[Switch]$IgnoreComments
	)
	
	Begin
	{
		Write-Debug "PsBoundParameters:"
		$PSBoundParameters.GetEnumerator() | ForEach-Object { Write-Debug $_ }
		if ($PSBoundParameters['Debug'])
		{
			$DebugPreference = 'Continue'
		}
		Write-Debug "DebugPreference: $DebugPreference"
		
		Write-Verbose "$($MyInvocation.MyCommand.Name):: Function started"
		
		$commentRegex = "^\s*([$($CommentChar -join '')].*)$"
		$sectionRegex = "^\s*\[(.+)\]\s*$"
		$keyRegex = "^\s*(.+?)\s*=\s*(['`"]?)(.*)\2\s*$"
		
		Write-Debug ("commentRegex is {0}." -f $commentRegex)
	}
	
	Process
	{
		Write-Verbose "$($MyInvocation.MyCommand.Name):: Processing file: $Filepath"
		
		$ini = New-Object System.Collections.Specialized.OrderedDictionary([System.StringComparer]::OrdinalIgnoreCase)
		#$ini = @{}
		
		if (!(Test-Path $Filepath))
		{
			Write-Verbose ("Warning: `"{0}`" was not found." -f $Filepath)
			Write-Output $ini
		}
		
		$commentCount = 0
		switch -regex -file $FilePath {
			$sectionRegex {
				# Section
				$section = $matches[1]
				Write-Verbose "$($MyInvocation.MyCommand.Name):: Adding section : $section"
				$ini[$section] = New-Object System.Collections.Specialized.OrderedDictionary([System.StringComparer]::OrdinalIgnoreCase)
				$CommentCount = 0
				continue
			}
			$commentRegex {
				# Comment
				if (!$IgnoreComments)
				{
					if (!(test-path "variable:local:section"))
					{
						$section = $script:NoSection
						$ini[$section] = New-Object System.Collections.Specialized.OrderedDictionary([System.StringComparer]::OrdinalIgnoreCase)
					}
					$value = $matches[1]
					$CommentCount++
					Write-Debug ("Incremented CommentCount is now {0}." -f $CommentCount)
					$name = "Comment" + $CommentCount
					Write-Verbose "$($MyInvocation.MyCommand.Name):: Adding $name with value: $value"
					$ini[$section][$name] = $value
				}
				else
				{
					Write-Debug ("Ignoring comment {0}." -f $matches[1])
				}
				
				continue
			}
			$keyRegex {
				# Key
				if (!(test-path "variable:local:section"))
				{
					$section = $script:NoSection
					$ini[$section] = New-Object System.Collections.Specialized.OrderedDictionary([System.StringComparer]::OrdinalIgnoreCase)
				}
				$name, $value = $matches[1, 3]
				Write-Verbose "$($MyInvocation.MyCommand.Name):: Adding key $name with value: $value"
				if (-not $ini[$section][$name])
				{
					$ini[$section][$name] = $value
				}
				else
				{
					if ($ini[$section][$name] -is [string])
					{
						$ini[$section][$name] = [System.Collections.ArrayList]::new()
						$ini[$section][$name].Add($ini[$section][$name]) | Out-Null
						$ini[$section][$name].Add($value) | Out-Null
					}
					else
					{
						$ini[$section][$name].Add($value) | Out-Null
					}
				}
				continue
			}
		}
		Write-Verbose "$($MyInvocation.MyCommand.Name):: Finished Processing file: $FilePath"
		Write-Output $ini
	}
	
	End
	{
		Write-Verbose "$($MyInvocation.MyCommand.Name):: Function ended"
	}
}
#endregion Get-IniContent
Export-ModuleMember -Function Get-IniContent

#region Set-IniContent
function Set-IniContent
{
	<#
	.Synopsis
		Updates existing values or adds new key-value pairs to an INI file
	
	.Description
		Updates specified keys to new values in all sections or certain sections.
		Used to add new or change existing values. To comment, uncomment or remove keys use the related functions instead.
		The ini source can be specified by a file or piped in by the result of Get-IniContent.
		The modified content is returned as a ordered dictionary hashtable and can be piped to a file with Out-IniFile.
	
	.Parameter FilePath
		Specifies the path to the input file.
	
	.Parameter InputObject
		Specifies the Hashtable to be modified. Enter a variable that contains the objects or type a command or expression that gets the objects.
	
	.Parameter NameValuePairs
		String of one or more key names and values to modify, with the name/value separated by a delimiter and the pairs separated by another delimiter . Required.
	
	.Parameter NameValueDelimiter
		Specify what character should be used to split the names and values specified in -NameValuePairs.
		Default: "="
	
	.Parameter NameValuePairDelimiter
		Specify what character should be used to split the specified name-value pairs.
		Default: ","
	
	.Parameter SectionDelimiter
		Specify what character should be used to split the -Sections parameter value.
		Default: ","
	
	.Parameter Sections
		String of one or more sections to limit the changes to, separated by a delimiter. Default is a comma, but this can be changed with -SectionDelimiter.
		Surrounding section names with square brackets is not necessary but is supported.
		Ini keys that do not have a defined section can be modified by specifying '_' (underscore) for the section.
	
	.Example
		$ini = Set-IniContent -FilePath "C:\myinifile.ini" -Sections 'Printers' -NameValuePairs 'Name With Space=Value1,AnotherName=Value2'
		-----------
		Description
		Reads in the INI File c:\myinifile.ini, adds or updates the 'Name With Space' and 'AnotherName' keys in the [Printers] section to the values specified,
		and saves the modified ini to $ini.
	
	.Example
		Set-IniContent -FilePath "C:\myinifile.ini" -Sections 'Terminals,Monitors' -NameValuePairs 'Updated=FY17Q2' | Out-IniFile "C:\myinifile.ini" -Force
		-----------
		Description
		Reads in the INI File c:\myinifile.ini and adds or updates the 'Updated' key in the [Terminals] and [Monitors] sections to the value specified.
		The ini is then piped to Out-IniFile to write the INI File to c:\myinifile.ini. If the file is already present it will be overwritten.
	
	.Example
		Get-IniContent "C:\myinifile.ini" | Set-IniContent -NameValuePairs 'Headers=True,Update=False' | Out-IniFile "C:\myinifile.ini" -Force
		-----------
		Description
		Reads in the INI File c:\myinifile.ini using Get-IniContent, which is then piped to Set-IniContent to add or update the 'Headers' and 'Update' keys in all sections
		to the specified values. The ini is then piped to Out-IniFile to write the INI File to c:\myinifile.ini. If the file is already present it will be overwritten.
	
	.Example
		Get-IniContent "C:\myinifile.ini" | Set-IniContent -NameValuePairs 'Updated=FY17Q2' -Sections '_' | Out-IniFile "C:\myinifile.ini" -Force
		-----------
		Description
		Reads in the INI File c:\myinifile.ini using Get-IniContent, which is then piped to Set-IniContent to add or update the 'Updated' key that
		is orphaned, i.e. not specifically in a section. The ini is then piped to Out-IniFile to write the INI File to c:\myinifile.ini.
	
	.Outputs
		System.Collections.Specialized.OrderedDictionary
	
	.Notes
		Author        : Sean Seymour <seanjseymour@gmail.com> based on work by Oliver Lipkau <oliver@lipkau.net>
		Source        : https://github.com/lipkau/PsIni
		http://gallery.technet.microsoft.com/scriptcenter/ea40c1ef-c856-434b-b8fb-ebd7a76e8d91
		Version        : 1.0.0 - 2016/08/18 - SS - Initial release
		
		#Requires -Version 2.0
	
	.Inputs
		System.String
		System.Collections.IDictionary
	
	.Link
		Get-IniContent
		Out-IniFile
#>
	[CmdletBinding(DefaultParameterSetName = 'File')]
	[OutputType([System.Collections.IDictionary])]
	param
	(
		[Parameter(ParameterSetName = 'File',
				   Mandatory = $true,
				   Position = 0)]
		[ValidateNotNullOrEmpty()]
		[String]$FilePath,
		[Parameter(ParameterSetName = 'Object',
				   Mandatory = $true,
				   ValueFromPipeline = $true)]
		[ValidateNotNullOrEmpty()]
		[System.Collections.IDictionary]$InputObject,
		[Parameter(ParameterSetName = 'File',
				   Mandatory = $true)]
		[Parameter(ParameterSetName = 'Object',
				   Mandatory = $true)]
		[ValidateNotNullOrEmpty()]
		[String]$NameValuePairs,
		[char]$NameValueDelimiter = '=',
		[char]$NameValuePairDelimiter = ',',
		[char]$SectionDelimiter = ',',
		[Parameter(ParameterSetName = 'File')]
		[Parameter(ParameterSetName = 'Object')]
		[ValidateNotNullOrEmpty()]
		[String]$Sections
	)
	
	Begin
	{
		Write-Debug "PsBoundParameters:"
		$PSBoundParameters.GetEnumerator() | ForEach { Write-Debug $_ }
		if ($PSBoundParameters['Debug']) { $DebugPreference = 'Continue' }
		Write-Debug "DebugPreference: $DebugPreference"
		Write-Verbose "$($MyInvocation.MyCommand.Name):: Function started"
		
		# Update or add the name/value pairs to the section.
		Function Update-IniEntry
		{
			param ($content,
				$section)
			
			foreach ($pair in $NameValuePairs.Split($NameValuePairDelimiter))
			{
				Write-Debug ("Processing '{0}' pair." -f $pair)
				
				$splitPair = $pair.Split($NameValueDelimiter)
				
				if ($splitPair.Length -ne 2)
				{
					Write-Warning("$($MyInvocation.MyCommand.Name):: Unable to split '{0}' into a distinct key/value pair." -f $pair)
					continue
				}
				
				$key = $splitPair[0].Trim()
				$value = $splitPair[1].Trim()
				Write-Debug ("Split key is {0}, split value is {1}" -f $key, $value)
				
				if (!($content[$section]))
				{
					Write-Verbose ("$($MyInvocation.MyCommand.Name):: '{0}' section does not exist, creating it." -f $section)
					$content[$section] = New-Object System.Collections.Specialized.OrderedDictionary([System.StringComparer]::OrdinalIgnoreCase)
				}
				
				Write-Verbose ("$($MyInvocation.MyCommand.Name):: Setting '{0}' key in section {1} to '{2}'." -f $key, $section, $value)
				$content[$section][$key] = $value
			}
		}
	}
	# Update the specified keys in the list, either in the specified section or in all sections.
	Process
	{
		# Get the ini from either a file or object passed in.
		if ($PSCmdlet.ParameterSetName -eq 'File') { $content = Get-IniContent $FilePath }
		if ($PSCmdlet.ParameterSetName -eq 'Object') { $content = $InputObject }
		
		# Specific section(s) were requested.
		if ($Sections)
		{
			foreach ($section in $Sections.Split($SectionDelimiter))
			{
				# Get rid of whitespace and section brackets.
				$section = $section.Trim() -replace '[][]', ''
				
				Write-Debug ("Processing '{0}' section." -f $section)
				
				Update-IniEntry $content $section
			}
		}
		else # No section supplied, go through the entire ini since changes apply to all sections.
		{
			foreach ($item in $content.GetEnumerator())
			{
				$section = $item.key
				
				Write-Debug ("Processing '{0}' section." -f $section)
				
				Update-IniEntry $content $section
			}
		}
		return $content
	}
	End
	{
		Write-Verbose "$($MyInvocation.MyCommand.Name):: Function ended"
	}
}
#endregion Set-IniContent
Export-ModuleMember -Function Set-IniContent

#region Get-DriverPath
<#
	.SYNOPSIS
		Finds path to driver of the device
	
	.DESCRIPTION
		Finds path (USB) to driver of the device based on information proviced
	
	.PARAMETER Model
		Model Number of Device
	
	.PARAMETER OSName
		OS Name (Mentioned in Image Description)
	
	.PARAMETER Arch
		Architecture of the OS
	
	.PARAMETER DriverCollectionRoot
		Root path of the Drivers
	
	.PARAMETER OS
		OS of the driver required
	
	.EXAMPLE
		PS C:\> Get-DriverPath
	
	.NOTES
		Additional information about the function.
#>
function Get-DriverPath
{
	[CmdletBinding()]
	[OutputType([System.Data.DataTable])]
	param
	(
		[string]$Model = (Get-WmiObject -Class Win32_ComputerSystem).Model,
		[string]$OSName,
		[string]$Arch,
		[string]$DriverCollectionRoot
	)
	#$Model = $Model -replace "[^0-9]", '' #Gets only number (digits) from Model Number
	$Model = $Model -replace '\D+([0-9]*).*', '$1' #Gets only number (digits) from Model Number
    $OSList = @('7', '8', '10', 'XP')
	$FindOSVer = $OSList | ForEach-Object {
		If ($OSName.toLower().Contains($_.toLower()))
		{ $OSVer = "W" + $_ }
	}
	$FindOSVer
	$DriverList = Get-ChildItem -Path $DriverCollectionRoot -Directory | `
	Where-Object { $_.Name -match $OSVer -and $_.Name -match $Arch -and $_.Name -match $Model -or $_.Name -match 'none' } | `
	Select-Object Name #| Out-GridView -OutputMode Single -Title "Select the Suitable Driver for Installation"
	#$FullDriverPath = Join-Path $DriverCollectionRoot -ChildPath $DriverList
	return $DriverList
}

#endregion Get-DriverPath
Export-ModuleMember -Function Get-DriverPath

#region Insert-Task
function Insert-Task
{
	[CmdletBinding()]
	[OutputType([bool])]
	param
	(
		[string]$TaskType,
		[string]$TaskDesc,
		[string]$UserName = 'U',
		[string]$DeviceSR
	)
}
#endregion Insert-Task

#region Install-Windows
<#
	.SYNOPSIS
		Install Windows
	
	.DESCRIPTION
		Install Windows OS along with drivers provided
	
	.PARAMETER WindowsImage
		Path to Windows Image file
	
	.PARAMETER Driver
		Driver Folder Path
	
	.EXAMPLE
				PS C:\> Install-Windows
	
	.NOTES
		Additional information about the function.
#>
function Install-Windows
{
	[CmdletBinding()]
	[OutputType([bool])]
	param
	(
		[string]$ImagePath,
		[string]$DriverPath		
	)
	
	#TODO: Place script here
}

#endregion Install-Windows
Export-ModuleMember -Function Install-Windows

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
Export-ModuleMember -Function Test-NetworkHost

#region Get-SqlDataStoredProc
	<#
	.SYNOPSIS
		Gets, Updates and Adds Data to Sql Database
	
	.DESCRIPTION
		Gets, Updates and Adds Data to Sql Database. Only Using Stored Procedure in Database to Select, Update and Add to database
	
	.PARAMETER PS_CSR
		Computer Serial Number.
	
	.PARAMETER PS_MAD
		Computer Network Card MAC Address
	
	.PARAMETER PS_MOD
		Computer Model Number
	
	.PARAMETER PS_NetworkType
		Type of Network Computer belongs to. Menu will be provided to select
	
	.PARAMETER SP_IPAddress
		Optional IP Address for the Computer
	
	.PARAMETER SP_TaskName
		Name of Task going to be performed. By default is Windows 10 Installation
	
	.PARAMETER SP_TaskUserName
		Name of User going to perform the Task. Usually Domain User Name
	
	.EXAMPLE
		PS C:\> Get-SqlDataStoredProc PS_CSR PS_MAD PS_NetworkType SP_IPAddress SP_TaskName SP_TaskUserName
	
	.NOTES
		Additional information about the function.
#>
function Get-SqlDataStoredProc
{
	[CmdletBinding()]
	[OutputType([string])]
	param
	(
		[System.Data.SqlClient.SqlConnection]$SqlConnection,
		[string]$PS_CSR,
		[string]$PS_MAD,
		[string]$PS_MOD,
		[string]$PS_NetworkType,
		[string]$SP_IPAddress,
		[string]$SP_TaskName = 'Windows 10 Installation',
		[string]$SP_TaskUserName
	)
	try
	{
		$SqlAdapter = New-Object System.Data.SqlClient.SqlDataAdapter
		$DataSet = New-Object System.Data.DataSet
		$ReturnDataTable = New-Object System.Data.DataTable
		
		$SqlConnection.Open()
		$Command = $SqlConnection.CreateCommand()
		Write-Debug "Using Stored Procedure UpdateAdd_Device_System_TBL to retrive SystemName"
		$Command.CommandType = [System.Data.CommandType]'StoredProcedure'
		$Command.CommandText = "UpdateAdd_Device_System_TBL" #Stored Procedure Name
		$Command.Parameters.AddWithValue("@SP_DeviceSRNO", $PS_CSR) | Out-Null
		$Command.Parameters.AddWithValue("@SP_DeviceMACAddress", $PS_MAD) | Out-Null
		$Command.Parameters.AddWithValue("@SP_DeviceModel", $PS_MOD) | Out-Null
		$Command.Parameters.AddWithValue("@SP_SysNameNetworkType", $PS_NetworkType) | Out-Null
		$Command.Parameters.AddWithValue("@SP_SysNameIPAddress", $SP_IPAddress) | Out-Null
		$Command.Parameters.AddWithValue("@SP_TaskName", $SP_TaskName) | Out-Null
		$Command.Parameters.AddWithValue("@SP_TaskUserName", $SP_TaskUserName) | Out-Null
		$SqlAdapter.SelectCommand = $Command
		$SqlAdapter.Fill($DataSet) | Out-Null
		$ReturnDataTable = $DataSet.Tables[0]
		$SqlConnection.Close()
		return $ReturnDataTable
	}
	Catch
	{
		Write-Output "Error While Retriving System Name from UpdateAdd_Device_System_TBL Stored Procedure"
		Write-Host $_.Exception.Message
		Exit
	}
}
#endregion Get-SqlDataStoredProc	
Export-ModuleMember -Function Get-SqlDataStoredProc

#region Get-UserStoredProc
	<#
	.SYNOPSIS
		Gets, Updates and Adds Data to Sql Database
	
	.DESCRIPTION
		Gets, Updates and Adds Data to Sql Database. Only Using Stored Procedure in Database to Select, Update and Add to database
	
	.PARAMETER PS_UserID
		User ID to get Detail.
		
	.EXAMPLE
		PS C:\> Get-UserStoredProc PS_UserID 'UserID'
	
	.NOTES
		Additional information about the function.
#>
function Get-UserStoredProc
{
	[CmdletBinding()]
	[OutputType([string])]
	param
	(
		[System.Data.SqlClient.SqlConnection]$SqlConnection = $LFSQLConnection.ConnectionString,
		[string]$PS_UserID
	)
	try
	{		
		$SqlAdapter = New-Object System.Data.SqlClient.SqlDataAdapter
		$DataSet = New-Object System.Data.DataSet
		$ReturnDataTable = New-Object System.Data.DataTable
		
		$SqlConnection.Open()
		$Command = $SqlConnection.CreateCommand()
		Write-Debug "Using Stored Procedure To Get Selected User Details"
		$Command.CommandType = [System.Data.CommandType]'StoredProcedure'
		$Command.CommandText = "Get_UserDetails" #Stored Procedure Name
		$Command.Parameters.AddWithValue("@SP_UserID", $PS_UserID) | Out-Null
		
		$SqlAdapter.SelectCommand = $Command
		$SqlAdapter.Fill($DataSet) | Out-Null
		$ReturnUserInfo = $DataSet.Tables[0]
		$SqlConnection.Close()
		return $ReturnUserInfo
	}
	Catch
	{
		Write-Output  $_.Exception.Message
		#Write-Host $_.Exception.Message
		Exit
	}
}
#endregion Get-SqlDataStoredProc	
Export-ModuleMember -Function Get-UserStoredProc

#region Get-SqlData Using Query
	<#
	.SYNOPSIS
		Executes Sql Query and Get the data
	
	.DESCRIPTION
		Executes Sql Query and Gets the result in form of Datatable
	
	.PARAMETER SqlConnection
		SqlConnection made in other fuction
	
	.PARAMETER SqlQuery
		A description of the SqlQuery parameter.
	
	.EXAMPLE
		PS C:\> Get-SqlData
	
	.NOTES
		Additional information about the function.
	#>
function Get-SqlData
{
	[CmdletBinding()]
	[OutputType([System.Data.DataTable])]
	param
	(
		[System.Data.SqlClient.SqlConnection]$SqlConnection= $LFSQLConnection.ConnectionString,
		[String]$SqlQuery
	)
	$ReturnDataTable = New-Object System.Data.DataTable
	
	$SqlConnection.Open()
	$Command = $SqlConnection.CreateCommand()
	$Command.CommandText = $SqlQuery
	$resultQuery = $Command.ExecuteReader()
	$ReturnDataTable.Load($resultQuery)
	$SqlConnection.Close()
	return $ReturnDataTable
}
#endregion Get-SqlData Using Query
Export-ModuleMember -Function Get-SqlData

#region Test-RegistryValue
<#
	.SYNOPSIS
		Test registry key value
	
	.DESCRIPTION
		A detailed description of the Test-RegistryValue function.
	
	.PARAMETER Path
		A description of the Path parameter.
	
	.PARAMETER Value
		A description of the Value parameter.
	
	.EXAMPLE
				PS C:\> Test-RegistryValue -Path $value1 -Value $value2
	
	.NOTES
		Additional information about the function.
#>
function Test-RegistryValue
{
	[OutputType([bool])]
	param
	(
		[Parameter(Mandatory = $true)]
		[ValidateNotNullOrEmpty()]
		$Path,
		[Parameter(Mandatory = $true)]
		[ValidateNotNullOrEmpty()]
		$Value
	)
	try
	{
		Get-ItemProperty -Path $Path | Select-Object -ExpandProperty $Value -ErrorAction Stop | Out-Null
		return $true
	}
	catch
	{ return $false }
}
#endregion Test-RegistryValue
Export-ModuleMember -Function Test-RegistryValue

#region AutoLogin-Windows
<#
	.SYNOPSIS
		Login To Windows Automatically with user provided
	
	.DESCRIPTION
		Login To Windows Automatically with user provided
	
	.PARAMETER UserName
		User to Login

	.PARAMETER UserPassword
		User Password use to Login

	.PARAMETER StartupFilePath
		Optional Startup File to execute at login

	.EXAMPLE
				PS C:\> AutoLogin-Windows -UserName -UserPassword 
	
	.NOTES
		Additional information about the function.
#>
function Autologin-Windows
{
	[CmdletBinding()]
	[OutputType([string])]
	param
	(
		[string]$UserName='Mudeer',
		[string]$UserPassword = 'win10sig@GHQ',
		[string]$DefaultDomainName,
		[string]$StartupFilePath
	)
	try
	{
		$AdminKey = "HKLM:"
		if ($StartupFilePath)
		{
			$RunOnceKey = $AdminKey + "\Software\Microsoft\Windows\CurrentVersion\RunOnce"
			Set-Itemproperty $RunOnceKey "ConfigureClient" "$StartupScriptFile" -Verbose
		}
		$WinLogonKey = $AdminKey + "\SOFTWARE\Microsoft\Windows NT\CurrentVersion\WinLogon"
		Set-Itemproperty $WinLogonKey "AutoAdminLogon" "1" -Verbose
		Set-Itemproperty $WinLogonKey "AutoLogonCount" "1" -Verbose
		Set-Itemproperty $WinLogonKey "DefaultUserName" $UserName -Verbose
		Set-Itemproperty $WinLogonKey "DefaultPassword" $UserPassword -Verbose
		#[bool]$UnderDomainFlag = (Get-WmiObject -Class Win32_ComputerSystem).PartOfDomain
		if($DefaultDomainName){ Set-Itemproperty $WinLogonKey "DefaultDomainName" $DefaultDomainName -Verbose} #Adding DefaultDomainName Reg if Under Domain		
	}
	catch { Write-Output $Error.Exception.Message }
}
#endregion Get-FolderSize
Export-ModuleMember -Function AutoLogin-Windows

#region AutoLogin-Windows
<#
	.SYNOPSIS
		Join Computer to Domain
	
	.DESCRIPTION
		Join Computer to Domain
	
	.PARAMETER UserName
		User to Login

	.PARAMETER UserPassword
		User Password use to Login

	.PARAMETER DomainName
		Optional Startup File to execute at login

	.EXAMPLE
				PS C:\> AutoLogin-Windows -UserName -UserPassword 
	
	.NOTES
		Additional information about the function.
#>
function Join-Domain
{
	[CmdletBinding()]
	[OutputType([string])]
	param
	(
		[string]$UserName,
		[string]$UserPassword,
		[string]$DomainName
	)
	try
	{
		[bool]$UnderDomainFlag = (Get-WmiObject -Class Win32_ComputerSystem).PartOfDomain
		if ($UnderDomainFlag -eq $false -and $env:COMPUTERNAME -match $SystemNamePattern)
		{
			$DomainUserCred = New-Object System.Management.Automation.PSCredential ($UserName, $(ConvertTo-SecureString $UserPassword -AsPlainText -Force))			
			Add-Computer -DomainName $DomainName -Credential $DomainUserCred -Force
		}
	}
	catch
	{
		$NoSystemNameReplyMessage = $WshObject.Popup("Joining to $($MyComputerInfo.DomainName) Failed due to `n$($_.Exception.Message) `n Please Continue manually", 0, "Join Domain FAILED!", 0 + 16)
		Start-Process systempropertiescomputername -PassThru
		break
	}
}
#endregion Get-FolderSize
Export-ModuleMember -Function Join-Domain

#region Get-FolderSize
<#
	.SYNOPSIS
		Returns Folder Size in readable form
	
	.DESCRIPTION
		Returns Folder Size in readable form
	
	.PARAMETER FolderPath
		A description of the FolderPath parameter.
	
	.EXAMPLE
				PS C:\> Get-FolderSize
	
	.NOTES
		Additional information about the function.
#>
function Get-FolderSize
{
	[CmdletBinding()]
	[OutputType([string])]
	param
	(
		[string]$FolderPath
	)
	
	$Shlwapi = Add-Type -MemberDefinition '
    [DllImport("Shlwapi.dll", CharSet=CharSet.Auto)]public static extern int StrFormatByteSize(long fileSize, System.Text.StringBuilder pwszBuff, int cchBuff);
' -Name "ShlwapiFunctions" -namespace ShlwapiFunctions -PassThru
	
	[long]$SizeInBytes = (robocopy $FolderPath $env:TEMP /S /bytes /XA:ST /XJ /XJD /XJF /R:1 /W:1 /V /ETA /TEE /JOB:"$PSScriptRoot\JOBFILE.RCJ" | Where-Object { $_ -match "Bytes :" }).trim().split(" ")[3 .. 12] | Measure-Object -Maximum | Select-Object -ExpandProperty Maximum
	
	$Bytes = New-Object Text.StringBuilder 20
	$Return = $Shlwapi::StrFormatByteSize($SizeInBytes, $Bytes, $Bytes.Capacity)
	If ($Return) { $Bytes.ToString() }
}
#endregion Get-FolderSize
Export-ModuleMember -Function Get-FolderSize

#region Add-Data
<#
	.SYNOPSIS
		Copy Data from Source to Destination
	
	.DESCRIPTION
		Copies Data from Source to Destination using robocopy
	
	.PARAMETER source
		A description of the source parameter.
	
	.PARAMETER dest
		A description of the dest parameter.
	
	.EXAMPLE
				PS C:\> Add-Data
	
	.NOTES
		Additional information about the function.
#>
function Add-Data
{
	[OutputType([bool])]
	param
	(
		[string]$source,
		[string]$dest
	)
	
	try
	{
		Write-Debug "Backing Up Data Now `n"
		chcp 65001
		ROBOCOPY.EXE "$source" "$dest" /L /S /XA:ST /XJ /XJD /XJF /R:0 /W:1 /V /ETA /TEE /LOG:"$dest\LogFile.txt" /JOB:"$PSScriptRoot\JOBFILE.RCJ"
		"Backup Done"
		return $true
	}
	catch
	{
		Write-Host $_.ErrorID
		Write-Host $_.Exception.Message
		return $false
	}
}
#endregion Add-Data
Export-ModuleMember -Function Add-Data

#region Test-Files
<#
	.SYNOPSIS
		Check if all files exist
	
	.DESCRIPTION
		A detailed description of the Test-Files function.
	
	.PARAMETER ReferenceObj
		A description of the ReferenceObj parameter.
	
	.PARAMETER DifferenceObj
		A description of the DifferenceObj parameter.
	
	.EXAMPLE
				PS C:\> Test-Files
	
	.NOTES
		Additional information about the function.
#>
function Test-Files
{
	[CmdletBinding()]
	[OutputType([hashtable])]
	param
	(
		[array]$ReferenceObj = @(),
		[array]$DifferenceObj = @()
	)
	try
	{
		[hashtable]$CompareResult = [ordered]@{ 'Missing' = $null; 'Return' = $false }
		$compare = $(Compare-Object $ConfigList $availableList -PassThru)
		$CompareResult.Missing = $compare
		If ($compare.count -eq 0) { $CompareResult.Return = $true }
		else { $CompareResult.Return = $false; throw "Missing File" }
	}
	catch { Write-Error "$($_.Exception.Message) $($CompareResult.Missing)" }
	return $CompareResult
}
#endregion Test-Files
Export-ModuleMember -Function Test-Files

#region Mount-NwDrive
function Mount-NwDrive
{
	param
	(
		[string]$Path = $HostNework.Path,
		[string]$User = $HostNework.User,
		[string]$UserPassword = $HostNework.Password,
		[string]$DriveLetter = '',
		[switch]$Disconnect
	)
	
	try
	{
		if ($Disconnect)
		{
			$SmbMap = Remove-SmbMapping -RemotePath $Path -Force
			#$NetObject.RemoveNetworkDrive($DriveLetter, "true")
			Write-Host "Network Drive $DriveLetter Successfully Removed"			
		}
		else
		{
			$PrevousMount = Get-SmbMapping -RemotePath $Path -ErrorAction SilentlyContinue
			if ($PrevousMount.Status -eq 'OK') { Remove-SmbMapping -RemotePath $Path -Force -ErrorAction SilentlyContinue}
			if (!$DriveLetter) { $DriveLetter = (Get-AvaliableDrive).drive }
			Write-Host "Mounting $DriveLetter to $Path"
			#$NetObject.MapNetworkDrive($DriveLetter, $Path, "true", $User, $UserPassword)
			$SmbMap = New-SmbMapping -RemotePath $Path -LocalPath $DriveLetter -UserName $User -Password $UserPassword -Persistent $true
			Write-Host "Successfully mounted $Path to $DriveLetter"
		}
		return $SmbMap
		
	}
	Catch
	{ Write-Host "$($_.ErrorID) `n $($_.Exception.Message)"; return $false }
}
#endregion Mount-NwDrive
Export-ModuleMember -Function Mount-NwDrive

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
		$SyncRobocopyArgs = "$SourceFolder $TargetFolder /S"
		$BackupRobocopyArgs = "$SourceFolder $TargetFolder /S /XA:ST /XJ /XJD /XJF /R:0 /W:0 /V /ETA /TEE /LOG:$(Join-Path $TargetFolder -ChildPath 'LogFile.txt') /JOB:$(Join-Path $PSScriptRoot -ChildPath 'JOBFILE.RCJ')"
		Write-Host "Copying  $SourceFolder to $TargetFolder"
		
		if ($Backup) { Start-Process -FilePath Robocopy -ArgumentList $BackupRobocopyArgs -Wait -Verbose }
		elseif ($File) { Copy-Item -Path $SourceFolder -Destination $TargetFolder -Recurse -Force -Verbose -PassThru }
		else { Start-Process -FilePath Robocopy $SyncRobocopyArgs -Wait -Verbose }
		
		Write-Host "Copying Done"
	}
	catch
	{
		Write-Error -Message "Unable to Update files from Server `n $($_.Exception.Message)" -ErrorAction SilentlyContinue
	}
	
}
#endregion Sync-Folder
Export-ModuleMember -Function Sync-Folder

#region ScritpBlock Clean-Up
$Clean_Up = {
	if ($(Test-Path "$PSScriptRoot\CompInfo.ini")) { Remove-Item -Path "$PSScriptRoot\CompInfo.ini" -Force }
	Get-ChildItem -Path "$PSScriptRoot" -Filter 'LF*' | Select-Object -ExpandProperty FullName | ForEach-Object { Remove-Item $_ -Force }
	Remove-Item -Path "$PSScriptRoot\LFEnCrypt.key" -Force
	#AutoLogin and Startup Script $AutoLoginStartupScript
	$StartupScriptFile = "$PSScriptRoot\LF-Installation.cmd"
	$AdminKey = "HKLM:"
	$WinLogonKey = $AdminKey + "\SOFTWARE\Microsoft\Windows NT\CurrentVersion\WinLogon"
	try
	{
		
		$StartupScriptFile = "$PSScriptRoot\LF-Installation.cmd"
		$AdminKey = "HKLM:"
		
		$WinLogonKey = $AdminKey + "\SOFTWARE\Microsoft\Windows NT\CurrentVersion\WinLogon"
		
		Remove-Itemproperty $WinLogonKey "DefaultUserName"
		Remove-Itemproperty $WinLogonKey "DefaultPassword"
		Remove-Itemproperty $WinLogonKey "AutoAdminLogon"
		Remove-Itemproperty $WinLogonKey "AutoLogonCount"
		Remove-Itemproperty $WinLogonKey "LastUsedUsername"
		
	}
	catch
	{
		Write-Host $_.Exception.Message
	}
}
#endregion ScritpBlock Clean-Up
Export-ModuleMember -Variable Clean_Up

#region Script Block for AutoLogin and Startup Script $AutoLoginStartupScript
$AutoLoginStartupScript = {
	$StartupScriptFile = "$PSScriptRoot\LF-Installation.cmd"
	$AdminKey = "HKLM:"
	$RunOnceKey = $AdminKey + "\Software\Microsoft\Windows\CurrentVersion\RunOnce"
	$WinLogonKey = $AdminKey + "\SOFTWARE\Microsoft\Windows NT\CurrentVersion\WinLogon"
	
	if ($(Test-Path -Path $StartupScriptFile) -and $(!$(Test-RegistryValue -Path $RunOnceKey -Value 'ConfigureClient'))) #if $StartupScript file avaliable and registry not updated
	{ Set-Itemproperty $RunOnceKey "ConfigureClient" "$StartupScriptFile" }
	if (!$(Test-RegistryValue -Path $WinLogonKey -Value 'DefaultUserName'))
	{ Set-Itemproperty $WinLogonKey "DefaultUserName" "Mudeer" }
	
	if (!$(Test-RegistryValue -Path $WinLogonKey -Value 'DefaultPassword'))
	{
		Set-Itemproperty $WinLogonKey "DefaultPassword" "win10sig@GHQ"
		Set-Itemproperty $WinLogonKey "AutoAdminLogon" "1"
		Set-Itemproperty $WinLogonKey "AutoLogonCount" "1"
	}
}
#endregion Script Block for AutoLogin and Startup Script $AutoLoginStartupScript 		
Export-ModuleMember -Variable AutoLoginStartupScript

#region CreateUpdateBatch
$CreateUpdateBatch = {
	@"
		@echo Off
		"C:\Program Files\McAfee\Agent\cmdagent.exe" /s
		"C:\Program Files\McAfee\Agent\cmdagent.exe" /c		
		"C:\Program Files\McAfee\Agent\cmdagent.exe" /e
		"C:\Program Files\McAfee\Agent\cmdagent.exe" /p
		"C:\Program Files\McAfee\Agent\cmdagent.exe" /f
		"C:\Program Files\McAfee\Agent\cmdagent.exe" /f
		"C:\Program Files\McAfee\Agent\cmdagent.exe" /c
		GPUpdate
		Exit    	    
"@ | Out-File -Encoding ascii -FilePath "$PSScriptRoot\MacUpdate.cmd"
	if (Test-Path "$PSScriptRoot\MacUpdate.cmd") #Creating Shorcut Link for Update at public desktop
	{
		$SourceMacFile = "$PSScriptRoot\MacUpdate.cmd"
		$ShortcutMacFile = "C:\Users\Public\Desktop\McAfee_Update.Lnk"
		$Shortcut = $WshObject.CreateShortcut($ShortcutMacFile)
		$Shortcut.TargetPath = $SourceMacFile
		$Shortcut.Save()
	}
}
#endregion CreateUpdateBatch
Export-ModuleMember -Variable CreateUpdateBatch

#region Variables Declaration

$NetObject = New-Object -ComObject WScript.Network #VbScirpt Mount Network Drive

$WshObject = New-Object -ComObject WScript.Shell #VbScript MessageBox Object

[void][System.Reflection.Assembly]::LoadWithPartialName('Microsoft.VisualBasic') #input box assembly

$WinInstDrives = @('W:\', 'S:\', 'R:\')

$LFBackupServer = [ordered]@{ Name = 'INET-LF-1166'; SharePath = '\\INET-LF-1166\Backups'; User = 'W7User'; Password = '123456' }
$LFServer = [ordered]@{ Name = '155.180.254.13'; SharePath = '\\155.180.254.13\Soft'; User = 'weblogin'; Password = '123456' }
$LFAppStruct = [ordered]@{ Drivers = 'Drivers'; Apps = 'PS_Apps'; Utility = 'Utility'; Wim = 'WIM' }

$LFSQLConnection = New-Object System.Data.SqlClient.SqlConnection
$LFSQLConnection.ConnectionString = "Server=$($LFServer.Name)\COMMSQLSVR;Database=Maintenance;Integrated Security = false;User ID=$($LFServer.User);Password=$($LFServer.Password)"

[regex]$SystemNamePattern = "^[a-zA-Z]{1,3}\-[a-zA-Z]{1,3}\-\w{1,3}\-\d{1,4}$"

[array]$PreInstallTask = @('Backup', 'ResetHDD', 'InstallImage', 'GenerateCN', 'JoinDomain')
			
$PartitionSchemeTable = New-Object System.Data.DataTable
$PartitionSchemeTable.Columns.AddRange(@("SchemeName", "Supported_Model"))
[void]$PartitionSchemeTable.Rows.Add('UEFI', 'Z220 And Above')
[void]$PartitionSchemeTable.Rows.Add('BIOS', '8300 And Below (Max 2 TB)')
[void]$PartitionSchemeTable.Rows.Add('Flat', 'Flat NTFS Partition Scheme (Non Bootable)')

$LFServer = [ordered]@{ Name = '155.180.254.13'; SharePath = '\\155.180.254.13\Soft'; User = 'weblogin'; Password = '123456' }
$LFAppStruct = [ordered]@{ Drivers = 'Drivers'; Apps = 'PS_Apps'; Utility = 'Utility'; Wim = 'WIM' }

$LFUser = [ordered]@{ Domain = 'U1155296'; Service = 'U1208791' }

#endregion Variables Declaration
Export-ModuleMember -Variable NetObject
Export-ModuleMember -Variable WshObject
Export-ModuleMember -Variable LFSQLConnection
Export-ModuleMember -Variable SystemNamePattern
Export-ModuleMember -Variable PartitionSchemeTable
Export-ModuleMember -Variable LFBackupServer
Export-ModuleMember -Variable LFServer
Export-ModuleMember -Variable LFAppStruct
Export-ModuleMember -Variable WinInstDrives
Export-ModuleMember -Variable LFUser
