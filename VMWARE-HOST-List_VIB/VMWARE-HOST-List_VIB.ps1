﻿<#
.DESCRIPTION
This Script retrieve the VIB information on all the VMware Host
.EXAMPLE
	VMWARE-HOST-List_VIB.ps1 -credential (Get-Credential) -vcenter vc01.fx.lab -AllVib
.EXAMPLE
	VMWARE-HOST-List_VIB.ps1 -credential (Get-Credential) -vcenter vc01.fx.lab -VibName "net-e1000e" -Verbose
.EXAMPLE
	VMWARE-HOST-List_VIB.ps1 -credential (Get-Credential) -vcenter vc01.fx.lab -VibVendor "Dell" -Verbose
#>
#Requires -PSSnapin VMware.VimAutomation.Core
[CmdletBinding(DefaultParameterSetName="All")]
PARAM (
	[parameter(Mandatory = $true)]
	$Credential,
	[parameter(Mandatory = $true)]
	$Vcenter,
	[Parameter(ParameterSetName = "All")]
	[Switch]$AllVib,
	[Parameter(ParameterSetName = "VIBName")]
	$VibName,
	[Parameter(ParameterSetName = "VIBVendor")]
	$VibVendor
)
BEGIN
{
	TRY
	{
		# Connect to Vcenter Server
		Connect-ViServer $Vcenter -Credential $Credential -ErrorAction Stop
	}
	CATCH
	{
		Write-Warning -Message "Can't Connect to the Vcenter Server $vcenter"
		Write-Warning -Message $Error[0].Exception.Message
	}
}
PROCESS
{
	TRY
	{
		$VMHosts = Get-VMHost -ErrorAction Stop -ErrorVariable ErrorGetVMhost | Where-Object { $_.ConnectionState -eq "Connected" }
		
		IF ($PSBoundParameters['AllVib'])
		{
			Foreach ($CurrentVMhost in $VMHosts)
			{
				TRY
				{
					# Exposes the ESX CLI functionality of the current host
					$ESXCLI = Get-EsxCli -VMHost $CurrentVMhost.name
					# Retrieve Vibs
					$ESXCLI.software.vib.list() |
					ForEach-Object {
						$VIB = $_
						$Prop = [ordered]@{
							'VMhost' = $CurrentVMhost.Name
							'ID' = $VIB.ID
							'Name' = $VIB.Name
							'Vendor' = $VIB.Vendor
							'Version' = $VIB.Version
							'Status' = $VIB.Status
							'ReleaseDate' = $VIB.ReleaseDate
							'InstallDate' = $VIB.InstallDate
							'AcceptanceLevel' = $VIB.AcceptanceLevel
						}#$Prop
						
						# Output Current Object
						New-Object PSobject -Property $Prop
					}#FOREACH
				}#TRY
				CATCH
				{
					Write-Warning -Message "Something wrong happened with $($CurrentVMhost.name)"
					Write-Warning -Message $Error[0].Exception.Message
				}
			}
		}
		IF ($PSBoundParameters['VibVendor'])
		{
			Foreach ($CurrentVMhost in $VMHosts)
			{
				TRY
				{
					# Exposes the ESX CLI functionality of the current host
					$ESXCLI = Get-EsxCli -VMHost $CurrentVMhost.name
					# Retrieve Vib from vendor $vibvendor
					$ESXCLI.software.vib.list() | Where-object { $_.Vendor -eq $VibVendor } |
					ForEach-Object
					{
						$VIB = $_
						$Prop = [ordered]@{
							'VMhost' = $CurrentVMhost.Name
							'ID' = $VIB.ID
							'Name' = $VIB.Name
							'Vendor' = $VIB.Vendor
							'Version' = $VIB.Version
							'Status' = $VIB.Status
							'ReleaseDate' = $VIB.ReleaseDate
							'InstallDate' = $VIB.InstallDate
							'AcceptanceLevel' = $VIB.AcceptanceLevel
						}#$Prop
						
						# Output Current Object
						New-Object PSobject -Property $Prop
					}#FOREACH
				}#TRY
				CATCH
				{
					Write-Warning -Message "Something wrong happened with $($CurrentVMhost.name)"
					Write-Warning -Message $Error[0].Exception.Message
				}
			}
		}
		IF ($PSBoundParameters['VibName'])
		{
			Foreach ($CurrentVMhost in $VMHosts)
			{
				TRY
				{
					# Exposes the ESX CLI functionality of the current host
					$ESXCLI = Get-EsxCli -VMHost $CurrentVMhost.name
					# Retrieve Vib with name $vibname
					$ESXCLI.software.vib.list() | Where-object { $_.Name -eq $VibName } |
					ForEach-Object
					{
						$VIB = $_
						$Prop = [ordered]@{
							'VMhost' = $CurrentVMhost.Name
							'ID' = $VIB.ID
							'Name' = $VIB.Name
							'Vendor' = $VIB.Vendor
							'Version' = $VIB.Version
							'Status' = $VIB.Status
							'ReleaseDate' = $VIB.ReleaseDate
							'InstallDate' = $VIB.InstallDate
							'AcceptanceLevel' = $VIB.AcceptanceLevel
						}#$Prop
						
						# Output Current Object
						New-Object PSobject -Property $Prop
					}#FOREACH
				}#TRY
				CATCH
				{
					Write-Warning -Message "Something wrong happened with $($CurrentVMhost.name)"
					Write-Warning -Message $Error[0].Exception.Message
				}
			}
		}
	}
	CATCH
	{
		Write-Warning -Message "Something wrong happened in the script"
		IF ($ErrorGetVMhost) { Write-Warning -Message "Couldn't retrieve VMhosts" }
		Write-Warning -Message $Error[0].Exception.Message
	}
}