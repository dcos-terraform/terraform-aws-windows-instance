variable "vpc_id" {
  description = "VPC id for new agents"
  default     = ""
}

variable "subnet_id" {
  type = "list"
  description = "Subnet for new agent"
}

variable "admin_ips" {
  type = "list"
  description = "List of admin IP adresses"
}

variable "num_winagent" {
  description = "Number of windows agents"
  default = "0"
}

variable "cluster_name" {
  description = "Name of cluster where we will connecting new agnets"
  default = ""
}

variable "expiration" {
  description = "Time to live the agents"
  default = "24h"
}

variable "owner" {
  description = "Who owned the agents"
  default = ""
}

variable "aws_key_name" {
  description = "ssh key for access to EC2 servers"
  default = ""
}

variable "security_groups" {
  description = "List of security groups"
  type = "list"
}

variable "bootstrap_public_ip" {
  description = "Parameter of bootstrap node"
}

variable "bootstrap_private_ip" {
  description = "Parameter of bootstrap node"
}

variable "bootstrap_os_user" {
  description = "Parameter of bootstrap node"
}

variable "ssh_private_key_file" {
  description = "Private ssh key"
  default = ""
}

variable "masters_private_ips" {
  type = "list"
  description = "List privat IP addresses of master nodes"
}

variable "rdp_port" {
  description = "Port for connection by RDP"
  default = 3389
}

variable "agent_instance_type" {
  description = "Type of instance"
  default = "t3.xlarge"
}

variable "get_password_data" {
  default = "true"
}

variable "agent_volume_type" {
  description = "Volume type for agent nodes"
  default = "gp2"
}

variable "agent_volume_size" {
  description = "Volume size for agent nodes"
  default = 230
}

variable "user_data" {
  description = "User data"
  default = <<-EOF
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

variable "remote-exec-inline" {
  description = "Commad wich executed by bootstrap node for windows agents"
  default = "rm -rf /tmp/dcos-ansible ; sudo yum install git -y && cd /tmp && git clone -b feature/windows https://github.com/alekspv/dcos-ansible && cd /tmp/dcos-ansible && sudo docker build -t dcos-ansible-bundle-win . && sudo docker run -it -v /tmp/win_inventory:/inventory -v /tmp/ansible.cfg:/ansible.cfg -v dcos.yml:/dcos-playbook.yml -v /tmp/mesosphere_universal_installer_dcos.yml:/dcos.yml dcos-ansible-bundle-win ansible-playbook -i inventory -l agents_windows dcos_playbook.yml -e @/dcos.yml"
}


locals {
  agent_security_groups = ["${var.security_groups}", "${aws_security_group.rdp.id}"]
}