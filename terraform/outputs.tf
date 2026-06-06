output "instance_public_ip" {
  value       = oci_core_instance.k3s_server.public_ip
  description = "IP pública de la VM"
}

output "ssh_command" {
  value       = "ssh ubuntu@${oci_core_instance.k3s_server.public_ip}"
  description = "Comando SSH para conectarse a la VM"
}

output "kubeconfig_command" {
  value       = <<-EOT
    # Exportar kubeconfig desde la VM (ejecutar localmente):
    scp ubuntu@${oci_core_instance.k3s_server.public_ip}:/etc/rancher/k3s/k3s.yaml ~/.kube/config
    sed -i 's/127.0.0.1/${oci_core_instance.k3s_server.public_ip}/g' ~/.kube/config
    chmod 600 ~/.kube/config

    # Generar secret para GitHub Actions:
    cat ~/.kube/config | base64 -w 0
  EOT
  description = "Pasos para obtener el kubeconfig y generar el secret KUBE_CONFIG"
}
