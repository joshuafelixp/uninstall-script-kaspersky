# uninstall-script-kaspersky
Uninstaller script for Kaspesky Endpoint Security and Kaspersky Security Center Network Agent. Can be use with GPO Active Directory.

Pay attentiton to this:
  Open the script and edit with notepad or any IDE.
  If your KES protected with uninstall password, fill the $Username and $PassKES with the correct credential.
  If not, you can fill blank $Username & $PassKES and make sure to delete KLUNINSTPASSWD parameter in KES msiexec script.
  If your Network Agent is potected with uninstall password, fill the $PassNET with correct password.
  If not, you can fill black the $PassNET and make sure to delete KLUNINSTPASSWD parameter in NET msiexec script.

A. Direct run script using Powershell
  1. Open Powershell with admin privilege.
  2. Type in and press enter:
     Set-ExecutionPolicy Bypass -Scope Process -Force
  3. Locate the script directory and use 'cd' to move directory to script location.
  4. Run the script with .\Uninstall_Kaspersky.ps1
  5. Wait for the uninstalling process.
  6. After it's finished, you can check log file in C:\temp\KES_Uninstall folder.

B. Running script with GPO Active Directory
  1. Copy the script network shared folder that server and client device can access.
     example store script in SYSVOL: \\domain.local\SYSVOL\domain.local\scripts\Uninstall_Kaspersky.ps1
  2. Create new GPO and link to OU (All computers you want to uninstall Kaspersky).
  3. Enable Powershell Execution.
     Locate Computer Configuration.
     → Policies
     → Administrative Templates
     → Windows Components
     → Windows PowerShell
     Enable Turn on Script Execution.
     Choose Allow all scripts.
  4. Add startup script.
     Locate Computer Configuration.
     → Policies
     → Windows Settings
     → Scripts (Startup/Shutdown)
     → Startup
     Choose Powershell script tab.
     Add the script you've already copied.
     On script parameter, fill in "-ExecutionPolicy Bypass -File path/to/file/Uninstall_Kaspersky.ps1
  5. Wait for policy to update in client device, or you can run gpupdate /force in client device to force policy update.
  6. Script will running when user turn on the device.
  7. You can check log file in C:\temp\KES_Uninstall folder.

  
