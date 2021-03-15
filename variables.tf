variable "m_az_location" {
    type = string
}
variable "m_opt_size" {
    type = number
    default = "14"
}

variable "m_meti_size" {
    type = number
    default = "66"
}

variable "m_optapplog_size" {
    type = number
    default = "20"
}

variable "tags" {
    type = map

    default = {
        Environment = "ARI"
        Billable    = "yes"
    }
}
variable "m_resource_group_name" {
    type = string
}

variable "m_ssh_username" {
    type = string
}

variable "m_public_key"  {
    type = string
}
variable "m_az_project" {
    type        = string
    description = "project to include the resources in"
}

variable "m_source_image" {
    type = string
    description = "value of the image to use for templating"
}

variable "m_az_computer_name" {
    type        = string
    description = "os name for the azure vm" 
}

variable "m_az_admin_password" {
    type        = string
    description = "admin password of the centos az vm"
}

variable "m_az_vm_size" {
    description = "Specifies the size of the virtual machine."
}

variable "m_az_image_publisher" {
  description = "Name of the publisher of the image (az vm image list)"
}

variable "m_az_image_offer" {
  description = "Name of the offer (az vm image list)"
}

variable "m_az_image_sku" {
  description = "Image SKU to apply (az vm image list)"
}

variable "m_az_image_version" {
  description = "Version of the image to apply (az vm image list)"
}

variable "m_az_image_data_disk_size" {
  description = "size of the data disk image in gb"
}

variable "m_az_ssh_allowed_ip" {
    description = "ip address allowed to ssh in the vm"
    type = string
}