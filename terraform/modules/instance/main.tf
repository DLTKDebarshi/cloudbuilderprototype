# Instance Module - Following your GitHub repository style

# Data source to get latest Windows Server AMI
data "aws_ami" "windows" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["Windows_Server-2022-English-Full-Base-*"]
  }
}

resource "aws_instance" "this" {
  ami                         = data.aws_ami.windows.id
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = var.security_group_ids
  user_data                   = var.user_data
  user_data_replace_on_change = true
  key_name                    = var.key_name

  tags = merge(var.tags, {
    Name         = var.name
    UserDataHash = var.user_data != null && var.user_data != "" ? substr(sha256(var.user_data), 0, 8) : "no-userdata"
  })
}
