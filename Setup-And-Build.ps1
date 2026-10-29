Install-Module -Name ps2exe -Scope CurrentUser -Force -SkipPublisherCheck
Invoke-ps2exe .\Choose-JetBrainsIDE.ps1 .\Choose-JetBrainsIDE.exe -noConsole
