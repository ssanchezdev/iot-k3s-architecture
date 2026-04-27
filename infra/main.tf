# Nombre de la máquina base limpia
variable "base_vm_name" {
  description = "Nombre de la VM"
  default     = "Ubuntu-Base" # <-- Se llama así mi VM
}

# Topología de clúster
variable "cluster_nodes" {
  type = map(object({
    cpus   = number
    memory = number
  }))
  default = {
    "k3s-master"   = { cpus = 2, memory = 4096 } # 4GB RAM cerebro
    "k3s-worker-1" = { cpus = 2, memory = 3072 } # 3GB RAM worker 1
    "k3s-worker-2" = { cpus = 2, memory = 3072 } # 3GB RAM worker 2
  }
}

# Recurso que clona, configura y enciende las máquinas
resource "null_resource" "vbox_cluster" {
  for_each = var.cluster_nodes

  # Disparador: Si cambiamos algo en la variable, se re-ejecuta
  triggers = {
    node_name = each.key
  }

  # Bloque de Creación
  provisioner "local-exec" {
    interpreter = ["bash", "-c"]
    command     = <<-EOT
      echo "Clonando ${each.key}..."
      "O:/VM/VBoxManage.exe" clonevm "${var.base_vm_name}" --name "${each.key}" --register
      
      echo "Asignando hardware..."
      "O:/VM/VBoxManage.exe" modifyvm "${each.key}" --cpus ${each.value.cpus} --memory ${each.value.memory}
      
      echo "Encendiendo ${each.key}..."
      "O:/VM/VBoxManage.exe" startvm "${each.key}" --type headless
    EOT
  }

  # Bloque de Destrucción
  provisioner "local-exec" {
    when        = destroy
    interpreter = ["bash", "-c"]
    command     = <<-EOT
      echo "Destruyendo ${each.key}..."
      "O:/VM/VBoxManage.exe" controlvm "${each.key}" poweroff || true
      sleep 2
      "O:/VM/VBoxManage.exe" unregistervm "${each.key}" --delete || true
    EOT
  }
}
