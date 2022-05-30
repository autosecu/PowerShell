#Create VM with specific network config
#Set vars for script
$location = "eastus"
$myResourceGroup = "RG-RedbearLab"
#need to add section to ask for input on RG, VM Name etc..

#Create a new Virtual Network Subnet
$subnet1 = New-AzVirtualNetworkSubnetConfig -Name "mySubnet1" -AddressPrefix 10.1.0.0/24

#New Virtual Network
$vnet = New-AzVirtualNetwork -Name "RBLVNet" -ResourceGroupName $myResourceGroup -Location $location -AddressPrefix 10.1.0.0/16 -Subnet $subnet1

#Get Creds - these are PScreds or anything authenticated.. Used as admin user and password
$creds = Get-Credential


#New Public IP address
$pip = New-AzPublicIpAddress -Name "RBLPublicIp2" -ResourceGroupName $myResourceGroup -Location $location -AllocationMethod Dynamic

#New Network Security rule
$rule1 = New-AzNetworkSecurityRuleConfig -Name rdp-rule -Description "Allow RDP" -Access Allow -Protocol Tcp -Direction Inbound -Priority 100 -SourceAddressPrefix Internet -SourcePortRange * -DestinationAddressPrefix * -DestinationPortRange 3389

#New Network Security group and adding the rules created previously
$nsg1 = New-AzNetworkSecurityGroup -Name "nsg1" -ResourceGroupName $myResourceGroup  -Location  "eastus" -SecurityRules $rule1

#New Azure Network Interface
$rblnic = New-AzNetworkInterface -Name "NetworkInterface2" -ResourceGroupName $myResourceGroup -Location $location -SubnetId $vnet.Subnets[0].Id -PublicIpAddressID $pip.Id -NetworkSecurityGroupId $nsg1.Id

#Create a deployment configuration for a VM with the new network info we made
$rblvmconfig = New-AzVMConfig -VMName RBL1 -VMSize Standard_D2s_v3 | Set-AzVMOperatingSystem -Windows -ComputerName "RBL1" -Credential $creds | Set-AzVMSourceImage -PublisherName MicrosoftWindowsServer -Offer WindowsServer -Skus 2016-Datacenter -Version latest | Add-AzVMNetworkInterface -Id $rblnic.Id

#Create a new VM with the config we made
New-AzVM -ResourceGroupName $myResourceGroup -Location $location $rblvmconfig
