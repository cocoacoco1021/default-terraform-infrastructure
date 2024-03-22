# ---------------------------------------------
# key pair
# ---------------------------------------------
resource "aws_key_pair" "keypair" {
  key_name   = "hulu-prod_keypair"
  public_key = file("./key/hulu-prod_keypair.pub")
  tags = {
    Name = "hulu-prod_keypair"
  }
}

resource "aws_instance" "ec2" {
  ami                         = "ami-0f36dcfcc94112ea1"
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.public_subnet_1a.id
  associate_public_ip_address = true
  vpc_security_group_ids = [
    aws_security_group.web_sg.id
  ]
  key_name = aws_key_pair.keypair.key_name

  tags = {
    Name    = "${var.project}-${var.environment}-wd01"
    Project = var.project
    Env     = var.environment
    Type    = "ec2"
  }
}

#resource "aws_instance" "ec2-multiple" {
#  count                       = 2
#  ami                         = "ami-0f36dcfcc94112ea1"
#  instance_type               = "t2.micro"
#  subnet_id                   = aws_subnet.public_subnet_1a.id
#  associate_public_ip_address = true
#  vpc_security_group_ids = [
#    aws_security_group.web_sg.id
#  ]
#  key_name = aws_key_pair.keypair.key_name
#
#  tags = {
#    Name    = "${format("${var.project}-${var.environment}%02d", count.index + 1)}"
#    Project = var.project
#    Env     = var.environment
#    Type    = "ec2-multiple"
#  } 
#}
