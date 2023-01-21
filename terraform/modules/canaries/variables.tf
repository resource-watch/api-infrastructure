variable "email_recipients" {
  type        = list(string)
  description = "List of email addresses to contact in case an alert fails"
}
