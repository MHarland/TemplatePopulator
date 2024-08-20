variable "project_name" {
  type = string
}

variable "env_name" {
  type = string
}

variable "rg_name" {
  type = string
}

variable "subscription_id" {
  type = string
}

variable "devops_rg" {
  type = string
}

variable "tenant_id" {
  type = string
}

variable "vnet_name" {
  type = string
}

variable "owners_entra_object_ids" {
  type = list(string)
}

variable "devops_vm_name" {
  type = string
}

variable "devops_vm_computer_name" {
  type = string
}

variable "devops_vm_username" {
  type = string
}

variable "devops_vm_ssh_pub_key_path" {
  type = string
}

variable "vnet_address_space" {
  type = list(string)
}

variable "vnet_subnet_prefixes" {
  type = list(string)
}

variable "vnet_subnet_gate_prefixes" {
  type = list(string)
}

variable "sta_tf_state_name" {
  type = string
}

variable "rg_tf_state_name" {
  type = string
}

variable "devops_sp_app_name" {
  type = string
}

variable "vnet_subnet_name" {
  type = string
}
