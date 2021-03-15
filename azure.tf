
locals {
  opt_size = format("${var.m_opt_size}%s", "%")
  meti_size1 = sum([var.m_opt_size,var.m_meti_size])
  meti_size = "${local.meti_size1}%"
}
resource "azurerm_virtual_network" "auchan_vnet" {
    name                    = "${var.m_az_project}-network"
    address_space           = ["10.10.0.0/16"]
    location                = var.m_az_location
    resource_group_name     = var.m_resource_group_name
}

resource "azurerm_subnet" "auchan_subnet" {
    name                    = "auchan_internal_subnet"
    resource_group_name     = var.m_resource_group_name
    virtual_network_name    = azurerm_virtual_network.auchan_vnet.name
    address_prefixes        = ["10.10.10.0/24"]
}

resource "azurerm_public_ip" "auchan_public_ip" {
    name                    = "${var.m_az_project}-public_ip"
    location                = var.m_az_location
    resource_group_name     = var.m_resource_group_name
    allocation_method       = "Static"
}

resource "azurerm_network_interface" "auchan-nic" {
    name                    = "${var.m_az_project}-nic"
    location                = var.m_az_location
    resource_group_name     = var.m_resource_group_name

    ip_configuration {
      name                  = "auchan-ARI-nic-config"
      subnet_id             = azurerm_subnet.auchan_subnet.id
      private_ip_address_allocation = "Dynamic"
      public_ip_address_id  = azurerm_public_ip.auchan_public_ip.id
    }
}

resource "azurerm_network_security_group" "ari-vm-sg" {
  name                           = "${var.m_az_project}-sg"
  location                       = var.m_az_location
  resource_group_name            = var.m_resource_group_name

  security_rule {
    name                         = "SSH"
    description                  = "allows ssh access from knonw IPs only"
    protocol                     = "TCP"
    access                       = "Allow"
    priority                     = 100
    direction                    = "Inbound"
    source_port_range            = "*"
    destination_address_prefix   = "*"
    destination_port_range       = "22"
    source_address_prefix        = var.m_az_ssh_allowed_ip
  }
} 
//data template cloud init to resize disks 
//mount_script4.cfg: takes into account the waiting time for lun to be mounted
//data "template_file" "linux_cloud-init" {
  //  template = file("${path.module}/mount_script4.cfg")
//}


//DEFINITION OF THE RESOURCE WITH AZURERM_LINUX_VIRTUAL_MACHINE
resource "azurerm_linux_virtual_machine" "auchan_vm" {
    name                    = "${var.m_az_project}-vm"
    location                = var.m_az_location
    resource_group_name     = var.m_resource_group_name 
    network_interface_ids   = [ azurerm_network_interface.auchan-nic.id ]
    size                 = var.m_az_vm_size
    source_image_id         = var.m_source_image 
    admin_username = "jerome"
    admin_password = var.m_az_admin_password
    
    boot_diagnostics {
      storage_account_uri = "https://jpapazianstorage.blob.core.windows.net/"
    }
    //custom_data = base64encode(data.template_file.linux_cloud-init.rendered)
    custom_data = base64encode(templatefile("${path.module}/mount_script4.cfg", { opt = local.opt_size, meti = local.meti_size}))
    admin_ssh_key {
        username = var.m_ssh_username
        public_key = var.m_public_key
        }
    os_disk {
        caching             = "ReadWrite"
        storage_account_type   = "Standard_LRS"
    }
//Commented the disk definition in case the image is created from packer with already an attached disk
//data "azurerm_managed_disk" "p6_64_image" {
//    name                    = "auchandatadiskimage"
//    resource_group_name     = var.m_resource_group_name
//}
}

resource "azurerm_managed_disk" "p6_64" {
    name                    = "data_disk1"
    location                = var.m_az_location
    resource_group_name     = var.m_resource_group_name
    storage_account_type    = "Standard_LRS"
    // use create_option = copy in conjunction with data_disk definition above and source_resource_id below. If not, use create_option = empty
    //source_resource_id      = data.azurerm_managed_disk.p6_64_image.id 
    create_option           = "Empty"
    disk_size_gb            = "64"
    }
    

resource "azurerm_virtual_machine_data_disk_attachment" "p6_64" {
    virtual_machine_id      = azurerm_linux_virtual_machine.auchan_vm.id
    managed_disk_id         = azurerm_managed_disk.p6_64.id
    lun                     = "0"
    caching                 = "ReadWrite"
}         //custom_data = data.template_file.linux_cloud-init.rendered

 //  disable_password_authentication = false
   // custom_data = base64encode(data.template_file.linux_cloud-init.rendered)

/*
resource "azurerm_virtual_machine" "auchan_vm" {
    name                    = "${var.m_az_project}-vm"
    location                = var.m_az_location
    resource_group_name     = var.m_resource_group_name
    network_interface_ids   = [ azurerm_network_interface.auchan-nic.id ]
    vm_size                 = var.m_az_vm_size
    delete_os_disk_on_termination = "true"
    delete_data_disks_on_termination = "true"

    storage_os_disk {
      name = "osdisk"
      caching = "ReadWrite"
      create_option = "FromImage"
      managed_disk_type = "Standard_LRS"
    }

    storage_image_reference {
      id = var.m_source_image
    }

    storage_data_disk {
        name                = "${var.m_az_project}-vm-data-disk1"
        caching             = "ReadWrite"
        create_option       = "Empty"
        managed_disk_type   = "Standard_LRS"
        disk_size_gb        = var.m_az_image_data_disk_size
        lun                 = "0"
    }

    os_profile {
        computer_name = "${var.m_az_project}-vm"
        admin_username = "jerome"
        admin_password = var.m_az_admin_password
        custom_data = data.template_file.linux_cloud-init.rendered
    }
    os_profile_linux_config {
        disable_password_authentication = "false"
        ssh_keys {
          key_data = var.m_public_key
          path = "/home/jerome/.ssh/authorized_keys"
        }
    }

    boot_diagnostics {
      enabled = "true"
      storage_uri = "https://jpapazianstorage.blob.core.windows.net/"
    }
}
*/

