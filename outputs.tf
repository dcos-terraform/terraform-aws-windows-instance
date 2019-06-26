output "public_ips" {
  description = "List of public IP address"
  value       = "${aws_instance.mesos-agent-windows.*.public_ip}"
}

output "private_ips" {
  description = "List of private IP address"
  value       = "${aws_instance.mesos-agent-windows.*.private_ip}"
}
output "instances" {
  description = "ID of instances"
  value       = "${aws_instance.mesos-agent-windows.*.id}"
}

