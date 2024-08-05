class NetworkChecker {
	
	[bool] CheckConnectionToHost([string]$hostName) {
		$ping = New-Object System.Net.NetworkInformation.Ping
		$timeout = 1000  # Timeout in milliseconds

		try {
			$pingReply = $ping.Send($hostName, $timeout)
			if ($pingReply.Status -eq 'Success') { return $true } # Connection successful
			else { Write-Output "Failed to connect to $hostName."; return $false }# Connection failed
		}
		catch {
			Write-Output "Failed to connect to $hostName. Error: $_"
			return $false  # Connection failed
		}
	}	
	
	[bool] CheckConnectionWithRetryPrompt([string]$hostName) {
		$retryCount = 0
        
		do {
			$connectionResult = $this.CheckConnectionToHost($hostName)
            
			if ($connectionResult) { return $true } # Connection successful
			
			else {
				$retryCount++
                
				$wshell = New-Object -ComObject WScript.Shell
				$userChoice = $wshell.Popup("Failed to connect to $hostName. Retry?", 0, "Connection Retry", 4)
                
				if ($userChoice -eq 6) { Write-Output "Retrying connection to $hostName..." }
				else {
					Write-Output "User cancelled the retry."
					return $false  # Connection failed after user cancellation
				}
			}
		} while ($retryCount -lt 3)

		# Write-Output "Failed to connect to $hostName after 3 retries."
		return $false  # Connection failed after retries
	}	
}



<#
# Create an instance of the NetworkChecker class
$networkChecker = [NetworkChecker]::new()

# Test connection with retry prompt
$hostToCheck = "155.168.2.255"
$connectionResult = $networkChecker.CheckConnectionWithRetryPrompt($hostToCheck)

if ($connectionResult) { Write-Output "Successfully connected to $hostToCheck." }
else { Write-Output "Failed to connect to $hostToCheck after retries." }
#>