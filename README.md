:bangbang: THIS IS AN ALPHA MODULE DO NOT USE IN PRODUCTION :bangbang:
======================================================================

AWS Windows Instance
============
This is an module to creates a DC/OS Windows AWS Instances.

If `ami` variable is not set. This module uses the latest AWS Windows AMI.

Using you own AMI *FIXME*
-----------------
If you choose to use your own AMI please make sure the DC/OS related
prerequisites are met. Take a look at https://docs.mesosphere.com/1.11/installing/ent/custom/system-requirements/install-docker-RHEL/

EXAMPLE
-------

```hcl
module "windows-agent" {
  source = "git::https://github.com/alekspv/terraform-aws-windows-instance.git?ref=features/windows-agent"
  num_winagent            = "2"
  admin_ips               = ["198.51.100.0/24"]
  vpc_id                  = "vpc-123456789"
  subnet_id               = "subnet-123456789"
  cluster_name            = "development"
  expiration              = "24h"
  owner                   = "John Dou"
  aws_key_name            = "${module.dcos.infrastructure.aws_key_name}"
  security_group_admin    = "${module.dcos.infrastructure.security_groups.admin}"
  security_group_internal = "${module.dcos.infrastructure.security_groups.internal}"
  bootstrap_private_ip    = "${module.dcos.infrastructure.bootstrap.private_ip}"
  bootstrap_public_ip     = "${module.dcos.infrastructure.bootstrap.public_ip}"
  bootstrap_os_user       = "${module.dcos.infrastructure.bootstrap.os_user}"
  ssh_private_key_file    = "~/.ssh/id_rsa"
  masters_private_ips     = "${module.dcos.infrastructure.masters.private_ips}"
}

```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| ami | AMI that will be used for the instance | string | n/a | yes |
| source | Path to module| string | n/a| yes |
| num_winagent | Number of windows agents | integer | 0 | yes |
| admin_ips | List of IP address  | list | n/a | yes |
| vpc_id | ID of VPC where agents will be created | string | n/a | yes |
| subnet_id | ID of subnet where agents will be created | string | n/a | yes |
| cluster_name | Name of cluster where agents will be created | string | n/a | yes |
| expiration | Time to live the agents | string | n/a | no |
| owner | Who owned the cluster | string | n/a | no |
| aws_key_name | Name of AWS key which to be added to EC2 instance for access | string | n/a | yes |
| security_group_admin | ID of admin security group | string | n/a | yes? |
| security_group_internal | ID of internal security group | string | n/a | yes? |
| bootstrap_private_ip | Privat IP address of bootstrap node | string | n/a | yes |
| bootstrap_public_ip | Public IP address of bootstrap node | string | n/a | yes |
| bootstrap_os_user | User for connecting by ssh to the bootstrap node | string | n/a | yes |
| ssh_private_key_file | Path to ssh key file | string | n/a | yes |
| masters_private_ips | IP address of master node | string | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| instances | List of instance IDs |
| private\_ips | List of private ip addresses created by this module |
| public\_ips | List of public ip addresses created by this module |

