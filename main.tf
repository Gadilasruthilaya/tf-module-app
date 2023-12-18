resource "null_resource" "test" {
  triggers = {
    xyz=timestamp()
  }
  provisioner "local-exec" {
    command= " echo command from - Env- ${var.env}"
  }
}