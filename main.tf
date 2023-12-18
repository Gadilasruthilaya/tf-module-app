resource "aws_instance" "test" {
  provisioner "local-exec" {
    command= "command from - ${var.env}"
  }
}