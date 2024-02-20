resource "aws_instance" "this" {
  ami           = var.ami_id
  instance_type = var.instance_type

  associate_public_ip_address = var.associate_public_ip_address
  ebs_optimized               = var.ebs_optimized
  key_name                    = var.key_name
  source_dest_check           = var.source_dest_check
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = var.vpc_security_group_ids

  iam_instance_profile = var.required_iam_role ? aws_iam_instance_profile.this[0].name : var.iam_instance_profile != null ? var.iam_instance_profile : null

  user_data        = var.user_data
  user_data_base64 = var.user_data_base64

  dynamic "root_block_device" {
    for_each = var.root_block_device
    content {
      delete_on_termination = lookup(root_block_device.value, "delete_on_termination", null)
      encrypted             = lookup(root_block_device.value, "encrypted", null)
      iops                  = lookup(root_block_device.value, "iops", null)
      kms_key_id            = lookup(root_block_device.value, "kms_key_id", null)
      volume_size           = lookup(root_block_device.value, "volume_size", null)
      volume_type           = lookup(root_block_device.value, "volume_type", null)
      throughput            = lookup(root_block_device.value, "throughput", null)
      tags                  = lookup(root_block_device.value, "tags", null)
    }
  }

  dynamic "ebs_block_device" {
    for_each = var.ebs_block_device
    content {
      delete_on_termination = lookup(ebs_block_device.value, "delete_on_termination", null)
      device_name           = ebs_block_device.value.device_name
      encrypted             = lookup(ebs_block_device.value, "encrypted", null)
      iops                  = lookup(ebs_block_device.value, "iops", null)
      kms_key_id            = lookup(ebs_block_device.value, "kms_key_id", null)
      snapshot_id           = lookup(ebs_block_device.value, "snapshot_id", null)
      volume_size           = lookup(ebs_block_device.value, "volume_size", null)
      volume_type           = lookup(ebs_block_device.value, "volume_type", null)
      throughput            = lookup(ebs_block_device.value, "throughput", null)
    }
  }

  dynamic "metadata_options" {
    for_each = var.metadata_options != null ? [var.metadata_options] : []
    content {
      http_endpoint               = lookup(metadata_options.value, "http_endpoint", "enabled")
      http_tokens                 = lookup(metadata_options.value, "http_tokens", "required")
      http_put_response_hop_limit = lookup(metadata_options.value, "http_put_response_hop_limit", "2")
      instance_metadata_tags      = lookup(metadata_options.value, "instance_metadata_tags", null)
    }
  }

  volume_tags = merge(local.default_tags, {
    Name = format("%s%s-%s", var.prefix, var.env, var.purpose)
  })

  tags = merge(local.default_tags, {
    Name = format("%s%s-%s", var.prefix, var.env, var.purpose)
  })

  lifecycle {
    ignore_changes = [
      ami,
    ]
  }
}

resource "aws_eip" "this" {
  count = var.required_eip ? 1 : 0

  instance = aws_instance.this.id

  tags = merge(local.default_tags, {
    Name = format("%s%s-%s-eip", var.prefix, var.env, var.purpose)
  })
}

resource "aws_iam_instance_profile" "this" {
  count = var.required_iam_role ? 1 : 0

  name = format("%s%s-%s-profile", var.prefix, var.env, var.purpose)
  role = aws_iam_role.this[0].name
}
