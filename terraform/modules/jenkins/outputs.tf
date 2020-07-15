output "jenkins_hostname" {
  value       = aws_instance.jenkins.public_dns
  description = "Jenkins hostname for SSH access."
}