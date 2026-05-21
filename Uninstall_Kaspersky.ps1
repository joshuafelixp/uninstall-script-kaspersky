# =============================================
# Kaspersky Endpoint Security Uninstall Script 
# for Windows Endpoint
# =============================================

# =============================================
# CREDENTIAL UNINSTALL KASPERSKY
# =============================================
$Username = "" # KES username
$PassKES = "" # KES password
$PassNET = "" # KSCNA password
# =============================================
# CREDENTIAL UNINSTALL KASPERSKY
# =============================================

# =============================================
# LOGGING
# =============================================
$Timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$Computer = $env:COMPUTERNAME

# PATH Log
$LogFolder = "C:\temp\KES_Uninstall"

if (!(Test-Path $LogFolder)) {
    New-Item -Path $LogFolder -ItemType Directory -Force
} 

# Location Log
$LogFile = "$LogFolder\${Computer}_Kaspersky_Uninstall_${Timestamp}.log"
$LogMSIKES = "$LogFolder\${Computer}_KES_MSI_${Timestamp}.log"
$LogMSINET = "$LogFolder\${Computer}_NET_MSI_${Timestamp}.log"

# Logging Function
function Write-Log {
    param(
        [ValidateSet("INFO", "WARNING", "ERROR", "SUCCESS")]
        [string]$Level = "INFO",
        [string]$Message
    )
    Add-Content $LogFile "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] [$Level] $Message"
}
# =============================================
# LOGGING
# =============================================

# =============================================
# UNINSTALL FUNCTIONS
# =============================================
function Uninstall-KES {
    try {
        Write-Log "INFO" "KES - Searching for GUID"
        $GUID = (Get-CimInstance Win32_Product | Where-Object {
                $_.Name -like "*Kaspersky Endpoint Security*"
            }).IdentifyingNumber
        if ($GUID) {
            Write-Log "SUCCESS" "KES - Found GUID: ${GUID}"
            Write-Log "INFO" "KES - Starting uninstall KES"
            #Delete KLUNINSTPASSWD if doesn't use password for uninstalling
            $Process = Start-Process msiexec.exe -Wait -PassThru -ArgumentList `
                "/x $GUID SKIPPRODUCTCHECK=1 KLLOGIN=$Username KLUNINSTPASSWD=$PassKES /qn /norestart /L*v $LogMSIKES"
            Write-Log "INFO" "KES - MSI uninstall process finished"
            Write-Log "INFO" "KES - MSI Exit Code: $($Process.ExitCode)"
            switch ($Process.ExitCode) {

                0 {
                    Write-Log "SUCCESS" "KES uninstall completed successfully"
                }

                3010 {
                    Write-Log "WARNING" "KES uninstall completed. Restart required"
                }

                default {
                    Write-Log  "ERROR" "KES uninstall failed with exit code: $($Process.ExitCode)"
                }
            }
        }
        else {
            Write-Log "WARNING" "KES - GUID KES not found"
        }
    }
    catch {
        Write-Log "ERROR" "KES - Error during uninstall process"
        Write-Log "ERROR" "KES - $($_.Exception.Message)"
    }
}

function Convert-PassNET {
    param([string]$Password)
    $hex = ""
    foreach ($char in $Password.ToCharArray()) {
        $hex += "{0:X2}00" -f [int][char]$char
    }
    return $hex
}

function Uninstall-NET {
    try {
        Write-Log "INFO" "NET - Searching for GUID"
        $GUID = (Get-CimInstance Win32_Product | Where-Object {
                $_.Name -like "*Kaspersky Security Center Network Agent*"
            }).IdentifyingNumber
        if ($GUID) {
            Write-Log "SUCCESS" "NET - Found GUID: ${GUID}"
            Write-Log "INFO" "NET - Starting uninstall NET"
            #Delete PassHex and KLUNINSTPASSWD if doesn't use password for uninstalling
            $PassHex = Convert-PassNET -Password $PassNET
            $Process = Start-Process msiexec.exe -Wait -PassThru -ArgumentList `
                "/x $GUID KLUNINSTPASSWD=$PassHex /qn /norestart /L*v $LogMSINET"
            Write-Log "INFO" "NET - MSI uninstall process finished"
            Write-Log "INFO" "NET - MSI Exit Code: $($Process.ExitCode)"
            switch ($Process.ExitCode) {

                0 {
                    Write-Log "SUCCESS" "NET - uninstall completed successfully"
                }

                3010 {
                    Write-Log "WARNING" "NET - uninstall completed. Restart required"
                }

                default {
                    Write-Log  "ERROR" "NET - uninstall failed with exit code: $($Process.ExitCode)"
                }
            }
        }
        else {
            Write-Log "WARNING" "NET - GUID NET not found"
        }
    }
    catch {
        Write-Log "ERROR" "NET - Error during uninstall process"
        Write-Log "ERROR" "NET - $($_.Exception.Message)"
    }
}
# =============================================
# UNINSTALL FUNCTIONS
# =============================================

# =============================================
# MAIN
# =============================================
Write-Log "INFO" "Script started"
Write-Log "INFO" "Trying to uninstall KES"
Uninstall-KES
Write-Log "INFO" "Trying to uninstall NET"
Uninstall-NET
Write-Log "INFO" "Checking for KES is still exist"
$GUIDKES = (Get-CimInstance Win32_Product | Where-Object {
        $_.Name -like "*Kaspersky Endpoint Security*"
    }).IdentifyingNumber
if ($GUIDKES) {
    Write-Log "WARNING" "KES is still exist"
}
else {
    Write-Log "SUCCESS" "KES is not found or already uninstall"
}
Write-Log "INFO" "Checking for NET is still exist"
$GUIDNET = (Get-CimInstance Win32_Product | Where-Object {
        $_.Name -like "*Kaspersky Security Center Network Agent*"
    }).IdentifyingNumber
if ($GUIDNET) {
    Write-Log "WARNING" "NET is still exist"
}
else {
    Write-Log "SUCCESS" "NET is not found or already uninstall"
}
Write-Log "INFO" "Script finished"
# =============================================
# MAIN
# =============================================