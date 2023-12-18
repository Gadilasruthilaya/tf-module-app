resource "null_resource" "test" {
  provisioner "local-exec" {
    command= "command from - ${var.env}"
  }
}