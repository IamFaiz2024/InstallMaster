BEGIN
{
	Add-Type -AssemblyName PresentationFramework #GUI Framework
	Add-Type -AssemblyName Microsoft.VisualBasic #input box assembly
	
	$UserName = [Microsoft.VisualBasic.Interaction]::InputBox('Enter Tawasul User Name', 'User Name Input', 'U')
	
	[string]$RequiredInfo = $null
	[string]$SerialNumber = $null
	[string]$MacAddress = $null
	[string]$ModelNumber = $null
	
	#region Get-WSCN
	function Get-WSCN
	{
		[CmdletBinding()]
		[OutputType([System.Data.DataTable])]
		param
		(
			[string]$SerialNumber,
			[string]$MACAddress,
			[string]$Model,
			[string]$NetworkType = 'W-ZMC-GRF',
			[string]$IPAddress = $null,
			[string]$UserName = 'U1208791',
			[string]$TaskName = 'CN Joined to Domain By Yasser U1187808'
		)
		BEGIN
		{
			$connectionString = "Server=155.180.254.13\COMMSQLSVR;Database=Maintenance;User Id=weblogin;Password='123456';"
			$SqlConnection = New-Object System.Data.SqlClient.SqlConnection
			$SqlConnection.ConnectionString = $connectionString
			$SqlAdapter = New-Object System.Data.SqlClient.SqlDataAdapter
			$DataSet = New-Object System.Data.DataSet
			$ReturnDataTable = New-Object System.Data.DataTable
		}
		PROCESS
		{
			try
			{
				$SqlConnection.Open()
				$Command = $SqlConnection.CreateCommand()
				Write-Debug "Using Stored Procedure UpdateAdd_Device_System_TBL to retrive SystemName"
				$Command.CommandType = [System.Data.CommandType]'StoredProcedure'
				$Command.CommandText = "UpdateAdd_Device_System_TBL" #Stored Procedure Name
				$Command.Parameters.AddWithValue("@SP_DeviceSRNO", $SerialNumber) | Out-Null
				$Command.Parameters.AddWithValue("@SP_DeviceMACAddress", $MACAddress) | Out-Null
				$Command.Parameters.AddWithValue("@SP_DeviceModel", $Model) | Out-Null
				$Command.Parameters.AddWithValue("@SP_SysNameNetworkType", $NetworkType) | Out-Null
				$Command.Parameters.AddWithValue("@SP_SysNameIPAddress", $IPAddress) | Out-Null
				$Command.Parameters.AddWithValue("@SP_TaskUserName", $UserName) | Out-Null
				$Command.Parameters.AddWithValue("@SP_TaskName", $TaskName) | Out-Null
				$SqlAdapter.SelectCommand = $Command
				$SqlAdapter.Fill($DataSet) | Out-Null
				$ReturnDataTable = $DataSet.Tables[0]
			}
			catch
			{
				Write-Host $_.Exception.Message
			}
		}
		END
		{
			$SqlConnection.Close()
			return $ReturnDataTable
		}
	}
	#endregion
	
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
	
	#region ParseTextBox Function
			<#
	.SYNOPSIS
		Get Required Work Station Information
	
	.DESCRIPTION
		A detailed description of the Get-Wsinfo function.
	
	.PARAMETER TxtBoxCtrl
		Target TextBox
	
	.EXAMPLE
		PS C:\> Get-Wsinfo
	
	.NOTES
		Additional information about the function.
#>
	function Get-Wsinfo
	{
		[CmdletBinding()]
		param
		(
			[System.Windows.Controls.TextBox]$TxtBoxCtrl
		)
		
		[string[]]$RequiredInfo = $TxtBoxCtrl.Text -split "`n"
		return $RequiredInfo
	}
	
	#endregion ParseTextBox Function
	
	#region MainFrm_OnLoad
	$var_MainFrm.Add_Loaded({
			$varLblTmp = New-Object System.Windows.Controls.Label
			$var_CN_txt.Visibility = 'Hidden'
			$var_User_lbl.Content = $UserName #Setting Form Title as UserName
			$var_CN_txt.Content = "W-ZMC-GRF-"
		})
	#endregion MainFrm_OnLoad
	
}
PROCESS
{
	$var_Parse_btn.Add_Click({
			Write-Host "Processing"
			[string[]]$Comp_Details = Get-Wsinfo -TxtBoxCtrl $var_Comp_Details
			
			$SerialNumber = $Comp_Details[0].ToUpper()
			$MacAddress = $Comp_Details[2].ToUpper()
			$ModelNumber = $Comp_Details[3].ToUpper()
			
			Write-Host "User is: $UserName"
			Write-Host "Serial Number is: $SerialNumber"
			Write-Host "MACAddress is: $MacAddress"
			Write-Host "Model Number is: $ModelNumber"
			
			
			#$CN = Get-WSCN -SerialNumber $SerialNumber -MACAddress $MacAddress -Model $ModelNumber
			
			$TextFileContent = "$SerialNumber$MacAddress$ModelNumber"
			$configFilePath = "$PSScriptRoot\$($SerialNumber.Trim()).txt"
			$TextFileContent | Out-File -FilePath $configFilePath -Append -Force -Verbose
		})
}

END
{
	#$CN = Get-WSCN -SerialNumber '35DVVD3' -MACAddress 'B0:7B:25:1D:9A:62' -Model 'OptiPlex 5080'
	$LFInstallationGuiWindow.ShowDialog()
}





