Param(
  [string]$outputdir,
  [string]$BUILD_TAG,
  [string]$GIT_BRANCH,
  [string]$vSphereUSERNAME,
  [string]$vSpherePASSWORD
)

#Because linux powercli doesn't have all the same modules we need to import a bit more carefully:
Import-Module VMware.VimAutomation.Core
Import-Module VMware.VimAutomation.Vds
Set-PowerCLIConfiguration -InvalidCertificateAction Ignore -Confirm:$false

$GIT_BRANCH = $GIT_BRANCH.split("/")[1]

Write-Host "Beginning upload to vcenter."
Write-Host "outputdir: $outputdir"
Write-Host "build_tag: $BUILD_TAG"
Write-Host "git_branch: $GIT_BRANCH"
Write-Host "user: $vSphereUSERNAME"


#Upload to Lab vCenter
$vCenterServerList = "vcenter.int.sentania.net"
$datastore = "ntx-iso"
$targetCluster = "ntnxlab"


$builtImages = Get-ChildItem $Outputdir -Filter *.ova -Recurse

foreach ($vcenter in $vcenterServerList)
{

write-host "Connecting to vCenter $vCenter"

try {
    $viConnection = connect-viserver -Server $vcenter -User $vSphereUSERNAME -Password $vSpherePASSWORD -ErrorAction Stop
}
catch {
    write-host "Failed to connect to vCenter $vcenter."
}

try {
    write-host "Locating required resources..."
    $templatesFolder = get-folder -name "Templates" -Server $viConnection -ErrorAction Stop
    Write-host "Templates Folder: $templatesFolder"
    $dsobj = Get-Datastore -Name $datastore -Server $viConnection -ErrorAction Stop
    Write-host "Datastore: $dsobj"
    $vmhost = get-cluster -Server $viConnection -name $targetCluster -ErrorAction Stop |  Get-VMHost -Server $viConnection -ErrorAction Stop | where {$_.ConnectionState -eq "Connected"}| Get-Random -Count 1
    Write-host "VMware Host: $vmhost"
}
catch {
    Write-host "Unable to locate required compute resources"
}


foreach ($image in $builtImages)
{

    Write-host "Deploying $image..."
    $VMName = $image.name.split(".")[0] + $BUILD_TAG
    $thisTemplateName = $image.name.split(".")[0] + "-" + $vcenter.Split(".")[0] + "-" + $:GIT_BRANCH

    $ovfConfig = Get-OvfConfiguration $image.fullname
    $vdPortGroup = Get-VDPortgroup -Server $viConnection "VM Network"
    $ovfConfig.NetworkMapping.nat.Value = $vdPortGroup

    $vm = Import-VApp -Server $viConnection -Source $image.fullname -InventoryLocation $templatesFolder -Name $VMName -VMHost $vmhost -Datastore $datastore -DiskStorageFormat thin -OvfConfiguration $ovfConfig
    $vm | set-vm -Description "$VMName $BUILD_TAG" -Confirm:$false

    #remove the old template
    $vmtemplates = Get-Template -Server $viConnection -ErrorAction SilentlyContinue | where {$_.name -like "*$thisTemplateName*"}
    foreach ($template in $vmtemplates)
    {
         Remove-Template -Server $viConnection -Template $template -Confirm:$false -ErrorAction SilentlyContinue
    }
    $vm | Set-vm -Server $viConnection -toTemplate -Name $thisTemplateName -Confirm:$false
}
Disconnect-VIServer $viConnection -Force -Confirm:$false
}
