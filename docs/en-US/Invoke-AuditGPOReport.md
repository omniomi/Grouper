---
external help file: Grouper-help.xml
Module Name: Grouper
online version: 
schema: 2.0.0
---

# Invoke-AuditGpoReport

## SYNOPSIS
Consumes a Get-GPOReport XML formatted report and outputs potentially vulnerable settings.

## SYNTAX

### NoArgs (Default)
```
Invoke-AuditGpoReport [<CommonParameters>]
```

### OnlineDomain
```
Invoke-AuditGpoReport [-Path <FileInfo>] [-showDisabled] [-level <Int32>] [-online] [-domain <String>]
 [<CommonParameters>]
```

### WithFile
```
Invoke-AuditGpoReport -Path <FileInfo> [-showDisabled] [-level <Int32>] [<CommonParameters>]
```

### WithoutFile
```
Invoke-AuditGpoReport [-showDisabled] [-level <Int32>] [<CommonParameters>]
```

## DESCRIPTION
GPP cpassword decryption function stolen shamelessly from @harmj0y
Other small snippets and ideas stolen shamelessly from @sysop_host

## EXAMPLES

### -------------------------- EXAMPLE 1 --------------------------
```
PS C:\> Get-GPOReport -All -ReportType XML -Path C:\temp\gporeport.xml
PS C:\> Invoke-AuditGPOReport -Path C:\temp\gporeport.xml
```

## PARAMETERS

### -Path
Path to XML GPO report

```yaml
Type: FileInfo
Parameter Sets: OnlineDomain
Aliases: 

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

```yaml
Type: FileInfo
Parameter Sets: WithFile
Aliases: 

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -domain
FQDN for the domain to target for online checks

```yaml
Type: String
Parameter Sets: OnlineDomain
Aliases: 

Required: False
Position: Named
Default value: $env:UserDomain
Accept pipeline input: False
Accept wildcard characters: False
```

### -level
Set verbosity level (1 = most verbose, 3 = only show things that are definitely bad)

```yaml
Type: Int32
Parameter Sets: OnlineDomain, WithFile, WithoutFile
Aliases: 
Accepted values: 1, 2, 3

Required: False
Position: Named
Default value: 2
Accept pipeline input: False
Accept wildcard characters: False
```

### -online
Perform online checks by actively contacting DCs within the target domain

```yaml
Type: SwitchParameter
Parameter Sets: OnlineDomain
Aliases: 

Required: True
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -showDisabled
Toggle filtering GPOs that aren't linked anywhere

```yaml
Type: SwitchParameter
Parameter Sets: OnlineDomain, WithFile, WithoutFile
Aliases: 

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS

