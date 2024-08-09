BEGIN
{
	Add-Type -AssemblyName PresentationFramework #GUI Framework
	
	[void][System.Reflection.Assembly]::LoadWithPartialName('Microsoft.VisualBasic') #input box assembly
	
	#$UserName = [Microsoft.VisualBasic.Interaction]::InputBox('Enter Tawasul User Name', 'User Name Input', 'U')
	
	[string]$RequiredInfo = $null
	[string]$SerialNumber = $null	
	[string]$MacAddress = $null
	[string]$ModelNumber = $null
	
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
	
	#region MainFrm_OnLoad
	$var_MainFrm.Add_Loaded({
			$var_User_lbl.Content = $UserName #Setting Form Title as UserName
			$var_CN_txt.Content = "W-ZMC-GRF-0000"
		})
	#endregion MainFrm_OnLoad
	
}
PROCESS
{
	
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
	$var_Parse_btn.Add_Click({
			Write-Host "Processing"
			#Write-Host $var_Comp_Details.Text
			#$var_Comp_Details.Text
<#			[array]$Arra1 = $null
			$ParseTextBox = $($var_Comp_Details.Text) #$($var_Comp_Details.Text).Split([Environment]::NewLine)
			$Arra1 = $ParseTextBox.Split(" ")
			#[array]$ParseTextBox1 = $ParseTextBox.Split(" ")
			Write-Host $Arra1[0]
			$$`#>
			
			$myTextBox = New-Object System.Windows.Controls.TextBox
			$myTextBox.Text = "$SerialNumber `r`n $MacAddress `r`n $ModelNumber `r`n"
			Write-Host $myTextBox.Text
			
			exit
			
			$SerialNumber = $ParseTextBox[0]			
			$MacAddress = $ParseTextBox[3]
			$ModelNumber = $ParseTextBox[4]
			
			Write-Host $SerialNumber
			Write-Host $MacAddress
			Write-Host $ModelNumber
			
			$CN = Get-WSCN -SerialNumber $SerialNumber -MACAddress $MacAddress -Model $ModelNumber
			$CN
			$TextFileConent = "$SerialNumber `r`n $MacAddress `r`n $ModelNumber `r`n"
			$desktopPath = [Environment]::GetFolderPath('Desktop')
			$configFilePath = Join-Path -Path $desktopPath -ChildPath "$SerialNumber.txt"
			Set-Content -Path $configFilePath -Value $TextFileConent			
		})
	
	<#$var_Parse_btn.Add_Click({
			
			
			
			
		})#>
}

END
{
	#$CN = Get-WSCN -SerialNumber '35DVVD3' -MACAddress 'B0:7B:25:1D:9A:62' -Model 'OptiPlex 5080'
	$LFInstallationGuiWindow.ShowDialog()
}





