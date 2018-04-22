---
Module Name: Grouper
Module Guid: 4eea11ea-5f93-4f09-8e5f-69976481e9e7
Download Help Link:
Help Version: 1.0.0.0
Locale: en-US
---

# Grouper Module
## Description
Grouper is a PowerShell module designed for pentesters and redteamers (although probably also useful for sysadmins) which sifts through the (usually very noisy) XML output from the Get-GPOReport cmdlet (part of Microsoft's Group Policy module) and identifies all the settings defined in Group Policy Objects (GPOs) that might prove useful to someone trying to do something fun/evil.

## Grouper Cmdlets
### [Invoke-AuditGPOReport](Invoke-AuditGPOReport.md)
Consumes a Get-GPOReport XML formatted report and outputs potentially vulnerable settings.

