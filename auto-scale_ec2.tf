resource "random_string" "s3_unique_key" {
  length  = 6
  upper   = false
  lower   = true
  number  = true
  special = false
}

# ---------------------------------------------
# S3 static bucket
# ---------------------------------------------
resource "aws_s3_bucket" "s3_static_bucket" {
  bucket = "${var.project}-${var.environment}-static-bucket-${random_string.s3_unique_key.result}"

  versioning {
    enabled = false
  }
}

resource "aws_s3_bucket_public_access_block" "s3_static_bucket" {
  bucket                  = aws_s3_bucket.s3_static_bucket.id
  block_public_acls       = true
  block_public_policy     = true # Create
  ignore_public_acls      = true
  restrict_public_buckets = true # Modify
  #  depends_on = [
  #    aws_s3_bucket_policy.s3_static_bucket,
  #  ]
}

#resource "aws_s3_bucket_policy" "s3_static_bucket" {
#  bucket = aws_s3_bucket.s3_static_bucket.id
#  policy = data.aws_iam_policy_document.s3_static_bucket.json
#}

# data "aws_iam_policy_document" "s3_static_bucket" {
#  statement {
#    effect    = "Allow"
#    actions   = ["s3:GetObject"]
#    resources = ["${aws_s3_bucket.s3_static_bucket.arn}/*"]
#    principals {
#      type        = "AWS"
#      identifiers = [aws_cloudfront_origin_access_identity.cf_s3_origin_access_identity.iam_arn]
#    }
#  }
#}

# ---------------------------------------------
# S3 deploy bucket
# ---------------------------------------------
resource "aws_s3_bucket" "s3_deploy_bucket" {
  bucket = "${var.project}-${var.environment}-deploy-bucket-${random_string.s3_unique_key.result}"

  versioning {
    enabled = false
  }
}

resource "aws_s3_bucket_public_access_block" "s3_deploy_bucket" {
  bucket                  = aws_s3_bucket.s3_deploy_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
  # depends_on = [
  #   aws_s3_bucket_policy.s3_deploy_bucket,
  # ]
}

#resource "aws_s3_bucket_policy" "s3_deploy_bucket" {
#  bucket = aws_s3_bucket.s3_deploy_bucket.id
#  policy = data.aws_iam_policy_document.s3_deploy_bucket.json
#}

#data "aws_iam_policy_document" "s3_deploy_bucket" {
#  statement {
#    effect    = "Allow"
#    actions   = ["s3:GetObject"]
#    resources = ["${aws_s3_bucket.s3_deploy_bucket.arn}/*"]
#    principals {
#      type        = "AWS"
#      identifiers = [aws_iam_role.app_iam_role.arn]
#    }
#  }
#}

# ---------------------------------------------
# launch template
# ---------------------------------------------
resource "aws_launch_template" "app_lt" {
  update_default_version = true

  name = "${var.project}-${var.environment}-app-lt"

  image_id = "ami-023aa337f144bdef1"

  key_name = aws_key_pair.keypair.key_name

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name    = "${var.project}-${var.environment}-app-ec2"
      Project = var.project
      Env     = var.environment
      Type    = "ec2"
    }
  }

  network_interfaces {
    associate_public_ip_address = true
    security_groups = [
      aws_security_group.web_sg.id,
    ]
    delete_on_termination = true
  }

  # iam_instance_profile {
  #   name = ""
  # }

  #  user_data = filebase64("./src/initialize.sh")
}

# ---------------------------------------------
# auto scaling group
# ---------------------------------------------
resource "aws_autoscaling_group" "app_asg" {
  name = "${var.project}-${var.environment}-app-asg"

  max_size         = 1
  min_size         = 1
  desired_capacity = 1

  health_check_grace_period = 300
  health_check_type         = "ELB"

  vpc_zone_identifier = [
    aws_subnet.public_subnet_1a.id,
    aws_subnet.public_subnet_1c.id
  ]

  target_group_arns = [aws_lb_target_group.alb_target_group.arn]

  mixed_instances_policy {
    launch_template {
      launch_template_specification {
        launch_template_id = aws_launch_template.app_lt.id
        version            = "$Latest"
      }

      override {
        instance_type = "t2.micro"
      }
    }
  }
}
