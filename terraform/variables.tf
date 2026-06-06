variable "tenancy_ocid" {
  description = "OCID del tenancy. Oracle Cloud → Profile → Tenancy"
}

variable "user_ocid" {
  description = "OCID del usuario. Oracle Cloud → Profile → User Settings"
}

variable "fingerprint" {
  description = "Fingerprint de la API key. Oracle Cloud → Profile → API Keys"
}

variable "private_key_path" {
  description = "Ruta local al archivo .pem de la API key de OCI"
  default     = "~/.oci/oci_api_key.pem"
}

variable "region" {
  description = "Región de OCI. Ej: sa-saopaulo-1, us-ashburn-1"
  default     = "sa-saopaulo-1"
}

variable "compartment_ocid" {
  description = "OCID del compartment. Usar el mismo OCID del tenancy para la cuenta raíz"
}

variable "ssh_public_key" {
  description = "Clave SSH pública para acceder a la VM. Contenido de ~/.ssh/id_rsa.pub"
}

variable "instance_name" {
  description = "Nombre de la VM"
  default     = "k3s-server"
}

variable "availability_domain_index" {
  description = "Índice del availability domain (0, 1 o 2 según la región)"
  default     = 0
}
