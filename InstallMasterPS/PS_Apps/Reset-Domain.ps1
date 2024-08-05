param
(
	[Parameter(Mandatory = $false)]
	[string]$RootPath = $PSScriptRoot
)


Add-Type -AssemblyName PresentationFramework #GUI Framework

[void][System.Reflection.Assembly]::LoadWithPartialName('Microsoft.VisualBasic') #input box assembly

Import-Module -Name "$RootPath\InstallOS-Module.psm1" -Force #Importing Module

$CheckStatus = (Get-WmiObject -Class Win32_ComputerSystem).PartofDomain
switch ($CheckStatus)
{
	$true {
		if (!($env:COMPUTERNAME -match $SystemNamePattern))
		{
			$JoinDomainCred = Get-UserStoredProc -PS_UserID 'U1155296'
			$JoinDomainCred | Export-Clixml -Path "$env:TEMP\JoinDomainCred.xml"
			$DomainName = (Get-WmiObject -Class Win32_ComputerSystem).Domain
			$RemoveDomainMessageBoxReply = $WshObject.Popup("Remove Computer from $($DomainName)?", 120, "Reset Domain", 4 + 32)
			if ($RemoveDomainMessageBoxReply -eq 6)
			{
				@"
if (`$(Get-WmiObject -Class Win32_ComputerSystem).PartofDomain -eq `$false)
			{
				`$JoinDomainCred = Import-Clixml -Path "`$env:TEMP\JoinDomainCred.xml"
				`$WorkgroupName = (Get-WmiObject -Class Win32_ComputerSystem).Workgoup
				Add-Computer -Credential `$JoinDomainCred -DomainName `$WorkgroupName -Force -Verbose
				Autologin-Windows -DefaultDomainName `$WorkgroupName
				`$RemoveDomainMessageBoxReply = `$WshObject.Popup("Remove Network Cable Now and Connect back on Login Screen", 120, "Reset Domain", 0 + 48)
				Restart-Computer -Force -TimeoutSec 5
			}
"@ | Out-File -Encoding ascii -FilePath "$env:TEMP\JoinDomain.ps1"
				@"
Powershell.exe -NoProfile -ExecutionPolicy Bypass -Command $env:TEMP\JoinDomain.ps1
"@ | Out-File -Encoding ascii -FilePath "$env:TEMP\JoinDomain.cmd"
				try
				{
					Write-Output "Removing Computer from Domain"
					Remove-Computer -UnjoinDomainCredential $JoinDomainCred -WorkgroupName $DomainName -Verbose -Force
					Write-Output "Adding startup file at next Startup"
					Autologin-Windows -StartupFilePath $env:TEMP\JoinDomain.cmd
					Write-Output "Restarting Computer Now"
					Restart-Computer -Verbose -Force -TimeoutSec 5
				}
				catch
				{
					Write-Warning $_.Exception
					throw
				}
			}
			else
			{
				$SysNamePatterErrorMsgBox = $WshObject.Popup("$($env:COMPUTERNAME) Name is not in Correct Patter. Please Continue Manually", 0, "Reset Domain", 0 + 16)
				Start-Process sysdm.cpl -PassThru
				exit
			}
		}
	}
	$false {
		$SysNamePatterErrorMsgBox = $WshObject.Popup("$($env:COMPUTERNAME) is already not under domain. Please Continue Manually", 0, "Reset Domain", 0 + 16)
		Start-Process sysdm.cpl -PassThru
		exit
	}	
}