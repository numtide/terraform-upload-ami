# terraform-upload-ami
Upload and import the AMI from a VHD
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 4.26.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_ami.ami](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ami) | resource |
| [aws_ebs_snapshot_import.ami](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ebs_snapshot_import) | resource |
| [aws_iam_role.ami_importer](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.ami_importer](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_s3_object.ami](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_object) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_bucket_arn"></a> [bucket\_arn](#input\_bucket\_arn) | Bucket ARN | `any` | n/a | yes |
| <a name="input_bucket_name"></a> [bucket\_name](#input\_bucket\_name) | Bucket ID where to upload the VHD to | `any` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Name of the image | `any` | n/a | yes |
| <a name="input_object_key"></a> [object\_key](#input\_object\_key) | Name of the key to use in S3 | `any` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | AWS Tags to apply on all the objects | `map(string)` | n/a | yes |
| <a name="input_vhd_path"></a> [vhd\_path](#input\_vhd\_path) | Path to the VHD to upload | `any` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ami_id"></a> [ami\_id](#output\_ami\_id) | n/a |
