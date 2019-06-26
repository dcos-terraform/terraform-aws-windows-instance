# :bangbang: THIS IS AN ALPHA MODULE DO NOT USE IN PRODUCTION :bangbang:
# ======================================================================

# AWS Windows Instance
# ============
# This is an module to creates a DC/OS Windows AWS Instances.

# f `ami` variable is not set. This module uses the latest AWS Windows AMI.

# Using you own AMI *FIXME*
# -----------------
# If you choose to use your own AMI please make sure the DC/OS related
# prerequisites are met. Take a look at https://docs.mesosphere.com/1.11/installing/ent/custom/system-requirements/install-docker-RHEL/

# EXAMPLE
# -------

# ```hcl
# module "windows-agent" {
#   source = "git::https://github.com/alekspv/terraform-aws-windows-instance.git?ref=features/windows-agent"
#   num_winagent            = "2"
#   admin_ips               = ["198.51.100.0/24"]
#   vpc_id                  = "vpc-123456789"
#   subnet_id               = "subnet-123456789"
#   cluster_name            = "development"
#   expiration              = "24h"
#   owner                   = "John Dou"
#   aws_key_name            = "${module.dcos.infrastructure.aws_key_name}"
#   security_group_admin    = "${module.dcos.infrastructure.security_groups.admin}"
#   security_group_internal = "${module.dcos.infrastructure.security_groups.internal}"
#   bootstrap_private_ip    = "${module.dcos.infrastructure.bootstrap.private_ip}"
#   bootstrap_public_ip     = "${module.dcos.infrastructure.bootstrap.public_ip}"
#   bootstrap_os_user       = "${module.dcos.infrastructure.bootstrap.os_user}"
#   ssh_private_key_file    = "~/.ssh/id_rsa"
#   masters_private_ips     = "${module.dcos.infrastructure.masters.private_ips}"
# }

# ```


data "aws_ami" "winAmi" {
 owners                               = ["amazon"]
  filter{
    name                              = "name"
    values                            = ["Windows_Server-1809-English-Core-ContainersLatest-2019.05.15"]
  }
}

resource "aws_security_group" "rdp" {
  description                         = "Allow incoming rdp traffic from admin_ips"
  vpc_id                              = "${var.vpc_id}"

      tags = {
        Name                          = "allow_rdp"
      }
      ingress {
        from_port                     = 3389
        to_port                       = 3389
        protocol                      = "tcp"
      cidr_blocks                     = ["${var.admin_ips}"]
            }
      ingress {
        from_port                     = 3389
        to_port                       = 3389
        protocol                      = "udp"
      cidr_blocks                     = ["${var.admin_ips}"]
            }
      ingress {
        from_port                     = 0
        to_port                       = 65535
        protocol                      = "tcp"
      cidr_blocks                     = ["0.0.0.0/0"]
            }
    }

resource "aws_instance" "mesos-agent-windows" {
  count                               = "${var.num_winagent}"
  ami                                 = "${data.aws_ami.winAmi.id}"
  instance_type                       = "t3.xlarge"
  get_password_data                   = "true"
  root_block_device {
    volume_type                       = "gp2"
    volume_size                       = 230
    }
  tags = {
    Name                              = "${var.cluster_name}-winagent-${count.index}"
    expiration                        = "${var.expiration}"
    owner                             = "${var.owner}"
  }
  key_name                            = "${var.aws_key_name}"
  subnet_id                           = "${element(var.subnet_id,0)}"
  security_groups                     = ["${list(
      var.security_group_internal,
      var.security_group_admin,
      aws_security_group.rdp.id)}"]

  user_data                           = <<-EOF
  <script>
    winrm quickconfig -q & winrm set winrm/config @{MaxTimeoutms="1800000"} & winrm set winrm/config/service @{AllowUnencrypted="true"} & winrm set winrm/config/service/auth @{Basic="true"}
  </script>
  <powershell>
  New-SelfSignedCertificate -DnsName $(Invoke-RestMethod -uri http://169.254.169.254/latest/meta-data/local-hostname) -CertStoreLocation Cert:\LocalMachine\My 
  New-Item WSMan:\localhost\Listener -Address * -Transport HTTPS -HostName $(Invoke-RestMethod -uri http://169.254.169.254/latest/meta-data/local-hostname) -CertificateThumbPrint $(ls Cert:\LocalMachine\My).Thumbprint -Force
  Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled False
  Set-MpPreference -DisableRealtimeMonitoring $true

  </powershell>
                    EOF
}

resource "null_resource" "run_ansible_from_bootstrap_node_to_install_dcos" {
    triggers {
    bootstrap_instance               = "${var.bootstrap_public_ip}"

    bootstrap_ip                     = "${var.bootstrap_private_ip}"
    master_instances                 = "${join(",", var.masters_private_ips)}"
    private_agents_instances         = "${join(",", aws_instance.mesos-agent-windows.*.private_ip)}"
  }

  connection {
    host                             = "${var.bootstrap_public_ip}"
    user                             = "${var.bootstrap_os_user}"
}

  provisioner "file" {
    destination                      = "/tmp/win_inventory"
    content                          = <<EOF
    ansible_python_interpreter=/usr/bin/python
    [bootstraps]
    [masters]
    ${join("\n",var.masters_private_ips) }
    [agents_private]
    [agents_public]
    [win_agents]
    ${join("\n",null_resource.pass.*.triggers.var.adm) }
    [win_agents:vars]
    ansible_user=Administrator
    ansible_connection=winrm
    ansible_winrm_server_cert_validation=ignore
    dcos_version="1.13"
    [agents:children]
    agents_private
    agents_public
    [dcos:children]
    bootstraps
    masters
    agents
    agents_public
    [linux:children]
    bootstraps
    masters
    agents_public
    agents_private
    [windows:children]
    win_agents
    EOF
  }

  provisioner "file" {
    source                           = "${path.module}/files/"
    destination                      = "/tmp"
  }


  provisioner "remote-exec" {
    inline                         = [
      "rm -rf /tmp/dcos-ansible ; sudo yum install git -y && cd /tmp && git clone -b feature/windows-agent-support https://github.com/alekspv/dcos-ansible && cd /tmp/dcos-ansible && sudo docker build -t dcos-ansible-bundle-win . && sudo docker run -it -v /tmp/win_inventory:/inventory -v /tmp/ansible.cfg:/ansible.cfg  dcos-ansible-bundle-win ansible-playbook -i inventory  -l win_agents dcos_playbook.yml"
    ]
  }

}

resource "null_resource" "pass" {
  count                              = "${var.num_winagent}"
  triggers                           = {
var.adm = "${aws_instance.mesos-agent-windows.*.private_ip[count.index]}   pass=${rsadecrypt(aws_instance.mesos-agent-windows.*.password_data[count.index], file("${var.ssh_private_key_file}"))}"
}
}

