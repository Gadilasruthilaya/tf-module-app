resource "null_resource" "test" {
  triggers = {
    xyz=timestamp()
  }
  provisioner "local-exec" {
    command= "command from - ${var.env}"
  }
}