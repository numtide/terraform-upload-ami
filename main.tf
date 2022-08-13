variable "vhd_path" {
  description = "Path to the VHD to upload"
}

variable "bucket_name" {
  description = "Bucket ID where to upload the VHD to"
}

variable "bucket_arn" {
  description = "Bucket ARN"
}

# We assume that the object key changes on each upload
variable "object_key" {
  description = "Name of the key to use in S3"
}

variable "name" {
  description = "Name of the image"
}

variable "tags" {
  description = "AWS Tags to apply on all the objects"
  type        = map(string)
}

locals {
  tags = merge(var.tags, {
    Name = var.name
  })
}

# --------------------------------------------------------------------------

# Upload the image to S3
resource "aws_s3_object" "ami" {
  bucket = var.bucket_name
  source = var.vhd_path
  tags   = local.tags

  # Make it so that the new file can be uploaded before deleting the old one
  key = "${filemd5(var.vhd_path)}/${var.object_key}"
  lifecycle {
    create_before_destroy = true
  }
}

# Create a role that can import EBS snapshots. It's a bit overkill to declare
# that role for each AMIs, but why not?
resource "aws_iam_role" "ami_importer" {
  name = "${var.name}-ami-importer"
  tags = local.tags

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "vmie.amazonaws.com"
        }
        Condition = {
          StringEquals = {
            "sts:Externalid" = "vmimport"
          }
        }
      },
    ]
  })
}

resource "aws_iam_role_policy" "ami_importer" {
  name = "${var.name}-ami-importer"
  role = aws_iam_role.ami_importer.id

  policy = jsonencode({
    "Version" = "2012-10-17",
    "Statement" = [
      {
        "Effect" = "Allow",
        "Action" = [
          "s3:GetBucketLocation",
          "s3:GetObject",
          "s3:ListBucket"
        ],
        "Resource" = [
          var.bucket_arn,
          "${var.bucket_arn}/*"
        ]
      },
      {
        "Effect" = "Allow",
        "Action" = [
          "ec2:ModifySnapshotAttribute",
          "ec2:CopySnapshot",
          "ec2:RegisterImage",
          "ec2:Describe*"
        ],
        "Resource" = "*"
      }
    ]
  })
}

# Convert the image to an EBS snapshot
resource "aws_ebs_snapshot_import" "ami" {
  role_name = aws_iam_role.ami_importer.name
  tags      = local.tags

  disk_container {
    format = "VHD"
    user_bucket {
      s3_bucket = var.bucket_name
      s3_key    = aws_s3_object.ami.key
    }
  }

  lifecycle {
    create_before_destroy = true
  }

  timeouts {
    create = "10m"
  }
}

# Register the snapshot as an AMI
resource "aws_ami" "ami" {
  name                = aws_s3_object.ami.key
  ena_support         = true
  root_device_name    = "/dev/xvda"
  tags                = local.tags
  virtualization_type = "hvm"

  ebs_block_device {
    device_name = "/dev/xvda"
    snapshot_id = aws_ebs_snapshot_import.ami.id
    volume_size = 8
  }

  lifecycle {
    create_before_destroy = true
  }
}

# --------------------------------------------------------------------------

output "ami_id" {
  value = aws_ami.ami.id
}
