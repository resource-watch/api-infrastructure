#################################################
# These 4 templates are probably not used anymore
#################################################

resource "sparkpost_template" "rw-dataset" {
  content_from_email     = "no-reply@resourcewatch.org"
  content_subject        = "Alerts"
  name                   = "Dataset alert (Resource Watch)"
  options_click_tracking = true
  options_open_tracking  = true
  options_transactional  = false
  published              = true
  content_html           = file("${path.module}/templates/rw-dataset.html")
}

resource "sparkpost_template" "recover-password" {
  content_from_email     = "{{fromEmail}}"
  content_from_name      = "{{fromName}}"
  content_subject        = "Recover password"
  name                   = "Recover password"
  options_click_tracking = true
  options_open_tracking  = true
  options_transactional  = false
  published              = true
  content_html           = file("${path.module}/templates/recover-password.html")
}

# Probably belonged to CT and can be removed
resource "sparkpost_template" "confirm-user" {
  content_from_email     = "{{fromEmail}}"
  content_from_name      = "{{fromName}}"
  content_subject        = "Confirm user"
  name                   = "Confirm user"
  options_click_tracking = true
  options_open_tracking  = true
  options_transactional  = false
  published              = true
  content_html           = file("${path.module}/templates/confirm-user.html")
}

# Probably belonged to CT and can be removed
resource "sparkpost_template" "confirm-user-with-password" {
  content_from_email     = "{{fromEmail}}"
  content_from_name      = "{{fromName}}"
  content_subject        = "Confirm user"
  name                   = "Confirm user with password"
  options_click_tracking = true
  options_open_tracking  = true
  options_transactional  = false
  published              = true
  content_html           = file("${path.module}/templates/confirm-user-with-password.html")
}
