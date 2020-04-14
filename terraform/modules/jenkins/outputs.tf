output "jenkins_hostname" {
  value       = length(aws_instance.jenkins) > 0 ? aws_instance.jenkins[0].public_dns : ""
  description = "Jenkins hostname for SSH access."
}