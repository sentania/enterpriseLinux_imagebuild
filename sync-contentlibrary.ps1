Param(
  [string]$vSphereUSERNAME,
  [string]$vSpherePASSWORD
)
Set-PSRepository -Name "PSGallery" -InstallationPolicy "Trusted"
Find-Module "VMware.PowerCLI" | Install-Module -Scope "CurrentUser" -AllowClobber
Import-Module "VMware.PowerCLI"
Set-PowerCLIConfiguration -InvalidCertificateAction Ignore -confirm:$false
$vCenterlist = get-content inputs/vcenterlist.txt

foreach ($vcenter in $vCenterlist)
{
$cisServerConnection = Connect-CisServer -Server $vcenter -User $vSphereUSERNAME -Password $vSpherePASSWORD

$contentlibrarysubscribedService = Get-CisService com.vmware.content.subscribed_library
foreach ($library in $contentlibrarysubscribedService.list() )
{
  $libraryID =  $library.value
  $contentlibrarysubscribedService.sync($libraryID)
}

Disconnect-CisServer -Server $cisServerConnection -Confirm:$false
}
