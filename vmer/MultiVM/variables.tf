variable "network_details"{
    description = "Detaljer om nettverket"
    default={
        network_name="fdlab-network"
        network_address_space="10.0.0.0/16"
        vm_subnet_name="fdsubnetlab01"
       vm_subnet_adress_space="10.0.0.0/16"
    }
}
variable "vm_details"{
  description = "Detaljer om maskiner"
    default={
        vmnames = ["fdvm"]
}
}
